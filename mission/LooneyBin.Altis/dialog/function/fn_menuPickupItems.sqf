disableSerialization;
if !(params[["_obj", objNull, [objNull]]]) exitWith {};
if (life_pickingUpItems) exitWith {["You are still in the process of picking up items!", "basic"] spawn life_fnc_handleMessage};
if ((_obj getVariable["plb_ufoLoot", false]) && ((SRV_ufoCrash select 2) > serverTime - 900)) exitWith {closeDialog 0;
    [format["This radiated loot is unstable right now. Try in another %1 minutes. Check back frequently!", ceil((((SRV_ufoCrash select 2) + 900) - serverTime) / 60)], "basic"] spawn life_fnc_handleMessage;
};
private _nearUnits = player nearEntities["CAManBase", 8] select {isPlayer _x && !(_x isEqualTo player)};
if !(isNull(_obj getVariable["plb_inUse", objNull])) exitWith {
    ["Someone is already accessing these items.", "basic"] spawn life_fnc_handleMessage;
    closeDialog 0;};
if !(_nearUnits isEqualTo[]) then {uiSleep(random 1.5)};
if !(isNull(_obj getVariable["plb_inUse", objNull])) exitWith {
    ["Someone is already accessing these items.", "basic"] spawn life_fnc_handleMessage;
    closeDialog 0;};
_obj setVariable["plb_inUse", player, true];
["life_pickup_items"] call life_fnc_createDialog;
private _display = findDisplay 1520;
private _itemList = _display displayCtrl 1521;
private _pickupButton = _display displayCtrl 1522;
_pickupButton ctrlEnable false;
lbClear _itemList;
life_didServerRespond = false;
private _maxDelayTime = time + 5; [[player], "TON_fnc_lagCheck", 2] spawn life_fnc_MP;
waitUntil {time > _maxDelayTime || life_didServerRespond};
if (time > _maxDelayTime) exitWith {closeDialog 0;
    ["Menu failed, try again.", "basic"] spawn life_fnc_handleMessage;
    if (_obj getVariable["plb_inUse", objNull] isEqualTo player) then {_obj setVariable["plb_inUse", nil, true]};};
_pickupButton ctrlEnable true;
private _items = _obj getVariable["plb_droppedItems", []];
life_pickMenuItems = +_items; {_x params["_itemShortName", "_itemAmount"];
    private _text =
    if (_itemShortName isEqualTo "money") then {format["$%1 Cash", [_itemAmount] call life_fnc_numberText];} else {
        format["%1x %2", _itemAmount, ["getName", _itemShortName] call life_fnc_virtItemCfg];};
    private _index = _itemList lbAdd _text;
    _itemList lbSetData[_index, format["['%1', %2]", _itemShortName, _itemAmount]];
    _itemList lbSetPicture[_index, ["getIcon", _itemShortName] call life_fnc_virtItemCfg];}
forEach life_pickMenuItems;
waitUntil {isNull _display && !life_pickingUpItems};
if !(isNull _obj) then {uiSleep 0.1;
    _obj setVariable["plb_inUse", nil, true];
    if (life_pickMenuItems isNotEqualTo _items) then {_obj setVariable["plb_droppedItems", life_pickMenuItems, true];};};