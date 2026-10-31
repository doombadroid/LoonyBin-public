#include "..\..\macro.h"
if (scriptAvailable(2)) exitWith {
    ["Wait a couple of seconds before attempting to use the swap function again."] spawn life_fnc_handleMessage};
// LooneyBin 2026-07-16: Loonazon delivery boxes are TAKE-ONLY -- swap trades a player item INTO the box, so
// block it here too (the opener hides the button; belt for any other entry).
if ((life_trunk_vehicle getVariable["plb_packageOwner", ""]) isNotEqualTo "") exitWith {
    ["The Loonazon box is take-only.", "basic"] spawn life_fnc_handleMessage;};
disableSerialization;
private _trunkSel = lbData[4502, lbCurSel 4502];
private _playerSel = lbData[4503, lbCursel 4503];
private _trunkNum = parseNumber(ctrlText 4505);
private _playerNum = parseNumber(ctrlText 4506);
if (lbCurSel 4502 isEqualTo - 1 || lbCurSel 4503 isEqualTo - 1 || _trunkSel isEqualTo "" || _playerSel isEqualTo "") exitWIth {
    ["You need to select an item from both inventories.", "basic"] spawn life_fnc_handleMessage;};
if (_trunkNum <= 0 || _playerNum <= 0) exitWith {
    ["You need to select a number above 0 for both inventories.", "basic"] spawn life_fnc_handleMessage;};
if (_trunkSel isEqualTo _playerSel) exitWith {
    ["It seems you've selected the same item... What would that accomplish?", "basic"] spawn life_fnc_handleMessage;};
if (_playerSel in ["goldbar", "bank_money"] && life_trunk_vehicle isKindOf "House_F") exitWith {
    ["You can't fit this into your house.", "basic"] spawn life_Fnc_handleMessage;};
if (_playerSel isEqualTo "goldbar" && life_trunk_vehicle isKindOf "Air") exitWith {
    ["This is too heavy for safe air transport.", "basic"] spawn life_fnc_handleMessage;};
if (_playerSel in ["crankp", "crank"] && life_trunk_vehicle isKindOf "House_F") exitWith {
    ["This item is too dangerous to store in your home!", "basic"] spawn life_Fnc_handleMessage;};
if ((_playerSel in ["uraniumu", "uraniump"]) && !((typeOf life_trunk_vehicle) in ["B_Truck_01_box_F", "C_Van_01_box_F"])) exitWith {
    ["This needs a HEMTT Box or Box Truck to safely transport!", "basic"] spawn life_fnc_handleMessage;};
if ((_playerSel in ["jewelHope", "jewelRolex", "jewelAP", "jewelDiamonds", "jewelGoldBag", "jewelExoJewels", "jewelRing", "jewelBling", "jewelBag"]) && life_trunk_vehicle isKindOf "Air") exitWith {
    ["This is too heavy for safe air transport!", "basic"] spawn life_fnc_handleMessage;};
if ((_playerSel in ["jewelHope", "jewelRolex", "jewelAP", "jewelDiamonds", "jewelGoldBag", "jewelExoJewels", "jewelRing", "jewelBling", "jewelBag"]) && life_trunk_vehicle isKindOf "House_F") exitWith {
    ["The African Warlord's henchmen will not allow you to store this!!"] spawn life_fnc_handleMessage;};
private _vehicleWeights = [life_trunk_vehicle, true] call life_fnc_vehicleWeight;
_vehicleWeights params["_max", "_used"];
private _itemSelWeight = _playerNum * (["getItemWeight", _playerSel] call life_fnc_virtItemCfg);
private _trunkSelWeight = _trunkNum * (["getItemWeight", _trunkSel] call life_fnc_virtItemCfg);
private _trunkWeightCheck = (_used + _itemSelWeight - _trunkSelWeight) > _max;
private _playerWeightCheck = (life_carryWeight - _itemSelWeight + _trunkSelWeight) > life_maxWeight;
if (_trunkWeightCheck && _playerWeightCheck) exitWith {
    ["Neither you or the vehicle can swap the number of items you've selected!", "basic"] spawn life_fnc_handleMessage;};
if (_trunkWeightCheck && !(_playerWeightCheck)) exitWith {
    ["The vehicle's trunk won't be able to hold the amount of items you are trying to swap!", "basic"] spawn life_fnc_handleMessage;};
if (_playerWeightCheck && !(_trunkWeightCheck)) exitWith {
    ["Your inventory won't be able to hold the amount of items you are trying to swap for.", "basic"] spawn life_fnc_handleMessage;};
(life_trunk_vehicle getVariable["plb_vinv", [[], 0]]) params["_items", "_trunkWeight"];
private _oldVirt = +(life_trunk_vehicle getVariable["plb_vinv", [[], 0]]);
private _oldPhys = +(life_trunk_vehicle getVariable["plb_pinv", [[], 0]]);
private _index = _items findIf {_x select 0 == _trunkSel};
if (_index isEqualTo - 1) exitWith {};
private _value = (_items select _index) select 1;
if (_trunkNum > _value) exitWith {["The vehicle doesn't have that many of that item.", "basic"] spawn life_fnc_handleMessage;};
if !([false, _playerSel, _playerNum] call life_fnc_handleInv) exitWith {
    ["You don't have that many of that item.", "basic"] spawn life_fnc_handleMessage;};
[true, _trunkSel, _trunkNum] call life_fnc_handleInv;
if (_trunkNum isEqualTo _value) then {_items deleteAt _index;} else {(_items select _index) set[1, _value - _trunkNum];};
private _index = _items findIf {_x select 0 == _playerSel};
if (_index isEqualTo - 1) then {_items pushBack[_playerSel, _playerNum];} else {private _oldValue = (_items select _index) select 1;
    (_items select _index) set[1, _oldValue + _playerNum];};
life_trunk_vehicle setVariable["plb_vinv", [_items, _trunkWeight + (_itemSelWeight - _trunkSelWeight)], true];
[life_trunk_vehicle, life_is_virtual] call life_fnc_refreshInventory;
private _getPlayerInv = {private _array = [];
    private _val = 0; {_val = missionNamespace getVariable format["life_inv_%1", _x];
        if ((_val) > 0) then {_array pushBack[_x, _val];};}
    forEach([2] call life_fnc_virtItemCfg);
    _array;};
private _newVirt = life_trunk_vehicle getVariable["plb_vinv", [[], 0]];
private _newPhys = life_trunk_vehicle getVariable["plb_pinv", [[], 0]];
if (life_trunk_vehicle isKindOf "House_F") then {[
        ["-HOUSEINV-", player, (profileName), format["Swapped storage of house (HouseID: %1 | Owner: %2 | Position: %3). Virtual change: %4, Physical change: %5, Player Virtual Inventory: %6, Player Physical Inventory: %7", life_trunk_vehicle getVariable["plb_houseID", -1], life_trunk_vehicle getVariable["plb_homeOwner", "NoPidVar"], getPosATL life_trunk_vehicle, [_oldVirt, _newVirt] call life_fnc_inventoryDifference, [_oldPhys, _newPhys] call life_fnc_inventoryDifference, [] call _getPlayerInv, getUnitLoadout player]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
} else {[
        ["-VEHINV-", player, (profileName), format["Swapped vehicle trunk (Vehicle: %1 | Owner: %2 | Position: %5). Virtual change: %3, Player Virtual Inventory: %4", typeOf life_trunk_vehicle, life_trunk_vehicle getVariable["plb_dbInfo", "NoVehData"], [_oldVirt, _newVirt] call life_fnc_inventoryDifference, [] call _getPlayerInv, getPosATL player]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
};