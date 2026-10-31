#include "..\..\macro.h"
params[["_redeploy", false, [true]]];
if (_redeploy && PLB_Server isEqualTo 1 && {scriptAvailable(300)}) exitWith {closeDialog 0;
    ["You can only redeploy once every 5 minutes!", "basic"] spawn life_fnc_handleMessage;};
private _exit = false;
if (_redeploy) then {closeDialog 0;
    private _damage = damage player;
    private _startPos = getPos player;
    for "_i"
    from 1 to 15 step 1 do {if !(alive player) exitWith {_exit = true;};
        if !(isNull objectParent player) exitWith {_exit = true;
            ["Redeploy aborted.", "basic"] spawn life_fnc_handleMessage;};
        if (damage player > _damage) exitWith {_exit = true;
            ["You took damage while attempting to deploy to a new loaction. Redeploy aborted.", "basic"] spawn life_fnc_handleMessage;};
        if (player distance2D _startPos > 10) exitWith {_exit = true;
            ["You wandered off while attempting to deploy to a new location. Redeploy aborted.", "basic"] spawn life_fnc_handleMessage;};
        titleText[format["Redeploying to %1 in %2 seconds...", life_spawn_point select 1, 16 - _i], "PLAIN"];
        uiSleep 1;
        titleText["", "PLAIN"];
        life_copEviReq = nil;};};
if (_exit) exitWith {closeDialog 0};
private _text =
if (_redeploy) then {"You have deployed to"} else {"You have spawned at"};
private _plb_pos = [0, 0, 0];
private _marker = life_spawn_point param[0, ""];
// LooneyBin: short-circuit on (life_radio_civ isEqualType 0). life_radio_civ is "" (no numeric
// radio channel created on this server yet); radioChannelInfo needs a Number, so the bare call
// threw here and ABORTED spawnConfirm before the teleport -> "click Spawn, nothing happens".
if (life_sidechat && (playerSide isEqualTo civilian) && !(player in ((radioChannelInfo life_radio_civ) param [3, []]))) then {
	[life_sidechat] call life_fnc_manageSidechat;};
if (life_spawn_point isEqualTo[]) then {private _spawnPoint = ([playerSide] call life_fnc_spawnPointCfg) select 0;
    if (playerSide isEqualTo civilian) then {
        // owner 2026-06-18 (#347): this branch built _spawnPos but NEVER wrote it to _plb_pos -> _plb_pos stayed
        // [0,0,0] -> spawnConfirm errored (the [0,0,0] guard below) and the engine left the player at the default
        // respawn (water) at restart. Assign it. civ_spawn_N (fn_initCiv) = array of city buildings; pick one + a
        // building position, fall back to the building's getPos, and to the city marker if the array is empty.
        private _arr = missionNamespace getVariable _spawnPoint;
        if (_arr isEqualType [] && {count _arr > 0}) then {private _bld = selectRandom _arr;
            _plb_pos = _bld buildingPos 0;
            if (_plb_pos isEqualTo [0,0,0]) then { _plb_pos = getPosATL _bld; };} else {
            _plb_pos = getMarkerPos (_spawnPoint param [0, "civ_spawn_3"]);};} else {private _marker = _spawnPoint select 0;
        if (playerSide isEqualTo west) then {_marker = format["%1_%2", _marker, floor random 4]};
        _plb_pos = getMarkerPos _marker;};
    titleText[format["%2 %1", _spawnPoint select 1, _text], "BLACK IN"];} else {if (playerSide isEqualTo civilian) then {switch (true) do {
            case ("house" in _marker): {
                    // owner 2026-07-09: houseTypes-filtered + param (was a bare House_F select 0 -- script error on
                    // an empty result, and never matched sheds; a shed spawn resolved nothing/derelict).
                    private _mpos = getMarkerPos _marker;
                    // owner 2026-07-09 #2 (shed spawn race, SPAWNPROBE): if the marker is MISSING (login-time
                    // CLinitHouses raced the streaming intact shed and named it under the DB-id fallback), the
                    // menu-listed phouse_<OID> resolves [0,0,0]. Re-derive the position from the owned object
                    // itself: match the marker's id suffix against plb_houseID across life_vehicles.
                    if (_mpos isEqualTo [0,0,0]) then {private _suffix = _marker select [7];   // strip "phouse_"
                        private _own = (life_vehicles select { format ["%1", _x getVariable ["plb_houseID", ""]] isEqualTo _suffix }) param [0, objNull];
                        if (!isNull _own) then { _mpos = getPosATL _own; };};
                    private _hcands = nearestObjects[_mpos, ["House"], 18, true];
                    private _house = (_hcands select { (typeOf _x) in life_houseTypes }) param [0, (_hcands param [0, objNull])];
                    private _buildingPos = [_house] call life_fnc_getBuildingPositions;
                    if (_buildingPos isEqualTo[]) exitWith {_plb_pos = _mpos;};
                    _plb_pos = selectRandom _buildingPos;};
            case ("safezone" in _marker): {_plb_pos = [[[getMarkerPos _marker, 5]], []] call BIS_fnc_randomPos;};
            case ("gangbldg" in _marker): {
                    // owner 2026-06-18 (#343/345/347): resolve the gang-building spawn from the PERSISTED HQ pos
                    // (life_gang_data param 3), NOT a marker -> works for any member even with the owner offline.
                    // Spawn inside the building if its positions are loaded, else at the HQ pos. A [0,0,0] (building
                    // unset between menu-open and confirm) falls through to the generic [0,0,0] guard below = a clean
                    // "try a different spawn", never the ocean.
                    private _gpos = life_gang_data param [3, [0,0,0]];
                    private _ghc = nearestObjects [_gpos, ["House"], 18, true];
                    private _gh = (_ghc select { (typeOf _x) in life_houseTypes }) param [0, (_ghc param [0, objNull])];   // owner 2026-07-09: shed-proof resolve (gang houses are often sheds)
                    private _bp = if (isNull _gh) then { [] } else { [_gh] call life_fnc_getBuildingPositions };
                    _plb_pos = if (_bp isEqualTo []) then { _gpos } else { selectRandom _bp };};
            default {private _houses = missionNamespace getVariable _marker;
                if (isNil "_houses") then {if (_marker isEqualTo "gangboat_label" && {(!isNil "SRV_gangBoatShops")}) then {
                        _plb_pos = (SRV_gangBoatShops select 3);} else {_plb_pos = getMarkerPos _marker;};} else {
                    _plb_pos = getPosATL(selectRandom _houses);};};};} else {
        if (playerSide isEqualTo west && !(_marker in ["armory_marker"]) && (PLB_Server isEqualTo 1)) then {
            _marker = format["%1_%2", _marker, floor random 4]};
        _plb_pos = getMarkerPos _marker;
        life_eviSpawn = false;
        if (life_spawn_point select 1 isEqualTo "Mobile HQ") then {_plb_pos = life_spawn_point select 0};
        if (playerSide isEqualTo west && _marker isEqualTo "armory_marker" && life_evidence_spawns < 2) then {for "_i" from 1 to 100 do {
                private _safePos = [getMarkerPos "armory_marker", 25, 195, 3, 0, 0.2, 0] call BIS_fnc_findSafePos;
                _safePos pushBack 0;
                if (_safePos inPolygon life_eviFencePoly) exitWith {_plb_pos = _safePos};};};
        if (_marker isEqualTo "armory_marker" && life_evidence_spawns < 2) then {private _loadouts = [[
                    ["arifle_MX_Black_F", "", "", "optic_Arco_blk_F", ["30Rnd_65x39_caseless_black_mag", 30], [], ""], [],
                    ["hgun_P07_F", "muzzle_snds_L", "", "", ["30Rnd_9x21_Mag", 26], [], ""], ["U_Rangemaster", [["SmokeShellBlue", 1, 1]]],
                    ["V_PlateCarrier1_blk", [["30Rnd_556x45_Stanag", 1, 30], ["30Rnd_9x21_Mag", 1, 30],
                        ["30Rnd_65x39_caseless_black_mag", 8, 30], ["SmokeShellBlue", 2, 1], ["MiniGrenade", 3, 1]]], ["B_Bergen_blk", [
                        ["ToolKit", 1], ["30Rnd_65x39_caseless_black_mag", 8, 30]]], "H_Cap_police", "", ["Binocular", "", "", "", [],
                        [], ""], ["ItemMap", "ItemGPS", "", "ItemCompass", "ItemWatch", "Integrated_NVG_F"]], [
                    ["arifle_MXM_Black_F", "", "", "optic_Arco_blk_F", ["30Rnd_65x39_caseless_black_mag", 30], [], ""], [],
                    ["hgun_P07_F", "muzzle_snds_L", "", "", ["30Rnd_9x21_Mag", 26], [], ""], ["U_Rangemaster", [["SmokeShellBlue", 1, 1]]],
                    ["V_PlateCarrier1_blk", [["30Rnd_556x45_Stanag", 1, 30], ["30Rnd_9x21_Mag", 1, 30],
                        ["30Rnd_65x39_caseless_black_mag", 8, 30], ["SmokeShellBlue", 2, 1], ["MiniGrenade", 3, 1]]], ["B_Bergen_blk", [
                        ["ToolKit", 1], ["30Rnd_65x39_caseless_black_mag", 8, 30]]], "H_Cap_police", "", ["Binocular", "", "", "", [],
                        [], ""], ["ItemMap", "ItemGPS", "", "ItemCompass", "ItemWatch", "Integrated_NVG_F"]], [
                    ["srifle_DMR_03_F", "", "", "optic_Arco_blk_F", ["20Rnd_762x51_Mag", 20], [], ""], [], [], ["U_Rangemaster", [
                        ["20Rnd_762x51_Mag", 3, 20], ["SmokeShellBlue", 1, 1]]], ["V_PlateCarrier1_blk", [["20Rnd_762x51_Mag", 11, 20],
                        ["SmokeShellBlue", 2, 1]]], ["B_FieldPack_blk", [["ToolKit", 1], ["20Rnd_762x51_Mag", 1, 20]
                    ]], "H_Cap_police", "", ["Binocular", "", "", "", [], [], ""],
                    ["ItemMap", "ItemGPS", "", "ItemCompass", "ItemWatch", "Integrated_NVG_F"]], [
                    ["arifle_SPAR_01_blk_F", "", "", "optic_Aco", ["30Rnd_556x45_Stanag", 30], [], ""], [],
                    ["hgun_P07_F", "muzzle_snds_L", "", "", ["30Rnd_9x21_Mag", 26], [], ""], ["U_Rangemaster", [["SmokeShellBlue", 1, 1]]],
                    ["V_TacVest_blk_POLICE", [["30Rnd_556x45_Stanag", 9, 30], ["MiniGrenade", 2, 1], ["1Rnd_SmokeBlue_Grenade_shell", 1, 1],
                        ["30Rnd_9x21_Mag", 1, 30]]], [], "H_Cap_police", "", ["Binocular", "", "", "", [], [], ""],
                    ["ItemMap", "ItemGPS", "", "ItemCompass", "ItemWatch", "Integrated_NVG_F"]]];
            life_eviSpawn = true;
            life_swatLoadout = getUnitLoadout player;
            player setUnitLoadout(_loadouts select floor random count _loadouts); [
                ["-COPEVIDENCE-", player, (profileName), "spawned at the evidence lockup."], "TON_fnc_logIt", 2] spawn life_fnc_MP;
            life_evidence_spawns = life_evidence_spawns + 1;
            [] spawn {uiSleep 360;
                life_evidence_spawns = 0;};};};
    titleText[format["%2 %1", life_spawn_point select 1, _text], "BLACK IN"];};
if (_plb_pos isEqualTo[0, 0, 0]) exitWith {
    ["Error. Please wait a bit or try a different spawn point.", "basic"] spawn life_fnc_handleMessage;};
// owner 2026-07-19: restore simulation before the teleport (players are held sim-off at 50km during spawn-select)
player enableSimulation true;
player setPosATL _plb_pos;
closeDialog 0;
"loadingScreen"
cutText["", "PLAIN"];
cutText["", "BLACK IN"];
if (life_firstSpawn) then {life_firstSpawn = false;};
[] call life_fnc_hudUpdate;
if (playerSide isEqualTo civilian) then {if (PLB_Server isEqualTo 1) then {
        // owner 2026-06-19 ("softlog strips gear"): civLoadout = the DEATH loadout -- it strips weapons/vest, force-adds
        // a RANDOM civ uniform, WIPES the virtual inventory, and saveGear-persists that naked state. It was firing on
        // EVERY spawn-menu confirm, so a CONNECT/RELOG that lands on the spawn menu (saved position empty/blanked ->
        // not the teleport-back path) got stripped and the naked state overwrote the real kit in the DB. Gate it on
        // life_respawned: ONLY an actual death-respawn (life_respawned=true, set by fn_doRespawn before the menu) strips.
        // A relog (life_respawned=false) RESTORES the loaded kit instead -- loadGear applies life_gear (already loaded
        // by requestReceived) and self-falls-back to civLoadout only if life_gear is genuinely empty.
        if (life_respawned) then {[] call life_fnc_civLoadout;} else {
            [] spawn life_fnc_loadGear;   // owner 2026-06-19: SPAWN not call -- loadGear has a waitUntil (scriptDone stripDownPlayer); fn_spawnConfirm runs UNSCHEDULED so `call` threw "Suspending not allowed in this context" -> loadGear aborted after stripping = naked relog. spawn = scheduled context, waitUntil ok, kit restored. (civLoadout has no suspend, hence it was call-safe.)
        };};} else {if !(_redeploy) then {[uniform player, "setUniform", ""] call life_fnc_clothingTextures;};};
if (!_redeploy && playerSide isEqualTo west && life_activeSWAT && !(_marker isEqualTo "armory_marker")) then {life_SWATActionAvail = false;
    player setUnitLoadout life_swatLoadout;
    life_activeSWAT = false;
    life_swatLoadout = nil;}; [
    ["-RESPAWN-", player, (profileName), format["spawned at %1", getPosATL player]], "TON_fnc_logIt", 2] spawn life_fnc_MP;