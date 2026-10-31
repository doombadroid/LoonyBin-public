if ((lbCurSel 361001) isEqualTo - 1) exitWith {["You didn't select an item you wanted to give", "basic"] spawn life_fnc_handleMessage;
    false};
if ((lbCurSel 361003) isEqualTo - 1) exitWith {["You didn't selected anyone to give this to", "basic"] spawn life_fnc_handleMessage;
    false};
private _item = lbData[361001, lbCurSel 361001];
if (_item isEqualTo "") exitWith {false};
private _unit = allUnits param[allUnits findIf {(getPlayerUID _x) isEqualTo(lbData[361003, lbCurSel 361003])}, objNull];
if ((isNull _unit) || (_unit isEqualTo player)) exitWith {false};
private _itemMax = missionNamespace getVariable(format["life_inv_%1", _item]);
private _itemQuantity =
if ((parseNumber(ctrlText 361002)) > _itemMax) then[{_itemMax}, {parseNumber(ctrlText 361002)}];
if ((life_is_processing) && (life_action_in_use)) exitWith {
    ["You cannot give items while processing", "basic"] spawn life_fnc_handleMessage;
    false};
if (player getVariable["plb_restrained", false]) exitWith {
    ["Your hands are bound, how can you possibly give that person anything?", "basic"] spawn life_fnc_handleMessage;
    false};
if (lineIntersects[eyePos player, aimPos _unit, vehicle player, _unit]) exitWith {
    ["It would be hard to pass things through the wall, don't you think?", "basic"] spawn life_fnc_handleMessage;
    false};
if (_itemQuantity <= 0) exitWith {["You need to enter an actual amount you want to give", "basic"] spawn life_fnc_handleMessage;
    false};
if !([false, _item, _itemQuantity] call life_fnc_handleInv) exitWith {
    ["Couldn't give that much of that item, maybe you don't have that amount?", "basic"] spawn life_fnc_handleMessage;
    false};
if !([str _itemQuantity] call life_fnc_isNumber) exitWith {["You didn't enter a positive integer.", "basic"] spawn life_fnc_handleMessage;
}; [[_unit, _itemQuantity, _item, player], "life_fnc_receiveItem", _unit, false, false] spawn life_fnc_MP;
[format["You gave %1 %2 %3.", name _unit, _itemQuantity, ["getName", _item] call life_fnc_virtItemCfg], "basic"] spawn life_fnc_handleMessage;
[false] spawn life_fnc_inventory;
[true] call life_fnc_saveGear;
true