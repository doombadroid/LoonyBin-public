/*
    TON_fnc_gangFortressSRV  (LooneyBin -- owner request 2026-06-10, outposts+persistence 2026-06-11)
    Server controller for the GANG FORTRESS event. The 2020 client (fn_initGangFortClient / HUD) draws
    the capture zone + spawns rebel-outpost shop NPCs from SRV_tempGangRebel; this server side creates
    those NPCs + map markers, runs the 1-hour scoring loop, and PERSISTS everything in the `gangfort`
    table so the event/ownership survives a reboot until the next pop.

    Modes (client admin menu / boot send):
      "start" : arm for 1 hour. Every 5s the single gang holding the 125m zone uncontested earns 5 pts.
                Two temporary safezone rebel outposts (weapon + vehicle NPC each) + map markers spawn.
      "stop"  : end early (same finish path).
      "load"  : (server boot) restore from DB -- resume an unfinished event with remaining time, or
                re-apply the last winner's ownership of the fortress shops.

    DB `gangfort` (single row id=1): active, ends(unix), winner_id, winner_name, leaderboard(mres).
    SRV_gangFortressData = [[id,name,pts],..] (client HUD). Flag plb_gang_fortress_data = [leadID, name, ACTIVE].
*/
params [["_mode", "", [""]], ["_caller", objNull, [objNull]]];
// owner 2026-07-24 SECURITY (audit): CfgRE allowedTargets=2 with NO authorisation -- the admin gate lived
// only in the admin-menu button (admin_menu.hpp:537, `(call life_adminLevel) >= 3`), so any client could
// remoteExec ["start"] or ["stop"] and arm or kill the hour-long Gang Fortress KotH event at will,
// including wiping an in-progress event's scoring. Re-query the level from players_global for the
// NON-SPOOFABLE caller and require the same >= 3 the button asks for (pattern from fn_createAdminVeh).
// Only the admin-triggered modes are gated: "load" is the server boot restore and the scheduled
// Wed/Sun auto-start both run server-internal (_src == 0), which passes untouched.
private _srcGF = remoteExecutedOwner;   // 0 == server-internal (boot restore / scheduled auto-start) = trusted
private _gfBlocked = false;
if (_srcGF isNotEqualTo 0 && {_mode in ["start", "stop"]}) then {
    private _gfCaller = (allPlayers select { owner _x isEqualTo _srcGF }) param [0, objNull];
    private _gfLvl = if (isNull _gfCaller) then { 0 } else {
        private _rows = [format ["SELECT CAST(adminlevel AS SIGNED) FROM players_global WHERE playerid='%1'", getPlayerUID _gfCaller], 2, true] call DB_fnc_asyncQuery;
        parseNumber format ["%1", (_rows param [0, [0]]) param [0, 0]]};
    if (_gfLvl < 3) then {
        ["-SEC-", _gfCaller, format ["BLOCKED gangFortress '%1' (adminlevel %2 < 3) by %3", _mode, _gfLvl, getPlayerUID _gfCaller]] call PLB_fnc_logIt;
        _gfBlocked = true;   // signal; the top-level guard below exits the function
    };};
if (_gfBlocked) exitWith {};

private _flag = missionNamespace getVariable ["gang_fortress_flag", objNull];
if (isNull _flag) exitWith { diag_log "[LooneyBin][gangfort] gang_fortress_flag missing -- aborted"; };
private _center = getMarkerPos "gang_fortress_marker";
if (_center isEqualTo [0,0,0]) then { _center = getPosATL _flag; };

// ---- outpost + marker setup/teardown (shared by start + load-resume) ----
PLB_fnc_fortOutpostUp = {params ["_center"];
    if (!isNil "SRV_tempGangRebel") then { call PLB_fnc_fortOutpostDown; };
    private _set = [];
    private _angles = [40, 220];   // two opposite sides
    {private _a = _x;
        // owner 2026-06-17: safezone rebel outposts pushed to 1000m from the fortress (was 230m -- too close,
        // their no-combat bubble overlapped the 125m capture zone). Far enough that the fort fight isn't safezone-adjacent.
        private _op = [[(_center select 0) + 1000 * sin _a, (_center select 1) + 1000 * cos _a, 0], 6, 40, 4, 0, 0.45, 0] call BIS_fnc_findSafePos;
        private _grp = createGroup [civilian, true];
        "C_man_polo_1_F" createUnit [_op, _grp, "", 0.5, "PRIVATE"];
        private _w = (units _grp) select (count (units _grp) - 1);
        private _vp = [_op, 8, 16, 4, 0, 0.45, 0] call BIS_fnc_findSafePos;
        "C_man_polo_4_F" createUnit [_vp, _grp, "", 0.5, "PRIVATE"];
        private _v = (units _grp) select (count (units _grp) - 1);
        { _x disableAI "ALL"; _x setUnitPos "UP"; _x allowDamage false; _x setBehaviour "CARELESS"; _x setVariable ["plb_fortNPC", true, true]; } forEach [_w, _v];
        // owner 2026-06-24: FREEZE the outpost shop NPCs. disableAI stops self-movement but NOT physics -- players
        // were body-shoving the ragdoll out of position ("bugging it out"). enableSimulationGlobal false (server-spawned
        // -> Global variant for all clients) locks them in place; collision geo stays (still solid) but no push/ragdoll.
        // Deferred ~2s so the unit settles into its standing pose before sim freezes (immediate freeze can lock a T-pose).
        [_w, _v] spawn { uiSleep 2; { if (!isNull _x) then { _x enableSimulationGlobal false; }; } forEach _this; };
        // owner 2026-06-21 (#474/#476 "rebel vehicle spawn blocked when nothing's there / can't spawn vehicles"):
        // fn_vehicleShopBuy resolves spawn points as MARKER NAMES (getMarkerPos) or OBJECTS (getPosATL) -- it has NO
        // branch for raw position arrays, so passing BIS_fnc_findSafePos POSITIONS fell into the marker branch ->
        // getMarkerPos([x,y,z]) -> [0,0,0] -> the clear-check never found a valid spot -> "blocked". Normal outposts
        // pass marker names (e.g. 'reb_g_4'). Create an invisible marker per spawn spot and pass the NAMES.
        private _spawns = [];
        for "_i" from 0 to 2 do {private _sp  = [_vp, 10, 22, 4, 0, 0.45, 0] call BIS_fnc_findSafePos;
            private _spm = format ["gangfort_vspawn_g_%1_%2", _forEachIndex, _i];
            deleteMarker _spm;
            createMarker [_spm, _sp]; _spm setMarkerType "Empty"; _spm setMarkerAlpha 0;
            _spawns pushBack _spm;};
        private _mk = format ["gangfort_outpost_%1", _forEachIndex + 1];
        createMarker [_mk, _op]; _mk setMarkerType "loc_Bunker"; _mk setMarkerColor "ColorGreen"; _mk setMarkerText "Rebel Outpost (Safezone)";
        // owner 2026-06-17: 50m-RADIUS (100m across) godmode + no-fire SAFEZONE bubble per outpost. Named
        // gangf_rebel_c_0 / gangf_rebel_c_1 to match the existing fn_onFired fire-block AND the new fn_handleDamage
        // godmode check (both `inArea` these markers). Global marker so `inArea` resolves on every client. deleteMarker
        // first in case a prior event left it (createMarker no-ops on a name clash -> would silently lose the zone).
        private _sz = format ["gangf_rebel_c_%1", _forEachIndex];
        deleteMarker _sz;
        createMarker [_sz, _op]; _sz setMarkerShape "ELLIPSE"; _sz setMarkerSize [50, 50]; _sz setMarkerBrush "Border"; _sz setMarkerColor "ColorGreen"; _sz setMarkerAlpha 0.7; _sz setMarkerText "";
        _set pushBack [_w, _v, _spawns];} forEach _angles;
    SRV_tempGangRebel = _set;
    publicVariable "SRV_tempGangRebel";
    // event-zone marker on the map (global, red ellipse around the fortress)
    deleteMarker "gangfort_zone";
    createMarker ["gangfort_zone", _center]; "gangfort_zone" setMarkerShape "ELLIPSE"; "gangfort_zone" setMarkerSize [125, 125];
    "gangfort_zone" setMarkerBrush "Border"; "gangfort_zone" setMarkerColor "ColorRed"; "gangfort_zone" setMarkerText "Gang Fortress";
    diag_log format ["[LooneyBin][gangfort] %1 outpost(s) + markers up", count _set];};
PLB_fnc_fortOutpostDown = {if (!isNil "SRV_tempGangRebel") then {
        { { if (!isNull _x) then { deleteVehicle _x; }; } forEach [_x select 0, _x select 1]; } forEach SRV_tempGangRebel;
        SRV_tempGangRebel = nil;
        publicVariable "SRV_tempGangRebel";};
    // owner 2026-06-21 (#474/#476): also clear the invisible vehicle-spawn markers (2 outposts x 3 spots).
    { deleteMarker _x; } forEach ["gangfort_outpost_1", "gangfort_outpost_2", "gangfort_zone", "gangf_rebel_c_0", "gangf_rebel_c_1",
        "gangfort_vspawn_g_0_0", "gangfort_vspawn_g_0_1", "gangfort_vspawn_g_0_2", "gangfort_vspawn_g_1_0", "gangfort_vspawn_g_1_1", "gangfort_vspawn_g_1_2"];
};

private _nowUnix = { parseNumber format ["%1", (["SELECT UNIX_TIMESTAMP()", 2] call DB_fnc_asyncQuery) param [0, 0]] };

// ---- the scoring loop (runs for _secs seconds of remaining time) ----
PLB_fnc_fortScore = {params ["_flag", "_center", "_secs"];
    [_flag, _center, _secs] spawn {params ["_flag", "_center", "_secs"];
        SRV_gangFortressActive = true;
        private _end = serverTime + _secs;
        private _lastSave = serverTime;
        while {SRV_gangFortressActive && {serverTime < _end}} do {uiSleep 5;
            // owner 2026-06-17: FLAG-CAPTURE scoring. Whoever OWNS the flag (captured it via life_fnc_captureGangFort
            // -> plb_gang_fortress_data) earns 5 pts/tick AS LONG AS they still HOLD it (>=1 alive, un-restrained
            // member of that gang inside the 125m zone). A rival re-captures the flag to flip ownership and start
            // scoring for themselves. (Was: only a SOLE UNCONTESTED gang scored -> a contested fort gave nobody points.)
            (_flag getVariable ["plb_gang_fortress_data", [-1, "Uncontrolled", true]]) params [["_oGid", -1], ["_oName", "Uncontrolled"]];
            if (_oGid isNotEqualTo -1) then {
                // owner 2026-06-17: points SCALE with how many of the HOLDING gang's members are alive + present
                // (un-restrained, in the 125m zone) -> commit more people to defend the flag = score faster.
                // 5 pts PER holding member each tick (1 member = 5, 4 members = 20, ...).
                private _holdCount = {
                    alive _x && {side _x isEqualTo civilian} && {(_x distance2D _center) <= 125} && {!(_x getVariable ["plb_restrained", false])}
                    && {((_x getVariable ["gang_data", []]) param [0, -1]) isEqualTo _oGid}} count allPlayers;
                if (_holdCount > 0) then {private _gain = _holdCount * 5;
                    private _i = SRV_gangFortressData findIf { (_x select 0) isEqualTo _oGid };
                    if (_i isEqualTo -1) then { SRV_gangFortressData pushBack [_oGid, _oName, _gain]; }
                    else { (SRV_gangFortressData select _i) set [2, ((SRV_gangFortressData select _i) select 2) + _gain]; };
                    publicVariable "SRV_gangFortressData";};};
            // persist leaderboard every ~60s so a reboot resumes with scores
            if (serverTime - _lastSave > 60) then {_lastSave = serverTime;
                [format ["UPDATE gangfort SET leaderboard='%1' WHERE id=1", [SRV_gangFortressData] call DB_fnc_mresArray]] call DB_fnc_asyncQuery;
            };};
        // finish
        SRV_gangFortressActive = false;
        private _top = [-1, "Uncontrolled", -1]; { if ((_x select 2) > (_top select 2)) then { _top = _x; }; } forEach SRV_gangFortressData;
        call PLB_fnc_fortOutpostDown;
        if ((_top select 0) isEqualTo -1) then {_flag setVariable ["plb_gang_fortress_data", [-1, "Uncontrolled", false], true];
            ["UPDATE gangfort SET active=0, winner_id=-1, winner_name='' WHERE id=1"] call DB_fnc_asyncQuery;
            [[1, "<t size='1.4' color='#FFD700'>Gang Fortress</t><br/><t size='1.05' color='#ffffff'>The event ended with no gang taking the fortress.</t>"], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
        } else {_flag setVariable ["plb_gang_fortress_data", [_top select 0, _top select 1, false], true];
            [format ["UPDATE gangfort SET active=0, winner_id=%1, winner_name='%2' WHERE id=1", _top select 0, (_top select 1) splitString "'`""" joinString ""]] call DB_fnc_asyncQuery;
            [[1, format ["<t size='1.4' color='#FFD700'>Gang Fortress</t><br/><t size='1.05' color='#ffffff'>%1 WON the Gang Fortress with %2 points and now owns it until the next event!</t>", _top select 1, _top select 2]], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
        };
        [777, objNull, format ["GANG FORTRESS ended -- winner %1", _top]] call PLB_fnc_logIt;
        if ((_top param [0,-1]) > 0) then { ["WAR", format ["%1 STORMS THE FORTRESS -- DEEP STATE BUNKER BREACHED", (_top select 1)], format ["%1 took the fortress -- that bunker had my documents. GONE.", (_top select 1)]] call TON_fnc_newsPush; };   // DataBattle
        diag_log format ["[LooneyBin][gangfort] ENDED -- winner %1", _top];};};

switch (toLower _mode) do {case "start": {if (missionNamespace getVariable ["SRV_gangFortressActive", false]) exitWith {
            if (!isNull _caller) then { [["The Gang Fortress event is already running.", "basic"], "life_fnc_handleMessage", _caller, false, false] spawn life_fnc_MP; };
        };
        SRV_gangFortressData = [];          publicVariable "SRV_gangFortressData";
        SRV_diedInGangFort = [];            publicVariable "SRV_diedInGangFort";
        _flag setVariable ["plb_gang_fortress_data", [-1, "Uncontrolled", true], true];
        [_center] call PLB_fnc_fortOutpostUp;
        private _ends = (call _nowUnix) + 3600;
        [format ["UPDATE gangfort SET active=1, ends=%1, winner_id=-1, winner_name='', leaderboard='[]' WHERE id=1", _ends]] call DB_fnc_asyncQuery;
        ["initMessages"] remoteExec ["life_fnc_initGangFortClient", -2];
        [_flag, _center, 3600] call PLB_fnc_fortScore;
        [777, _caller, format ["GANG FORTRESS started by %1", if (isNull _caller) then {"server"} else {name _caller}]] call PLB_fnc_logIt;
        diag_log "[LooneyBin][gangfort] STARTED (1h)";};
    case "stop": {if !(missionNamespace getVariable ["SRV_gangFortressActive", false]) exitWith {
            if (!isNull _caller) then { [["No Gang Fortress event is running.", "basic"], "life_fnc_handleMessage", _caller, false, false] spawn life_fnc_MP; };
        };
        SRV_gangFortressActive = false;   // scoring thread runs the finish path next tick
        [777, _caller, format ["GANG FORTRESS stopped early by %1", if (isNull _caller) then {"server"} else {name _caller}]] call PLB_fnc_logIt;
    };
    case "load": {
        // owner 2026-06-20 (mres decode -- same QUOTE double-wrap bug as houses keyholders): leaderboard is mres-
        // encoded (line ~108 DB_fnc_mresArray) so its own outer quotes ARE the compile delimiters -- QUOTE()-ing it
        // double-wrapped -> mresToArray failed -> a fort resumed after a reboot mid-event came back with an EMPTY
        // leaderboard (scores wiped). Read it BARE; winner_name (a plain string) still needs QUOTE. The bareword '[]'
        // default comes back as an array, which format["%1",_lb] (line 163) coerces fine.
        private _row = ["SELECT active, ends, winner_id, QUOTE(COALESCE(winner_name,'')), COALESCE(leaderboard,'[]') FROM gangfort WHERE id=1", 2, true] call DB_fnc_asyncQuery;
        if !(_row isEqualType [] && {count _row > 0}) exitWith {};
        (_row select 0) params [["_active", 0], ["_ends", 0], ["_wid", -1], ["_wname", ""], ["_lb", "[]"]];
        _active = parseNumber format ["%1", _active];
        _ends = parseNumber format ["%1", _ends];
        _wid = parseNumber format ["%1", _wid];
        _wname = format ["%1", _wname];   // asyncQuery already compiled the QUOTE'd string
        private _now = call _nowUnix;
        if (_active isEqualTo 1 && {_ends > _now + 30}) then {
            // resume the unfinished event for the remaining time
            private _lbStr = [format ["%1", _lb]] call DB_fnc_mresToArray;
            SRV_gangFortressData = parseSimpleArray (format ["%1", _lbStr]);
            if (isNil "SRV_gangFortressData" || {!(SRV_gangFortressData isEqualType [])}) then { SRV_gangFortressData = []; };
            publicVariable "SRV_gangFortressData";
            SRV_diedInGangFort = [];  publicVariable "SRV_diedInGangFort";
            _flag setVariable ["plb_gang_fortress_data", [-1, "Uncontrolled", true], true];
            [_center] call PLB_fnc_fortOutpostUp;
            ["missedMessages"] remoteExec ["life_fnc_initGangFortClient", -2];
            [_flag, _center, _ends - _now] call PLB_fnc_fortScore;
            diag_log format ["[LooneyBin][gangfort] RESUMED, %1s left", _ends - _now];} else {
            if (_active isEqualTo 1) then { ["UPDATE gangfort SET active=0 WHERE id=1"] call DB_fnc_asyncQuery; };
            if (_wid isNotEqualTo -1) then {
                // no live event -- keep the last winner owning the fortress (shops/discount)
                _flag setVariable ["plb_gang_fortress_data", [_wid, format ["%1", _wname], false], true];
                diag_log format ["[LooneyBin][gangfort] ownership restored -> gang %1 (%2)", _wid, _wname];};};};};
