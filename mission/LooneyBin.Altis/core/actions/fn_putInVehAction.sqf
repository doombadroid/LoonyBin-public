params[["_vehicle", objNull, [objNull]]];
if (isNull _vehicle || !(isNull objectParent player)) exitWith {};
if (_vehicle distance player > 15) exitWith {};
player moveInCargo _vehicle;