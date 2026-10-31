/*
    TON_fnc_intakeSRV  (LooneyBin, owner 2026-07-11)
    THE INTAKE, Act 1 -- server half of the new-player onboarding opener. The client (life_fnc_intake)
    runs the whole experience locally (cinematic, padded cell, interview, release); this fn owns the
    PERSISTENCE + the payout so none of it trusts the client's money math.

    players.intake_path: 0 = pending (fresh accounts; INSERT default), 1 = worker, 2 = criminal,
    3 = do-gooder, 9 = skipped/grandfathered. Existing accounts are backfilled to 9 by run-boot2's
    one-time marker (nobody who already lives here wakes up committed).

    Modes (CfgRE targets=2):
        ["complete", _player, _path]   interview finished -> persist path, pay the release stipend
        ["skip", _player]              player skipped -> path 9, no stipend
        ["step", _player, _step]       PAROLE PAPERS (Act 2): persist arc progress + pay that step's
                                       reward. Monotonic (a step only pays once, replay-proof); step
                                       255 = arc done. Rewards live in PLB_paroleRewards below.
        ["mentorlink", _newbie, _mUid] MENTOR PROGRAM (Act 3): link accepted -- pair stored server-side;
                                       the mentor is paid $1,000,000 when the newbie's arc completes (online =
                                       instant ack; offline = direct DB bank credit)
        ["reset", _player]             OWNER-ONLY test helper -> both cols back to 0 (re-runs on relog)
*/
#define INTAKE_STIPEND 2500
// _path is untyped on purpose: number for complete/step, mentor-UID STRING for "mentorlink"
params [["_mode", "", [""]], ["_player", objNull, [objNull]], ["_path", 0]];
if (!isServer) exitWith {};

// per-step payouts (index = the step JUST completed; finale = index 5)
PLB_paroleRewards = [2500, 2500, 5000, 7500, 5000, 15000];   // license, wheels, peaches, sell, talent, finale

// column ensure -- synchronous (mode 2, the storage_vault race lesson); backfill lives in run-boot2
if (isNil "PLB_intakeColReady") then {
    ["ALTER TABLE players ADD COLUMN IF NOT EXISTS intake_path TINYINT(1) NOT NULL DEFAULT 0", 2] call DB_fnc_asyncQuery;
    ["ALTER TABLE players ADD COLUMN IF NOT EXISTS intake_step TINYINT UNSIGNED NOT NULL DEFAULT 0", 2] call DB_fnc_asyncQuery;
    ["CREATE TABLE IF NOT EXISTS mentor_notify (id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, uid VARCHAR(17) NOT NULL, msg TEXT, INDEX idx_uid (uid))", 2] call DB_fnc_asyncQuery;
    PLB_intakeColReady = true;};

private _src = remoteExecutedOwner;
if (_src isNotEqualTo 0) then { _player = (allPlayers select { owner _x isEqualTo _src }) param [0, objNull]; };
if (isNull _player) exitWith {};
private _uid = getPlayerUID _player;
if (_uid isEqualTo "") exitWith {};
private _uidSql = (_uid splitString "\'""") joinString "";

switch (_mode) do {case "complete": {if (!(_path isEqualType 0) || {!(_path in [1, 2, 3])}) exitWith {};
        // one-shot: only a PENDING row completes (a replayed client call can't double-pay)
        private _cur = [format ["SELECT COALESCE(intake_path,0) FROM players WHERE playerid='%1'", _uidSql], 2] call DB_fnc_asyncQuery;
        if ((parseNumber format ["%1", _cur param [0, 1]]) isNotEqualTo 0) exitWith {
            ["-ONBOARD-", _player, format ["intake complete REPLAY ignored (uid %1)", _uid]] call PLB_fnc_logIt;};
        [format ["UPDATE players SET intake_path=%1 WHERE playerid='%2'", _path, _uidSql]] call DB_fnc_asyncQuery;
        // stipend ack -> the client pays itself (online money is client-authoritative in this codebase);
        // the client-side handler refuses any sender that isn't the server (remoteExecutedOwner 2 gate).
        [["ack", INTAKE_STIPEND], "life_fnc_intake", _src] call life_fnc_MP;
        ["-ONBOARD-", _player, format ["INTAKE COMPLETE path=%1 stipend=%2 uid=%3", _path, INTAKE_STIPEND, _uid]] call PLB_fnc_logIt;};
    case "skip": {
        [format ["UPDATE players SET intake_path=9 WHERE playerid='%1' AND COALESCE(intake_path,0)=0", _uidSql]] call DB_fnc_asyncQuery;
        ["-ONBOARD-", _player, format ["INTAKE SKIPPED uid=%1", _uid]] call PLB_fnc_logIt;};
    case "step": {private _step = _path;   // 3rd arg doubles as the step index for this mode
        if (!(_step isEqualType 0) || {_step < 0} || {_step > 5 && {_step isNotEqualTo 255}}) exitWith {};
        // monotonic: only pay when advancing PAST the stored value (replay/rollback-proof)
        private _cur = parseNumber format ["%1", ([format ["SELECT COALESCE(intake_step,0) FROM players WHERE playerid='%1'", _uidSql], 2] call DB_fnc_asyncQuery) param [0, 255]];
        private _new = if (_step isEqualTo 5) then { 255 } else { _step + 1 };   // finale closes the arc
        if (_new <= _cur) exitWith {
            ["-ONBOARD-", _player, format ["parole step %1 REPLAY ignored (cur %2) uid %3", _step, _cur, _uid]] call PLB_fnc_logIt;};
        [format ["UPDATE players SET intake_step=%1 WHERE playerid='%2'", _new, _uidSql]] call DB_fnc_asyncQuery;
        if (isNil "PLB_onboardTrack") then { PLB_onboardTrack = createHashMap; };
        if (_new isEqualTo 255) then { PLB_onboardTrack deleteAt _uid; } else { PLB_onboardTrack set [_uid, [_new, diag_tickTime]]; };
        // MENTOR payout hint needs the mentee's intake PATH (the step handler's 3rd arg is the step) --
        // one tiny SELECT on the just-graduated row.
        private _path = if (_new isEqualTo 255) then {
            parseNumber format ["%1", ([format ["SELECT COALESCE(intake_path,1) FROM players WHERE playerid='%1'", _uidSql], 2] call DB_fnc_asyncQuery) param [0, 1]]
        } else { 0 };
        // MENTOR payout: arc done + a linked mentor -> $1,000,000, online (ack) or offline (DB bank credit --
        // offline money is DB-authoritative here). One-shot: the link is consumed either way.
        if (_new isEqualTo 255 && {!isNil "PLB_mentorLinks"}) then {private _link = PLB_mentorLinks getOrDefault [_uid, []];
            if (_link isNotEqualTo []) then {_link params ["_mUid", "_mName"];
                // encouragement tailored to what the mentee said at INTAKE -- give the mentor a mission
                private _hint = switch (_path) do {
                    case 2: { "They answered 'criminal' at intake -- show them the REBEL life: licenses, a first run, a first gunfight." };
                    case 3: { "They lean do-gooder -- walk them to the National Guard recruiter or get them a bounty license." };
                    default { "They're a worker type -- take them on a real money run: copper, salt, the long hauls. Show them the island pays the patient." };
                };
                private _mentor = (allPlayers select { (getPlayerUID _x) isEqualTo _mUid }) param [0, objNull];
                if (!isNull _mentor) then {[["ack", 1000000], "life_fnc_intake", owner _mentor] call life_fnc_MP;
                    [["paid", name _player, _hint], "life_fnc_mentor", owner _mentor] call life_fnc_MP;} else {
                    private _mSql = (_mUid splitString "\'""") joinString "";
                    [format ["UPDATE players SET bankacc=bankacc+1000000 WHERE playerid='%1'", _mSql]] call DB_fnc_asyncQuery;
                    private _msg = format ["<t color='#c7a24e'>While you were away:</t> your mentee %1 finished their parole -- <t color='#c7a24e'>$1,000,000</t> deposited. %2", name _player, _hint];
                    [format ["INSERT INTO mentor_notify (uid, msg) VALUES ('%1', '%2')", _mSql, (_msg splitString "'") joinString "''"]] call DB_fnc_asyncQuery;
                };
                _player setVariable ["plb_mentorUid", nil, true];   // link consumed -> offer action valid again (not that they need one)
                ["-ONBOARD-", _player, format ["MENTOR PAID $1000000 -> %1 (%2, online %3) for graduating %4", _mName, _mUid, !isNull _mentor, _uid]] call PLB_fnc_logIt;
                PLB_mentorLinks deleteAt _uid;};};
        private _pay = PLB_paroleRewards param [_step, 0];
        if (_pay > 0) then { [["ack", _pay], "life_fnc_intake", _src] call life_fnc_MP; };
        ["-ONBOARD-", _player, format ["PAROLE step %1 done (+$%2) -> %3 uid %4", _step, _pay, _new, _uid]] call PLB_fnc_logIt;};
    case "mentorlink": {
        // caller = the NEWBIE (resolved from remoteExecutedOwner above); _path = the mentor's UID string
        private _mUid = (format ["%1", _path]) splitString "\'""" joinString "";
        if (_mUid isEqualTo "" || {_mUid isEqualTo _uid}) exitWith {};
        if !(_player getVariable ["plb_newBlood", false]) exitWith {};   // server-side truth, not client claim
        private _mentor = (allPlayers select { (getPlayerUID _x) isEqualTo _mUid }) param [0, objNull];
        if (isNull _mentor || {_mentor getVariable ["plb_newBlood", false]}) exitWith {};   // mentor online + not new blood
        if (isNil "PLB_mentorLinks") then { PLB_mentorLinks = createHashMap; };
        if ((PLB_mentorLinks getOrDefault [_uid, []]) isNotEqualTo []) exitWith {
            [["linked", "already linked -- one mentor per parolee"], "life_fnc_mentor", _src] call life_fnc_MP;};
        PLB_mentorLinks set [_uid, [_mUid, name _mentor]];
        _player setVariable ["plb_mentorUid", _mUid, true];   // hides the Offer action on every client
        [["linked", name _mentor], "life_fnc_mentor", _src] call life_fnc_MP;
        [["linked", name _player], "life_fnc_mentor", owner _mentor] call life_fnc_MP;
        ["-ONBOARD-", _player, format ["MENTOR LINKED %1 (%2) -> newbie %3 (%4)", name _mentor, _mUid, name _player, _uid]] call PLB_fnc_logIt;
    };
    case "reset": {if (_uid isNotEqualTo "76561190000000001") exitWith {};   // owner-only test helper
        [format ["UPDATE players SET intake_path=0, intake_step=0 WHERE playerid='%1'", _uidSql]] call DB_fnc_asyncQuery;
        diag_log "[LooneyBin][intake] owner reset -> pending (re-triggers next login/relog)";};};
