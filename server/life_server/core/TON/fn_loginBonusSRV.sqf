/*
    TON_fnc_loginBonusSRV  (LooneyBin -- implemented from stub 2026-06-09)
    Daily login bonus backend. DB: players.lb_days / lb_claimed / lb_last (added 2026-06-09).
    The connect-time streak compute + push of life_loginBonusData lives in DB_fnc_queryRequest.
    Client cases (core/civilian/fn_loginBonusGive.sqf):
      ["giveCar",          [uid, player, classname]] -> insert the reward vehicle into the player's garage
      ["updatePlayerData", [uid, consecutiveDays]]   -> mark today's gift claimed
*/
params [["_caseType", "", [""]], ["_data", [], [[]]]];

// owner 2026-06-23 SECURITY (security.md §2.3 — cross-account write + SQLi): both cases used a client _uid raw
// (INSERT a garage vehicle / UPDATE lb_* flags), so a scripter could write to ANY account or inject SQL. Force
// the actor to the NON-SPOOFABLE caller's OWN account; escape _uid + _class. Server-internal (_src==0) keeps
// the passed _uid. NB: the reward classname is still client-chosen -- the daily-bonus value gate lives in the
// caller (fn_loginBonusGive); arbitrary-class grants are tracked separately. Here we close the SQL/cross-acct hole.
private _src = remoteExecutedOwner;
private _realUID = if (_src isEqualTo 0) then { "" } else { getPlayerUID ((allPlayers select { owner _x isEqualTo _src }) param [0, objNull]) };
private _san = { (format ["%1", _this]) splitString "\'""" joinString "" };

switch (_caseType) do {case "giveCar": {_data params [["_uid", "", [""]], ["_unit", objNull, [objNull]], ["_class", "", [""]]];
        if (_src != 0) then { _uid = _realUID; };
        _uid = _uid call _san;
        _class = _class call _san;
        if (_uid isEqualTo "" || {_class isEqualTo ""}) exitWith {};
        private _type = switch (true) do {case (_class isKindOf "Air"):  { "Air" };
            case (_class isKindOf "Ship"): { "Ship" };
            default { "Car" };};
        private _plate = round (random [100000, 550000, 999999]);
        // active=0 -> sits in the garage; alive=1; empty inventory
        [format ["INSERT INTO %1 (side, classname, type, pid, alive, active, inventory, color, plate, fuel, damage, alarm) VALUES ('civ', '%2', '%3', '%4', '1', '0', '[]', '0', '%5', '100', '0', '0')", srv_table_vehicles, _class, _type, _uid, _plate]] call DB_fnc_asyncQuery;
        diag_log format ["[LooneyBin][loginBonus] gave %1 a %2 (garage)", _uid, _class];};
    case "updatePlayerData": {_data params [["_uid", "", [""]], ["_days", 0, [0]]];
        if (_src != 0) then { _uid = _realUID; };
        _uid = _uid call _san;
        if (_uid isEqualTo "") exitWith {};
        [format ["UPDATE players SET lb_claimed='1', lb_days='%2' WHERE playerid='%1'", _uid, round (_days max 0)]] call DB_fnc_asyncQuery;
        diag_log format ["[LooneyBin][loginBonus] %1 claimed day-%2 bonus", _uid, _days];};
    default {diag_log format ["[LooneyBin][loginBonusSRV] unhandled case: %1", _this];};};
