/*
    TON_fnc_houseTaxSRV  (LooneyBin -- implemented from stub 2026-06-09)
    House tax backend. DB: houses.tax_playtime (minutes the owner was online, +5/5min loop in init.sqf)
    + houses.tax_paid (last payment). Boot loop in init.sqf tags every owned house with
        plb_house_tax = [overdue(bool), canPayTax(bool), playtime(min), lastPayed(days)]
    which is all the client menu reads. Client cases (core/housing/fn_manageHouseTax.sqf):
      ["paySingleHouse", [player, houseObj, houseID]]
      ["payAllHouses",   [player, [[houseObj, houseID], ...]]]
    Price = client formula re-computed server-side (days * upkeep * playtime-reduction); charged via
    life_fnc_uC atm-take on the client (client pre-checks affordability); life_houseTxn cleared via
    netSetVar when done (the menu waits on it).
*/
params [["_caseType", "", [""]], ["_data", [], [[]]]];
// owner 2026-06-23 SECURITY (security.md §2.3 — SQLi): the client _houseID flows into `WHERE oid='%1'` and the
// derived _ownerUID into `WHERE owners='%1'` RAW. Money/authz here is already SAFE (§2.1); this only adds SQL
// escaping. Strip quotes/backslash before every interpolation.
private _san = { (format ["%1", _this]) splitString "\'""" joinString "" };

private _calcTax = {params [["_house", objNull, [objNull]], ["_ownerUID", "", [""]]];
    if (isNull _house) exitWith { 0 };
    private _hd = _house getVariable ["plb_house_tax", []];
    if (_hd isEqualTo []) exitWith { 0 };
    _hd params ["_overdue", "_canPay", "_playtime", "_lastPayed"];
    if (_lastPayed <= 0) exitWith { 0 };
    private _cfg = [typeOf _house] call life_fnc_houseConfig;
    if (_cfg isEqualTo []) exitWith { 0 };
    private _upkeep = _cfg select 4;
    private _cnt = 1;
    private _r = [format ["SELECT COUNT(*) FROM houses WHERE owners='%1'", _ownerUID call _san], 2] call DB_fnc_asyncQuery;
    if (_r isEqualType []) then { _cnt = ((parseNumber format ["%1", _r param [0, 1]]) max 1) min 5; };
    private _tbl = [[1.0, 0.9, 0.8, 0.6, 0.4, 0.25], [1.2, 1.2, 1.1, 1.1, 1.0, 1.0, 0.8, 0.6, 0.5, 0.4, 0.25],
        [1.3, 1.3, 1.2, 1.2, 1.1, 1.1, 1.0, 0.9, 0.8, 0.6, 0.5, 0.4, 0.4, 0.3, 0.3, 0.25],
        [1.5, 1.5, 1.5, 1.4, 1.4, 1.4, 1.3, 1.3, 1.2, 1.1, 1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.4, 0.3, 0.3, 0.25],
        [2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 1.9, 1.8, 1.7, 1.6, 1.5, 1.4, 1.3, 1.2, 1.1, 1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.4, 0.3, 0.3, 0.25]
    ] select (_cnt - 1);
    private _idx = floor (_playtime / 60);
    private _red = if (_idx > ((count _tbl) - 1)) then { 0.25 } else { _tbl select _idx };
    _red = (_red max 0.25) min 2.0;
    if (_overdue && _lastPayed > 32) then { _red = _red + 0.2; };
    round (_lastPayed * _upkeep * _red)};

private _payOne = {params ["_unit", "_house", "_houseID"];
    private _uid = getPlayerUID _unit;
    private _price = [_house, _uid] call _calcTax;
    if (_price <= 0) exitWith { 0 };
    [["atm", "take", _price], "life_fnc_uC", _unit, false, false] spawn life_fnc_MP;   // client pre-checked affordability
    // owner 2026-06-18 (#374 house-tax double-charge on relog): the client passes _houseID = plb_houseID = the
    // house OID (init.sqf:444 sets plb_houseID to the `oid` column), NOT the `id` PK. The old `WHERE id='%1'`
    // therefore matched the WRONG row / nothing -> tax_paid never updated -> on relog DATEDIFF(NOW(),tax_paid)
    // stayed high -> house showed unpaid + charged AGAIN (money lost every relog). `oid` is UNIQUE and is the
    // house-identity key the rest of the system uses (fn_bldgUpdateKeys writes `WHERE oid=...`). Use it here too.
    [format ["UPDATE houses SET tax_paid=NOW(), tax_playtime='0' WHERE oid='%1'", _houseID call _san]] call DB_fnc_asyncQuery;
    _house setVariable ["plb_house_tax", [false, false, 0, 0], true];
    _price};

switch (_caseType) do {case "paySingleHouse": {
        _data params [["_unit", objNull, [objNull]], ["_house", objNull, [objNull]], ["_houseID", -1, [0, ""]]];
        if (isNull _unit || {isNull _house}) exitWith {};
        private _paid = [_unit, _house, _houseID] call _payOne;
        if (_paid > 0) then {
            [[format ["You paid $%1 house tax.", [_paid] call life_fnc_numberText], "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
        };
        [["life_houseTxn", false], "life_fnc_netSetVar", _unit, false, false] spawn life_fnc_MP;};
    case "payAllHouses": {_data params [["_unit", objNull, [objNull]], ["_taxHouses", [], [[]]]];
        if (isNull _unit) exitWith {};
        private _total = 0;
        { _x params ["_house", "_houseID"]; if (!isNull _house) then { _total = _total + ([_unit, _house, _houseID] call _payOne); }; } forEach _taxHouses;
        if (_total > 0) then {
            [[format ["You paid $%1 house tax for %2 house(s).", [_total] call life_fnc_numberText, count _taxHouses], "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
        };
        [["life_houseTxn", false], "life_fnc_netSetVar", _unit, false, false] spawn life_fnc_MP;};
    default { diag_log format ["[LooneyBin][houseTax] unhandled case: %1", _this]; };};
