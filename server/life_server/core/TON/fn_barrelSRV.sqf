/*
    TON_fnc_barrelSRV  (LooneyBin -- house SPIRIT aging, server-authoritative. Clone of TON_fnc_greenhouseSRV.
    owner 2026-06-21: "make scotch work exactly like house weed." Replaces the old per-restart aging
    (fn_addStorage) with real-time aging, restart-proof. In-game decision (features.md / BUGS.md #325): 6h/stage.)

    Crop on each house object: _house plb_barrel_crop = [[type, laidUnix, count], ...]
      type in ["scotch","whiskeyc","whiskeyr","rum"]. You lay down the STAGE-0 new-make spirit (scotch_0 etc.).
    Stage = floor((nowUnix - laidUnix) / 21600), CAPPED at 2 (= "15 Year"); 21600s = 6h per stage.
      stage 0 = New Make, 1 = the named spirit (Scotch/Corn/Rye/Rum), 2 = 15-Year/Aged/Reserve.
      Collecting yields the item `<type>_<stage>` at its CURRENT stage (auto-ages through; collect any time).
      stage 2 -> 3 (25 Year / Reserve) stays the aging-chemicals PROCESSOR step, NOT the barrel.
    Capacity (max units in the barrel) = floor(house plb_vcap / 30). Requires the Aging Barrel upgrade
      (plb_barrel_unaged) installed -- the same way the greenhouse needs plb_greenhouse_unaged.
    Persisted to houses.barrel_crop (str of the array), NULL when empty. Each spirit unit weighs 3 (fn_virtItemCfg).
    Cases:
      ["laydown", [player, house, type, count]]
      ["collect", [player, house, wantCount]]   (wantCount = how many units the client can carry = floor(free/3))
      ["reload",  []]   -- boot: load crops from DB onto the house objects (after houses + buildings exist)
*/
params [["_case", "", [""]], ["_data", [], [[]]]];
private _nowUnix = (missionNamespace getVariable ["PLB_bootUnix", 0]) + serverTime;   // wall-clock approx (restart-proof)
#define BARREL_STAGE_SECONDS 21600
#define BARREL_MAX_STAGE 2
#define BARREL_CAP_DIV 30
private _types = ["scotch", "whiskeyc", "whiskeyr", "rum"];

// persist a house's barrel to the DB (NULL when empty so the reload filter skips it)
private _persist = {params ["_h"];
    private _oid = _h getVariable ["plb_houseID", -1];
    if (format ["%1", _oid] isEqualTo "-1") exitWith {};
    private _c = _h getVariable ["plb_barrel_crop", []];
    if (_c isEqualTo []) then {[format ["UPDATE houses SET barrel_crop=NULL WHERE oid='%1'", _oid]] call DB_fnc_asyncQuery;} else {
        [format ["UPDATE houses SET barrel_crop='%1' WHERE oid='%2'", str _c, _oid]] call DB_fnc_asyncQuery;};};

// owner 2026-07-15: same derelict-shed resolution bug as fn_greenhouseSRV -- see the note there. Barrel crops
// on rebuilt (createVehicle'd) sheds attached to the hidden derelict and "vanished" the same way.
private _fnResolveHouse = {params ["_pos"];
    private _cands = (nearestObjects [_pos, ["House_F", "Land_i_Shed_Ind_F"], 12]) select { !isObjectHidden _x };
    private _sheds = _cands select { (typeOf _x) isEqualTo "Land_i_Shed_Ind_F" };
    if (_sheds isNotEqualTo []) then { _sheds select 0 } else { _cands param [0, objNull] }};

switch (_case) do {case "reload": {
        private _rows = ["SELECT oid, QUOTE(worldspace), QUOTE(COALESCE(barrel_crop,'')) FROM houses WHERE barrel_crop IS NOT NULL AND barrel_crop <> ''", 2, true] call DB_fnc_asyncQuery;
        if (!(_rows isEqualType [])) exitWith {};
        private _n = 0; {_x params [["_oid", ""], ["_ws", ""], ["_cropStr", ""]];
            private _pos  = parseSimpleArray _ws;
            private _crop = parseSimpleArray _cropStr;
            if (_pos isEqualType [] && {count _pos >= 2} && {_crop isEqualType []} && {!(_crop isEqualTo [])}) then {
                private _b = [_pos] call _fnResolveHouse;
                if (!isNull _b) then { _b setVariable ["plb_barrel_crop", _crop, true]; _n = _n + 1; };};} forEach _rows;
        diag_log format ["[LooneyBin][spirits] reloaded barrel crops onto %1 house(s)", _n];};

    case "laydown": {
        _data params [["_player", objNull, [objNull]], ["_house", objNull, [objNull]], ["_type", "", [""]], ["_count", 0, [0]]];
        if (isNull _player || {isNull _house} || {!(_type in _types)} || {_count < 1}) exitWith {};
        if !(_house getVariable ["plb_barrel_unaged", false]) exitWith {
            [["This property has no aging barrel installed.", "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
        };
        // usable by the owner OR anyone with KEYS (mirrors the greenhouse)
        private _uid = getPlayerUID _player;
        if !((_house getVariable ["plb_homeOwner", ""]) isEqualTo _uid || {((_house getVariable ["plb_house_keys", []]) findIf { (_x param [0, ""]) isEqualTo _uid }) != -1}) exitWith {
            [["You need keys to this property to use its aging barrel.", "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
        };
        private _crop = _house getVariable ["plb_barrel_crop", []];
        private _cur = 0; { _cur = _cur + (_x param [2, 0]); } forEach _crop;
        private _maxUnits = floor ((_house getVariable ["plb_vcap", 0]) / BARREL_CAP_DIV);
        if (_cur + _count > _maxUnits) exitWith {
            [[format ["Barrel is full -- %1 / %2 units (cap = virtual storage capacity / %4). You can lay down %3 more.", _cur, _maxUnits, (_maxUnits - _cur) max 0, BARREL_CAP_DIV], "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
        };
        _crop pushBack [_type, _nowUnix, _count];
        _house setVariable ["plb_barrel_crop", _crop, true];
        [_house] call _persist;
        private _totalHrs = BARREL_MAX_STAGE * (BARREL_STAGE_SECONDS / 3600);
        [[format ["Laid down %1 new-make %2 to age. Fully ages in %3 hours (6h/stage) -- ages while you're offline.", _count, _type, _totalHrs], "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
        ["-SPIRITS-", _player, format ["laid down %1 %2 (house %3) -> %4/%5", _count, _type, _house getVariable ["plb_houseID", -1], _cur + _count, _maxUnits]] call PLB_fnc_logIt;
    };

    case "collect": {_data params [["_player", objNull, [objNull]], ["_house", objNull, [objNull]], ["_want", 0, [0]]];
        if (isNull _player || {isNull _house}) exitWith {};
        private _uid = getPlayerUID _player;
        if !((_house getVariable ["plb_homeOwner", ""]) isEqualTo _uid || {((_house getVariable ["plb_house_keys", []]) findIf { (_x param [0, ""]) isEqualTo _uid }) != -1}) exitWith {
            [["You need keys to this property to use its aging barrel.", "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
        };
        private _crop = _house getVariable ["plb_barrel_crop", []];
        if (_crop isEqualTo []) exitWith {
            [["The aging barrel is empty.", "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;};
        if (_want < 1) exitWith {
            [["Your inventory is full -- make room before collecting (each bottle weighs 3).", "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
        };
        // give up to _want units, OLDEST batches first; each yields <type>_<currentStage>. Tally per item, keep the rest.
        private _rem = _want;
        private _give = [];   // [[item, count], ...]
        private _newCrop = []; {_x params ["_t", "_lt", "_cnt"];
            private _stage = (floor (((_nowUnix - _lt) max 0) / BARREL_STAGE_SECONDS)) min BARREL_MAX_STAGE;
            private _take = _rem min _cnt;
            if (_take > 0) then {private _item = format ["%1_%2", _t, _stage];
                private _gi = _give findIf { (_x select 0) isEqualTo _item };
                if (_gi isEqualTo -1) then { _give pushBack [_item, _take]; } else { (_give select _gi) set [1, ((_give select _gi) select 1) + _take]; };
                _rem = _rem - _take;};
            private _keep = _cnt - _take;
            if (_keep > 0) then { _newCrop pushBack [_t, _lt, _keep]; };} forEach _crop;
        _house setVariable ["plb_barrel_crop", _newCrop, true];
        [_house] call _persist;
        private _summary = ""; {_x params ["_item", "_c"];
            [[true, _item, _c], "life_fnc_handleInv", _player, false, false] spawn life_fnc_MP;
            _summary = _summary + format ["%1x %2  ", _c, _item];} forEach _give;
        [[format ["Collected from the barrel: %1", _summary], "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
        ["-SPIRITS-", _player, format ["collected %1 (house %2)", _summary, _house getVariable ["plb_houseID", -1]]] call PLB_fnc_logIt;};
};
