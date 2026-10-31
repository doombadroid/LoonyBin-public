/*
    life_fnc_renameHouseDone  (LooneyBin, owner 2026-07-10) -- server confirms a rename; refresh THIS
    client's local house marker text to the new name (or back to the type name when cleared) + toast.
    plb_houseName is already set GLOBAL by the server, so the spawn list + other clients' markers pick it
    up on their next open/relog. _this = [_house, _name]
*/
params [["_house", objNull, [objNull]], ["_name", "", [""]]];
if (isNull _house) exitWith {};
private _mk = format ["phouse_%1", _house getVariable ["plb_houseID", ""]];
private _label = if (_name isEqualTo "") then { getText (configFile >> "CfgVehicles" >> typeOf _house >> "displayName") } else { _name };
if !((markerType _mk) isEqualTo "") then { _mk setMarkerTextLocal _label; };
[if (_name isEqualTo "") then { "House name cleared." } else { format ["House renamed to ""%1"".", _name] }, "success"] spawn life_fnc_handleMessage;
