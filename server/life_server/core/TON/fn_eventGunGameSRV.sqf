/*
    TON_fnc_eventGunGameSRV  (LooneyBin -- implemented from stub 2026-06-09)
    Admin event: GUN GAME. Admin menu (fn_handleAdminEvent) calls the eventCfg start lambda ->
    [1, objNull, _locationID] here. Clients join via the event key (keyUpHandler dispatches on
    life_adminEvent select 2 == 1 -> fn_eventGunGameClient), teleport + loadouts are client-side.
    A player's 15th-tier kill sends [2, player] = the WINNER.
    life_adminEvent = [active, joinsLocked, eventMode, locationID]
*/
params [["_mode", -1, [0]], ["_x1", objNull, [objNull]], ["_locID", -1, [0]]];
if (isNil "life_event_queue") then { life_event_queue = []; };

// owner 2026-06-23 SECURITY (security.md §2.1/§2.2): START is an ADMIN event but was server-side ungated, so
// any client could remoteExec [1, ...] to launch a Gun Game (grief/spam). Re-query the NON-SPOOFABLE caller's
// admin level (DB, model fn_adminDelVeh) and require >= 3 to START. server-internal (_src==0) passes. (case 2
// pays the caller; the join window / queue are participant-driven.)
private _src = remoteExecutedOwner;
private _starter = if (_src isEqualTo 0) then { objNull } else { (allPlayers select { owner _x isEqualTo _src }) param [0, objNull] };

switch (_mode) do {case 1: {   // START
        // FLAT exitWith (no nesting in then{} -- that would only leave the block and fall through into START).
        private _lvl = if (_src isEqualTo 0) then { 999 } else {
            private _rows = [format ["SELECT CAST(adminlevel AS SIGNED) FROM players_global WHERE playerid='%1'", getPlayerUID _starter], 2, true] call DB_fnc_asyncQuery;
            parseNumber format ["%1", (_rows param [0, [0]]) param [0, 0]]};
        if (_lvl < 3) exitWith { ["-SEC-", _starter, format ["BLOCKED eventGunGameSRV START by %1 (admin %2)", getPlayerUID _starter, _lvl]] call PLB_fnc_logIt; };
        if (life_adminEvent param [0, false]) exitWith {};
        life_event_queue = [];
        life_adminEvent = [true, false, 1, _locID];
        publicVariable "life_adminEvent";
        private _locName = (["getLocationByID", _locID] call life_fnc_eventCfg) param [1, "?"];
        [[0, format ["ADMIN EVENT: GUN GAME at %1! Civilians -- press your event key to join!", _locName]], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
        [] spawn {uiSleep 180;   // 3-min join window
            if (life_adminEvent param [0, false] && {(life_adminEvent param [2, 0]) isEqualTo 1}) then {
                life_adminEvent set [1, true]; publicVariable "life_adminEvent";
                [[0, "Gun Game joins are now CLOSED. Fight!"], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;};
            uiSleep 1620;  // 27 more min -> 30-min cap, no winner
            if (life_adminEvent param [0, false] && {(life_adminEvent param [2, 0]) isEqualTo 1}) then {
                life_adminEvent = [false, false, 0, 0]; publicVariable "life_adminEvent";
                life_event_queue = [];
                [[0, "The Gun Game admin event has ended with no winner."], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;};};
    };
    case 2: {   // WINNER (15th-tier kill)
        // owner 2026-06-23 SECURITY (security.md §2.1 HIGH): CfgRE-whitelisted -> during any active Gun Game a
        // client could remoteExec [2, anyPlayer] to award that account $250k. Pay the CALLER (the legit client
        // fn_eventGunGameKill passes `player` = itself), derived from the non-spoofable remoteExecutedOwner
        // (model fn_seizeLock:22) -- never the passed object -> a scripter can only ever award THEMSELVES, and
        // only during a live event that ends on the first win. (Server can't verify the caller truly hit the
        // 15th-tier kill without server-side kill tracking -> that is NEEDS OWNER REVIEW.)
        private _src = remoteExecutedOwner;
        private _winner = if (_src isEqualTo 0) then { _x1 } else { (allPlayers select { owner _x isEqualTo _src }) param [0, objNull] };
        if (isNull _winner) exitWith { ["-SEC-", objNull, format ["BLOCKED eventGunGameSRV case2 (no real winner, src %1)", _src]] call PLB_fnc_logIt; };
        if !((life_adminEvent param [2, 0]) isEqualTo 1) exitWith {};
        life_adminEvent = [false, false, 0, 0];
        publicVariable "life_adminEvent";
        life_event_queue = [];
        [["atm", "add", 250000], "life_fnc_uC", _winner, false, false] spawn life_fnc_MP;
        [[0, format ["%1 has WON the Gun Game admin event! ($250,000 prize)", name _winner]], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
        diag_log format ["[LooneyBin][event] GunGame won by %1", getPlayerUID _winner];
        ["-EVENT-", _winner, "WON Gun Game ($250k)"] call PLB_fnc_logIt;};};
