#include "..\..\macro.h"
if (scriptAvailable(3)) exitWith {["Please don't spam vehicle purchases!", "basic"] spawn life_fnc_handleMessage;};
// owner 2026-06-24: DUTY shops (SWAT / Firefighter / SRT) don't count toward the garage cap, so fn_vehicleShopMenu
// deliberately SKIPS fetching life_garageCount for them -> it stays at the default -1. The "-1 / over-cap" guards below
// then wrongly blocked the buy ("Failed to fetch garage count") in the SWAT/Fire/SRT garage for any cop who hadn't
// opened a normal garage first this session. Skip both count guards for duty shops (SWAT pulls unlimited; Firefighter
// and SRT keep their OWN per-type caps in the duty block further down).
private _dutyShop = (life_veh_shop param [0, ""]) in ["swat_car", "firefighter_car", "srt_car"];
if (!_dutyShop && {life_garageCount isEqualTo - 1}) exitWith {
    ["Please try this vehicle purchase in a few seconds. Failed to fetch garage count from server.", "basic"] spawn life_fnc_handleMessage;
};
if (!_dutyShop && {life_garageCount >= (call life_maxGarageVeh)}) exitWith {
    [format["You have %1 out of %2 max vehicles allowed in your garage.", life_garageCount, (call life_maxGarageVeh)], "basic"] spawn life_fnc_handleMessage;
};
if ((lbCurSel 100102) isEqualTo - 1) exitWith {["You did not select a vehicle to purchase!", "basic"] spawn life_fnc_handleMessage;};
private _display = findDisplay 100100;
private _classname = lbData[100102, lbCurSel 100102];
private _vehCfgRow = ["getVehicleRowParsed", "", _classname] call life_fnc_vehicleConfig;
private _vehPrice = _vehCfgRow param[7, 1000];
private _price =
if (ctrlChecked(_display displayCtrl 100106)) then {_vehPrice + 500} else {_vehPrice};
private _alarm =
if (ctrlChecked(_display displayCtrl 100106)) then {1} else {0};
private _skinID =
if (lbSize 100105 isEqualTo 0) then {-1} else {lbValue[100105, lbCurSel 100105]};
private _selText = lbText[100105, lbCurSel 100105];
// NIGHT CITY buy-time mods: read the configure grid (duty vehicles are temporary -> no mods)
private _modCost = 0;
private _fnModRead = {params ["_idc"];
    private _c = _display displayCtrl _idc;
    if ((lbSize _c) isEqualTo 0 || {(lbCurSel _c) < 0}) exitWith { 0 };
    _modCost = _modCost + parseNumber (_c lbData (lbCurSel _c));
    _c lbValue (lbCurSel _c)};
private _mTrunk    = [100110] call _fnModRead;
private _mHandling = [100111] call _fnModRead;
private _mHorn     = [100112] call _fnModRead;
private _mNitro    = [100113] call _fnModRead;
private _mTracker  = [100114] call _fnModRead;
private _mLocks    = [100115] call _fnModRead;
private _mDoors    = [100116] call _fnModRead;
private _mAutopilot = [100118] call _fnModRead;
private _purchaseButton = _display displayCtrl 100107;
private _ndBuy = life_ndShop;
_price = _price + (_price * (call life_fnc_getGovTax));
private _ownAndInFortress = ([
    ["gang_fortress_marker"], 400, player] call life_fnc_inZone) && (((gang_fortress_flag getVariable["plb_gang_fortress_data", [-1, "Unknown", false]]) param[0, -1]) isEqualTo(life_gang_data param[0, -1]));
_price =
if (_ownAndInFortress) then {_price - (_price * 0.15)} else {_price};
_purchaseButton ctrlEnable false;
life_veh_shop params["_shopVar", "_spawnPoints", "_shopFlag", ""];
private _isSwat = _shopVar isEqualTo "swat_car";
if (_dutyShop) then { _modCost = 0; _mTrunk = 0; _mHandling = 0; _mHorn = 0; _mNitro = 0; _mTracker = 0; _mLocks = 0; _mDoors = 0; _mAutopilot = 0; };
private _isFirefighter = _shopVar isEqualTo "firefighter_car";
private _isSRT = _shopVar isEqualTo "srt_car";
private _vehCount = count(vehicles select {
    (_x getVariable["plb_isSwat", false]) || (_x getVariable["plb_isFirefighter", false]) || (_x getVariable["plb_isSRT", false])});
private _maxVehicles = 3;
// owner 2026-06-20 (Payton): SWAT vehicle pulls are UNLIMITED (was capped at 3). Firefighter + SRT keep the cap.
if (_vehCount >= _maxVehicles && _isFirefighter) exitWith {closeDialog 0;
    ["The maximum amount of Firefighting vehicles have been pulled.", "basic"] spawn life_fnc_handleMessage;};
if (_vehCount >= _maxVehicles && _isSRT) exitWith {closeDialog 0;
    ["The maximum amount of SRT vehicles have been pulled.", "basic"] spawn life_fnc_handleMessage;};
if ((_classname isEqualTo "O_APC_Wheeled_02_rcws_v2_F") && (count(vehicles select {typeOf _x isEqualTo "O_APC_Wheeled_02_rcws_v2_F"
}) isNotEqualTo 0)) exitWith {closeDialog 0;
    ["The maximum amount of Madrids have been pulled.", "basic"] spawn life_fnc_handleMessage;};
private _spawnPoint = "";
if (_spawnPoints isEqualType[]) then {
    // owner 2026-07-10: pick the spawn points matching the vehicle's domain, but FALL BACK to the garage's
    // own pads if it has none of that type. A ground-type SWAT garage carries only "_g_" spawns, so pulling an
    // air vehicle (SWAT Orca) used to empty this list -> findIf on [] returned -1 -> _spawnPoint="" -> a bogus
    // "vehicle blocking the spawn point" with nothing there. The fallback lets a duty heli spawn on an open
    // ground pad instead; the 5m Car / 14m Air clearance checks below still guard against a genuinely occupied pad.
    if (_classname isKindOf "Land") then {private _f = _spawnPoints select { "_g_" in (str _x) };
        if (_f isNotEqualTo []) then { _spawnPoints = _f };};
    if (_classname isKindOf "Air") then {private _f = _spawnPoints select { "_air_" in (str _x) };
        if (_f isNotEqualTo []) then { _spawnPoints = _f };};
    if (_classname isKindOf "Ship") then {private _f = _spawnPoints select { "_sea_" in (str _x) };
        if (_f isNotEqualTo []) then { _spawnPoints = _f };};
    if ((_spawnPoints param[0, objNull]) isEqualType objNull) then {if !(surfaceIsWater position player) then {
            _spawnPoint = _spawnPoints param[_spawnPoints findIf {
                nearestObjects[getPosATL _x, ["Car", "Tank", "Ship"], 5] isEqualTo[] && nearestObjects[getPosATL _x, ["Air"], 14] isEqualTo[] && (player distance2D(getPosATL _x) <= 100)
            }, ""];} else {_spawnPoint = _spawnPoints param[_spawnPoints findIf {
                nearestObjects[getPosASL _x, ["Car", "Tank", "Ship"], 5] isEqualTo[] && nearestObjects[getPosASL _x, ["Air"], 14] isEqualTo[] && (player distance2D(getPosASL _x) <= 100)
            }, ""];};} else {_spawnPoint = _spawnPoints param[_spawnPoints findIf {
            nearestObjects[getMarkerPos _x, ["Car", "Tank", "Ship"], 5] isEqualTo[] && nearestObjects[getMarkerPos _x, ["Air"], 14] isEqualTo[]
        }, ""];}} else {if (_spawnPoints isEqualType "") then {
        if (nearestObjects[getMarkerPos _spawnPoints, ["Car", "Tank", "Ship"], 5] isEqualTo[] && nearestObjects[getMarkerPos _spawnPoints, ["Air"], 14] isEqualTo[]) then {
            _spawnPoint = _spawnPoints};} else {
        if (nearestObjects[getPosATL _spawnPoints, ["Car", "Tank", "Ship"], 5] isEqualTo[] && nearestObjects[getPosATL _spawnPoints, ["Air"], 14] isEqualTo[]) then {
            _spawnPoint = _spawnPoints};};};
if (_spawnPoint isEqualTo "") exitWith {
    ["There is a vehicle currently blocking the spawn point(s).", "basic"] spawn life_fnc_handleMessage;};
private _success = false;
private _ndPricePaid = "0";
if (_ndBuy) then {
    // NEW DRACHMA: the vehicle's ND price is INDEPENDENT (fn_ndPriceCfg, keyed by classname). Discount
    // applies as a fraction; mods add at 6000:1 (they have no ND table entry). Server-authoritative debit
    // via PLB_fnc_ndBuySync (this fn is spawned -> waitUntil is legal).
    private _ndBase = [_classname] call life_fnc_ndPriceCfg;
    if (_ndBase isEqualTo "") then { _ndBase = [_price] call PLB_fnc_ndFromLegacy; diag_log format ["[LooneyBin][ND] vehicle missing price key %1 -- 6000:1 fallback", _classname]; };
    // apply the vehshop discount to the ND base, add the mods (converted), re-round to 4dp -> string
    private _ndNum = (parseNumber _ndBase) * (["vehshop", true] call life_fnc_getDiscount);
    _ndNum = _ndNum + (parseNumber ([_modCost] call PLB_fnc_ndFromLegacy));
    private _ndPrice = ((round (_ndNum * 10000)) / 10000) toFixed 4;
    _ndPricePaid = _ndPrice;
    if !([_ndPrice] call PLB_fnc_ndAfford) exitWith {
        [format["You cannot afford this. You need %1 ND", [_ndPrice] call PLB_fnc_ndText], "basic"] spawn life_fnc_handleMessage;};
    if !([_ndPrice] call PLB_fnc_ndBuySync) exitWith {["New Drachma payment failed -- try again.", "basic"] spawn life_fnc_handleMessage;};
    _success = true;} else {
    if (_classname isEqualTo "C_Hatchback_01_sport_F" && playerSide isEqualTo west && 656 in life_completedLifetimeQuests) then {
        _price = _price * 0.95;};
    if (_classname isKindOf "Air" && playerSide in [west, independent] && ((657 in life_completedLifetimeQuests) || (809 in life_completedLifetimeQuests))) then {
        _price = _price * 0.98;};
    if (_classname isKindOf "Land" && playerSide isEqualTo independent && 808 in life_completedLifetimeQuests) then {
        _price = _price * 0.98;};
    if (_classname in ["B_MRAP_01_F", "I_MRAP_03_F", "O_MRAP_02_F", "O_APC_Wheeled_02_rcws_v2_F"] && playerSide isEqualTo west && 658 in life_completedLifetimeQuests) then {
        _price = _price * 0.98;};
    _price =
    if (_isSwat || _isFirefighter) then {0} else {_price * (["vehshop", true] call life_fnc_getDiscount);};
    _price = _price + _modCost;   // buy-time mods: flat, untaxed/undiscounted (garage parity)
    if !([_price] call life_fnc_debitCard) exitWith {};
    _success = true;
    if (_classname isKindOf "Land") then {["buy", "invehiclevalue", _price] call life_fnc_handleQuest;};
    if (_classname isKindOf "Air") then {["buy", "inaircraftvalue", _price] call life_fnc_handleQuest;};
    if (_classname isEqualTo "C_Hatchback_01_sport_F") then {["buy", "inhatchbackvalue", _price] call life_fnc_handleQuest;};
    if (_classname in ["B_MRAP_01_F", "I_MRAP_03_F", "O_MRAP_02_F", "O_APC_Wheeled_02_rcws_v2_F"]) then {
        ["buy", "inarmorvalue", _price] call life_fnc_handleQuest;};};
if !(_success) exitWith {};
if (playerSide isEqualTo independent) then {["buy", "vehicle", 1] spawn life_fnc_handleQuest;};
if !(_ndBuy) then {[6] call life_fnc_ClupdatePartial;};
private _markerPos =
if (_spawnPoint isEqualType objNull) then {getPosATL _spawnPoint} else {getMarkerPos _spawnPoint};
_markerPos set[2, (_markerPos select 2) + 1.5];
private _vehicle = createVehicle[_classname, [random 999, random 999, 999], [], 0, "CAN_COLLIDE"];
// owner 2026-06-27: NG AMV-7 Marshall is parade/blocking armor only -- keep the 40mm visible but issue it
// with NO ammo and block rearm (strip all turret mags, zero ammo, re-zero on any reload attempt).
if (typeOf _vehicle isEqualTo "B_APC_Wheeled_01_cannon_F") then {
    _vehicle animate ["HideTurret", 1];   // owner 2026-07-04: hide the 40mm turret entirely (like the Marid's cop_apc), not just ammo-strip
    { _vehicle removeMagazinesTurret [_x select 0, _x select 1] } forEach (magazinesAllTurrets _vehicle);
    _vehicle setVehicleAmmo 0;
    _vehicle addEventHandler ["Reloaded", { (_this select 0) setVehicleAmmo 0 }];};
waitUntil {!isNil "_vehicle" && {!isNull _vehicle}};
_vehicle lock true;
_vehicle allowDamage false;
if (_spawnPoint isEqualType objNull) then {
    _vehicle setDir([((direction _spawnPoint) - 90), direction _spawnPoint] select("VR" in typeOf _spawnPoint))} else {
    _vehicle setDir(markerDir _spawnPoint)};
if (_spawnPoint in [civ_air_carrier_1, civ_air_carrier_2, civ_air_carrier_3, "gangboatrebel_air_1", "gangboatrebel_car_1"]) then {
    if (_spawnPoint in ["gangboatrebel_air_1", "gangboatrebel_car_1"]) then {private _boatSpawnPos = getMarkerPos[_spawnPoint, true];
        _boatSpawnPos set[2, (_boatSpawnPos select 2) + 0.2];
        _vehicle setPosATL _boatSpawnPos;} else {_vehicle setPosATL _markerPos;
        _vehicle setVectorUp(surfaceNormal _markerPos);};} else {_vehicle setPos _markerPos;
    _vehicle setVectorUp(surfaceNormal _markerPos);};
private _tax =
if (!(_ndBuy) && !(_shopVar in ["reb_car", "nd_car"])) then {(_price * (call life_fnc_getGovTax))} else {0};
private _extra =
if (!(_ndBuy) && !(_shopVar in ["reb_car", "nd_car"])) then {format[", including a tax of $%1", [_tax] call life_fnc_numberText]} else {
    ""};
playSound "purchase";
if (_ndBuy) then {
    [format["You bought a %1 for %2 ND. Press U while looking at the vehicle to unlock it or relock it.", getText(configFile >> "CfgVehicles" >> _className >> "displayName"), [_ndPricePaid] call PLB_fnc_ndText], "basic"] spawn life_fnc_handleMessage;
} else {
    [format["You bought a %1 for $%2%3. Press U while looking at the vehicle to unlock it or relock it.", getText(configFile >> "CfgVehicles" >> _className >> "displayName"), [_price] call life_fnc_numberText, _extra], "basic"] spawn life_fnc_handleMessage;
    ["payGovernor", [_tax]] spawn life_fnc_govSystem;};
closeDialog 0;
private _rebelOutposts = ["Rebelop_1", "Rebelop_2", "Rebelop_3", "Rebelop_4", "Rebelop_5", "Rebelop_6"];
if !(({player distance(getMarkerPos _x) <= 200}
count _rebelOutposts) isEqualTo 0) then {["moneyspentrebel", _price] call life_fnc_statArrUpdate;};
["vehiclesbought", 1] call life_fnc_statArrUpdate;
[_vehicle] call life_fnc_clearVehicleAmmo;
clearItemCargoGlobal _vehicle;
clearBackpackCargoGlobal _vehicle;
uiSleep 1;
private _mods =
if (_alarm isEqualTo 1 || (playerSide isEqualTo west && 91 in life_side_talents)) then {
    [1, _mTrunk, _mHandling, _mHorn, _mNitro, _mTracker, 0, _mLocks, _mDoors, _mAutopilot]} else {
    [0, _mTrunk, _mHandling, _mHorn, _mNitro, _mTracker, 0, _mLocks, _mDoors, _mAutopilot]};
private _side = [] call life_fnc_sideString;
[_vehicle, _mods, _skinID, "", [0, 1], _isSwat, false, _isFirefighter, _isSRT] spawn life_fnc_prepareVehicle;   // owner 2026-06-13: new vehicles spawn FULL fuel (was 0.5 = the "all vehicles half fuel" bug)
[
    [player, _vehicle, getPlayerUID player, _side, _skinID, _alarm, _isSwat, _isFirefighter, _isSRT, _mods], "TON_fnc_vehicleCreate", 2] spawn life_fnc_MP;