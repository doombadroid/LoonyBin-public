enableSaving[false, false];
// LooneyBin call-audit toggles (consumed by core/functions/network/fn_MP.sqf). Settable live via debug
// console -- e.g. `PLB_logCallsAll = true;` for a forensic firehose burst, then back to false.
// taze/down threshold scales with the target's armour (evh/fn_handleDamage.sqf). spec: bare 1 / plate 6 /
// headshot 1 / helmeted-head 2. BODY hits-to-down = round(base + (vestChestArmor/refPlateArmor)*(refHits-base)
// + vehArmor/vehDiv), clamped [1 .. max]. refPlateArmor is read LIVE from PLB_stunRefVest's config once, so
// the curve self-calibrates to the real numbers (basic plate = refHits; heavier Lvl IV/V rigs scale higher).
PLB_stunBase    = 1;                    // hits to down a BARE (no vest, on foot) body -- the floor
PLB_stunHeadBare   = 1;                  // head hit, no headgear  -> instant down
PLB_stunHeadHelmet = 2;                  // head hit WITH headgear -> 2 hits
PLB_stunVehDiv  = 50;                   // vehicle armour per extra hit (Ifrit ~600 -> +12 hits = can't taze through it)
PLB_stunMax     = 40;                   // hard ceiling so a down is never literally impossible
// owner 2026-06-17: HITS-TO-DOWN TABLE -- [vest level][calibre] -> exact hits (replaces the old armour formula
// + per-round weight; those PLB_stunRef*/CalMin/Max tunables are retired). Rows = vest Lvl 1..5 then the
// EXPLOSIVE-resistant vest (row index 5). Columns (calibre):
//   0 = 9mm      1 = 5.56    2 = 5.8     3 = 6.5     4 = 7.62
//   5 = .338     6 = 9.3 Navid (the 9.3 LMG)        7 = 9.3 Cyrus / other 9.3     8 = .50/12.7    9 = higher
// (Navid vs Cyrus fire the SAME 9.3x64 round, so they're split by WEAPON. Where the spec only gave Cyrus,
//  Navid uses the same number.) Per the owner's spec verbatim (incl. the Lvl 2 > Lvl 3 9mm step).
PLB_downTable = [
//   9mm 5.56 5.8 6.5 7.62 .338 9.3N 9.3C .50 hi
    [  3,  2,  2,  1,  1,   1,   1,   1,   1,  1],   // Lvl 1
    [  5,  2,  2,  2,  1,   1,   1,   1,   1,  1],   // Lvl 2
    [  4,  3,  2,  2,  2,   2,   2,   1,   1,  1],   // Lvl 3
    [  6,  4,  3,  2,  2,   2,   2,   2,   1,  1],   // Lvl 4
    [  7,  4,  3,  3,  2,   2,   2,   2,   1,  1],   // Lvl 5
    [ 13,  4,  3,  2,  2,   1,   1,   1,   1,  1]    // Explosive-resistant vest
];
// vest LEVEL is derived from the worn vest's Chest armour, split into 5 EVEN bands between a light and a heavy
// reference vest whose armour is read LIVE from config (self-calibrating -> no hard-coded armour numbers, and a
// modded vest auto-tiers by where its armour lands). Lightest armoured vest -> Lvl 1, heaviest -> Lvl 5; an
// armour-0 / no real vest = BARE (PLB_stunBase). Explosive-resistant vests are matched by classname FIRST.
PLB_downRefLight = "V_TacVest_blk";           // Lvl 1 armour anchor (lightest armoured vest)
PLB_downRefHeavy = "V_PlateCarrierSpec_blk";  // Lvl 5 armour anchor (Carrier Special Rig, NATO Level V)
PLB_downExplosiveVests = ["platecarriergl", "eod"];  // lowercase classname substrings -> the EXPLOSIVE row (Carrier GL Rig / EOD suit). Add yours here.
PLB_logCalls    = true;     // master switch for the -FNCALL- audit
PLB_logCallsAll = false;    // true = log EVERY remote fn name (heavy; burst only)
PLB_logCallList = ["bank","atm","wire","money","cash","key","vehowner","addvehicle","2chain","inv","trunk","store","gather","process","sell","buy","gang","cartel","house","bldg","lockpick","restrain","arrest","wanted","admin","give","spawnvehicle","revive","heal","redeem","craft","upgrade","query","insert","update","delete","mres","drug","seize","chop","garage","property","tent","wear","drop","pickup"];
life_achievements = [];
// life_nextFrameBufferA/B, life_nextFrameNo, life_waitAndExecArray and
// life_waitUntilAndExecArray removed 2026-07-24: all four were write-only or
// self-referential -- nothing ever pushed to the two exec arrays, nothing read
// the buffers, and nextFrameNo's only reader was its own guard.
life_eachFrameHandles = [];
life_eachFrameHandlerArray = [];
// owner 2026-06-21 (PFH leak): the per-frame array is wiped here on every mission (re)load, so the cached
// handle for the civ save-loop must reset in lockstep -- otherwise on a relog fn_initCiv would see a stale
// life_civSavePFH, skip registration, and the player would get NO periodic gear/position save. Nil it here so
// fn_initCiv registers exactly one handler per session.
life_civSavePFH = nil;
diag_log "init first" + str(allDisplays);

// ── HEADLESS CLIENT ───────────────────────────────────────────────────────────────────────────────
// The HC has no player and no UI. Its whole job: OWN driverless vehicles and drive them with the physics
// autopilot (life_fnc_hcDrive) at ANY range from players -- deliveries, convoys, scripted events. It
// announces itself to the server (PLB_UsingHeadless + PLB_hcOwner) so the server knows to hand vehicles to
// it, then pumps any LOCAL vehicle tagged `hc_ap_want` into the autopilot. Skips every player-oriented
// init below (no player -> those would all no-op or error).
if (!hasInterface && !isServer) exitWith {diag_log "LB HC: headless client online -- autopilot driver standing by";
    [] spawn {                     // re-announce forever so a server that reboots after us relearns our owner id
        while {true} do {PLB_hcOwner = clientOwner;   publicVariable "PLB_hcOwner";
            // owner 2026-07-16: do NOT set PLB_UsingHeadless=true. That flag flips the mission into the LEGACY
            // full-HC model (server_init HandleDisconnect -> BIS_fnc_endMission on HC drop; eventhandlers relay
            // sync via owner HC1). The Loonazon autopilot HC only DRIVES vans -- it is not mission-critical, so it
            // must never be able to end the mission. PLB_hcOwner alone signals "HC online" to the van handoff.
            uiSleep 20;};};
    [] spawn {                     // driver pump: a local tagged veh -> autopilot it (drive, or a departure maneuver)
        while {true} do {{if (local _x) then {
                    if ((_x getVariable ["hc_ap_departWant", false]) && {!(_x getVariable ["hc_ap_departing", false])}) then {
                        [_x] spawn life_fnc_hcDepart;   // reverse off the spot -> 3-point turn -> hand back to hcDrive
                    } else {if ((_x getVariable ["hc_ap_want", false])
                            && {!(_x getVariable ["hc_ap_driving", false])}
                            && {(_x getVariable ["hc_ap_done", ""]) isEqualTo ""}) then {private _dest = _x getVariable ["hc_ap_dest", []];
                            if (_dest isEqualType [] && {count _dest >= 2}) then {
                                [_x, _dest, _x getVariable ["hc_ap_mode", "normal"]] call life_fnc_hcDrive;};};};};} forEach vehicles;
            uiSleep 1;};};};

MISSION_ROOT = str missionConfigFile select[0, count str missionConfigFile - 15];
[] execVM "briefing.sqf";
[] call life_fnc_KRON_Strings;
player setVariable["BIS_noCoreConversations", true];
0 fadeRadio 0;
enableRadio false;
enableSentences false;
private _fedWalls = [[15931.1, 16988.5], [15935.9, 16988.4], [15953.6, 16941.6], [15982.6, 16902.3], [15985.7, 16860.3], [15994.5, 16828.9],
    [16108.9, 16823.3], [16116.7, 16835], [16122.1, 16834.1], [16126.9, 16841.7], [16122.8, 16845.4], [16142.3, 16882.1], [16179, 16948.4],
    [16206.4, 16996.2], [16210.9, 16997.4], [16215.1, 17007.6], [16213.9, 17010.4], [16242.7, 17061.5], [16222.2, 17097.9],
    [16197.3, 17100.5], [16117.3, 17125.7], [16117.8, 17141.9], [16041.7, 17147], [15906.6, 17061.7], [15930.8, 17000.8], [15926.9, 16999]
];
fedWalls = _fedWalls apply {[_x select 0, _x select 1, 0]};

// LooneyBin custom buildings (mission-embedded .p3d): spawn MOVED to initServer.sqf (server) +
// initPlayerLocal.sqf (each client). init.sqf runs too early on clients (world/terrain not ready) for
// createSimpleObject to take -- the rig loaded server-side but never on clients. Spawn in-world instead.
