#include "macro.h"
params["_player", "_didJIP"];
if !(hasInterface) exitWith {};
// LooneyBin 2026-06-11: nil-guard the server-owned trial vars so the prison/courthouse NPC actions and
// fn_trialSystem never throw on `SRV_trialData select N` before the server's publicVariable arrives (JIP race).
if (isNil "SRV_trialData") then { SRV_trialData = [objNull,[],[],false,false,false,""]; };
if (isNil "SRV_trialPreviousDefenders") then { SRV_trialPreviousDefenders = []; };
// quest vars: fn_handleQuest/fn_questSync read these before fn_questAccept sets them on a no-active-quest path
// -> "undefined variable life_questItems/Progress" spam (CLANKR script-err bursts). Default empty.
if (isNil "life_questItems") then { life_questItems = []; };
if (isNil "life_questProgress") then { life_questProgress = []; };
if (isNil "life_airDrop_last") then { life_airDrop_last = -99999; };
// LooneyBin dynamic market (2026-06-11): keep this client's life_price_index in sync with the server.
// The server pushes the full index on login (fn_query) and broadcasts each per-good change as
// life_stock_change=[class,newSaturation]; apply it so life_fnc_marketFactor prices stay live.
if (isNil "life_price_index" || {!(life_price_index isEqualType [])}) then { life_price_index = []; };
"life_stock_change" addPublicVariableEventHandler {if (!(life_price_index isEqualType [])) exitWith {};
    private _d = _this select 1;
    if (!(_d isEqualType []) || {count _d < 2}) exitWith {};
    private _i = life_price_index findIf {(_x isEqualType []) && {(_x param [0, ""]) isEqualTo (_d select 0)}};
    if (_i > -1) then { (life_price_index select _i) set [1, _d select 1]; };};
// LooneyBin (owner, 2026-06-11): MAX-VERBOSITY -- capture EVERY client script error to this client's RPT AND
// mirror it to the SERVER console.log (+ DB `log` table) so errors on REMOTE players' machines are visible
// centrally (otherwise a client's errors only land in that client's local RPT, unreadable server-side).
// Throttled 2s/client so a recurring error can't flood the wire. Returns false -> engine still logs/handles it.
addMissionEventHandler ["ScriptError", {diag_log format ["[LB-SCRIPTERR][client] %1", _this];
    if ((time - (missionNamespace getVariable ["PLB_lastScriptErrT", -10])) > 2) then {
        missionNamespace setVariable ["PLB_lastScriptErrT", time];
        [["-SCRIPTERR-", player, profileName, ((format ["%1", _this]) select [0, 380])], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
    };
    false}];
__SETCONST__(BIS_fnc_endMission, BIS_fnc_endMission);
life_quitWelcomeUI = false;
[missionNamespace, "OnGameInterrupt", {_this call life_fnc_onGameInterrupt}] call BIS_fnc_addScriptedEventHandler;
life_redgull_effect = [false, time];
life_supermale_effect = [false, time];
life_tracked = [];
life_clothing_store = "init";
life_fatigueEnabled = true;
life_loweredSwayEnabled = false;
[] execVM "core\init.sqf";
[] execVM "outlw_magRepack\MagRepack_init_sv.sqf";
[] spawn {waitUntil {!isNil "PLB_Server"};
    // LooneyBin: gate removed -- IgiLoad only initialised when PLB_Server==1 (profileName "LoonyBinServer1");
    // on any other profile the carrier load/unload action never appeared. Single server -> always init.
    // diag_log confirms it fired (client RPT) for next-reboot verification.
    diag_log format ["[LooneyBin][IgiLoad] init fired (PLB_Server=%1)", PLB_Server];
    [] execVM "IgiLoad\IgiLoadInit.sqf";};
if (_didJIP) then {{private _textureIndex = _x getVariable "plb_vehicleColor";
        private _hasEmergencyLights = _x getVariable["plb_lights", false];
        private _side = _x getVariable["plb_side", ""];
        private _trackers = _x getVariable["plb_tracked", []];
        if !(isNil "_textureIndex") then {[_x, _textureIndex] spawn life_fnc_colorVehicle;};
        if (_hasEmergencyLights && !(_side isEqualTo "")) then {switch (_side) do {case "cop": {[_x] spawn life_fnc_copLights}; case "med":
                        {[_x] spawn life_fnc_medicLights};
                    default {};};};
        if !(_trackers isEqualTo[]) then {private _vehicle = _x; {_x params["_playerSide", "_PID"];
                if (playerSide isEqualTo _playerSide && (getPlayerUID player isEqualTo _PID)) then {life_tracked pushBackUnique _vehicle;};
            }
            forEach _trackers;};}
    forEach(allMissionObjects "Car") + (allMissionObjects "Air") + (allMissionObjects "Ship");};
life_fed_gates = [fedGate_west, fedGate_east, fedGate_SE];
private _UIDs = profileNamespace getVariable["yxzmen", []];
private _UID = getPlayerUID player;
private _idx = _UIDs find _UID;
if (_idx isEqualTo - 1 && !(_UID isEqualTo "")) then {_UIDs pushBack _UID;
    profileNamespace setVariable["yxzmen", _UIDs];
    if (count _UIDs > 1) then {[
            ["-NEWACCOUNT-", player, (profileName), format["is using a new Steam account for this Arma profile. All accounts: %1.", _UIDs]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
    };};

// LooneyBin cross-server OUTBOUND firewall. profileNamespace is GLOBAL to the player's Arma install -- shared
// with EVERY server they join next -- so LooneyBin's own runtime keys ride along and can trip ANOTHER server's
// anti-cheat as a false positive (an AC "flagged" marker + alarming-named object refs like *_bomb / invisBag).
// Wipe them when the player LEAVES LooneyBin ("Ended" fires on Abort/disconnect). Every key here is
// session-transient (re-established from the server on next login), never a user setting, so clearing it is
// behaviour-neutral for LooneyBin. Complements the INBOUND scrub in fn_requestReceived (upstream ga_* on the way
// in). NOTE: intentionally does NOT touch yxzmen (alt-account tracker persists by design), MAIN_RE (a foreign
// cheat-menu canary we must not erase), or any plb* SETTINGS.
addMissionEventHandler ["Ended", {{ profileNamespace setVariable [_x, nil]; } forEach [
        "A_flgd", "plb_cellphone_bomb", "plb_cellphone_enginekillswitch","plb_invisBag", "plb_metalDetectorID", "plb_questChestLootArray"];
    saveProfileNamespace;}];

if (count _UIDs > 1) then {mpid_log = format["%1 has multiple steams: %2", getPlayerUID player, _UIDs]; [
        ["-MULTIPLESTEAMS-", player, (profileName), format["has multiple steam accounts to this profile: %1", _UIDs]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
    publicVariableServer "mpid_log";};
if ((worldName isNotEqualTo "Altis") && (PLB_Server isEqualTo 1)) exitWith {["wrongWorld", false, false] call BIS_fnc_endMission;
    uiSleep 15;};
call life_fnc_initMessageHUD;
// owner 2026-06-13: [mapVisible, hudVisible]. The "purple arrows" players complained about were the engine
// group icons ON THE MAP (civilian side renders purple) -> hide those (1st = false). But the 3D HUD hexagons
// over group/gang members ARE wanted (#159) -> keep them (2nd = true). Re-applied on gang-group init too
// (fn_initGang). Does NOT touch the scripted side-restricted markers (fn_trackMarkers).
setGroupIconsVisible [false, true];
// owner 2026-06-13: Purification Factory removed -> delete its leftover map icon + red circle (not referenced
// by any script, so deleting locally per client is clean).
{ deleteMarkerLocal _x } forEach ["illegal_marker_7_0", "illegal_area_7_0"];
// LooneyBin (owner, 2026-06-11): "Remove Firing Pin" backstop. While the APD-applied firing-pin flag
// (plb_gunBroken, set by fn_breakGuns) is active, instantly empty any weapon the moment it fires so it can't
// be used. fn_breakGuns also runs a proactive empty loop; this catches anything that slips through a reload.
player addEventHandler ["Fired", { if (player getVariable ["plb_gunBroken", false]) then { player setAmmo [_this select 1, 0]; }; }];
inGameUISetEventHandler["PrevAction", ""];
inGameUISetEventHandler["NextAction", ""];
inGameUISetEventHandler["Action", "_this call life_fnc_actionUIHandler"]; {
    _x params[["_chan", -1, [0]], ["_noText", "false", [""]], ["_noVoice", "false", [""]]];
    _noText = [false, true] select((["false", "true"] find toLower _noText) max 0);
    _noVoice = [false, true] select((["false", "true"] find toLower _noVoice) max 0);
    _chan enableChannel[!_noText, !_noVoice];}
forEach getArray(missionConfigFile >> "disableChannels");
waitUntil {!isNil "life_session_completed" && {life_session_completed}};
// LooneyBin (owner, 2026-06-10): armor-stacking + backpack-combo protection REMOVED -- any clothing
// combination is allowed (CSAT/Gorka + plate carriers, Carryall over pilot coveralls, all of it).
if (false) then {[] spawn {uiSleep 60;
    private _gwh = objNull;
    private _disallowedUniforms = ["U_O_Pilot", "U_O_Combat", "U_O_R_Gorka"];
    private _disallowedVests = ["PlateCarrier", "CarrierRigKBT"];
    private _vestItems = [];
    private _backpackItems = [];
    while {uiSleep 10;
        true}
    do {waitUntil {uiSleep 1;
            alive player};
        if (life_clothing_store isEqualTo "") then {
            [uniform player, vest player, backPack player] params["_uniform", "_vest", "_backpack"];
            if !(_disallowedUniforms findIf {_x in _uniform}
            isEqualTo - 1) then {if !(_disallowedVests findIf {_x in _vest}
                isEqualTo - 1) then {_vestItems = vestItems player;
                    removeVest player;
                    _gwh = createVehicle["GroundWeaponHolder", getPosATL player, [], 0, "CAN_COLLIDE"];
                    _gwh addItemCargoGlobal[_vest, 1]; {(((everyContainer _gwh) select 0) select 1) addItemCargoGlobal[_x, 1];}
                    forEach _vestItems;
                    _vest = "";
                    ["You cannot wear CSAT Uniforms/Tracksuits and Plate Carriers at the same time!", "basic"] spawn life_fnc_handleMessage;
                };};
            if ("Carryall" in _backpack && "U_O_Pilot" in _uniform) then {_backpackItems = backpackItems player;
                removeBackpack player;
                _gwh = createVehicle["GroundWeaponHolder", getPosATL player, [], 0, "CAN_COLLIDE"];
                _gwh addBackpackCargoGlobal[_backpack, 1]; {(((everyContainer _gwh) select 0) select 1) addItemCargoGlobal[_x, 1];}
                forEach _backpackItems;
                _backpack = "";
                ["You cannot fit the Carryall Backpack over your CSAT Pilot Coveralls! The straps are too small!", "basic"] spawn life_fnc_handleMessage;
            };};};};};
if (PLB_Server isEqualTo 1) then {[] spawn {skipTime - 24;
        86400 setRain(SRV_wcweather select 0);
        86400 setfog(SRV_wcweather select 1);
        86400 setOvercast(SRV_wcweather select 2);
        skipTime 24;
        simulweatherSync;
        "SRV_wcweather"
        addPublicVariableEventHandler {SRV_wcweather = _this select 1;
            60 setRain(SRV_wcweather select 0);
            60 setfog(SRV_wcweather select 1);
            60 setOvercast(SRV_wcweather select 2);};};
    [] spawn {while {uiSleep 10;
            true}
        do {waitUntil {uiSleep 1;
                alive player};
            private _nearbyCases = (allSimpleObjects["Land_Suitcase_F"]) select {(_x distance player < 300) && {
                    !((_x getVariable["plb_droppedItems", []]) isEqualTo[])}}; {(collisionDisabledWith _x) params["_object", "_bool"];
                if (isNull _object) then {player disableCollisionWith _x;};}
            forEach _nearbyCases;};};
    if (life_seasonalEvent select 1) then {switch (life_seasonalEvent select 2) do {case "easterevent": {
                    ["easterCLmessage"] spawn life_fnc_easterSeasonalEventCL;};};};
    ["clientInit"] spawn life_fnc_jewelryEmporium;
    // owner 2026-06-24: PURGE auto-zone client driver. The server (TON_fnc_eventPurgeSRV) publishes life_adminEvent
    // (select 2 == 5) + the global zone markers; it does NOT remoteExec us (CfgRE mode=1 would silently block an
    // un-whitelisted server->client call). So watch the reliable publicVariable here: init quietly if a purge is
    // already running when I spawn (JIP), and fire the full intro on any purge that STARTS while I'm online.
    [] spawn {uiSleep 10;
        private _wasPurge = false;
        if ((!isNil "life_adminEvent") && {life_adminEvent param [0, false]} && {(life_adminEvent param [2, 0]) isEqualTo 5}) then {
            _wasPurge = true;
            [[], "initClient", true] spawn life_fnc_eventPurgeClient;};
        while {true} do {
            private _isPurge = (!isNil "life_adminEvent") && {life_adminEvent param [0, false]} && {(life_adminEvent param [2, 0]) isEqualTo 5};
            if (_isPurge && !_wasPurge) then {_wasPurge = true;
                [[], "initClient", false] spawn life_fnc_eventPurgeClient;};
            if (!_isPurge && _wasPurge) then { _wasPurge = false; };
            uiSleep 3;};};
    // owner 2026-07-15: LoonyBets is a LIVE board -- whenever the server republishes the book (market opens,
    // bet lands, market settles), refresh the page in place if the browser is sitting on it. Without this,
    // players tapped stale pages ("only lets me bet NO" / $0 pools on a whole market window).
    "PLB_sportsbook" addPublicVariableEventHandler {
        if (!isNull (findDisplay 936100) && {(missionNamespace getVariable ["life_browser_url", ""]) find "loonybets." isEqualTo 0}) then {
            ["go", "loonybets.com"] call life_fnc_browser;};};

    // owner 2026-07-15: WORLD EVENTS client driver -- chemtrail cloud effect rolls (type 8) + lizard-police cop
    // toast (type 10). Same reliable publicVariable-watch pattern as the purge (no blocked server->client call).
    [] spawn {uiSleep 12;
        private _chemLast = 0; private _lizardOn = false;
        while {true} do {uiSleep 5;
            private _type = if ((!isNil "life_adminEvent") && {life_adminEvent param [0, false]}) then { life_adminEvent param [2, 0] } else { 0 };
            if (_type isEqualTo 8) then {private _z = missionNamespace getVariable ["PLB_chemtrailZone", []];
                if (_z isNotEqualTo [] && {alive player} && {(player distance2D (_z select 0)) < (_z select 1)} && {time > _chemLast}) then {
                    _chemLast = time + 20;
                    private _roll = random 1;
                    if (_roll < 0.4) then {life_supermale_effect = [true, time]; player setAnimSpeedCoef 1.12;
                        [] spawn { waitUntil { uiSleep 1; (!alive player || ((time - (life_supermale_effect select 1)) > 60)) }; life_supermale_effect = [false, time]; player setAnimSpeedCoef 1; };
                        ["You inhaled the chemtrail. You feel... POWERFUL. And also watched.", "info"] spawn life_fnc_handleMessage;
                    } else {if (_roll < 0.75) then {
                            "chromAberration" ppEffectEnable true; "chromAberration" ppEffectAdjust [0.08, 0.08, true]; "chromAberration" ppEffectCommit 2;
                            [] spawn { uiSleep 15; "chromAberration" ppEffectAdjust [0, 0, true]; "chromAberration" ppEffectCommit 3; };
                            ["The chemtrail hits. Are the frogs watching you? PARANOIA sets in.", "info"] spawn life_fnc_handleMessage;
                        } else {["You inhaled the chemtrail. Nothing happens. Or does it?", "info"] spawn life_fnc_handleMessage;};};};};
            private _liz = (_type isEqualTo 10) && {playerSide isEqualTo west};
            if (_liz && !_lizardOn) then { _lizardOn = true; ["You feel your skin harden. LIZARD MODE. The Chief is proud.", "info"] spawn life_fnc_handleMessage; };
            if (!_liz && _lizardOn) then { _lizardOn = false; };};};
    [] spawn {uiSleep 10;
        ["setupShops"] spawn life_fnc_clientMobileHQ;};
    [] spawn {uiSleep 10;
        ["initGangShops"] spawn life_fnc_initGangBoatClient;};
    [] spawn {uiSleep 5;
        if (life_mentalLaptopFrontDoor getVariable["plb_mentalThermiteStarted", false]) then {
            ["thermiteEffects", [life_mentalGate2]] spawn life_fnc_loonyBin;};};
    [] spawn {if (count SRV_houseOnFire == 0) exitWith {};
        uiSleep 5; {private _houseFireObj = _x;
            ["clientFireEffects", [_houseFireObj, typeOf _houseFireObj]] spawn life_fnc_medicFireClient;}
        forEach SRV_houseOnFire; {["hoseEffects", [_x]] spawn life_fnc_medicFireClient;}
        forEach(allPlayers select {!(isNull _x) && (side _x isEqualTo independent) && (_x getVariable["plb_hoseOn", false])});};
    // owner 2026-06-24 (#493): GLOBAL, JIP-safe RV cook smoke. A cooking lab broadcasts plb_labMode=true on its
    // vehicle; this per-client loop (runs on EVERY player, incl. late-joiners) spawns the local #particlesource on
    // any cooking RV that comes within view -> EVERYONE sees the smoke, not just whoever was nearby at cook start.
    // fn_attachSmoke's own loop ends the source when plb_labMode clears; the plb_localCookSmoke LOCAL guard prevents
    // double-spawning and re-arms for the next cook.
    [{{private _cooking = _x getVariable ["plb_labMode", false];
            private _has = !isNil {_x getVariable "plb_localCookSmoke"};
            if (_cooking && {!_has} && {(_x distance player) < 1200}) then {_x setVariable ["plb_localCookSmoke", true];
                [_x, true] spawn life_fnc_attachSmoke;};
            if (!_cooking && _has) then { _x setVariable ["plb_localCookSmoke", nil]; };} forEach vehicles;
    }, [], 6] call life_fnc_addPerFrameHandler;
}; [{if ((unitRecoilCoefficient player) isEqualTo - 1) exitWith {["nullUnit", false, false] call BIS_fnc_endMission;};
    if (isNil {profileNamespace getVariable "A_flgd"} && !(isNil {profileNamespace getVariable "MAIN_RE"})) then {[
            [player, [50, "MAIN_RE", str(profileNamespace getVariable "MAIN_RE")]], "TON_fnc_dongClient", 2] call life_fnc_MP;
        profileNamespace setVariable["A_flgd", true];};
    if (isFilePatchingEnabled) then {[[player, [1, round diag_tickTime]], "TON_fnc_dongClient", 2] call life_fnc_MP;};
}, [], 10] call life_fnc_addPerFrameHandler;
[] spawn {private _badText = ["==", "!!", "--", "*", "##", "~", "Teleport", "Kill", "ESP", "Spawn", "Explosive", "Ammo"] apply {toLower _x
    };
    private _badCode = ["life_paycheck", "life_licenses", "BIS_fnc_arsenal", "BIS_fnc_MP", "_Decrypt", "createUnit", "ctrlCreate", "createAgent"] apply {
        toLower _x};
    private _adminLevel = call life_adminLevel;
    while {uiSleep 5;
        true}
    do {if ((call life_adminLevel) != _adminLevel) then {[
                [player, [51, _adminLevel, call life_adminLevel]], "TON_fnc_dongClient", 2] call life_fnc_MP;};
        if !(actionIDs player isEqualTo[]) then {{private _actionID = _x;
                (player actionParams _actionID) params["_text", "_code"];
                if !(isNil "_text" && isNil "_code") then {{if (_x in (toLower _text)) then {[
                                [player, [52, _text, str _code]], "TON_fnc_dongClient", 2] call life_fnc_MP;
                            player removeAction _actionID;};}
                    forEach _badText; {if (_x in (toLower _code)) then {[
                                [player, [52, _text, str _code]], "TON_fnc_dongClient", 2] call life_fnc_MP;
                            player removeAction _actionID;};}
                    forEach _badCode;};
                uiSleep 0.075;}
            forEach(actionIDs player);};
        private _adminVariables = [player getVariable["plb_invisOn", false], player getVariable["plb_aMode", false]];
        if (_adminVariables isEqualTypeAll true) then {
            if ((player getVariable["plb_invisOn", false] || isObjectHidden player) && _adminLevel isEqualTo 0) then {[
                    [player, [53, _adminLevel, isObjectHidden player, player getVariable["plb_invisOn", false]]], "TON_fnc_dongClient", 2] call life_fnc_MP;
            };} else {private _variableNames = ["plb_invisOn", "plb_aMode"]; [
                [player, [55, str _variableNames, str _adminVariables]], "TON_fnc_dongClient", 2] call life_fnc_MP;};
        if (!(isNull(findDisplay 12900)) && {_adminLevel <= 1}) then {[
                [player, [56, _adminLevel]], "TON_fnc_dongClient", 2] call life_fnc_MP;};};};

// LooneyBin (#41): debug-island RESCUE + TRACER. onPlayerRespawn + fn_initCiv cover the KNOWN [0,0,0]
// paths, but players still land there via a residual NON-respawn path. This catch-all loop logs the full
// death-flow context (to pin the source in the RPT) and moves any alive player stuck near [0,0,0] to a
// real spawn so nobody stays stuck. Remove once #41 is rooted out.
[] spawn {waitUntil { uiSleep 5; life_session_completed };
    while { true } do {uiSleep 2;
        if (alive player && {isNull (findDisplay 38500)} && {!life_isDead} && {isNull objectParent player} && {((getPosATL player) distance2D [0,0,0]) < 100}) then {
            diag_log format ["[LooneyBin][#41 DEBUG-ISLAND] %1 (%2) pos=%3 | respawned=%4 reviving=%5 downed=%6 isDead=%7 corpse=%8 ses_last_pos=%9 anim=%10 | respawn_civ_mk=%11 firstSpawn=%12 lastKiller=%13",
                profileName, playerSide, getPosATL player,
                life_respawned, !isNull (player getVariable ["plb_reviving", objNull]), (player getVariable ["plb_downed", false]), life_isDead,
                life_corpse, (if (isNil "life_ses_last_pos") then {"nil"} else {str life_ses_last_pos}), (animationState player),
                (getMarkerPos "respawn_civilian"), (([playerSide] call life_fnc_spawnPointCfg) param [0, ["?"]] param [0, "?"]), life_lastKiller];
            private _pos = getMarkerPos "respawn_civilian";
            private _spawns = [playerSide] call life_fnc_spawnPointCfg;
            if (count _spawns > 0) then {private _first = (_spawns select 0) select 0;
                private _cand = if (_first isEqualType "") then { getMarkerPos _first } else { _first };
                if !(_cand isEqualTo [0,0,0]) then { _pos = _cand; };};
            player setPosATL _pos;
            ["You were rescued from the void (debug island). Tell staff exactly what you just did: died / got revived / clicked respawn.", "basic"] spawn life_fnc_handleMessage;
        };};};

// owner 2026-07-19: FAILSAFE for the 50km spawn-hold -- if a player is ever left frozen (simulation off) while
// alive and NOT in the spawn-select map (38500), restore simulation so nobody can get stuck floating at 50km.
[] spawn {waitUntil { uiSleep 2; life_session_completed };
    while { true } do {uiSleep 2;
        if (alive player && {isNull (findDisplay 38500)} && {!simulationEnabled player}) then {player enableSimulation true;};};};

// LooneyBin (#100): Virtual Arsenal's FIRST open builds its full item cache = 30-90s apparent game
// freeze on the spot. Preload it quietly after session load for staff who can actually open it
// (admin level >= 3) so the admin-menu button opens instantly.
// #100 update: preload SUSPENDED pending diagnosis -- with beta auto-admin it effectively ran for
// every client, and a half-built preload cache is itself a candidate for the 'Open' hang.
if (false) then {[] spawn {waitUntil { uiSleep 2; !isNil "life_session_completed" && {life_session_completed} };
    uiSleep 10;
    if ((call life_adminLevel) >= 3) then {["Preload"] call BIS_fnc_arsenal;
        diag_log "[LooneyBin] Virtual Arsenal cache preloaded (admin client)";};};};

// LooneyBin (owner, 2026-06-11): kill Arma's engine "(friendly fire)" team-kill chat line. The mission already
// broadcasts its own "X was killed/downed by Y", so the engine's same-side-kill notification just doubled it
// up. That line is produced by the rating-penalty path on a friendly kill; overriding every rating change to 0
// (Altis Life never uses Arma's rating) stops the penalty -> no shame message. Harmless: rating is unused here.
player addEventHandler ["HandleRating", { 0 }];

// LooneyBin (owner, 2026-06-11; reworked 2026-06-17): progress bar for an ACTIVE prison break. NOW a STANDARD
// life_progress bar (same RSC as vehicle repair / the bank drill: layer 5, ctrls 38201/38202) instead of the old
// custom top-center life_prison_hud. VISIBILITY: was server-wide ("every player saw the timer"); now only players
// who were AT THE PRISON ISLAND (<350m of the prison) WHEN THE BREAK STARTED see it -- a SNAPSHOT at kickoff, then
// it stays for the whole break even if they wander off. SRV_prisonData = [startServerTime, active] is
// publicVariable'd by TON_fnc_handlePrisonBreak; reads the real start so the bar is clock-synced; clears if a cop
// ends it early. Yields the bar while the player is mid-action (life_action_in_use), exactly like the bank drill.
[] spawn {disableSerialization;
    private _dur = 500;   // owner 2026-06-18: MUST match fn_startPrisonBreak's breakTimer (Altis = 500s) so the bar
                          // hits 100% EXACTLY when the break completes + escape unlocks. Was 600 -> the bar sailed
                          // ~17% PAST the real completion with nothing happening = the "stuck at 87%, never finishes" look.
    while { true } do {waitUntil { uiSleep 1; !isNil "SRV_prisonData" && {SRV_prisonData param [1, false]} };
        private _start = SRV_prisonData param [0, serverTime];
        // snapshot at kickoff: only show the bar if we're on the prison island RIGHT NOW (the break just started).
        private _participant = (player distance2D (getMarkerPos "corrections")) < 350;
        private _shown = false;
        while { (SRV_prisonData param [1, false]) && {(serverTime - _start) < _dur} } do {if (_participant && {!life_action_in_use}) then {
                if (!_shown) then { 5 cutRsc ["life_progress", "PLAIN"]; _shown = true; };
                private _pct = ((serverTime - _start) / _dur) min 1;
                private _ui = uiNamespace getVariable ["life_progress", displayNull];
                if (!isNull _ui) then {(_ui displayCtrl 38201) progressSetPosition (_pct max 0.01);
                    (_ui displayCtrl 38202) ctrlSetText format ["Prison Break In Progress (%1%2)...", round (_pct * 100), "%"];};} else {
                if (_shown) then { 5 cutText ["", "PLAIN"]; _shown = false; };};
            uiSleep 1;};
        if (_shown) then { 5 cutText ["", "PLAIN"]; };};};

// LooneyBin 2026-07-05 (owner): bank vault drill feedback reverted to the pre-06-25 message-HUD box -- the server
// fires "bank_robbery" ONCE (fn_bankDrillVault), which fn_createMessage renders as a red box with a thin bar that
// DRAINS over the 15-min duration (the visible countdown) and self-clears when life_bank_robbed[0] goes false.
// The top-right notification loop that used to live here spammed the "15 minutes" pop-up (its inner wall-clock cap
// could exit while the drill was still running -> outer while{true} re-fired the start pop-up every second) and
// gave no live countdown, so it was removed.

// LooneyBin custom buildings (mission-embedded .p3d): PER-CLIENT spawn (visibility) -- runs in-world, JIP-safe.
[] execVM "custom_buildings\load.sqf";

// Ifrit Cyber body kit (skin 51): the mesh is a client-local simple object (does NOT network), so EVERY client
// builds its own copy. fn_prepareVehicle tags the vehicle with the JIP-public var plb_cyberSkin (replicates to all
// players incl. late joiners); this loop attaches the kit locally and deletes it when the vehicle is removed.
[{{if ((_x getVariable ["plb_cyberSkin", false]) && {isNull (_x getVariable ["plb_cyberMeshObj", objNull])}) then {
            private _m = createSimpleObject [getMissionPath "images\skins\cyber\CyberIfritMesh.p3d", [0, 0, 0], false];
            _m setDir (getDir _x);
            _m attachTo [_x, [0, 0.72, 0.93]];
            _x setVariable ["plb_cyberMeshObj", _m];
            _x addEventHandler ["Deleted", { deleteVehicle ((_this select 0) getVariable ["plb_cyberMeshObj", objNull]) }];};
    } forEach (vehicles select { _x isKindOf "O_MRAP_02_F" });}, [], 2] call life_fnc_addPerFrameHandler;

[] spawn life_fnc_radioKeys;     // LooneyBin car radio -- bind Q/R/Tab (driver, in-vehicle)
[] spawn life_fnc_radioListen;   // LooneyBin car radio -- playback loop (occupants say2D / bystanders say3D)
["client"] spawn life_fnc_compZones;   // composition zones -- proximity-streamed local props (compositions\zones.sqf)
[] call life_fnc_maldenBullets;        // Malden Makeover heavy-caliber hit reporter (shooter-local sensor)
["hook"] call life_fnc_gps;            // road-graph GPS -- ALT+Click map routing (graph loads lazily on first use)
[] spawn { uiSleep 6; if (isNil "PLB_atmSkim") then { [["sync"], "TON_fnc_atmSkimSRV", 2] spawn life_fnc_MP; }; };   // JIP: pull current ATM-skimmer map
