params["_control", "_selectedIndex"];
disableSerialization;
private _display = findDisplay 3100;
if (isNull _display) exitWith {};
private _list = _display displayCtrl 3101;
private _infoText = _display displayCtrl 3102;
private _titleText = _display displayCtrl 3103;
private _titleButton = _display displayCtrl 3104;
private _id = _list lbValue _selectedIndex;
if (_id isEqualTo - 1) exitWith {_titleText ctrlSetText "Achievement has no title";
    _titleButton ctrlEnable(!isNil {player getVariable "plb_prefix"});
    _infoText ctrlSetStructuredText parseText "<t size='0.25'>&#160;</t><br/><t align='center' size='0.65'>Remove your current title</t>";
};
private _achievement = life_achievementInfo param[life_achievementInfo findIf {_id isEqualTo(_x select 0)}, []];
_achievement params["_id", "_sides", "_name", "_condition", "_desc", "_rewards", "_title", "_isHidden"];
private _text =
if (_title isEqualTo "") then {"<t size='0.90' color='#%2' align='center'>Achievement has no title</t>"} else {
    format["<t size='0.90' color='#%2' align='center'>%1</t>", format[_title, profileName], [_title] call life_fnc_getTitleColor]};
_titleText ctrlSetStructuredText parseText _text;
_titleButton ctrlEnable(!(_title isEqualTo "") && (_id in life_achievements) && !((player getVariable["plb_prefix", ""]) isEqualTo _title));
private _rewardText = ""; {_rewardText = _rewardText + format["- %1<br/>", _x]}
forEach _rewards;
private _rewardText =
if (_rewardText isEqualTo "") then[{"None"}, {_rewardText}];
private _text = parseText format["<t size='0.25'>&#160;</t><br/><t align='center' size='0.65'>%1</t><br/><t size='0.50  '>&#160;</t><br/><t align='center' size='0.65'>Rewards</t><br/><t align='center' size='0.65'>%2</t>", _desc, _rewardText];
_infoText ctrlSetStructuredText _text;