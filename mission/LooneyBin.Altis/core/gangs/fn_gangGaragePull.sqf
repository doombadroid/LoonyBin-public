#include "..\..\macro.h"
if (scriptAvailable(5)) exitWith {["Wait a few seconds before pulling another vehicle.", "basic"] spawn life_fnc_handleMessage;};
disableSerialization;
// owner 2026-06-23: only gang ranks R1-R3 may pull gang vehicles -- R4 & R5 are blocked. Mirrors the greyed GET
// button (fn_gangGarageLBChange) + the <=3 add-gate in fn_gangGarageAdd. life_gang_data[2] = this player's gang
// rank (1 = leader/top .. 5 = recruit/lowest); default 5 = blocked if it's somehow missing.
if ((life_gang_data param [2, 5]) > 3) exitWith {["Only gang ranks R1-R3 can pull gang vehicles.", "basic"] spawn life_fnc_handleMessage;
    closeDialog 0;};
if ((lbCurSel 10301) isEqualTo - 1) exitWith {
    ["You did not select a vehicle to retrieve from your gang garage!", "basic"] spawn life_fnc_handleMessage;
    closeDialog 0;};
private _display = findDisplay 10300;
private _vehicleList = _display displayCtrl 10301;
private _vehicleTitle = _display displayCtrl 10302;
private _detailsText = _display displayCtrl 10303;
private _getButton = _display displayCtrl 10304;
private _repairButton = _display displayCtrl 10305;
private _displayTitle = _display displayCtrl 10306;
private _destroyButton = _display displayCtrl 10307;
private _vehicle = parseSimpleArray(lbData[10301, lbCurSel 10301]);
if (isNil "_vehicle") exitWith {
    ["There was an error selecting your vehicle from the garage. Please try again.", "basic"] spawn life_fnc_handleMessage;
    closeDialog 0;};
_vehicle params["_classname", "_plate", "_color", "", "_mods", "_vehWear", "_customPlate"];
["Attempting to pull vehicle from gang garage...", "basic"] spawn life_fnc_handleMessage;
_repairButton ctrlEnable false;
_getButton ctrlEnable false;
_destroyButton ctrlEnable false;
private _vehCfgRow = ["getVehicleRowParsed", "", _classname] call life_fnc_vehicleConfig;
if (_vehCfgRow isEqualTo[]) exitWith {};
private _textureShopFlags = (["specific", _classname, _color] call life_fnc_vehicleTextures) param[2, [""]];
if (playerSide isEqualTo west && {
    life_copRole != "detective" && life_copRole != "all" && (!("cop" in _textureShopFlags) && !("fed" in _textureShopFlags))}) exitWith {
    ["This vehicle can only be used when you are in the undercover role.", "basic"] spawn life_fnc_handleMessage};
private _spawnPoint = "";
if (life_garage_sp isEqualType[]) then {if (_classname isKindOf "Land") then {life_garage_sp = life_garage_sp select { "_g_" in (str _x) }
    };
    if (_classname isKindOf "Air") then {life_garage_sp = life_garage_sp select { "_air_" in (str _x) }};
    if (_classname isKindOf "Ship") then {life_garage_sp = life_garage_sp select { "_sea_" in (str _x) }};
    if ((life_garage_sp param[0, objNull]) isEqualType objNull) then {if !(surfaceIsWater position player) then {
            _spawnPoint = life_garage_sp param[life_garage_sp findIf {
                nearestObjects[getPosATL _x, ["Car", "Tank", "Ship"], 5] isEqualTo[] && nearestObjects[getPosATL _x, ["Air"], 14] isEqualTo[] && (player distance2D(getPosATL _x) <= 100)
            }, ""];} else {_spawnPoint = life_garage_sp param[life_garage_sp findIf {
                nearestObjects[getPosASL _x, ["Car", "Tank", "Ship"], 5] isEqualTo[] && nearestObjects[getPosASL _x, ["Air"], 14] isEqualTo[] && (player distance2D(getPosASL _x) <= 100)
            }, ""];};} else {_spawnPoint = life_garage_sp param[life_garage_sp findIf {
            nearestObjects[getMarkerPos _x, ["Car", "Tank", "Ship"], 5] isEqualTo[] && nearestObjects[getMarkerPos _x, ["Air"], 14] isEqualTo[] && (player distance2D(getMarkerPos _x) <= 100)
        }, ""];};} else {if (life_garage_sp isKindOf "House_F") then {
        if (nearestObjects[getPosATL life_garage_sp, ["Car", "Tank", "Air"], 9] isEqualTo[]) then {_spawnPoint = life_garage_sp};} else {
        if (nearestObjects[getPosATL life_garage_sp, ["Car", "Tank", "Ship"], 5] isEqualTo[] && nearestObjects[getPosATL life_garage_sp, ["Air"], 14] isEqualTo[] && (player distance2D(getPosATL life_garage_sp) <= 100)) then {
            _spawnPoint = life_garage_sp};};};
if (_spawnPoint isEqualTo "") exitWith {
    ["There is a vehicle currently blocking the spawn point(s).", "basic"] spawn life_fnc_handleMessage;
    closeDialog 0;};
private _pullFee = _vehCfgRow select 9;
private _exit = false;
private _isProperty = _spawnPoint isKindOf "House_F";
if (!_isProperty && !(_pullFee isEqualTo 0)) then {if !([_pullFee] call life_fnc_debitCard) exitWith {_exit = true;};};
if (_exit) exitWith {closeDialog 0;};
private _exit = false;
if (_spawnPoint isKindOf "House_F") then {
    if (typeOf _spawnPoint isEqualTo "Land_i_Shed_Ind_F" && _classname isEqualTo "B_Truck_01_box_F") exitWith {_exit = true};
    if (_classname in ["C_Van_01_box_F", "C_Van_01_fuel_F", "C_Van_01_transport_F", "B_Truck_01_box_F", "B_Truck_01_transport_F", "B_Truck_01_fuel_F", "I_Truck_02_covered_F", "I_Truck_02_transport_F", "O_Truck_03_device_F"] && !(typeOf _spawnPoint isEqualTo "Land_i_Shed_Ind_F")) exitWith {
        _exit = true};};
private _flickExit = false;
if (_spawnPoint isEqualType objNull && {playerSide isEqualTo civilian && !("VR_" in typeOf _spawnPoint)}) then {
    if (!(_spawnPoint in life_vehicles) && !(_spawnPoint in life_gangBuilding)) then {
        if !([cursorObject, getPlayerUID player, "accessLock"] call life_fnc_keyHolderStatus) then {_flickExit = true};};};
if (_flickExit) exitWith {closeDialog 0;
    ["You must be looking at your building to pull out a vehicle!", "basic"] spawn life_fnc_handleMessage;};
private _vehName = ([_classname] call life_fnc_fetchCfgDetails) select 1;
if (_exit) exitWith {[format["%1 is too large for this garage.", _vehName], "basic"] spawn life_fnc_handleMessage;};
uiSleep(random 2.1);
uiSleep(random 2.2);
uiSleep(random 2.5);
if !(life_vehicles findIf {(_x getVariable["plb_dbInfo", []] param[1, -1]) isEqualTo _plate}
isEqualTo - 1) exitWith {["This vehicle is already in use.", "basic"] spawn life_fnc_handleMessage};
closeDialog 0;
private _markerPos =
if (_spawnPoint isEqualType objNull) then {getPosATL _spawnPoint} else {getMarkerPos _spawnPoint};
if (_spawnPoint isKindOf "House_F") then {if (typeOf _spawnPoint isEqualTo "Land_i_Shed_Ind_F") then {
        _markerPos = _spawnPoint modelToWorld[4, 4, -0.5];} else {_markerPos set[2, (getPosATL _spawnPoint select 2) + 0.155541];};} else {
    _markerPos set[2, (_markerPos select 2) + 1.5];};
private _vehicle = createVehicle[_classname, [random 999, random 999, 999], [], 0, "CAN_COLLIDE"];
// owner 2026-06-27: NG AMV-7 Marshall stays ammo-less + non-rearmable on gang garage pull too.
if (typeOf _vehicle isEqualTo "B_APC_Wheeled_01_cannon_F") then {
    _vehicle animate ["HideTurret", 1];   // owner 2026-07-04: hide the 40mm turret entirely (like the Marid's cop_apc), not just ammo-strip
    { _vehicle removeMagazinesTurret [_x select 0, _x select 1] } forEach (magazinesAllTurrets _vehicle);
    _vehicle setVehicleAmmo 0;
    _vehicle addEventHandler ["Reloaded", { (_this select 0) setVehicleAmmo 0 }];};
waitUntil {!isNil "_vehicle" && {!isNull _vehicle}}; [
    [(life_gang_data param[0, -1]), player, getPlayerUID player, _plate, _vehicle], "TON_fnc_gangGarageSetActive", 2] spawn life_fnc_MP;
_vehicle lock true;
_vehicle allowDamage false;
private _boatSpawns = [civ_air_hs_1, civ_air_hs_2, civ_air_carrier_1, civ_air_carrier_2, civ_air_carrier_3, "gangboatrebel_air_1", "gangboatrebel_car_1"];
if (_spawnPoint in _boatSpawns) then {if (_spawnPoint in ["gangboatrebel_air_1", "gangboatrebel_car_1"]) then {
        private _boatSpawnPos = getMarkerPos[_spawnPoint, true];
        _boatSpawnPos set[2, (_boatSpawnPos select 2) + 0.2];
        _vehicle setPosATL _boatSpawnPos;} else {_vehicle setPosATL _markerPos;};} else {
    // owner 2026-06-15 (#237): same cartel-flag-pole spawn-kill guard as fn_spawnVehicle, but only for OPEN
    // MARKER garages (spawnPoint is a string). House garages use an object spawnPoint + boats are excluded,
    // so neither is nudged. Moves the car off the flag pole to clear flat ground.
    // owner 2026-07-03 (#520): DROPPED the old "House_F within 8m" skip -- the DRUG cartel sits next to a
    // CHURCH (House_F), so that clause skipped the nudge there and cars STILL spawned on the flag pole and
    // desync-killed players. Mirrors the #254 fix already shipped in fn_spawnVehicle: gate on garage TYPE
    // (string marker = open garage) instead of proximity to a building. Widened to 10m / <20m to match it.
    // owner 2026-07-04: gate the #520 findSafePos nudge to markers that actually have a flag pole (FlagCarrier)
    // within 5m (cartel garages) -- it was firing at every marker garage and shifting spawns up to 10m off the
    // marker map-wide. Normal garages now spawn ON the marker. Still skip when a vehicle already sits there (2nd+
    // pull) so findSafePos can't scatter the next car into a tree.
    if ((_spawnPoint isEqualType "")
        && {!(_spawnPoint in _boatSpawns)}
        && {(nearestObjects [_markerPos, ["FlagCarrier"], 5]) isNotEqualTo []}
        && {(nearestObjects [_markerPos, ["Car", "Air", "Ship"], 9]) isEqualTo []}) then {
        private _safe = [_markerPos, 0, 10, 3.2, 0, 0.4, 0] call BIS_fnc_findSafePos;
        if (_safe isEqualType [] && {count _safe >= 2} && {(_safe distance2D _markerPos) < 20}) then { _markerPos set [0, _safe select 0]; _markerPos set [1, _safe select 1]; };
    };
    _vehicle setPos _markerPos;};
if (_spawnPoint isEqualType objNull) then {
    _vehicle setDir([((direction _spawnPoint) - 90), direction _spawnPoint] select("VR" in typeOf _spawnPoint))} else {
    _vehicle setDir(markerDir _spawnPoint)};
private _rebelOutposts = ["Rebelop_1", "Rebelop_2", "Rebelop_3", "Rebelop_4", "Rebelop_5", "Rebelop_6"];
if !(({player distance(getMarkerPos _x) <= 200}
count _rebelOutposts) isEqualTo 0) then {["moneyspentrebel", _pullFee] call life_fnc_statArrUpdate;};
[format["Your %1 is ready on the spawn point!", getText(configFile >> "CfgVehicles" >> _classname >> "displayName")], "basic"] spawn life_fnc_handleMessage;
[
    ["-GANGVEHICLEPULL-", player, (profileName), format["pulled a %1 (%2), Gang ID: %4, POS: %3", getText(configFile >> "CfgVehicles" >> _classname >> "displayName"), _plate, getPosATL player, life_gang_data param[0, 0]]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
[_vehicle] call life_fnc_clearVehicleAmmo;
clearItemCargoGlobal _vehicle;
clearBackpackCargoGlobal _vehicle;
uiSleep 1;
_vehicle setVariable["plb_dbInfo", [str(life_gang_data param[0, -1]), _plate, true], true]; [
    [_vehicle, player], "life_fnc_addVehicle2Chain", ([life_gang_data param[0, -1]] call life_fnc_getOnlineMembers)] spawn life_fnc_MP;
[_vehicle, _mods, _color, _customPlate, _vehWear, false, true] spawn life_fnc_prepareVehicle;