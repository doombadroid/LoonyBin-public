// LooneyBin: removed `if !(_this select 0) exitWith {}` -- Arma auto-runs initServer with _this=[],
// so that guard aborted server init (life_server never spawned). Auto-run must proceed.
bis_fnc_drawMinefields_active = true;
PLB_worldName =
switch (worldName) do {case ("blud_vidda"): {"Vidda"}; case ("chernarus"): {"Chernarus Autumn"}; case ("sara"): {
                    "Sahrani"}; case ("zargabad"): {"Zargabad"}; case ("utes"): {
                            "Utes"}; default {worldName};}; publicVariable "PLB_worldName";
PLB_Server =
switch (profileName) do {case "LoonyBinServer1": {1}; case "LoonyBinServer2": {2};
        case "LoonyBinServer3": {3};
        case "LoonyBinServer4": {4};
        default {1};}; publicVariable "PLB_Server";

// owner 2026-07-10: DAY/NIGHT CYCLE RE-ENABLED. This used to re-assert noon every 10 min ("permanent
// DAYTIME"), which snapped the clock back before it ever reached dark -> the server_init "dayNightTime"
// setTimeMultiplier job (12x day / 54x night, already live) could never carry it into night. Removed so
// the multiplier cycles freely: a full game-day passes in ~1.5 real hours, nights pass fast (54x) so it's
// never dark for long. (The old comment's fear that setTimeMultiplier stretches mission `time`/uiSleep is
// outdated -- setTimeMultiplier only accelerates the time-of-DAY clock, not `time`; the 12x multiplier has
// been live via the scheduler the whole time with no timer issues.) Start date/hour comes from mission.sqm.

// LooneyBin: cops (respawn_west) + medics (respawn_guerrila) had NO respawn=BASE marker, so on
// bleedout the engine respawned them at [0,0,0] = debug island. Create the missing side anchors at
// the civilian respawn pos (just a pre-spawn-menu holding spot) so nobody lands on debug island.
{if ((getMarkerPos _x) isEqualTo [0,0,0]) then {createMarker [_x, getMarkerPos "respawn_civilian"];
        _x setMarkerAlpha 0;};} forEach ["respawn_west", "respawn_guerrila", "respawn_east"];
[] call life_fnc_mapData; {_x params["", "", "", "", "_xIsServer"];
    if (_xIsServer) then {_x spawn life_fnc_createVehicleLocal;};}
forEach(allLocalMapEntities);

// owner 2026-06-22: 2nd weed processor REDZONE at [16462.5,19572.8] -- a red locator dot ("Cannabis Processing",
// matching the other drug-processor redzones in the .sqm) + a 300m red KOS ellipse (the standard redzone range).
// The processor NPC itself is spawned via fn_mapData allLocalMapEntities (sim + damage disabled). Created here on
// the server -> GLOBAL markers (synced to every client + JIP). KOS is social like the other drug redzones (no trigger).
private _wp2 = [16462.5, 19572.8, 0];
createMarker ["weed_processor_2", _wp2];
"weed_processor_2" setMarkerType "mil_dot";
"weed_processor_2" setMarkerColor "ColorRed";
"weed_processor_2" setMarkerText "Cannabis Processing";
createMarker ["weed_processor_2_zone", _wp2];
"weed_processor_2_zone" setMarkerShape "ELLIPSE";
"weed_processor_2_zone" setMarkerBrush "Border";
"weed_processor_2_zone" setMarkerSize [300, 300];
"weed_processor_2_zone" setMarkerColor "ColorRed";
"weed_processor_2_zone" setMarkerAlpha 0.8;

// owner 2026-06-25: SIDEWINDER ISLAND map label -- red locator dot + red text, no zone. Created on the server
// -> GLOBAL marker (synced to every client + JIP), same pattern as the processor dots.
private _sidewinder = [13548, 12082.8, 0];
createMarker ["sidewinder_island", _sidewinder];
"sidewinder_island" setMarkerType "mil_dot";
"sidewinder_island" setMarkerColor "ColorRed";
"sidewinder_island" setMarkerText "SIDEWINDER ISLAND";

// owner 2026-06-22: 3rd weed processor REDZONE at [18142.6,15285.7] -- same as #2 (red locator dot + 300m red KOS ellipse).
private _wp3 = [18142.6, 15285.7, 0];
createMarker ["weed_processor_3", _wp3];
"weed_processor_3" setMarkerType "mil_dot";
"weed_processor_3" setMarkerColor "ColorRed";
"weed_processor_3" setMarkerText "Cannabis Processing";
createMarker ["weed_processor_3_zone", _wp3];
"weed_processor_3_zone" setMarkerShape "ELLIPSE";
"weed_processor_3_zone" setMarkerBrush "Border";
"weed_processor_3_zone" setMarkerSize [300, 300];
"weed_processor_3_zone" setMarkerColor "ColorRed";
"weed_processor_3_zone" setMarkerAlpha 0.8;

// owner 2026-06-22: 4th weed processor REDZONE at [21938.4,17601.4] -- same as #2/#3 (red locator dot + 300m red KOS ellipse).
private _wp4 = [21938.4, 17601.4, 0];
createMarker ["weed_processor_4", _wp4];
"weed_processor_4" setMarkerType "mil_dot";
"weed_processor_4" setMarkerColor "ColorRed";
"weed_processor_4" setMarkerText "Cannabis Processing";
createMarker ["weed_processor_4_zone", _wp4];
"weed_processor_4_zone" setMarkerShape "ELLIPSE";
"weed_processor_4_zone" setMarkerBrush "Border";
"weed_processor_4_zone" setMarkerSize [300, 300];
"weed_processor_4_zone" setMarkerColor "ColorRed";
"weed_processor_4_zone" setMarkerAlpha 0.8;
// owner 2026-06-22: the #4 processor stands INSIDE a house -> flag that house plb_restricted_house=true so NO ONE can
// buy or manage it (the fn_buyHouse:27 + fn_houseMenu gates), which also blocks LOCKING it (locking needs ownership,
// and it can never be owned). Delayed ~35s so the map building has streamed in; GLOBAL setVar -> syncs to every
// client + JIP. The 5-min gang-house re-tag only CLEARS this flag on OWNED (DB-registered) houses -- this one is
// unowned, so the restriction sticks.
[] spawn {uiSleep 35;
    private _wpHouse = (nearestObjects [[21938.4, 17601.4, 0], ["House_F"], 15]) param [0, objNull];
    if (!isNull _wpHouse) then {_wpHouse setVariable ["plb_restricted_house", true, true];
        diag_log format ["[LooneyBin] weed-processor #4 house flagged restricted (no buy/lock): %1 @ %2", typeOf _wpHouse, getPosATL _wpHouse];
    } else {diag_log "[LooneyBin] weed-processor #4: NO House_F found within 15m of [21938.4,17601.4] to restrict";};};

// ── Moving rebel-outpost aircraft carrier (LooneyBin v1 — translation only) ──────────
//  Picks a random sea position each restart and rigid-translates the carrier + its
//  server-side deck objects + spawn markers there (keeps the original heading).
//  TUNE: edit _carrierSpots ([x,y] sea positions). #1 = the original north-sea spot
//  (known-good). Restart a few times and verify each spot sits on OPEN WATER with no
//  land/seabed clipping; delete any bad one.
//  v1 GAPS to confirm in-game (report for v2 if wrong): the vendor NPC + civ_sea_11/12
//  boat spawns may be client-local / not carrier-owned and might not follow.
if (!isNull life_aircraftCarrier) then {
    // LooneyBin: ONLY these 3 spots, rotating each restart (owner-set, from 6-fig map grids ->[x,y]x100).
    // CARRIER MUST SIT ON OPEN WATER -- restart a few times + check the LB_CARRIER log / in-game; if any
    // spot clips land/seabed, swap it for a real world [x,y] sea position.
    private _carrierSpots = [[15200.0, 13700.0],    // 1 · grid 152137  (VERIFY WATER — central Altis, may be land)
        [14200.0,  8300.0],    // 2 · grid 142083  (VERIFY WATER)
        [ 1400.0, 13700.0]     // 3 · grid 014137  (VERIFY WATER — far west)
    ];
    private _oldPos = getPosWorld life_aircraftCarrier;
    private _pick   = selectRandom _carrierSpots;
    private _off    = [(_pick select 0) - (_oldPos select 0), (_pick select 1) - (_oldPos select 1), 0];
    if (vectorMagnitude _off > 1) then {{if (local _x && {!(isPlayer _x)}) then {_x setPosWorld ((getPosWorld _x) vectorAdd _off);};
        } forEach (nearestObjects [_oldPos, [], 320]); {if !((getMarkerPos _x) isEqualTo [0,0,0]) then {
                _x setMarkerPos ((getMarkerPos _x) vectorAdd _off);};
        } forEach ["civ_air_carrier_1", "civ_air_carrier_2", "civ_air_carrier_3", "Rebelop_7"];
        diag_log format ["LB_CARRIER moved to %1 (offset %2)", _pick, _off];};};

[] spawn compile PreprocessFileLineNumbers "\life_server\init.sqf";
// LooneyBin: SpyGlass server-side guard removed (was: failMission loop unless profileName ~ sylu/JS)

// owner 2026-06-18: seal the Loony Bin at boot -- lock the church/hospital doors + front gate, restore the
// breach wall/box. Delayed so the server init (SRV_loonyBinData + TON fns) and the mapData church both exist.
[] spawn { uiSleep 25; if (!isNil "TON_fnc_loonyBinSRV") then { ["loonyBinReset", []] call TON_fnc_loonyBinSRV; }; };
// LooneyBin custom buildings (mission-embedded .p3d): SERVER-side spawn (collision) -- world ready here.
[] execVM "custom_buildings\load.sqf";
// LooneyBin (owner 2026-07-03): swap derelict industrial sheds (Land_u_Shed_Ind_F) for intact, buyable ones.
[] execVM "custom_buildings\replace_sheds.sqf";
// LooneyBin (owner 2026-07-11): MALDEN MAKEOVER boot pass -- re-swap every malden=1 house (terrain originals
// are pristine each restart). At +9s: after replace_sheds' +6s spawn + immediate tag, so the makeover's own
// tag re-run is the last word on identity vars.
[] spawn { uiSleep 9; if (!isNil "TON_fnc_maldenSRV") then { ["boot"] call TON_fnc_maldenSRV; }; };
// LooneyBin composition zones (owner 2026-07-10): serverSide zones spawn on the dedicated server at boot;
// every client streams its own local copies by proximity (see compositions\zones.sqf + life_fnc_compZones).
["server"] call life_fnc_compZones;
