private _tutorialID = life_activeTutorial;
private _tutorialData = (["getTutorialByID", _tutorialID] call life_fnc_tutorialCfg);
_tutorialData params["", "_isLegal", "_name", "_finishMessage", "_tutorialAdditionalData"];
private _createWaypoint = {params["_playerObj", "_position", "_text"];
    if !(life_tutorialEventHandler isEqualTo - 1) then {removeMissionEventHandler["Draw3D", life_tutorialEventHandler];};
    if !(life_tutorialTask isEqualTo - 1) then {life_tutorialTask setTaskState "Succeeded";
        uiSleep(0.3);
        _playerObj removeSimpleTask life_tutorialTask;};
    private _color = [(profileNamespace getVariable['IGUI_TACTPING_RGB_R', 0.6]), (profileNamespace getVariable['IGUI_TACTPING_RGB_G', 0.6]), (profileNamespace getVariable['IGUI_TACTPING_RGB_B', 0.6]), 1];
    life_tutorialEventHandler = addMissionEventHandler["Draw3D", format["drawIcon3D ['a3\ui_f\data\map\mapcontrol\waypoint_ca.paa', %1, %2, 1.1, 1.1, 0, '', 1, 0.05, 'TahomaB', 'center', true];", _color, _position]];
    life_tutorialTask = _playerObj createSimpleTask["Tutorial Task"];
    life_tutorialTask setSimpleTaskDescription[_text, "Tutorial Task", "Tutorial Task"];
    life_tutorialTask setSimpleTaskDestination _position;
    life_tutorialTask setTaskState "Assigned";
    _playerObj setCurrentTask life_tutorialTask;}; {_x params["_id", "_locationsToFindClosest", "_wpRadius", "_message"];
    private _nearestPosition = [];
    if ((count _locationsToFindClosest) != 0) then {_nearestPosition = [_locationsToFindClosest, player] call BIS_fnc_nearestPosition;
        if ((typeName _nearestPosition) == "STRING") then {_nearestPosition = getMarkerPos _nearestPosition;};
        [player, _nearestPosition, _message] spawn _createWaypoint;
        [format["<t align='center' size='1.5' color='#ffc038'>Tutorial System</t><br/><br/>%1", _message], "tutorial"] spawn life_fnc_handleMessage;
        waitUntil {uiSleep 1;
            life_activeTutorial != _tutorialID || ((_nearestPosition distance2D player) < _wpRadius)};} else {if (((life_vehicles select {
            alive _x && _x isKindOf "Car" && ((_x distance2D player) < 150)}) isEqualTo[])) then {
            [format["<t align='center' size='1.5' color='#ffc038'>Tutorial System</t><br/><br/>Buy or pull a car from your garage for this tutorial! We have marked one for you but it doesn't need to be this one in particular any garage works!"], "tutorial"] spawn life_fnc_handleMessage;
            _nearestPosition = [["car1_1_2", "car1_2_1_1", "car1_1", "car1_2", "car1_2_1_1_1"], player] call BIS_fnc_nearestPosition;
            _nearestPosition = getMarkerPos _nearestPosition;
            [player, _nearestPosition, "Buy or pull a car from a garage for this tutorial!"] spawn _createWaypoint;};
        waitUntil {uiSleep 1;
            life_activeTutorial != _tutorialID || !((life_vehicles select {alive _x && _x isKindOf "Car" && ((_x distance2D player) < 150)
            }) isEqualTo[])};
        if (life_activeTutorial != _tutorialID) exitWith {};
        private _ownedVehicles = life_vehicles select {alive _x && _x isKindOf "Car" && ((_x distance2D player) < 150)};
        _nearestCar = [_ownedVehicles, player] call BIS_fnc_nearestPosition;
        _nearestPosition = getPos(_nearestCar param[0]);
        [format["<t align='center' size='1.5' color='#ffc038'>Tutorial System</t><br/><br/>%1", _message], "tutorial"] spawn life_fnc_handleMessage;
        [player, _nearestPosition, _message] spawn _createWaypoint;
        waitUntil {uiSleep 1;
            life_activeTutorial != _tutorialID || ((_nearestPosition distance2D player) < 10) && ((vehicle player) in _ownedVehicles)};};
    if (life_activeTutorial != _tutorialID) exitWith {};}
foreach _tutorialAdditionalData;
if !(life_tutorialEventHandler isEqualTo - 1) then {removeMissionEventHandler["Draw3D", life_tutorialEventHandler];};
if !(life_tutorialTask isEqualTo - 1) then {life_tutorialTask setTaskState "Succeeded";
    uiSleep(0.3);
    player removeSimpleTask life_tutorialTask;};
if (life_activeTutorial != _tutorialID) then {
    [format["<t align='center' size='1.5' color='#ffc038'>Tutorial System</t><br/><br/>You cancelled the tutorial '%1', you can now continue on with your day or start a new tutorial from the menu.", _name], "tutorial"] spawn life_fnc_handleMessage;
} else {if (_finishMessage != "") then {
        [format["<t align='center' size='1.5' color='#ffc038'>Tutorial System</t><br/><br/>Congratulations on finishing the tutorial '%1' <br/><br/>%2", _name, _finishMessage], "tutorial"] spawn life_fnc_handleMessage;
    } else {
        [format["<t align='center' size='1.5' color='#ffc038'>Tutorial System</t><br/><br/>Congratulations on finishing the tutorial '%1'", _name], "tutorial"] spawn life_fnc_handleMessage;
    };};
life_activeTutorial = -1;