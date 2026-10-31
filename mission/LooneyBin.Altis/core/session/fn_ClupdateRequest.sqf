if !(life_session_completed) exitWith {};
// owner 2026-06-21 (player108 money-wipe): bail if the player is at the SPAWN-SELECT screen (display 38500). The
// restart force-flush (init.sqf force-ClupdateRequest, BOTH the scheduled-restart and gracefulsave paths)
// broadcasts to ALL clients -- including one parked at spawn-select whose life_session_completed is stale-TRUE
// from a prior session while life_cash/atmcash have reset to 0. The money packet below is gated ONLY by
// session_completed, NOT by in-world state, so it saved cash/bank 0 over the real balance (player108: 547k -> 0;
// isolated -- only he was at spawn-select during the restart). At spawn-select the player is not in-world --
// money/pos/gear aren't live -> never persist from here. (isNull findDisplay 38500 = the established in-world
// idiom, see initPlayerLocal.sqf:395.)
if (!isNull (findDisplay 38500)) exitWith {};
// owner 2026-06-21 (Vista money-wipe): NEVER build the save packet with uninitialised money. life_session_completed
// goes stale-TRUE across sessions, so at reconnect this can run before the session sets life_cash/life_atmcash ->
// the packet shipped [..,any,any], the server defaulted nil->0 and wrote bankacc=0 over the real balance (Vista
// 423k -> 0). Bail until the money vars are real numbers (session actually loaded). Server-side DB_fnc_updateRequest
// has the same guard as the authoritative backstop.
if (isNil "life_cash" || {isNil "life_atmcash"} || {!(life_cash isEqualType 0)} || {!(life_atmcash isEqualType 0)}) exitWith {};
if (isFilePatchingEnabled) then {[[player, [1, round diag_tickTime]], "TON_fnc_dongClient", 2] call life_fnc_MP;};
private _totalItemsActual = 0; {_totalItemsActual = _totalItemsActual + (missionNameSpace getVariable [_x, 0]);}
forEach life_invMonVars;
// BUGS.md #79/#80: was `exitWith` -- the item-count monitor ABORTED the whole periodic save (gear,
// cash, talents, position all stopped persisting) once a player passed 130 items. Log + resync, keep saving.
if (_totalItemsActual > (life_invMonitor - life_invRVar) || _totalItemsActual >= 130) then {private _hackedItemArray = []; {
        if ((missionNameSpace getVariable [_x, 0]) > 0) then {_hackedItemArray pushBack[_x, (missionNameSpace getVariable [_x, 0])];};}
    forEach life_invMonVars; [
        [player, [3, (life_invMonitor - life_invRVar), _totalItemsActual, str _hackedItemArray]], "TON_fnc_dongClient", 2] call life_fnc_MP;
    [] spawn {uiSleep 2;
        diag_log "[LooneyBin] MemHackCash AC neutered (no kick)";};
    life_invMonitor = _totalItemsActual + life_invRVar;};
private _packet = [player, profileName, playerSide, life_cash, life_atmcash];
_packet pushBack life_side_talents;
_packet pushBack life_side_exp;
if (((life_is_arrested param [0,0]) isEqualTo 0) && (player distance(getMarkerPos "respawn_west") > 1000)) then {
    [false] call life_fnc_saveGear;
    if ((life_lastSynced_gear != str(life_gear)) && (life_clothing_store isEqualTo "")) then {[3] call life_fnc_ClupdatePartial;};};
if (PLB_useStatBuffer) then {
    // singleevh.md Phase 3a: durable stat buffer's event flush (double-buffered; same wire format + server RMW).
    call life_fnc_flushStats;} else {if (plbv_tempStats findIf {_x > 0}
isNotEqualTo - 1) then {plbv_savedStats = plbv_tempStats;
    private _updateArray = []; {if (_x isNotEqualTo 0) then {_updateArray pushBack[_forEachIndex, _x];};}
    forEach plbv_savedStats; [[getPlayerUID player, _updateArray], "TON_fnc_statTableUpdate", 2] spawn life_fnc_MP;
    plbv_tempStats = +plbv_defaultStats;
    plbv_savedStats = +plbv_defaultStats;};};
private _syncQuest = false;
if (!(life_LifetimeProgressQuests isEqualTo[]) && !(life_lastSynced_LifetimeProgressQuests isEqualTo life_LifetimeProgressQuests)) then {
    _syncQuest = true};
if !(life_lastSynced_completedLifetimeQuests isEqualTo life_completedLifetimeQuests) then {_syncQuest = true};
if (_syncQuest) then {[20] call life_fnc_ClupdatePartial};
[1] call life_fnc_questSync;
switch (playerSide) do {case civilian: {profileNamespace setVariable["plb_thirst", plbv_thirst];
            profileNamespace setVariable["plb_hunger", plbv_hunger];
            profileNamespace setVariable["plb_playerDir", getDir vehicle player];
            profileNamespace setVariable["plb_playerDamage", getDammage player];
            if (alive player && ((player distance getMarkerPos("respawn_civilian")) > 1500) && (player distance[0, 0, 0] > 1000)) then {
                private _noSyncZones = [["life_bank_door", 55], ["fed_reserve", 185], ["armory_marker", 220]];
                if (!(alive player) || (({(player distance(getMarkerPos(_x select 0))) <= (_x select 1)}
                count _noSyncZones) isEqualTo 0)) then {private _pos = getPosATL player;
                    if (vehicle player isKindOf "Air") then {_pos set[2, 1];};
                    private _randomSyncZone = [["arms_cartel", 200], ["drug_cartel", 200], ["oil_cartel", 200], ["wongs_cartel", 200],
                        ["life_mentalHospital", 200]]; {_x params["_marker", "_distance"];
                        if ((player distance(getMarkerPos _marker)) <= (_distance)) exitWith {
                            _pos = [getMarkerPos _marker, 250, 300, 3, 0, 1, 0] call BIS_fnc_findSafePos;
                            _pos set[2, 1];};}
                    forEach _randomSyncZone;
                    _pos =
                    if (surfaceIsWater _pos) then {getPosASL player} else {_pos};
                    life_ses_last_pos = _pos;};} else {life_ses_last_pos = [];};
            _packet pushBack life_ses_last_pos;};}; if (life_lastUpdateRequest == format["%1", _packet]) exitWith {};
life_lastUpdateRequest = format["%1", _packet];
[_packet, "DB_fnc_updateRequest", false, false] spawn life_fnc_MP;