// life_fnc_startPrisonBreak (LooneyBin compat) -- MIRROR of server/life_server/core/jail/fn_startPrisonBreak.sqf
// FIX 2026-07-18 (compat-stub shadow): this file shipped as a reverse-drift no-op stub
// (`if (true) exitWith {};`). Because the mission ALSO registers life_fnc_startPrisonBreak, the no-op
// SHADOWED the real @life_server impl on the server (mission CfgFunctions wins) -> every
// server-internal call silently did nothing -> the prison-break event never actually ran: no jail alarm, no broadcast, no red 'Break in Progress' marker, no dispatch/SWAT.
// Restored to the real impl. The isServer guard makes it a safe no-op on clients (which lack
// the server-authoritative vars); all real callers are server-internal. Keep in sync w/ the twin.
if (!isServer) exitWith {};
 
private["_unit","_jailId","_start","_soundOn","_dispatch"]; 
 
_unit = [_this,0,Objnull,[Objnull]] call BIS_fnc_param; 
_jail = [_this,1,1,[1]] call BIS_fnc_param; 
_npc = [_this,2,Objnull,[Objnull]] call BIS_fnc_param; 
 
if (isNull _unit || isNull _npc) exitWith {}; 
 
_soundOn = createSoundSource ["Sound_Alarm", getMarkerPos "jail_marker2", [], 0]; 
_start = time;
private _holdAnchor = getPosATL _unit;   // owner 2026-06-23: 500m hold radius anchored where the break started (the laptop) -- old check was _unit distance _npc with _npc=_unit = always 0 (never enforced)
 
"corrections" setMarkerText "Prison [Break in Progress]"; 
"corrections" setMarkerColor "ColorRed"; 
 
[[0, format["%1 has initiated a prison break!", name _unit]],"life_fnc_broadcast",civilian,false] spawn life_fnc_MP; 
[[[0,1,2], format["%1 has initiated a prison break!", name _unit]],"life_fnc_broadcast",west,false] spawn life_fnc_MP; 
 
life_prison_inProgress = true; 
publicVariable "life_prison_inProgress"; 
 
_dispatch = ceil (random 9000); 
[_dispatch, "Prison Break", 5000, 3, 4, getMarkerPos "jail_marker2", ""] spawn life_fnc_createDispatch; 
 
if (life_swat_instance == 0) then {life_swat_instance = _dispatch;
[_npc] spawn {_npc = _this select 0;
sleep 35; 
_units = []; 
{ if (side _x == civilian && _x distance _npc < 300 && !(primaryWeapon _x == "" && handgunWeapon _x == "")) then { _units pushBack _x }; } forEach allPlayers; 
_swatPos = switch (worldName) do {
case "Altis": { [["Police HQ",[17465,13274,0]],["Naval East",[17295,13938,0]],["Naval West",[16317.1,12838.3,0]],["North Pyrgos",[16676.9,13045.3,0]],["Halo Jump",[16473.2,13648.3,1500]]] }; 
case "Tanoa": { [["Farmstead",[11421,11110,0]],["Cliffside",[10717,11732,0]],["Road Fork",[10669,11582,0]],["North Pyrgos",[11229,11644,7.5]],["Halo Jump",[11110,11500,2000]]] }; 
case "Stratis": { [["Hill Camp",[6594,5328,0]],["Lighthouse",[6597,5170,0]],["Crossroads",[6018,4941,0]],["Construction",[6029,5618,0]]] }; 
case "Australia": { [["Garage",[29267,17515,0]],["Farmstead",[30603,17885,0]],["Willcania PD",[31413,16913,0]],["Lumber Mill",[28958,16570,0]]] }; 
}; 
if(life_activeSWAT || !life_prison_inProgress || count _units < 2) exitWith {}; 
[count _units, _swatPos, getMarkerPos "jail_marker2"] spawn life_fnc_swatDispatch;};};
 
_breakTimer = if (worldName == "Australia") then { 600 } else { 800 };   // owner 2026-06-23: +5min hold (was 300/500). MUST match the client hold-bar _holdTime in core/civilian/fn_doPrisonBreak.sqf.
[[1, format["You've initiated a prison break. Stay within 500 meters for %1 minutes and do not enter a vehicle.", _breakTimer / 60]],"life_fnc_broadcast",_unit,false] spawn life_fnc_MP; 
waitUntil {sleep 2; (!alive _unit || _unit getVariable ["restrained",false] || vehicle _unit != _unit || (_unit distance2D _holdAnchor) > 500 || (time - _start) > _breakTimer)};   // owner 2026-06-23: 15m->500m, anchored on start/laptop
 
_criminals = []; 
{ if (side _x == civilian && !(_x getVariable ["prisoner",false]) && _x distance (getMarkerPos "corrections") < 100) then {_criminals pushBack _x}; } forEach allPlayers; 
 
if ((time - _start) > _breakTimer && alive _unit && vehicle _unit == _unit && !(_unit getVariable ["restrained",false])) then {
[[[0,1], "You have successfully completed a prison break!"],"life_fnc_broadcast",_unit,false] spawn life_fnc_MP; 
if (worldName != "Australia") then { [[name _unit,_jail],"life_fnc_prisonBreakQuery",true,false] spawn life_fnc_MP; }; 
[[_dispatch, false],"life_fnc_finishDispatch",west,false] spawn life_fnc_MP; {
[[_unit],"life_fnc_prisonBreaker",_x,false] spawn life_fnc_MP;} forEach _criminals;}
else {[[[0,1], "You have failed the prison break and nobody made it out."],"life_fnc_broadcast",_unit,false] spawn life_fnc_MP;
[[[0,1,2], format["The prison break has been quelled!"]],"life_fnc_broadcast",west,false] spawn life_fnc_MP; 
[[_dispatch, true],"life_fnc_finishDispatch",west,false] spawn life_fnc_MP;};
 
deleteVehicle _soundOn; 
"corrections" setMarkerText format["%1 Maximum Security Prison", worldName]; 
"corrections" setMarkerColor "ColorWEST"; 
 
life_lastPrison = time; 
publicVariable "life_lastPrison"; 
life_prison_inProgress = false;
publicVariable "life_prison_inProgress";
// owner 2026-06-19 (#342): also clear the NEW server gate SRV_prisonData[1]. The case-1 start-gate in
// TON_fnc_handlePrisonBreak reads SRV_prisonData[1], but this completion only reset the legacy
// life_prison_inProgress -> the gate stayed TRUE until the 20-min watchdog cap, so a NEW break was blocked
// for up to 20 min after a finished one ("prison break not working after a successful prison break").
// owner 2026-06-21 (#481 "release didn't let me out"): DEFER this clear ~70s. It fired in the SAME frame as the
// release above (life_fnc_prisonBreaker sets life_breakout, the Yes/No escape dialog goes out), but the client
// release gate (fn_jailMe.sqf:98) needs SRV_prisonData[1] AND life_breakout true together, the jail loop ticks
// ~1s, and the escape dialog allows ~65s to click Yes -> clearing it instantly killed the AND before the
// prisoner could leave. Delay it so the release window + a late click work, then clear so a NEW break can start
// (preserves the #342 fix above -- just 70s instead of the old 20-min watchdog cap, not instant).
if (!isNil "SRV_prisonData") then { [] spawn { uiSleep 70; SRV_prisonData set [1, false]; publicVariable "SRV_prisonData"; }; };
 
if (life_swat_instance == _dispatch) then {_dispatch spawn {sleep 300;
if (life_swat_deployed && life_swat_instance == _this) then {[] call life_fnc_swatDeactivate;};};};