params[["_vehicle", objNull, [objNull]]];
if (isNull _vehicle) exitWith {};
if (playerSide isNotEqualTo civilian) exitWith {};
if (life_gatheringDevice) exitWith {["You can only operate one gathering device at a time.", "basic"] spawn life_fnc_handleMessage;};
life_gatheringDevice = true;
private _zone = "";
private _resourceZones = ["apple_1", "apple_2", "apple_4", "apple_5", "peaches_2", "peaches_3", "peaches_4", "weed_1", "illegal_marker_1_0", "illegal_marker_2_0", "illegal_marker_3_0", "illegal_marker_8_0"];
private _maxWeight = _vehicle getVariable["plb_vcap", ["getVirtCap", "", typeOf _vehicle] call life_fnc_vehicleConfig];
if !(objNull isEqualTo(_vehicle getVariable["plb_mining", objNull])) exitWith {
    ["This vehicle is already mining", "basic"] spawn life_fnc_handleMessage;
    life_gatheringDevice = false;};
_vehicle setVariable["plb_mining", player, true];
private _totalGathered = 0;
private _itemGathered = "";
private _dbInfo = _vehicle getVariable["plb_dbInfo", []];
while {driver _vehicle isEqualTo player}
do {if (!alive _vehicle || isNull _vehicle || !alive player) exitWith {};
    private _zone = _resourceZones param[_resourceZones findIf {(player distance(getMarkerPos _x) < 290)}, ""];
    private _gatherArray =
    switch (true) do {case (_zone isEqualTo "illegal_marker_1_0"): {["heroinu", 290];};
        case (_zone isEqualTo "illegal_marker_2_0"): {["cocaine", 290];};
        case (_zone isEqualTo "illegal_marker_3_0"): {["ephedrau", 290];};
        case (_zone isEqualTo "illegal_marker_8_0"): {["henbane", 290];};
        case (_zone isEqualTo "weed_1"): {["cannabis", 290];};
        case (_zone find "apple" != -1): {["apple", 50];};
        case (_zone find "peaches" != -1): {["peach", 50];};
        default {["", 0]};}; _gatherArray params["_item", "_distance"];
    _itemGathered = _item;
    if !(_gatherArray isEqualTo["", 0]) then {
        if ((player distance(getMarkerPos _zone) < _distance) && (speed player > 5) && (((getPosATL player) select 2) < 2) && !(dialog)) then {
            private _vehInv = _vehicle getVariable["plb_vinv", [[], 0]];
            _vehInv params["_items", "_weight"];
            private _sum = [_item, 3, _weight, _maxWeight] call life_fnc_calWeightDiff;
            if (_sum < 1) exitWith {titleText["The vehicle is full", "PLAIN"];};
            private _itemWeight = ((["getItemWeight", _item] call life_fnc_virtItemCfg) * _sum);
            private _index = _items findIf {(_x select 0) isEqualTo _item};
            if (_index isEqualTo - 1) then {_items pushBack[_item, _sum];} else {private _oldVal = (_items select _index) select 1;
                (_items select _index) set[1, _oldVal + _sum];};
            titleText[format["The tractor has gathered %1 %2. %3/%4.", _sum, ["getName", _item] call life_fnc_virtItemCfg, _weight + _itemWeight, _maxWeight], "PLAIN"];
            [_item, _sum] call life_fnc_statArrUpdate;
            _totalGathered = _totalGathered + _sum;
            _vehicle setVariable["plb_vinv", [_items, _weight + _itemWeight], true];
            _sum = [_item, 3, _weight + _itemWeight, _maxWeight] call life_fnc_calWeightDiff;
            if (_sum < 1) exitWith {titleText["The vehicle is full", "PLAIN"];};};};
    if !(driver _vehicle isEqualTo player) exitWith {};
    uiSleep 8;}; life_gatheringDevice = false;
if ((_totalGathered isNotEqualTo 0) && (_itemGathered isNotEqualTo "") && (_dbInfo isNotEqualTo[])) then {
    _dbInfo params["_ownerPID", "_plate"];
    _keychainUIDs = (_vehicle getVariable["plb_vehOwners", []]); [
        ["-GATHERTRACTOR-", player, profileName, format["gathered %1 %2 with a tractor at position %3. Plate: %4. OwnerUID: %5. Keychain: %6", _totalGathered, ["getName", _itemGathered] call life_fnc_virtItemCfg, getPosATL player, _plate, _ownerPID, _keychainUIDs]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
};
_vehicle setVariable["plb_mining", objNull, true];