/*
    TON_fnc_handlePrisonBreak  (LooneyBin -- implemented 2026-06-09; the passthrough fed
    [mode, unit, uid, group] into 2017 startPrisonBreak [unit, jailID, npc] -> isNull gate killed it
    instantly = PRISON BREAK NEVER STARTED. Mode 2 (cop stop) had no 2017 equivalent at all.)
      [1, player, uid, group]  civ starts the break (core/civilian/fn_doPrisonBreak.sqf)
      [2, player, uid]         cop restores security (core/cop/fn_stopPrisonBreak.sqf)
    SRV_prisonData = [lastBreak(serverTime), active(bool)] -- was NEVER defined anywhere (clients read
    slot 1); init.sqf now publishes it and this keeps it synced alongside 2017's life_prison_inProgress.
*/
params [["_mode", -1, [0]], ["_unit", objNull, [objNull]], ["_uid", "", [""]], ["_grp", grpNull, [grpNull]]];
// owner 2026-06-23 SECURITY (security.md §2.2): per-mode authz. mode 1 = a civ STARTING the break
// (fn_doPrisonBreak, passes `player`) -> require the starter to BE the real caller. mode 2 = a COP STOPPING it
// (fn_stopPrisonBreak, west-gated client-side) -> require side==west. Ungated, any civ could start/stop the
// prison-break event at will (grief/availability). Derive the caller from remoteExecutedOwner (non-spoofable);
// server-internal passes either mode. _uid is sanitized downstream by PLB_fnc_logIt.
private _src = remoteExecutedOwner;
private _caller = if (_src isEqualTo 0) then { objNull } else { (allPlayers select { owner _x isEqualTo _src }) param [0, objNull] };
if (_src isNotEqualTo 0) then {private _ok = switch (_mode) do {case 1: { _unit isEqualTo _caller };
        case 2: { side _caller isEqualTo west };
        default { false };};
    if (!_ok) exitWith { ["-SEC-", _caller, format ["BLOCKED handlePrisonBreak mode %1 by %2", _mode, getPlayerUID _caller]] call PLB_fnc_logIt; };
};
if (isNull _unit) exitWith {};

switch (_mode) do {case 1: {if (SRV_prisonData param [1, false]) exitWith {};
        // owner 2026-06-16 (#302): server-authoritative one-federal-event-at-a-time gate (client check has a window).
        if (["prison"] call PLB_fnc_fedEventActive) exitWith {
            [[2, "Another major crime is already in progress -- the prison break can't kick off."], "life_fnc_broadcast", _unit, false, false] spawn life_fnc_MP;
        };
        SRV_prisonData = [serverTime, true];
        publicVariable "SRV_prisonData";
        // 2017 fn wants [unit, jailID, npcAnchor]; the prison NPC global doesn't exist in this build --
        // the breaker himself anchors the 300m SWAT-candidate scan (he's standing at the prison).
        [_unit, 1, _unit] spawn life_fnc_startPrisonBreak;
        ["-PRISON-", _unit, "started a prison break"] call PLB_fnc_logIt;
        [_unit] spawn {   // watchdog: 20-min cap resets the event state
            params ["_u"];
            private _endAt = serverTime + 1200;
            waitUntil { uiSleep 10; (serverTime > _endAt) || !(SRV_prisonData param [1, false]) };
            if (SRV_prisonData param [1, false]) then {SRV_prisonData set [1, false]; publicVariable "SRV_prisonData";
                life_prison_inProgress = false; publicVariable "life_prison_inProgress";
                "corrections" setMarkerText "Prison";
                "corrections" setMarkerColor "ColorBlue";};};};
    case 2: {if !(SRV_prisonData param [1, false]) exitWith {};
        SRV_prisonData set [1, false];
        publicVariable "SRV_prisonData";
        life_prison_inProgress = false; publicVariable "life_prison_inProgress";
        "corrections" setMarkerText "Prison";
        "corrections" setMarkerColor "ColorBlue";
        [[0, format ["%1 has restored the prison security systems -- the break is OVER!", name _unit]], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
        ["-PRISON-", _unit, "stopped the prison break"] call PLB_fnc_logIt;};};
