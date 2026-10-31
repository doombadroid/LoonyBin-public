private _item = cursorObject;
if (isNull _item) exitWith {};
private _index = [typeOf _item, life_placeable] call life_fnc_index;
if (_index isEqualTo - 1) exitWith {["This item cannot be picked up.", "basic"] spawn life_fnc_handleMessage};
if (!(_item getVariable['plb_placedItem', false])) exitWith {
    ["This item was not placed by a player and cannot be picked up.", "basic"] spawn life_fnc_handleMessage};
(life_placeable select _index) params["_itemCfgName", "_className", "_itemLongName", "_rotation", "_distance", "_damagable"];
if !([true, _itemCfgName, 1] call life_fnc_handleInv) exitWith {
    [format["You don't have room in your inventory for a %1.", _itemLongName], "basic"] spawn life_fnc_handleMessage};
[format["You picked up a %1.", _itemLongName], "basic"] spawn life_fnc_handleMessage;
// LooneyBin furniture: also remove from the house's persisted furniture row (matched by position)
if (_itemCfgName in PLB_furnitureItems) then {[["remove", getPosATL _item], "TON_fnc_houseFurnitureSRV", 2] spawn life_fnc_MP;};
deleteVehicle _item;