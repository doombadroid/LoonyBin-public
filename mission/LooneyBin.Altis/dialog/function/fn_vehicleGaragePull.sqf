#include "..\..\macro.h"
if (scriptAvailable(5)) exitWith {["Wait a few seconds before pulling another vehicle.", "basic"] spawn life_fnc_handleMessage;};
disableSerialization;
if ((lbCurSel 100151) isEqualTo - 1) exitWith {
    ["You did not select a vehicle to retrieve from your garage!", "basic"] spawn life_fnc_handleMessage;
    closeDialog 0;};
private _vehicle = parseSimpleArray(lbData[100151, lbCurSel 100151]);
if (isNil "_vehicle") exitWith {
    ["There was an error selecting your vehicle from the garage. Please try again.", "basic"] spawn life_fnc_handleMessage;
    closeDialog 0;};
_vehicle params["_classname", "_plate", "_color", "", "_mods", "_vehWear", "_customPlate"];
if !(life_vehicles findIf {(_x getVariable["plb_dbInfo", []] param[1, -1]) isEqualTo _plate}
isEqualTo - 1) exitWith {["This vehicle is already in use.", "basic"] spawn life_fnc_handleMessage};
if ((_classname isEqualTo "O_APC_Wheeled_02_rcws_v2_F") && (count(vehicles select {typeOf _x isEqualTo "O_APC_Wheeled_02_rcws_v2_F"
}) isNotEqualTo 0)) exitWith {closeDialog 0;
    ["The maximum amount of Madrids have been pulled.", "basic"] spawn life_fnc_handleMessage;};
private _vehCfgRow = ["getVehicleRowParsed", "", _classname] call life_fnc_vehicleConfig;
if (_vehCfgRow isEqualTo[]) exitWith {};
private _textureShopFlags = (["specific", _classname, _color] call life_fnc_vehicleTextures) param[2, [""]];
// owner 2026-06-13 (#162): the undercover gate only passed if the vehicle's TEXTURE carried a cop/fed flag.
// A legit cop vehicle with no cop SKIN (e.g. the Strider before its skin was added) failed this and couldn't
// be pulled ("undercover role only"). Also allow when the vehicle is a cop vehicle by CONFIG CATEGORY.
private _copCats = ["cop_car", "cop_air", "cop_ship", "swat_car", "srt_car"];
private _isCopVeh = ((_vehCfgRow param[3, []]) findIf { _x in _copCats }) > -1;
if (playerSide isEqualTo west && {
    life_copRole != "detective" && life_copRole != "all" && (!("cop" in _textureShopFlags) && !("fed" in _textureShopFlags) && !_isCopVeh)
}) exitWith {["This vehicle can only be used when you are in the undercover role.", "basic"] spawn life_fnc_handleMessage};
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
if (playerSide isEqualTo independent && _classname isKindOf "Air" && 806 in life_completedLifetimeQuests) then {_pullFee = _pullFee * 0.50
};
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
closeDialog 0;
private _markerPos =
if (_spawnPoint isEqualType objNull) then {getPosATL _spawnPoint} else {getMarkerPos _spawnPoint};
if (_spawnPoint isKindOf "House_F") then {if (typeOf _spawnPoint == "Land_i_Shed_Ind_F") then {
        _markerPos = _spawnPoint modelToWorld[4, 4, -0.5];
        // owner 2026-07-10 SHED HELIPAD: an upgraded shed pulls AIR vehicles dead-centre on its pad deck,
        // ~1m clearance; the setDir(direction _spawnPoint) below already points the nose along the shed's
        // facing (owner spec: nose = shed front, never the sides). Offsets are the shed-model frame of the
        // owner's Eden comp (pad centre [3.35,3.44], deck top +4.79).
        if (_classname isKindOf "Air" && {_spawnPoint getVariable ["plb_helipad", false]}) then {
            _markerPos = _spawnPoint modelToWorld [3.351, 3.436, 5.8];};} else {
        _markerPos set[2, (getPosATL _spawnPoint select 2) + 0.155541];};} else {_markerPos set[2, (_markerPos select 2) + 1.5];};
private _vehicle = createVehicle[_classname, [random 999, random 999, 999], [], 0, "CAN_COLLIDE"];
// owner 2026-06-27: NG AMV-7 Marshall stays ammo-less + non-rearmable on garage pull too (see fn_vehicleShopBuy).
if (typeOf _vehicle isEqualTo "B_APC_Wheeled_01_cannon_F") then {
    { _vehicle removeMagazinesTurret [_x select 0, _x select 1] } forEach (magazinesAllTurrets _vehicle);
    _vehicle setVehicleAmmo 0;
    _vehicle addEventHandler ["Reloaded", { (_this select 0) setVehicleAmmo 0 }];};
waitUntil {!isNil "_vehicle" && {!isNull _vehicle}}; [[player, _plate, _vehicle], "TON_fnc_vehicleSetActive", 2] call life_fnc_MP;
_vehicle lock true;
_vehicle allowDamage false;
private _boatSpawns = [civ_air_hs_1, civ_air_hs_2, civ_air_carrier_1, civ_air_carrier_2, civ_air_carrier_3, "gangboatrebel_air_1", "gangboatrebel_car_1"];
if (_spawnPoint in _boatSpawns) then {if (_spawnPoint in ["gangboatrebel_air_1", "gangboatrebel_car_1"]) then {
        private _boatSpawnPos = getMarkerPos[_spawnPoint, true];
        _boatSpawnPos set[2, (_boatSpawnPos select 2) + 0.2];
        _vehicle setPosATL _boatSpawnPos;} else {_vehicle setPosATL _markerPos;};} else {
    // owner 2026-07-04 (#520): nudge personal-garage pulls off the cartel flag pole (mirrors fn_gangGaragePull;
    // open marker garages only -- house/shed OBJECT garages keep their precise offset).
    // owner 2026-07-04: the #520 findSafePos nudge was meant ONLY to lift a pulled car off the cartel flag pole,
    // but it gated on "string marker = any open garage" -> it fired at EVERY city/marker garage and findSafePos
    // relocated the spawn up to 10m off the marker = vehicle spawns shifted map-wide. Gate it to markers that
    // actually have a flag pole (FlagCarrier) within 5m (cartel garages); normal garages now spawn ON the marker.
    // Also still skip when a vehicle already sits on the marker (2nd+ pull) so it doesn't scatter into a tree.
    if (_spawnPoint isEqualType ""
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
    ["-VEHICLEPULL-", player, (profileName), format["pulled a %1 (%2), POS: %3 | Mods: %4", getText(configFile >> "CfgVehicles" >> _classname >> "displayName"), _plate, getPosATL player, _mods]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
if (_classname isKindOf "Air") then {["action", "garagepullaircraft", 1] call life_fnc_handleQuest;};

if (playerSide isEqualTo west ) then {

    private _textureName = ["specific", typeOf _vehicle, _color] call life_fnc_vehicleTextures;
    private _textureAddress = _textureName select 11;
    private _policeMarked = "apd" in str _textureAddress;
    private _hasPositions = "Hatchback" in (typeOf _vehicle); //([_vehicle] call life_fnc_copVehObjLoc) select 2;

    diag_log format["%1: %2 %3", _textureAddress, _policeMarked, _hasPositions];

    //only add to land vehicles that have positions for objects and for non UC cops
    if (_vehicle isKindOf "LandVehicle" && _hasPositions == true && _policeMarked == true) then {

        _createfnc = {

            params ["_vehicle"];

            uisleep 2;

            if !(isNull _vehicle) then {[_vehicle] remoteExec ["PLB_fnc_createP3DObjects", 2, false]};

            systemChat format "P3D Objects created for vehicle: %1", _vehicle;};

        [_vehicle] spawn _createfnc;};};

[_vehicle] call life_fnc_clearVehicleAmmo;
clearItemCargoGlobal _vehicle;
clearBackpackCargoGlobal _vehicle;
uiSleep 1;
[_vehicle, _mods, _color, _customPlate, _vehWear, false] spawn life_fnc_prepareVehicle;
_vehicle setVariable["plb_dbInfo", [getPlayerUID player, _plate], true];