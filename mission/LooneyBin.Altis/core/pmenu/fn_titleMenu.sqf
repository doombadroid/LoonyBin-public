disableSerialization;
createDialog "life_titles_menu";
waitUntil {!isNull(findDisplay 91000)};
private _display = findDisplay 91000;
[_display] spawn life_fnc_p_updateMenu;
private _list = _display displayCtrl 91001;
private _infoText = _display displayCtrl 91002;
private _titleButton = _display displayCtrl 91003;
_list ctrlAddEventHandler["LBSelChanged", "_this spawn life_fnc_titleSel"];
_titleButton ctrlAddEventHandler["ButtonClick", "[lbData [91001, lbCurSel 91001], 'plb_title'] call life_fnc_setTitle; (_this select 0) ctrlEnable false"]; {
    lbClear _x}
forEach[_list];
_titleButton ctrlEnable false;
private _titleSelect = -1;
private _timer = 0;
waitUntil {uiSleep 0.01;
    _timer = _timer + 0.01;
    (!(plbv_statTotals isEqualTo - 1) || _timer isEqualTo 200)};
if (_timer isEqualTo 200) exitWith {["We had trouble fetching your titles. Please try again later.", "basic"] spawn life_fnc_handleMessage;
};
private _index = _list lbAdd "Remove Title";
_list lbSetValue[_index, -1];
_list lbSetData[_index, ""];
if (isNil {player getVariable "plb_title"}) then {_list lbSetColor[_index, [1, 0, 0, 0.8]];
    _list lbSetSelectColor[_index, [1, 0, 0, 0.8]];};
private _allTitles = ([1] call life_fnc_titleCfg); {_x params["_id", "_name", "_sides", "_description", "_showDescription", "_unlocked"];
    if (playerSide in _sides) then {private _index = _list lbAdd format["%1", _name];
        _list lbSetValue[_index, _forEachIndex];
        _list lbSetData[_index, _name];
        if (_name isEqualTo((player getVariable["plb_title", ["", "#B6B6B6"]]) param[0, ""])) then {_list lbSetCurSel _index};
        if !(_unlocked) then {_list lbSetColor[_index, [1, 0, 0, 0.8]];
            _list lbSetSelectColor[_index, [1, 0, 0, 0.8]];};};}
forEach _allTitles;
if ((lbCurSel _list) isEqualTo - 1) then {_list lbSetCurSel 0;};
private _preTitle = ((player getVariable["plb_title", ["", "#B6B6B6"]]) param[0, ""]);
waitUntil {isNull(findDisplay 91000)};
if !(((player getVariable["plb_title", ["", "#B6B6B6"]]) param[0, ""]) isEqualTo _preTitle) then {[19] call life_fnc_ClupdatePartial;};