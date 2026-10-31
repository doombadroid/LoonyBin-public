params[["_type", "", [""]], ["_controlData", [], [[]]]];
private _plb_display = findDisplay 39400;
if (isNull _plb_display) exitWith {};
private _filterList = _plb_display displayCtrl 39402;
private _mainListGroup = _plb_display displayCtrl 39404;
private _mainItemList = _mainListGroup controlsGroupCtrl 1000;
private _mainItemListBackground = _mainListGroup controlsGroupCtrl 1003;
private _sideListGroup = _plb_display displayCtrl 39405;
private _sideItemList = _sideListGroup controlsGroupCtrl 1000;
private _sideItemListButton = _sideListGroup controlsGroupCtrl 1001;
private _deleteButton = _sideListGroup controlsGroupCtrl 1005;
private _saveButton = _sideListGroup controlsGroupCtrl 1004; {_x ctrlEnable false;}
forEach[_deleteButton, _saveButton, _sideItemListButton];
private _indexValZero = (_sideItemList lnbValue[lbCurSel _sideItemList, 0]);
private _indexValOne = (_sideItemList lnbValue[lbCurSel _sideItemList, 1]);
private _loadoutName =
if (_indexValZero in [-3, -5]) then {((life_loadoutHolder select _indexValOne) select 2)} else {
    ((life_loadoutHolder select _indexValZero) select 2)};
private _uniqueID =
if (_indexValZero in [-3, -5]) then {((life_loadoutHolder select _indexValOne) select 0)} else {
    ((life_loadoutHolder select _indexValZero) select 0)};
private _action = [format["Are you sure you want to delete the loadout named %1?", _loadoutName], "Loadout Delete Confirmation", "Delete", "Cancel"] call BIS_fnc_guiMessage;
if !(_action) exitWith {};
closeDialog 0;
if (_indexValZero in [-3, -5] || (_indexValZero >= 0 && _indexValZero <= 5)) then {[
        [1, getPlayerUID player, _uniqueID, playerSide], "TON_fnc_handleLoadouts", 2] call life_fnc_MP;
    if (_indexValZero in [-3, -5]) then {life_loadoutHolder set[_indexValOne, []];} else {life_loadoutHolder set[_indexValZero, []];};
    [format["You have successfully deleted the %1 loadout!", _loadoutName], "basic"] spawn life_fnc_handleMessage;}; [
    ["-LOADOUTDEL-", player, (profileName), format["attempted to delete loadout %1 at POS: %2", _uniqueID, getPosATL player]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
waitUntil {!dialog};
[nil, nil, nil, _type] spawn life_fnc_loadoutMenu;