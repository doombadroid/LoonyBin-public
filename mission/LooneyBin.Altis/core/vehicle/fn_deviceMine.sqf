#include "..\..\macro.h"
if (scriptAvailable(5)) exitWith {["Wait a bit before attempting to start gathering again.", "basic"] spawn life_fnc_handleMessage;};
params[["_vehicle", objNull, [objNull]]];
if (isNull _vehicle) exitWith {};
if (_vehicle getVariable["plb_mentalTruck", false]) exitWith {
    ["This action is currently disabled for the loony bin truck.", "basic"] spawn life_fnc_handleMessage;};
if !(objNull isEqualTo(_vehicle getVariable["plb_mining", objNull])) exitWith {
    ["This vehicle is already mining", "basic"] spawn life_fnc_handleMessage;};
closeDialog 0;
life_action_in_use = true;
if (((_vehicle getVariable["plb_vinv", [[], 0]]) select 1) >= (_vehicle getVariable["plb_vcap", 100])) exitWith {
    ["The vehicle is full", "basic"] spawn life_fnc_handleMessage;
    life_action_in_use = false;};
private _zone = "";
private _resourceZones = ["apple_1", "apple_2", "apple_4", "apple_5", "peaches_2", "peaches_3", "peaches_4", "weed_1", "illegal_marker_1_0", "illegal_marker_2_0", "illegal_marker_3_0", "illegal_marker_8_0", "rock_1", "rock_2", "rock_3", "oil_1", "oil_2", "oil_3", "salt_1"];
private _dbInfo = _vehicle getVariable["plb_dbInfo", []];
private _zone = _resourceZones param[_resourceZones findIf {(player distance(getMarkerPos _x) < 290)}, ""];
if (_zone isEqualTo "") exitWith {["You are not near a resource field.", "basic"] spawn life_fnc_handleMessage;
    life_action_in_use = false;};
private _gatherArray =
switch (true) do {case (_zone isEqualTo "illegal_marker_1_0"): {["heroinu", 150];};
    case (_zone isEqualTo "illegal_marker_2_0"): {["cocaine", 150];};
    case (_zone isEqualTo "illegal_marker_3_0"): {["ephedrau", 150];};
    case (_zone isEqualTo "illegal_marker_8_0"): {["henbane", 150];};
    case (_zone isEqualTo "weed_1"): {["cannabis", 150];};
    case (_zone find "rock" != -1): {["phos", 150];};
    case (_zone find "oil" != -1): {["hydro", 150];};
    case (_zone find "salt" != -1): {["salt", 150];};
    case (_zone find "apple" != -1): {["apple", 50];};
    case (_zone find "peaches" != -1): {["peach", 50];};
    default {""};}; _gatherArray params["_item", "_distance"];
// owner 2026-06-16 (#264): the zone is matched within 290m (line ~23) but each resource has a tighter
// _distance (50/150m). Standing between _distance and 290m fell into this exit -- which DIDN'T reset
// life_action_in_use (still TRUE from line 14), unlike every other early-exit above. A stuck action-lock =
// "started gathering just outside the zone, now I can't interact with anything." Release the lock + tell them.
if (player distance(getMarkerPos _zone) > _distance) exitWith {life_action_in_use = false;
    ["You're too far from the resource field -- move closer to gather.", "basic"] spawn life_fnc_handleMessage;};
life_action_in_use = false;
if (isEngineOn _vehicle) exitWith {titleText["The vehicle must be turned off before mining.", "PLAIN"];};
if !(objNull isEqualTo(_vehicle getVariable["plb_mining", objNull])) exitWith {
    ["This vehicle is already mining", "basic"] spawn life_fnc_handleMessage;};
if (life_gatheringDevice) exitWith {["You can only operate one gathering device at a time.", "basic"] spawn life_fnc_handleMessage;};
life_gatheringDevice = true;
uiSleep(random 1);
_vehicle setVariable["plb_mining", player, true];
private _toSend = (allPlayers - [allDeadMen]) select {(_x distance player) <= 2000}; [
    [_vehicle], "life_fnc_soundDevice", _toSend, false, false] spawn life_fnc_MP;
private _time = 0;
private _maxWeight = _vehicle getVariable["plb_vcap", 100];
private _sum = 0;
private _index = 0;
private _itemWeight = 0;
private _totalGathered = 0;
private _timeDelay = 33.2;
private _amountPerCycle = 12;
for "_i"
from 0 to 1 step 0 do {if (!alive _vehicle || isNull _vehicle) exitWith {};
    if (player distance _vehicle > 10) exitWith {["You must stay near the vehicle.", "basic"] spawn life_fnc_handleMessage;};
    if (isEngineOn _vehicle) exitWith {titleText["You cannot turn the vehicle on when mining", "PLAIN"];};
    if !(player isEqualTo(_vehicle getVariable["plb_mining", objNull])) exitWith {
        ["You can only have one device running at a time", "basic"] spawn life_fnc_handleMessage;};
    titleText["The Device is gathering...", "PLAIN"];
    _time = time + _timeDelay;
    waitUntil {if (isEngineOn _vehicle) exitWith {titleText["You cannot turn the vehicle on when mining", "PLAIN"];
            true};
        if (player distance _vehicle > 10) exitWith {true};
        if (round(_time - time) < 1) exitWith {true};
        uiSleep 0.2;
        false};
    if (isEngineOn _vehicle) exitWith {titleText["You cannot turn the vehicle on when mining", "PLAIN"];};
    if (player distance _vehicle > 10) exitWith {["You must stay near the vehicle.", "basic"] spawn life_fnc_handleMessage;};
    private _vehInv = _vehicle getVariable["plb_vinv", [[], 0]];
    _vehInv params["_items", "_weight"];
    _sum = [_item, _amountPerCycle, _weight, _maxWeight] call life_fnc_calWeightDiff;
    if (_sum < 1) exitWith {titleText["The vehicle is full", "PLAIN"];};
    _itemWeight = ((["getItemWeight", _item] call life_fnc_virtItemCfg) * _sum);
    _index = _items findIf {(_x select 0) isEqualTo _item};
    if (_index isEqualTo - 1) then {_items pushBack[_item, _sum];} else {private _oldVal = (_items select _index) select 1;
        (_items select _index) set[1, _oldVal + _sum];};
    if (fuel _vehicle isEqualTo 0) exitWith {titleText["The vehicle is out of fuel.", "PLAIN"];};
    if (local _vehicle) then {_vehicle setFuel((fuel _vehicle) - 0.02);} else {[
            [_vehicle, (fuel _vehicle) - 0.02], "life_fnc_setFuel", _vehicle, false] spawn life_fnc_MP;};
    if (fuel _vehicle isEqualTo 0) exitWith {titleText["Vehicle is out of fuel", "PLAIN"];};
    if !(player isEqualTo(_vehicle getVariable["plb_mining", objNull])) exitWith {
        ["You can only have one device running at a time", "basic"] spawn life_fnc_handleMessage;};
    titleText[format["Completed cycle, the device has mined %1 %2", _sum, ["getName", _item] call life_fnc_virtItemCfg], "PLAIN"];
    [_item, _sum] call life_fnc_statArrUpdate;
    _totalGathered = _totalGathered + _sum;
    _vehicle setVariable["plb_vinv", [_items, _weight + _itemWeight], true];
    _sum = [_item, _amountPerCycle, _weight + _itemWeight, _maxWeight] call life_fnc_calWeightDiff;
    if (_sum < 1) exitWith {titleText["The vehicle is full", "PLAIN DOWN"];};
    uiSleep 2;}; life_gatheringDevice = false;
if ((_totalGathered isNotEqualTo 0) && (_dbInfo isNotEqualTo[])) then {_dbInfo params["_ownerPID", "_plate"];
    _keychainUIDs = (_vehicle getVariable["plb_vehOwners", []]); [
        ["-GATHERDEVICE-", player, profileName, format["gathered %1 %2 with a tempest device at position %3. Plate: %4. OwnerUID: %5. Keychain: %6", _totalGathered, ["getName", _item] call life_fnc_virtItemCfg, getPosATL player, _plate, _ownerPID, _keychainUIDs]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
};
if !(player isEqualTo(_vehicle getVariable["plb_mining", objNull])) exitWith {};
_vehicle setVariable["plb_mining", objNull, true];