/*
    TON_fnc_govSystemSRV  (LooneyBin -- REBUILT 2026-06-13 for the owner's 7-DAY TERM model.)

    Model: ONE governor holds a 7-day term. The owner APPOINTS the first governor to start the cycle.
    During the term players REGISTER (runForOffice) + VOTE (one each). At term end the top-voted candidate
    is seated for the next 7-day term; if nobody ran, the sitting governor keeps the seat. Cycle repeats.

    Governor powers (law menu -> updateGovConfig): sales tax 0-15%, weed legal/illegal, SPAR-16 legal/illegal.
    Sales tax surcharge (the governor's % only -- the wealth "rich tax" stays a sink) is deposited into the
    governor TREASURY = gang id 50000's bank, which the governor withdraws via the gov bank menu.

    State:
      SRV_governorData (public) = [uid@0, name@1, tax@2, weedLegal@3, sparLegal@4, deathPen@5, electedAt@6]
                                   uid "" = vacant. termEnd = electedAt + GOV_TERM.
      SRV_govCandidates (server) = [[uid, name, policy, investment, votes], ...]
    Persistence: gov_state (single row id=1) for the seated governor; candidates + votes tables for the race.

    Cases:
      ["reload",            []]                                  BOOT: load gov_state + candidates + votes, arm timer
      ["appointGovernor",   [unit, uid, name]]                   owner-gated: seat a governor, fresh 7-day term
      ["runForOffice",      [unit, [name,uid,gang], side, investment, policy]]
      ["getCandidates",     [unit, side]]
      ["addCandidateVote",  [unit, voterUID, candUID]]
      ["addTaxToCache",     [amount]]                            deposit governor tax into the treasury (gang 50000)
      ["updateGovConfig",   [[tax, weedLegal, sparLegal]]]       governor sets laws
*/
#define GOV_TERM   604800          // 7 days in seconds
#define GOV_ELECTION 604800        // 7-day OPEN-ELECTION window (vacant seat self-start, #330) -- from the FIRST candidacy
#define GOV_GANG   "50000"         // treasury gang id
#define GOV_OWNER  "76561190000000001"

params [["_caseType", "", [""]], ["_data", [], [[]]]];
// owner 2026-07-24 SECURITY (audit): CfgRE allowedTargets=2, and the authorisation in "appointGovernor"
// (owner-only) and "updateGovConfig" (governor-only) both read `getPlayerUID _unit`, where _unit is an
// element of the CLIENT-supplied _data array. Passing somebody else's player object -- the owner's, or the
// seated governor's -- satisfied either check, letting any client seat a governor or rewrite the tax and
// legalisation policy. "runForOffice" and "addCandidateVote" were equally impersonatable.
// Force element 0 to the real caller for the cases that take a unit there. Scoped by case ON PURPOSE:
// "addTaxToCache" passes [_amount] and "reload" passes no unit, so a blind element-0 overwrite would
// corrupt their arguments. Legit clients always pass `player`, so this is a no-op for honest calls.
private _srcGov = remoteExecutedOwner;   // 0 == server-internal (boot reload / server tax) = trusted
if (_srcGov isNotEqualTo 0 && {_caseType in ["appointGovernor", "runForOffice", "getCandidates", "addCandidateVote", "updateGovConfig"]}) then {
    private _govCaller = (allPlayers select { owner _x isEqualTo _srcGov }) param [0, objNull];
    if (isNull _govCaller) then {_data = [];   // unresolvable -> each case's own `isNull _unit` guard drops it
    } else {if (_data isEqualType [] && {count _data > 0}) then {if (!((_data select 0) isEqualTo _govCaller)) then {
                ["-SEC-", _govCaller, format ["BLOCKED govSystem impersonation (%1): claimed %2", _caseType, _data select 0]] call PLB_fnc_logIt;
            };
            _data set [0, _govCaller];};};};
if (isNil "SRV_govCandidates") then { SRV_govCandidates = []; };
if (isNil "SRV_governorData")  then { SRV_governorData  = ["", "", 0, false, false, false, 0]; };
if (isNil "SRV_govTermGen")    then { SRV_govTermGen    = 0; };   // term generation -> kills stale armed timers
if (isNil "SRV_govElectionArmed") then { SRV_govElectionArmed = false; };   // #330 self-start: only one open-election timer at a time

// owner 2026-06-24 (#521 "gov doesn't work through a restart"): the reload SELECTs wrap playerid/name/policy in
// SQL QUOTE() (so a name with a comma can't break the 2D-array parse), but QUOTE() ADDS literal single-quotes to the
// VALUE -> SRV_governorData[0] loaded as "'765...'" instead of "765...". Every "is the caller the governor?" check
// (law menu, treasury, re-seat) compares getPlayerUID (no quotes) and silently failed -> a restarted governor kept
// the title but lost all power. Same poisoned the candidate UIDs (voting/ballot lookups). Strip the QUOTE wrapping on
// read: outer quotes off, and un-double QUOTE's interior '' escaping. (UIDs are numeric -> always clean after this.)
PLB_fnc_govUnq = {private _s = format ["%1", _this];
    if ((count _s) >= 2 && {(_s select [0,1]) isEqualTo "'"} && {(_s select [(count _s) - 1, 1]) isEqualTo "'"}) then {
        _s = _s select [1, (count _s) - 2];   // strip the outer '...' QUOTE() wrapping (UIDs are numeric -> clean)
    };
    _s};

// persist the seated governor to gov_state (single row id=1). bool -> 0/1 via select.
PLB_fnc_govPersist = {private _g = SRV_governorData;
    private _nameSafe = ((_g param [1, ""]) splitString "\'""") joinString "";
    [format ["REPLACE INTO gov_state (id, playerid, name, tax, weedlegal, sparlegal, deathpen, elected_at) VALUES (1,'%1','%2',%3,%4,%5,%6,%7)",
        _g param [0, ""], _nameSafe, _g param [2, 0], (["0", "1"] select (_g param [3, false])), (["0", "1"] select (_g param [4, false])),
        (["0", "1"] select (_g param [5, false])), _g param [6, 0]]] call DB_fnc_asyncQuery;};

// seat a governor (winner of the race, the re-seated incumbent, or an owner appointment). Starts a fresh
// 7-day term, clears the race, broadcasts, persists, re-arms the term timer.
PLB_fnc_govSeat = {params ["_uid", "_name", ["_announce", true]];
    // carry the incumbent's laws if re-seating the same person; otherwise default laws for a new governor.
    private _same = (_uid isEqualTo (SRV_governorData param [0, ""])) && {_uid isNotEqualTo ""};
    private _tax  = if (_same) then { SRV_governorData param [2, 0] }     else { 0 };
    private _weed = if (_same) then { SRV_governorData param [3, false] } else { false };
    private _spar = if (_same) then { SRV_governorData param [4, false] } else { false };
    private _dp   = if (_same) then { SRV_governorData param [5, false] } else { false };
    private _nowU = parseNumber format ["%1", (["SELECT UNIX_TIMESTAMP()", 2] call DB_fnc_asyncQuery) select 0];
    SRV_governorData = [_uid, _name, _tax, _weed, _spar, _dp, _nowU];
    SRV_govTermGen = SRV_govTermGen + 1;   // invalidate any timer armed for the previous term (anti double-resolve)
    publicVariable "SRV_governorData";
    call PLB_fnc_govPersist;
    SRV_govCandidates = [];
    ["DELETE FROM votes"] call DB_fnc_asyncQuery;
    ["DELETE FROM candidates"] call DB_fnc_asyncQuery;
    if (_announce) then {
        [[0, format ["%1 has taken office as GOVERNOR of %2! Term: 7 days.", _name, worldName]], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
    };
    ["-GOV-", objNull, format ["seated governor %1 (%2), termEnd in %3s", _name, _uid, GOV_TERM]] call PLB_fnc_logIt;
    ["GOV", format ["LIZARD INSTALLED IN OFFICE -- %1 SWORN IN, TONGUE NOT SHOWN", _name], format ["they SEATED %1 as governor. i have never seen them blink. think about it.", _name]] call TON_fnc_newsPush;   // DataBattle
    call PLB_fnc_govArmTimer;};

// resolve at term end: top-voted candidate wins; if nobody ran, the incumbent keeps the seat for another term.
PLB_fnc_govResolve = {if (SRV_govCandidates isEqualTo []) exitWith {private _cur = SRV_governorData param [0, ""];
        if (_cur isNotEqualTo "") then {
            [SRV_governorData param [0, ""], SRV_governorData param [1, ""], false] call PLB_fnc_govSeat;   // re-seat, quiet
            [[0, "No candidates ran -- the sitting Governor keeps office for another 7-day term."], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
        } else {SRV_governorData = ["", "", 0, false, false, false, 0]; publicVariable "SRV_governorData";};};
    private _w = [];
    { if (_w isEqualTo [] || {(_x select 4) > (_w select 4)}) then { _w = _x; }; } forEach SRV_govCandidates;
    _w params ["_wUID", "_wName", "_wPolicy", "_wInv", "_wVotes"];
    [_wUID, _wName] call PLB_fnc_govSeat;
    [[0, format ["ELECTION OVER: %1 won with %2 vote(s) and is the new Governor!", _wName, _wVotes]], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
};

// arm ONE watcher that fires PLB_fnc_govResolve when the 7-day term expires. Idempotent (a stray second
// watcher just re-checks the same time). Re-armed on every seat.
PLB_fnc_govArmTimer = {private _gen = SRV_govTermGen;   // capture this term's generation; a later seat bumps it and retires us
    [_gen] spawn {params ["_gen"];
        waitUntil {uiSleep 30;
            (SRV_govTermGen != _gen) ||
            (SRV_governorData param [0, ""] isEqualTo "") ||
            { private _nowU = parseNumber format ["%1", (["SELECT UNIX_TIMESTAMP()", 2] call DB_fnc_asyncQuery) select 0];
              _nowU >= ((SRV_governorData param [6, 0]) + GOV_TERM) }};
        // only the CURRENT-generation timer resolves; a stale one (new term seated meanwhile) just exits.
        if (SRV_govTermGen isEqualTo _gen && {SRV_governorData param [0, ""] isNotEqualTo ""}) then {
            private _nowU = parseNumber format ["%1", (["SELECT UNIX_TIMESTAMP()", 2] call DB_fnc_asyncQuery) select 0];
            if (_nowU >= ((SRV_governorData param [6, 0]) + GOV_TERM)) then { call PLB_fnc_govResolve; };};};};

// SELF-START open election (owner 2026-06-17 #330): with NO governor seated but candidates running, resolve the
// race after an open-election window (GOV_ELECTION measured from the FIRST candidacy) -> seats the top-voted as
// the first governor, which then starts the normal 7-day term cycle. Without this, a vacant seat had no term
// timer, so persisted votes never elected anyone. Idempotent (one timer); aborts if a governor gets seated
// (e.g. an owner appointment) or the race empties before the deadline. Re-armed on every boot by "reload".
// owner 2026-06-24 (#515): purge ZOMBIE candidacies + resync the in-memory ballot from the survivors. Candidates from a
// never-resolved open election linger across restarts; their stale started_at makes MIN(started_at) already past the
// election window, so the deadline check fires on the FIRST 30s tick -> the open election "closes 30 seconds after
// someone pays 150k to run" (player095, #515) and seats whoever held stale votes. Purging by the FULL window keeps a LIVE
// cycle's candidates (<7d) and drops only truly-expired rows; the survivors then define the real deadline.
PLB_fnc_govPurgeStaleAndSync = {
    private _nowU = parseNumber format ["%1", (["SELECT UNIX_TIMESTAMP()", 2] call DB_fnc_asyncQuery) select 0];
    ["DELETE FROM candidates WHERE started_at < " + str (_nowU - GOV_ELECTION)] call DB_fnc_asyncQuery;
    private _rows = ["SELECT QUOTE(playerid), QUOTE(name), QUOTE(COALESCE(policy,'')), investment FROM candidates", 2, true] call DB_fnc_asyncQuery;
    SRV_govCandidates = [];
    if (_rows isEqualType []) then {{_x params [["_u", ""], ["_n", ""], ["_p", ""], ["_inv", 0]];
            _u = _u call PLB_fnc_govUnq; _n = _n call PLB_fnc_govUnq; _p = _p call PLB_fnc_govUnq;   // #521: strip QUOTE() wrapping (uid must match votes/getPlayerUID)
            if (_u isNotEqualTo "") then {
                private _vc = [format ["SELECT COUNT(*) FROM votes WHERE candidate='%1'", _u], 2] call DB_fnc_asyncQuery;
                SRV_govCandidates pushBack [_u, _n, _p, _inv, parseNumber format ["%1", (_vc param [0, 0])]];};} forEach _rows;};};

PLB_fnc_govArmElectionTimer = {
    if ((SRV_governorData param [0, ""]) isNotEqualTo "") exitWith {};   // already seated -> the term timer owns resolution
    call PLB_fnc_govPurgeStaleAndSync;   // #515: clear zombie candidacies + resync the ballot BEFORE deciding/arming
    if (SRV_govCandidates isEqualTo []) exitWith {};                     // no LIVE race left -> nothing to resolve
    if (SRV_govElectionArmed) exitWith {};                              // already armed -> idempotent
    SRV_govElectionArmed = true;
    ["-GOV-", objNull, "open-election self-start armed (vacant seat + candidates)"] call PLB_fnc_logIt;
    [] spawn {private _fnc_deadline = {private _r = ["SELECT MIN(started_at) FROM candidates", 2] call DB_fnc_asyncQuery;
            private _first = parseNumber format ["%1", (_r param [0, 0])];
            if (_first <= 0) then { 0 } else { _first + GOV_ELECTION }};
        waitUntil {uiSleep 30;
            ((SRV_governorData param [0, ""]) isNotEqualTo "") ||   // seated meanwhile (appointment) -> abort
            (SRV_govCandidates isEqualTo []) ||                     // race emptied -> abort
            { private _dl = call _fnc_deadline;
              (_dl > 0) && { (parseNumber format ["%1", (["SELECT UNIX_TIMESTAMP()", 2] call DB_fnc_asyncQuery) select 0]) >= _dl } }};
        SRV_govElectionArmed = false;
        // resolve ONLY if still genuinely vacant + candidates past the deadline (a seat/appoint meanwhile cancels it)
        if ((SRV_governorData param [0, ""]) isEqualTo "" && {SRV_govCandidates isNotEqualTo []}) then {private _dl = call _fnc_deadline;
            if (_dl > 0 && {(parseNumber format ["%1", (["SELECT UNIX_TIMESTAMP()", 2] call DB_fnc_asyncQuery) select 0]) >= _dl}) then {
                ["-GOV-", objNull, "open-election deadline reached -> resolving (self-start)"] call PLB_fnc_logIt;
                call PLB_fnc_govResolve;};};};};

switch (_caseType) do {case "reload": {   // BOOT: load seated governor + the in-flight race from DB, resume the term timer
        // ensure the treasury gang exists so deposits/withdraws have a row to hit
        ["INSERT IGNORE INTO gangs (id, name, bank) VALUES (50000, 'Government', 0)"] call DB_fnc_asyncQuery;
        private _gs = ["SELECT QUOTE(playerid), QUOTE(name), tax, weedlegal, sparlegal, deathpen, elected_at FROM gov_state WHERE id=1", 2, true] call DB_fnc_asyncQuery;
        // owner 2026-06-28 (#gov "powers dead + treasury broken on live"): the reload was silently NOT seating the
        // persisted governor -> SRV_governorData stayed empty -> every gov-gated action (law menu, bank/withdraw,
        // pardon) failed the `getPlayerUID player == SRV_governorData param[0]` check. Live RPT showed NO "reloaded
        // governor" line at boot despite a valid gov_state row, so this row-extraction skipped. Root: the [query,2,true]
        // result shape was assumed strictly 2D (LIST OF ROWS), but extDB3 can return a SINGLE row UNWRAPPED (flat) -> the
        // old guard `(_gs select 0) isEqualType []` saw a uid STRING, not a row, and bailed to []. Handle BOTH shapes.
        diag_log format ["[LooneyBin][gov] reload: raw gov_state result = %1", _gs];
        private _row =
            if (_gs isEqualType [] && {count _gs > 0}) then {
                if ((_gs select 0) isEqualType []) then { _gs select 0 } else { _gs }   // 2D list-of-rows -> row0; else flat single row
            } else { [] };
        if ((count _row) >= 7 && {((_row select 0) call PLB_fnc_govUnq) isNotEqualTo ""}) then {SRV_governorData = [
                (_row select 0) call PLB_fnc_govUnq, (_row select 1) call PLB_fnc_govUnq,   // #521: strip QUOTE() wrapping (uid must match getPlayerUID)
                parseNumber format ["%1", _row select 2], ((format ["%1", _row select 3]) != "0"), ((format ["%1", _row select 4]) != "0"),
                ((format ["%1", _row select 5]) != "0"), parseNumber format ["%1", _row select 6]];
            publicVariable "SRV_governorData";
            call PLB_fnc_govArmTimer;
            diag_log format ["[LooneyBin][gov] reloaded governor %1 (term ends at unix %2)", SRV_governorData select 1, (SRV_governorData select 6) + GOV_TERM];
        };
        // rebuild the candidate list + vote tallies via the shared helper, which ALSO purges zombie candidacies
        // (expired-window rows) -- so a stale started_at from a never-resolved election can't instant-resolve a
        // fresh open election right after boot (#515).
        call PLB_fnc_govPurgeStaleAndSync;;
        // #330 self-start: vacant seat + candidates just loaded -> arm the open-election timer (no-op if a
        // governor was seated above, or if there are no candidates).
        call PLB_fnc_govArmElectionTimer;};

    case "appointGovernor": {_data params [["_unit", objNull, [objNull]], ["_uid", "", [""]], ["_name", "", [""]]];
        if (isNull _unit || {_uid isEqualTo ""}) exitWith {};
        if ((getPlayerUID _unit) isNotEqualTo GOV_OWNER) exitWith {
            [["Only the server owner can appoint a governor.", "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
        };
        [_uid, _name] call PLB_fnc_govSeat;};

    case "runForOffice": {
        _data params [["_unit", objNull, [objNull]], ["_id", [], [[]]], ["_side", civilian], ["_investment", 0, [0]], ["_policy", "", [""]]];
        if (isNull _unit) exitWith {};
        // SECURITY: derive uid+name from the player object SERVER-SIDE -- never trust the client-supplied _id
        // (a crafted client could file a candidacy AS someone else). _investment stays client-side (the buyer
        // already paid it in fn_govCandidateMenu; it's only stored/displayed, never refunded or paid out).
        private _uid  = getPlayerUID _unit;
        private _name = name _unit;
        if (_uid isEqualTo "") exitWith {};
        if ((SRV_governorData param [0, ""]) isEqualTo _uid) exitWith {
            [["You are already the sitting Governor.", "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;};
        if ((SRV_govCandidates findIf { (_x select 0) isEqualTo _uid }) > -1) exitWith {
            [["You are already on the ballot.", "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;};
        private _policySafe = (_policy splitString "\'""") joinString "";
        private _nameSafe   = (_name splitString "\'""") joinString "";
        SRV_govCandidates pushBack [_uid, _name, _policySafe, _investment, 0];
        [format ["REPLACE INTO candidates (playerid, name, policy, investment, started_at) VALUES ('%1','%2','%3',%4,UNIX_TIMESTAMP())", _uid, _nameSafe, _policySafe, _investment]] call DB_fnc_asyncQuery;
        [[0, format ["%1 is running for Governor! Policy: %2 -- vote at any voting booth before the term ends.", _name, _policySafe]], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
        ["-GOV-", _unit, format ["filed candidacy (invest %1): %2", _investment, _policySafe]] call PLB_fnc_logIt;
        // #330 self-start: if the seat is vacant, arm the open-election timer so this race resolves on its own
        // (top-voted seated as first governor) without needing an owner appointment. Idempotent.
        call PLB_fnc_govArmElectionTimer;};

    case "getCandidates": {_data params [["_unit", objNull, [objNull]]];
        if (isNull _unit) exitWith {};
        [["life_govCandidates", SRV_govCandidates], "life_fnc_netSetVar", _unit, false, false] spawn life_fnc_MP;
        [["life_govCandidatesRequested", true], "life_fnc_netSetVar", _unit, false, false] spawn life_fnc_MP;};

    case "addCandidateVote": {_data params [["_unit", objNull, [objNull]], ["_ignoredVoterUID", "", [""]], ["_candUID", "", [""]]];
        if (isNull _unit || {_candUID isEqualTo ""}) exitWith {};
        // SECURITY: the voter UID is the SERVER-resolved uid of the caller, NOT the client-sent value -- else a
        // crafted client could spoof different voter UIDs and stuff the ballot past the one-vote-per-player gate.
        private _voterUID = getPlayerUID _unit;
        if (_voterUID isEqualTo "") exitWith {};
        private _ci = SRV_govCandidates findIf { (_x select 0) isEqualTo _candUID };
        if (_ci isEqualTo -1) exitWith {
            [["That candidate is no longer on the ballot.", "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;};
        private _already = [format ["SELECT 1 FROM votes WHERE playerid='%1' LIMIT 1", _voterUID], 2] call DB_fnc_asyncQuery;
        if (_already isEqualType [] && {count _already > 0}) exitWith {
            [["You have already voted in this election!", "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;};
        [format ["INSERT INTO votes (playerid, candidate) VALUES ('%1', '%2')", _voterUID, _candUID]] call DB_fnc_asyncQuery;
        (SRV_govCandidates select _ci) set [4, ((SRV_govCandidates select _ci) select 4) + 1];
        [["Your vote has been cast!", "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
        ["-GOV-", _unit, format ["voted for %1", _candUID]] call PLB_fnc_logIt;};

    case "addTaxToCache": {_data params [["_amount", 0, [0]]];
        if (_amount <= 0) exitWith {};
        if ((SRV_governorData param [0, ""]) isEqualTo "") exitWith {};   // no governor -> the surcharge is just a sink
        // SECURITY: this is a client-trusted deposit (the buyer's cash was debited client-side). Hard-cap the
        // per-call amount so a crafted client can't pump the treasury to absurd values. 5m matches payGovernor's
        // client cap and comfortably covers a legit combined-tax (gov% + wealth%, up to ~30%) on the priciest
        // purchases (houses). Oversized = drop + log for the anti-cheat (CLANKR).
        _amount = floor _amount;
        if (_amount > 5000000) exitWith {["-GOV-", objNull, format ["REJECTED oversized tax deposit: $%1", _amount]] call PLB_fnc_logIt;};
        // deposit into the treasury (gang 50000). relative DB update + keep the in-memory cache in sync.
        [format ["UPDATE gangs SET bank = (bank + %1) WHERE id='%2'", _amount, GOV_GANG], 2] call DB_fnc_asyncQuery;
        private _gi = life_server_gangs findIf { (format ["%1", _x select 0]) isEqualTo GOV_GANG };
        if (_gi > -1) then { private _g = life_server_gangs select _gi; _g set [5, (_g select 5) + _amount]; life_server_gangs set [_gi, _g]; };
        ["-GOV-", objNull, format ["tax +$%1 -> treasury", _amount]] call PLB_fnc_logIt;};

    case "updateGovConfig": {_data params [["_unit", objNull, [objNull]], ["_cfg", [], [[]]]];
        if (_cfg isEqualTo []) exitWith {};
        // SECURITY: ONLY the sitting governor may change laws. Verify the caller server-side (was missing -> any
        // client could remoteExec law changes). Also covers the vacant-seat case (getPlayerUID != "" unless null).
        if (isNull _unit || {(getPlayerUID _unit) isNotEqualTo (SRV_governorData param [0, ""])}) exitWith {};
        // [tax(0-15), weedLegal(bool), sparLegal(bool)]
        private _rate = floor (((_cfg param [0, 5]) max 0) min 15);
        private _weed = _cfg param [1, false];
        private _spar = _cfg param [2, false];
        SRV_governorData set [2, _rate];
        SRV_governorData set [3, _weed];
        SRV_governorData set [4, _spar];
        publicVariable "SRV_governorData";
        call PLB_fnc_govPersist;
        [[0, format ["The Governor set sales tax to %1%2, weed %3, SPAR-16s %4.", _rate, "%", (["illegal", "legal"] select _weed), (["illegal", "legal"] select _spar)]], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
        ["-GOV-", objNull, format ["laws updated: tax %1 weed %2 spar %3", _rate, _weed, _spar]] call PLB_fnc_logIt;};

    default { diag_log format ["[LooneyBin][gov] unhandled case: %1", _this]; };};
