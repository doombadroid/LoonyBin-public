/*
    TON_fnc_claimBodybagSRV  (LooneyBin: claim a combat-log fugitive bodybag) -- runs on the SERVER.
    owner 2026-06-27: when a WANTED player combat-logs, fn_playerDisconnected drops a tagged "Fugitive Bodybag"
    object at their logout spot. APD (any rank) OR the bounty hunter tracking that player's bounty can scroll-wheel
    it (fn_setupActions action -> remoteExec here). This:
      1. JAILS the offline fugitive PERSISTENTLY -- writes players.arrested=[1,bail,sentence] so they spawn in the
         cell on their next login (survives a server restart, unlike the in-memory life_restrained_players flag).
      2. also pushes them into life_restrained_players (re-jail this session if they relog before a restart).
      3. pays the claimer the FULL bounty + a combat-log bonus (owner decision), via the normal bountyReceive path.
      4. clears the fugitive's wanted (server list + DB row) so the bounty is resolved + can't be double-claimed.
      5. deletes the bodybag.
    Client passes [_bag]. The claimer is the NON-SPOOFABLE remoteExecutedOwner -- re-gated server-side (cop or BH),
    distance-checked, and single-fired (plb_bbClaimed) so a double-click / remote can't pay twice or jail-from-afar.
*/
params [["_bag", objNull, [objNull]]];
if (isNull _bag) exitWith {};

// --- authorize the claimer (mirrors TON_fnc_setJail's gate: APD west OR a server-set bounty hunter) ---
private _src = remoteExecutedOwner;
private _caller = if (_src isEqualTo 0) then { objNull } else { (allPlayers select { owner _x isEqualTo _src }) param [0, objNull] };
if (isNull _caller) exitWith {};
if !((side _caller isEqualTo west) || {_caller getVariable ["plb_isBountyHunter", false]}) exitWith {
    ["-SEC-", _caller, format ["BLOCKED bodybag claim by %1 (not cop/BH)", getPlayerUID _caller]] call PLB_fnc_logIt;};
// anti-remote (must physically be at the bag) + single-fire (anti double-claim / #517-style repeat pay)
if ((_caller distance _bag) > 6) exitWith {};
if (_bag getVariable ["plb_bbClaimed", false]) exitWith {};
_bag setVariable ["plb_bbClaimed", true, true];

private _san   = { (format ["%1", _this]) splitString "\'""" joinString "" };
private _uid   = (_bag getVariable ["plb_bbUID", ""]) call _san;
private _bname = _bag getVariable ["plb_bbName", "Fugitive"];
private _bounty= round (_bag getVariable ["plb_bbBounty", 0]);
private _jail  = round (_bag getVariable ["plb_bbJailTime", 0]);
if (_uid isEqualTo "") exitWith { deleteVehicle _bag; };
if (_jail < 1) then { _jail = 600; };                 // floor: wanted but no charge-time -> 10 min
private _bail  = _bounty max 2500;                    // bail = bounty (jailMe model), floored so it isn't free

// 1. PERSISTENT jail: arrested=[flag,bail,sentenceSeconds]. fn_queryRequest loads this on login ->
//    fn_initCiv re-runs life_fnc_jailPlayer -> the fugitive spawns straight into the cell. Survives a restart.
//    MUST mres-encode (same as fn_updatePartial's _enc) -- the column stores the value WITH outer quotes
//    ("[1,26055,573]"), and the login _dec expects that; a plain [..] would fail to decode.
private _arrEnc = [[1, _bail, _jail]] call DB_fnc_mresArray;
[format ["UPDATE players SET arrested='%1' WHERE playerid='%2'", _arrEnc, _uid]] call DB_fnc_asyncQuery;

// 2. re-jail THIS session too (if they reconnect before a restart) -- the existing combat-log mechanism.
if !(_uid in life_restrained_players) then { life_restrained_players pushBack _uid; };

// 3. clear their wanted (server list + DB) so it's resolved + can't be claimed twice.
private _wid = life_wanted_list findIf { _uid in _x };
if (_wid != -1) then { life_wanted_list deleteAt _wid; };
[format ["DELETE FROM `%1` WHERE `playerid`='%2'", srv_table_wanted, _uid]] call DB_fnc_asyncQuery;

// 4. pay the claimer: FULL bounty + combat-log bonus (owner decision). Same payout path as a live arrest.
private _bonus  = (round (_bounty * 0.5)) max 10000;  // +50%, min $10k (tunable)
private _payout = _bounty + _bonus;
[[_payout, _payout, _caller, _bounty], "life_fnc_bountyReceive", _caller, false] spawn life_fnc_MP;
[[format ["You sent fugitive %1 to jail -- they'll be behind bars on their next login.", _bname], "basic"], "life_fnc_handleMessage", _caller, false] spawn life_fnc_MP;

["-COMBATLOG-CLAIM-", getPlayerUID _caller, format ["%1 (%2) claimed fugitive %3 [%4]: jailed %5s, paid $%6 (bounty $%7 + bonus $%8)", name _caller, getPlayerUID _caller, _bname, _uid, _jail, _payout, _bounty, _bonus]] call PLB_fnc_logIt;

// 5. remove the bodybag
deleteVehicle _bag;
