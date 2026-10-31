#include "..\..\macro.h"
/*
    life_fnc_vehicleGarageSell  (LooneyBin — Personal Vehicle Garage "Sell Vehicle")
    Wired to SellButton (idc 100154) by fn_vehicleGarageLBChange. Sells the SELECTED stored vehicle:
    server (TON_fnc_srvSellVehicle) deletes the DB row (pid+plate) and credits the bank sell-back.
    Price = vehicle-config sell value (row 8). lbData row = [classname, plate, color, ...].
*/
if (scriptAvailable(5)) exitWith {["Wait a few seconds before attempting to sell another vehicle.", "basic"] spawn life_fnc_handleMessage;
};
disableSerialization;
if ((lbCurSel 100151) isEqualTo - 1) exitWith {
    ["You did not select a vehicle to sell from your garage!", "basic"] spawn life_fnc_handleMessage;
    closeDialog 0;};
private _vehicle = lbData[100151, lbCurSel 100151];
_vehicle = parseSimpleArray _vehicle;
_vehicle params ["_classname", "_plate"];
// block selling a vehicle that is currently spawned/out
if !(life_vehicles findIf {(_x getVariable ["plb_dbInfo", []] param [1, -1]) isEqualTo _plate} isEqualTo - 1) exitWith {
    ["This vehicle is currently out — store it in the garage before selling.", "basic"] spawn life_fnc_handleMessage;};
private _vehCfgRow = ["getVehicleRowParsed", "", _classname] call life_fnc_vehicleConfig;
if (_vehCfgRow isEqualTo []) exitWith {["Unable to price that vehicle.", "basic"] spawn life_fnc_handleMessage;};
private _sellPrice = round(_vehCfgRow select 8);
if (_sellPrice <= 0) exitWith {["This vehicle has no sell-back value.", "basic"] spawn life_fnc_handleMessage;};
// owner 2026-07-24 BUGFIX (owner-reported): an ND vehicle is PAID in New Drachma by the server
// (TON_fnc_srvSellVehicle credits _price/6000 into the wallet) but every message here quoted the raw
// CASH row value -- a Nyx advertised "$80,000" and actually credited 13.3333 ND. Quote the currency the
// player will actually receive. ND-ness is the same test the server uses: "nd_car" (in an ND shop) or the
// "nd_priced" currency-only sentinel (pulled from the shop but still ND) in shop-key list idx 3.
private _shopKeys = _vehCfgRow param [3, []];
private _isND = (_shopKeys isEqualType []) && {("nd_car" in _shopKeys) || {"nd_priced" in _shopKeys}};
private _priceTxt = if (_isND) then {format ["%1 ND", [(_sellPrice / 6000) toFixed 4] call PLB_fnc_ndText]} else {
    format ["$%1", [_sellPrice] call life_fnc_numberText]};
private _action = [format["Are you sure you want to sell this vehicle for %1?", _priceTxt], "Sell Vehicle", "Yes", "No"] call BIS_fnc_guiMessage;
if !(_action) exitWith {};
private _playerUID = getPlayerUID player; [[_playerUID, _plate, _sellPrice], "TON_fnc_srvSellVehicle", 2] spawn life_fnc_MP; [
    ["-VEHICLESOLD-", player, (profileName), format["sold a %1 for %2.", getText(configFile >> "CfgVehicles" >> _classname >> "displayName"), _priceTxt]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
lbDelete[100151, lbCurSel 100151];
[format["You sold this vehicle for %1", _priceTxt], "basic"] spawn life_fnc_handleMessage;
closeDialog 0;
