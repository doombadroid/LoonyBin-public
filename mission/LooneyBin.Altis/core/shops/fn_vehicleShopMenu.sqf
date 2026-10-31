(_this select 3) params[["_shop", "", [""]], ["_sideCheck", sideUnknown, [civilian]], ["_spawnPoints", "", ["", [], objNull]], ["_shopFlag", "", [""]], ["_shopTitle", "", [""]], ["_disableBuy", false, [true]]];
if (dialog || _shop isEqualTo "" || _sideCheck isEqualTo sideUnknown || player getVariable["plb_restrained", false] || player getVariable["plb_surrendered", false]) exitWith {};
if !(_sideCheck isEqualTo playerSide) exitWith {["This shop is not allowed for your faction!", "basic"] spawn life_fnc_handleMessage;};
private _shop =
_shop;
disableSerialization;
if (_shop isEqualTo "nd_car") then {life_ndShop = true;};
["PLB_vehicleShop"] call life_fnc_createDialog;
if !(_shop in ["swat_car", "firefighter_car", "srt_car"]) then {life_garageCount = -1; [
        [getPlayerUID player, playerSide, player], "TON_fnc_garageCount", 2] spawn life_fnc_MP;} else {life_garageCount = 0;};
life_veh_shop = [_shop, _spawnPoints, _shopFlag, _disableBuy];
if (life_ndShop) then {ctrlSetText[100101, _shopTitle + (format[" - %1 ND", [life_ndStr] call PLB_fnc_ndText])];} else {
    ctrlSetText[100101, _shopTitle];};
if (_disableBuy) then {ctrlEnable[100107, false];};
private _vehicleList = ["shopVehicles", _shop] call life_fnc_vehicleConfig;
// owner 2026-06-24 DIAG (SWAT garage empty): client RPT is unreadable on Linux, so mirror what shopVehicles returned
// for the duty shops to the SERVER RPT (-VEHSHOP-). Shows live whether the list is genuinely empty or it's a render issue.
if (_shop in ["swat_car", "srt_car", "firefighter_car"]) then {
    [["-VEHSHOP-", player, profileName, format ["%1 -> %2 veh: %3 | copLvl %4 isSwat %5", _shop, count _vehicleList, _vehicleList apply { _x select 0 }, call life_copLevel, missionNamespace getVariable ["life_isSwat", false]]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
};
private _diagControl = ((findDisplay 100100) displayCtrl 100102);
private _diagVehInfo = ((findDisplay 100100) displayCtrl 100104);
private _index = -1;
private _index = _vehicleList findIf {(_x select 0) isEqualTo "I_Plane_Fighter_04_F"};
if (_shop isEqualTo "srt_car") then {private _index = _vehicleList findIf {(_x select 0) isEqualTo "B_G_Offroad_01_armed_F"};
    if ((_index isNotEqualTo - 1) && (playerSide isEqualTo west)) then {_vehicleList deleteAt _index};
    private _index = _vehicleList findIf {(_x select 0) isEqualTo "O_MRAP_02_F"};
    if ((_index isNotEqualTo - 1) && (playerSide isEqualTo west)) then {_vehicleList deleteAt _index};};
lbClear _diagControl;
_diagVehInfo ctrlSetStructuredText parseText "<t size='0.40'>&#160;</t><br/><t align='center'>Select a vehicle to purchase</t>";
private["_className", "_vehInfo"]; {_className = _x select 0;
    _vehInfo = [_className] call life_fnc_fetchVehInfo;
    if ((_x select 1) isEqualTo "") then {_diagControl lbAdd(_vehInfo select 3);} else {_diagControl lbAdd(_x select 1);};
    _diagControl lbSetPicture[(lbSize _diagControl) - 1, (_vehInfo select 2)];
    _diagControl lbSetData[(lbSize _diagControl) - 1, _className];
    _diagControl lbSetValue[(lbSize _diagControl) - 1, _forEachIndex];}
forEach _vehicleList;
waitUntil {isNull(findDisplay 100100)};
if (life_ndShop) then {life_ndShop = false;};