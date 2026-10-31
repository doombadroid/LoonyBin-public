params["_control", "_selectedIndex"];
disableSerialization;
private _display = findDisplay 91000;
if (isNull _display) exitWith {};
private _list = _display displayCtrl 91001;
private _infoText = _display displayCtrl 91002;
private _titleButton = _display displayCtrl 91003;
private _index = _list lbValue _selectedIndex;
if (_index isEqualTo - 1) exitWith {_titleButton ctrlEnable(!isNil {player getVariable "plb_title"});
    private _rmvText =
    if (isNil {player getVariable "plb_title"}) then {
        "<t size='0.25'>&#160;</t><br/><t align='center' size='0.65'>You currently do not have a title set</t>"} else {
        "<t size='0.25'>&#160;</t><br/><t align='center' size='0.65'>Remove your current title</t>"};
    _infoText ctrlSetStructuredText parseText _rmvText;};
private _allTitles = [1] call life_fnc_titleCfg;
private _title = _allTitles select _index;
_title params["_id", "_name", "_sides", "_description", "_showDescription", "_unlocked"];
_titleButton ctrlEnable(!(_name isEqualTo "") && _unlocked && !(((player getVariable["plb_title", ["", "#B6B6B6"]]) param[0, ""]) isEqualTo _name));
_description =
if !(_unlocked || _showDescription) then {"Unlock Requirements Hidden"} else {_description};
private _text = parseText format["<t size='0.25'>&#160;</t><br/><t align='center' size='0.65'>%1</t>", _description];
_infoText ctrlSetStructuredText _text;