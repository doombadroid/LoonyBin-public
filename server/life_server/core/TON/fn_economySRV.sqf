/*
    TON_fnc_economySRV  (LooneyBin Economy -- owner request 2026-06-11)
    Owner-only live price overrides, persisted in `price_overrides` + broadcast as PLB_priceOv.
    Client (life_fnc_economyMenu) sends:
      ["set", family, key, p0, p1, p2, displayName, caller]  upsert + apply live
      ["reset", family, key, caller]                          delete override (back to config default)
      ["load"]                              (server boot)      DB -> PLB_priceOv -> publicVariable
    Owner gate: the CALLER's players_global.adminlevel must be >= 5 (owner). Re-checked here from the
    DB every call -- the client gate is never trusted. (Beta auto-admin is level 4, so testers can't.)
*/
params [["_mode", "", [""]]];
if (isNil "PLB_priceOv") then { PLB_priceOv = []; };

// owner 2026-06-23 SECURITY (security.md §2.2 — owner check was on a PASSED object, spoofable): the owner
// gate re-queried adminlevel by getPlayerUID of a client-supplied _caller arg, so an attacker could pass a
// real owner's object (if online) and pass the check. Derive the actor from the NON-SPOOFABLE
// remoteExecutedOwner instead (0 = server-internal boot "load" = trusted). _realCaller / _callerUID below
// replace every use of the passed _caller arg.
private _src = remoteExecutedOwner;
private _realCaller = if (_src isEqualTo 0) then { objNull } else { (allPlayers select { owner _x isEqualTo _src }) param [0, objNull] };
private _callerUID = getPlayerUID _realCaller;
private _isOwner = {if (_src isEqualTo 0) exitWith { true };   // server-internal (boot load) always passes
    if (_callerUID isEqualTo "") exitWith { false };
    private _lr = [format ["SELECT CAST(adminlevel AS SIGNED) FROM players_global WHERE playerid='%1'", _callerUID], 2, true] call DB_fnc_asyncQuery;
    (parseNumber format ["%1", (_lr param [0, [0]]) param [0, 0]]) >= 5};

switch (toLower _mode) do {case "load": {
        // QUOTE the string columns: DB_fnc_asyncQuery call-compiles the result, so bare family/key
        // (e.g. veh, O_MRAP_02_hmg_F) parsed as undefined variables and the whole load threw.
        private _rows = ["SELECT QUOTE(family), QUOTE(item_key), p0, p1, p2 FROM price_overrides", 2, true] call DB_fnc_asyncQuery;
        PLB_priceOv = [];
        if (_rows isEqualType []) then {{_x params [["_f", ""], ["_k", ""], ["_p0", -1], ["_p1", -1], ["_p2", -1]];
                PLB_priceOv pushBack [format ["%1", _f], format ["%1", _k], parseNumber format ["%1", _p0], parseNumber format ["%1", _p1], parseNumber format ["%1", _p2]];
            } forEach _rows;};
        publicVariable "PLB_priceOv";
        diag_log format ["[LooneyBin][economy] loaded %1 override(s)", count PLB_priceOv];};
    case "set": {
        params ["", ["_family", "", [""]], ["_key", "", [""]], ["_p0", -1, [0]], ["_p1", -1, [0]], ["_p2", -1, [0]], ["_dn", "", [""]]];   // client _caller arg ignored -- use the non-spoofable _realCaller
        if (_family isEqualTo "" || {_key isEqualTo ""}) exitWith {};
        if !(call _isOwner) exitWith { ["-SEC-", _realCaller, format ["BLOCKED economySRV set by %1", _callerUID]] call PLB_fnc_logIt; };
        private _bad = toString [39, 96, 34];   // ' ` "  -- strip SQL-breakers
        private _sf = _family splitString _bad joinString "";
        private _sk = _key splitString _bad joinString "";
        private _sdn = _dn splitString _bad joinString "";
        [format ["INSERT INTO price_overrides (family,item_key,p0,p1,p2,display_name,updated_by) VALUES ('%1','%2',%3,%4,%5,'%6','%7') ON DUPLICATE KEY UPDATE p0=%3,p1=%4,p2=%5,display_name='%6',updated_by='%7'",
            _sf, _sk, round _p0, round _p1, round _p2, _sdn, _callerUID]] call DB_fnc_asyncQuery;
        private _i = PLB_priceOv findIf { ((_x select 0) isEqualTo _sf) && {(_x select 1) isEqualTo _sk} };
        if (_i isEqualTo -1) then { PLB_priceOv pushBack [_sf, _sk, round _p0, round _p1, round _p2]; }
        else { PLB_priceOv set [_i, [_sf, _sk, round _p0, round _p1, round _p2]]; };
        publicVariable "PLB_priceOv";
        [777, _realCaller, format ["ECON set %1/%2 = [%3,%4,%5]", _sf, _sk, round _p0, round _p1, round _p2]] call PLB_fnc_logIt;
        [[format ["Economy: %1 price saved (live).", _sk], "success"], "life_fnc_handleMessage", _realCaller, false, false] spawn life_fnc_MP;
    };
    case "reset": {
        params ["", ["_family", "", [""]], ["_key", "", [""]]];   // client _caller arg ignored -- use the non-spoofable _realCaller
        if !(call _isOwner) exitWith { ["-SEC-", _realCaller, format ["BLOCKED economySRV reset by %1", _callerUID]] call PLB_fnc_logIt; };
        private _bad = toString [39, 96, 34];
        private _sf = _family splitString _bad joinString "";
        private _sk = _key splitString _bad joinString "";
        [format ["DELETE FROM price_overrides WHERE family='%1' AND item_key='%2'", _sf, _sk]] call DB_fnc_asyncQuery;
        private _i = PLB_priceOv findIf { ((_x select 0) isEqualTo _sf) && {(_x select 1) isEqualTo _sk} };
        if (_i isNotEqualTo -1) then { PLB_priceOv deleteAt _i; };
        publicVariable "PLB_priceOv";
        [[format ["Economy: %1 reset to default.", _sk], "success"], "life_fnc_handleMessage", _realCaller, false, false] spawn life_fnc_MP;
    };};
