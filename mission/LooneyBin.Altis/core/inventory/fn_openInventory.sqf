#include "..\..\macro.h"
if (scriptAvailable(2)) exitWith {["Wait a bit before attempting to open the inventory again."] spawn life_fnc_handleMessage};
if !(isNull(findDisplay 4500)) exitWith {};
if !(isNull(findDisplay 3000)) exitWith {};
disableSerialization;
params[["_vehicle", objNull, [objNull]], ["_isadmin", false, [false]]];
if (isNull _vehicle || !(_vehicle isKindOf "Car" || _vehicle isKindOf "Air" || _vehicle isKindOf "Ship" || _vehicle isKindOf "Tank" || (typeOf _vehicle) in life_houseTypes || _vehicle getVariable["plb_supplyPlane", false] || typeOf _vehicle in ["Land_TentA_F", "Land_TentDome_F", "C_IDAP_CargoNet_01_supplies_F", "B_CargoNet_01_ammo_F", "Box_FIA_Ammo_F", "VirtualReammoBox_F", "VirtualReammoBox_small_F", "I_E_CargoNet_01_ammo_F", "I_E_CargoNet_01_ammo_F"])) exitWith {};   // owner 2026-07-23: + Tank (blood-shop Nyx trunk)
// LooneyBin (owner 2026-06-16): defense-in-depth STORAGE ACCESS GUARD for houses/sheds. Blocks opening a
// house/shed you have no rights to -- the tent+cursorObject exploit AND any other malformed caller -- while
// FULLY PRESERVING shared access by mirroring the game's own model. ALLOWS: admin, the OWNER (plb_homeOwner),
// KEYHOLDERS / shared keys (life_fnc_keyHolderStatus "accessInv" = rank 1 or 2), and GANGMATES of a gang
// house/shed (plb_house_gang == your gang id, life_gang_data select 0). Unowned map/industrial sheds carry
// none of these (homeOwner ""/NoPidVar, house_gang -1, no keys) -> blocked. Scoped to House_F only so
// vehicles/tents/crates are untouched.
// LooneyBin (owner 2026-07-04): DISTANCE guard for house/shed storage. cursorObject can resolve a House_F
// from far when aiming with binoculars, so a scroll/keybind path could open your storage from across the map.
// The house menu's own <10m gate doesn't cover every entry point -- guard the chokepoint here. Size-aware so
// the far door of a big shed/house still counts (sizeOf), but 30m+ binocular range is blocked. Admins exempt.
if (((_vehicle isKindOf "House_F") || {(typeOf _vehicle) in life_houseTypes}) && !_isadmin && {!((call life_adminLevel) >= 2)} && {(player distance _vehicle) > ((if (214 in life_side_talents) then {25} else {10}) + (0.5 * sizeOf (typeOf _vehicle)))}) exitWith {   // HOMESTEADER Open House: 25m reach
    ["You are too far from the house to access its storage.", "basic"] spawn life_fnc_handleMessage;
    closeDialog 0;};
if (((_vehicle isKindOf "House_F") || {(typeOf _vehicle) in life_houseTypes}) && !_isadmin && {!((call life_adminLevel) >= 2)}) then {
    private _uid = getPlayerUID player;
    private _owner = _vehicle getVariable ["plb_homeOwner", ""];
    private _hGang = _vehicle getVariable ["plb_house_gang", -1];
    private _myGang = life_gang_data param [0, -1];
    private _isOwner = (_owner isEqualType "") && {_owner != ""} && {_owner != "NoPidVar"} && {_uid isEqualTo _owner};
    private _isKey  = ([_vehicle, _uid, "accessInv"] call life_fnc_keyHolderStatus) isEqualTo true;
    private _isGang = (_hGang isEqualType 0) && {_hGang > 0} && {_myGang isEqualType 0} && {_hGang isEqualTo _myGang};
    if !(_isOwner || _isKey || _isGang) exitWith {["You do not have access to this storage.", "basic"] spawn life_fnc_handleMessage;
        closeDialog 0;};};
if (_vehicle isKindOf "House_F" && !(isNull objectParent player)) exitWith {
    ["You can not access your house inventory from within a vehicle...", "basic"] spawn life_fnc_handleMessage;
    closeDialog 0};
if (_vehicle getVariable["plb_seizing", false]) exitWith {["This vehicle is being seized.", "basic"] spawn life_fnc_handleMessage;
    closeDialog 0};
// owner 2026-06-27 (DATA LOSS -- Chris Blanco, 50 Indica Buds vanished): SERIALIZE-LOCK FIX. The house HYDRATE just
// below (TON_fnc_initHouseInventory, :50) BUMPS the server-side plb_invGen on every open. It ran BEFORE the
// plb_trunkLock open-guard (still at :~80 below), so a rapid re-open during a prior close's 1.25s settle was
// ultimately refused there -- but the gen had ALREADY been advanced by the hydrate. That made the settling close
// look STALE, so TON_fnc_updateHouseTrunk SKIPPED it (the #542 guard): the just-deposited items were never persisted
// AND the re-hydrate re-read the pre-deposit DB row = silent deposit loss. FIX: enforce the lock HERE, before the
// hydrate -- a locked re-open bails WITHOUT bumping the gen, so the settling close persists normally and the next
// open (after the ~2s settle, by which point updateHouseTrunk has already written) hydrates the fresh row.
if (_vehicle isKindOf "House_F" && {_vehicle getVariable ["plb_trunkLock", false]}) exitWith {
    ["This storage is being saved, try again in a moment.", "basic"] spawn life_fnc_handleMessage;
    life_action_in_use = false;};
// owner 2026-06-24 (LIVE house-storage OUTAGE -- houses opened EMPTY after the first access, and a close-while-empty
// WIPED the DB row): option-B storage is SERVER-LOCAL at rest and DEHYDRATED to [[],0] (broadcast) on every close, so
// after the first open+close the client's plb_vinv/pinv is [[],0] -- NOT nil. The old `isNil` hydrate trigger therefore
// NEVER re-fired: every subsequent open showed empty, and the close then saved that [[],0] back over real stored gear.
// FIX: ALWAYS re-hydrate on a house open. Clear our LOCAL copy to nil first so the wait can detect the server's fresh
// GATED-hydrate broadcast (vs. the stale [[],0]); if it never lands (denied / timeout) the vars stay nil and the guard
// at :120 exits BEFORE the dialog opens -> "Could not load... try again" instead of a false-empty house + wipe-on-close.
if (_vehicle isKindOf "House_F") then {
    _vehicle setVariable ["plb_vinv", nil];   // LOCAL clear -> waitUntil-non-nil detects the hydrate broadcast
    _vehicle setVariable ["plb_pinv", nil];
    private _exitTime = time + 5; [[_vehicle, _vehicle getVariable["plb_houseID", -1]], "TON_fnc_initHouseInventory", 2] call life_fnc_MP;
    waitUntil {uiSleep 0.1;
        time > _exitTime || (!isNil {_vehicle getVariable "plb_vinv"} && !isNil {_vehicle getVariable "plb_pinv"})};};
if (_vehicle isKindOf "House_F" && {(_vehicle getVariable["plb_house_tax", [false]]) select 0}) exitWith {
    ["houseTaxAccess"] call life_fnc_manageHouseTax;};
private _activeTrunk = _vehicle getVariable["plb_activeTrunk", objNull];
if ((_activeTrunk isNotEqualTo objNull) && (_activeTrunk isNotEqualTo player)) exitWith {
    ["This vehicle's trunk is in use, only one person can use it at a time.", "basic"] spawn life_fnc_handleMessage;
    life_action_in_use = false;};
// owner 2026-06-18 (CLANKR dupe): refuse to OPEN while the storage is locked for serialization. The store/impound/
// gang-store paths raise plb_trunkLock then settle ~1.25s before snapshotting plb_vinv; this blocks a re-open
// during that window so the player can't inject a fresh take mid-settle. (The in-trunk monitor below already
// force-CLOSES on this flag; this is the matching open-side guard.)
if (_vehicle getVariable["plb_trunkLock", false]) exitWith {
    ["This storage is being saved, try again in a moment.", "basic"] spawn life_fnc_handleMessage;
    life_action_in_use = false;};
private _exit = false;
if (!(_vehicle in life_vehicles) && _isadmin && ((call life_adminLevel) >= 3) && !(_vehicle getVariable["plb_owner", objNull] isEqualTo player)) then {
    private _action = [format["Are you sure you want to force yourself into the inventory? This feature is intended for compensation purposes. Misuse of this feature will result in administrative action."], "Confirmation", "Yes", "No"] call BIS_fnc_guiMessage;
    waitUntil {!isNil "_action"};
    if (_action) then {life_adminForce = true;} else {_exit = true;
        life_action_in_use = false;
        life_adminForce = false;
        _vehicle setVariable["plb_activeTrunk", nil, true];};};
if (_exit) exitWith {};
if (life_inEvent) exitWith {["You cannot access inventories during an admin event", "basic"] spawn life_fnc_handleMessage;};
life_didServerRespond = false;
private _maxDelayTime = time + 5; [[player], "TON_fnc_lagCheck", false, false] spawn life_fnc_MP;
waitUntil {time > _maxDelayTime || life_didServerRespond};
if (time > _maxDelayTime) exitWith {["Inventory opening failed... Try again.", "basic"] spawn life_fnc_handleMessage;
    life_adminForce = false;};
if (((_vehicle getVariable["plb_rebelAirDrop", false] || _vehicle getVariable["plb_supplyPlane", false] || _vehicle getVariable["plb_ufoLoot", false] || _vehicle getVariable["plb_santaLoot", false]) && ((player distance _vehicle) > 6))) exitWith {
    ["You're too far away!", "basic"] spawn life_fnc_handleMessage;};
if ((_vehicle getVariable["plb_rebelAirDrop", false]) && (life_airDrop_last > serverTime - 600)) exitWith {
    [format["The crate is still locked for another %1 minutes. Check back frequently!", ceil(((life_airDrop_last + 600) - serverTime) / 60)], "basic"] spawn life_fnc_handleMessage;
};
if ((_vehicle getVariable["plb_ufoLoot", false]) && ((SRV_ufoCrash select 2) > serverTime - 600)) exitWith {
    [format["This radiated loot is unstable right now. Try in another %1 minutes. Check back frequently!", ceil((((SRV_ufoCrash select 2) + 600) - serverTime) / 60)], "basic"] spawn life_fnc_handleMessage;
};
if ((_vehicle getVariable["plb_santaLoot", false]) && {(SRV_winterEvent select 1) > serverTime - 600}) exitWith {
    [format["The crate is still locked for another %1 minutes. Check back frequently!", ceil((((SRV_winterEvent select 1) + 600) - serverTime) / 60)], "basic"] spawn life_fnc_handleMessage;
};
if ((typeOf _vehicle isEqualTo "VirtualReammoBox_F") && (SRV_loonyBinData param[4, false])) exitWith {
    ["The Patient's Tomb is still locked! You must first unlock the door!", "basic"] spawn life_fnc_handleMessage;};
if (_vehicle isKindOf "House_F" && (isNil {_vehicle getVariable "plb_vinv"} || isNil {_vehicle getVariable "plb_pinv"})) exitWith {
    closeDialog 0;
    ["Could not load house inventory. Please try again.", "basic"] spawn life_fnc_handleMessage};
_vehicle setVariable["plb_activeTrunk", player, true];
life_trunk_vehicle = _vehicle;
while {dialog}
do {closeDialog 0};
["TrunkMenu"] call life_fnc_createDialog;
((findDisplay 4500) displayCtrl 4523) ctrlShow false;   // "Store All -> Vehicle": hidden by default, shown for houses (civ view) below
if !(_vehicle isKindOf "House_F") then {[_vehicle, 900] call life_fnc_setVehicleIdle;};
[_vehicle] spawn {private _vehicle = (_this select 0);
    while {!(isNull(findDisplay 4500))}
    do {uiSleep 0.25;
        if (isNull _vehicle) exitWith {while {dialog}
            do {closeDialog 0;};};
        if ((_vehicle getVariable["plb_activeTrunk", objNull] isNotEqualTo player) && (_vehicle getVariable["plb_activeTrunk", objNull] isNotEqualTo objNull)) exitWith {
            ["Someone else has somehow opened the trunk, only one player may use the trunk at a time.", "basic"] spawn life_fnc_handleMessage;
            while {dialog}
            do {closeDialog 0;}; life_adminForce = false;
            life_action_in_use = false;};
        if (_vehicle getVariable["plb_activeTrunk", objNull] isEqualTo objNull) exitWith {while {dialog}
            do {closeDialog 0;}; life_adminForce = false;
            life_action_in_use = false;};
        if (_vehicle getVariable["plb_trunkLock", false]) exitWith {while {dialog}
            do {closeDialog 0;}; _vehicle setVariable["plb_activeTrunk", nil, true];
            ["Inventory is being saved, you cannot access it.", "basic"] spawn life_fnc_handleMessage;
            life_adminForce = false;
            life_action_in_use = false;};
        if (player getVariable["plb_restrained", false]) exitWith {while {dialog}
            do {closeDialog 0;}; _vehicle setVariable["plb_activeTrunk", nil, true];
            life_adminForce = false;
            life_action_in_use = false;};
        if (player getVariable["plb_downed", false]) exitWith {while {dialog}
            do {closeDialog 0;}; _vehicle setVariable["plb_activeTrunk", nil, true];
            life_adminForce = false;
            life_action_in_use = false;};
        if !(isNull(findDisplay 49)) exitWith {closeDialog 0;
            life_adminForce = false;
            life_action_in_use = false;};};};
life_is_virtual = true;
((findDisplay 4500) displayCtrl 4518) ctrlSetText "Switch to Physical Inventory";
private _vehData = [0, 0];
private _get_inv = {private _array = [];
    private _val = 0; {_val = missionNamespace getVariable [format["life_inv_%1", _x], 0];
        if ((_val) > 0) then {_array pushBack[_x, _val];};}
    forEach([2] call life_fnc_virtItemCfg);
    _array;};
if (_vehicle isKindOf "House_F") then {[
        ["-HOUSEINV-", player, (profileName), format["opened house storage. (ID: %1 | Owner: %2 | Position: %7), House Virtual Inventory: %3, House Physical Inventory: %4, Player Virtual Inventory: %5, Player Physical Inventory: %6", _vehicle getVariable["plb_houseID", -1], _vehicle getVariable["plb_homeOwner", "NoPidVar"], _vehicle getVariable["plb_vinv", [
            [], 0]], _vehicle getVariable["plb_pinv", [
            [], 0]], [] call _get_inv, getUnitLoadout player, getPosATL _vehicle]], "TON_fnc_logIt", 2] spawn life_fnc_MP;} else {[
        ["-VEHINV-", player, (profileName), format["opened vehicle trunk. (Vehicle: %1 | Owner: %2 | Position: %5) Virtual Inventory: %3, Player Virtual Inventory: %4", typeOf _vehicle, _vehicle getVariable["plb_dbInfo", "NoVehData"], _vehicle getVariable["plb_vinv", [
            [], 0]], [] call _get_inv, getPosATL player]], "TON_fnc_logIt", 2] spawn life_fnc_MP;};
if (life_adminForce) then {[
        ["-ADMINACTION-", player, (profileName), format["force opened inventory of %1.", typeOf _vehicle]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
};
if (_vehicle isKindOf "House_F") then {if (playerSide isEqualTo west && !(life_adminForce)) then {
        ((findDisplay 4500) displayCtrl 4507) ctrlSetText "Seize";
        ((findDisplay 4500) displayCtrl 4507) ctrlEnable true;
        ((findDisplay 4500) displayCtrl 4508) ctrlEnable false;
        ((findDisplay 4500) displayCtrl 4505) ctrlEnable false;
        ((findDisplay 4500) displayCtrl 4506) ctrlEnable false;
        ((findDisplay 4500) displayCtrl 4519) ctrlEnable false;
        ((findDisplay 4500) displayCtrl 4520) ctrlEnable false;
        ((findDisplay 4500) displayCtrl 4521) ctrlEnable false;
        ((findDisplay 4500) displayCtrl 4522) ctrlEnable false;} else {((findDisplay 4500) displayCtrl 4507) ctrlSetText "Take";
        ((findDisplay 4500) displayCtrl 4507) ctrlEnable true;
        ((findDisplay 4500) displayCtrl 4508) ctrlEnable true;
        ((findDisplay 4500) displayCtrl 4519) ctrlEnable true;
        ((findDisplay 4500) displayCtrl 4520) ctrlEnable true;
        ((findDisplay 4500) displayCtrl 4521) ctrlEnable true;
        ((findDisplay 4500) displayCtrl 4522) ctrlEnable false;
        ((findDisplay 4500) displayCtrl 4523) ctrlShow true;    // owner/keyholder/gang house view -> allow bulk store-to-vehicle
        ((findDisplay 4500) displayCtrl 4523) ctrlEnable true;};
    ctrlSetText[4501, format[("House Storage") + " - %1", getText(configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName")]];
    if (life_is_virtual) then {_vehData = [(_vehicle getVariable["plb_vcap", 100]), (_vehicle getVariable["plb_vinv", [[], 0]]) select 1];
    } else {_vehData = [(_vehicle getVariable["plb_phys_cap", 100]), (_vehicle getVariable["plb_pinv", [[], 0]]) select 1];};
    ctrlSetText[4504, format["Weight: %1/%2", _vehdata select 1, _vehdata select 0]];} else {ctrlShow[4518, false];
    ctrlSetText[4501, format[("Vehicle Trunk") + " - %1", getText(configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName")]];
    private _weight = [_vehicle] call life_fnc_vehicleWeight;
    _vehData = [_weight select 1, _weight select 0];
    ctrlSetText[4504, format["Weight: %1/%2", _vehData select 0, _vehData select 1]];
    // owner 2026-07-06: REVERSE bulk-store -- for a vehicle YOU own/key, show "Store Item -> House" (deposits the
    // highlighted item into the nearest house you can access, within 25m). Dispatch handled in fn_houseToVehicleStore.
    if (((_vehicle getVariable ["plb_vehOwners", []]) findIf { (format ["%1", _x param [0, ""]]) isEqualTo (getPlayerUID player) }) > -1) then {
        ((findDisplay 4500) displayCtrl 4523) ctrlShow true;
        ((findDisplay 4500) displayCtrl 4523) ctrlEnable true;
        ((findDisplay 4500) displayCtrl 4523) ctrlSetText "Store Item -> House ";};};
if !(life_adminForce) then {[_vehicle, life_is_virtual] call life_fnc_refreshInventory;} else {
    [_vehicle, true] call life_fnc_refreshAdminInventory;};
if ((currentWeapon player == "Binocular" || currentWeapon player == "Rangefinder") && (vehicle player) isEqualTo player) then {
    player action["SwitchWeapon", player, player, 100];
    uiSleep 1;
    player switchCamera cameraView;
    player playActionNow "Gear";} else {player playActionNow "Gear";};
_vehicle spawn {params["_object"];
    private _oldVirt = +(_object getVariable["plb_vinv", [[], 0]]);
    private _oldPhys = +(_object getVariable["plb_pinv", [[], 0]]);
    waitUntil {isNull(findDisplay 4500)};
    life_trunk_vehicle setVariable["plb_activeTrunk", nil, true];
    life_action_in_use = false;
    if (life_inventoryInteraction) then {[true] call life_fnc_saveGear;
        life_inventoryInteraction = false;};
    if (life_movedItem) then {life_trunk_vehicle setVariable["plb_vinv", (life_trunk_vehicle getVariable "plb_vinv"), true];
        life_trunk_vehicle setVariable["plb_pinv", (life_trunk_vehicle getVariable "plb_pinv"), true];
        life_movedItem = false;};
    [_object] call life_fnc_slingAndMass;
    private _get_inv = {private _array = [];
        private _val = 0; {_val = missionNamespace getVariable [format["life_inv_%1", _x], 0];
            if ((_val) > 0) then {_array pushBack[_x, _val];};}
        forEach([2] call life_fnc_virtItemCfg);
        _array;};
    private _newVirt = _object getVariable["plb_vinv", [[], 0]];
    private _newPhys = _object getVariable["plb_pinv", [[], 0]];
    if (_object isKindOf "House_F") then {[
            ["-HOUSEINV-", player, (profileName), format["closed storage of house (HouseID: %1 | Owner: %2 | Position: %3). Virtual change: %4, Physical change: %5, Player Virtual Inventory: %6, Player Physical Inventory: %7", _object getVariable["plb_houseID", -1], _object getVariable["plb_homeOwner", "NoPidVar"], getPosATL _object, [_oldVirt, _newVirt] call life_fnc_inventoryDifference, [_oldPhys, _newPhys] call life_fnc_inventoryDifference, [] call _get_inv, getUnitLoadout player]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
    } else {[
            ["-VEHINV-", player, (profileName), format["closed vehicle trunk (Vehicle: %1 | Owner: %2 | Position: %5). Virtual change: %3, Player Virtual Inventory: %4", typeOf _object, _object getVariable["plb_dbInfo", "NoVehData"], [_oldVirt, _newVirt] call life_fnc_inventoryDifference, [] call _get_inv, getPosATL player]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
    };
    life_trunk_vehicle = objNull;
    if (_object isKindOf "House_F") then {
        // owner 2026-06-19 (HOUSE-STORAGE DUPE -- Jeff Stall): plb_pinv/plb_vinv are mutated CLIENT-side via async
        // setVariable [...,true]; a take/store fired just before close hadn't propagated to the server, so
        // TON_fnc_updateHouseTrunk snapshotted a STALE inventory (item still in the house) while the gear-save kept
        // the item = a dupe re-pulled on the next open. Twin of the vehicle/gang trunk fix: raise plb_trunkLock NOW
        // (blocks re-open via fn_openInventory:69), SETTLE out the propagation window, THEN persist, then release.
        // (The disconnect path calls updateHouseTrunk directly/synchronously -- left untouched, no settle needed there.)
        _object setVariable ["plb_trunkLock", true, true];
        // owner 2026-06-19: pass the CLIENT-authoritative post-take inv (_newVirt/_newPhys, read above) to the
        // save instead of letting the SERVER re-read the raced plb_pinv -> kills the stale-save dupe. Lock+settle
        // kept as belt-and-suspenders against a same-frame re-open.
        // owner 2026-06-25 (#542): also capture the SESSION gen (bumped by each hydrate). If a newer open hydrates
        // this house during the 1.25s settle, updateHouseTrunk no-ops this stale close so its dehydrate can't wipe
        // the live session. Belt to the live houses_no_wipe DB trigger.
        private _gen = _object getVariable ["plb_invGen", 0];
        [player, _object, _newVirt, _newPhys, _gen] spawn {params ["_pl", "_obj", "_v", "_p", "_g"];
            uiSleep 1.25;
            [[_pl, _obj, _v, _p, _g], "TON_fnc_updateHouseTrunk", false, false] spawn life_fnc_MP;
            uiSleep 0.75;
            if (!isNull _obj) then { _obj setVariable ["plb_trunkLock", false, true]; };};};};