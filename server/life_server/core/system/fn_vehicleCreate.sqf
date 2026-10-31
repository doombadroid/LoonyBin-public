/*
    (ASY|TON)_fnc_vehicleCreate  (LooneyBin: 2020 vehicle-buy adapter)
    2020 client args : [player, _vehicle, getPlayerUID player, _side("cop"/"civ"/"med"),
                        _skinID, _alarm, _isSwat, _isFirefighter, _isSRT]   (fn_vehicleShopBuy :265)
    Generates a plate, INSERTs the persistent row, and stamps the vehicle with ownership vars so
    it can be stored later: plb_dbInfo=[uid,plate] (2020 client reads this), dbInfo=[uid,plate,color,
    alarm] (2017 server readers: vehicleStore/vehicleDead/cleanup). Adds the Killed EH so a destroyed
    car deletes its row. SWAT/Firefighter/SRT vehicles are temporary — set up, not persisted.
    NOTE: rewritten from the 2017 signature ([uid,side,veh,color,player,plate,...]); no other callers.
*/
params [["_player",objNull,[objNull]], ["_vehicle",objNull,[objNull]], ["_uid","",[""]],
    ["_side","",[""]], ["_color",0,[0]], ["_alarm",0,[0]],
    ["_isSwat",false,[false]], ["_isFirefighter",false,[false]], ["_isSRT",false,[false]], ["_mods",[],[[]]]];
// owner 2026-06-23 SECURITY (security.md §2.3 — cross-account write + SQLi): the client _uid flows into
// DB_fnc_insertVehicle's INSERT (pid slot) RAW. Force the actor to the NON-SPOOFABLE caller's OWN account
// (fn_vehicleShopBuy always passes getPlayerUID player -- you buy a car for yourself) and escape it, so a
// scripter can't register a bought vehicle under someone ELSE's pid or inject SQL. Server-internal keeps _uid.
// (_className passed to insertVehicle is typeOf _vehicle = the real server-side class, so it's safe.)
private _src = remoteExecutedOwner;
if (_src != 0) then { _uid = getPlayerUID ((allPlayers select { owner _x isEqualTo _src }) param [0, objNull]); };
_uid = (format ["%1", _uid]) splitString "\'""" joinString "";
if (isNull _vehicle || _uid == "" || {!alive _vehicle}) exitWith {};

// Temporary on-duty vehicles are never persisted, but still clean up on death.
if (_isSwat || _isFirefighter || _isSRT) exitWith {_vehicle addEventHandler ["Killed", { _this spawn PLB_fnc_vehicleDead }];};

private _class = typeOf _vehicle;
private _type = switch (true) do {case (_class in ["C_Kart_01_Blu_F","C_Kart_01_Fuel_F","C_Kart_01_Red_F","C_Kart_01_Vrana_F"]): {"Kart"};
    case (_vehicle isKindOf "Car"): {"Car"};
    case (_vehicle isKindOf "Air"): {"Air"};
    case (_vehicle isKindOf "Ship"): {"Ship"};
    default {"Car"};};
private _sideStr = switch (toLower _side) do {case "west"; case "cop": {"cop"};
    case "independent"; case "med": {"med"};
    default {"civ"};};
private _alarmBool = (_alarm > 0);
// buy-time mods (client-supplied, ui branch): numeric-coerce EVERY slot (kills SQLi via str _mods),
// pad legacy callers to the 9-slot shape, keep slot 0 in sync with the alarm flag.
_mods = _mods apply { round parseNumber format ["%1", _x] };
if (count _mods < 9) then { _mods = [[0, 1] select _alarmBool, 0, 0, 0, 0, 0, 0, 0, 0]; };
while {count _mods < 10} do { _mods pushBack 0; };
_mods resize 10;   // slot 9 = autopilot module (was resize 9 -- silently amputated shop-bought autopilot)
if (_alarmBool || ((_mods param [0, 0]) > 0)) then { _mods set [0, 1]; _alarmBool = true; };
if (_color < 0) then { _color = 0; };               // -1 = no skin; insertVehicle rejects -1
private _plate = floor (random 999000) + 1000;      // 4-6 digit plate (per-pid identity/key)

// insertVehicle: [uid, side, type, classname, color, plate, fuel, damage, alarm, mods]
[_uid, _sideStr, _type, _class, _color, _plate, 1, 0, _alarmBool, _mods] call DB_fnc_insertVehicle;

_vehicle setVariable ["plb_dbInfo", [_uid, _plate], true];               // 2020 client (store lookup)
_vehicle setVariable ["dbInfo", [_uid, _plate, _color, _alarmBool], true]; // 2017 readers (idle cleanup garages via this)
_vehicle addEventHandler ["Killed", { _this spawn PLB_fnc_vehicleDead }];
