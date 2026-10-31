params[["_button", controlNull]];
private _display = findDisplay 315000;
private _wallpaperID =
if (!isNull _display) then {private _list = _display displayCtrl 315001;
    private _details = _display displayCtrl 315002;
    private _button = _display displayCtrl 315003;
    if (!isNull _button) then {_button ctrlEnable false};
    _list lbValue(lbCurSel _list)} else {(profileNamespace getVariable "PLBClientSettings") select 0};
life_wallpaper = _wallpaperID;
(profileNamespace getVariable "PLBClientSettings") set[0, life_wallpaper];
private _index = life_wallpapers findIf {(_x select 0) isEqualTo life_wallpaper};
private _wallpaperImage = (life_wallpapers select _index) select 1; {
    (_x displayCtrl 90300) ctrlSetText format["images\wallpapers\%1", _wallpaperImage]}
forEach[findDisplay 90000, findDisplay 315000];
[] spawn life_fnc_wallpaperAnim;   // restart the driver for the newly chosen wallpaper