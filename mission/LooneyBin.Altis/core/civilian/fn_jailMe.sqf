params[["_ret", [], [[]]], ["_jailSpawn", "jail_marker2", [""]], ["_jailRelease", "jail_release2", [""]]];
_ret params[["_name", "", [""]], ["_PID", "", [""]], ["_crimes", [], [[]]], ["_bounty", 1500, [0]]];
private _charges = A_stats_crimes select[1, count A_stats_crimes];
private _chargeTimes = ["getChargeTimes"] call life_fnc_wantedChargesConfig;
private _deathPenMinimum = 100000;
private _jailTime = 0; {if (_x > 0) then {_jailTime = _jailTime + ((_chargeTimes select _forEachIndex) * _x)};}
forEach _charges;
life_is_arrested set[0, 1];
life_is_arrested set[1, _bounty];
if ((life_is_arrested select 2) isEqualTo 0) then {life_is_arrested set[2, _jailTime]};
life_bail_paid = false;
life_breakout = false;
// LooneyBin bail fix (2026-07-18): life_fnc_wantedPerson is a dead compat stub, so the server-passed _ret was
// ALWAYS empty and _bounty fell to its 1500 param default -> every prisoner bailed for a flat $1500 regardless
// of their real wanted level. jailMe runs on the OFFENDER'S OWN client, where A_stats_crimes[0] IS the live,
// authoritative accumulated wanted $ (set by fn_wantedListAdd) = the full bail. Use it directly (no server
// lookup, no sync race); keep _bounty (>=1500 default, or the real value once wantedPerson is restored) only as
// a floor so a 0-wanted edge can't yield a $0 free release.
life_bail_amount = (A_stats_crimes param [0, 0]) max _bounty;
private _jailSpawnPos = getMarkerPos _jailSpawn;
private _jailReleasePos = getMarkerPos _jailRelease;
player setPosATL _jailSpawnPos;
// LooneyBin: clear the restraint on jailing so the prisoner can actually move in the cells
if (alive player) then { player switchMove ""; player setVariable ["plb_escorting", false, true]; player setVariable ["plb_transporting", false, true]; player setVariable ["plb_restrained", false, true]; detach player; };
closeDialog 0;
["ALL"] call life_fnc_seizePlayerIllegalAction;
[5] call life_fnc_ClUpdatePartial;
[0] call life_fnc_virtItemCfg;
// LooneyBin #514: a player blindfolded by a skip-tracer / bounty hunter who is then sent to prison was
// left with a PERMANENTLY BLACK screen (and still flagged blinded). The arrest path
// (fn_arrestAction -> TON_fnc_handleJail -> life_fnc_jailMe) bypasses fn_jailPlayer, and jailMe only nil'd the
// plb_blinded flag -- it never reversed fn_blindfoldClient's blackout (`cutText "BLACK FADED"; 0 cutFadeOut
// 9999999`) nor removed the blindfold goggles. So the prisoner reached jail still blacked out + blindfolded
// (exactly the report: "sent me to jail, screen still black, says I am blindfolded"). Fully reverse the
// blindfold here (mirror fn_blindfoldClient case 2): drop the black overlay, swap the blindfold goggles back
// to the old pair, relink map/GPS, rejoin the old group, and clear the flag (broadcast so others stop
// treating us as blinded).
if (player getVariable["plb_blinded", false]) then {
    0 cutText["", "PLAIN"];   // clear the persistent "BLACK FADED" overlay (0 cutFadeOut 9999999 in blindfoldClient)
    0 cutFadeOut 0;
    if ((goggles player) in ["G_blindfold_01_black_F", "G_blindfold_01_white_F"]) then {removeGoggles player;};
    if (!isNil "life_old_goggles" && {life_old_goggles isEqualType "" && {life_old_goggles != ""}}) then {
        player addGoggles life_old_goggles;
        life_old_goggles = nil;};
    player linkItem "ItemMap";
    if (player getVariable["hadGPS", false]) then {player linkItem "ItemGPS";
        player setVariable["hadGPS", nil];};
    if (!isNil "life_old_group" && {!isNull life_old_group}) then {[player] joinSilent life_old_group;
        life_old_group = grpNull;};};
player setVariable["plb_blinded", nil, true];
removeVest player;
removeHeadgear player;
removeBackpack player;
private _plb_dmg = player;
_plb_dmg setDamage 0;
player forceAddUniform "U_C_Scientist";
[] spawn {uiSleep 0.5;
    [uniform player, "setIdx", 28] call life_fnc_clothingTextures;};
private _bail = false;
private _toServeTime = selectMin[life_is_arrested select 2, 1500 * 1];
private _startTime = time;
life_jailReleaseTime = round(_startTime + _toServeTime);
[["-JAILDBG-", player, profileName, format ["ENTER arr=%1 jailTime=%2 toServe=%3 relTime=%4 crimes0=%5 bounty=%6 downed=%7 alive=%8", life_is_arrested, _jailTime, _toServeTime, life_jailReleaseTime, A_stats_crimes select 0, _bounty, life_isDowned, alive player]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
private _jailTimerSync = time + 300;
// LooneyBin: flag arrested at jail-START. The cop/BH-arrest path (arrestAction -> handleJail -> jailMe)
// only ever set plb_arrested=FALSE (on release, below) -> jailed fugitives read as "not arrested" ->
// fetchPersistentBounties kept re-adding them to bounty-hunter lists -> BH stuck tracking a now-$0 ghost
// even though handleJail cleared it on arrest. jailPlayer (self-turn-in) already sets this true; mirror it.
// Does NOT clear wanted/crimes -> the fugitive stays wanted until they serve the sentence or pay bail.
player setVariable["plb_arrested", true, true];
disableSerialization;
4 cutRsc["life_progress", "PLAIN"];
private _display = uiNameSpace getVariable["life_progress", displayNull];
private _progressBar = _display displayCtrl 38201;
private _progressText = _display displayCtrl 38202;
_progressText ctrlSetText "Time to collect";
_progressBar progressSetPosition 1;
private["_timeRemaining", "_isSeconds"];
while {(life_is_arrested param [0,0]) isEqualTo 1}
do {
    uiSleep 1;   // LooneyBin: throttle the jail loop. It had NO sleep -> ran every frame calling life_fnc_hudUpdate + MM:SS string-formatting + inPolygon + thirst/hunger resets EVERY frame, tanking prisoners to ~10 fps. Timer is second-resolution so 1/sec is exact.
    if (life_jailReleaseTime > time) then {_timeRemaining = toArray([life_jailReleaseTime - time, "MM:SS"] call BIS_fnc_secondsToString);
        if ((_timeRemaining select 0) in [48]) then {_timeRemaining deleteAt 0};
        _isSeconds = (_timeRemaining select 0) in [48];
        _timeRemaining = toString _timeRemaining;
        _progressText ctrlSetText format["Time remaining: %1 %2", _timeRemaining, if (_isSeconds) then {"seconds"} else {"minutes"}];
        _progressBar progressSetPosition(1 - ((time - _startTime) / (life_jailReleaseTime - _startTime)));};
    if (!life_laser_inprogress && !(weapons player isEqualTo[])) then {removeAllWeapons player};
    if (time > life_jailReleaseTime) exitWith {};
    if (life_bail_paid) exitWith {_bail = true;};
    if ((SRV_prisonData select 1) && life_breakout) exitWith {};
    if !(isNull objectParent player) then {player action["Eject", vehicle player]};
    if ((A_stats_crimes select 0) isEqualTo 0) exitWith {};
    if (!((getPosATL player) inPolygon life_jailPoly) && !life_laser_inprogress && !(life_clientTrialData select 0)) then {
        systemChat "Stay within the confines of the yard!";
        player setPos(getMarkerPos "jail_marker_loonybin");};
    if (_toServeTime > 0 && !(alive player)) exitWith {};
    plbv_thirst = 100;
    plbv_hunger = 100;
    [] call life_fnc_hudUpdate;
    // owner 2026-06-15 (#245): keep the remaining sentence CURRENT every tick (was only updated at the 300s
    // DB sync). A restart's graceful flush now captures the live remaining, so a prisoner reloads with the
    // RIGHT time left instead of re-serving the FULL sentence ("jail time resets on restart"). The 60s DB
    // sync (down from 300s) also bounds the loss on a non-graceful crash to ~1 min.
    life_is_arrested set[2, (life_jailReleaseTime - time) max 0];
    if (time > _jailTimerSync) then {_jailTimerSync = time + 60;
        [5] call life_fnc_ClUpdatePartial;
        ["prisontime", 60] call life_fnc_statArrUpdate;};}; 4 cutText["", "PLAIN"];
waitUntil {!life_isDowned};
[["-JAILDBG-", player, profileName, format ["EXIT t=%1 relTime=%2 arr0=%3 crimes0=%4 bail=%5 breakout=%6 alive=%7", time, life_jailReleaseTime, life_is_arrested param[0,0], A_stats_crimes select 0, _bail, life_breakout, alive player]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
player setVariable["plb_arrested", false, true];
life_is_arrested = [0, 0, 0];
life_jailReleaseTime = 99999;
[5] call life_fnc_ClUpdatePartial;
life_inv_shank = 0;
life_action_in_use = false;
[true] spawn life_fnc_loadGear;
switch (true) do {case (_bail): {life_bail_paid = false;
            ["You have been released from prison.", "basic"] spawn life_fnc_handleMessage;
            [999, getPlayerUID player] call life_fnc_wantedListAdd; [[getPlayerUID player], "TON_fnc_wantedRemove", 2] spawn life_fnc_MP;
            player setPosATL _jailReleasePos;};
    case (life_breakout): {life_breakout = false;
            ["You have escaped from prison, you still retain your previous crimes and now have a count of escaping prison.", "basic"] spawn life_fnc_handleMessage;
            [[13, player], "TON_fnc_wantedAdd", 2] spawn life_fnc_MP; [
                [0, format["%1 has escaped from prison!", profileName]], "life_fnc_broadcast", west] spawn life_fnc_MP;
            uiSleep 2;
            player setPos(getMarkerPos "jail_release2");};
    case (alive player && !life_breakout && !_bail): {
            if (((A_stats_crimes param[0, 0]) >= _deathPenMinimum) && (SRV_governorData param[4, false]) && ((serverCycleLength - (serverTime - serverStartTime)) >= 300)) exitWith {
                ["electricChair"] spawn life_fnc_govSystem;};
            ["You have been released from prison.", "basic"] spawn life_fnc_handleMessage;
            [999, getPlayerUID player] call life_fnc_wantedListAdd; [[getPlayerUID player], "TON_fnc_wantedRemove", 2] spawn life_fnc_MP;
            player setPosATL _jailReleasePos;};};