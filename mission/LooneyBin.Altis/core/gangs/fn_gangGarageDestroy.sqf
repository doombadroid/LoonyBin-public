#include "..\..\macro.h"
if (scriptAvailable(5)) exitWith {["Wait a few seconds before trying to destroy another vehicle!", "basic"] spawn life_fnc_handleMessage;};
if ((lbCurSel 10301) isEqualTo - 1) exitWith {
    ["You did not select a vehicle to destroy from your gang garage!", "basic"] spawn life_fnc_handleMessage;};
params["_selectedVehicleData"];
_selectedVehicleData params["_classname", "_plate", "_color", "_insured", "_mods", "_vehWear", "_customPlate"];
_vehWear params["_currentVehDamage", "_currentVehFuelPercent", "_currentVehArmour"];
private _vehCfgRow = ["getVehicleRowParsed", "", _classname] call life_fnc_vehicleConfig;
private _destroyPrice = (_vehCfgRow select 8) * 0.12;
if (life_atmcash < _destroyPrice) exitWith {["You can't afford to destroy your vehicle!", "basic"] spawn life_fnc_handleMessage;};
if !(life_vehicles findIf {(_x getVariable["plb_dbInfo", []] param[1, -1]) isEqualTo _plate}
isEqualTo - 1) exitWith {["This vehicle is already in use.", "basic"] spawn life_fnc_handleMessage};
private _action = [format["Do you want to destroy this vehicle from %1's gang garage? It will cost you $%2", getText(configFile >> "CfgVehicles" >> _classname >> "displayName"), [_destroyPrice] call life_fnc_numberText], "Destroy Gang Vehicle", "Yes", "No"] call BIS_fnc_guiMessage;
if !(_action) exitWith {["You chose not to destroy your gang's vehicle!", "basic"] spawn life_fnc_handleMessage;};
life_atmcash = life_atmcash - _destroyPrice;
life_atmcashCacheB = ((life_atmcash / 4) + 11);
[1] call life_fnc_ClupdatePartial; [[_plate, str(life_gang_data param[0, -1]), true], "TON_fnc_vehicleDelete", 2] spawn life_fnc_MP;
lbDelete[10301, lbCurSel 10301];
[format["You have destroyed your gang %1!", getText(configFile >> "CfgVehicles" >> _classname >> "displayName")], "basic"] spawn life_fnc_handleMessage;
closeDialog 0;