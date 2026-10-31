params[["_display", displayNull]];
if (isNull _display) exitWith {};
private _wallpaper = _display displayCtrl 90300;
private _statusLeft = _display displayCtrl 90301;
private _statusCenter = _display displayCtrl 90302;
private _statusRight = _display displayCtrl 90303;
private _defaultWallpaperImage = life_wallpapers select(life_wallpapers findIf {
    (_x select 0) isEqualTo(life_clientDefaultSettings select 0)}) select 1;
private _wallpaperID = (profileNamespace getVariable["PLBClientSettings", [1]]) select 0;
private _index = life_wallpapers findIf {(_x select 0) isEqualTo _wallpaperID};
private _wallpaperImage =
if (_index isEqualTo - 1) then[{_defaultWallpaperImage}, {(life_wallpapers select _index) select 1}];
_wallpaper ctrlSetText format["images\wallpapers\%1", _wallpaperImage];
[] spawn life_fnc_wallpaperAnim;   // no-op unless the selected wallpaper is animated
if (!ctrlShown _statusLeft) then {{_x ctrlSetFade 1;
        _x ctrlCommit 0}
    forEach[_statusLeft, _statusCenter, _statusRight]};
while {!isNull _display}
do {private _hour = date select 3;
    private _min = date select 4;
    if (_hour < 10) then {_hour = format["0%1", _hour];};
    if (_min < 10) then {_min = format["0%1", _min];};
    private _ttr =
    if (isNil "serverStartTime") then {round((14400 - serverTime) / 60)} else {
        round((serverCycleLength - (serverTime - serverStartTime)) / 60)};
    private _textLeft = format["$%1", [life_cash] call life_fnc_numberText];
    private _textCenter = format["%1:%2 [%3 mins]", _hour, _min, _ttr];
    private _textRight = format["%1/%2", life_carryWeight, life_maxWeight];
    _statusLeft ctrlSetStructuredText parseText("<t align='left' shadow='0' size='0.7'>" + _textLeft + "</t>");
    _statusCenter ctrlSetStructuredText parseText("<t align='center' shadow='0' size='0.7'>" + "   " + _textCenter + "</t>");
    _statusRight ctrlSetStructuredText parseText("<t align='right' shadow='0' size='0.7'>" + _textRight + "</t>");
    if (!ctrlShown _statusLeft) then {{_x ctrlShow true;
            _x ctrlSetFade 0;
            _x ctrlCommit 0}
        forEach[_statusLeft, _statusCenter, _statusRight]};
    uiSleep 1;};