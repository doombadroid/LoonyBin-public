params[["_vehicle", objNull, [objNull]], ["_mods", [0, 0, 0, 0, 0, 0, 0, 0, 0], []
], ["_color", -1, [0]], ["_customPlate", "", [""]], ["_vehWear", [0, 1], []
], ["_isSwat", false, [false]], ["_isGang", false, [false]], ["_isFirefighter", false, [false]], ["_isSRT", false, [false]], ["_isMobileHQ", false, [false]]];
if (isNull _vehicle) exitWith {};
if !(_vehicle isKindOf "Air" || _vehicle isKindOf "Ship" || _vehicle isKindOf "LandVehicle") exitWith {};
_vehicle allowDamage true;
[_vehicle] call life_fnc_clearVehicleAmmo;
clearItemCargoGlobal _vehicle;
clearBackpackCargoGlobal _vehicle;
if (PLB_Server isEqualTo 1) then {[[_vehicle], "TON_fnc_igiInit", 2] spawn life_fnc_MP;};
if (count _mods < 9) then {private _toAdd = 9 - (count _mods);
    for "_i"
    from 1 to _toAdd do {_mods pushBack 0;};};
private _handling = _mods select 2;
if (_handling isEqualTo 1) then {_vehicle setMass((getMass _vehicle) / 1.35)};
if (_handling isEqualTo 2) then {_vehicle setMass((getMass _vehicle) / 1.53)};
if !(_customPlate isEqualTo "") then {_vehicle setPlateNumber _customPlate;};
private _virtualCap = (["getVirtCap", "", typeOf _vehicle] call life_fnc_vehicleConfig) + (_mods select 1);
_vehicle setVariable["plb_vcap", _virtualCap, true];
private _nitrous = _mods select 4;
if (_nitrous > 0) then {_vehicle setVariable["plb_nitro", _nitrous, true];};
// owner 2026-07-12: GPS autopilot module (garage mod slot 9, $300) -- gates the TAB-radial driving modes
// owner 2026-07-21: slot 9 == 2 is the ANALOG RETROFIT -- the computer is physically gone, so it grants NO
// autopilot and instead publishes the immunity flag every remote-vehicle hack checks (Killswitch, Remote
// Vehicle Stop, Valet Protocol). Published so the SERVER can honour it; nothing client-side decides it.
if ((_mods param [9, 0]) isEqualTo 1) then {_vehicle setVariable["plb_autopilot", true, true];};
if ((_mods param [9, 0]) isEqualTo 2) then {_vehicle setVariable["plb_analog", true, true];
    _vehicle setVariable["plb_autopilot", false, true];};
// owner 2026-07-21: DEADBOLT CHIP -- a physical lock, fitted at the moment you pull the vehicle. Stamped as a
// public var so the thief's client can see the refusal without needing the owner online. Swapping the chip
// later does not retro-fit cars already on the road, which is the point of it being hardware.
// owner 2026-07-21: three firewall chips stamp the car at pull time (same hardware-fitted-once model as Deadbolt --
// swapping the chip later does not retro-fit cars already on the road). Deadbolt blocks deck breach, Sealed Tank
// blocks Leech, Co-Pilot Guardian auto-fights a Chauffeur hijack.
private _fwNow = call PLB_fnc_fwEquipped;
if ("deadbolt" in _fwNow) then {_vehicle setVariable ["plb_deadbolt", true, true];};
if ("sealed" in _fwNow) then {_vehicle setVariable ["plb_sealedTank", true, true];};
if ("copilot" in _fwNow) then {_vehicle setVariable ["plb_coPilot", true, true];};
private _tracked = _mods select 5;
private _showDoors = (_mods select 8) isEqualTo 1;
private _side = [] call life_fnc_sideString;
_vehicle setVariable["plb_side", _side, true];
// owner 2026-06-21 (#346 "cars don't despawn"): tag freshly pulled/bought vehicles as "spawned" so fn_cleanup
// uses the shorter SPAWNED idle tier (40 min) instead of the STORED tier (60 min). This var was NEVER set
// anywhere, so EVERY vehicle fell to the 60-min branch and abandoned cars effectively never despawned in-session
// (only the restart restore reaped them). Restored vehicles don't run this fn -> they correctly stay on 60 min.
// Occupied vehicles (crew>0) + any get-in/out/trunk-open (re-stamps idleTime) are still protected, so an actively
// used or processing vehicle won't be reaped.
_vehicle setVariable["spawned", true, true];
_vehicle setVariable["plb_vinv", [[], 0], true];
_vehicle setVariable["plb_defaultMass", getMass _vehicle, true];
if ((_mods findIf {_x isNotEqualTo 0}) isNotEqualTo - 1) then {_vehicle setVariable["plb_mods", _mods, true]};
if (_isSwat) then {_vehicle setVariable["plb_isSwat", true, true];};
if (_isFirefighter) then {_vehicle setVariable["plb_isFirefighter", true, true];};
if (_isSRT) then {_vehicle setVariable["plb_isSRT", true, true];};
if (_isGang) then {private _vehicleOwnerArray = [
        [str(life_gang_data param[0, -1]), format["%1 Gang Vehicle", (life_gang_data param[1, ""])]]]; {
        _vehicleOwnerArray pushBack[(_x getVariable["plb_playerid", getPlayerUID _x]), (_x getVariable["plb_name", name _x])];}
    forEach([life_gang_data param[0, -1]] call life_fnc_getOnlineMembers);
    _vehicle setVariable["plb_vehOwners", _vehicleOwnerArray, true];} else {_vehicle setVariable["plb_vehOwners", [
        [getPlayerUID player, profileName]], true];};
private _plb_dmg = _vehicle;
_vehicle disableTIEquipment true;
_plb_dmg setDamage(_vehWear select 0);
_vehicle setFuel(selectMax[0.1, _vehWear select 1]); [[player, _vehicle, 1], "TON_fnc_keyManagement", 2] spawn life_fnc_MP;
if (_isMobileHQ) then {[_vehicle, 1800] call life_fnc_setVehicleIdle;} else {[_vehicle, 900] call life_fnc_setVehicleIdle;};
life_vehicles pushBack _vehicle;
// owner 2026-06-26: APD livery is the DEFAULT for these cop vehicles. The vehicle shop already pre-selects the
// APD skin (skin list cursel 0 -> the only/first cop skin for these classes), but a NO-skin spawn would otherwise
// show the base texture: an old garage row saved with color=-1 (bought before the skin existed), or an admin/Zeus
// pre-placed spawn. Fall back to the APD livery (skin id 40 = og) for a COP spawning one of these classes when no
// skin was explicitly chosen. An explicit pick (APD og=40 / APD Blue=41) sets _color != -1 and is never overridden.
if (_color isEqualTo - 1 && {_side isEqualTo "cop"} && {(typeOf _vehicle) in ["B_Heli_Light_01_F", "O_Heli_Light_02_unarmed_F", "O_MRAP_02_F"]}) then {
    _color = 40;};
if !(_color isEqualTo - 1) then {
    // Ifrit Cyber (skin 51): the body-kit mesh is a client-local createSimpleObject (simple objects do NOT network),
    // so we can't just build it here on the puller. Tag the vehicle with a JIP-public var instead -- it replicates
    // to every client and every late joiner, and the per-client loop in initPlayerLocal attaches + cleans up each
    // local copy. The cyber paint itself is broadcast globally via colorVehicle below.
    if (_color isEqualTo 51 && {(typeOf _vehicle) isEqualTo "O_MRAP_02_F"}) then {_vehicle setVariable ["plb_cyberSkin", true, true];}; [
        [_vehicle, _color], "life_fnc_colorVehicle", 0] call life_fnc_MP;};
if ((typeOf _vehicle) in ["B_Truck_01_fuel_F", "C_Truck_02_fuel_F", "C_Van_01_fuel_F"]) then {_vehicle setFuelCargo 0;};
// owner 2026-07-13: Grease Monkey (68) trunk-stocking REMOVED here -- it duplicated Motorist Road Warrior (200).
// Grease Monkey keeps its repair-kit-save perk (fn_repairTruck); Road Warrior owns trunk-stocking now.
// owner 2026-07-13 (MOTORIST tree): Road Warrior (200) stocks the trunk for the road; Pit Boss (204)
// tags the vehicle so fn_handleVehicleDamage softens collisions for the perk holder.
if (200 in life_side_talents) then {[_vehicle] spawn {params ["_vehicle"];
        sleep 1;
        _vehicle addItemCargoGlobal ["ToolKit", 1];
        _vehicle addItemCargoGlobal ["FirstAidKit", 3];};};
if (204 in life_side_talents) then { _vehicle setVariable ["plb_pitBoss", true, true]; };
if (_vehicle isKindOf "Air" && (21 in life_side_talents || playerSide in [west, independent])) then {private _num =
    if ("Heli_Light_01" in (typeOf _vehicle)) then {4} else {count(fullCrew[_vehicle, "", true])};
    if ((backpackCargo _vehicle) findIf {_x isEqualTo "B_AssaultPack_cbr"}
    isEqualTo - 1) then {_vehicle addBackpackCargoGlobal["B_AssaultPack_cbr", 1]};
    _vehicle addBackpackCargoGlobal["B_Parachute", _num];};
if (_vehicle isKindOf "O_MRAP_02_F" && 8 in life_infamy_talents && license_civ_rebel) then {
    _vehicle addMagazineTurret["SmokeLauncherMag", [-1]];};
_vehicle addEventHandler["HandleDamage", {_this call life_fnc_handleVehicleDamage;}];
_vehicle enableRopeAttach false;
[typeOf _vehicle, _vehicle, true, _color, _showDoors] spawn life_fnc_vehicleAnimate;
_vehicle allowDamage true;
_vehicle lock true;
// owner 2026-07-21: an Analog Retrofit has no onboard computer, so it carries no tracker either -- that is the
// other half of the tradeoff (nothing to hack, but nothing to find it with when it gets stolen).
if (((_vehicle isKindOf "Air" && 22 in life_side_talents) || 93 in life_side_talents || _tracked IsEqualTo 1) && {!(_vehicle getVariable ["plb_analog", false])}) then {
    life_tracked pushBackUnique _vehicle;
    _vehicle setVariable["plb_tracked", [[playerSide, getPlayerUID player]], true];};
if ((21 in life_side_talents || (playerSide in [west, independent])) && _vehicle isKindOf "Air") then {
    _vehicle addEventHandler["RopeBreak", {_this spawn life_fnc_slingParachute;}];};
