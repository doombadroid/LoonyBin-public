disableSerialization;
private _newLoad =
if (isNull(findDisplay 2700)) then {createDialog "Life_key_management";
    waitUntil {!isNull(findDisplay 2700)};
    [findDisplay 2700] spawn life_fnc_p_updateMenu;
    true} else {false};
private _display = findDisplay 2700;
private _vehicleTitle = _display displayCtrl 2701;
private _vehicleList = _display displayCtrl 2702;
private _playerList = _display displayCtrl 2703;
private _giveKeys = _display displayCtrl 2704; {_x ctrlEnable false}
forEach[_vehicleList, _playerList, _giveKeys];
lbClear _vehicleList;
lbClear _playerList; {_x params["_vehicle"];
    if (!isNull _vehicle && alive _vehicle) then {
        private _displayName = getText(configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName");
        private _picture =
        if !(_vehicle isKindOf "House_F") then {getText(configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "picture")};
        private _skinText = ["colorname", typeOf _vehicle, _vehicle getVariable["plb_vehicleColor", -1]] call life_fnc_vehicleTextures;
        private _skinText =
        if (_skinText isEqualTo "") then[{""}, {format["(%1)", _skinText]}];
        private _distance = [round(player distance _vehicle)] call life_fnc_numberText;
        private _index = _vehicleList lbAdd format["%3m - %1 %2 ", _displayName, _skinText, _distance];
        if !(_vehicle isKindOf "House_F") then {_vehicleList lbSetPicture[_index, _picture]};
        private _findVehicleTime = life_idleVehicleCache findIf {(_x select 0) isEqualTo _vehicle};
        if (_findVehicleTime != -1) then {private _vehicleTimeData = life_idleVehicleCache select _findVehicleTime;
            private _vehicleDespawnTime = round(900 - (serverTime - (_vehicleTimeData select 1)));
            if (_vehicleDespawnTime <= 0) then {_vehicleDespawnTime = 0;};
            _vehicleList lbSetTooltip[_index, format["Despawns in %1 second(s)", _vehicleDespawnTime]];};} else {
        life_vehicles = life_vehicles - [_x];};}
forEach life_vehicles;
private _myGroup = group player;
private _myGangId = life_gang_data param[0, -5];
private _myVehicle = vehicle player;
private _isOnFoot = isNull(objectParent player);
private _myPosition = getPosATL player;
private _allPlayers = allPlayers - [player];
private _players = _allPlayers select {private _gangId = (_x getVariable["gang_data", [-1]]) param[0, -1];
    private _sameGroup = (group _x) isEqualTo _myGroup;
    private _sameGang = _gangId isEqualTo _myGangId;
    private _sameVehicle = (vehicle _x) isEqualTo _myVehicle;
    private _isNearby = ((getPosATL _x) distance _myPosition) <= 12;
    _sameGroup || _sameGang || (_isOnFoot && _isNearby) || _sameVehicle};
_vehicleTitle ctrlSetStructuredText parseText "<t size='0.90' align='center'>Keychain Management</t>";
if ((lbSize _vehicleList) isEqualTo 0) exitWith {
    _vehicleTitle ctrlSetStructuredText parseText "<t size='0.90' align='center'>You own no vehicles</t>"};
if (_newLoad) then {_giveKeys ctrlAddEventHandler["ButtonClick", "_this spawn life_fnc_keyGive"];
    ((findDisplay 2700) displayCtrl 2705) ctrlAddEventHandler["ButtonClick", "_this spawn life_fnc_keyDrop"];   // LooneyBin: Drop Key
    // LooneyBin: Open All Doors on the selected vehicle (if it has door animation sources, e.g. Ifrit).
    ((findDisplay 2700) displayCtrl 2706) ctrlAddEventHandler ["ButtonClick", {private _sel = lbCurSel 2702;
        if (_sel < 0) exitWith { ["Select one of your vehicles first.", "basic"] spawn life_fnc_handleMessage; };
        private _veh = objectFromNetId (lbData [2702, _sel]);
        if (isNull _veh || {!alive _veh}) exitWith { ["That vehicle isn't spawned right now.", "basic"] spawn life_fnc_handleMessage; };
        private _doors = (("isClass _x" configClasses (configFile >> "CfgVehicles" >> (typeOf _veh) >> "AnimationSources")) apply { configName _x }) select { private _n = toLower _x; (_n find "door" >= 0) || {_n find "ramp" >= 0} };
        if (_doors isEqualTo []) exitWith { ["This vehicle has no openable doors.", "basic"] spawn life_fnc_handleMessage; };
        [[_veh], "life_fnc_openVehDoors", _veh] spawn life_fnc_MP;
        ["Toggled the vehicle's doors.", "basic"] spawn life_fnc_handleMessage;}];
    _vehicleList ctrlAddEventHandler["LBSelChanged", "ctrlEnable [2704, ((lbCurSel 2703) >= 0)]"];
    _playerList ctrlAddEventHandler["LBSelChanged", "ctrlSetFocus ((findDisplay 2700) displayCtrl 2702); ctrlEnable [2704, ((lbCurSel 2702) >= 0)]"];
}; {if (!isNull _x && alive _x) then {private _index = _playerList lbAdd format["%1", [name _x] call life_fnc_cleanName];
        _playerList lbSetTextRight[_index, format["[%1]", side _x]];
        _playerList lbSetData[_index, getPlayerUID _x];};}
forEach _players; {_x ctrlEnable true}
forEach[_vehicleList, _playerList];
if ((lbSize _playerList) >= 1) then {_playerList lbSetCurSel 0} else {_playerList ctrlEnable false};
private _vehicleIndex = life_vehicles findIf {_x isEqualTo(vehicle player)};
if (_vehicleIndex >= 0) then {_vehicleList lbSetCurSel _vehicleIndex};