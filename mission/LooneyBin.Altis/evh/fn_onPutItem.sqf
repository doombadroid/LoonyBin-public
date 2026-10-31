params[["_unit", objNull, [objNull]], ["_container", objNull, [objNull]], ["_item", "", [""]]];
if (life_laser_inprogress) exitWith {deleteVehicle _container};
if (isNull _unit || _item isEqualTo "") exitWith {};
if (life_eviSpawn || life_activeSWAT) exitWith {};
if (playerSide isEqualTo independent) exitWith {};
if (typeOf _container == "GroundWeaponHolder") then {[[_container, 450], "TON_fnc_setCleanTime", 2] spawn life_fnc_MP;}; [
    ["-STOREDITEM-", player, profileName, format["Stored %1 in %2 :: %3 - %4 - %5 - %6", _item, typeOf _container, getWeaponCargo _container, getItemCargo _container, getBackpackCargo _container, getMagazineCargo _container]], "TON_fnc_logIt", false] call life_fnc_MP;
[false] call life_fnc_saveGear;
[3] call life_fnc_ClupdatePartial;