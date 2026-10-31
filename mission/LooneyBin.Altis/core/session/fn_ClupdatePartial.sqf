#include "..\..\macro.h"
if !(life_session_completed) exitWith {};
// owner 2026-06-21 (player108 money-wipe): mirror the spawn-select guard from fn_ClupdateRequest. case 0/1 below
// persist life_cash/atmcash, so block ALL partial saves while the spawn-select menu (38500) is open (player
// not in-world -> money not live). This path is in-world-triggered today (ATM deposit/withdraw), but it carries
// the identical save-0-over-real-balance hole, so guard it too (defense-in-depth).
if (!isNull (findDisplay 38500)) exitWith {};
if (isFilePatchingEnabled) then {[[player, [1, round diag_tickTime]], "TON_fnc_dongClient", 2] call life_fnc_MP;};
params[["_mode", 0, [0]]];
if (alive player && !isNil "life_sidechat") then {[life_sidechat] call life_fnc_manageSidechat;};
if (playerSide isEqualTo west && _mode in [8, 10]) exitWith {};
if (playerSide isEqualTo independent && _mode in [10]) exitWith {};
if (playerSide isEqualTo civilian && _mode in []) exitWith {};
if (!isNil "life_shop_cam" && {!isNull life_shop_cam} && {_mode in [3]}) exitWith {};
private _packet = [player, playerSide, getPlayerUID player, _mode];
private _array = [];
private _sideFlag =
switch (playerSide) do {case west: {"cop"};
    case civilian: {"civ"};
    case independent: {"med"};}; private _exit = false;
private _hackDetected = false;
if (_mode isEqualTo 3) then {private _totalItemsActual = 0; {
        _totalItemsActual = _totalItemsActual + (missionNameSpace getVariable [_x, 0]);}
    forEach life_invMonVars;
    if (_totalItemsActual > (life_invMonitor - life_invRVar) || _totalItemsActual >= 130) exitWith {_hackDetected = true;
        private _hackedItemArray = []; {if ((missionNameSpace getVariable [_x, 0]) > 0) then {
                _hackedItemArray pushBack[_x, (missionNameSpace getVariable [_x, 0])];};}
        forEach life_invMonVars; [
            [player, [3, (life_invMonitor - life_invRVar), _totalItemsActual, str _hackedItemArray]], "TON_fnc_dongClient", 2] call life_fnc_MP;
        [] spawn {uiSleep 2;
            diag_log "[LooneyBin] MemHackCash AC neutered (no kick)";};
        // BUGS.md #79/#80: same monitor -- was blocking the mode-3 gear save past 130 items. Log + resync, keep saving.
        life_invMonitor = _totalItemsActual + life_invRVar;
        _hackDetected = false;};};
if (_hackDetected) exitWith {};
switch (_mode) do {case 0: {if (life_lastSyncedCash isEqualTo life_cash) exitWith {_exit = true};
            _packet pushBack life_cash;
            life_lastSyncedCash = life_cash;};
    case 1: {if (life_lastSyncedBank isEqualTo life_atmCash) exitWith {_exit = true};
            _packet pushBack life_atmcash;
            [] call life_fnc_achievementScan;
            life_lastSyncedBank = life_atmCash;};
    case 2: {{if (_x select 1 == _sideFlag) then {_array pushBack[_x select 0, (missionNamespace getVariable(_x select 0))];};}
            forEach life_licenses;
            _packet pushBack _array;};
    case 3: {
            // LooneyBin: life_clothing_store is initialised to "init" (initPlayerLocal) and only reset
            // to "" by the clothing shop -> this guard `!= ""` blocked EVERY gear save until you'd
            // opened+closed a clothing shop, so civ_gear never persisted. Treat "init" as "no shop".
            if !(life_clothing_store in ["", "init"]) exitWith {_exit = true};
            if ((life_is_arrested param [0,0]) isEqualTo 1) exitWith {_exit = true;};
            private _rwPos = getMarkerPos "respawn_west";  // LooneyBin: respawn_west absent -> [0,0,0];
            // only block near it when it actually exists (else it blocked all saves near map origin).
            if (life_isDead || ((_rwPos isNotEqualTo [0,0,0]) && {(player distance _rwPos) < 1000})) exitWith {_exit = true};
            if (life_inEvent) exitWith {_exit = true};
            if (life_lastSynced_gear isEqualTo(str life_gear)) exitWith {_exit = true};
            if (life_activeSWAT || life_eviSpawn) exitWith {_exit = true};
            if (life_isActiveFirefighter) exitWith {_exit = true};
            if (str player in ["cop_detective_1", "cop_detective_2", "cop_detective_3"]) exitWith {_exit = true;
                [17] call life_fnc_ClupdatePartial};
            life_lastSynced_gear = str life_gear;
            _packet pushBack life_gear;};
    case 4: {_packet pushBack life_side_talents;
            _packet pushBack life_side_exp;};
    case 5: {_packet pushBack life_is_arrested;};
    case 6: {_packet pushBack life_cash;
            _packet pushBack life_atmcash;
            [] call life_fnc_achievementScan;};
    case 7: {_packet pushBack life_achievements;};
    case 8: {_packet pushBack A_stats_crimes;};
    case 9: {
            _packet pushBack[A_stats_warKills, A_stats_warDeaths, A_stats_warRating, A_stats_copArrests, A_stats_civArrests, A_stats_warPoints, A_stats_apbEvades, A_stats_civKills, A_stats_civDeaths, A_stats_civRevives, A_stats_civExecutes, A_stats_civTime, A_stats_copLethals, A_stats_copDeaths, A_stats_copTime, A_stats_medTime, A_stats_medRevives];
        };
    case 10: {profileNamespace setVariable["plb_thirst", plbv_thirst];
            profileNamespace setVariable["plb_hunger", plbv_hunger];
            profileNamespace setVariable["plb_playerDir", getDir vehicle player];
            profileNamespace setVariable["plb_playerDamage", getDammage player];
            if (alive player && (player distance(getMarkerPos "Respawn_west") > 1000) && (player distance[0, 0, 0] > 1000)) then {
                private _noSyncZones = [["life_bank_door", 55], ["life_bank_door_2", 55], ["fed_reserve", 185], ["armory_marker", 220]];
                private _cartelSyncZones = [["arms_cartel", 200], ["drug_cartel", 200], ["oil_cartel", 200], ["wongs_cartel", 200]];
                if (_noSyncZones findIf {player distance(getMarkerPos(_x select 0)) < (_x select 1)}
                isEqualTo - 1) then {private _pos =
                    if (surfaceIsWater(getPosATL player)) then {getPosASL player} else {getPosATL player};
                    if (vehicle player isKindOf "Air") then {_pos set[2, 1]}; {_x params["_marker", "_maxDistance"];
                        if (player distance(getMarkerPos _marker) <= _maxDistance) exitWith {
                            _pos = [getMarkerPos _marker, 250, 300, 3, 0, 1, 0] call BIS_fnc_findSafePos;
                            _pos set[2, 1];};}
                    forEach _cartelSyncZones;
                    life_ses_last_pos = _pos;} else {_exit = true;};} else {life_ses_last_pos = [];};
            _packet pushBack life_ses_last_pos;};
    case 11:
        { _packet pushBack life_gear; };   // LooneyBin #63: death-gear save. onPlayerKilled resets life_gear to the side default then calls mode 11/12/13 -- these cases were EMPTY and the server had no matching cases -> the death save was a no-op end to end, so Alt-F4 after dying kept the old loadout in the DB (combat-log dupe). Push the (already-reset) gear; server cases 11/12/13 write it to <side>_gear.
    case 12:
        { _packet pushBack life_gear; };
    case 13:
        { _packet pushBack life_gear; };
    case 14: {_packet pushBack life_honor_exp;
            _packet pushBack life_honor_talents;};
    case 15: {_packet pushBack(player getVariable["plb_prefix", ""]);};
    case 16: {if (isNil "life_prestige" || isNil "life_cop_talents") exitWith {_exit = true};
            _packet pushBack life_prestige;
            _packet pushBack life_cop_talents;};
    case 17: {if !(life_clothing_store isEqualTo "") exitWith {_exit = true};
            if !(str player in ["cop_detective_1", "cop_detective_2", "cop_detective_3"]) exitWith {_exit = true};
            life_lastSynced_gear = str life_gear;
            _packet pushBack life_gear;};
    case 18: {
            // LooneyBin 2026-07-23 NEW DRACHMA: the wallet is server-authoritative (TON_fnc_ndSRV).
            // The client no longer persists new_drachma -- the server ignores partial-18 anyway.
            _exit = true;};
    case 19: {_packet pushBack([3, ((player getVariable["plb_title", ["", "#B6B6B6"]]) param[0, ""])] call life_fnc_titleCfg);};
    case 20: {_packet pushBack(str life_completedLifetimeQuests);
            _packet pushBack(str life_LifetimeProgressQuests);
            life_lastSynced_LifetimeProgressQuests = +life_LifetimeProgressQuests;
            life_lastSynced_completedLifetimeQuests = +life_completedLifetimeQuests;};
    case 21: {_packet pushBack life_govClientData;};
    case 22: {_packet pushBack life_infamy_exp;
            _packet pushBack life_infamy_talents;};
    case 23: {if (isNil "life_medic_exp" || isNil "life_medic_talents") exitWith {_exit = true};
            _packet pushBack life_medic_exp;
            _packet pushBack life_medic_talents;};
    case 24: {
            _packet pushBack (if (life_isFirefighter) then {1} else {0});   // LooneyBin: firefighter registration -> persist isfirefighter
        };}; if (_exit) exitWith {};
[_packet, "DB_fnc_updatePartial", false, false] call life_fnc_MP;