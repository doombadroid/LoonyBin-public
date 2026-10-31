disableSerialization;
createDialog "Life_license_menu";
waitUntil {!isNull(findDisplay 31800)};
private _display = findDisplay 31800;
[_display] spawn life_fnc_p_updateMenu;
private _list = _display displayCtrl 31801;
private _details = _display displayCtrl 31802;
private _unitSide =
switch (playerSide) do {case west: {"cop"};
    case civilian: {"civ"};
    case independent: {"med"}}; { _x params["_license", "_side"];
    if (_side isEqualTo _unitSide) then {private _displayName = ["varToStr", _license] call life_fnc_licenseCfg;
        private _isUnlocked = missionNamespace getVariable[_license, false];
        if ((_isUnlocked) && !(_displayName isEqualTo "")) then {_list lbAdd format["%1", _displayName]};};}
forEach life_licenses;
_details ctrlSetStructuredText parseText "<t size='0.90' align='center'>Current Licenses</t>";