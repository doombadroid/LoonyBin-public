["waitForPlay"] call life_fnc_welcomeUI;
civ_spawn_1 = nearestObjects[getMarkerPos "civ_spawn_1", ["Land_i_Shop_01_V1_F", "Land_i_Shop_02_V1_F", "Land_i_Shop_01_V1_dam_F", "Land_i_Shop_02_V1_dam_F", "Land_i_Barracks_V1_F", "Land_i_Barracks_V2_dam_F", "Land_i_Barracks_V2_F", "Land_i_Garage_V1_F"], 100];
civ_spawn_2 = nearestObjects[getMarkerPos "civ_spawn_2", ["Land_i_Shop_01_V1_F", "Land_i_Shop_02_V1_F", "Land_i_Shop_01_V1_dam_F", "Land_i_Shop_02_V1_dam_F", "Land_i_Barracks_V1_F", "Land_i_Barracks_V2_dam_F", "Land_i_Barracks_V2_F", "Land_i_Garage_V1_F"], 100];
civ_spawn_3 = nearestObjects[getMarkerPos "civ_spawn_3", ["Land_i_Shop_01_V1_F", "Land_i_Shop_02_V1_F", "Land_i_Shop_01_V1_dam_F", "Land_i_Shop_02_V1_dam_F", "Land_i_Barracks_V1_F", "Land_i_Barracks_V2_dam_F", "Land_i_Barracks_V2_F", "Land_i_Garage_V1_F"], 100];
civ_spawn_4 = nearestObjects[getMarkerPos "civ_spawn_4", ["Land_i_Shop_01_V1_F", "Land_i_Shop_02_V1_F", "Land_i_Shop_01_V1_dam_F", "Land_i_Shop_02_V1_dam_F", "Land_i_Barracks_V1_F", "Land_i_Barracks_V2_dam_F", "Land_i_Barracks_V2_F", "Land_i_Garage_V1_F"], 100];
donor_town = nearestObjects[getMarkerPos "donor_town", ["Land_i_Shop_01_V1_F", "Land_i_Shop_02_V1_F", "Land_i_Shop_01_V1_dam_F", "Land_i_Shop_02_V1_dam_F", "Land_i_Barracks_V1_F", "Land_i_Barracks_V2_dam_F", "Land_i_Barracks_V2_F", "Land_i_Garage_V1_F"], 150];
waitUntil {!(isNull(findDisplay 46))};
private _thread = [] spawn {[[getPlayerUID player, profileName, A_stats_crimes], "TON_fnc_bulkAdd", 2] spawn life_fnc_MP;};
// LooneyBin: type-safe arrested check. life_is_arrested must be an array whose [0]==1 to mean
// "in jail". A nil/malformed value (bad DB decode) was passing the old `select 0 isEqualTo 1`
// (or aborting it) -> player wrongly sent to fn_jailPlayer -> setPosATL getMarkerPos "jail_marker2"
// (a marker that doesn't exist in mission.sqm) -> [0,0,0] debug island, stuck. param[0,0]
// defaults to 0 for empty/short arrays, so only a genuine [1,...] jails.
if ((life_is_arrested isEqualType []) && {(life_is_arrested param [0,0]) isEqualTo 1}) then {waitUntil {scriptDone _thread};
    [player, false, false, false, true] spawn life_fnc_jailPlayer;} else {
    // LooneyBin: only treat as a returning-player teleport if life_ses_last_pos is a real position
    // array (3+ numbers). A junk sentinel (string/[[]]/[]) must fall through to the spawn menu;
    // otherwise `life_ses_last_pos distance [0,0,0]` throws and the player is never positioned.
    // owner 2026-06-20 (#SOFTLOG instrument): the owner STILL hits the spawn-selection menu on relog while
    // alive, but the entire load chain (queryRequest col 11 -> packet[17] -> requestReceived:183 -> here)
    // checks out in static analysis AND in the live DB (a real 3-number position, far from spawn+origin).
    // fn_initCiv runs CLIENT-side so its diag_log is invisible (can't read client RPT) -- mirror the EXACT
    // decision state to the SERVER log via TON_fnc_logIt so the NEXT relog tells us which sub-condition
    // actually fails at runtime instead of guessing a 4th positional fix. One row per civ login; remove once
    // the cause is pinned. `_slpOK`/`_farOK` mirror the real branch predicates below (no behaviour change).
    private _slpOK = (life_ses_last_pos isEqualType []) && {count life_ses_last_pos > 2} && {(life_ses_last_pos select 0) isEqualType 0} && (PLB_Server isEqualTo 1);
    private _farOK = if (_slpOK) then { (life_ses_last_pos distance [0,0,0]) > 500 } else { false };
    private _branch = if (_slpOK && _farOK) then { "TELEPORT" } else { if (_slpOK) then { "MENU(near-origin<=500)" } else { "MENU(bad-pos/PLB_Server)" } };
    [["-SOFTLOG-", player, name player, format ["spawnDecide branch=%1 ses_last_pos=%2 type=%3 cnt=%4 PLB_Server=%5 arrested=%6", _branch, str life_ses_last_pos, typeName life_ses_last_pos, (if (life_ses_last_pos isEqualType []) then { count life_ses_last_pos } else { -1 }), PLB_Server, str life_is_arrested]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
    if ((life_ses_last_pos isEqualType []) && {count life_ses_last_pos > 2} && {(life_ses_last_pos select 0) isEqualType 0} && (PLB_Server isEqualTo 1)) then {
        private _plb_dmg = player;
        plbv_thirst = profileNamespace getVariable["plb_thirst", 100];
        plbv_hunger = profileNamespace getVariable["plb_hunger", 100];
        player setDir(profileNamespace getVariable["plb_playerDir", 0]);
        _plb_dmg setDamage(profileNamespace getVariable["plb_playerDamage", 0]);
        if (life_ses_last_pos distance[0, 0, 0] > 500) then {if ((life_ses_last_pos select 2) > 50) then {life_ses_last_pos set[2, 0];};
            private _rebelMarkers = ["Rebelop_1", "Rebelop_2", "Rebelop_3", "Rebelop_4", "Rebelop_5", "Rebelop_6"];
            private _markerIndex = _rebelMarkers findIf {life_ses_last_pos distance(getMarkerPos _x) <= 150};
            if !(_markerIndex isEqualTo - 1) then {private _marker = _rebelMarkers select _markerIndex;
                private _toSend = (allPlayers select {
                    isPlayer _x && _x distance(getMarkerPos _marker) <= 150 && !(life_gang_data param[0, -33] isEqualTo(_x getVariable["gang_data", [-22]] select 0))
                }) - [player];
                if (_toSend isEqualTo[]) exitWith {}; [[
                        [0, 1, 2], "A potentially hostile player has entered the world nearby!"], "life_fnc_broadcast", _toSend] spawn life_fnc_MP;
            };
            private _zone = dynamicMap_zoneLocations param[dynamicMap_zoneLocations findIf {
                ((life_ses_last_pos distance2D(_x select 0)) < _x select 1)}, []];
            waitUntil {missionNamespace getVariable[format["dynamicMap_%1_status", _zone param[2, -1]], "active"] isEqualTo "active"};
            if (surfaceIsWater life_ses_last_pos) then {player setPosASL life_ses_last_pos} else {player setPosATL life_ses_last_pos};
        } else {[] call life_fnc_spawnMenu;
            waitUntil {!isNull(findDisplay 38500)};
            waitUntil {isNull(findDisplay 38500)};};} else {
        // owner 2026-07-11: THE INTAKE Act 1 -- a fresh account (players.intake_path = 0, veterans are
        // grandfathered to 9) never sees the spawn menu: they wake up committed inside the Loony Bin
        // (cinematic -> padded-ward basics -> interview -> release into Kavala). Disconnecting mid-intake
        // leaves the flag 0, so it simply runs again next login. Everyone else: spawn menu as always.
        if (life_intakePath isEqualTo 0) then {["start"] spawn life_fnc_intake;} else {[] call life_fnc_spawnMenu;
            waitUntil {!isNull(findDisplay 38500)};
            waitUntil {isNull(findDisplay 38500)};};};};
// owner 2026-07-11 (PAROLE PAPERS, Act 2): a relog mid-arc resumes the contract chain from the persisted
// step (players.intake_step, login payload slot 39). Fresh intake sessions start it themselves.
if ((life_intakePath in [1, 2, 3]) && {(missionNamespace getVariable ["life_intakeStep", 255]) <= 4}) then {
    [] spawn { uiSleep 12; ["start"] call life_fnc_parole; };};
// owner 2026-06-21 (PFH leak): register the 240s civ save-loop ONCE per session. fn_initCiv re-runs within a
// session, and the custom PFH system has NO removePerFrameHandler + this call never captured its handle ->
// duplicate handlers ACCUMULATED -> the same position+gear save fired 2-3x per cycle (confirmed live: Spark /
// kiosk / Mr player104 each saved position 3x within 5s), tripling the holding-area position-blank odds + the log
// spam. Guard on a handle in life_civSavePFH (reset to nil per connect in init.sqf next to the
// life_eachFrameHandlerArray reset) so exactly one handler exists per session.
if (isNil "life_civSavePFH") then {life_civSavePFH = [{if (alive player) then {[10] call life_fnc_ClupdatePartial;
            // owner 2026-06-19 (kit-loss-on-restart cluster #408/#409/#413/#414/#416/#417/#418): civ gear was persisted
            // ONLY on an inventory CHANGE (handleInv/saveGear) and at the T-55 scheduled-restart sync. A crash / deploy /
            // manual hard-restart (watchdog pkill -> no disconnect handler fires) reverted gear to the last change-save =
            // "lost my kit". Persist worn gear every cycle too. saveGear self-gates (arrest / dead / near-cop-spawn) and
            // mode-3 self-dedups (life_lastSynced_gear), so this only writes when the kit actually changed -> an ungraceful
            // exit now loses <=4 min, not the whole loadout. Skip during clothing-store edits (finalized on store close).
            if (life_clothing_store isEqualTo "") then { [true] call life_fnc_saveGear; };};}, [], 240] call life_fnc_addPerFrameHandler;};
// owner 2026-06-21: REMOVED the proximity fed-alarm trigger. The alarm used to trip from standing inside fedWalls
// on foot, holding any robbery item, on a random roll (the "fed triggers too easy" report #449). Per owner, the
// Federal Reserve alarm now fires ONLY when a gate is bolt-cut (fn_openGate -> TON_fnc_fedRobbery) or a dome side
// door is hacked (fn_openVault -> TON_fnc_fedRobbery). The matching server-side UNMASKED-ENTRY-within-175m trigger
// in life_server/init.sqf is removed too. (Nothing replaces this per-frame handler -- the robbery is action-driven now.)
[{if (((A_stats_crimes param[0, 0]) > 10000)) then {private _toSend = (allPlayers - [allDeadMen] - [player]) select {
            side _x isEqualTo west || (side _x isEqualTo civilian && _x getVariable["plb_isBountyHunter", false])};
        if ((round(random 1)) isEqualTo 0) then {
            private _nearTown = (player distance(getMarkerPos "city") < 250) || (player distance(getMarkerPos "donor_town") < 250) || (player distance(getMarkerPos "civ_spawn_2") < 250) || (player distance(getMarkerPos "civ_spawn_3") < 250) || (player distance(getMarkerPos "civ_spawn_4") < 250);
            if (_nearTown) then {[[7, profileName, "0", player], "life_fnc_clientMessage", _toSend] spawn life_fnc_MP;} else {
                private _marker = [allMapMarkers, player] call BIS_fnc_nearestPosition;
                if ((getMarkerColor _marker) in ["ColorRed", "ColorEast"]) then {if !("_USER_DEFINED" in _marker) then {
                        if ((player distance2D(getMarkerPos _marker) < 300)) then {[
                                [7, profileName, "1", player], "life_fnc_clientMessage", _toSend] spawn life_fnc_MP;};};};};};};
}, [], 300] call life_fnc_addPerFrameHandler; [{if (!license_civ_bounty || !(8 in life_side_talents)) then {
        if (alive player && !(life_isDead)) then {private _currentWeapon = primaryWeapon player;
            if (_currentWeapon in ["arifle_MX_F", "arifle_MXC_F", "arifle_MX_khk_F"]) then {
                private _gwh = createVehicle["GroundWeaponHolder", getPosATL player, [], 0, "CAN_COLLIDE"];
                private _gItems = primaryWeaponItems player;
                player removeWeapon(primaryWeapon player);
                _gwh addWeaponCargoGlobal[_prev, 1]; {_gwh addItemCargoGlobal[_x, 1]}
                forEach _gItems;
                ["You cannot carry an MX without a BH License and the Master Bounty Hunter Talent!", "basic"] spawn life_fnc_handleMessage;
            };};};}, [], 10] call life_fnc_addPerFrameHandler;
if ((license_civ_bounty)) then {
    // owner 2026-06-20 (#447, decision A = NO bounty persistence): this fired a per-connect SELECT on the (always
    // empty) `bounties` table and MP'd to life_fnc_persistentBounties, which doesn't exist -- the whole persistence
    // chain is half-built (requestBounty never writes the table, no receiver fn, target/hunter query mismatch) and
    // was the source of the old "BH stuck tracking a $0 ghost" bug. Bounties intentionally do NOT survive a relog;
    // the BH re-requests after login. Trigger disabled. To re-enable (decision B) restore this + build the save side.
    // [[getPlayerUID player], "TON_fnc_srvPersistentBounties", 2] spawn life_fnc_MP;
    player setVariable["plb_isBountyHunter", true, true];};
life_maxTalents = 20;
[] call life_fnc_verifyTalents;
[] spawn life_fnc_trackMarkers;
if (SRV_ufoCrash select 0) then {uiSleep 5;
    [(SRV_ufoCrash select 3)] spawn life_fnc_ufoCrash;};
[] spawn life_fnc_serverInfoMessages;
if (true) then {
    if ((A_stats_civTime <= 180) || ((profileNamespace getVariable["plb_tutorialProgress", -1]) < 14) && (A_stats_civTime <= 180)) then {
        [] spawn {uiSleep 5;
            [] spawn life_fnc_tutorialNewPlayer;};} else {if (A_stats_civTime >= 180 && A_stats_civTime <= 360) then {
            [format["<t color='#FF0000'><t size='1.5'><t align='center'>Tutorials<br/><br/></t></t></t>We see that you have completed our message tutorials but you are still a fairly new player, we'd like to give you a friendly reminder that you can always checkout the tutorials in your phone by pressing y and clicking on the tab tutorials"], "warning"] spawn life_fnc_handleMessage;
        };
        profileNamespace setVariable["plb_tutorialProgress", 14];};
    // LooneyBin (owner, 2026-06-11): passive mode for new players REMOVED -- no auto-enable, no "new player is
    // invulnerable" message. New players spawn vulnerable like everyone else.
};
[] spawn {uiSleep 7.5;
    if !((profileNamespace getVariable["plb_questChestLootArray", []]) isEqualTo[]) then {if (isNil "life_questChestTask") then {
            ["spawnLootChest", "spawnLootChest", 1] spawn life_fnc_handleQuest;};};};
[] spawn {uiSleep 30;
    life_loginBonusData params["_playerUID", "_consecutiveDays", "_needsGift", "_wipeProgress"];
    if ((_needsGift)) then {
        ["You have a login bonus available for you! Type !loginbonus to retrieve it.", "login_bonus"] spawn life_fnc_handleMessage;};};
[] spawn {if (!("winter" in SRV_enabledSeasonalEvents)) exitWith {};
    uiSleep 30;
    life_christmasTreeGiftData params["_playerUID", "_needsGift"];
    if ((_needsGift)) then {
        ["You have not opened your christmas gift yet, go to the christmas tree to open your gift.", "christmas_present"] spawn life_fnc_handleMessage;
    };};
[] spawn {uiSleep 8;
    private _nearbyBoomBoxes = player nearObjects["Land_BatteryPack_01_closed_black_F", 350];
    if (_nearbyBoomBoxes isNotEqualTo[]) then {{["initMusic", [_x]] spawn life_fnc_boomBox;}
        forEach _nearbyBoomBoxes;};};
[] spawn {uiSleep 10;
    ["missedMessages"] spawn life_fnc_initGangFortClient;
    ["missedMessages"] spawn life_fnc_initGangBoatClient;};

// owner 2026-07-12: everyone carries a GPS -- the map's G-search / route HUD is gated on it
if !("ItemGPS" in assignedItems player) then { player linkItem "ItemGPS"; };
// owner 2026-07-15: re-link after a beat -- fn_loadGear (login/respawn gear restore) can strip assignedItems
// AFTER this init runs, leaving civs GPS-less. A short delayed re-link survives that clobber.
[] spawn { uiSleep 6; if (alive player && {!("ItemGPS" in assignedItems player)}) then { player linkItem "ItemGPS"; }; };
