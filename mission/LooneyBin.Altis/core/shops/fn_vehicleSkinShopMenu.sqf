private _unit = cursorObject;
if (isNull _unit) exitWith {};
if !(_unit isKindOf "CAManBase") exitWith {};
if !(isNull objectParent player) exitWith {
    ["This action cannot be performed from within a vehicle.", "basic"] spawn life_fnc_handleMessage;};
if ((player distance _unit) > 10) exitWith {["You are too far away.", "basic"] spawn life_fnc_handleMessage;};
if (serverRestartLock) exitWith {
    ["You cannot access this menu right now. Try again after the restart!", "basic"] spawn life_fnc_handleMessage;};
if (player getVariable["plb_restrained", false]) exitWith {};
if (player getVariable["plb_surrendered", false]) exitWith {};
disableSerialization;
["life_vehicle_skin_shop"] call life_fnc_createDialog;
private _config = call life_fnc_vehicleSkinShopCfg;
if (_config isEqualType "") exitWith {closeDialog 0;};
_config params["_shopTitle", "_itemArray"];
ctrlSetText[39401, _shopTitle];
private _itemList = ((findDisplay 39400) displayCtrl 39403);
private _buyBtn = ((findDisplay 39400) displayCtrl 39405);
lbClear _itemList;
private _itemInfo = "";
private _itemName = "";
private _index = 0;
private["_vehInfo"]; {_x params["_className", "_customName", "_skinCrateRewardID", "_price"];
    _vehInfo = [_className] call life_fnc_fetchVehInfo;
    _itemName = _customName;
    _index = _itemList lbAdd _itemName;
    _itemList lbSetData[_index, str _skinCrateRewardID];
    _itemList lbSetPicture[(lbSize _itemList) - 1, (_vehInfo select 2)];
    _itemList lbSetValue[_index, _price];}
forEach _itemArray;
((findDisplay 39400) displayCtrl 39405) ctrlSetText "Buy";
_itemList ctrlSetEventHandler["LBSelChanged", format["[_this, '%1'] call life_fnc_vehicleSkinShopSelection"]];
_buyBtn ctrlSetEventHandler["ButtonClick", format["[((findDisplay 39400) displayCtrl 39403), lbCurSel 39403, '%1'] call life_fnc_vehicleSkinShopBuy"]];