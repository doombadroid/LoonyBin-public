disableSerialization;
createDialog "life_wallpaper_menu";
waitUntil {!isNull(findDisplay 315000)};
private _display = findDisplay 315000;
[_display] spawn life_fnc_p_updateMenu;
private _list = _display displayCtrl 315001;
private _details = _display displayCtrl 315002;
private _button = _display displayCtrl 315003;
_details ctrlSetStructuredText parseText "<t size='0.90' align='center'>Select a wallpaper</t>"; {if (call(_x select 3)) then {
        private _index = _list lbAdd format["%1", _x select 2];
        _list lbSetData[_index, _x select 1];
        _list lbSetValue[_index, _x select 0];};}
forEach life_wallpapers;
_button ctrlAddEventHandler["ButtonClick", {_this spawn life_fnc_setWallpaper}];
_list ctrlAddEventHandler["LBSelChanged", {ctrlSetText[90300, format["images\wallpapers\%1", lbData[315001, lbCurSel 315001]]];
    ctrlEnable[315003, !((lbValue[315001, lbCurSel 315001]) isEqualTo((profileNamespace getVariable "PLBClientSettings") select 0))];}];
_list lbSetCurSel(life_wallpapers findIf {(_x select 0) isEqualTo((profileNamespace getVariable "PLBClientSettings") select 0)});