
// LooneyBin 2026-07-16: HEADLESS CLIENT EXCLUSION. allPlayers INCLUDES the connected headless client, and on
// this box getPlayerUID(HC) returns "HC50998" (non-empty), so the usual `getPlayerUID != ""` filter lets it
// leak into player-processing (proven: it was accruing houses.tax_playtime as owner 'HC50998'). Real Steam64s
// are digits only. PLB_fnc_realPlayers = allPlayers minus anything without an all-numeric UID (the HC, plus any
// not-yet-authed client). Use at every AGGREGATE site (pop counts, online-UID lists) so the HC never counts as
// a civ. Point lookups (findIf UID==target) already never match the HC, so they don't need it.
PLB_fnc_realPlayers = {allPlayers select {private _u = getPlayerUID _x;
        (_u isNotEqualTo "") && { (toArray _u) findIf { _x < 48 || _x > 57 } isEqualTo -1 }}};
// LooneyBin 2026-07-16 (HC-incident fix): AUTHORITATIVE headless-client presence. PLB_hcOwner is the "HC online"
// signal Loonazon keys off (no HC -> "on strike" message, no delivery). The HC self-announces it, but an
// UNGRACEFUL drop (crash / hard kill) leaves it stale, and the HandleDisconnect EH can lag a 30s timeout. This
// loop is the source of truth: every 15s it sets PLB_hcOwner to the connected HeadlessClient's owner id, or 0 if
// none. Cheap; never touches the mission. (PLB_UsingHeadless is NOT set anymore -- it armed the legacy
// endMission-on-HC-drop path that booted the whole server.)
if (isNil "PLB_hcOwner") then { PLB_hcOwner = 0; publicVariable "PLB_hcOwner"; };
[] spawn {while {true} do {uiSleep 15;
        private _hc = (allPlayers select { (typeOf _x) isEqualTo "HeadlessClient_F" }) param [0, objNull];
        private _o = if (isNull _hc) then { 0 } else { owner _hc };
        if (_o isNotEqualTo PLB_hcOwner) then { PLB_hcOwner = _o; publicVariable "PLB_hcOwner"; };};};
server_query_running = false;
life_DB_queue = [];
life_item_pickups = [];
serv_sv_use = [];

call compile preprocessFileLineNumbers "\life_server\vars.sqf";

// singleevh.md Phase 1 — install the single-wheel task scheduler API (server-only). Idempotent install;
// PLB_fnc_schedulerStart is called AFTER the migration sites register their jobs. Each job used to be
// registered behind an `if (PLB_useScheduler)` gate with the pre-migration loop in the else; that flag and
// all 24 legacy else bodies were removed 2026-07-24 (live since 2026-07-05, fallback never once executed).
call PLB_fnc_scheduler;
call PLB_fnc_schedulerStart;   // starts the wheel; jobs registered later in init are picked up live

if (!isServer) then { [] execVM "\life_server\eventhandlers.sqf"; };
// LooneyBin: server_init.sqf was a DEAD FILE — execVM'd nowhere — so the ONLY HandleDisconnect EH in
// the codebase was never registered (disconnected players left a corpse at your feet, no final flush)
// AND the server-side eventhandlers.sqf (serv_* PV handlers) never loaded. Merge gap: the 2017 server
// init was never wired into LooneyBin's init.sqf. Run it on the server now (after vars.sqf, before READY).
if (isServer) then { [] execVM "\life_server\server_init.sqf"; };

_extDB = false;

if(isNil {uiNamespace getVariable "life_sql_id"}) then {life_sql_id = round(random(9999));
uiNamespace setVariable ["life_sql_id",life_sql_id];

// --- extDB3 migration (LooneyBin) -----------------------------------------
// extDB3 raw-SQL: ADD_DATABASE + ADD_DATABASE_PROTOCOL:<db>:SQL:<id>: then
// query via "<mode>:<id>:<sql>" and read with "4:<key>" (see fn_asyncQuery).
_result = "extDB3" callExtension "9:VERSION";
diag_log format ["extDB3: Version: %1", _result];
if(_result == "") exitWith {diag_log "extDB3: Extension not loaded (check @extDB3 mod + extDB3 in serverMod)";};

_result = "extDB3" callExtension format["9:ADD_DATABASE:%1","Database"];
if(_result != "[1]") exitWith {diag_log "extDB3: Error with Database Connection (check extdb3-conf.ini [Database] block)";};
_result = "extDB3" callExtension format["9:ADD_DATABASE_PROTOCOL:%1:SQL:%2:","Database",life_sql_id];
if(_result != "[1]") exitWith {diag_log "extDB3: Error adding SQL protocol";};
"extDB3" callExtension "9:LOCK";
_extDB = true;
diag_log "extDB3: Connected to Database";} else {life_sql_id = uiNamespace getVariable "life_sql_id";
_extDB = true;
diag_log "extDB: Still Connected to Database";};

if (!_extDB) exitWith {life_server_extDB_notLoaded = true;
publicVariable "life_server_extDB_notLoaded";
diag_log "extDB: Error checked extDB/logs for more info";};

// extDB3 raw: stored procedures must exist in the DB (see sql/looneybin_schema.sql TODO: procs)
if (worldName == "Australia") then { ["CALL resetAusVehicles();",1] call DB_fnc_asyncQuery; }
else { ["CALL resetLifeVehicles();",1] call DB_fnc_asyncQuery; };
["CALL updateLifeHouses();",1] call DB_fnc_asyncQuery;

[] call DB_fnc_queryConfig;
// owner 2026-06-13: legacy PLB_fnc_govMaint (5-day positional life_configuration election) REMOVED -- it
// fought the new 7-day case system (different state vars = conflicting governors). govSystemSRV "reload"
// below is now the sole governor authority (seats from gov_state, runs the 7-day term timer).
["load"] call TON_fnc_economySRV;   // LooneyBin Economy: load owner price overrides -> PLB_priceOv
["load"] call TON_fnc_atmSkimSRV;   // LooneyBin 2026-07-16: restore ATM skimmers onto the ATM objects (self-delays 20s for mapData)
["reload"] call TON_fnc_govSystemSRV;   // owner 2026-06-13: seat governor from gov_state, rebuild race, arm 7-day term timer
[] spawn { uiSleep 15; ["boot"] call TON_fnc_sportsbookResolve; };   // LoonyBets sportsbook: open markets + deadline watcher
// owner 2026-06-24: load the NAMED-FORESKIN registry (foreskins table) -> PLB_foreskinReg, broadcast to all clients so
// any held/traded foreskin renders "<name>'s Foreskin". Must exist BEFORE players load their gear (fn_loadGear grants
// foreskin_<uid> via handleInv, which needs virtItemCfg to know the item). Boot-time, server is the sole writer.
PLB_foreskinReg = [];
// QUOTE both cols: DB_fnc_asyncQuery mode 2 `call compile`s the result, so a bare varchar (name="Unknown"/
// "retro") is read as an UNDEFINED VARIABLE -> the whole result fails to compile -> "0 names" + boot error spam.
// QUOTE(name) makes it a string literal; QUOTE(uid) keeps the Steam64 exact (a bareword digit run -> lossy float).
private _fsRows = [format ["SELECT QUOTE(uid),QUOTE(name) FROM foreskins"], 2] call DB_fnc_asyncQuery;
if (!isNil "_fsRows" && {_fsRows isEqualType []}) then {{
        if (_x isEqualType [] && {count _x >= 2}) then { PLB_foreskinReg pushBack [format ["%1", _x select 0], format ["%1", _x select 1]]; };
    } forEach _fsRows;};
publicVariable "PLB_foreskinReg";
diag_log format ["[LooneyBin][foreskin] registry loaded: %1 names", count PLB_foreskinReg];
// owner 2026-06-18: restore STIMMY CHECKS from server_control.stimmy (single row id=1) so the 10x cartel stimulus
// survives reboots. fn_cartelSRV reads PLB_stimmy to multiply the cartel-owner payout; the admin-menu indicator
// reflects it; CLANKR reads the same DB flag to stay quiet about the conjured cash while it's on.
PLB_stimmy = (parseNumber format ["%1", (["SELECT stimmy FROM server_control WHERE id=1", 2] call DB_fnc_asyncQuery) select 0]) > 0;
publicVariable "PLB_stimmy";
// weed.md: wall-clock reference for the house-weed grow timer (nowUnix = PLB_bootUnix + serverTime). Set ONCE
// at boot from the DB; serverTime counts real seconds from mission start, so the sum tracks wall clock across
// the session. Stage = floor((nowUnix - plantedUnix)/3600) -> purely timestamp-driven, restart-proof.
// owner 2026-06-15 (#248): SUBTRACT a fixed epoch. SQF numbers are single-precision floats -- a raw unix
// timestamp (~1.75e9) has a ULP of ~128, so `PLB_bootUnix + serverTime` SWALLOWED the per-second serverTime
// increments and `str` save/load of plantedUnix lost precision -> plants "stuck" / never advanced. Working in
// (unix - 1.7e9) keeps values ~5e7 (ULP ~4s), so hour-granularity growth + the DB round-trip are exact enough.
// (Old crops stored against the raw timestamp read as age<0 -> reset to Seed and grow from now -- acceptable.)
PLB_GH_EPOCH = 1700000000;
PLB_bootUnix = (parseNumber format ["%1", (["SELECT UNIX_TIMESTAMP()", 2] call DB_fnc_asyncQuery) select 0]) - PLB_GH_EPOCH;
publicVariable "PLB_bootUnix";
[] spawn { uiSleep 20; ["reload"] call TON_fnc_greenhouseSRV; };   // restore greenhouse crops after houses + buildings exist
[] spawn { uiSleep 20; ["reload"] call TON_fnc_barrelSRV; };
[] spawn { uiSleep 22; ["reload"] call TON_fnc_miningSRV; };   // owner 2026-07-15: restore house mining rigs       // owner 2026-06-21: restore spirit-barrel crops the same way (after houses exist)
[] spawn { uiSleep 25; ["presenceStart"] call TON_fnc_shedHelipadSRV; };
// LooneyBin (owner 2026-07-15): loonstreets.com feed -- refresh the gang leaderboard publicVar every 5 min.
[] spawn { uiSleep 45; while { true } do { [] call TON_fnc_loonstreetsSRV; uiSleep 300; }; };
[] spawn { uiSleep 30; while { true } do { [] call TON_fnc_bonesDeliver; uiSleep 8; }; };   // owner 2026-07-15: deliver Ben Bones AI replies
// LooneyBin (owner 2026-07-15): PUBLIC rebel weapon airdrops -- every 45-90 min, only when 4+ players are on.
[] spawn {uiSleep 600;   // never within 10 min of a restart
    while { true } do {uiSleep (2700 + random 2700);
        if ((count call PLB_fnc_realPlayers) >= 4) then { ["drop"] call TON_fnc_airdropEventSRV; };};
};   // owner 2026-07-15: REBUILD bought helipads at boot (after replace_sheds +6s). This call was never wired -> "helipads don't persist": pads spawned on buy, houses.helipad=1 was written, and nothing ever re-spawned them after a restart.
// LooneyBin (owner 2026-07-17): HOURLY SUPPLY BOMBER -- every ~hour, fly the WEST or EAST hand-drawn route and drop
// ONE sealed crate (10-min lock -> unlock + fill; drop site is a redzone; Ben Bones texts everyone). Plane has no
// map marker. On the single-wheel scheduler (singleevh). Pop-gated like the rebel airdrop; SRV self-picks the route.
["supplyBomberHourly", {params ["_st"];
    if ((count call PLB_fnc_realPlayers) < 4) exitWith {};
    [[]] spawn TON_fnc_eventSupplyBomberSRV;   // [] -> SRV self-selects WEST/EAST; detached so the job returns fast
}, 3600, false, true] call PLB_fnc_schedule;
// (apStress dev-trigger removed 2026-07-18 -- was spamming the dev server during rig testing)
// owner 2026-06-17: self-heal the single gangfort row. The pre-launch DB wipe (2026-06-12) dropped the id=1 row,
// so EVERY `UPDATE gangfort ... WHERE id=1` (event start, score persist, load, auto-scheduler) silently updated
// ZERO rows -> fort state never persisted across a reboot + last_auto never stuck. Idempotently re-seed it on
// boot so a fresh/wiped DB always has the row to write into. (mode 1 fire-and-forget; lands long before the +18s load.)
["INSERT IGNORE INTO gangfort (id) VALUES (1)"] call DB_fnc_asyncQuery;
[] spawn { uiSleep 18; ["load"] call TON_fnc_gangFortressSRV; };   // restore Gang Fortress event/ownership (needs the flag object placed first)
// owner 2026-06-17: AUTO-START the Gang Fortress every WEDNESDAY and SUNDAY at 5pm CENTRAL (wall-clock). The hour
// + weekday come from CONVERT_TZ(..,'America/Chicago') so they track WALL-CLOCK Central and are DST-aware -- the
// box/DB run UTC but Chicago is UTC-5 (CDT) in summer and UTC-6 (CST) in winter, so a FIXED offset would fire an
// hour off for half the year. (Verified live: tz tables loaded -> Central hr=17, DAYOFWEEK=4 at 5:47pm CDT Wed.)
// DAYOFWEEK: 1=Sun .. 7=Sat, so Sun=1, Wed=4. The now/last/ends values stay raw unix (used only for time DELTAS,
// which are timezone-independent). Gates (ALL must hold to fire):
//   * not already running (SRV_gangFortressActive)            -- don't stack a 2nd event
//   * dow in [1,4] and hr == 17                               -- Sun/Wed 5pm Central window (whole hour, so a delayed poll still catches it)
//   * (now - last_auto) > 12h                                 -- de-dupe: after the first fire last_auto=now, the 60s poll can't re-fire this hour
//   * ends <= now - 600                                       -- skip if an event (manual or auto) just ended/was scheduled past this minute (kills a manual-start bleeding across :00)
// singleevh.md Phase 1c: gangfort auto-start poll migrated onto the single-wheel scheduler (id
// "gangfortAuto", 60s). The one-shot boot settle (uiSleep 55, so the fort object is loaded via the +18s
// ["load"] before an auto-start can fire) runs on the FIRST fire only; the poll itself is DB-driven
// de-dupe (last_auto + 12h gate) so it holds no cross-iteration local. Flag OFF => the original loop runs
// byte-for-byte (else branch) = ZERO behavior change.
["gangfortAuto", {params ["_st"];
    if !(_st getOrDefault ["init", false]) then { uiSleep 55; _st set ["init", true]; };   // let the fort load before an auto-start can fire
    if !(missionNamespace getVariable ["SRV_gangFortressActive", false]) then {
        private _q = ["SELECT HOUR(CONVERT_TZ(UTC_TIMESTAMP(),'+00:00','America/Chicago')), DAYOFWEEK(CONVERT_TZ(UTC_TIMESTAMP(),'+00:00','America/Chicago')), UNIX_TIMESTAMP(), last_auto, ends FROM gangfort WHERE id=1", 2] call DB_fnc_asyncQuery;
        if (_q isEqualType [] && {count _q >= 5}) then {private _hr   = parseNumber format ["%1", _q select 0];
            private _dow  = parseNumber format ["%1", _q select 1];
            private _now  = parseNumber format ["%1", _q select 2];
            private _last = parseNumber format ["%1", _q select 3];
            private _ends = parseNumber format ["%1", _q select 4];
            if ((_dow in [1,4]) && {_hr isEqualTo 17} && {(_now - _last) > 43200} && {_ends <= (_now - 600)}) then {
                [format ["UPDATE gangfort SET last_auto=%1 WHERE id=1", _now]] call DB_fnc_asyncQuery;
                ["start"] call TON_fnc_gangFortressSRV;
                diag_log format ["[LooneyBin][gangfort] AUTO-STARTED (Wed/Sun 5pm CST) dow=%1 hr=%2 now=%3", _dow, _hr, _now];};};};
}, 60, false, true] call PLB_fnc_schedule;

if(!hasInterface) then {};

// owner 2026-06-18 (#335): GANG-VEHICLE garage hygiene at boot. (1) DEDUPE -- fn_gangGarageStore used to INSERT a
// fresh row on every store WITHOUT clearing the old active='1' row, so each pull->store left a zombie duplicate
// (one plate had 4 rows). Keep only the newest row per (gang_id, plate). (2) UNIQUE key so the store's new UPSERT
// (ON DUPLICATE KEY UPDATE) folds into that one row instead of dup'ing. (3) GARAGE-RETURN -- a hard restart wipes
// the world object and fn_restoreVehicles only relinks PERSONAL-table plates, so an OUT gang vehicle used to POOF
// (gone from world + stuck active='1', which the pull menu (active='0') hides). Reset every active='1' back to '0'
// so they return to the gang garage (re-pullable) instead of being lost. Order matters: dedupe (blocking) must
// finish before ADD UNIQUE, else the ALTER fails on the existing dupes -> no key -> upsert can't de-dup. Respawn-
// at-position is a logged follow-up (needs the fragile vehicle_mem restore to learn gang plates + gang-key relink).
[] spawn {uiSleep 8;
    ["DELETE gv FROM gang_vehicles gv JOIN (SELECT gang_id, plate, MAX(id) AS keep_id FROM gang_vehicles GROUP BY gang_id, plate) m ON gv.gang_id=m.gang_id AND gv.plate=m.plate AND gv.id < m.keep_id", 2] call DB_fnc_asyncQuery;
    ["ALTER TABLE gang_vehicles ADD UNIQUE KEY IF NOT EXISTS uq_gang_plate (gang_id, plate)", 2] call DB_fnc_asyncQuery;
    ["UPDATE gang_vehicles SET active='0' WHERE active='1'"] call DB_fnc_asyncQuery;
    diag_log "[LooneyBin][gangveh] boot hygiene done: deduped + unique key + garage-returned out vehicles";};

life_fnc_wantedAdd = compileFinal PreprocessFileLineNumbers "\life_server\wanted_add.sqf";
life_fnc_wantedRemove = compileFinal PreprocessFileLineNumbers "\life_server\wanted_remove.sqf";
life_group_list = [];
publicVariable "life_group_list";

// LooneyBin: 2020 client reads these server->client globals during init (gov/weather/events/HUD);
// the 2017-derived server never set them -> "Undefined variable" spam + glitchy HUD on spawn.
// Publish inert defaults so client init runs clean (real feature logic can populate later).
// PLB_instance_id: per-boot session token. Client compares it to DB-stored session ids to detect
// server restarts (gov elections/pardons, quest loot) and uses it as a
// profileNamespace key element. Never set on this server -> nil -> govSystem _serverRestarted /
// _newElection threw. Make it a unique string each boot, broadcast to clients.
PLB_instance_id = round(diag_tickTime * 1000) + floor(random 99999);
publicVariable "PLB_instance_id";
SRV_governorData = [];                 publicVariable "SRV_governorData";
SRV_houseOnFire = [];                  publicVariable "SRV_houseOnFire";
SRV_wcWeather = [0,0,0,0];             publicVariable "SRV_wcWeather";
SRV_ufoCrash = [false,objNull,-99999,[]];  publicVariable "SRV_ufoCrash";  // [active(Bool),obj,crashTime,data]; idx0 read as Bool by fn_initCiv:166 + fn_ufoCrash (was objNull -> "Type Object expected Bool" on every connect)
SRV_winterEvent = [objNull,-99999];    publicVariable "SRV_winterEvent";   // fn_inventoryOpened santa-loot check reads select 1 (timestamp); was undefined
SRV_enabledSeasonalEvents = [];        publicVariable "SRV_enabledSeasonalEvents";
// life_seasonalEvent: client (initPlayerLocal:190) does `if (life_seasonalEvent select 1)` (Bool
// enabled-flag) then `switch (life_seasonalEvent select 2)` (event-name String). Empty [] -> select 1
// nil -> threw at spawn. Default [_, enabled=false, name=""] so the seasonal block skips clean.
life_seasonalEvent = [false,false,""];  publicVariable "life_seasonalEvent";
life_topWealth = [];                   publicVariable "life_topWealth";
life_topDonor = [];                    publicVariable "life_topDonor";
life_radio_civ = radioChannelCreate [[0, 0.95, 1, 0.8], "Side Channel", "%UNIT_NAME", []];                   
publicVariable "life_radio_civ";
// life_radio_med: cop/medic side radio. manageSidechat evaluates `else {life_radio_med}` for any
// non-civ BEFORE the west early-exit, so cops hit "undefined life_radio_med" without this default.
life_radio_med = "";                   publicVariable "life_radio_med";
life_allPointsBulletin = [];           publicVariable "life_allPointsBulletin";
// More server->client globals the 2020 client reads during side-init / EHs. Inert-but-typed
// defaults so client code doing `select N` / `param[N]` on them can't throw and hang init.
// SRV_mobileHQ: client does `SRV_mobileHQ param[1,objNull]` (HQ truck) + `select 3`; needs >=4 elems.
// SRV_mobileHQ: client param[1] = HQ truck; client "setupShops" reads `select 3` as
// [level, gearNPC, vehicleNPC] then derefs each -> index 3 must be a 3-array, not objNull.
// index 2 = ACTIVE bool: the "Setup Mobile HQ" addAction condition does `!(SRV_mobileHQ select 2)` -- the old
// objNull there threw "Type Object, expected Bool" every frame (CLANKR flagged the burst). Match fn_srvMobileHQ
// ([setupTime, truck, activeBool, [level,gearNPC,vehNPC]]): time number @0, false @2.
SRV_mobileHQ = [-1800,objNull,false,[0,objNull,objNull]];  publicVariable "SRV_mobileHQ";
// SRV_gangBoatFortressData: client does `!(... select 0)` / `if (... select 0)` -> select 0 = Bool.
SRV_gangBoatFortressData = [false,[],[]];                publicVariable "SRV_gangBoatFortressData";
// SRV_duelArenaData + randomized_life_group_list: NEVER initialized -> onPlayerKilled (death) threw
// "Undefined variable" on both BEFORE the DeathScreen dialog + doRespawn ran -> with respawnDelay=0 the
// player dropped straight to the missing respawn_west marker = debug island (no revive/medic screen).
// onPlayerKilled reads SRV_duelArenaData select 0/1/2/3/5; group list is a gang array (set by lock/unlockGroup).
SRV_duelArenaData = [false,-1800,"","",objNull,[0,0]]; publicVariable "SRV_duelArenaData";
randomized_life_group_list = [];                       publicVariable "randomized_life_group_list";
// life_adminEvent: client does `if (life_adminEvent select 2 != 5) exitWith{}` + `select 3`; >=4 elems,
// select 2 != 5 so the admin-event display path early-exits cleanly until a real event broadcasts.
life_adminEvent = [false,0,0,0];                         publicVariable "life_adminEvent";  // [0]=Bool (onPlayerKilled does `select 0 && ...`); [2]=mode number
// LooneyBin (#41 ROOT): these were only ever pushBack/set on-demand, so on a fresh boot they are
// UNDEFINED on clients -> fn_spawnPointCfg lines 44-45 throw -> spawn list build breaks -> debug island.
if (isNil "SRV_diedInGangFort") then { SRV_diedInGangFort = []; }; publicVariable "SRV_diedInGangFort";
// BUGS.md #98: boot shape was [false,false] (2 elems) but the client drill gate reads `select 6`
// (cops required) -> out-of-range error silently killed "Start Drilling Door". Full 7-slot shape per
// fn_jewelryEmporiumSRV: [lastBreach, active, safeDrilled, safeWelded, casesLootable, 0, copsRequired].
if (isNil "SRV_jewelryEmporiumSRV") then { SRV_jewelryEmporiumSRV = [-1800, false, false, false, false, 0, 6]; }; publicVariable "SRV_jewelryEmporiumSRV";
// LooneyBin batch-2 federal/event state (2026-06-09):
// SRV_evidence_status = [hasEvidence, defensesUp, unused, lastAttackTime, copsRequired] (evidence lockup)
SRV_evidence_status = [false, true, 0, -1800, 2];      publicVariable "SRV_evidence_status";
SRV_evidencePool = []; SRV_evidenceWeps = [];
SRV_lastMedSupply = -900;                              publicVariable "SRV_lastMedSupply";   // medDrop item 15-min global cooldown
// SRV_loonyBinData = [lastBreach, breached, 0, keycode, tombLocked, remainsObj, copsRequired] (the namesake heist)
// owner 2026-06-18: copsRequired = 0 -- TEST setting so the breach can be triggered solo (intended live value = 2).
// REVERT before public -- tracked in launch.md.
SRV_loonyBinData = [-2700, false, 0, "", true, objNull, 0];   publicVariable "SRV_loonyBinData";
// Restart cycle (2026-06-09): serverStartTime/serverCycleLength/serverRestartLock were NEVER defined,
// so every restart-aware feature was dead (anywhere-jail near restart, shop/tax restart locks,
// fn_notifyServerRestart) and clients reading the bare serverRestartLock script-errored. The actual
// restart is still done by the host/loonybot (!srv hardr) -- this just drives the in-game countdown QoL.
serverStartTime  = serverTime;                       publicVariable "serverStartTime";
PLB_restartPeriod = 4 * 3600;   // owner 2026-06-13: AUTO-RESTART every 4 HOURS, ALWAYS HARD (graceful save -> restart_watchdog). The 2h soft cycle was removed.
serverCycleLength = missionNamespace getVariable ["PLB_restartPeriod", 4 * 3600];  publicVariable "serverCycleLength";
serverRestartLock = false;                           publicVariable "serverRestartLock";
// SRV_convoy_status = [active, lastAttack, level, copsExtra] (Altis Shipping convoy robbery)
SRV_convoy_status = [false, -1800, 0, 0];            publicVariable "SRV_convoy_status";
life_event_queue = [];   // admin-event participants (TON_fnc_eventParticipants/PLB_fnc_addToEvent -- was never initialized)
// owner 2026-06-17 (#330): REMOVED the per-boot `DELETE FROM votes`. The rebuilt 7-day-term gov system
// (govSystemSRV) PERSISTS votes across restarts -- "reload" rebuilds the candidate tallies from this table,
// and votes are cleared ONLY when a governor is SEATED (PLB_fnc_govSeat = a new term). Wiping every boot meant
// votes never survived a restart -> "voted yesterday, 0 votes today" (#330). The one-vote-per-election gate is
// per-TERM (cleared at govSeat), not per-session.
SRV_prisonData = [-1800, false];   publicVariable "SRV_prisonData";   // [lastBreak, active] -- was NEVER defined; clients read slot 1 (jailMe / doPrisonBreak / activeFederalEvent)

// LooneyBin (owner, 2026-06-11): MAX-VERBOSITY logging. Global flag any future verbose gate can read, + a
// server-side ScriptError handler so EVERY script error on the server (mission + @life_server) is dumped to
// console.log with its full callstack (tagged [LB-SCRIPTERR]). Returns false -> engine still logs normally.
PLB_verboseLog = true; publicVariable "PLB_verboseLog";
addMissionEventHandler ["ScriptError", { diag_log format ["[LB-SCRIPTERR][server] %1", _this]; false }];

// LooneyBin (owner, 2026-06-11): alert EVERY online APD officer with the "Federal Event" admin-style popup
// (+ audible ping) whenever ANY federal event STARTS -- bank, fed reserve, evidence lockup, PRISON BREAK,
// convoy, Loony Bin, jewelry. The federaleventcop message style existed in fn_handleMessage but was wired to
// nothing. Single server-side edge-detector: same active predicates fn_activeFederalEvent uses; fires once on
// each event's false->true transition. nil-safe reads so var-load order/timing can't break it.
// singleevh.md Phase 1b: fed-event -> APD alert edge-detector migrated onto the single-wheel scheduler
// (id "fedAlert", 5s). Cross-iteration state (the _events config + the _prev false->true edge tracker) lives
// in the per-job _st; the one-shot boot settle (uiSleep 30 + seed _prev with current state) runs on the first
// fire only. Flag OFF => the original loop runs byte-for-byte (else branch) = ZERO behavior change.
["fedAlert", {params ["_st"];
    if !(_st getOrDefault ["init", false]) then {
        uiSleep 30;   // let event vars + clients settle after boot (and don't alert for state that was already live)
        private _events = [
            ["Federal Reserve robbery",   { ((missionNamespace getVariable ["life_fed_robbed", [false]]) param [0, false]) }, "fed",      { getMarkerPos "fed_reserve" }],
            ["Bank robbery",              { ((missionNamespace getVariable ["life_bank_robbed", [false]]) param [0, false]) }, "bank",     { getMarkerPos "life_bank_door" }],
            ["Evidence Lockup raid",      { !((missionNamespace getVariable ["SRV_evidence_status", [false, true]]) param [1, true]) }, "evidence", { [20898.6, 19221.7, 0] }],
            ["Prison Break",              { ((missionNamespace getVariable ["SRV_prisonData", [0, false]]) param [1, false]) }, ""],
            ["Prisoner Transport convoy", { ((missionNamespace getVariable ["SRV_convoy_status", [false]]) param [0, false]) }, "shipping", { [] }],
            ["Loony Bin breach",          { ((missionNamespace getVariable ["SRV_loonyBinData", [0, false]]) param [1, false]) }, "loonybin", { [24096.3, 15532.6, 0] }],
            ["Jewelry Emporium robbery",  { ((missionNamespace getVariable ["SRV_jewelryEmporiumSRV", [0, false]]) param [1, false]) }, "jewelry",  { [20720, 16620, 0] }]
        ];
        _st set ["events", _events];
        _st set ["prev", _events apply { call (_x select 1) }];   // seed with current state -> no spam for events already active at boot
        _st set ["init", true];};
    private _events = _st getOrDefault ["events", []];
    private _prev   = _st getOrDefault ["prev", []]; {private _active = call (_x select 1);
        if (_active && {!(_prev select _forEachIndex)}) then {
            // admin-style "Federal Event" popup + ping to every online APD officer (side west)
            [[(_x select 0), "federaleventcop"], "life_fnc_handleMessage", west, false, false] spawn life_fnc_MP;
            if ((_x param [2, ""]) isNotEqualTo "") then { ["open", _x param [2, ""]] call TON_fnc_sportsbookResolve; };   // LoonyBets: heist market opens
            // owner 2026-07-18: the standalone mining-component crate is RETIRED -- components now spawn
            // INSIDE each heist's own loot (loonyBin gold case / fed + bank cash case / jewelry display case).
            ["-FEDALERT-", objNull, format ["APD alerted: %1 started", (_x select 0)]] call PLB_fnc_logIt;};
        _prev set [_forEachIndex, _active];} forEach _events;}, 5, false, true] call PLB_fnc_schedule;

[] spawn {
    // owner 2026-06-13: AUTO-RESTART scheduler (every serverCycleLength = 2h). Countdown is delivered as
    // admin-message BOXES (TON_fnc_adminMsg -> clientMessage type 5 "adminall" = the phone-admin box + sound).
    // DEFAULT = SOFT restart: instance 1 -> "#restart" (players bounced to lobby, mission reloads, NO forced
    // disconnect). If server_control.hard_pending=1 (operator staged fixes that need a fresh PBO) -> HARD:
    // flag restart_now=1 so the external restart_watchdog relaunches the PROCESS. Every restart is logged to
    // restart_log (powers the owner-connect tally / until-10am count). Self-heals: if no restart lands within
    // 3 min past T-0 (watchdog down / endMission no-op), clear the lock + extend a cycle so features don't freeze.
    private _pnum = { parseNumber (format ["%1", _this]) };
    private _offsets = [[3600, "1 Hour until RESTART (full rejoin)"], [1800, "30 Minutes Till RESTART (full rejoin)"],
        [900,  "15 minutes till RESTART (full rejoin)"], [600,  "10 minutes till RESTART (full rejoin)"],
        [300,  "5 minutes till RESTART -- SYNC NOW"], [120,  "2 minutes until RESTART -- SYNC NOW"],
        [60,   "1 minute until RESTART (you should have synced)"]];
    private _sent = [];
    private _fired = false;
    while {true} do {uiSleep 15;
        private _left = serverCycleLength - (serverTime - serverStartTime);
        // T-5 feature lock + the press-Y SYNC DATA client prompt
        if (_left <= 300 && {!serverRestartLock}) then {serverRestartLock = true; publicVariable "serverRestartLock";
            [[], "life_fnc_notifyServerRestart", -2, true, false] spawn life_fnc_MP;}; {_x params ["_off", "_msg"];
            if (_left <= _off && {!(_off in _sent)}) then {_sent pushBack _off;
                ["SERVER RESTART", _msg] call TON_fnc_adminMsg;};} forEach _offsets;
        // uptime guard (owner 2026-06-14): never fire a restart in the first 20 min of uptime. Defense against
        // a premature T-0 if serverTime/serverStartTime are ever off at boot -- the restart only runs once the
        // server has genuinely been up a while, so it can't "restart right after the warning" on a fresh boot.
        if (_left <= 0 && {!_fired} && {(serverTime - serverStartTime) > 1200}) then {_fired = true;
            // owner 2026-06-13: ALWAYS HARD now (the 2h soft/endMission cycle was removed). GRACEFUL SAVE first
            // (vehicle_mem incl. plb_vinv trunks + flushAllPlayers + storage), let the writes flush, THEN hand
            // to the restart_watchdog (server_control.restart_now=1 -> it pkills + run-boot2 = fresh process).
            // owner 2026-06-18: hard_pending=0 here -> the watchdog reloads the DEPLOYED PBOs as-is (NO_REPACK,
            // no code deploy). Staged source only goes live via the in-game UPDATE button or a manual run-boot2.
            // owner 2026-06-19 (kit-loss-on-restart cluster #408/#409/#413/#414/#416/#417/#418): FORCE every online
            // client to flush gear+position+money NOW, before the snapshot. saveVehicles -> flushAllPlayers only
            // DRAINS already-queued writes (life_update_buffer); it does NOT snapshot live client state, so a player
            // whose last auto-save predated the restart reverted on rejoin (= "lost my kit" / respawn menu). Clupdate-
            // Request is the full client save; the server is CfgRE-exempt so this server->client MP runs (same path as
            // the T-55 notifyServerRestart sync, just guaranteed here for late-joiners + anyone the countdown missed).
            [[], "life_fnc_ClupdateRequest", -2, false, false] spawn life_fnc_MP;
            uiSleep 8;   // let the client row-writes land before the vehicle snapshot + watchdog handoff
            private _h = [] spawn DB_fnc_saveVehicles;
            waitUntil { scriptDone _h };
            uiSleep 35;   // let extDB3 commit the async save queue before the watchdog kills the process
            ["INSERT INTO restart_log (mode) VALUES ('hard')"] call DB_fnc_asyncQuery;
            ["UPDATE server_control SET restart_now=1, hard_pending=0 WHERE id=1"] call DB_fnc_asyncQuery;
            ["SERVER RESTART", "Restarting now -- rejoin from the server browser in ~60s."] call TON_fnc_adminMsg;
            diag_log "[LooneyBin][autorestart] 4h HARD restart -> saved + restart_watchdog relaunches the process";};
        if (_fired && {_left <= -180}) then {
            // SAFETY NET: 3 min past T-0 and the process never relaunched -> the restart_watchdog didn't act
            // (it's down, or busy). Re-assert restart_now=1, clear the lock + extend ONE cycle so nothing stays
            // frozen, and re-arm the countdown so the NEXT cycle tries again (rather than hanging forever).
            ["UPDATE server_control SET restart_now=1 WHERE id=1"] call DB_fnc_asyncQuery;
            serverRestartLock = false; publicVariable "serverRestartLock";
            serverCycleLength = serverCycleLength + PLB_restartPeriod; publicVariable "serverCycleLength";
            _sent = []; _fired = false;
            ["SERVER", "Restart is taking a moment -- standby."] call TON_fnc_adminMsg;
            diag_log "[LooneyBin][autorestart] watchdog didn't relaunch within 3min -> re-asserted restart_now=1 (lock cleared, cycle extended)";
        };};};
// owner 2026-06-19 (persistence cluster #335/#274/#319/#192/#190): PERIODIC vehicle save. The graceful save
// only ran on a SCHEDULED restart -- manual hard restarts (deploys, !srv hardr, a raw restart_now=1) and
// crashes pkilled the process with NO save, losing every spawned/left-out vehicle. Snapshot vehicle_mem every
// 8 min so the world survives any ungraceful exit (lose <=8 min, not everything). Lightweight: _vehiclesOnly
// skips the heavy player/storage/gang flush. Pairs with fn_restoreVehicles no longer wiping vehicle_mem.
// singleevh.md Phase 1c: periodic vehicle-save migrated onto the single-wheel scheduler (id "vehSave",
// 480s). The one-shot boot settle (uiSleep 300, so saveVehicles never snapshots a half-restored world --
// saveVehicles DELETEs then re-fills vehicle_mem, so an early snapshot could wipe it) runs on the FIRST
// fire only; the periodic body keeps its own blocking DB saveVehicles/updateCaptures. Flag OFF => the
// original loop runs byte-for-byte (else branch) = ZERO behavior change.
["vehSave", {params ["_st"];
    if !(_st getOrDefault ["init", false]) then { uiSleep 300; _st set ["init", true]; };   // let the boot restore settle before the first snapshot
    if (!life_server_training) then {[true] call DB_fnc_saveVehicles;
        [] call DB_fnc_updateCaptures;   // #368: persist cartel/turf ownership changes too (was graceful-restart-only)
    };}, 480, false, true] call PLB_fnc_schedule;

// Ambient earthquakes (2026-06-09): wires the dormant life_fnc_earthquakeClient. Rare flavor event --
// every 2-4 h a light-to-moderate quake centered on a random land position.
[] spawn {while {true} do {uiSleep (7200 + random 7200);
        private _center = [random worldSize, random worldSize, 0];
        if (!surfaceIsWater _center) then {private _mag = selectRandom [1, 1, 2];
            [[_mag, _center], "life_fnc_earthquakeClient", -2, false, false] spawn life_fnc_MP;
            diag_log format ["[LooneyBin] ambient earthquake mag %1 at %2", _mag, _center];};};};
// evidence laptop: nothing in the mission defines the global `evidenceLaptop` -> find or create it at
// the lockup so the whole evidence chain (hack/repair/cop-redeploy) has its object, and publish for JIP.
[] spawn {uiSleep 20;
    private _domePos = [20898.6, 19221.7, 0];
    private _laptop = nearestObject [_domePos, "Land_Laptop_unfolded_F"];
    if (isNull _laptop || {_laptop distance2D _domePos > 60}) then {_laptop = "Land_Laptop_unfolded_F" createVehicle _domePos;
        _laptop setPosATL [20893.5, 19224.0, 0];
        _laptop allowDamage false;};
    _laptop setVariable ["plb_laptopstatus", 1, true];
    missionNamespace setVariable ["evidenceLaptop", _laptop, true];
    diag_log format ["[LooneyBin][evidence] laptop published at %1", getPosATL _laptop];
    // lock the lockup dome at boot -- nothing else seals door 3 until a cop "secures" mid-event,
    // so after every restart the evidence dome stood open to anyone
    private _dome = nearestObject [_domePos, "Land_Dome_Big_F"];
    if (!isNull _dome) then {_dome setVariable ["plb_bombPlanted", false, true];
        _dome setVariable ["plb_evidenceOpen", false, true];
        _dome setVariable ["plb_vaultBreached", false, true];
        _dome setVariable ["bis_disabled_Door_3", 1, true];
        _dome animate ["door_3_rot", 0];
        diag_log "[LooneyBin][evidence] dome sealed at boot";};};
// house furniture: presence-spawn manager -- only spawns a house's furniture while the homeowner (or, for a
// gang house, any gang member) is online; despawns when nobody's home. Runs after the gang re-tag below so
// buildings already carry plb_house_gang.
[] spawn {uiSleep 32;
    ["presenceStart"] call TON_fnc_houseFurnitureSRV;};
// gang houses: re-tag each persisted gang building (gangs.house_pos) with plb_house_gang so members'
// initGang (which waits on that var) finds it after every restart. Houses are objects by ~20s.
[] spawn {uiSleep 25;
    private _rows = ["SELECT id, QUOTE(house_pos) FROM gangs WHERE house_pos IS NOT NULL", 2, true] call DB_fnc_asyncQuery;
    if !(_rows isEqualType []) exitWith {}; {private _gid = _x param [0, -1];
        private _pos = parseSimpleArray format ["%1", _x param [1, "[]"]];
        if (_pos isEqualType [] && {count _pos >= 2}) then {
            // owner 2026-06-14 (#208): nearestBuilding (ANY building type) instead of nearestObjects["House_F"].
            // An industrial SHED gang-HQ (Land_i_Shed_Ind_F) is NOT isKindOf "House_F", so the old filter never
            // tagged shed HQs -> shed gang buildings gave members no keys/marker/spawn/pull. Distance-gate so a
            // deleted HQ can't tag a random nearby structure.
            private _b = nearestBuilding _pos;
            if (!isNull _b && {(_b distance _pos) < 14}) then {_b setVariable ["plb_house_gang", _gid, true];} else {
                diag_log format ["[LooneyBin][gangHouse] no building at %1 for gang %2", _pos, _gid];};};} forEach _rows;
    diag_log format ["[LooneyBin][gangHouse] re-tagged %1 gang building(s)", count _rows];};
// house tax (2026-06-09): tag every owned house with plb_house_tax = [overdue, canPayTax, playtime(min),
// lastPayed(days)] (all the client tax menu reads), then +5 playtime per 5 min while the owner is online.
// Pay/reset handled by TON_fnc_houseTaxSRV. Overdue threshold = 14 days unpaid.
// singleevh.md Phase 1c: house-tax tagger migrated onto the single-wheel scheduler (id "houseTax", 300s).
// The closures (_decKeys / _tagHouses) are redefined each fire -- pure code with no captured mutable state,
// so this is behaviorally identical. The one-shot boot setup (uiSleep 30 settle so buildings have streamed,
// then the ALTER TABLE + the first tag pass) runs on the FIRST fire only via exitWith; every later fire does
// the +5 playtime UPDATE + a re-tag. _tagHouses calls _decKeys, both privates of the SAME callback scope
// (the exact call-scope sharing the original relied on). Flag OFF => the original loop runs byte-for-byte
// (else branch) = ZERO behavior change.
["houseTax", {params ["_st"];
// decode an mres-encoded keyholders blob the same way fn_receiveHouses does
private _decKeys = {params [["_v", "", [""]]];
    if (_v isEqualTo "" || {_v isEqualTo "NULL"}) exitWith {[]};
    private _a = [_v] call DB_fnc_mresToArray;
    if (typeName _a == "STRING") then { _a = parseSimpleArray (format ["%1", _a]); };
    if (isNil "_a" || {!(_a isEqualType [])}) then { _a = []; };
    _a};
private _tagHouses = {
    // owner 2026-06-20 (mres decode spam -- 76 errors/5min): keyholders is an mres/str2-encoded blob whose
    // OWN outer double-quotes are the string delimiters asyncQuery's call-compile consumes (the project RULE,
    // see fn_queryRequest:56-58). QUOTE()-ing it added a SECOND quote layer -> mresToArray got `"[[``...``]]"`
    // with literal outer quotes -> its inner `call compile` went nil -> "Undefined variable: _array" x76 every
    // 5-min tag pass AND the keyholder list never decoded -> shared-house keys never restored after a restart
    // (#307). fn_receiveHouses reads keyholders BARE (fn_queryHouses:15) and decodes fine with 0 errors -> match
    // it exactly: bare column, no QUOTE/COALESCE (the _decKeys guard already handles ""/"NULL").
    // owner 2026-07-04: classname MUST be QUOTE()'d. extDB3 returns varchars BARE and DB_fnc_asyncQuery
    // call-compiles the whole result string, so an unquoted `Land_u_Shed_Ind_F` compiled as an UNDEFINED
    // VARIABLE -> that result slot nil'd -> _x param [7,""] fell back to "" for EVERY shed row -> _dbCls=""
    // -> _isShedRow=false -> the entire shed-resolution branch below was DEAD (the b0125 fix never ran).
    // Same footgun the code documents at fn_getVehicles (QUOTE(classname) / QUOTE(COALESCE(mods,'[]'))).
    // keyholders stays BARE on purpose -- it is an mres blob that carries its own quotes (see line ~466).
    private _rows = ["SELECT id, QUOTE(worldspace), tax_playtime, COALESCE(DATEDIFF(NOW(), tax_paid), 0), QUOTE(owners), QUOTE(oid), keyholders, QUOTE(COALESCE(classname,'')), vcap, phys_cap, keycap, barrel, greenhouse, leadcontainer, locked FROM houses", 2, true] call DB_fnc_asyncQuery;
    if !(_rows isEqualType []) exitWith { 0 };
    private _n = 0; {private _ws = parseSimpleArray format ["%1", _x param [1, "[]"]];
        if (_ws isEqualType [] && {count _ws >= 2}) then {
            // owner 2026-07-04: resolve the House_F whose TYPE matches the DB classname (param 7), not just
            // the nearest. Some worldspaces have MULTIPLE House_F -- most notably a buyable industrial shed
            // (Land_i_Shed_Ind_F, createVehicle'd by replace_sheds) whose spot ALSO holds the banished derelict
            // Land_u_Shed_Ind_F. A bare `param [0]` grabbed the wrong one, so the owned shed never got
            // plb_homeOwner -> "buy your own shed" while inventory (keyed on plb_house_keys / life_vehicles)
            // still worked. Fall back to the nearest House_F for old rows with no stored classname.
            private _dbCls = format ["%1", _x param [7, ""]];
            // owner 2026-07-04: SHED rows are special. The derelict Land_u_Shed_Ind_F lingers at every buyable
            // shed spot (terrain object -- can't be deleted, hideObjectGlobal only hides it, setPos won't move
            // a static map object), so a bought shed's worldspace sits ON the hidden derelict while the intact,
            // createVehicle'd Land_i_Shed_Ind_F stands at the SAME spot (both House_F, both dist 0). A plain
            // nearest-House_F grab is a coin-flip that keeps landing on the derelict. For a shed row, resolve
            // the intact by its EXACT class (NOT a "House_F" filter -- Land_i_Shed_Ind_F is not reliably
            // isKindOf "House_F" per the gang-tagger #208 note above) and force the classname write to intact so
            // the DB self-heals (683/684/685/686/689/692). Never tag/write the derelict for a shed row.
            private _isShedRow = (_dbCls isEqualTo "Land_i_Shed_Ind_F") || (_dbCls isEqualTo "Land_u_Shed_Ind_F");
            private _cands = nearestObjects [_ws, ["House_F"], 10];
            private _b = objNull;
            if (_isShedRow) then {_b = (nearestObjects [_ws, ["Land_i_Shed_Ind_F"], 18]) param [0, objNull];
                if (!isNull _b) then { _dbCls = "Land_i_Shed_Ind_F"; };} else {
                if (_dbCls isNotEqualTo "" && {_dbCls isNotEqualTo "NULL"}) then {
                    _b = (_cands select { (typeOf _x) isEqualTo _dbCls }) param [0, objNull];};
                if (isNull _b) then { _b = _cands param [0, objNull]; };};
            if (!isNull _b) then {private _pt   = parseNumber format ["%1", _x param [2, 0]];
                private _days = parseNumber format ["%1", _x param [3, 0]];
                _b setVariable ["plb_house_tax", [_days > 14, _days >= 1, _pt, _days], true];
                // owner 2026-06-16 (#305/#307/#310): fn_receiveHouses tags house OWNERSHIP/ID/KEYS at boot, but it
                // resolves the building with nearestObjects and the map buildings stream in ~20s AFTER it runs ->
                // it tagged nothing -> plb_homeOwner="" (gang houses died for members whenever the owner was
                // offline, #305/#310) AND plb_houseID=-1 so fn_bldgUpdateKeys SKIPPED its `WHERE oid=...` write
                // -> given house keys NEVER persisted (#307; keyholders column was NULL for every row). This loop
                // runs at +30s (buildings loaded), so re-establish the identity tags (keyed on `oid`, exactly
                // like fn_receiveHouses) + restore the keyholder list. owner/oid don't change in-session; keys
                // come straight from the DB (bldgUpdateKeys writes them immediately) so re-reading stays correct.
                private _oid = format ["%1", _x param [5, ""]];
                private _own = format ["%1", _x param [4, ""]];
                if (_own isNotEqualTo "" && {_own isNotEqualTo "NULL"}) then {_b setVariable ["plb_homeOwner", _own, true];
                    // owner 2026-06-20: a registered house sitting within 10m of a shop NPC was getting wrongly
                    // flagged plb_restricted_house=true by fn_shops' nearest-building grab (before/around this
                    // tagging), killing the owner's House Menu + grab-ID. Clear it on every owned house here (this
                    // loop re-runs every 5min, so it also self-heals an early-connect race). Shops aren't in the
                    // `houses` table so their flag is never touched. Pairs with the fn_shops/fn_copShops fix.
                    _b setVariable ["plb_restricted_house", false, true];};
                if (_oid isNotEqualTo "" && {_oid isNotEqualTo "NULL"}) then {_b setVariable ["plb_houseID", _oid, true];
                    _b setVariable ["plb_buildID", _oid, true];
                    _b setVariable ["houseId", _oid, true];};
                // owner 2026-06-21 (Latoya IRS bot): persist the house TYPE so the offline Discord tax bot can
                // compute exact upkeep (the houses table only stored worldspace). Write only when missing/changed.
                if (_oid isNotEqualTo "" && {_oid isNotEqualTo "NULL"}) then {private _cls = typeOf _b;
                    if (_cls isNotEqualTo "" && {(format ["%1", _x param [7, ""]]) isNotEqualTo _cls}) then {
                        [format ["UPDATE houses SET classname='%1' WHERE oid='%2'", _cls, _oid]] call DB_fnc_asyncQuery;};};
                private _kh = [format ["%1", _x param [6, ""]]] call _decKeys;
                if (_kh isEqualType [] && {count _kh > 0}) then {_b setVariable ["plb_house_keys", _kh, true];};
                // owner 2026-07-06: SHED 100-CAP FIX. fn_receiveHouses (the only boot cap-restorer) resolves houses
                // via nearestObjects["House_F"] at init, but buyable sheds are createVehicle'd ~6s LATER
                // (replace_sheds) so the intact shed doesn't exist yet -> its plb_vcap/phys_cap/keycap/upgrade-flags
                // are never stamped -> reads fall to the 100 fallback + fn_upgradeProperty treats the NIL cap as
                // maxed and refuses to expand. This loop runs at +30s (after the shed exists) + already re-resolves
                // the intact shed, so restore the storage state receiveHouses missed (mirrors fn_receiveHouses:49-54).
                // Self-heals ANY house the boot race skipped, sheds included. The DB row still holds the correct
                // values (fn_addHouse INSERT + fn_upgradeProperty writes) -> no data loss; affected sheds heal next restart.
                private _shedVcap = parseNumber format ["%1", _x param [8, -1]];   // guard NULL/empty -> don't zero the cap
                if (_shedVcap > 0) then { _b setVariable ["plb_vcap", _shedVcap, true]; };
                private _shedPcap = parseNumber format ["%1", _x param [9, -1]];
                if (_shedPcap > 0) then { _b setVariable ["plb_phys_cap", _shedPcap, true]; };
                _b setVariable ["plb_keycap",               parseNumber format ["%1", _x param [10, 0]],   true];
                _b setVariable ["plb_barrel_unaged",        (parseNumber format ["%1", _x param [11, 0]]) isEqualTo 1, true];
                _b setVariable ["plb_greenhouse_unaged",    (parseNumber format ["%1", _x param [12, 0]]) isEqualTo 1, true];
                _b setVariable ["plb_leadcontainer_unaged", (parseNumber format ["%1", _x param [13, 0]]) isEqualTo 1, true];
                _b setVariable ["plb_locked",               (parseNumber format ["%1", _x param [14, 0]]) isEqualTo 1, true];
                _n = _n + 1;};};} forEach _rows;
    _n};
    if !(_st getOrDefault ["init", false]) exitWith {uiSleep 30;
        // owner 2026-06-21 (Latoya IRS bot): ensure the classname column exists (idempotent) before the tag loop writes
        // house types into it. Additive nullable column -> safe for the live extDB3 named-column house INSERTs.
        ["ALTER TABLE houses ADD COLUMN IF NOT EXISTS classname VARCHAR(64) DEFAULT NULL"] call DB_fnc_asyncQuery;
        private _n = call _tagHouses;
        diag_log format ["[LooneyBin][houseTax] tagged %1 house(s)", _n];
        _st set ["init", true];};
    private _uids = (call PLB_fnc_realPlayers) apply { format ["'%1'", getPlayerUID _x] };
    if !(_uids isEqualTo []) then {
        ["UPDATE houses SET tax_playtime = tax_playtime + 5 WHERE owners IN (" + (_uids joinString ",") + ")"] call DB_fnc_asyncQuery;};
    call _tagHouses;   // refresh the client-visible tax vars (cheap: one SELECT + setVariables)
}, 300, false, true] call PLB_fnc_schedule;
life_wanted_list = [];
client_session_list = [];

[] spawn {private["_logic","_queue","_chopOptions","_vehClass"];
while {true} do {

life_chopVehicle = [];
_chopOptions = ["C_Hatchback_01_F","C_Hatchback_01_F","C_Offroad_01_F","C_SUV_01_F","C_Hatchback_01_sport_F","C_Van_01_transport_F","B_G_Offroad_01_F","I_Truck_02_transport_F","I_Truck_02_covered_F","B_Truck_01_transport_F","B_Truck_01_box_F","B_Truck_01_box_F","B_Truck_01_box_F"];
for "_i" from 1 to 3 do {while {true} do {_vehClass = _chopOptions call BIS_fnc_selectRandom;
if (!(_vehClass in life_chopVehicle)) exitWith { life_chopVehicle pushBack _vehClass; };};};
publicVariable "life_chopVehicle";

sleep (30 * 60);

_logic = missionnamespace getvariable ["bis_functions_mainscope",objnull];
_queue = _logic getvariable "life_fnc_MP_queue";
_logic setVariable["life_fnc_MP_queue",[],TRUE];

// LooneyBin 2026-07-18: dead 2017 group-race event DISABLED (owner "leave it dead"; superseded by the
// time-trial system). PLB_fnc_initEvent teleported queued players onto a race grid into fuel-less cars and
// then called the stubbed life_fnc_joinRace -> nothing happened. Worse, it did `life_event_queue = []`, which
// could clobber the LIVE admin-event participant queue (GunGame/Graveyard/etc. share that var). Trigger removed
// -> no more phantom event window / grid teleport. fn_initEvent + joinRace/finishRace/startRace/raceWon are now
// unreferenced inert dead code (safe to delete later).
};};

[] spawn {if (worldName == "Stratis") then { life_restart_delay = 6000; };

[] spawn {private ["_rand","_max"];
_max = life_restart_delay;
_rand = floor random (_max * 2);
if (_rand < _max) then {sleep _rand;
_rand = ceil random 4;
[[_rand],"BIS_fnc_earthquake",true,false] spawn life_fnc_MP;
sleep 12;
[[[0,1],format["A factor %1 earthquake has been detected on the island of %2.",_rand,worldName]],"life_fnc_broadcast",true,false] spawn life_fnc_MP;
};};

[] spawn {while {true} do {_max = life_restart_delay * 0.5;
_rand = floor random (_max - 300);
if (_rand < 960) then { _rand = 960; };
sleep _rand;
_largest = [nil,nil,nil,0,nil]; {if (_x select 3 > _largest select 3 && !((_x select 1) in life_past_APB)) then {_wanted = _x;
_online = false;
{ if (_wanted select 1 == getPlayerUID _x && side _x == civilian && !(_x getVariable ["prisoner",false])) then { _online = true; } } forEach allPlayers;
if (_online) then {	_largest = _x; };};} forEach life_wanted_list;
if (_largest select 3 > 0) then {life_allpoints = [_largest select 0, _largest select 1, _largest select 3];
life_past_APB pushBack (_largest select 1);
publicVariable "life_allpoints";
[] spawn {sleep 900;
if (count life_allpoints > 0) then {[[life_allpoints select 1],"life_fnc_removeBounty",west,false] spawn life_fnc_MP;
_online = objNull;
{ if (life_allpoints select 1 == getPlayerUID _x) then { _online = _x; } } forEach allPlayers;
if (!isNull _online) then { [[6,1],"life_fnc_addStatistic",_online,false] spawn life_fnc_MP; };
life_allpoints = [];
publicVariable "life_allpoints";};};};};};};

fnc_serv_kick = {endMission "loser";};
publicVariable "fnc_serv_kick";

[] spawn PLB_fnc_queryHouses;
[] spawn PLB_fnc_queryGangs;
[] spawn DB_fnc_queryCaptures;

// LooneyBin TEST: load the new-player role-grant toggle from config (index 200). Default ON; the Owner
// phone button persists OFF here via REPLACE. fn_queryRequest reads SRV_grantNewbieRoles for new players.
// >>> LAUNCH (launch.md #2, 2026-06-13): default DISABLED for public. config[200] also set to 0 in DB.
SRV_grantNewbieRoles = false;
// >>> LAUNCH HARDENING (launch.md #1 god-stats, #2b zero-cop federal events): toggles OFF for public.
PLB_betaMaxStats = false; publicVariable "PLB_betaMaxStats";
PLB_betaZeroCops = false; publicVariable "PLB_betaZeroCops";
// owner 2026-06-19: restore FED OVERRIDE (server_control.fedoverride) so a persisted owner toggle survives reboots.
// ON -> re-assert the cop-requirement waiver (PLB_betaZeroCops) + restart the cooldown-clear loop. Placed AFTER the
// betaZeroCops=false above so the override wins. (Loop zeroes cooldown TIMESTAMPS only -- never active-robbery flags.)
PLB_fedOverride = (parseNumber format ["%1", (["SELECT fedoverride FROM server_control WHERE id=1", 2] call DB_fnc_asyncQuery) select 0]) > 0;
publicVariable "PLB_fedOverride";
if (PLB_fedOverride) then {PLB_betaZeroCops = true; publicVariable "PLB_betaZeroCops";
    // singleevh.md Phase 1b: fed-override cooldown-clear migrated onto the single-wheel scheduler (id
    // "fedOverrideClear", 4s). Conditional-while (`while { PLB_fedOverride }`) -> registered ONLY here, where
    // the override activates (mirrors the original spawn site), and self-exits + unschedules the instant the
    // override is turned off (so !srv resetfed / a manual toggle stops it exactly like the old loop's while
    // predicate did). Flag OFF => the original loop runs byte-for-byte (else branch) = ZERO behavior change.
    ["fedOverrideClear", {params ["_st"];
        if !(missionNamespace getVariable ["PLB_fedOverride", false]) exitWith { ["fedOverrideClear"] call PLB_fnc_unschedule; };
        if (!isNil "SRV_lastRobbery" && {SRV_lastRobbery != -99999}) then { SRV_lastRobbery = -99999; publicVariable "SRV_lastRobbery"; };
        if (!isNil "life_fed_robbed"  && {(life_fed_robbed  param [1, 0]) != -99999}) then { life_fed_robbed  set [1, -99999]; publicVariable "life_fed_robbed"; };
        if (!isNil "life_bank_robbed" && {(life_bank_robbed param [1, 0]) != -99999}) then { life_bank_robbed set [1, -99999]; publicVariable "life_bank_robbed"; };
        if (!isNil "SRV_loonyBinData" && {(SRV_loonyBinData param [0, 0]) != -99999}) then { SRV_loonyBinData set [0, -99999]; publicVariable "SRV_loonyBinData"; };
    }, 4, false, true] call PLB_fnc_schedule;};
// owner 2026-06-22 (#496 anti soft-log heist gate): the heist cop-count gates (bank/jewelry/fed) counted a raw
// `west countSide allPlayers` snapshot, so a gang could flip whitelisted members to cop side, instantly satisfy
// the requirement (e.g. 4 for the bank), start the robbery, then switch right back to civ. Track each cop's
// CONTINUOUS time on west side and count only cops on-duty >= PLB_copTenureReq toward a heist requirement -> a
// just-switched soft-logger contributes 0 until they've actually served. PLB_copDutySince = [[uid, joinTime], ...],
// maintained by the loop below (stamp newcomers to west, drop anyone who left west so their tenure restarts on return).
PLB_copTenureReq = 300;        // seconds continuously on cop side before a cop counts toward a heist requirement
PLB_copDutySince = [];
PLB_fnc_tenuredCops = {params [["_wantList", false]];
    private _now = diag_tickTime;
    private _units = []; {private _u = _x;   // capture unit -- the nested findIf below rebinds _x to a [uid,time] pair
        if ((side _u) isEqualTo west) then {private _uid = getPlayerUID _u;
            private _ix = PLB_copDutySince findIf { (_x select 0) isEqualTo _uid };
            if (_ix > -1 && {(_now - ((PLB_copDutySince select _ix) select 1)) >= PLB_copTenureReq}) then { _units pushBack _u; };};
    } forEach allPlayers;
    if (_wantList) then { _units } else { count _units }};
// singleevh.md Phase 1b: cop duty-tenure tracker migrated onto the single-wheel scheduler (id "copTenure",
// 20s). Body is self-contained -- all privates (_now/_westUids/_u/_uid) declared inside it, only GLOBAL
// PLB_copDutySince mutated. Flag OFF => original loop runs byte-for-byte (else branch) = ZERO behavior change.
["copTenure", {private _now = diag_tickTime;
    private _westUids = []; {private _u = _x;   // capture unit -- nested findIf rebinds _x to a [uid,time] pair
        if ((side _u) isEqualTo west) then {private _uid = getPlayerUID _u;
            if (_uid != "") then {_westUids pushBack _uid;
                if ((PLB_copDutySince findIf { (_x select 0) isEqualTo _uid }) isEqualTo -1) then {PLB_copDutySince pushBack [_uid, _now];
                };};};} forEach allPlayers;
    PLB_copDutySince = PLB_copDutySince select { (_x select 0) in _westUids };}, 20, false, true] call PLB_fnc_schedule;
[] spawn {private _row = [format ["SELECT value FROM config WHERE `index`=200"], 2] call DB_fnc_asyncQuery;
    if (!isNil "_row" && {!(_row isEqualTo [])}) then {SRV_grantNewbieRoles = ((format ["%1", _row select 0]) != "0");};
    publicVariable "SRV_grantNewbieRoles";};

publicVariable "PLB_fnc_addVehicle2Chain";
publicVariable "PLB_fnc_experienceReq";

[] spawn DB_fnc_queryStock;
[] spawn PLB_fnc_marketTick;   // LooneyBin dynamic-market engine (autonomous drift + events)

[] spawn {private ["_toCap","_capIndex","_turf","_delay","_started","_winSecs"];
_toCap = [0,1,2]; private _flags = [rodo_flag, zaros_flag, panagia_flag]; private _flagNames = ["rodo_flag","zaros_flag","panagia_flag"];
_delay = (life_restart_delay / (count life_turf_list)) - (life_restart_delay / (life_restart_delay / 1000));
diag_log format ["[LooneyBin][turf] scheduler START -- delay=%1s, window=900s, turfs=%2 (restart_delay=%3)", round _delay, count life_turf_list, life_restart_delay];   // owner 2026-06-20: the turf system had ZERO logging, so "check the logs for why turfs aren't popping" was impossible. Instrument START + each activation/deactivation.
// owner 2026-06-20: SELF-HEAL the single-row turf_state (id=1). The row was WIPED (launch wipe / a migration) leaving
// the table EMPTY -> the resume SELECT below returned nothing AND every `UPDATE ... WHERE id=1` no-op'd, so the active
// turf + remaining window NEVER persisted across a restart (same single-row footgun as gang_fortress). Without resume,
// EVERY restart/crash/deploy restarts the 33-min first-pop countdown from scratch (with frequent restarts -> turfs
// rarely survive to activation). INSERT IGNORE re-creates the row without clobbering a real mid-cycle saved state.
["INSERT IGNORE INTO turf_state (id, active_idx, ends) VALUES (1, -1, 0)"] call DB_fnc_asyncQuery;
// LooneyBin (owner 2026-06-11): persist the ACTIVE turf + remaining window across reboot. If a turf
// was mid-capture at shutdown, resume the same one for the time left instead of restarting the rotation.
private _nowUnix = { parseNumber format ["%1", (["SELECT UNIX_TIMESTAMP()", 2] call DB_fnc_asyncQuery) param [0, 0]] };
private _resumeIdx = -1; private _resumeSecs = 0;
private _tsRow = ["SELECT active_idx, ends FROM turf_state WHERE id=1", 2, true] call DB_fnc_asyncQuery;
if (_tsRow isEqualType [] && {count _tsRow > 0}) then {private _ai = parseNumber format ["%1", (_tsRow select 0) param [0, -1]];
    private _en = parseNumber format ["%1", (_tsRow select 0) param [1, 0]];
    if (_ai in [0,1,2] && {_en > (call _nowUnix) + 20}) then { _resumeIdx = _ai; _resumeSecs = _en - (call _nowUnix); };};
while {true} do {if (_toCap isEqualTo []) then { _toCap = [0,1,2]; };
_winSecs = 900;
if (_resumeIdx isNotEqualTo -1) then {
    _capIndex = _resumeIdx; _winSecs = _resumeSecs; _resumeIdx = -1;   // one-shot resume of the saved turf
    _toCap = _toCap - [_capIndex];
    diag_log format ["[LooneyBin][turf] resumed active turf %1, %2s left", _capIndex, _winSecs];} else {sleep _delay;
[] spawn PLB_fnc_reduceMarket;
_capIndex = _toCap call BIS_fnc_selectRandom;
_toCap = _toCap - [_capIndex];};
_turf = life_turf_list select _capIndex;
life_active_turf = _capIndex;
publicVariable "life_active_turf";
diag_log format ["[LooneyBin][turf] ACTIVATED turf %1 (%2) for %3s -- area+label markers RED, flag plb_turf_data active", _capIndex, (_turf select 0), round _winSecs];   // owner 2026-06-20: turf instrumentation
_marker = format["turf_label_%1", _flagNames select _capIndex];
_marker setMarkerColor "ColorRed";
(format["turf_area_%1", _flagNames select _capIndex]) setMarkerColor "ColorRed";
private _fd = (_flags select _capIndex) getVariable ["plb_turf_data", [-1,"Unknown",false,"Unknown"]]; _fd set [2, true]; (_flags select _capIndex) setVariable ["plb_turf_data", _fd, true];
life_turf_captor = [];
publicVariable "life_turf_captor";
[format ["UPDATE turf_state SET active_idx=%1, ends=%2 WHERE id=1", _capIndex, (call _nowUnix) + _winSecs]] call DB_fnc_asyncQuery;
// owner 2026-06-24 (#501, model B = RECAP-ON-RED): this turf just went ACTIVE (red) -> the previous owner LOSES it.
// Drop it to neutral/Contested + PERSIST the wipe, so everyone (incl. the old owner) must RE-CAPTURE it this window. A
// held turf still survives a RESTART while it's NOT red (queryCaptures restores it); it's only cleared here, when its
// own cycle comes up. If nobody recaptures before the window ends it stays neutral -- you must defend to keep it. The
// window-end block below re-commits + saves the new captor (or leaves it neutral). Persisting the wipe means a restart
// during/after the red window can't resurrect the old owner.
_turf set [1, "0"]; _turf set [2, "Contested"];
life_turf_list set [_capIndex, _turf];
publicVariable "life_turf_list";
[] spawn DB_fnc_updateTurf;
diag_log format ["[LooneyBin][turf] RECAP-ON-RED: turf %1 (%2) went active -> owner cleared, up for grabs", _capIndex, (_turf select 0)];
_started = time;
waitUntil { (time - _started) > _winSecs };
["UPDATE turf_state SET active_idx=-1, ends=0 WHERE id=1"] call DB_fnc_asyncQuery;
life_active_turf = -1;
publicVariable "life_active_turf";
diag_log format ["[LooneyBin][turf] window ENDED for turf %1 (%2) -- captor=%3", _capIndex, (_turf select 0), (if (count life_turf_captor > 0) then { life_turf_captor select 0 } else { "none (uncaptured)" })];   // owner 2026-06-20: turf instrumentation
_marker setMarkerColor "ColorUNKNOWN";
(format["turf_area_%1", _flagNames select _capIndex]) setMarkerColor "ColorUNKNOWN";
private _fd2 = (_flags select _capIndex) getVariable ["plb_turf_data", [-1,"Unknown",false,"Unknown"]]; _fd2 set [2, false]; (_flags select _capIndex) setVariable ["plb_turf_data", _fd2, true];
_benefits = switch (_capIndex) do {case 0: { "double gathering speed of most drugs" };
case 1: { "increased gas station robbery and chop shop payouts" };
case 2: { "reduced material cost at the black market" };};
if (count life_turf_captor > 0) then {_pdist = if (worldName == "Stratis") then { 700 } else { 2000 };
_members = []; { if (_x getVariable ["gang","0"] == (life_turf_captor select 2) && (getMarkerPos _marker) distance _x < _pdist) then { _members pushBack _x; }} forEach allPlayers;
if (count _members > 5) exitWith {{
[[1, format["<t color='#ff0000'><t size='2'><t align='center'>Gang Turf<br/><br/><t size='1'><t color='#ffffff'>The gang turf of <t color='#ff0000'>%1</t> failed to be taken by your gang due to too many gang members in the region!", _turf select 0]],"life_fnc_broadcast",_unit,false] spawn life_fnc_MP;
} forEach _members;};
_turf set [1, life_turf_captor select 2];
_turf set [2, life_turf_captor select 1];
life_turf_list set [_capIndex, _turf];
publicVariable "life_turf_list";
_owned = 0; { if (_x select 1 == life_turf_captor select 2) then { _owned = _owned + 1 } } forEach life_turf_list;
if (_owned > 1) then { _benefits = _benefits + " as well as reduced weapon prices for holding multiple turf areas"; };
[[1, format["<t color='#ff0000'><t size='2'><t align='center'>Gang Turf<br/><br/><t size='1'><t color='#ffffff'>The gang turf of <t color='#ff0000'>%1</t> was captured by %2 for <t color='#ff0000'>%3</t>! Gang benefits are %4.", _turf select 0, life_turf_captor select 0, life_turf_captor select 1, _benefits]],"life_fnc_broadcast",_unit,false] spawn life_fnc_MP;
[] spawn DB_fnc_updateTurf;
 {[[2,3],"life_fnc_addStatistic",_x,false] spawn life_fnc_MP;} forEach _members;};};};

[] spawn {private ["_query"];
_query = format["SELECT QUOTE(p.`name`) FROM `%1` as p LEFT JOIN `players_global` as g ON p.playerid=g.playerid AND g.`wealth` > 0 AND g.`adminlevel` = '0' AND p.`lastupdated` > DATE_SUB(NOW(), INTERVAL 2 WEEK) ORDER BY g.`wealth` DESC LIMIT 10", srv_table_players];  // LooneyBin: QUOTE name -- unquoted names with spaces (e.g. "player107 Fire") broke call-compile of the result -> empty top-wealth board
life_topWealth = [_query,2,true] call DB_fnc_asyncQuery;};

[] spawn PLB_fnc_monitorCaptures;

// LooneyBin FED RESERVE LOCKDOWN (2026-06-09 rework): nothing at the fed was ever locked at boot --
// every dome door, inner safe building and gate sat freely usable. Lock the lot:
//   domes (Land_Dome_Big/Small_F): every door disabled + shut, plb_vaultlocked 1 (break-in = fn_openVault
//   60s side-door action; unlock-all on success = the big vehicle door only opens AFTER the side door),
//   inner safe buildings (Land_Research_*): doors disabled + shut (drill 60s / demo via fn_openSafe),
//   gates (Land_BarGate_F): shut, gate_max 0 (30s boltcut that CONSUMES the cutter).
[] spawn {uiSleep 12;
    private _fed = getMarkerPos "fed_reserve";
    if (_fed isEqualTo [0,0,0]) exitWith { diag_log "[LooneyBin][fed] fed_reserve marker missing -- lockdown skipped"; };
    private _domes = nearestObjects [_fed, ["Land_Dome_Big_F", "Land_Dome_Small_F"], 400]; {private _d = _x;
        private _n = getNumber (configFile >> "CfgVehicles" >> (typeOf _d) >> "numberOfDoors");
        for "_i" from 1 to _n do { _d setVariable [format ["bis_disabled_door_%1", _i], 1, true]; };
        { _d animate [_x, 0, true]; } forEach (animationNames _d);
        _d setVariable ["plb_vaultlocked", 1, true];
        _d setVariable ["plb_goldSpawned", false, true];
        diag_log format ["[LooneyBin][fed] dome %1 @ %2: %3 doors disabled, anims %4", typeOf _d, getPosATL _d, _n, count (animationNames _d)];
    } forEach _domes;
    missionNamespace setVariable ["PLB_fedComponentSpawned", false, true];   // re-arm the mining-component drop
    private _safes = nearestObjects [_fed, ["Land_Research_house_V1_F", "Land_Research_HQ_F"], 400]; {private _s = _x;
        private _n = getNumber (configFile >> "CfgVehicles" >> (typeOf _s) >> "numberOfDoors");
        for "_i" from 1 to _n do { _s setVariable [format ["bis_disabled_door_%1", _i], 1, true]; };
        { _s animate [_x, 0, true]; } forEach (animationNames _s);
        _s setVariable ["plb_vaultlocked", 1, true];} forEach _safes;
    private _gates = nearestObjects [_fed, ["Land_BarGate_F"], 400]; {_x setVariable ["gate_max", 0, true];
        _x setVariable ["bis_disabled_Door_1", 1, true];
        _x animateSource ["door_1_sound_source", 0];
        diag_log format ["[LooneyBin][fed] gate @ %1 locked (phase %2)", getPosATL _x, _x animationSourcePhase "door_1_sound_source"];
    } forEach _gates;
    // fn_fedAlarm's end-of-robbery relock iterates the LEGACY globals (life_bank_gates/vaults/safes)
    // and the older init block waitUntils on them -- nothing ever defined them in this build
    // ("Undefined variable life_bank_gates", fn_fedAlarm line 90). Publish the lockdown's object sets.
    life_bank_gates  = _gates;
    life_bank_vaults = _domes;
    life_bank_safes  = _safes;
    // v4 HARD ENFORCER: Land_BarGate_F's engine open action does NOT reliably respect bis_disabled_Door_1
    // (the "gates still not locked" report) -> force any uncut gate (gate_max 0) shut every 3s. The
    // boltcut sets gate_max -> the enforcer leaves it alone from then on.
    // singleevh.md Phase 1b: fed gate re-lock enforcer migrated onto the single-wheel scheduler (id
    // "fedGateRelock", 3s). The captured spawn-arg _gates is recomputed from the global life_bank_gates
    // (set === _gates immediately above), so the callback needs no closure capture. Registered here inside
    // the boot lockdown routine, mirroring the original nested spawn site (only runs if the fed marker
    // existed). Flag OFF => the original nested loop runs byte-for-byte (else branch) = ZERO behavior change.
    ["fedGateRelock", {params ["_st"];
        private _gates = missionNamespace getVariable ["life_bank_gates", []]; {
            if (((_x getVariable ["gate_max", 0]) isEqualTo 0) && {(_x animationSourcePhase "door_1_sound_source") > 0.05}) then {
                _x animateSource ["door_1_sound_source", 0];};} forEach _gates;}, 3, false, true] call PLB_fnc_schedule;

    // deer stands around the fed kept spawning as ruins -- repair + damage-proof them at boot
    // (terrain deer stands are nearestTerrainObjects type "HIDE")
    // repair EVERYTHING that spawns broken near the fed (deer stands etc.) -- and LOG each model name
    // so we learn what they are + what keeps killing them. Runs again at +60s to catch late destroyers.
    private _repairBroken = {private _broken = (nearestTerrainObjects [getMarkerPos "fed_reserve", [], 600]) select { damage _x > 0.4 }; {
            diag_log format ["[LooneyBin][fed] repairing broken terrain object: %1 (dmg %2)", _x, damage _x];
            _x setDamage 0;} forEach _broken;
        count _broken};
    private _stands = call _repairBroken;
    [_repairBroken] spawn { params ["_f"]; uiSleep 60; private _n = call _f; if (_n > 0) then { diag_log format ["[LooneyBin][fed] second-pass repaired %1 (something destroys them AFTER boot)", _n] }; };
    diag_log format ["[LooneyBin][fed] lockdown applied: %1 dome(s), %2 safe building(s), %3 gate(s), %4 broken object(s) repaired", count _domes, count _safes, count _gates, _stands];   // _stands is already a COUNT (the repair helper returns a number)
};
// owner 2026-06-21: REMOVED the unmasked-entry fed-alarm trigger (this loop rang the alarm whenever an unmasked
// civilian came within 175m of fed_reserve). Per owner, the Federal Reserve alarm now fires ONLY on a gate bolt-cut
// (fn_openGate) or a dome side-door hack (fn_openVault) -- both call TON_fnc_fedRobbery. The matching client
// proximity+items trigger in mission core/fn_initCiv.sqf is removed too. (PLB_fnc_fedAlarm stays -- still used by
// fedLockdown's relock + any direct calls; it just isn't auto-tripped by mere presence anymore.)

// LooneyBin (2026-06-09): the four cartel CAPTURE CONTAINERS (capture_container_1..4 = Arms/Drug/Oil/
// Wong, index order = life_capture_list) were never placed in this mission build -> the 300s dirty-money
// /rubber filler loop + DB_fnc_updateCaptures errored on undefined vars every pass, and the cartel stash
// had no physical crate. Create them at the cartel markers + publish (client Captures app + retrieve
// actions read the published objects / gangContainer var).
// LooneyBin (owner 2026-06-13): cartel crate LOOT TABLE. Owner spec: crates may ONLY contain items that
// are buyable at the REBEL shop (fn_weaponShopCfg "rebelwep"). The old per-cartel switch dropped a fixed,
// partly-non-rebel set (Mk20/Medikit/SMG_02...) ONCE at boot and never refilled -> "wrong loot or no loot"
// the moment it was looted. Now: one shared rebel pool, randomised per fill, mags auto-resolved from the
// weapon's CfgWeapons >> magazines, plus a refill loop so an emptied crate restocks (never permanently bare).
// Pools below are all confirmed "rebelwep"-buyable classnames. End-game items (Zafir/LMG_03/RPG/Titan) are
// intentionally left OUT so they aren't free cartel spam, even though they're rebel-buyable.
// owner 2026-07-05: cartel WEAPON crates removed ENTIRELY (owner: "physical crate that spawns weapons at the
// cartels ... they need to go"). No more B_supplyCrate_F, no gun loot, no weapon fill/lock loop. The four
// income containers (dirty money / oil rubber) now live on the FLAG objects -- the gangContainer var is still
// DB-persisted via fn_updateCaptures/fn_queryCaptures and shown in the Captures phone app exactly as before.
// Oil rubber retrieval (fn_getCartelRubber, off the flag's plb_cap_oil) and the cartel tax (fn_cartelSRV) are
// crate-independent and unaffected.
[] spawn {uiSleep 10;
    private _flagNames = ["arms_flag", "drug_flag", "oil_flag", "wongs_flag"];
    life_capture_containers = []; {private _c = missionNamespace getVariable [(_flagNames param [_forEachIndex, ""]), objNull];
        if (!isNull _c) then {private _item = if (_x isEqualTo "oil_cartel") then { "life_inv_rubber" } else { "life_inv_dirty_money" };
            // only seed a fresh container -- fn_queryCaptures may have already restored the DB amount onto the flag
            if (isNil { _c getVariable "gangContainer" }) then { _c setVariable ["gangContainer", [_item, 0], true]; };} else {
            diag_log format ["[LooneyBin][cartel] flag %1 missing -- container %2 left null", (_flagNames param [_forEachIndex, ""]), _forEachIndex + 1];
        };
        missionNamespace setVariable [format ["capture_container_%1", _forEachIndex + 1], _c, true];
        life_capture_containers pushBack _c;} forEach ["arms_cartel", "drug_cartel", "oil_cartel", "wongs_cartel"];
    publicVariable "life_capture_containers";
    diag_log format ["[LooneyBin][cartel] income containers on flags (%1 live); weapon crates removed", {!isNull _x} count life_capture_containers];
};

// LooneyBin (owner 2026-06-16): CARTEL OWNERSHIP PERSISTENCE. plb_capData (which gang owns each cartel) was
// ONLY ever set client-side in fn_captureCartel and networked with `true` -- it was never written to the DB
// and never restored on boot, so EVERY cartel (arms/drug/oil/wongs) reset to Neutral on every reboot. Save
// each flag's ownership to a `cartel_state` table and restore it at boot. We store only gang_id + progress
// (both numeric -> no SQL string-injection from gang names); the gang NAME is re-derived from
// life_server_gangs on restore. A cartel whose owning gang no longer exists (disbanded) stays Neutral.
// singleevh.md Phase 1c: cartel-ownership persistence save migrated onto the single-wheel scheduler (id
// "cartelOwnSave", 60s). The one-shot boot setup (CREATE TABLE + waitUntil gangs/flags loaded + the restore
// pass) runs on the FIRST fire only via exitWith, which also seeds the cross-iteration _last signature
// de-dupe -- the exact local the simple pattern couldn't carry -- into the per-job _st alongside the
// _flagNames/_cartels config; later fires read them back and run the conditional REPLACE. Flag OFF => the
// original loop runs byte-for-byte (else branch) = ZERO behavior change.
["cartelOwnSave", {params ["_st"];
    if !(_st getOrDefault ["init", false]) exitWith {private _flagNames = ["arms_flag", "drug_flag", "oil_flag", "wongs_flag"];
        private _cartels   = ["arms", "drug", "oil", "wongs"]; [
            "CREATE TABLE IF NOT EXISTS cartel_state ("
            + "cartel VARCHAR(16) PRIMARY KEY, gang_id VARCHAR(32), progress DOUBLE, updated DATETIME"
            + ") CHARSET=utf8mb4"] call DB_fnc_asyncQuery;
        // restore once the flags AND the gang list are loaded (need the gang list to map id -> name)
        waitUntil { uiSleep 2; (!isNil "life_server_gangs") && {!isNull (missionNamespace getVariable ["drug_flag", objNull])} };
        // owner 2026-06-20: QUOTE(cartel) -- the cartel column is a plain VARCHAR bareword. Without QUOTE, extDB3
        // returned arms/drug/oil/wongs UNQUOTED -> the mode-2 result `[1,[[arms,'0',0],...]]` hit `call compile`
        // as undefined variables ("Undefined variable in expression: arms") -> the whole restore THREW and aborted,
        // so cartel ownership reset to Neutral on EVERY reboot (the exact failure this block was written to fix).
        // Same compile-safety fix as QUOTE(class) in fn_restoreVehicles. (gang_id was already QUOTE'd; cartel wasn't.)
        private _rows = ["SELECT QUOTE(cartel), QUOTE(COALESCE(gang_id,'0')), COALESCE(progress,0) FROM cartel_state", 2, true] call DB_fnc_asyncQuery;
        if (_rows isEqualType []) then {{_x params [["_cName", ""], ["_gid", "0"], ["_prog", 0]];
                private _idx = _cartels findIf { _x isEqualTo _cName };
                if (_idx >= 0 && {(format ["%1", _gid]) != "0"}) then {   // owner 2026-07-05: persist owner even at partial progress (dropped the _prog>=1 gate) so a captured cartel never reverts to Neutral on restart -- the last owner keeps it until someone re-captures
                    private _flag = missionNamespace getVariable [(_flagNames select _idx), objNull];
                    private _gIdx = life_server_gangs findIf { (format ["%1", _x select 0]) isEqualTo (format ["%1", _gid]) };
                    if (!isNull _flag && {_gIdx >= 0}) then {private _gname = (life_server_gangs select _gIdx) select 1;
                        _flag setVariable ["plb_capData", [parseNumber (format ["%1", _gid]), _gname, 1], true];   // owner 2026-07-05: restore at FULL ownership (was _prog) so the previous owner solidly holds it until someone captures
                        diag_log format ["[LooneyBin][cartel] restored %1 cartel -> gang %2 (%3) prog %4", _cName, _gid, _gname, _prog];};
                };} forEach _rows;};
        _st set ["flagNames", _flagNames];
        _st set ["cartels", _cartels];
        _st set ["last", ["", "", "", ""]];   // cross-iteration ownership-signature de-dupe
        _st set ["init", true];};
    // periodic save: write a cartel's row only when its ownership signature changes (cheap, no DB spam)
    private _flagNames = _st getOrDefault ["flagNames", ["arms_flag", "drug_flag", "oil_flag", "wongs_flag"]];
    private _cartels   = _st getOrDefault ["cartels", ["arms", "drug", "oil", "wongs"]];
    private _last      = _st getOrDefault ["last", ["", "", "", ""]]; {private _flag = missionNamespace getVariable [_x, objNull];
        if (!isNull _flag) then {(_flag getVariable ["plb_capData", [0, "Neutral", 0]]) params [["_gid", 0], ["_gname", ""], ["_prog", 0]];
            private _sig = format ["%1|%2", _gid, _prog];
            if (_sig isNotEqualTo (_last select _forEachIndex)) then {_last set [_forEachIndex, _sig];
                [format ["REPLACE INTO cartel_state (cartel, gang_id, progress, updated) VALUES ('%1','%2',%3,NOW())",
                    (_cartels select _forEachIndex), (format ["%1", _gid]), _prog]] call DB_fnc_asyncQuery;};};} forEach _flagNames;
}, 60, false, true] call PLB_fnc_schedule;

// LooneyBin: oil-cartel RUBBER GENERATION. fn_getCartelRubber only ever DECREMENTS oil_flag's plb_cap_oil
// (the player retrieve action) -- nothing ever produced it, so the oil cartel never had any rubber. Generate
// it server-side while a gang fully owns the cartel, up to a cap. Tune _rate / _cap / _tick.
// singleevh.md Phase 1b: oil-cartel rubber generation migrated onto the single-wheel scheduler (id
// "oilRubber", 60s = the old _tick). The one-shot boot setup (config _rate/_cap, waitUntil oil_flag, the
// over-water standing-deck placement, plb_cap_oil seed) runs on the FIRST fire only; _rate/_cap are stashed
// in the per-job _st and read by the periodic body. Flag OFF => the original loop runs byte-for-byte (else
// branch) = ZERO behavior change.
["oilRubber", {params ["_st"];
    if !(_st getOrDefault ["init", false]) then {
        private _rate = 1;     // owner 2026-06-23 (#506/#508): nerfed 25 -> 1 rubber per tick (was too generous)
        private _cap  = 100;   // owner 2026-06-23: max rubber 250 -> 100
        waitUntil { uiSleep 5; (!isNil "oil_flag") && {!isNull oil_flag} };
        // BUGS.md #72: the oil-cartel flag floats over open water with nothing to stand on -> rubber
        // collection meant swimming. Drop a helipad platform just under the flag as a standing deck
        // (flag stays above water by design -- collection happens at the flag).
        if (surfaceIsWater (getPosATL oil_flag)) then {private _fp = getPosASL oil_flag;
            private _deck = "Land_HelipadRescue_F" createVehicle [0,0,0];
            _deck setPosASL [_fp select 0, _fp select 1, 0.1];
            _deck allowDamage false;
            _deck setVariable ["owner", "cartel", true];
            diag_log format ["[LooneyBin][cartel] oil deck placed under the flag at %1", getPosASL _deck];};
        if (isNil { oil_flag getVariable "plb_cap_oil" }) then { oil_flag setVariable ["plb_cap_oil", 0, true]; };
        _st set ["rate", _rate];
        _st set ["cap", _cap];
        _st set ["init", true];};
    private _rate = _st getOrDefault ["rate", 1];
    private _cap  = _st getOrDefault ["cap", 100];
    if (!isNull oil_flag) then {
        (oil_flag getVariable ["plb_capData", [0, "Neutral", 0]]) params [["_oid", 0], ["_oname", ""], ["_prog", 0]];
        private _cur = oil_flag getVariable ["plb_cap_oil", 0];
        // owner 2026-06-16 (#286): the oil cartel now produces rubber ALWAYS -- capped, contested, or
        // neutral (was gated on a gang FULLY holding it, so an uncapped oil cartel never accumulated any).
        // Whoever controls the cartel still gates who can RETRIEVE it (fn_getCartelRubber); production
        // itself is unconditional now.
        private _new = (_cur + _rate) min _cap;
        if (_new != _cur) then {oil_flag setVariable ["plb_cap_oil", _new, true];
            diag_log format ["[LooneyBin][cartel-rubber] +%1 -> %2/%3 (owner gang %4, prog %5)", (_new - _cur), _new, _cap, _oid, _prog];};
    };}, 60, false, true] call PLB_fnc_schedule;

// singleevh.md Phase 1c: periodic storage-save migrated onto the single-wheel scheduler (id "storageSave",
// 300s). No cross-iteration state -- _changed is a per-item temp. The inner `sleep 2` throttle between
// per-object DB writes stays in the body (the scheduler runs each job in its own spawn WITH overlap
// protection, so an in-body suspend is safe). Flag OFF => the original loop runs byte-for-byte (else branch)
// = ZERO behavior change.
["storageSave", {params ["_st"];
    private "_changed"; {if (typeName _x == "OBJECT") then {_changed = _x getVariable["lootModified", false];
    if (_changed) then {[_x] spawn DB_fnc_updateStorage;
    sleep 2;};};} forEach life_storage_array;
    [] spawn DB_fnc_updateCaptures;
    10 setFog 0;}, 300, false, true] call PLB_fnc_schedule;

[] spawn {private ["_numDoors"];
waitUntil {!isNil "life_bank_vaults"}; {_numDoors = getNumber(configFile >> "CfgVehicles" >> (typeOf _x) >> "numberOfDoors");
_x setVariable["life_locked", 1, true];
for "_i" from 1 to _numDoors do {_x setVariable[format["bis_disabled_Door_%1", _i], 1, true];};} forEach life_bank_vaults;
waitUntil {!isNil "life_bank_safes"}; {_numDoors = getNumber(configFile >> "CfgVehicles" >> (typeOf _x) >> "numberOfDoors");
_x setVariable["life_locked", 1, true];
for "_i" from 1 to _numDoors do {_x setVariable[format["bis_disabled_Door_%1", _i], 1, true];};} forEach life_bank_safes;};
if (worldName in ["Altis","Australia","Tanoa"]) then { [] spawn PLB_fnc_spawnGoldBars; }; 

// singleevh.md Phase 1b: bank-vault passive funds accrual migrated onto the single-wheel scheduler (id
// "bankFunds", 300s). The one-shot boot setup (waitUntil life_bank_building, disable/close the vault door,
// seed life_bank_drilling/last + publish, compute _bankInc per world) runs on the FIRST fire only; _bankInc
// is stashed in the per-job _st. Flag OFF => the original loop runs byte-for-byte (else branch) = ZERO
// behavior change.
["bankFunds", {params ["_st"];
    if !(_st getOrDefault ["init", false]) then {waitUntil { !isNil "life_bank_building" };
        life_bank_building setVariable ["bis_disabled_Door_4", 1, true];
        life_bank_building animate ["door4_rot", 0];
        life_bank_drilling = false;
        life_bank_last = -2000;
        publicVariable "life_bank_drilling";
        publicVariable "life_bank_funds";
        publicVariable "life_bank_last";
        _st set ["bankInc", (if (worldName == "Altis") then { 7000 } else { 5000 })];
        _st set ["init", true];};
    private _bankInc = _st getOrDefault ["bankInc", 5000];
    life_bank_funds = life_bank_funds + _bankInc;
    publicVariable "life_bank_funds";}, 300, false, true] call PLB_fnc_schedule;

[] spawn {{if(!isPlayer _x) then {removeAllWeapons _x;
removeBackpack _x;};} foreach allUnits;};

PLBObjectWhitelist = ["Rope","Box_East_Support_F","Box_East_WpsSpecial_F","Land_WaterBarrel_F","Steerable_Parachute_F","Land_BagBunker_Small_F","Land_BagFence_Corner_F","Land_BagFence_Long_F","Land_BagFence_Round_F","Land_Hbarrier_3_F","Land_Hbarrier_Big_F","Land_CamoNet_open_F","Land_Razorwire_F","Land_HBarrierTower_F","Land_BagFence_End_F","Land_HBarrierWall4_F","Land_Hbarrier_1_F","Land_BagBunker_Tower_F","Land_FieldToilet_F","Land_Pier_small_F","Land_BagFence_Short_F","Land_Research_house_V1_F","Land_Research_HQ_F"];
{if (!((typeOf _x) in PLBObjectWhitelist)) then {PLBObjectWhitelist pushBack (typeOf _x);};} forEach vehicles;

// singleevh.md Phase 1c: periodic cleanup + cartel auto-deposit migrated onto the single-wheel scheduler
// (id "cleanupCartel", 300s). Self-contained body -- no cross-iteration state, no boot setup, no in-body
// suspend. Flag OFF => the original loop runs byte-for-byte (else branch) = ZERO behavior change.
["cleanupCartel", {params ["_st"];
    [] call PLB_fnc_cleanup;
    // owner 2026-07-05: cartels AUTO-DEPOSIT money straight into the OWNING GANG's bank (arms/drug/wongs) every
    // 300s tick while fully captured -- no more dirty-money container to accumulate/farm. OIL is the exception:
    // it deposits RUBBER at its flag (oil_flag plb_cap_oil, generated by the rubber loop below, retrieved via the
    // Get Cartel Rubber action) -- excluded here. Only a fully-captured cartel with a still-existing owning gang
    // pays. Same gang-bank write pattern as fn_cartelSRV (the sale tax); this is a separate passive income.
    {private _flagName = _x;
        private _flag = missionNamespace getVariable [_flagName, objNull];
        if (!isNull _flag) then {
            (_flag getVariable ["plb_capData", [0, "Neutral", 0]]) params [["_gangID", 0], ["_gangName", ""], ["_progress", 0]];
            if (_progress >= 1 && {(format ["%1", _gangID]) isNotEqualTo "0"}) then {
                private _gidx = life_server_gangs findIf { (format ["%1", _x select 0]) isEqualTo (format ["%1", _gangID]) };
                if (_gidx >= 0) then {private _gang = life_server_gangs select _gidx;
                    private _deposit = 30000;   // per 300s tick, per owned cartel -- tune here
                    private _newBank = ((_gang select 5) + _deposit) max 0;
                    _gang set [5, _newBank];
                    [str (_gang select 0), 0, 0, _newBank] spawn DB_fnc_updateGang;   // persist gangs.bank
                    [[998, objNull, format ["Cartel auto-deposit: %1 -> gang %2 (%3) +$%4 = bank $%5", _flagName, _gangID, _gangName, _deposit, _newBank]], "PLB_fnc_logIt", false, false] spawn life_fnc_MP;
                };};};} forEach ["arms_flag", "drug_flag", "wongs_flag"];}, 300, false, true] call PLB_fnc_schedule;

// singleevh.md Phase 1c: periodic flushAllPlayers drain migrated onto the single-wheel scheduler (id
// "flushPlayers", 420s). Trivial body -- no state, no boot setup. Flag OFF => the original loop runs
// byte-for-byte (else branch) = ZERO behavior change.
["flushPlayers", { params ["_st"]; [] spawn DB_fnc_flushAllPlayers; }, 420, false, true] call PLB_fnc_schedule;

if (worldName == "Australia") then {

[] spawn {_obj = nearestObjects [[25000,25000,0], ["Land_CommonwealthBank","Land_PoliceStation"], 15000]; {switch (typeof _x) do {
case "Land_PoliceStation": { _x animate ["gatedoor_1", -1.6]; _x animate ["gatedoor_2", 1.6]; };
case "Land_CommonwealthBank": { _x animate ["LeftSlideDoor",-1.7]; _x animate ["RightSlideDoor",1.7] };}} forEach _obj;};

life_prison_building = nearestObject [getMarkerPos "corrections", "Land_MainSection"];
life_prison_building animate ["Door3", 1];
life_prison_building animate ["Door4", 1];
life_prison_building animate ["Door7", 1];
life_prison_building animate ["Door13", 1];
life_prison_building animate ["Door14", 1];};

[] spawn DB_fnc_restoreVehicles;
[] spawn PLB_fnc_laserTag;

[] spawn { sleep 20; { _x setDamage 1; } forEach (nearestObjects [getMarkerPos "fed_reserve", ["Land_Cargo_Patrol_V1_F"], 200]); };

[] spawn {_query = format["DELETE FROM `online` WHERE `instance`='%1'", life_server_instance];
[_query] call DB_fnc_asyncQuery;};

 {_x animate ["Door_1_rot", 1];} forEach allMissionObjects "Land_BarGate_F";
[] spawn KBW_fnc_fixBadOffers;
SRV_exchangeIsReady = true;   publicVariable "SRV_exchangeIsReady";   // LooneyBin: the Exchange menus hard-gate on this -- never published before (menus said "still being initialized" forever)
[] spawn TON_fnc_radioSRV;   // LooneyBin car-radio station master -- broadcasts PLB_radioNow per station (Build A ready)
_forSaleHouses = [format["SELECT worldspace,sale FROM houses WHERE sale>0",life_server_instance],2,true] call DB_fnc_asyncQuery;
life_forSaleHouses = [];
// owner 2026-06-14 (#182): restore the listing into plb_house_price, NOT the dead "salePrice" var. Every
// reader (fn_buyHouse, fn_houseMenu, fn_marketSellHouse, the "Locate Homes for Sale" home-store action) keys
// off plb_house_price; "salePrice" has zero readers. So persisted for-sale houses came back from the DB
// invisible to the market AND un-buyable after every restart -- the locate action marked nothing on the map.
// owner 2026-06-19: asyncQuery returns `worldspace` ALREADY PARSED to an array for these sale>0 rows. The old
// unconditional `call compile (_x select 0)` then threw "compile: Type Array, expected String" and HALTED the
// main init thread BEFORE life_server_isReady published -> every client hung at "waiting for server ready" =
// total join outage. (Latent: only triggered once b0075's fn_updateHousePrice oid fix made listings persist.)
// Handle array-or-string + skip anything malformed so one bad row can never wedge boot again.
{private _ws = _x select 0;
    if (_ws isEqualType "") then { _ws = parseSimpleArray (format ["%1", _ws]); };
    if (_ws isEqualType []) then {nearestBuilding _ws setVariable ["plb_house_price", _x select 1, true];
        life_forSaleHouses pushBack _ws;};} forEach _forSaleHouses;
publicVariable "life_forSaleHouses";
// singleevh.md Phase 1c: exchange listing-timer increment migrated onto the single-wheel scheduler (id
// "exchangeTimer", 3600s). Trivial body -- one UPDATE, no state, no boot setup. Flag OFF => the original
// loop runs byte-for-byte (else branch) = ZERO behavior change.
["exchangeTimer", {params ["_st"];
    private _query = "UPDATE exchange SET timer=timer+1 WHERE active='1'";   // LooneyBin: storage rows (active=2) age by bought_at, not the listing timer
    [_query,1] call DB_fnc_asyncQuery;}, 3600, false, true] call PLB_fnc_schedule;

// --- LooneyBin: announce server readiness to the 2020 client ----------------
// The 2020 client (core\init.sqf) gates on these two flags before it runs
// life_fnc_dataQuery (the player-load DB handshake). The 2017-derived server never
// published them -> client hung forever at waitUntil{!isNil "life_server_isReady"}
// -> spawned on debug island with no welcome/HUD/markers/phone. Publish them now that
// server init has completed. SRV_VehiclesLoaded gates the client's vehicle wait; restore
// runs async (spawned above) and JIP-syncs vehicles as they load, so it's safe to flag here.
SRV_VehiclesLoaded = true;
publicVariable "SRV_VehiclesLoaded";
life_server_isReady = true;
publicVariable "life_server_isReady";
diag_log "::LooneyBin Server:: READY — published life_server_isReady + SRV_VehiclesLoaded";

// ===== LooneyBin: loonybot command bridge -- executes queued admin commands from the bot_commands table =====
// singleevh.md Phase 1c: loonybot command bridge poll migrated onto the single-wheel scheduler (id
// "botBridge", 5s = the old poll cadence). The one-shot boot settle (uiSleep 30) runs on the FIRST fire
// only via first-run-init so queued commands aren't dispatched before life_fnc_MP / PLB_fnc_* are ready;
// the body is unchanged (DB_Async_Active-gated SELECT + per-command switch). Flag OFF => the original loop
// runs byte-for-byte (else branch) = ZERO behavior change.
["botBridge", {params ["_st"];
    if !(_st getOrDefault ["init", false]) then { uiSleep 30; _st set ["init", true]; };   // let boot settle before dispatching queued commands
    if (!DB_Async_Active) then {
        private _rows = ["SELECT id, QUOTE(command), QUOTE(COALESCE(target,'')), QUOTE(COALESCE(arg1,'')), QUOTE(COALESCE(arg2,'')) FROM bot_commands WHERE status='pending' ORDER BY id ASC LIMIT 10", 2, true] call DB_fnc_asyncQuery;
        if (_rows isEqualType [] && {count _rows > 0}) then {{
                _x params [["_cid", -1, [0]], ["_cmd", "", [""]], ["_tgt", "", [""]], ["_a1", "", [""]], ["_a2", "", [""]]];
                private _ok = true;
                switch (toLower _cmd) do {case "msg": {[[0, _a1], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;};
                    case "kick": {private _u = (allPlayers select { (getPlayerUID _x) isEqualTo _tgt }) param [0, objNull];
                        if (!isNull _u) then { [[_a2], "life_fnc_botKick", _u, false, false] spawn life_fnc_MP; };};
                    case "ban": {private _u = (allPlayers select { (getPlayerUID _x) isEqualTo _tgt }) param [0, objNull];
                        if (!isNull _u) then { [[format ["Banned: %1", _a2]], "life_fnc_botKick", _u, false, false] spawn life_fnc_MP; };};
                    case "hardkick": {
                        // LooneyBin: engine-level kick from the SERVER -- works even when the
                        // target client's scripts are wedged (frozen-arsenal case; the normal
                        // 'kick' routes endMission through the CLIENT and dies with it).
                        private _u = (allPlayers select { (getPlayerUID _x) isEqualTo _tgt }) param [0, objNull];
                        if (!isNull _u) then {diag_log format ["[LooneyBin][bot] hardkick %1 (%2)", name _u, _tgt];
                            serverCommand format ["#kick %1", owner _u];
                            [_u] spawn {params ["_u"];
                                uiSleep 8;
                                // serverCommand can be unavailable to dedicated-server scripts --
                                // engine fallback: deleting the player object drops the client
                                if (!isNull _u) then { deleteVehicle _u; };};};};
                    case "gracefulsave": {
                        // owner 2026-06-13: DETERMINISTIC soft restart (replaces the endMission attempt, which
                        // depended on a config-specific in-place mission reload that proved unreliable on this
                        // headless box -- -autoInit + no admin/RCON). loonybot's !srv softr fires THIS to do a
                        // FULL graceful save (vehicle_mem incl. plb_vinv trunks + flushAllPlayers + storage)
                        // BEFORE it kills + relaunches the process. restoreVehicles rebuilds the world on boot,
                        // so nothing is lost. Marks the command 'saved' once the async writes have flushed.
                        // Guarded so a repeated softr can't run two concurrent saves (saveVehicles DELETEs then
                        // re-fills vehicle_mem -- overlapping runs would corrupt it).
                        if (isNil "PLB_savingForRestart" || {!PLB_savingForRestart}) then {PLB_savingForRestart = true;
                            [_cid] spawn {params ["_cid"];
                                [[1, "Server saving for a restart -- your progress + vehicles are being persisted..."], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
                                // owner 2026-06-19 (kit-loss cluster): force a live client gear+pos+money flush BEFORE
                                // the snapshot -- flushAllPlayers only drains queued writes, not live state. This covers
                                // !srv softr / hardr / deploys (all route through gracefulsave). See the scheduled path above.
                                [[], "life_fnc_ClupdateRequest", -2, false, false] spawn life_fnc_MP;
                                uiSleep 8;                      // let the client row-writes land before the snapshot
                                [] call DB_fnc_saveVehicles;   // BLOCKING: queues vehicle_mem + flushAllPlayers + storage
                                uiSleep 35;                     // let extDB3 flush its async write queue (established buffer)
                                [format ["UPDATE bot_commands SET status='saved' WHERE id=%1", _cid]] call DB_fnc_asyncQuery;
                                diag_log "[LooneyBin][softr] graceful save complete + flushed -> safe to restart the process";
                                PLB_savingForRestart = false;};};};
                    case "resetfed": {
                        // owner 2026-06-16: clear a stuck/cooling-down Federal Reserve so players can retry
                        // without a reboot (life_fed_robbed stuck [true,...] or SRV_lastRobbery cooldown).
                        [] call PLB_fnc_resetFed;
                        [[2, "Federal Reserve security systems have been reset by command."], "life_fnc_broadcast", west, false, false] spawn life_fnc_MP;
                    };
                    case "ghrefresh": {
                        // owner 2026-06-20: the Enrique offline-gardener bot writes a house's vinv + greenhouse_crop
                        // straight to the DB, but the LIVE server caches both on the house OBJECT (plb_vinv /
                        // plb_gh_crop, loaded once at boot) -> without this the DB change is invisible in-game AND a
                        // later house save clobbers it. Re-read both from the DB onto the running object (owner + all
                        // keyholders are offline by Enrique's own gate, so nothing else is touching the house). _tgt =
                        // house oid, _a1 = worldspace "[x,y,z]".
                        private _pos = parseSimpleArray _a1;
                        private _h = if (_tgt isNotEqualTo "" && {_pos isEqualType []} && {count _pos >= 2}) then { (nearestObjects [_pos, ["House_F"], 14]) param [0, objNull] } else { objNull };
                        if (isNull _h) then { _ok = false; } else {
                            private _row = [format ["SELECT vinv, QUOTE(COALESCE(greenhouse_crop,'')) FROM houses WHERE oid='%1'", _tgt], 2] call DB_fnc_asyncQuery;
                            if (!(_row isEqualType []) || {count _row < 2}) then { _ok = false; } else {
                                // vinv is str2/mres-encoded -> read RAW (project rule, see fn_queryHouses) -> mresToArray -> plb_vinv
                                private _vinv = [_row select 0] call DB_fnc_mresToArray;
                                if (typeName _vinv == "STRING") then { _vinv = parseSimpleArray (format ["%1", _vinv]); };
                                if (!(_vinv isEqualType []) || {count _vinv < 2}) then { _vinv = [[], 0]; };
                                _h setVariable ["plb_vinv", _vinv];   // owner 2026-06-23 (B): server-LOCAL cache (not broadcast); next gated open re-reads the DB row anyway
                                // greenhouse_crop is a PLAIN array string -> parseSimpleArray -> plb_gh_crop
                                private _crop = parseSimpleArray (format ["%1", _row select 1]);
                                if !(_crop isEqualType []) then { _crop = []; };
                                _h setVariable ["plb_gh_crop", _crop, true];
                                diag_log format ["[LooneyBin][enrique] ghrefresh house %1 -> plb_vinv(%2 items)/plb_gh_crop(%3 batches)", _tgt, count (_vinv param [0, []]), count _crop];
                            };};};
                    default { _ok = false; };};
                [format ["UPDATE bot_commands SET status='%1' WHERE id=%2", (["error","done"] select _ok), _cid]] call DB_fnc_asyncQuery;
            } forEach _rows;};};}, 5, false, true] call PLB_fnc_schedule;
