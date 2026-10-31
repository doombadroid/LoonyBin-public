params[["_object", objNull, [objNull]]];
if (isNull _object) exitWith {};
if (_object in life_vehicles) then {life_vehicles = life_vehicles - [_object];};