/*
    TON_fnc_eventSmirnoffJumpSRV  (LooneyBin -- new admin event, 2026-06-28)
    Admin event mode 7: SMIRNOFF JUMPING (self-contained parkour mini-game at Kavala BH, location 1000).
    The eventCfg menu start lambda remoteExecs [1, objNull, _locID] here. The jump/parkour mechanic is
    fully client-side (fn_eventSmirnoffJumpingClient, joined via the event key -> keyUpHandler dispatch on
    life_adminEvent select 2 == 7). Server = admin-gated START, OPEN joins (select 1 stays false; the
    client key handlers all leave when select 2 != 7), ~20-min round, close.
    life_adminEvent = [active, joinsLocked, eventMode, locationID]
*/
params [["_mode", -1, [0]], ["_x1", objNull, [objNull]], ["_locID", 1000, [0]]];
if !(_mode isEqualTo 1) exitWith {};

// owner 2026-06-28 SECURITY (mirrors fn_eventGunGameSRV / security.md §2.1): START is an ADMIN action but is
// CfgRE-whitelisted (allowedTargets=2), so any client could remoteExec [1, ...] to spam-launch the event.
// Re-query the NON-SPOOFABLE caller's admin level (remoteExecutedOwner -> DB) and require >= 3 to START.
// server-internal (_src==0) passes.
private _src = remoteExecutedOwner;
private _starter = if (_src isEqualTo 0) then { objNull } else { (allPlayers select { owner _x isEqualTo _src }) param [0, objNull] };
private _lvl = if (_src isEqualTo 0) then { 999 } else {
    private _rows = [format ["SELECT CAST(adminlevel AS SIGNED) FROM players_global WHERE playerid='%1'", getPlayerUID _starter], 2, true] call DB_fnc_asyncQuery;
    parseNumber format ["%1", (_rows param [0, [0]]) param [0, 0]]};
if (_lvl < 3) exitWith { ["-SEC-", _starter, format ["BLOCKED eventSmirnoffJumpSRV START by %1 (admin %2)", getPlayerUID _starter, _lvl]] call PLB_fnc_logIt; };

if (life_adminEvent param [0, false]) exitWith {};
if (isNil "life_event_queue") then { life_event_queue = []; };
life_event_queue = [];
life_adminEvent = [true, false, 7, _locID];
publicVariable "life_adminEvent";
[[0, "ADMIN EVENT: SMIRNOFF JUMPING! Civilians -- press your event key to take on the Kavala BH parkour course!"], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
[] spawn {uiSleep 1200;   // 20-min round
    if (life_adminEvent param [0, false] && {(life_adminEvent param [2, 0]) isEqualTo 7}) then {
        life_adminEvent = [false, false, 0, 0]; publicVariable "life_adminEvent";
        life_event_queue = [];
        [[0, "The Smirnoff Jumping admin event has ended!"], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;};};
