params["_control", "_selectedIndex"];
disableSerialization;
private _getQuestProgress = {params["_questID", "_isLifetime"];
    private _return = "";
    switch (true) do {case (_isLifetime): {private _lifetimeChosen = life_LifetimeProgressQuests param[life_LifetimeProgressQuests findIf {
                    _questID isEqualTo(_x select 0)}, []];
                switch (true) do {case (_questID in life_completedLifetimeQuests): {_return = "Completed"};
                    case (_lifetimeChosen isEqualTo[]): {_return = "No Progress"};
                    default {_lifetimeChosen params["", "_amountDone"];
                        _return = format["%1 Completed", [_amountDone] call life_fnc_numberText];};};};
        case (!_isLifetime): {switch (true) do {case (_questID in life_completedQuests): {_return = "Completed"};
                    case !(_questID isEqualTo life_activeQuest): {_return = "Not Active"};
                    case (life_activeQuest isEqualTo 0): {_return = "Not Active"};
                    case (life_questProgress isEqualTo[]): {_return = "No Progress"};
                    default {_progressString = "Completed: "; {_x params["_xRequired", "_xCount"];
                            _xRequired =
                            if (playerSide isEqualTo west) then {""} else {format["%1: ", _xRequired]};
                            if (count life_questProgress isEqualTo 1) exitWith {
                                _progressString = _progressString + format["%1%2", _xRequired, [_xCount] call life_fnc_numberText];};
                            if (_forEachIndex isEqualTo(count life_questProgress - 1)) then {
                                _progressString = _progressString + format["and %1%2", _xRequired, [_xCount] call life_fnc_numberText];
                            } else {_progressString = _progressString + format["%1%2, ", _xRequired, [_xCount] call life_fnc_numberText];};
                        }
                        forEach life_questProgress;
                        _return = _progressString;};};};}; _return};
private _display = findDisplay 8100;
if (isNull _display) exitWith {};
private _list = _display displayCtrl 8101;
private _infoText = _display displayCtrl 8102;
private _questAmountDone = _display displayCtrl 8103;
private _acceptButton = _display displayCtrl 8104;
private _index = _list lbValue _selectedIndex;
private _selectedQuest = ["getQuestRowByID", _index] call life_fnc_questsCfg;
if (_selectedQuest isEqualTo[]) exitWith {};
_selectedQuest params["_id", "_faction", "_type", "_multiStage", "_qreserved", "", "", "", "_nameText", "_requirementText", "_awardText"];
private _lifetimeQuest =
if (_type == 2) then {true} else {false};
private _doneAmount = [_id, _lifetimeQuest] call _getQuestProgress;
_questAmountDone ctrlSetText _doneAmount;
_acceptButton ctrlEnable(life_activeQuest isEqualTo 0 && !_lifetimeQuest && !(_id in life_completedQuests));
switch (true) do {case (_lifetimeQuest && !(_id in life_completedLifetimeQuests)): {_acceptButton ctrlSetText "Already Active";
            _acceptButton ctrlEnable false;};
    case ((_id in life_completedLifetimeQuests) || (_id in life_completedQuests)): {_acceptButton ctrlSetText "Completed";
            _acceptButton ctrlEnable false;};
    case (life_activeQuest isEqualTo 0): {_acceptButton ctrlSetText "Accept Quest";
            _acceptButton ctrlEnable true;};
    case !(life_activeQuest isEqualTo 0): {
            private _questName = (["getQuestRowByID", life_activeQuest] call life_fnc_questsCfg) param[8, "Error: No quest found"];
            _acceptButton ctrlSetText "Cancel Active Quest";
            _acceptButton buttonSetAction format["[] spawn{
				private _action = [
					'Do you want to cancel your active quest: %1?',
					'Quest System',
					'Confirm',
					'Cancel'
				] call BIS_fnc_guiMessage;
				if !(_action) exitWith {};
				life_activeQuest = 0;
				life_questItems = [];
				life_questProgress = [];
				['You have canceled your active quest.', 'basic'] spawn life_fnc_handleMessage;
				[1] call life_fnc_questSync;
				closeDialog 0;
			};
			", [_questName] call BIS_fnc_filterString];
            _acceptButton ctrlEnable true;};
}; private _text = parseText format["<t size='0.25'>&#160;</t><br/><t align='center' size='0.65'>%1</t><br/><t size='0.50  '>&#160;</t><br/><t align='center' size='0.65'>Rewards</t><br/><t align='center' size='0.65'>%2</t>", _requirementText, _awardText];
_infoText ctrlSetStructuredText _text;