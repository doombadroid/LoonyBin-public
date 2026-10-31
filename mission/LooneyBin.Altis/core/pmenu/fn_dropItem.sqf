#include "..\..\macro.h"
if (scriptAvailable(2)) exitWith {["Please don't spam item drops!", "basic"] spawn life_fnc_handleMessage;};
if ((life_is_processing) && (life_action_in_use)) exitWith {
    ["You cannot drop items while processing!", "basic"] spawn life_fnc_handleMessage;
    true};
if (((getPosASL player) select 2) < 0) exitWith {["You cannot drop items while under water!", "basic"] spawn life_fnc_handleMessage;
    true};
if (((time - life_last_transfer) < 3)) exitWith {
    ["You can only drop items once per 3 seconds. Try dropping more at a time.", "basic"] spawn life_fnc_handleMessage;
    true};
if (!(isNull objectParent player) && !(objectParent player isKindOf "Ship")) exitWith {
    ["You cannot drop items from inside a vehicle!", "basic"] spawn life_fnc_handleMessage;
    true};
if (player getVariable["plb_restrained", false]) exitWith {
    ["You cannot drop items while restrained!", "basic"] spawn life_fnc_handleMessage;
    true};
if (isOnRoad player && ((life_is_arrested select 0) isEqualTo 0)) exitWith {
    ["Littering on the road is not acceptable!", "basic"] spawn life_fnc_handleMessage;
    true};
private _nearbyCases = {!((_x getVariable["plb_droppedItems", []]) isEqualTo[]) && (isNull(_x getVariable["plb_inUse", objNull]))}
count(nearestObjects[player, [], 4]);
if (_nearbyCases >= 3) exitWith {
    ["Please make a suitcase pile elsewhere or wait for a nearby case to not be in use by other people.", "basic"] spawn life_fnc_handleMessage;
    true};
private _shortName = lbData[361001, lbCurSel 361001];
private _playerTypedDropAmount = parseNumber(ctrlText 361002);
private _itemMax = missionNamespace getVariable(format["life_inv_%1", _shortName]);
if (isNil "_itemMax") exitWith {["You can't drop this item!", "basic"] spawn life_fnc_handleMessage;};
if (_shortName isEqualTo "") exitWith {["You need to select an item to drop.", "basic"] spawn life_fnc_handleMessage;};
if (_shortName in ["debitcard", "humanscalp"]) exitWith {["You cannot drop this item.", "basic"] spawn life_fnc_handleMessage;};
IF!([str _playerTypedDropAmount] call life_fnc_isNumber) exitWith {["You must enter a round number.", "basic"] spawn life_fnc_handleMessage
};
if (_playerTypedDropAmount <= 0) exitWith {};
if (_playerTypedDropAmount > _itemMax) then {
    [format["You attempted to drop %1, but you only had %2 so that has been dropped instead", _playerTypedDropAmount, _itemMax], "basic"] spawn life_fnc_handleMessage;
    _playerTypedDropAmount = _itemMax;};
private _action = true;
if ((life_is_arrested select 0) isEqualTo 1) then {
    _action = ["Dropping this item while in jail will delete it. Are you sure?", "Delete Item", "Yes", "No"] call BIS_fnc_guiMessage;};
if !(_action) exitWith {}; [
    ["-ITEMDROPPED-", player, profileName, format["dropped %1 %2, Position: %3.", _playerTypedDropAmount, ["getName", _shortName] call life_fnc_virtItemCfg, getPosATL player]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
missionNamespace setVariable[format["life_inv_%1", _shortName], _itemMax - _playerTypedDropAmount];
[false] call life_fnc_saveGear;
[3] call life_fnc_ClupdatePartial;
if ((life_is_arrested select 0) isEqualTo 0) then {private _pos =
    if (objectParent player isKindOf "Ship") then {(objectParent player) modelToWorld[0, -8, -1]} else {getPosASL player}; [[[
                [_shortName, _playerTypedDropAmount]], _pos, "Land_Suitcase_F"], "TON_fnc_createItem", 2] spawn life_fnc_MP;};
[false] spawn life_fnc_inventory;
[] call life_fnc_calWeight;
[findDisplay 361000] spawn life_fnc_p_updateMenu;