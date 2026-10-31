params[["_vehicle", objNull, [objNull]], ["_sirenType", "", [""]], ["_sirenObject", objNull, [objNull]], ["_driver", objNull, [objNull]]];
if (isNull _vehicle || _sirenType isEqualTo "") exitWith {};
if (isNil {_vehicle getVariable "plb_siren"}) exitWith {};
private _length =
switch (_sirenType) do {case "SirenWail": {4.61}; case "SirenYelp": {6.35};
        case "SirenPhaser": {7.18};
        case "siren2": {13.775}}; while {!isNull _vehicle && !isNull(driver _vehicle) && alive _vehicle}
do {_sirenObject say3D[_sirenType, 650];
    uiSleep _length;}; if (_driver isEqualTo player) then {if !(isNull life_siren_obj) then {deleteVehicle life_siren_obj;
        if (_vehicle getVariable["plb_siren", false]) then {_vehicle setVariable["plb_siren", false, true];};};};