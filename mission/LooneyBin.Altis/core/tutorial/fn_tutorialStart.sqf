if !(params[["_tutorialID", -1, [0]]]) exitWith {};
private _selectedTutorial = (["getTutorialByID", _tutorialID] call life_fnc_tutorialCfg);
private _tutorialName = _selectedTutorial param[2, "Error: No tutorial found"];
private _action = [format["Do you want to activate tutorial: %1?", _tutorialName], "Tutorial System", "Confirm", "Cancel"] call BIS_fnc_guiMessage;
if !(_action) exitWith {};
closeDialog 0;
life_activeTutorial = _tutorialID;
[] spawn life_fnc_handleTutorial;