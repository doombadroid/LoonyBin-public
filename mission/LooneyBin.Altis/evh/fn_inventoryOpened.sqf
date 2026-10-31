#include "..\macro.h"
if (life_isActiveFirefighter) exitWith {["You can't open your inventory while actively being a firefighter"] spawn life_fnc_handleMessage;
    true;};
if (((call life_adminLevel) >= 3) && {life_adminMode}) exitWith {false;};
params[["_unit", objNull, [objNull]], ["_container", objNull, [objNull]]];
if (isNull _container) exitWith {false;};
if (_container isKindOf "Bag_Base" && cursorTarget getVariable["plb_surrendered", false]) exitWith {false;};
if (_container isKindOf "Bag_Base" && !(cursorTarget getVariable["plb_surrendered", false]) && playerSide != west) exitWith {
    ["No stealing allowed!", "basic"] spawn life_fnc_handleMessage;
    true;};
if (_container isKindOf "CAManBase") exitWith {true;};
if (_container getVariable["plb_seizing", false]) exitWith {["This vehicle is being seized."] spawn life_fnc_handleMessage;
    true};
if (scriptAvailable(2)) exitWith {["Wait a bit before attempting to open the inventory again."] spawn life_fnc_handleMessage;
    true};
if (life_action_in_use) exitWith {["You're currently doing a different action..", "basic"] spawn life_fnc_handleMessage;
    true};
if (life_inEvent) exitWith {true;};
private _nearestCrate = nearestObject[player, "B_CargoNet_01_ammo_F"];
if (!isNull _nearestCrate && {
    _nearestCrate getVariable["plb_rebelAirDrop", false] && (player distance _nearestCrate) < 6 && life_airDrop_last > serverTime - 600
}) exitWith {
    [format["The crate is still locked for another %1 minutes. Check back frequently!", ceil(((life_airDrop_last + 600) - serverTime) / 60)], "basic"] spawn life_fnc_handleMessage;
    true;};
private _nearestCrate = nearestObject[player, "Box_FIA_Ammo_F"];
if (!(isNull _nearestCrate) && (_nearestCrate getVariable["plb_ufoLoot", false]) && ((SRV_ufoCrash select 2) > serverTime - 600)) exitWith {
    [format["This radiated loot is unstable right now. Try in another %1 minutes. Check back frequently!", ceil((((SRV_ufoCrash select 2) + 600) - serverTime) / 60)], "basic"] spawn life_fnc_handleMessage;
    true;};
private _nearestCrate = nearestObject[player, "I_E_CargoNet_01_ammo_F"];
if (!isNull _nearestCrate && {
    _nearestCrate getVariable["plb_santaLoot", false] && (player distance _nearestCrate) < 6 && (SRV_winterEvent select 1) > serverTime - 600
}) exitWith {
    [format["The crate is still locked for another %1 minutes. Check back frequently!", ceil((((SRV_winterEvent select 1) + 600) - serverTime) / 60)], "basic"] spawn life_fnc_handleMessage;
    true;};
private _nearestCrate = nearestObject[player, "VirtualReammoBox_F"];
if (!(isNull _nearestCrate) && (SRV_loonyBinData param[4, false]) && (PLB_Server isEqualTo 1)) exitWith {
    ["This crate is locked until someone enters the right combination for the keypad!", "basic"] spawn life_fnc_handleMessage;
    true;};
private _isVehicle = (_container isKindOf "LandVehicle" || _container isKindOf "Ship" || _container isKindOf "Air");
if (_isVehicle && !(_container in life_vehicles) && !(playerSide isEqualTo west) && {(locked _container) isEqualTo 2
} && ((call life_adminLevel) <= 3)) exitWith {
    ["You cannot access the inventory of locked vehicles. Try using lockpicks or getting the keys.", "basic"] spawn life_fnc_handleMessage;
    life_action_in_use = false;
    true};
private _usedBy = _container getVariable["plb_veh_in_use", objNull];
private _inUse = _usedBy isNotEqualTo objNull;
if (_inUse && !(_usedBy isEqualTo player)) exitWith {
    ["This inventory is already being used by someone.", "basic"] spawn life_fnc_handleMessage;
    life_action_in_use = false;
    true};
_container setVariable["plb_veh_in_use", player, true];
_container spawn {params["_container"];
    private _time = time;
    waitUntil {!isNull(findDisplay 602) || time - _time > 3};
    if (time - _time < 3) then {[true] spawn life_fnc_inventory;
        waitUntil {private _gearInUse = _container getVariable["plb_veh_in_use", objNull];
            if (isNull _gearInUse) exitWith {true};
            if (serverRestartLock) exitWith {
                ["The server is saving this vehicle. Please wait until after restart to open the inventory.", "basic"] spawn life_fnc_handleMessage;
                true};
            if (_container getVariable["plb_trunkLock", false]) exitWith {
                ["The server is saving this vehicle. Please wait until after restart to open the inventory.", "basic"] spawn life_fnc_handleMessage;
                true};
            if (_gearInUse isNotEqualTo player) exitWith {
                ["Only one person can access the inventory at a time.", "basic"] spawn life_fnc_handleMessage;
                true};
            isNull(findDisplay 602) || isNull _container};};
    _container setVariable["plb_veh_in_use", nil, true];
    while {!isNull(findDisplay 602)}
    do {closeDialog 0;
        uiSleep 0.1;};};
[] spawn {uiSleep 1;
    (findDisplay 49) closeDisplay 2;};