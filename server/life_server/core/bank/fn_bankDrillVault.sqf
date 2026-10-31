 
_unit = [_this,0,Objnull,[Objnull]] call BIS_fnc_param;
if (isNull _unit) exitWith {};
if (life_bank_drilling) exitWith {
    // LooneyBin: the cop "Disable Drill" action (fn_stopBankRobbery) calls this SAME fn -- the 2020
    // client had a stop mode the 2017 fn lacks. Cop + drilling = kill the drill loop (fail the robbery).
    if (side _unit isEqualTo west) then {life_bank_drilling = false;
        publicVariable "life_bank_drilling";
        // owner 2026-06-16 (#290): tell EVERYONE (incl. the robbers/civs) the APD disarmed it -- previously
        // only cops got the "no longer being robbed" line, so civs had no idea the drill had been stopped.
        [[[0,1,2], format ["The APD has DISARMED the bank vault drill -- the robbery is over."]], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
        ["resolve", "bank", "no"] call TON_fnc_sportsbookResolve;   // LoonyBets: APD stopped it
    };};

// owner 2026-06-13: SERVER-AUTHORITATIVE cop gate (4 cops for the bank). The requirement was client-only;
// a JIP client whose PLB_betaZeroCops hadn't synced (getVariable default TRUE) could start it understaffed.
// Past the drilling check above this is always a fresh START, so gate non-cop callers. Flat top-level
// exitWith (a then{}-nested exitWith would only exit the block, not the script -> robbery would still run).
// owner 2026-06-22 (#496): count only TENURED cops (continuously on-duty >= PLB_copTenureReq), not a raw side
// snapshot -- blocks soft-logging whitelisted members to cop just long enough to satisfy the 4-cop gate.
if ((side _unit isNotEqualTo west) && {!(missionNamespace getVariable ["PLB_betaZeroCops", false])} && {([] call PLB_fnc_tenuredCops) < 4}) exitWith {
    [[2, "The bank cannot be robbed with fewer than 4 police officers online."], "life_fnc_broadcast", _unit, false] spawn life_fnc_MP;};
// owner 2026-06-16 (#302): server-authoritative one-federal-event-at-a-time gate (client check has a window).
if (["bank"] call PLB_fnc_fedEventActive) exitWith {
    [[2, "Another major crime is already in progress -- the bank drill won't start."], "life_fnc_broadcast", _unit, false] spawn life_fnc_MP;
};
// owner 2026-07-02 (#575): SERVER-AUTHORITATIVE bank re-rob cooldown. #302 excludes "bank" from its own check,
// so nothing server-side blocked a BACK-TO-BACK bank job -- the 20-min re-rob window lived ONLY in the client
// action condition (fn_setupActions: (life_bank_robbed select 1) < serverTime - 1200), so a re-fired
// TON_fnc_bankRobbery (JIP/desync/remoteExec) past the drilling flag re-ran the drill + re-spawned the FULL
// payout every time. Mirror the client's 1200s window here off life_bank_robbed[1] (set to the finish time on
// completion). A legit action already waited out the window, so this never blocks normal play.
private _lastRob = (missionNamespace getVariable ["life_bank_robbed", [false, -99999]]) param [1, -99999];
if (_lastRob > (serverTime - 1200)) exitWith {
    [[2, format ["Security is high after the last bank robbery -- try again in %1 minute(s).", ceil ((1200 - (serverTime - _lastRob)) / 60)]], "life_fnc_broadcast", _unit, false] spawn life_fnc_MP;
};

life_bank_drilling = true;
publicVariable "life_bank_drilling";
life_bank_robbed = [true, serverTime];   // LooneyBin: client drill-action condition var (see vars.sqf)
publicVariable "life_bank_robbed";
 
_dispatch = ceil (random 9000); 
[_dispatch, "Bank Robbery", 5000, 5, 4, position life_bank_building, ""] spawn life_fnc_createDispatch; 
 
_robbers = []; {if (_x distance life_bank_building < 300 && side _x != west) then { _robbers pushBack _x };} forEach allPlayers;
// LooneyBin 2026-06-11: charge every civilian within 90m with "Bank Robbery" (charge ID 4). The 2017 code
// called life_fnc_wantedAdd which NEVER existed in this build -> no charge was ever applied. TON_fnc_wantedAdd
// is the live server-side wanted pipeline (relays to the offender's client + rebuilds the cop wanted list).
{if (_x distance life_bank_building < 90 && side _x isEqualTo civilian) then { [4, _x] call TON_fnc_wantedAdd; };} forEach allPlayers;

// owner 2026-07-05: drill-progress feedback -- fire it ONCE here (in-scope _robbers). The "bank_robbery" message
// (fn_createMessage) is a red box with a thin bar that DRAINS over the 15-min duration = the visible countdown,
// and self-clears when life_bank_robbed[0] goes false. This replaces both the every-second re-send below (which
// ran inside the drill spawn where _robbers was nil -> never rendered / would have stacked boxes) and the
// top-right notification loop in initPlayerLocal (which spammed the "15 minutes" pop-up).
["Robbery in Progress!", "bank_robbery", {life_bank_robbed select 0}] remoteExec ["life_fnc_handleMessage", _robbers];

[_dispatch, _robbers] spawn {private ["_dispatch", "_robbers"];
_dispatch = _this select 0; 
_robbers = _this select 1; 
// LooneyBin: wanted charge now applied via the 90m TON_fnc_wantedAdd pass above (life_fnc_wantedAdd never existed).
sleep 35;
if (count _robbers < 2 || !life_bank_drilling || life_activeSWAT) exitWith {}; 
if (life_swat_instance == 0) then {life_swat_instance = _dispatch;
_swatPos = switch (worldName) do {
case "Altis": { [["Office Building",[14942,11150,0]],["Small Lighthouse",[14722,11207,0]],["East Bay",[15278.7,10843,0]],["East Faronaki",[15209.9,10968.7,0]],["North Rocks",[15150.8,11538.0,0]],["Halo Jump",[14771.2,11015.4,1500]]] }; 
case "Tanoa": { [["Regina Gas",[5031,3927,0]],["Bay Rocks",[4424,3876,0]],["South Peninsula",[4432,3115,0]],["East Bay",[4863,3568,0]],["Regina East",[5087,3529,0]],["Halo Jump",[3985,3321,1500]]] }; 
default { [["Runway Hanger",[1740,5226,0]],["Nisi Bay",[1915,4192,0]],["Air Base",[2160,5588,0]]] };};
[count _robbers, _swatPos, getPos life_bank_building] spawn life_fnc_swatDispatch;};};
 
[_unit] spawn {while {life_bank_drilling} do {
playSound3D [MISSION_ROOT + "sounds\bankalarm.ogg", life_bank_building, false, getPos life_bank_building, 10, 1, 50];  
sleep 1.2;};};
 
[_dispatch, _unit] spawn {private ["_dispatch", "_unit"];
_dispatch = _this select 0; 
_unit = _this select 1; 
deleteMarker "bankMarker"; 
createMarker ["bankMarker", position life_bank_building]; 
"bankMarker" setMarkerShape "ICON"; 
"bankMarker" setMarkerType "mil_dot"; 
"bankMarker" setMarkerColor "ColorRed"; 
"bankMarker" setMarkerText "Robbery in Progress"; 
 
life_bank_building setVariable ["bis_disabled_Door_4", 1, true]; 
life_bank_building animate ["door_4_rot", 0]; 
 
// BUGS.md #95: 2017-era hardcoded pos sat ~32m from this mission's bank door -> "no visual drill".
// Anchor on the life_bank_door marker (where the drill ACTION lives), fall back to the building.
_drillPos = getMarkerPos "life_bank_door";
if (_drillPos isEqualTo [0,0,0]) then { _drillPos = getPosATL life_bank_building; };
_drillPos set [2, 0];
_drill = "Land_DrillAku_F" createVehicle _drillPos;
_drill setDir (getDir life_bank_building);
_drill setPosATL _drillPos;
_drill setVariable ["owner", _unit, true];
// LooneyBin 2026-06-11: disable sim AFTER positioning + a short delay. Disabling it on the same frame as
// createVehicle can leave the prop unstreamed/invisible on remote clients ("drill not showing on the door").
uiSleep 0.5;
if (!isNull _drill) then { _drill enableSimulationGlobal false; };
 
[[_unit, "drilling", 30],"life_fnc_playSound",true,false] spawn life_fnc_MP; 
 
_success = false;
_elapsed = 0;
while {life_bank_drilling} do {sleep 1;
_elapsed = _elapsed + 1;
// owner 2026-07-05: drill-progress feedback moved to a SINGLE send at kickoff (above). The createMessage draining
// bar is the 15-min countdown; re-sending here every second targeted a nil _robbers (out of scope in THIS spawn)
// and would have stacked message boxes. Removed.

// owner 2026-06-15: success was tied to the ORIGINAL driller (_unit) staying alive + within 60m. If they
// died, disconnected, or stepped >60m away (even near the end), the WHOLE crew got no door + no dirty money
// despite "completing" the 10-min drill. Now it only fails if the bank is fully ABANDONED -- the drill holds
// as long as ANY living civilian robber is within 60m. (Also fixes the dead "restrained" var, was plb_restrained.)
private _crewHolding = { (side _x isEqualTo civilian) && {alive _x} && {!(_x getVariable ["plb_restrained", false])} && {(_x distance (getPos life_bank_building)) <= 60} } count allPlayers;
if (_crewHolding isEqualTo 0) exitWith {_success = false};
if (_elapsed >= 900) exitWith {_success = true};   // 15-min drill window (owner 2026-07-18: keep original bank timer; Terminal Breach only GATES the start)
};
 
_policeSuccess = !_success; 
[[_dispatch, _policeSuccess],"life_fnc_finishDispatch",west,false] spawn life_fnc_MP; 
 
if (life_swat_instance == _dispatch) then {_dispatch spawn {sleep 300;
if (life_swat_deployed && life_swat_instance == _this) then {[] call life_fnc_swatDeactivate;};};};
[[[0,1,2],"The Bank of Altis is no longer being robbed."],"life_fnc_broadcast",west,false] spawn life_fnc_MP; 
 
deleteVehicle _drill; 
"bankMarker" setMarkerText "Elevated Security"; 
[] spawn {sleep 1100;
deleteMarker "bankMarker";};
 
if (_success) then {
 
// LooneyBin 2026-06-13 (owner): DIRTY MONEY payout -- base $50k + $50k per cop online, even with zero
// cops. (Old loot used setVariable["item",...] (2017 pickup) which NOTHING in the 2020 client reads ->
// inert props, "money isn't spawning". Now a Dirty Money (bank_money) pile via plb_droppedItems, the
// live pickup system; launders 1:1 into cash 5 min after pickup via Y-menu.)
private _copsOnline = { side _x isEqualTo west } count allPlayers;
private _payout = 50000 + (50000 * _copsOnline);
// owner 2026-06-16: pay the vault out as MULTIPLE BRIEFCASES that ANYONE can grab (was a single owned
// Land_Money_F pile -> effectively only the first/driller got the whole pot). Split the payout across N
// ownerless suitcases spread over the vault floor so the whole crew can each grab one. No plb_owner var ->
// the Y-menu pickup (fn_menuPickupItems) is open to anyone standing on it.
private _casePos = switch (worldName) do {
case "Altis": { [[14786.625977,10755.871094,1.20139],[14786.585938,10756,1.20139],[14786.545898,10756.128906,1.20139],[14786.505859,10756.257813,1.20139],[14785.614258,10755.719727,1.26389],[14785.617188,10755.854492,1.26389],[14785.620117,10755.989258,1.26389],[14785.623047,10756.124023,1.26389],[14785.625977,10756.258789,1.26389],[14785.628906,10756.393555,1.26389]] };
case "Tanoa": { [[4171.703,8393.295,1.55],[4172.047,8393.428,1.55],[4172.368,8393.493,1.55],[4174.243,8392.506,1.55],[4173.892,8392.412,1.55],[4173.563,8392.349,1.55],[4174.552,8391.642,1.55],[4174.238,8391.578,1.55],[4173.9,8391.505,1.55],[4169.578,8392.166,1.438]] };
default { [[2097.0708008,5634.387207,1.02651],[2097.202637,5634.359375,1.02651],[2097.334473,5634.331543,1.02651],[2097.466309,5634.303711,1.02651],[2097.598145,5634.275879,1.02651],[2097.276611,5635.290039,1.02651],[2097.408447,5635.262207,1.02651],[2097.540283,5635.234375,1.02651],[2097.672119,5635.206543,1.02651],[2097.803955,5635.178711,1.02652]] };
};
// owner 2026-06-18 (briefcases spawn OUTSIDE the vault / #364 "briefcase didn't spawn"): OVERRIDE the hardcoded
// _casePos above -- those coords were ~28m from the vault door (the bank building MOVED but the coords never
// updated), so briefcases spawned out in the open / looked un-spawned. Re-anchor on the SAME spot the drill +
// player use (life_bank_door marker), offset ~2m INSIDE toward the building interior, clustered. Robust to the
// bank's actual position (works on any map with the marker). ⚠ verify the inside-offset in-game; tune the 2m.
// owner 2026-06-19 (#377/#349): the life_bank_door anchor above is the EXTERIOR drill spot, so the briefcases
// still landed out front of the bank. Anchor on the REAL vault-INTERIOR coord (owner-clipboarded). Cluster the
// cases around it (5x2 grid) at the vault floor height.
private _vaultPos = switch (worldName) do {case "Altis": { [14765.7, 10732, 0.44] };
    default {private _dp = getMarkerPos "life_bank_door";
        if (_dp isEqualTo [0,0,0]) then { _dp = getPosATL life_bank_building; };
        _dp getPos [2, (_dp getDir (getPosATL life_bank_building))]};};
_casePos = [];
for "_k" from 0 to 9 do {private _col = _k mod 5; private _row = floor (_k / 5);
    _casePos pushBack [(_vaultPos select 0) + ((_col - 2) * 0.45), (_vaultPos select 1) + (_row * 0.5), (_vaultPos select 2)];};
private _caseDir = if (worldName == "Altis") then { -16.326 } else { 76.948 };
private _numCases = (((_copsOnline + 2) max 4) min (count _casePos));
private _share = floor (_payout / _numCases);
private _cases = [];
for "_i" from 0 to (_numCases - 1) do {private _cp = _casePos select _i;
private _case = "Land_Suitcase_F" createVehicle _cp;
_case setDir _caseDir;
_case enableSimulationGlobal false;
_case setPosATL _cp;
_case setVectorUp [0,0,1];
private _amt = if (_i isEqualTo (_numCases - 1)) then { _payout - (_share * (_numCases - 1)) } else { _share };  // last case carries the rounding remainder
_case setVariable ["plb_droppedItems", [["bank_money", _amt]], true];
_cases pushBack _case;};
// owner 2026-07-18: 1 crypto MINING COMPONENT in a case NEXT TO the vault cash (retires the standalone mining
// crate). Looted via the same locked pickup; reaped with the cash on the 3-min sweep (pushed to _cases).
private _compCase = "Land_Suitcase_F" createVehicle _vaultPos;
_compCase setDir _caseDir;
_compCase enableSimulationGlobal false;
_compCase setPosATL [(_vaultPos select 0) + 1.35, (_vaultPos select 1) + 0.25, _vaultPos select 2];
_compCase setVectorUp [0,0,1];
_compCase setVariable ["owner", "bank_component", true];
_compCase setVariable ["plb_droppedItems", [[selectRandom ["cryptoCPU","cryptoGPU","cryptoPSU","cryptoStorage","cryptoMotherboard","cryptoRam","cryptoCooler","cryptoCase"], 1]], true];
_cases pushBack _compCase;
diag_log format ["[LooneyBin][bank] vault success: %1 cop(s) online -> $%2 across %3 briefcase(s)", _copsOnline, _payout, _numCases];
// post-heist: reset the pot so back-to-back jobs don't compound (re-grows +7k/5min from base)
life_bank_funds = 10000;
publicVariable "life_bank_funds";

life_bank_building setVariable ["bis_disabled_Door_4", 0, true];
life_bank_building animate ["door_4_rot", 1];
[[[0,1,2],"The vault is OPEN for 3 minutes -- grab the briefcases!"],"life_fnc_broadcast",-2,false] spawn life_fnc_MP;
["resolve", "bank", "yes"] call TON_fnc_sportsbookResolve;   // LoonyBets: vault cracked
[_cases] spawn {params ["_cases"];
sleep (3*60);
life_bank_building setVariable ["bis_disabled_Door_4", 1, true];
life_bank_building animate ["door_4_rot", 0];
{ if (!isNull _x) then { deleteVehicle _x }; } forEach _cases;};}
else {life_bank_building setVariable ["bis_disabled_Door_4", 1, true];
life_bank_building animate ["door_4_rot", 0];};
 
life_bank_drilling = false;
life_bank_last = serverTime;
life_bank_funds = 10000;
life_bank_robbed = [false, serverTime];   // ends robbery + starts the client action's 20-min re-rob window
SRV_lastRobbery = serverTime;             // 15-min "security is high" cross-fed cooldown
publicVariable "life_bank_drilling";
publicVariable "life_bank_funds";
publicVariable "life_bank_last";
publicVariable "life_bank_robbed";
publicVariable "SRV_lastRobbery";};
 
[[[0,1,2],"The alarm at the BANK OF ALTIS has been activated!"],"life_fnc_broadcast",west,false] spawn life_fnc_MP;