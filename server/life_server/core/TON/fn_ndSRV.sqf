/*
    File: fn_ndSRV.sqf  (TON_fnc_ndSRV)
    LooneyBin 2026-07-23: NEW DRACHMA authority — the server-side wallet. First server-authoritative
    currency on the box: the ledger lives in players.new_drachma (DECIMAL(20,4)), ALL arithmetic is
    SQL, amounts travel as 4dp STRINGS end to end. SQF 32-bit floats never touch the ledger — that is
    the entire reason this file exists (exact 4-decimal money beyond the 2^24 float ceiling).

      ["credit", "<amt>", "<reason>"]            remote, from a client — rate-capped per reason
      ["debit",  "<amt>", "<token>"]             remote, from a client — atomic conditional spend
      ["get"]                                    remote, from a client — re-sync balance
      ["creditSrv", _player, "<amt>", "<reason>"] SERVER-INTERNAL ONLY (mining, login bonus). A remote
                                                  call of this mode is rejected by remoteExecutedOwner.

    Caller identity comes from remoteExecutedOwner (unspoofable), NEVER from client-passed uids.
    Per-uid lock serializes every txn for a player (credit AND debit), so the old/new string compare
    that detects debit success can't be fooled by an interleaved credit.
*/
private ["_mode"];
params [["_a", "", ["", objNull]], ["_b", "", ["", objNull]], ["_c", "", [""]], ["_d", "", [""]]];
_mode = if (_a isEqualType "") then { _a } else { "" };
if (_mode isEqualTo "") exitWith {};

// ---------- shared helpers (file-local) ----------------------------------------------------------
// strict wire format: 1-14 int digits, optional . + 1-4 frac digits. Doubles as the SQL-injection
// guard — a validated amount is safe to interpolate.
private _ndValid = { params ["_s"]; (_s isEqualType "") && {_s regexMatch "\d{1,14}(\.\d{1,4})?"} && {_s isNotEqualTo "0"} && {!(_s regexMatch "0+(\.0{1,4})?")} };
// zero-pad to 14+4 digits for exact ordering
private _ndPad = {params ["_s"];
    private _p = _s splitString ".";
    private _i = _p param [0, "0"];
    private _f = _p param [1, ""];
    while { count _f < 4 } do { _f = _f + "0" };
    while { count _i < 14 } do { _i = "0" + _i };
    _i + _f};
// exact a >= b on padded digit strings (char-by-char — SQF has no string ordering)
private _ndGE = {params ["_pa", "_pb"];
    private _aa = toArray _pa; private _bb = toArray _pb;
    private _r = true;
    for "_i" from 0 to ((count _aa) - 1) do {private _ca = _aa select _i; private _cb = _bb select _i;
        if (_ca != _cb) exitWith { _r = _ca > _cb };};
    _r};
private _ndSelect = {params ["_uid"];
    private _row = [format ["SELECT QUOTE(new_drachma) FROM players WHERE playerid='%1'", _uid], 2] call DB_fnc_asyncQuery;
    if !(_row isEqualType []) exitWith { "" };
    private _v = _row param [0, ""];
    if !(_v isEqualType "") exitWith { "" };
    _v};
private _resolveCaller = {private _ro = remoteExecutedOwner;
    if (_ro <= 2) exitWith { objNull };   // 0 = local, 2 = server — remote modes require a real client
    (allPlayers select { owner _x == _ro }) param [0, objNull]};
private _lockAcquire = {params ["_uid"];
    if (isNil "PLB_ndLocks") then { PLB_ndLocks = createHashMap };
    private _t0 = diag_tickTime;
    waitUntil { !(PLB_ndLocks getOrDefault [_uid, false]) || {diag_tickTime - _t0 > 8} };
    if (PLB_ndLocks getOrDefault [_uid, false]) exitWith { false };   // 8s bail — DB is wedged, refuse the txn
    PLB_ndLocks set [_uid, true];
    true};
private _lockRelease = { params ["_uid"]; PLB_ndLocks set [_uid, false]; };

// NOTE: server-internal trusted credit is TON_fnc_ndCreditSrv (a SEPARATE fn NOT in CfgRE, so a client
// cannot remoteExec it). It can't live here as a mode: ndSRV is CfgRE-whitelisted, and during a
// client-initiated RE chain (e.g. mining) remoteExecutedOwner stays the client's id, so an
// owner-based guard here can't tell a legit internal call from a client forging the mode.

// ---------- remote modes: resolve caller first ---------------------------------------------------
private _pl = call _resolveCaller;
if (isNull _pl) exitWith {};
private _uid = getPlayerUID _pl;
if !(_uid regexMatch "\d{17}") exitWith {};

switch (_mode) do {case "get": {private _bal = [_uid] call _ndSelect;
        if (_bal isNotEqualTo "") then { [[_bal, "sync", ""], "life_fnc_ndSync", _pl, false] spawn life_fnc_MP; };};
    case "credit": {private _amt = _b; private _reason = _c;
        if !([_amt] call _ndValid) exitWith { diag_log format ["[LooneyBin][ND][TAMPER] bad credit amount '%1' from %2 (%3)", _amt, _uid, _reason]; };
        // per-reason hourly caps: the client only ever REQUESTS a credit; these bound what a modified
        // client can grind out of each source. Unknown reason = rejected outright. TUNE freely.
        // coinsell caps the legacy-coin drain (USE-convert + Blackmarket sell). Generous: coins are finite
        // pre-switch stock and are CONSUMED on convert, so a big honest house stash shouldn't clip; the cap
        // only bounds a modded client forging coins (already a client-auth item, so this is just a ceiling).
        private _caps = createHashMapFromArray [["warkill", 60], ["quest", 50], ["event", 50], ["loginbonus", 50], ["coinsell", 100000]];
        if !(_reason in _caps) exitWith { diag_log format ["[LooneyBin][ND][TAMPER] unknown credit reason '%1' from %2", _reason, _uid]; };
        // cap accounting in floats is fine — caps are << the 2^24 ceiling, and the LEDGER never sees these numbers
        if (isNil "PLB_ndRateWin") then { PLB_ndRateWin = createHashMap };
        private _k = _uid + "|" + _reason;
        private _w = PLB_ndRateWin getOrDefault [_k, [serverTime, 0]];
        if (serverTime - (_w select 0) > 3600) then { _w = [serverTime, 0]; };
        private _amtN = parseNumber _amt;
        if (((_w select 1) + _amtN) > (_caps get _reason)) exitWith {
            diag_log format ["[LooneyBin][ND][CAP] %1 hit the '%2' hourly cap (%3 + %4)", _uid, _reason, _w select 1, _amt];};
        _w set [1, (_w select 1) + _amtN];
        PLB_ndRateWin set [_k, _w];
        if !([_uid] call _lockAcquire) exitWith {};
        [format ["UPDATE players SET new_drachma = new_drachma + %1 WHERE playerid='%2'", _amt, _uid], 2] call DB_fnc_asyncQuery;
        private _new = [_uid] call _ndSelect;
        [_uid] call _lockRelease;
        if (_new isEqualTo "") exitWith {};
        diag_log format ["[LooneyBin][ND] credit +%1 (%2) -> %3 = %4", _amt, _reason, _uid, _new];
        [[_new, _reason, _amt], "life_fnc_ndSync", _pl, false] spawn life_fnc_MP;};
    case "debit": {private _amt = _b; private _tok = _c;
        if (_tok isEqualTo "" || {count _tok > 40}) exitWith {};
        if !([_amt] call _ndValid) exitWith {diag_log format ["[LooneyBin][ND][TAMPER] bad debit amount '%1' from %2", _amt, _uid];
            [[false, "", _tok], "life_fnc_ndResult", _pl, false] spawn life_fnc_MP;};
        if !([_uid] call _lockAcquire) exitWith { [[false, "", _tok], "life_fnc_ndResult", _pl, false] spawn life_fnc_MP; };
        private _old = [_uid] call _ndSelect;
        private _ok = false;
        private _new = _old;
        if (_old isNotEqualTo "" && { [[_old] call _ndPad, [_amt] call _ndPad] call _ndGE }) then {
            // SQL-side guard is the atomic authority; the lock + old/new compare just make the
            // result detection exact (extDB3 UPDATE reports no row count through this pipe)
            [format ["UPDATE players SET new_drachma = new_drachma - %1 WHERE playerid='%2' AND new_drachma >= %1", _amt, _uid], 2] call DB_fnc_asyncQuery;
            _new = [_uid] call _ndSelect;
            _ok = (_new isNotEqualTo "") && { _new isNotEqualTo _old };};
        [_uid] call _lockRelease;
        if (_new isEqualTo "") then { _new = _old; };
        diag_log format ["[LooneyBin][ND] debit -%1 tok %2 %3 -> %4 = %5", _amt, _tok, _uid, ["DENIED", "OK"] select _ok, _new];
        [[_ok, _new, _tok], "life_fnc_ndResult", _pl, false] spawn life_fnc_MP;};};
