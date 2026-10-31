params[["_oldHouse", objNull, [objNull]], ["_newHouse", objNull, [objNull]]];
if (isNull _oldHouse || isNull _newHouse) exitWith {};
private _gangID = life_gang_data param[0, -1];
if !(_gangID isEqualTo - 1) then {life_gangBuilding = [_newHouse, getPosATL _newHouse];
    life_gang_data set[3, getPosATL _newHouse];
    if (life_gang_data param[2, 0] isEqualTo 1) then {[[_oldHouse, _newHouse, _gangID], "TON_fnc_changeGangHouseSRV", 2] spawn life_fnc_MP;
        ["You have chosen this house as your new gang house.", "basic"] spawn life_fnc_handleMessage;} else {
        deleteMarkerLocal life_gangBldgMark;
        private _marker = createMarkerLocal[format["phouse_%1%2", _gangID, _newHouse getVariable["plb_homeOwner", ""]], getPosATL _newHouse];
        _marker setMarkerTextLocal "Gang Building";
        _marker setMarkerColorLocal "ColorGreen";
        _marker setMarkerTypeLocal "mil_end";
        life_gangBldgMark = _marker;
        ["Your gang leader has changed the gang house.", "basic"] spawn life_fnc_handleMessage;};};