params["_wantedList", "_selectedIndex"];
disableSerialization;
private _display = ctrlParent _wantedList;
if (isNull _display) exitWith {};
private _connection = _display displayCtrl 2401;
private _criminalState = _display displayCtrl 2403;
private _bountyPrice = _display displayCtrl 2404;
private _chargesList = _display displayCtrl 2405;
private _removeInput = _display displayCtrl 2406;
private _removeButton = _display displayCtrl 2407;
private _button1 = _display displayCtrl 2408;
private _button2 = _display displayCtrl 2409;
private _button3 = _display displayCtrl 2410;
lbClear _chargesList;
_chargesList lbSetCurSel - 1; {if (ctrlShown _x) then {_x ctrlEnable false}}
forEach[_removeInput, _removeButton];
if ((lbCurSel _wantedList) isEqualTo - 1) exitWith {};
private _data = _wantedList lbData(lbCurSel _wantedList);
private _data = parseSimpleArray _data;
if !(_data isEqualType[]) exitWith {_wantedList lbDelete _selectedIndex;
    _wantedList lbSetCurSel - 1;};
if !(_data params[["_name", ""], ["_unitUID", ""], ["_charges", []], ["_bounty", 0]]) exitWith {_wantedList lbDelete _selectedIndex;
    _wantedList lbSetCurSel - 1;};
private _players = allPlayers;
private _unit = _players param[_players findIf {(getPlayerUID _x) isEqualTo _unitUID}, objNull];
if (isNull _unit) exitWith {_wantedList lbDelete _selectedIndex;};
if (_charges isEqualTo[]) exitWith {_wantedList lbAdd "Failed to display crimes";};
// LooneyBin: life_wanted_list[2] is a FLAT list of charge IDs repeated per count (TON_fnc_wantedSyncList /
// wanted_add "chargeIDs, repeats" format). Group it into [chargeID, count] pairs so a charge applied xN shows
// "N count(s)" -- the display loop below expected pre-grouped pairs, so after the A_stats_crimes refactor every
// duplicate rendered as its own "1 count(s)" row ("count shows x1 not x2"). Producer + remove-path stay flat.
private _grouped = []; {private _cid = _x;
    private _gi = _grouped findIf { (_x select 0) isEqualTo _cid };
    if (_gi isEqualTo -1) then {_grouped pushBack [_cid, 1];} else {(_grouped select _gi) set [1, ((_grouped select _gi) select 1) + 1];};}
forEach _charges; {_x params["_chargeID", "_chargeAmount"];
    private _chargeName = ["getChargeName", _chargeID] call life_fnc_wantedChargesConfig;
    private _index = _chargesList lbAdd format["%1 count(s) of %2", _chargeAmount, _chargeName];
    _chargesList lbSetData[_index, _chargeID];
    _chargesList lbSetValue[_index, _chargeAmount];}
forEach _grouped;
private _index = _chargesList lbAdd "";
_chargesList lbSetData[_index, ""];
_bountyPrice ctrlSetText format["Current Bounty Price: $%1", [_bounty] call life_fnc_numberText];
_criminalState ctrlSetText format["Criminal Status: %1", if (_unit getVariable["plb_arrested", false]) then {"Arrested"} else {
    "Not Arrested"}];
private _isPardon = (ctrlText _button1) isEqualTo(toUpper "Pardon");
private _toggle = !((_unit getVariable["plb_arrested", false]) && ((call life_adminLevel) <= 2));
if (_isPardon) then {_button1 ctrlEnable _toggle} else {_button1 ctrlEnable true};
if !(life_bounty_list isEqualTo[]) then {_button2 ctrlEnable true};
if (((getPlayerUID player) isEqualTo _unitUID) && (call life_adminLevel <= 2)) then {{_x ctrlEnable false}
    forEach[_button1, _button2]};
private _chargeSelected = {params[["_basic", []], ["_unitUID", ""]];
    _basic params[["_control", controlNull], ["_selectedIndex", -1]];
    if (_selectedIndex isEqualTo - 1) exitWith {};
    if (isNull _control) exitWith {};
    private _display = ctrlParent _control;
    if (isNull _display) exitWith {};
    private _wantedList = _display displayCtrl 2402;
    private _chargesList = _display displayCtrl 2405;
    private _removeInput = _display displayCtrl 2406;
    private _removeButton = _display displayCtrl 2407;
    private _button1 = _display displayCtrl 2408;
    private _players = allPlayers;
    private _unit = _players param[_players findIf {(getPlayerUID _x) isEqualTo _unitUID}, objNull];
    if (isNull _unit) exitWith {_wantedList lbDelete(lbCurSel _wantedList)};
    private _data = _wantedList lbData(lbCurSel _wantedList);
    private _data = parseSimpleArray _data;
    if ((_selectedIndex + 1) > (count(_data select 2))) exitWith {_removeInput ctrlSetText "1"; {if (ctrlShown _x) then {
                _x ctrlEnable false}}
        forEach[_removeInput, _removeButton];};
    private _crimeName = (_chargesList lbData _selectedIndex);
    private _amount = (_chargesList lbValue _selectedIndex);
    private _toggle = !((_unit getVariable["plb_arrested", false]) && ((call life_adminLevel) <= 2)); {if (ctrlShown _x) then {
            _x ctrlEnable _toggle}}
    forEach[_removeInput, _removeButton];
    if ((ctrlShown _removeInput) && !(_count isEqualTo _amount)) then {_removeInput ctrlSetText "1"};};
private _chargeDoubleClick = {params[["_control", controlNull], ["_selectedIndex", -1]];
    if (_selectedIndex isEqualTo - 1) exitWith {};
    if (isNull _control) exitWith {};
    private _display = ctrlParent _control;
    if (isNull _display) exitWith {};
    private _wantedList = _display displayCtrl 2402;
    private _chargesList = _display displayCtrl 2405;
    private _removeInput = _display displayCtrl 2406;
    if ((lbCurSel _wantedList) isEqualTo - 1) exitWith {};
    if ((ctrlShown _removeInput) && (ctrlEnabled _removeInput)) then {private _data = _wantedList lbData(lbCurSel _wantedList);
        if (_data isEqualTo "") exitWith {_removeInput ctrlSetText "1"};
        private _data = parseSimpleArray _data;
        private _crimeName = (_chargesList lbData _selectedIndex);
        private _amount = (_chargesList lbValue _selectedIndex);
        _removeInput ctrlSetText format["%1", _amount];};};
_chargesList ctrlSetEventHandler["LBSelChanged", format["[_this, '%2'] call %1", _chargeSelected, _unitUID]];
_chargesList ctrlSetEventHandler["LBDblClick", format["_this call %1", _chargeDoubleClick]];