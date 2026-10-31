/*
    TON_fnc_copSplit  (LooneyBin) -- distribute a cop payout evenly among the active
    on-duty police, crediting each officer's bank. Runs on the SERVER.
    2020 client args: [_cop, _amount]   (_cop = initiating officer, _amount = total pool)

    Was a no-op stub, so cops were NEVER paid for tickets, money/vehicle/inventory seizures,
    impounds, illegal tents, or arrest bounties (the west branch of fn_bountyReceive also
    routes the bounty here). Civilian bounty hunters were unaffected (they bypass this and
    credit life_atmcash directly), which is why only police reported missing pay.

    Pairs with life_fnc_copSplitReceive (client). Server->client MP is exempt from the
    CfgRemoteExec mode=1 whitelist, so the receiver needs no CfgRE.hpp entry.
*/
params [["_cop", objNull, [objNull]], ["_amount", 0, [0]]];

// owner 2026-06-24 SECURITY + #528 FIX: CfgRE-whitelisted -> a client could remoteExec [player, 9.9e8] to split an
// arbitrary pool among cops. The 2026-06-23 hardening required the CALLER be a COP (side west) -- but that was a FALSE
// POSITIVE: fn_ticketPay runs on the CIVILIAN payer's client, so the legit ticket-payout caller is the paying civ, not
// a cop -> every paid ticket logged "-SEC- BLOCKED copSplit (caller not a cop)" and cops went UNPAID (#528). The side
// gate was also pointed the wrong way for abuse: a COP caller (the old ALLOWED case) is a payee and can pay THEMSELVES,
// while a civilian caller is NOT a payee (payees are server-filtered to west+alive below) and gains nothing. So the real
// defenses are: (1) a non-spoofable caller (remoteExecutedOwner, model fn_seizeLock:22); (2) the per-call pool ceiling;
// (3) a short per-caller cooldown so copSplit can't be spam-minted. server-internal (_src==0) passes (seize/bounty paths).
private _src = remoteExecutedOwner;
private _caller = if (_src isEqualTo 0) then { objNull } else { (allPlayers select { owner _x isEqualTo _src }) param [0, objNull] };
if (_src isNotEqualTo 0 && {isNull _caller}) exitWith {};   // spoofed / vanished caller
if (_src isNotEqualTo 0) then {
    // anti-spam: a legit ticket-pay / seize / impound is seconds+ apart -- a 2s per-caller cooldown can't block a real
    // action but stops a client minting the capped pool to cops in a tight loop. (CLANKR also watches copSplit volume.)
    // NOTE: exitWith here would only leave THIS then-block (SQF scope trap), so signal a throttle via _amount=-1 and
    // let the TOP-LEVEL `_amount <= 0` guard below exit the whole function.
    private _cUid = getPlayerUID _caller;
    private _cdVar = format ["PLB_copSplitCD_%1", _cUid];
    private _now = diag_tickTime;
    if ((_now - (missionNamespace getVariable [_cdVar, -999])) < 2) then {
        ["-SEC-", _caller, format ["throttled copSplit (rapid repeat) by %1", _cUid]] call PLB_fnc_logIt;
        _amount = -1;} else {missionNamespace setVariable [_cdVar, _now];
        _cop = _caller;};};
private _MAX_POOL = 5000000;   // generous per-call ceiling (no legit single seize/ticket/impound approaches this)
_amount = (round _amount) min _MAX_POOL;
if (_amount <= 0) exitWith {};   // throttled (_amount=-1) OR non-positive pool -> no payout (top-level exit)

private _cops = allPlayers select { isPlayer _x && {(side _x) isEqualTo west} && {alive _x} };
if (_cops isEqualTo []) exitWith {diag_log format ["[LooneyBin][copSplit] no active cops to pay (pool $%1)", _amount];};

private _share = round (_amount / (count _cops));
if (_share <= 0) exitWith {}; {[[_share], "life_fnc_copSplitReceive", _x, false] spawn life_fnc_MP;} forEach _cops;
diag_log format ["[LooneyBin][copSplit] paid $%1 each to %2 cop(s) (pool $%3)", _share, count _cops, _amount];
