/*
    TON_fnc_wantedAdd  (LooneyBin: add a charge to a player's wanted level) -- runs on the SERVER.
    Callers: [chargeID, unit]  or  [chargeID, unit, amount].
    Relay the charge to the OFFENDER's own client (life_fnc_wantedListAdd) -> it updates A_stats_crimes
    (single source of truth) + republishes plb_wantedAmt, then pushes the authoritative state to
    TON_fnc_wantedSyncList which rebuilds the cop-facing life_wanted_list (+ its index-3 bounty the payout
    reads). NO separate server accumulation here -- that desynced from A_stats_crimes and under-paid bounties
    (player wanted 93k while the list/payout sat on one stale 5k charge).
*/
params [["_chargeID", -1, [0]], ["_unit", objNull, [objNull]], ["_amount", 1, [0]]];
// owner 2026-06-23 SECURITY (security.md §2.2): this is NOT cop-only -- civs self-charge for their own crimes
// (robStore/lockpick/prisonBreak/etc pass [chargeID, player]) and the kill-attribution path charges another
// civ (the killer) at a fixed low charge, amount 1. So DON'T require side==west. Two real holes are closed:
//   1) AMOUNT INFLATION: the old `(round _amount) max 1` set only a FLOOR -> a client could remoteExec
//      [60, victim, 999999] and the victim's own fn_wantedListAdd (which keys on its own UID) would apply
//      crimeValue*999999. The legit cop UX (fn_applyCharge) hard-caps amount at 5, so clamp 1..5 here too.
//   2) Derive the REAL caller (remoteExecutedOwner, non-spoofable). Self-charge and server-internal (_src==0,
//      bank/fed/jewelry call this directly) always pass. A client charging a DIFFERENT player is allowed only
//      for west cops (applyCharge) OR civ-vs-civ (the kill path) -- but with the amount now capped, the worst a
//      civ can do is grief a low-value charge onto a UID. NEEDS OWNER REVIEW: tie civ-vs-civ charging to a
//      server-side recent-kill/witness record to fully close low-value griefing (kept open so kill charges work).
private _src = remoteExecutedOwner;
private _caller = if (_src isEqualTo 0) then { objNull } else { (allPlayers select { owner _x isEqualTo _src }) param [0, objNull] };
if (isNull _unit) exitWith {};
// owner 2026-06-24: THE PURGE -- crimes committed inside the active purge zone add NO wanted level (auto-zone,
// "all crime legal"). PLB_purgeZone = [centerPos, radius] is published by TON_fnc_eventPurgeSRV (nil = no purge).
if (!isNil "PLB_purgeZone" && {(PLB_purgeZone param [1, 0]) > 0} && {(getPosATL _unit) distance2D (PLB_purgeZone param [0, [0,0,0]]) < (PLB_purgeZone param [1, 0])}) exitWith {};
if (_chargeID < 1 || _chargeID > 150) exitWith {};
_amount = ((round _amount) max 1) min 5;
private _uid = getPlayerUID _unit;
if (_uid isEqualTo "") exitWith {};
if (isNil "life_wanted_list") then { life_wanted_list = []; };
[[_chargeID, _uid, _amount], "life_fnc_wantedListAdd", _unit, false, false] spawn life_fnc_MP;
