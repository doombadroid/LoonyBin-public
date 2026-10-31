/*
    TON_fnc_greenhouseSRV  (LooneyBin -- house weed grow, server-authoritative. spec: weed.md, 2026-06-13)
    Crop on each house object: _house plb_gh_crop = [[strain, plantedUnix, count], ...]
      strain "s" = Sativa (matures stage 2 = 2h),  "i" = Indica (matures stage 3 = 3h).
    Stage = floor((nowUnix - plantedUnix) / 3600). Persisted to houses.greenhouse_crop (str of the array).
    Capacity (max plants) = floor(house plb_vcap / 10).  Harvest yields the bud item (weight 1):
      Sativa -> cannas_3 (Weed),  Indica -> cannai_3 (High-Potency Weed).
    Cases:
      ["plant",   [player, house, strain, count]]
      ["harvest", [player, house, wantSativa, wantIndica]]   (want* = how many the client can carry)
      ["reload",  []]   -- boot: load crops from DB onto the house objects (after houses + buildings exist)
*/
params [["_case", "", [""]], ["_data", [], [[]]]];
private _nowUnix = (missionNamespace getVariable ["PLB_bootUnix", 0]) + serverTime;   // wall-clock approx

// persist a house's crop to the DB (NULL when empty so the reload filter skips it)
private _persist = {params ["_h"];
    private _oid = _h getVariable ["plb_houseID", -1];
    if (format ["%1", _oid] isEqualTo "-1") exitWith {};
    private _c = _h getVariable ["plb_gh_crop", []];
    if (_c isEqualTo []) then {[format ["UPDATE houses SET greenhouse_crop=NULL WHERE oid='%1'", _oid]] call DB_fnc_asyncQuery;} else {
        [format ["UPDATE houses SET greenhouse_crop='%1' WHERE oid='%2'", str _c, _oid]] call DB_fnc_asyncQuery;};};

// owner 2026-07-15 ("Enrique plants and they vanish", rebuilt sheds): resolve the building for a crop row the
// way fn_tagHousesSRV does, NOT via a bare nearest-House_F grab. Buyable-shed spots hold TWO buildings at ~0m:
// the hidden derelict Land_u_Shed_Ind_F (terrain object, hideObjectGlobal'd by replace_sheds) and the intact
// createVehicle'd Land_i_Shed_Ind_F (which is NOT reliably isKindOf House_F, so the old filter could only ever
// find the DERELICT there). Crops attached to the hidden derelict while the players' menus target the intact
// shed -> Enrique's overnight plants were invisible, and the next in-game plant persisted the intact shed's
// empty crop over them. Prefer the intact shed, and never attach to a hidden object (also covers the hidden
// Malden originals).
private _fnResolveHouse = {params ["_pos"];
    private _cands = (nearestObjects [_pos, ["House_F", "Land_i_Shed_Ind_F"], 12]) select { !isObjectHidden _x };
    private _sheds = _cands select { (typeOf _x) isEqualTo "Land_i_Shed_Ind_F" };
    if (_sheds isNotEqualTo []) then { _sheds select 0 } else { _cands param [0, objNull] }};

// owner 2026-07-15: DB re-read on the FIRST in-game touch of a house's greenhouse each session. Enrique writes
// greenhouse_crop while the server is running (owner + keyholders all offline -- his gate), but the server only
// read the column at boot, so a mid-session Enrique run stayed invisible and the next plant/harvest clobbered it.
// Race-free: Enrique refuses to run while anyone with keys is online, and only key-holders can trigger this.
// Also self-heals rows whose crop got attached to the derelict by the pre-fix reload.
private _fnSyncFromDB = {params ["_h"];
    if (_h getVariable ["plb_gh_synced", false]) exitWith {};
    _h setVariable ["plb_gh_synced", true];
    private _oid = format ["%1", _h getVariable ["plb_houseID", -1]];
    if (_oid in ["-1", ""]) exitWith {};
    private _rows = [format ["SELECT QUOTE(COALESCE(greenhouse_crop,'')) FROM houses WHERE oid='%1'", _oid], 2, true] call DB_fnc_asyncQuery;
    if !(_rows isEqualType []) exitWith {};
    private _cropStr = format ["%1", (_rows param [0, []]) param [0, ""]];
    private _crop = if (_cropStr in ["", "''"]) then { [] } else { parseSimpleArray _cropStr };
    if (isNil "_crop" || {!(_crop isEqualType [])}) exitWith {};
    if (_crop isNotEqualTo (_h getVariable ["plb_gh_crop", []])) then {_h setVariable ["plb_gh_crop", _crop, true];};};

switch (_case) do {case "reload": {
        private _rows = ["SELECT oid, QUOTE(worldspace), QUOTE(COALESCE(greenhouse_crop,'')) FROM houses WHERE greenhouse_crop IS NOT NULL AND greenhouse_crop <> ''", 2, true] call DB_fnc_asyncQuery;
        if (!(_rows isEqualType [])) exitWith {};
        private _n = 0; {_x params [["_oid", ""], ["_ws", ""], ["_cropStr", ""]];
            private _pos  = parseSimpleArray _ws;
            private _crop = parseSimpleArray _cropStr;
            if (_pos isEqualType [] && {count _pos >= 2} && {_crop isEqualType []} && {!(_crop isEqualTo [])}) then {
                private _b = [_pos] call _fnResolveHouse;
                if (!isNull _b) then { _b setVariable ["plb_gh_crop", _crop, true]; _b setVariable ["plb_gh_synced", true]; _n = _n + 1; };
            };} forEach _rows;
        diag_log format ["[LooneyBin][weed] reloaded greenhouse crops onto %1 house(s)", _n];};

    case "plant": {
        _data params [["_player", objNull, [objNull]], ["_house", objNull, [objNull]], ["_strain", "", [""]], ["_count", 0, [0]]];
        if (isNull _player || {isNull _house} || {!(_strain in ["s", "i"])} || {_count < 1}) exitWith {};
        // owner 2026-07-15: the client consumes the seeds BEFORE this call, so every reject below must hand
        // them back or a server-side refusal silently eats the seeds.
        private _seedItem = if (_strain isEqualTo "s") then {"cannas_0"} else {"cannai_0"};
        private _fnRefund = { [[true, _seedItem, _count], "life_fnc_handleInv", _player, false, false] spawn life_fnc_MP; };
        [_house] call _fnSyncFromDB;
        if !(_house getVariable ["plb_greenhouse_unaged", false]) exitWith {call _fnRefund;
            [["This property has no greenhouse installed.", "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;};
        // owner 2026-06-16: greenhouse usable by anyone with KEYS to the house, not just the owner.
        private _ghUid = getPlayerUID _player;
        if !((_house getVariable ["plb_homeOwner", ""]) isEqualTo _ghUid || {((_house getVariable ["plb_house_keys", []]) findIf { (_x param [0, ""]) isEqualTo _ghUid }) != -1}) exitWith {
            call _fnRefund;
            [["You need keys to this property to plant in its greenhouse.", "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
        };
        private _crop = _house getVariable ["plb_gh_crop", []];
        private _cur = 0; { _cur = _cur + (_x param [2, 0]); } forEach _crop;
        private _maxPlants = floor ((_house getVariable ["plb_vcap", 0]) / 10);
        if (_cur + _count > _maxPlants) exitWith {call _fnRefund;
            [[format ["Greenhouse is full -- %1 / %2 plants (cap = virtual storage capacity / 10). You can plant %3 more.", _cur, _maxPlants, (_maxPlants - _cur) max 0], "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
        };
        _crop pushBack [_strain, _nowUnix, _count];
        _house setVariable ["plb_gh_crop", _crop, true];
        [_house] call _persist;
        private _hrs = if (_strain isEqualTo "s") then {2} else {3};
        private _sName = if (_strain isEqualTo "s") then {"Sativa"} else {"Indica"};
        [[format ["Planted %1 %2 seed(s). Mature in %3 hours -- grows while you're offline.", _count, _sName, _hrs], "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
        ["-WEED-", _player, format ["planted %1 %2 (house %3) -> %4/%5", _count, _strain, _house getVariable ["plb_houseID", -1], _cur + _count, _maxPlants]] call PLB_fnc_logIt;
    };

    case "sync": {_data params [["_player", objNull, [objNull]], ["_house", objNull, [objNull]]];
        if (isNull _house) exitWith {};
        [_house] call _fnSyncFromDB;};

    case "harvest": {
        _data params [["_player", objNull, [objNull]], ["_house", objNull, [objNull]], ["_wantS", 0, [0]], ["_wantI", 0, [0]]];
        if (isNull _player || {isNull _house}) exitWith {};
        private _ghUid = getPlayerUID _player;
        if !((_house getVariable ["plb_homeOwner", ""]) isEqualTo _ghUid || {((_house getVariable ["plb_house_keys", []]) findIf { (_x param [0, ""]) isEqualTo _ghUid }) != -1}) exitWith {
            [["You need keys to this property to harvest its greenhouse.", "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
        };
        [_house] call _fnSyncFromDB;
        private _crop = _house getVariable ["plb_gh_crop", []];
        if (_crop isEqualTo []) exitWith {
            [["Nothing is growing here.", "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;};
        // tally mature per strain
        private _matS = 0; private _matI = 0; {
            _x params ["_st", "_pt", "_cnt"]; if (_pt > 1000000000) then { _pt = _pt - 1700000000 };  // owner 2026-06-16: normalize PRE-#248 full-unix plant times to the epoch-offset clock so old crops still mature
            private _need = if (_st isEqualTo "s") then {2} else {3};
            if (floor (((_nowUnix - _pt) max 0) / 3600) >= _need) then {
                if (_st isEqualTo "s") then { _matS = _matS + _cnt } else { _matI = _matI + _cnt };};} forEach _crop;
        private _giveS = (_wantS max 0) min _matS;
        private _giveI = (_wantI max 0) min _matI;
        if (_giveS + _giveI <= 0) exitWith {
            [[format ["No mature plants you can carry right now (mature: %1 Weed, %2 High-Potency -- free up inventory).", _matS, _matI], "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
        };
        // consume from mature batches (oldest first), keep the rest
        private _newCrop = [];
        private _remS = _giveS; private _remI = _giveI; {
            _x params ["_st", "_pt", "_cnt"]; if (_pt > 1000000000) then { _pt = _pt - 1700000000 };  // owner 2026-06-16: normalize PRE-#248 full-unix plant times to the epoch-offset clock so old crops still mature
            private _need = if (_st isEqualTo "s") then {2} else {3};
            private _keep = _cnt;
            if (floor (((_nowUnix - _pt) max 0) / 3600) >= _need) then {
                if (_st isEqualTo "s" && {_remS > 0}) then { private _take = _remS min _cnt; _keep = _cnt - _take; _remS = _remS - _take; };
                if (_st isEqualTo "i" && {_remI > 0}) then { private _take = _remI min _cnt; _keep = _cnt - _take; _remI = _remI - _take; };
            };
            if (_keep > 0) then { _newCrop pushBack [_st, _pt, _keep]; };} forEach _crop;
        _house setVariable ["plb_gh_crop", _newCrop, true];
        [_house] call _persist;
        if (_giveS > 0) then { [[true, "cannas_3", _giveS], "life_fnc_handleInv", _player, false, false] spawn life_fnc_MP; };
        if (_giveI > 0) then { [[true, "cannai_3", _giveI], "life_fnc_handleInv", _player, false, false] spawn life_fnc_MP; };
        [[format ["Harvested %1 Weed + %2 High-Potency Weed.", _giveS, _giveI], "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
        ["-WEED-", _player, format ["harvested s=%1 i=%2 (house %3)", _giveS, _giveI, _house getVariable ["plb_houseID", -1]]] call PLB_fnc_logIt;
    };};
