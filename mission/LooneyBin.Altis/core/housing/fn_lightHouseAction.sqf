params[["_house", objNull, [objNull]], ["_rgb", [], [[]]]];
if (isNull _house) exitWith {};
if !(_house isKindOf "House_F") exitWith {};
private _enable = isNull(_house getVariable["plb_lightSource", objNull]); [
    [_house, _enable, _rgb], "life_fnc_lightHouse", -2] spawn life_fnc_MP;