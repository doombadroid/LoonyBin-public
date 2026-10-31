 
_name = _this select 0;
_uid = _this select 1;
_unit = _this select 2;
// LooneyBin: capture EXACT logout/crash position so the player reconnects where they left
// (anti-combat-log + crash recovery), not a stale spawn from minutes ago. The server still holds
// the live unit here -> exact on a clean disconnect, within timeout-drift ("walking distance") on a
// crash. ALIVE-only (a dead player should reconnect to the spawn menu, not their corpse spot).
// queryRequest already loads the `position` column and spawns there if valid, so wiring this save
// side is all that was missing. Mode 10 = position, encoded identically to the normal periodic save.
// owner 2026-06-19 ("softlog gives the respawn screen"): `alive _unit` is UNRELIABLE in HandleDisconnect -- the
// engine flags a cleanly-disconnecting (Esc->Abort) ALIVE player's body as not-alive, so an alive softlog hit the
// old `!alive` clear and WIPED the just-saved position -> reconnect landed on the spawn-select menu instead of
// teleporting back. The respawn screen must only appear on DEATH/BLEEDOUT. Decide off the persistent markers
// instead: Revive (set true by fn_onPlayerKilled on death) / plb_downed (set by fn_handleDowned on bleedout).
// died/bleedout -> clear position (-> spawn menu); otherwise save the exact logout spot (-> reconnect teleports back).
// #260 (suicide -> alt-F4) still works: a suicide sets Revive=true, so it clears as before.
// owner 2026-06-20 (REVERTED the dead/downed-DC gear strip -- it mass-FALSE-STRIPPED live players): the prior version
// NULL'd <side>_gear whenever Revive/plb_downed read true at disconnect, but those unit vars are UNRELIABLE in
// HandleDisconnect (plb_downed/Revive get stuck-true after a botched revive or cross-side switch, and `side _unit`
// can read wrong) -> 38 strips across 16+ LIVE players, legit kits wiped on ordinary softlogs (#443/#446). A false
// strip = the player loses their WHOLE kit, far worse than a combat-logger keeping gear. So NO gear strip here.
// Position only (low-stakes -- a wrong call is just spawn-menu vs teleport, never item loss), and ONLY for a CIVILIAN:
// cops/medics spawn at HQ and never restore `position`, and writing it for them bled their cop/medic logoff spot into
// the shared `position` column so a later login on the same account spawned there (#439).
// owner 2026-06-20: gate on the side from `life_connected` (recorded reliably on CONNECT), NOT `side _unit` -- the
// engine can report `side _unit` as civilian for a disconnecting COP, so the old gate SAVED a cop's PD logoff spot and
// a later CIV login on that account then spawned INSIDE the PD with a full civ loadout (free "raid the police"). Cops
// must ALWAYS reconnect to respawn (HQ/spawn-select); only a real civilian's exact spot is ever saved.
private _connSide = east;
{ if ((_x select 0) isEqualTo _uid) exitWith { _connSide = _x select 1; }; } forEach life_connected;
if (!isNull _unit && {_uid != ""} && {_connSide isEqualTo civilian}) then {
    if ((_unit getVariable ["Revive", false]) || (_unit getVariable ["plb_downed", false])) then {
        // died / bleeding out -> clear position -> reconnect to the spawn-select menu (respawn screen = death only)
        [_unit, civilian, _uid, 10, []] call DB_fnc_updatePartial;} else {private _lp = getPosATL _unit;
        if ((_lp distance [0,0,0]) > 100) then {
            [_unit, civilian, _uid, 10, _lp] call DB_fnc_updatePartial;   // alive softlog -> save exact spot -> teleport back
        } else {
            // junk/origin position (never teleport a reconnect to the [0,0,0] debug island) -> spawn menu
            [_unit, civilian, _uid, 10, []] call DB_fnc_updatePartial;};};}; {if (typeName _x == "OBJECT") then {
_changed = _x getVariable["lootModified", false]; 
if (_changed) then {[_x] spawn DB_fnc_updateStorage;
sleep 2;};};} forEach life_storage_array;
 
// owner 2026-06-13: free the leaver's phone-call LINE so the pool doesn't leak. The old managePhone(objNull)
// call had no player ref so it freed nothing -> a disconnect mid-call pinned a channel forever -> the pool
// drained -> "too many people making phone calls" for everyone. End their active call by their unit ref.
if (!isNil "PLB_phoneCalls" && {!isNull _unit}) then {
    private _pi = PLB_phoneCalls findIf { ((_x select 1) isEqualTo _unit) || {(_x select 2) isEqualTo _unit} };
    if (_pi > -1) then {["endPhoneCall", [(PLB_phoneCalls select _pi) select 0, _unit]] call TON_fnc_handlePhoneCallSRV;};};
// owner 2026-06-16 (DISCONNECT-DUPE, CLANKR HIGH): if the leaver alt+F4'd with a HOUSE storage open, the
// normal close-save (TON_fnc_updateHouseTrunk) never fired -> the house DB row still holds the items they
// pulled AND their gear flushes WITH those items = DUPE. The house object already carries the CURRENT
// (post-take) plb_vinv (set global by fn_storeInventory/fn_takeInventory) and plb_activeTrunk == the leaver
// while open. Force-persist that house here, BEFORE flushPlayer saves their gear, so the removal is recorded.
if (!isNull _unit) then {{if ((_x getVariable ["plb_activeTrunk", objNull]) isEqualTo _unit) then {
			if (_x isKindOf "House_F") then { [objNull, _x] call TON_fnc_updateHouseTrunk; };
			_x setVariable ["plb_activeTrunk", nil, true];};} forEach (nearestObjects [getPosATL _unit, ["House_F", "Car", "Air", "Ship"], 50]);};
// owner 2026-07-08 (casino): a hard disconnect never fires the hilo/blackjack "quit" teardown, so the server-side
// run state (PLB_casinoHiLo / PLB_bjGames, keyed by uid) was orphaned -- it leaked the HashMap entry AND left the
// client-debited wager with no matching result row, so CLANKR's casino mass-balance drifted (the forfeited loss
// was never booked). Clear both here and BOOK the forfeited bet as a house win so the ledger closes. deleteAt is
// idempotent, so a late-arriving client "quit" can't double-log. Also drop the per-uid cooldown / free-claim vars.
// pass the UNIT to logIt when it's still valid so the row is attributed to the player's NAME (PLB_fnc_logIt only
// derives name from a unit arg -- a bare uid string leaves name='SERVER', which mis-groups the forfeit in the econ
// digest); fall back to the uid string on a crash where the unit is null (playerid still correct either way).
private _logWho = if (isNull _unit) then { _uid } else { _unit };
if (!isNil "PLB_casinoHiLo") then {private _run = PLB_casinoHiLo getOrDefault [_uid, []];
    if (_run isNotEqualTo []) then {
        ["-CASINOHL-", _logWho, format ["net $-%1 (hilo forfeited on disconnect at mult %2)", _run param [2, 0], _run param [1, 1]]] call PLB_fnc_logIt;
    };
    PLB_casinoHiLo deleteAt _uid;};
if (!isNil "PLB_bjGames") then {private _bg = PLB_bjGames getOrDefault [_uid, []];
    if (_bg isNotEqualTo []) then {
        ["-CASINOBJ-", _logWho, format ["net $-%1 (blackjack forfeited on disconnect)", _bg param [5, 0]]] call PLB_fnc_logIt;};
    PLB_bjGames deleteAt _uid;};
missionNamespace setVariable [format ["PLB_casinoCD_%1", _uid], nil];
missionNamespace setVariable [format ["PLB_bjCD_%1", _uid], nil];
if (!isNil "PLB_casinoWheelFreeMem") then { PLB_casinoWheelFreeMem deleteAt _uid; };
if (!isNil "PLB_casinoVehDay") then { PLB_casinoVehDay deleteAt _uid; };

[_uid] spawn DB_fnc_flushPlayer;
[_uid] spawn PLB_fnc_cleanupStorage;
[_uid] spawn PLB_fnc_cleanupHouses; 
[[_uid],"life_fnc_removeBounty",true,false] spawn life_fnc_MP;
["-DISCONNECT-", _uid, format ["%1 disconnected", _name]] call PLB_fnc_logIt;
// owner 2026-06-27 (combat-log fugitive bodybag): a WANTED/bountied player who logs out drops a tagged "Fugitive
// Bodybag" object at their exact spot. APD (any rank) OR the bounty hunter tracking their bounty can scroll-wheel it
// (fn_setupActions -> TON_fnc_claimBodybagSRV) to JAIL them on their next login (persisted to players.arrested,
// survives a restart) + collect the full bounty + a combat-log bonus. Replaces the old cop-within-150m auto-jail
// (no interaction / no payout). The bounty stays in life_wanted_list until the bag is claimed. Server-authoritative
// wanted gate, so an innocent/AFK disconnect drops nothing. `owner` is tagged so fn_cleanup's ownerless-reap
// (core/.../fn_cleanup.sqf -- instant-deletes spawned objects with no owner var) doesn't vaporize the bag.
// owner 2026-06-29: only drop the bag if the fugitive logged while DOWNED or RESTRAINED (i.e. escaping arrest),
// not on a clean disconnect while free. lifeState "INCAPACITATED" is the engine-authoritative downed signal
// (setUnconscious in fn_handleDowned:143), so it's immune to the stuck-true plb_downed/Revive vars this file warns
// about above; plb_restrained is cleared to nil on un-restrain (fn_unrestrain), so it's reliable at disconnect.
if (!isNull _unit
    && {((lifeState _unit) isEqualTo "INCAPACITATED") || {_unit getVariable ["plb_restrained", false]}}
    && {(life_wanted_list findIf { _uid in _x }) != -1}) then {
    private _we   = life_wanted_list select (life_wanted_list findIf { _uid in _x });
    private _bpos = getPosATL _unit;
    // owner 2026-06-28: use the real body-bag model (matches the loony-bin "patient remains" -- fn_loonyBinSRV).
    // It's flat + un-targetable by cursorObject, which is WHY the loony bin abandoned it; the radius addAction
    // below (not cursorObject) makes it claimable anyway.
    private _bag  = createVehicle ["Land_Bodybag_01_black_F", _bpos, [], 0, "CAN_COLLIDE"];
    _bag setPosATL _bpos;
    _bag setVariable ["owner", _bag, true];
    _bag setVariable ["plb_bbUID", _uid, true];
    _bag setVariable ["plb_bbName", _name, true];
    _bag setVariable ["plb_bbBounty", (_we param [3, 0]), true];
    _bag setVariable ["plb_bbJailTime", (_we param [4, 0]), true];
    _bag allowDamage false;
    // owner 2026-06-28 (bodybag had NO usable scroll-wheel): put the claim action ON THE BAG (global + JIP) instead
    // of the old player+cursorObject scroll. A small flat body bag is near-impossible to land cursorObject on,
    // and the old client gate ALSO required the BH to be actively TRACKING this fugitive (life_bounty_list) -- stricter
    // than the server's "any cop/BH" gate. Radius action shows for any cop / licensed BH within 6m; the real auth is
    // TON_fnc_claimBodybagSRV. Sim stays ON so the bag presents its own addAction (sim-off objects hide theirs).
    private _act = ["<t color='#FF8000'>Send Fugitive to Jail</t>", { [[_this select 0], "TON_fnc_claimBodybagSRV", 2] spawn life_fnc_MP; }, nil, 6, true, true, "", "((side _this) isEqualTo west || {license_civ_bounty}) && {(_this distance _target) < 6} && {!(_target getVariable ['plb_bbClaimed', false])}", 6];
    [_bag, _act] remoteExec ["addAction", 0, _bag];
    // ping the drop location to APD + bounty hunters (existing client marker fn, self-expires 60s)
    { [[_bpos, _name], "life_fnc_bodybagMarker", _x, false] spawn life_fnc_MP; } forEach (allPlayers select { (side _x isEqualTo west) || {_x getVariable ["plb_isBountyHunter", false]} });
    ["-COMBATLOG-", _uid, format ["%1 combat-logged WANTED -> fugitive bodybag at %2 (bounty $%3, %4s)", _name, _bpos, (_we param [3, 0]), (_we param [4, 0])]] call PLB_fnc_logIt;
    // auto-despawn the bag after 30 min if nobody claims it
    [_bag] spawn { params ["_b"]; uiSleep 1800; if (!isNull _b && {!(_b getVariable ["plb_bbClaimed", false])}) then { deleteVehicle _b; }; };
};
_side = east;
_conn = -1; 
{ if (_x select 0 == _uid) then { _side = _x select 1; _conn = _forEachIndex; } } forEach life_connected; 
if (!(_side in [east])) then {_i = count life_disconnects;
{ if (_x select 0 == _uid) then { _i = _forEachIndex } } forEach life_disconnects; 
life_disconnects set [_i, [_uid,_side,time]]; 
life_connected set [_conn, 0]; 
life_connected = life_connected - [0];};
 
_query = format["DELETE FROM `online` WHERE playerid='%1' AND `instance`=%2", _uid, life_server_instance]; 
[_query,1] call DB_fnc_asyncQuery; 
sleep 3; {
// LooneyBin: the 2020 client tags its unit with "plb_steamid" (core/init.sqf), but this 2017
// cleanup looked up "steam64ID" -> never matched -> the disconnected body was never deleted,
// leaving a corpse holding the player's gear and forcing a fresh naked body each relog. Check
// plb_steamid first, fall back to the old name.
_pid = _x getVariable["plb_steamid", _x getVariable["steam64ID","0"]];
if (_uid == _pid) then {if (!isNull (_x getVariable["blindfold", objNull])) then { deleteVehicle (_x getVariable["blindfold"]); };
_containers = nearestObjects [_x,["WeaponHolderSimulated"],5];  
{deleteVehicle _x;} foreach _containers;  
deleteVehicle _x;};} foreach allDeadMen;

// LooneyBin: the allDeadMen sweep only catches DEAD bodies. A disconnected player's unit is often
// still ALIVE (frozen AI) -> never in allDeadMen -> left standing as a "body" wearing the player's
// gear. We already have the unit directly (HandleDisconnect _this select 2), so delete it outright.
if (!isNull _unit) then {{ deleteVehicle _x; } forEach (nearestObjects [_unit, ["WeaponHolderSimulated"], 6]);
    deleteVehicle _unit;};
// owner 2026-06-20: the post-flush dead/downed-DC gear strip was REMOVED here (see the top of this file) -- it was
// false-stripping live players' kits via unreliable HandleDisconnect state. Re-add anti-combat-log ONLY with a
// reliable signal (a DB death/down marker stamped by onPlayerKilled/handleDowned + checked here), never volatile unit vars.
