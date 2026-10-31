addMissionEventHandler["Draw3D", {private _group = group player;
    private _leader = leader _group;
    private _sideUnits = allPlayers select {(side _x) isEqualTo playerSide};
    private _allSideMembers = _sideUnits select {
        (alive _x) && (_x in allPlayers) && !(_x isEqualTo player) && !(_x getVariable["plb_restrained", false])};
    private _allSideVehicles = (_allSideMembers apply {vehicle _x}) select {(alive _x) && !(_x isKindOf "CAManBase")};
    private _allSideVehicles = _allSideVehicles arrayIntersect _allSideVehicles;
    private _allSideMembers = _allSideMembers select {(vehicle _x) isEqualTo _x};
    private _getHexPicture = {params[["_unit", objNull, [objNull]]];
        if (_unit distance2D(getMarkerPos "respawn_west") <= 1000) exitWith {"\A3\ui_f\data\igui\cfg\cursors\select_ca.paa"};
        if (side _unit isEqualTo independent) exitWith {"icons\med_hex.paa"};};
    private _getDriverName = {params["_vehicle"];
        private _crew = crew _vehicle;
        private _driver = driver _vehicle;
        private _return =
        if (isNull _driver) then {name(_crew param[_crew findIf {alive _x}, objNull])} else {name _driver};
        _return}; {private _unit = _x;
        private _hexIcon =
        if (life_isCustomHexesEnabled) then {[_unit] call _getHexPicture} else {"\A3\ui_f\data\igui\cfg\cursors\select_ca.paa"};
        private _color =
        
            ((profileNamespace getVariable["plb_coloredHexesData", [[-1, ""], [1, 1, 1, 1]]]) param[1, [1, 1, 1, 1]]);
        if (((toLower _hexIcon) find "a3") isEqualTo - 1) then {
            _hexIcon = format["mpmissions\__cur_mp.%1\%2", toLower worldName, _hexIcon];};
        if !(_unit isEqualTo(vehicle player)) then {private _selection =
            if (_unit in _allSideVehicles) then {"zamerny"} else {"spine3"};
            private _position = _unit modelToWorldVisual(_unit selectionPosition[_selection, "Memory"]);
            private _text =
            if (life_targetTag) then {if (_unit in _allSideMembers) then {
                    format["%1 - %2m", name _unit, [round(_unit distance2D player)] call life_fnc_numberText];} else {
                    if (_unit in _allSideVehicles) then {
                        format["%1 (%3) - %2m ", [_unit] call _getDriverName, [round(_unit distance2D player)] call life_fnc_numberText, count((crew(vehicle _unit)) select {
                            alive _x})];} else {"";};};} else {"";
            }; if (_hexIcon isNotEqualTo "\A3\ui_f\data\igui\cfg\cursors\select_ca.paa") then {
                drawIcon3D[_hexIcon, _color, _position, 0.5, 0.5, 0, "", true];};
            drawIcon3D["\A3\ui_f\data\igui\cfg\cursors\select_ca.paa", _color, _position, 1, 1, 0, _text, 2];};}
    forEach(_allSideMembers + _allSideVehicles);}];