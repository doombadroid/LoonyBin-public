#include "..\..\macro.h"
private _getTitleColor = {_return = "#B6B6B6";
    _return =
    profileNamespace getVariable["plb_titleColor", "#B6B6B6"];
    _return};
life_session_tries = life_session_tries + 1;
if (life_session_completed) exitWith {};
if (life_session_tries > 3) exitWith {life_loadingScreenStatus = "There Was An Error In Trying To Setup Your Client Info";};
life_loadingScreenStatus = "Received Request From Server... Validating....";
if (isNil "_this") exitWith {[] call life_fnc_insertPlayerInfo;};
if (_this isEqualType "") exitWith {[] call life_fnc_insertPlayerInfo;};
if (count _this isEqualTo 0) exitWith {[] call life_fnc_insertPlayerInfo;};
if ((getPlayerUID player) != _this select 0) exitWith {[] call life_fnc_dataQuery;};
life_cash = _this select 1;
life_atmcash = _this select 2;
life_cashCacheB = ((life_cash / 4) + 9);
life_atmcashCacheB = ((life_atmcash / 4) + 11);
// LooneyBin (owner 2026-06-13): beta-tester whitelist flag (load slot 35, all sides). Gates the Beta Tester
// Shirt in the civ clothing shop. count-guarded so an older/short load array can't throw.
PLB_betaTester = (count _this > 35) && {(_this select 35) isEqualTo 1};
player setVariable ["plb_casinoBanned", (count _this > 37) && {(_this select 37) isEqualTo 1}];   // LooneyBin: casino self-exclusion (players.casino_banned) -> phone-button + casino-app gate
// LooneyBin: cross-server profile firewall. profileNamespace is GLOBAL to the player's Arma profile (shared
// across EVERY Arma server). LoonyBin USED to inherit the upstream ga_* key names verbatim -> a player arriving from the origin server
// imported their addiction / drug use / hunger / quest progress on first join (e.g. Torch spawning
// pre-addicted). As of 2026-06-11 the ENTIRE codebase was renamed ga_* -> plb_* (full isolation: a key
// collision with the origin server can never happen again, so the leak is structurally fixed). This block stays as
// belt-and-suspenders: a ONE-time scrub of any leftover upstream ga_* profile data so a migrating profile
// starts clean. It wipes ga_* (the upstream keys), NOT plb_* (LoonyBin's own keys -- never touch those).
if ((profileNamespace getVariable ["PLB_profileTag", ""]) isNotEqualTo "LOONYBIN") then {
    { profileNamespace setVariable [_x, nil]; } forEach ["ga_addictionCiv", "ga_addictionCop", "ga_addictionMedic",
        "ga_drugsUsedCiv", "ga_drugsUsedCop", "ga_drugsUsedMedic","ga_clothingSkinsCiv", "ga_clothingSkinsCop", "ga_clothingSkinsMed",
        "ga_hunger", "ga_thirst", "ga_pain", "ga_playerDamage", "ga_playerDir",
        "ga_titleColor", "ga_coloredHexesData", "ga_metalDetectorID",
        "ga_questChestLootArray", "ga_questDoubleClickedIndex", "ga_questDoubleClickedIndexSeas", "ga_tutorialProgress"];
    profileNamespace setVariable ["PLB_profileTag", "LOONYBIN"];
    saveProfileNamespace;};
__SETCONST__(life_adminLevel, (_this select 3));
private _isAdmin = call life_adminLevel >= 3;
__SETCONST__(life_eventCoordinatorLevel, (_this select 4));
if ((count(_this select 7)) > 0) then {{missionNamespace setVariable[_x select 0, _x select 1];}
    forEach(_this select 7);};
life_side_exp = _this select 8;
if (playerSide isEqualTo civilian && {life_side_exp < 100}) then {life_side_exp = 100;};
life_side_talents = _this select 9;
// owner 2026-06-24: REVERTED the 2026-06-11 blanket force-grant. The standard Talents menu is restored
// (Talents phone button) so civ/cop/medic pick + freely respec their own build (max points via the cap,
// free respec). Load the player's SAVED talents from the DB (_this select 9 above) -- no auto-grant of all.
if ((_this select 10) isEqualType "" && {!((_this select 10) isEqualTo "")}) then {player setVariable["plb_prefix", _this select 10, true];
};
life_achievements = _this select 11;
// owner 2026-06-19 (#395): achievements persist DOUBLE-quoted ("[0]") in players_global, so the global decoder's
// `call compile` returns the STRING "[0]" not the array [0]. life_achievements then being a string broke
// `_id in life_achievements` (always false) and `pushBack` (errors) in fn_achievementGrant -> event achievements
// (fishing 13/14/15, kills, etc.) re-fired the "unlocked" notification on every action AND never saved (no player
// had fishing achievements in the DB). Coerce to a real array -- parseSimpleArray round-trips the string form.
if (life_achievements isEqualType "") then { life_achievements = parseSimpleArray life_achievements; };
if !(life_achievements isEqualType []) then { life_achievements = []; };
private _allLootRewards = [500, 501, 502, 503, 504, 505];
for "_i"
from 1 to 140 do {_allLootRewards pushBack _i;}; for "_i"
from 1500 to 1571 do {_allLootRewards pushBack _i;}; life_lootRewards = _allLootRewards;
A_stats = _this select 14;
// LooneyBin: the DB stats column holds the 2020 asyv (deeply-nested) stats, but this 2017 A_stats code
// reads it as a FLAT numeric array (select 0 = warKills...). When select 0 is an array (the nested blob),
// the achievement conditions ({A_stats_warKills>=25} etc.) throw "Type Array, expected Number" ->
// life_fnc_achievementScan aborts mid-forEach -> the ClupdatePartial that called it halts -> ANY action
// that runs ClupdatePartial first (a vehicle purchase does [6] call ClupdatePartial before createVehicle)
// silently dies -> no car, no message, repeated half-scans spam achievement notifications. Reset to a flat
// numeric array when malformed so A_stats_* are always Numbers.
// owner 2026-06-21 (#462 buying clothing -> false Bounty Hunter achievement): players_global.stats is SHARED
// with the 148-slot lifetime stat array (TON_fnc_statTableUpdate) which clobbers the 17-slot A_stats. A loaded
// array LONGER than 17 = the lifetime array -> A_stats[4] reads `prisontime` as `civArrests` -> a high prison-
// time player gets Bounty Hunter (id 27) falsely granted on the next achievementScan (fires when the clothing
// shop closes). Reject any >17 array as invalid A_stats (reset -> padded to 17 zeros below). This stops the
// SYMPTOM; the real fix is splitting the two stat systems off the shared column (flagged to owner, #462).
if (!(A_stats isEqualType []) || {(A_stats param [0, []]) isEqualType []} || {(count A_stats) > 17}) then { A_stats = []; };
if ((count A_stats) < 17) then {_toAdd = 17 - (count A_stats);
    for [{_x = 1}, {_x <= _toAdd}, {_x = _x + 1}] do {A_stats pushBack 0;};};
A_stats_warKills = A_stats select 0;
A_stats_warDeaths = A_stats select 1;
A_stats_warRating = A_stats select 2;
A_stats_copArrests = A_stats select 3;
A_stats_civArrests = A_stats select 4;
A_stats_warPoints = A_stats select 5;
A_stats_apbEvades = A_stats select 6;
A_stats_civKills = A_stats select 7;
A_stats_civDeaths = A_stats select 8;
A_stats_civRevives = A_stats select 9;
A_stats_civExecutes = A_stats select 10;
A_stats_civTime = A_stats select 11;
A_stats_copLethals = A_stats select 12;
A_stats_copDeaths = A_stats select 13;
A_stats_copTime = A_stats select 14;
A_stats_medTime = A_stats select 15;
A_stats_medRevives = A_stats select 16;
// singleevh.md Phase 3a.2: hydrate the live stat map from the DB lifetime_stats (login reply field 36 -- NOT
// 15, which the side switch owns: civ=arrested / cop=coplevel / med=mediclevel). Defensive param[36,[]] so an
// older/mismatched reply cannot throw. Populated unconditionally; harmless when PLB_useStatBuffer is off.
private _plbLtStats = _this param [36, []];
if !(_plbLtStats isEqualType []) then { _plbLtStats = []; };
PLB_stats_live = createHashMap;
{ if (_x isEqualType 0 && {_x != 0}) then { PLB_stats_live set [_forEachIndex, _x]; }; } forEach _plbLtStats;
if !(A_stats_warRating isEqualTo 0) then {player setVariable["plb_season", A_stats_warRating, true]};
if ((SRV_governorData param[0, "Nah"]) isEqualTo(getPlayerUID player)) then {life_govTax set[0, true];} else {life_govTax set[0, false];};
private _copLevel = 0;
private _copRetiredLevel = 0;
private _medicLevel = 0;
switch (playerSide) do {case civilian: {if (A_stats_civTime <= 480) then {player setVariable["plb_lowtime", true, true];};
            life_is_arrested = _this select 15;
            // LooneyBin (Torch/Nikki/Typhoon "can't be downed" ROOT): index 15 (DB `arrested`) decodes to an
            // EMPTY/malformed array for some accounts (never-arrested or migrated rows) -> `life_is_arrested
            // select 0` returns nil, and the DOWN gate's `(life_is_arrested param [0,0]) isEqualTo 0` is then
            // FALSE (nil != 0) so handleDowned never spawns = the player can never be downed (GATEDIAG showed
            // arrested=<null> on the affected players vs arrested=0 on a normal one). Normalise to a valid
            // [state,time,?] (default [0,0,0]); a real jail ([0]==1, 3 elems) is kept intact.
            if !((life_is_arrested isEqualType []) && {(count life_is_arrested) >= 3} && {(life_is_arrested param [0, -1]) in [0, 1]}) then { life_is_arrested = [0, 0, 0]; };
            A_stats_crimes = _this select 16;
            if !((count A_stats_crimes) isEqualTo life_totalCrimes) then {private _missing = life_totalCrimes - (count A_stats_crimes);
                if (_missing < 0) then {A_stats_crimes resize life_totalCrimes;} else {for "_i"
                    from 1 to _missing do {A_stats_crimes pushBack 0;};};};
            [] spawn {uiSleep 20;
                waitUntil {alive player};
                player setVariable["plb_wantedAmt", A_stats_crimes select 0, true];
                if ((A_stats_crimes param [0, 0]) > 0) then { [getPlayerUID player, name player, +A_stats_crimes] remoteExec ["TON_fnc_wantedSyncList", 2]; };
            };
            life_ses_last_pos = _this select 17;
            life_infamy_exp = _this select 19;
            life_infamy_talents = _this select 20;
            life_honor_exp = _this select 21;
            life_honor_talents = _this select 22;
            // NEW DRACHMA: server sends the EXACT balance as a 4dp STRING (slot 23). life_ndStr is the
            // display truth; life_nd is a float mirror kept only so legacy afford-checks/labels
            // keep compiling. Both are set ONLY by the server (here, ndSync, ndResult) from now on.
            life_ndStr = _this select 23;
            if (isNil "life_ndStr" || {!(life_ndStr isEqualType "")}) then { life_ndStr = "0"; };
            life_nd = parseNumber life_ndStr;
            life_ndCacheB = ((life_nd / 4) + 5);
            if !((_this select 25) isEqualTo - 1) then {
                player setVariable["plb_title", [([4, (_this select 25)] call life_fnc_titleCfg), (call _getTitleColor)], true];};
            life_completedLifetimeQuests = ((_this select 26) select 0);
            life_LifetimeProgressQuests = ((_this select 26) select 1);
            life_lastSynced_LifetimeProgressQuests = +life_LifetimeProgressQuests;
            life_lastSynced_completedLifetimeQuests = +life_completedLifetimeQuests;
            life_gang_data = _this select 28;
            if !(life_gang_data isEqualTo[]) then {private _gangVar = life_gang_data;
                // owner 2026-06-21 (#469/#470 gang houses dead): the server packs the gang HOUSE position at
                // _gangVar[3] (fn_queryRequest: "slot 3 = gang HOUSE position"; slot 5 is a vestigial [0,0,0]
                // placeholder). This read param[5] -> life_gang_data[3] was ALWAYS [0,0,0] -> fn_initGang's
                // marker/spawn/building-access block (gated on [3] != [0,0,0]) was SKIPPED for EVERY gang, so
                // members couldn't see, spawn at, or access the gang house. Read slot 3 to match the server.
                life_gang_data = [(_gangVar param[0, -1]), (_gangVar param[1, "Error Gang Name"]), (_gangVar param[2, 5]), (_gangVar param[3, [0, 0, 0]])];
                life_gang_talents = ((_gangVar select 4) select 1);
                life_gang_exp = ((_gangVar select 4) select 0);
                player setVariable["gang_data", life_gang_data, true];} else {player setVariable["gang_data", [], true];};
            if ((life_gang_data param[0, 0]) <= 0) then {life_gang_data = [];};
            if !(life_gang_data isEqualTo[]) then {[] spawn life_fnc_initGang;};
            life_houses = _this select 27;
            // owner 2026-07-09 (Phil's ghost "unfinished shed" keychain entry): this used to ALSO resolve every
            // owned house here with a raw nearestObjects["House"] select 0 -- no house-type filter. At a replaced
            // shed spot the HIDDEN terrain derelict (Land_u_Shed_Ind_F, still present client-side; setPos doesn't
            // replicate for terrain objects) ties at d=0 with the intact shed and can win the tie -> the DERELICT
            // entered the keychain, and fn_CLinitHouses' in-guard (dupe check) never evicted it. CLinitHouses is
            // spawned right below and does the SAME job with the houseTypes-filtered resolve (2026-07-04 fix + the
            // 18m radius) -- so the raw duplicate loop is simply gone. One resolver, one answer.
            [] spawn life_fnc_CLinitHouses;
            // owner 2026-06-23: keyholders see green "(Key)" markers for houses they hold keys to (server filters).
            [[], "TON_fnc_sendKeyHouses", 2] spawn life_fnc_MP;
            if (count(_this select 29) > 0) then {{life_vehicles pushBack _x;}
                forEach(_this select 29);};
            ["initGovClient", [(_this select 30)]] spawn life_fnc_govSystem;
            private _newPlayer = (_this select 31) isEqualTo 1;
            // owner 2026-07-11: THE INTAKE Act 1 -- 0 = pending (fresh account) -> fn_initCiv swaps the
            // spawn menu for the onboarding sequence. -1 default = payload missing (never triggers).
            life_intakePath = _this param [38, -1];
            life_intakeStep = _this param [39, 255];   // Parole Papers arc progress (255 = done/none)
            __SETCONST__(life_newplayer, if (_newPlayer && A_stats_civTime <= 120) then {true} else {false});
            // LooneyBin (owner, 2026-06-11): passive mode (new-player invulnerability) REMOVED entirely -- the
            // auto-"start" call is gone. New players are vulnerable like everyone else.
            life_addiction = profileNamespace getVariable["plb_addictionCiv", [0, 0, 0, 0, 0]];
            life_used_drug = profileNamespace getVariable["plb_drugsUsedCiv", [0, 0, 0, 0, 0]];
            life_uniformBackpack_skins = profileNamespace getVariable["plb_clothingSkinsCiv", [-1, -1]];};
    case west: {_copLevel = _this select 15;
            life_prestige = _this select 16;
            life_cop_talents = _this select 17;
            life_isSwat = (_this select 20) isEqualTo 1;
            life_isDetective = (_this select 23) isEqualTo 1;   // owner 2026-06-19: undercover/detective whitelist (players.isdetective -> queryRequest cop slot 23). fn_initCop gates the cop_detective_* slots on this.
            if !((_this select 21) isEqualTo - 1) then {
                player setVariable["plb_title", [([4, (_this select 21)] call life_fnc_titleCfg), (call _getTitleColor)], true];};
            life_completedLifetimeQuests = ((_this select 22) select 0);
            life_LifetimeProgressQuests = ((_this select 22) select 1);
            life_lastSynced_LifetimeProgressQuests = +life_LifetimeProgressQuests;
            life_lastSynced_completedLifetimeQuests = +life_completedLifetimeQuests;
            if (count(_this select 18) > 0) then {{life_vehicles pushBack _x;}
                forEach(_this select 18);};
            _copRetiredLevel = (_this select 24);
            A_stats_crimes = [];
            if (((count A_stats_crimes) - 1) < life_totalCrimes) then {_newCrimes = life_totalCrimes - ((count A_stats_crimes) - 1);
                for [{_x = 1}, {_x <= _newCrimes}, {_x = _x + 1}] do {A_stats_crimes pushBack 0;};};
            if (((count A_stats_crimes) - 1) != life_totalCrimes) then {A_stats_crimes = [];
                for [{_x = 0}, {_x <= life_totalCrimes}, {_x = _x + 1}] do {A_stats_crimes pushBack 0;};};
            life_maxTalents = 20;
            if (_copLevel > 2) then {life_maxTalents = life_maxTalents + (2 * (_copLevel - 2));};
            life_addiction = profileNamespace getVariable["plb_addictionCop", [0, 0, 0, 0, 0]];
            life_used_drug = profileNamespace getVariable["plb_drugsUsedCop", [0, 0, 0, 0, 0]];
            life_uniformBackpack_skins = profileNamespace getVariable["plb_clothingSkinsCop", [-1, -1]];};
    case independent: {_medicLevel = _this select 15;
            // NG "EMT Volunteer" tier: a player who took a medic lobby slot but is NOT whitelisted (DB
            // mediclevel 0) becomes a level-99 volunteer instead of being kicked at fn_initMedic. 99 is
            // Suda's sentinel -> handled by getRankString/playerTags/clothing_med case 99, and NORMALIZED
            // to 0 in every rank `>=` perk gate (weaponShopCfg _ngRank, clothing_med _glvl) so a volunteer
            // is unarmed/basic-gear only. Injected HERE, before life_medicLevel is __SETCONST__'d at :365,
            // so every `call life_medicLevel` consumer sees the volunteer value consistently.
            if (_medicLevel < 1) then { _medicLevel = 99; };
            life_medic_exp = _this param [33, 0];           // LooneyBin: NG prestige points
            life_medic_talents = _this param [34, []];      // LooneyBin: NG prestige talents
            if !((_this select 18) isEqualTo - 1) then {
                player setVariable["plb_title", [([4, (_this select 17)] call life_fnc_titleCfg), (call _getTitleColor)], true];};
            life_completedLifetimeQuests = ((_this select 19) select 0);
            life_LifetimeProgressQuests = ((_this select 19) select 1);
            life_lastSynced_LifetimeProgressQuests = +life_LifetimeProgressQuests;
            life_lastSynced_completedLifetimeQuests = +life_completedLifetimeQuests;
            life_isFirefighter = (_this select 21) isEqualTo 1;
            if (count(_this select 16) > 0) then {{life_vehicles pushBack _x;}
                forEach(_this select 16);};
            A_stats_crimes = [];
            if (((count A_stats_crimes) - 1) < life_totalCrimes) then {_newCrimes = life_totalCrimes - ((count A_stats_crimes) - 1);
                for [{_x = 1}, {_x <= _newCrimes}, {_x = _x + 1}] do {A_stats_crimes pushBack 0;};};
            if (((count A_stats_crimes) - 1) != life_totalCrimes) then {A_stats_crimes = [];
                for [{_x = 0}, {_x <= life_totalCrimes}, {_x = _x + 1}] do {A_stats_crimes pushBack 0;};};
            life_addiction = profileNamespace getVariable["plb_addictionMedic", [0, 0, 0, 0, 0]];
            life_used_drug = profileNamespace getVariable["plb_drugsUsedMedic", [0, 0, 0, 0, 0]];
            life_uniformBackpack_skins = profileNamespace getVariable["plb_clothingSkinsMed", [-1, -1]];};
}; __SETCONST__(life_copLevel, _copLevel);
__SETCONST__(life_copRetiredLevel, _copRetiredLevel);
// LooneyBin BETA GOD-STATS: while in closed beta, max EVERYONE on load -- 1 billion in every progression
// currency + every talent/prestige tree fully unlocked. Applied at load (re-applies each login). Gated by
// PLB_betaMaxStats (default true). getSpecialitys = all prestige nodes for a tree; getFactionTalentsIDs =
// all standard talents for the player's side -> mapping to IDs unlocks everything.
// >>> UNDO BEFORE PUBLIC LAUNCH: see launch.md (remove/disable this block + reset the progression DB
// columns -- these vars ARE persisted by the periodic save, so a code change alone won't clear accounts).
if (missionNamespace getVariable ["PLB_betaMaxStats", true]) then {
    life_prestige   = 1000000000;  life_cop_talents    = (["getSpecialitys", "cop"]   call life_fnc_prestigeCfg) apply {_x select 0};
    life_infamy_exp = 1000000000;  life_infamy_talents = (["getSpecialitys", "rebel"] call life_fnc_prestigeCfg) apply {_x select 0};
    life_honor_exp  = 1000000000;  life_honor_talents  = (["getSpecialitys", "bh"]    call life_fnc_prestigeCfg) apply {_x select 0};
    life_medic_exp  = 1000000000;  life_medic_talents  = (["getSpecialitys", "medic"] call life_fnc_prestigeCfg) apply {_x select 0};
    life_side_exp   = 1000000000;  // owner 2026-06-24: keep max XP (-> capped MAX talent points, no grind) but DROP the all-talent auto-grant so players build + respec their own via the restored Talents menu.
    life_gang_exp   = 1000000000;};
__SETCONST__(life_medicLevel, _medicLevel);
life_gear = _this select 6;
// LooneyBin: never let a nil gear element UNDEFINE life_gear (SQF: `x = nil` deletes x). A nil here
// made fn_loadGear strip the player then error before re-dressing -> permanently naked. Default to
// [] so loadGear falls back to the side's default loadout (which then saves valid gear).
if (isNil "life_gear" || {!(life_gear isEqualType [])}) then { life_gear = []; };
life_gear_cache = life_gear;
// LooneyBin: restore saved licenses. Server sends them at index 32 from the side's <side>_licenses
// column; each entry is [full-var-name, bool] e.g. ["license_civ_home", true]. licenseCfg already
// defaulted them all to false during init, so this overwrites with the persisted values.
{ if (_x isEqualType [] && {count _x >= 2}) then { missionNamespace setVariable [_x select 0, _x select 1]; }; } forEach (_this param [32, []]);
life_lastSync_gear = format["%1", life_gear];
[] call life_fnc_stripDownPlayer;
[] call life_fnc_loadGear;
// owner 2026-06-14 (#184): re-apply invisible backpack after (re)connect. plb_invisBag persists in profileNamespace,
// but the pack OBJECT is rebuilt on login -> re-empty its texture once the loadout's backpack exists (short delay =
// addBackpack settled). (2026-07-06: was hideObjectGlobal -> now empty-texture, see fn_invisBag.)
if (profileNamespace getVariable ["plb_invisBag", false]) then {[] spawn { uiSleep 2; [true] call life_fnc_invisBag; };};
[] call life_fnc_calTalents; {_x params["_varName", "_defaultVars"];
    if (((profileNameSpace getVariable[_varName, _defaultVars]) param[0, 0]) != PLB_instance_id) then {
        profileNameSpace setVariable[_varName, _defaultVars];};}
forEach[["plb_recent_revive", [0, 0]], ["plb_recent_organ", [0, 0]], ["plb_recent_scalp", [0, 0]], ["plb_killCache", [0, []]], ["plb_recent_spray", [0, 0]], ["plb_lastbh_dropped", [0, 0]], ["plb_cellphone_bomb", [0, objNull, -1]], ["plb_cellphone_enginekillswitch", [0, objNull, -1]], ["plb_lastgov_message", [0, 0]]];
private _remoteExplosive = (profileNameSpace getVariable["plb_cellphone_bomb", [0, objNull, -1]]);
life_remoteExplosive = +[vehicles param[vehicles findIf {
    (_remoteExplosive param[2, -1]) isEqualTo(_x getVariable["plb_dbInfo", ["", 0]] param[1, 0])
}, objNull], _remoteExplosive param[2, -1]];
private _remoteEngineKillSwitch = (profileNameSpace getVariable["plb_cellphone_enginekillswitch", [0, objNull, -1]]);
life_engineKillSwitch = +[vehicles param[vehicles findIf {
    (_remoteEngineKillSwitch param[2, -1]) isEqualTo(_x getVariable["plb_dbInfo", ["", 0]] param[1, 0])
}, objNull], _remoteEngineKillSwitch param[2, -1]];
// LooneyBin 2026-07-16: BUYABLE TALENT POINTS -- pull the purchased count once the session is up (server
// answers via life_fnc_talentPointsRecv, which re-runs calTalents). Fire-and-forget; default 0 until it lands.
[] spawn { uiSleep 4; [["load"], "TON_fnc_talentPointsSRV", 2] spawn life_fnc_MP; };
life_session_completed = true;
