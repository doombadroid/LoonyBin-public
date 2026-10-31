params[["_house", objNull, [objNull]]];
if (isNull _house || !(_house isKindOf "House_F")) exitWith {};
if (player distance _house > 20) exitWith {};
if (call life_copLevel < 5 && call life_medicLevel < 4 && !(_house in life_vehicles)) exitWith {};
private _isLocked = _house getVariable["plb_locked", false];
private _buildingName = getText(configFile >> "CfgVehicles" >> typeOf _house >> "displayName");
private _numDoors = getNumber(configFile >> "CfgVehicles" >> typeOf _house >> "numberOfDoors");
if (_numDoors < 1) exitWith {["You can't lock a building with no doors!", "basic"] spawn life_fnc_handleMessage;};
if (playerSide isEqualTo independent) exitWith {private _lockedDoors = 0;
    for "_i"
    from 1 to _numDoors do {if (_house getVariable[format["bis_disabled_Door_%1", _i], 0] isEqualTo 1) then {
            _lockedDoors = _lockedDoors + 1;};}; if (_lockedDoors isEqualTo 0) then {[1, 0]} else {[0, 1]}
    params["_num", "_animateState"];
    for "_i"
    from 1 to _numDoors do {
        if !((typeOf _house in ["Land_i_Shop_01_V1_F", "Land_i_Shop_01_V2_F", "Land_i_Shop_01_V3_F"]) && (_i == 1 || _i == 3)) then {
            _house setVariable[format["bis_disabled_Door_%1", _i], _num, true];
            _house animate[format["door_%1_rot", _i], _animateState];};};};
if (_isLocked) then {_isLocked = false;
    [format["Unlocked all doors of %1.", _buildingName], "basic"] spawn life_fnc_handleMessage;} else {_isLocked = true;
    [format["Locked all doors of %1.", _buildingName], "basic"] spawn life_fnc_handleMessage;};
_house setVariable["plb_locked", _isLocked, true];
private _num =
if (_isLocked) then {1} else {0};
for "_i"
from 1 to _numDoors do {
    if !((typeOf _house in ["Land_i_Shop_01_V1_F", "Land_i_Shop_01_V2_F", "Land_i_Shop_01_V3_F"]) && (_i == 1 || _i == 3)) then {
        _house setVariable[format["bis_disabled_Door_%1", _i], _num, true];
        if (_isLocked) then {_house animate[format["door_%1_rot", _i], 0];};};}; private _soundFile =
if (_isLocked) then {"lock"} else {"unlock"};
private _toSend = (allPlayers - [allDeadMen]) select {(_x distance player) <= 10}; [
    [player, _soundFile], "life_fnc_playSound", _toSend, false, false] spawn life_fnc_MP;