params["_control", "_selectedIndex"];
disableSerialization;
private _display = findDisplay 3200;
if (isNull _display) exitWith {};
private _list = _display displayCtrl 3201;
private _tutorialName = _display displayCtrl 3203;
private _acceptButton = _display displayCtrl 3204;
private _index = _list lbValue _selectedIndex;
private _selectedTutorial = ["getTutorialByID", _index] call life_fnc_tutorialCfg;
if (_selectedTutorial isEqualTo[]) exitWith {};
_selectedTutorial params["_id", "_legal", "_name", "_finishMessage", "_waypoints"];
_tutorialName ctrlSetText _name;
_acceptButton ctrlEnable(life_activeTutorial == -1);
switch (true) do {case (life_activeTutorial == -1): {_acceptButton ctrlSetText "Accept Tutorial";
            _acceptButton ctrlEnable true;};
    case (life_activeTutorial != -1): {
            private _tutorialName = (["getTutorialByID", life_activeTutorial] call life_fnc_tutorialCfg) param[2, "Error: No tutorial found"];
            _acceptButton ctrlSetText "Cancel active tutorial";
            _acceptButton buttonSetAction format["[] spawn{
				private _action = [
					'Do you want to cancel your active tutorial: %1?',
					'Tutorial System',
					'Confirm',
					'Cancel'
				] call BIS_fnc_guiMessage;
				if !(_action) exitWith {};
				life_activeTutorial = -1;
				['You have canceled your active tutorial.', 'basic'] spawn life_fnc_handleMessage;
				closeDialog 0;
			};
			", _tutorialName];
            _acceptButton ctrlEnable true;};};