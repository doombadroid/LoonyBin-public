params[["_vehicle", objnull, [objnull]]];
if (isNull _vehicle) exitWith {};
profileNameSpace setVariable["plb_dynamicMap_lastVehicleID", floor(random 9999)];
private _randomID = profileNameSpace getVariable["plb_dynamicMap_lastVehicleID", -1];
private _neededZones = ["zone18", "zone23"];
while {_vehicle isEqualTo life_dynamicMap_lastVehicle}
do {if (isNull _vehicle) exitWith {life_dynamicMap_lastVehicle = objNull};
    if !(alive _vehicle) exitWith {life_dynamicMap_lastVehicle = objNull};
    if !(_randomID isEqualTo(profileNameSpace getVariable["plb_dynamicMap_lastVehicleID", -1])) exitWith {};
    if (!(isNull driver _vehicle) && !(driver _vehicle isEqualTo player) && (alive(driver _vehicle))) exitWith {
        life_dynamicMap_lastVehicle = objNull};
    private _zone = dynamicMap_zoneLocations param[dynamicMap_zoneLocations findIf {
        (((getPosATL _vehicle) distance2D(_x select 0)) < _x select 1)}, []];
    if (_zone isEqualTo[]) exitWith {life_dynamicMap_lastVehicle = objNull};
    if !((_zone select 2) in _neededZones) exitWith {life_dynamicMap_lastVehicle = objNull};
    uiSleep 5;};