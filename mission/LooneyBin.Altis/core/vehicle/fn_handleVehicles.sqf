#include "..\..\macro.h"
params["_type", "_spawn", ["_isGangGarage", false, [false]]];
if (scriptAvailable(3)) exitWith {if (_isGangGarage) then {
        ["Please do not spam your gang's garage. It may take a bit to show vehicles if the server is under heavy load.", "basic"] spawn life_fnc_handleMessage;
    } else {
        ["Please do not spam your garage. It may take a bit to show your vehicles if the server is under heavy load.", "basic"] spawn life_fnc_handleMessage;
    };};
if (life_inEvent) exitWith {["You cannot use the garage during an admin event.", "basic"] spawn life_fnc_handleMessage;};
life_garageData = [];
if (_isGangGarage) then {[
        [(life_gang_data param[0, -1]), player, getPlayerUID player, _type], "TON_fnc_gangGarageGetVehicles", 2] spawn life_fnc_MP;
    ["gangGarage"] call life_fnc_createDialog;} else {[[player, _type], "TON_fnc_getVehicles", 2] spawn life_fnc_MP;
    ["PLB_vehicleGarage"] call life_fnc_createDialog;};
disableSerialization;
life_garage_sp = _spawn;
life_garage_type = _type;