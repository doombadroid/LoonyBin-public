/*
    DB_fnc_queryRequest  (LooneyBin: 2020 player load)
    client fn_dataQuery -> [player, playerSide]
    Builds the exact 32-element side-array that life_fnc_requestReceived parses and
    sends it back to the client. New players (no row) -> send nil -> client inserts.
    Schema: sql/looneybin_schema.sql (players + players_global). Load index map: see
    core/session/fn_requestReceived.sqf.
    TODO: houses(27)/vehicles/gang(28) sent empty for now -> loaded via their own menus.
*/
params [["_player",objNull,[objNull]],["_side",civilian,[civilian]]];
if (isNull _player) exitWith {};
private _plb_t0 = diag_tickTime;   // LooneyBin [PERF step 1]: connect-load instrumentation (logged at the end)
private _uid = getPlayerUID _player;
private _client = owner _player;

// owner 2026-07-24 SECURITY (audit: bans were unenforced): the ban gate used to live ONLY in
// DB_fnc_insertRequest, which fn_requestReceived calls only when the server's load payload is
// nil / String / empty -- i.e. only for a player with NO players_global row. Every RETURNING player
// (anyone who has played before, which is every banned player by definition) skipped it entirely, so
// admin bans and CLANKR auto-bans were both dead on reconnect. This is the one load path every player
// takes (client fn_dataQuery -> here; new players arrive via insertRequest -> here), and _uid above is
// engine-derived from getPlayerUID, not a client argument, so it cannot be spoofed or injected.
// FAIL-OPEN by design: DB_fnc_asyncQuery returns [] on ANY error, so a DB hiccup can never wrongly
// block a legitimate load -- it just fails to enforce, same as the original gate.
private _banRow = [format ["SELECT id FROM bans WHERE playerid='%1' AND (until IS NULL OR until > NOW()) LIMIT 1", _uid], 2] call DB_fnc_asyncQuery;
if (_banRow isEqualType [] && {(count _banRow) > 0}) exitWith {diag_log format ["[LooneyBin] banned player blocked on load: %1", _uid];
    [["You are banned from this server."], "life_fnc_botKick", _player, false, false] spawn life_fnc_MP;};

private _dec = { // backtick-encoded DB string -> SQF value (array/[] )
    params [["_v", ""]];   // accept any type: a NULL text column arrives pre-decoded as an array, not a string
    // LooneyBin: NULL-safe. A NULL DB column (e.g. a never-saved civ_gear) comes back as "" or the
    // literal "NULL"; mresToArray/compile on it can yield nil. Returning nil here makes the client do
    // `life_gear = _this select 6` = nil, which UNDEFINES life_gear (SQF) -> fn_loadGear strips the
    // player then errors before re-dressing -> spawned NAKED and never re-saves -> stuck naked
    // forever. Always return a real array so the client falls back to the default loadout instead.
    if (isNil "_v") exitWith {[]};
    if (_v isEqualType []) exitWith {_v};   // NULL text col (e.g. never-saved medic_talents) arrives pre-decoded as an array -> pass through; no mresToArray, no "Type Array, expected String" warn
    if (_v isEqualTo "" || {_v isEqualTo "NULL"}) exitWith {[]};
    private _a = [_v] call DB_fnc_mresToArray;
    if (typeName _a == "STRING") then { _a = parseSimpleArray (format ["%1", _a]); };   // SECURITY: parse, never call compile -- a poisoned free-text column (gear/name) would otherwise execute as SQF on login (Lystic compile-RCE class)
    if (isNil "_a") then { _a = []; };
    _a};
private _num = { parseNumber (format ["%1", _this]) };

// --- global (account) row ---
private _gq = format ["SELECT adminlevel,eventcoordinatorlvl,coplevel,copretired,mediclevel,achievements,stats,honor_exp,honor_talents,lootrewards,betatester,QUOTE(COALESCE(lifetime_stats,'[]')) FROM players_global WHERE playerid='%1'", _uid];
private _g = [_gq,2] call DB_fnc_asyncQuery;
if (_g isEqualTo []) exitWith {
    // NB: `nil remoteExecCall [...]` transmits NO argument and the engine drops the call ->
    // client never enters requestReceived. Send an explicit empty array; the client's
    // requestReceived treats count==0 as new-player (calls insertPlayerInfo).
    [] remoteExec ["life_fnc_requestReceived", _client];}; // new player

private _sideFlag = switch (_side) do { case west:{"cop"}; case independent:{"med"}; default {"civ"} };
private _gearCol = format ["%1_gear", _sideFlag];
private _talCol  = format ["%1_talents", _sideFlag];
private _expCol  = format ["%1_exp", _sideFlag];
private _licCol  = format ["%1_licenses", _sideFlag];

// LooneyBin: Discord !link 500k + beta-tester 1M bank grants moved DOWN -- they now run AFTER the
// players-row existence check (the `_p isEqualTo [] exitWith` below) and patch _bank in memory. Previously
// they ran HERE, before the row check, which LOST the grant for a never-joined linker whose players_global
// row had been pre-created by loonybot's retroactive sweep: the UPDATE hit 0 rows (no players row yet) but
// still cleared the flag, so the second pass (after insertRequest creates the row) saw it already cleared.

// --- player (character) row, current side's columns ---
// licenses col (%5) is UNQUOTED, exactly like the gear col (%2): both are str2-encoded with their own
// outer double-quotes, which serve as the string delimiters for asyncQuery's compile. QUOTE-ing it
// would double-wrap (the stored value already has outer quotes) and break _dec.
// LooneyBin 2026-07-23 NEW DRACHMA: new_drachma is QUOTE-wrapped so it loads as an EXACT 4dp STRING
// (asyncQuery's call-compile consumes the single quotes as delimiters -> _p select 2 is a bare string).
// A parseNumber here would drop it back into a 32-bit float and defeat the whole point.
private _pq = format ["SELECT cash,bankacc,QUOTE(new_drachma),%2,%3,%4,prestige,infamy_exp,infamy_talents,arrested,crimes,position,gov_data,completed_quests,progress_quests,title,isswat,isfirefighter,gang0,new_player,QUOTE(COALESCE(prefix,'')),gangrank0,%5,medic_prestige,medic_talents,pre_talents,isdetective,casino_banned,COALESCE(intake_path,0),COALESCE(intake_step,0),QUOTE(COALESCE(cyberdeck_modules,'[]')) FROM players WHERE playerid='%1'", _uid, _gearCol, _talCol, _expCol, _licCol];
private _p = [_pq,2] call DB_fnc_asyncQuery;
if (_p isEqualTo []) exitWith { [] remoteExec ["life_fnc_requestReceived", _client]; };

// LooneyBin: alias tracking for loonybot !info. queryRequest is the universal connect-load path
// (returning players AND new players, via insertRequest's tail call), so every connect lands here
// once the row exists. Dedup on UNIQUE(playerid,name) -> a repeat name just bumps `seen`. Sanitize
// the name like insertRequest (SQF has no string-minus operator; split on the unsafe chars + rejoin).
// mode-1 fire-and-forget: a failed write must never delay the player's data push below.
private _pname = (name _player) splitString "\'""" joinString "";
if (_pname != "") then {
    [format ["INSERT INTO player_names (playerid,name) VALUES ('%1','%2') ON DUPLICATE KEY UPDATE seen=NOW()", _uid, _pname]] call DB_fnc_asyncQuery;
};

// owner 2026-06-20: mark this connection ONLINE. The `online` table's ONLY INSERT lived in the dead 2017
// fn_query.sqf session path (never called in this live queryRequest connect flow) -> `online` was ALWAYS EMPTY,
// so Enrique's offline-gate (is_online = SELECT COUNT FROM online WHERE playerid) never blocked an online player
// (and any other `online` consumer read 0). Boot cleanup (init.sqf DELETE WHERE instance) + the disconnect DELETE
// (fn_playerDisconnected) already maintain it; only the CONNECT insert was missing. INSERT IGNORE = a reconnect
// with a stale row just keeps it (still online); PK is (playerid,instance). mode-1 fire-and-forget so a write
// hiccup never delays the player's data push. _pname is already sanitized above.
[format ["INSERT IGNORE INTO `online` (`playerid`,`name`,`instance`) VALUES ('%1','%2',%3)", _uid, _pname, life_server_instance]] call DB_fnc_asyncQuery;

// global fields
private _admin     = (_g select 0) call _num;
private _eventCoord= (_g select 1) call _num;
private _donor     = 0;                          // donorlevel column dropped (placeholder for wire pos)
private _copLvl    = (_g select 2) call _num;
// owner 2026-06-20: OWNER cop rank -- the owner (locked UID) ALWAYS gets full CHIEF (7) powers regardless of their
// stored coplevel. Their DISPLAY rank is a CUSTOM title (plb_ownerCopTitle, set in-game via the "Set My APD Title"
// scroll action + shown by fn_getRankString), but the POWERS are Chief. Owner-only -- no whitelist column needed.
if (_uid isEqualTo "76561190000000001") then { _copLvl = _copLvl max 7; };
private _copRet    = (_g select 3) call _num;
private _medLvl    = (_g select 4) call _num;
private _sub       = 0;                           // subscribed column dropped (placeholder)
private _achv      = [_g select 5] call _dec;
private _stats     = [_g select 6] call _dec;
// singleevh.md Phase 3a.2: parse the 148-slot lifetime_stats -> client PLB_stats_live (login reply field 15).
// Plain str number-array, QUOTE-wrapped in the SELECT; strip wrappers + parseSimpleArray (mirrors getStatsArr).
private _ltStats = [];
private _ltRaw = (format ["%1", _g param [11, "[]"]]) splitString "`'""" joinString "";
if (_ltRaw isEqualTo "") then { _ltRaw = "[]"; };
_ltStats = parseSimpleArray _ltRaw;
if !(_ltStats isEqualType []) then { _ltStats = []; };
private _honorExp  = (_g select 7) call _num;
private _honorTal  = [_g select 8] call _dec;
private _loot      = [_g select 9] call _dec;
private _lootKeys  = [];                          // lootkeys column dropped (placeholder)
private _beta      = (_g select 10) call _num;    // betatester whitelist flag -> wired to load slot 35 (PLB_betaTester)

// player fields
private _cash   = (_p select 0) call _num;
private _bank   = (_p select 1) call _num;
// owner 2026-06-13: !link 500k + beta-tester 1M bank grants. ROW-GATED -- we're past the `_p isEqualTo []`
// exit above, so the players row EXISTS. A never-joined linker (players_global row pre-made by loonybot's
// sweep) now gets the grant on their REAL first connect (after insertRequest creates the row), not lost.
// Patch _bank in memory so the loaded bank reflects it; clear the one-time flags. Online-safe.
private _reward = [format ["SELECT reward_pending FROM discord_links WHERE playerid='%1'", _uid], 2] call DB_fnc_asyncQuery;
if (_reward isEqualType [] && {count _reward > 0} && {(((_reward select 0) param [0, 0]) call _num) isEqualTo 1}) then {
    [format ["UPDATE players SET bankacc=bankacc+500000 WHERE playerid='%1'", _uid], 2] call DB_fnc_asyncQuery;
    [format ["UPDATE discord_links SET reward_pending=0 WHERE playerid='%1'", _uid], 2] call DB_fnc_asyncQuery;
    _bank = _bank + 500000;
    diag_log format ["[LooneyBin][link] granted 500k bank reward to %1", _uid];};
private _betaReward = [format ["SELECT beta_pending FROM discord_links WHERE playerid='%1'", _uid], 2] call DB_fnc_asyncQuery;
if (_betaReward isEqualType [] && {count _betaReward > 0} && {(((_betaReward select 0) param [0, 0]) call _num) isEqualTo 1}) then {
    [format ["UPDATE players SET bankacc=bankacc+1000000 WHERE playerid='%1'", _uid], 2] call DB_fnc_asyncQuery;
    [format ["UPDATE discord_links SET beta_pending=0 WHERE playerid='%1'", _uid], 2] call DB_fnc_asyncQuery;
    _bank = _bank + 1000000;
    diag_log format ["[LooneyBin][beta] granted 1M beta-tester bonus to %1", _uid];};
// NEW DRACHMA: keep the exact string (QUOTE-wrapped above). Guard a nil/non-string to "0".
private _ndBal  = _p select 2; if (isNil "_ndBal" || {!(_ndBal isEqualType "")}) then { _ndBal = "0"; };
private _gear   = [_p select 3] call _dec;
// NEW DRACHMA 2026-07-23: legacy loonycoin (New Drachma coin item) auto-converts to the WALLET at login,
// 1 coin = 1 ND. Done SERVER-SIDE off the persisted gear blob (not client-trusted): the coin count is read
// from what the DB stored, so a modified client can't inflate it. loonycoin is WEIGHTLESS (owner 2026-07-22),
// so filtering it out never changes the saved carry-weight -> we only drop the row + credit the wallet, then
// re-SELECT the exact new balance string. Civ side only (that's where mining lands); gear shape guarded so a
// malformed blob just skips the sweep (coins stay, no harm). Miners now deposit ND directly, so this is a
// one-time drain of pre-switch stock.
if (_sideFlag isEqualTo "civ" && {_gear isEqualType []} && {count _gear >= 2} && {(_gear select 1) isEqualType []} && {count (_gear select 1) >= 1} && {((_gear select 1) select 0) isEqualType []}) then {
    private _inv = (_gear select 1) select 0;   // [[item,count],...]
    private _coins = 0;
    { if ((_x isEqualType []) && {count _x >= 2} && {(_x select 0) isEqualTo "loonycoin"}) then { _coins = _coins + (_x select 1); }; } forEach _inv;
    if (_coins > 0) then {
        private _newInv = _inv select { !((_x isEqualType []) && {count _x >= 2} && {(_x select 0) isEqualTo "loonycoin"}) };
        (_gear select 1) set [0, _newInv];   // weightless -> (_gear select 1) select 1 (weight) unchanged
        private _encGear = [_gear] call DB_fnc_mresArray;
        [format ["UPDATE players SET civ_gear='%1', new_drachma = new_drachma + %2 WHERE playerid='%3'", _encGear, _coins, _uid], 2] call DB_fnc_asyncQuery;
        private _reSel = [format ["SELECT QUOTE(new_drachma) FROM players WHERE playerid='%1'", _uid], 2] call DB_fnc_asyncQuery;
        if (_reSel isEqualType [] && {(_reSel param [0, ""]) isEqualType ""} && {(_reSel select 0) isNotEqualTo ""}) then { _ndBal = _reSel select 0; };
        diag_log format ["[LooneyBin][ND] login coin-sweep: %1 loonycoin -> +%1 ND for %2 (new bal %3)", _coins, _uid, _ndBal];
        [[_coins], "life_fnc_ndCoinSwept", _client, false] spawn life_fnc_MP;   // client toast only (balance already in the load payload)
    };};
private _talents= [_p select 4] call _dec;
private _exp    = (_p select 5) call _num;
private _prest  = (_p select 6) call _num;   // LooneyBin: cop prestige is a NUMBER (numberSafe on save, fn_updatePartial case 16) -> parseNumber. Was _dec (array decoder) -> ran mresToArray/compile on a bare number -> life_prestige never loaded from DB.
private _infExp = (_p select 7) call _num;
private _infTal = [_p select 8] call _dec;
private _arr    = [_p select 9] call _dec;
private _crimes = [_p select 10] call _dec;
private _pos    = [_p select 11] call _dec;
// LooneyBin: normalize saved position. The DB "no position" sentinel is "[[]]" which decodes to a
// value with count>2 (string/nested-array), NOT a real [x,y,z]. The client (fn_initCiv) does
// `if (count life_ses_last_pos > 2)` to decide returning-player teleport vs spawn-menu; a junk value
// passes that test, then `life_ses_last_pos distance [0,0,0]` throws (String/array-distance) -> the
// if aborts -> player is never positioned -> stuck dead at [0,0,0] (debug island). Force anything
// that isn't a 3-number position to [] so the client opens the spawn-selection menu instead.
// First UNWRAP a double-nested position: a save path stores `[[x,y,z]]` (array-in-array) instead of
// `[x,y,z]`, so without this the player always got the spawn menu instead of loading at last position.
if (_pos isEqualType [] && {count _pos isEqualTo 1} && {(_pos select 0) isEqualType []} && {count (_pos select 0) >= 3}) then { _pos = _pos select 0; };
if (!(_pos isEqualType []) || {count _pos < 3} || {!((_pos select 0) isEqualType 0)}) then { _pos = []; };
private _gov    = [_p select 12] call _dec;
private _qC     = [_p select 13] call _dec;
private _qP     = [_p select 14] call _dec;
private _title  = (_p select 15) call _num;
private _swat   = (_p select 16) call _num;
private _ff     = (_p select 17) call _num;
private _gangId = (_p select 18) call _num;
private _new    = (_p select 19) call _num;
private _prefix = _p select 20; if (isNil "_prefix" || {!(_prefix isEqualType "")}) then { _prefix = ""; };
private _gangRank = (_p select 21) call _num;
private _lic     = [_p select 22] call _dec;   // [[license_<side>_<name>, bool], ...]; applied client-side in fn_requestReceived
private _medPrest= (_p select 23) call _num;   // LooneyBin AFD prestige points  -> life_medic_exp
private _medTal  = [_p select 24] call _dec;   // LooneyBin AFD prestige talents -> life_medic_talents
private _preTal  = [_p select 25] call _dec;   // LooneyBin: cop PRESTIGE tree (life_cop_talents). OWN column, separate from cop_talents (= cop STANDARD tree -> life_side_talents, slot 9). NULL on the fresh column -> _dec passes through [] -> empty prestige unlocks (re-learnable; banked currency is intact in `prestige`).
private _casinoBan = (_p select 27) call _num;   // LooneyBin: casino self-exclusion flag (players.casino_banned) -> client var (slot 37) + server PLB_bjBanned enforcement cache
private _intakeP   = (_p select 28) call _num;
private _intakeS   = (_p select 29) call _num;   // Parole Papers arc progress (Act 2)   // owner 2026-07-11: THE INTAKE Act 1 (players.intake_path; 0 = pending -> fn_initCiv runs onboarding instead of the spawn menu)
private _isDet   = (_p select 26) call _num;   // owner 2026-06-19: undercover/detective WHITELIST (players.isdetective). Wired to cop slot 23 -> client life_isDetective. fn_initCop gates the cop_detective_* slots on this (pure whitelist, replaced the Sgt+ rank gate). Managed via officer_maggot !detective.

// LooneyBin TEST: auto-grant NEW players APD Chief (cop 7) + NG Marshal (medic 7) + Senior Admin (admin
// 4) while SRV_grantNewbieRoles is on. Applied on-load only (not written to the account).
// Use `max`, NOT a flat set: a flat set DEMOTED the owner from 5 -> 4. max only ever upgrades, so a real
// Owner (5) / Chief stays put while a fresh account (0) is raised to the grant floor.
if (_new isEqualTo 1) then {if (missionNamespace getVariable ["SRV_grantNewbieRoles", true]) then {_admin  = _admin max 4;
        _copLvl = _copLvl max 7;
        _medLvl = _medLvl max 7;
        // PERSIST so the roles STICK on every future login. GREATEST = upgrade-only, so it never demotes
        // a real Owner/Chief. Without this the grant was one-shot: new_player is cleared below, so the
        // player's NEXT login skipped the grant and fell back to admin 0 (exactly what hit player101).
        [format ["UPDATE players_global SET adminlevel=GREATEST(CAST(adminlevel AS SIGNED),4), coplevel=GREATEST(CAST(coplevel AS SIGNED),7), mediclevel=GREATEST(CAST(mediclevel AS SIGNED),7) WHERE playerid='%1'", _uid]] call DB_fnc_asyncQuery;
    };
    // new_player never gets cleared in this build, so it reads 1 for EVERY account on EVERY login -- the
    // "new players only" gate matched everyone (that's why the owner kept getting re-granted/demoted).
    // Clear it after the first load so the grant (and the new-player UI) only touch genuinely-new accounts.
    [format ["UPDATE players SET new_player='0' WHERE playerid='%1'", _uid]] call DB_fnc_asyncQuery;};

// --- sub-loads: vehicles (spawned objects owned by uid), houses, gang ---
private _vehObjs = vehicles select { !isNull _x && {((_x getVariable ["plb_dbInfo", ["", 0]]) param [0, ""]) isEqualTo _uid} };
private _houses = [];
// QUOTE(worldspace) keeps the position a STRING ("[x,y,z]"); raw, asyncQuery's call-compile turns it
// into an array -> CLinitHouses' parseSimpleArray (needs a string) errors -> owned houses never init.
private _hr = [format ["SELECT QUOTE(worldspace),id FROM houses WHERE owners='%1'", _uid], 2, true] call DB_fnc_asyncQuery;
if !(_hr isEqualTo []) then { _houses = _hr apply { [_x select 0, _x select 1] }; };
private _gangData = [];
if (_gangId > 0) then {
    // QUOTE the varchar/text cols (name, talents) or asyncQuery's call-compile dies on the bare gang
    // name -> _gr broken -> life_gang_data=[] -> gang vanishes on relog. COALESCE talents (NULL for a
    // fresh gang) to '[]'. Numeric cols (id, experience) arrive pre-typed -> no parseNumber.
    private _gq2 = format ["SELECT id,QUOTE(name),experience,QUOTE(COALESCE(talents,'[]')),QUOTE(COALESCE(house_pos,'[]')) FROM gangs WHERE id='%1'", _gangId];
    private _gr = [_gq2, 2] call DB_fnc_asyncQuery;
    // LooneyBin #59 (gang lost on restart/rejoin): if the player's gang0 points at a gang the SELECT
    // can't find (boot-rush contention or an orphaned id), the player silently loaded GANGLESS even
    // though their row was intact. Retry once, and if still empty log LOUDLY with both ids so the
    // write-side vs orphan-id fork (see BUGS.md #59) can be settled from the RPT.
    if (isNil "_gr" || {_gr isEqualTo []}) then {uiSleep 1;
        _gr = [_gq2, 2] call DB_fnc_asyncQuery;
        if (isNil "_gr" || {_gr isEqualTo []}) then {
            diag_log format ["[LooneyBin][GANG-ORPHAN] uid=%1 has gang0=%2 but no gangs row answered -- player will load gangless", _uid, _gangId];
        };};
    if (!isNil "_gr" && {!(_gr isEqualTo [])}) then {private _ghPos = parseSimpleArray format ["%1", _gr param [4, "[]"]];
        // owner 2026-06-16 (#305/#310): "no gang house" MUST load as [0,0,0], NOT []. Both consumers
        // (fn_setGangHouse + fn_initGang) test `select 3 isEqualTo [0,0,0]`; an empty [] from a NULL house_pos
        // is != [0,0,0], so it (a) falsely tripped the "You already have a gang house!" guard -> the leader
        // could never (re)set one, and (b) wouldn't init. Normalize empty/short to [0,0,0].
        if (!(_ghPos isEqualType []) || {count _ghPos < 3}) then { _ghPos = [0,0,0]; };
        // slot 3 = gang HOUSE position -> client fn_initGang locates the building + marker from it
        _gangData = [(_gr select 0), (_gr select 1), _gangRank, _ghPos, [(_gr select 2), [_gr select 3] call _dec], [0, 0, 0]];};};

// common head (load indices 0-14); 7 = dynamic vars (none), 10 = prefix (sent via setVariable elsewhere)
private _r = [_uid, _cash, _bank, _admin, _eventCoord, _donor, _gear, [], _exp, _talents, _prefix, _achv, _loot, _lootKeys, _stats];

switch (_side) do {case civilian: {_r set [15, _arr];
        _r set [16, _crimes];
        _r set [17, _pos];
        _r set [18, -1];
        _r set [19, _infExp];
        _r set [20, _infTal];
        _r set [21, _honorExp];
        _r set [22, _honorTal];
        _r set [23, _ndBal];
        _r set [24, _sub];
        _r set [25, _title];
        _r set [26, [_qC, _qP]];
        _r set [27, _houses];
        _r set [28, _gangData];
        _r set [29, _vehObjs];
        _r set [30, _gov];
        _r set [31, _new];};
    case west: {_r set [15, _copLvl];
        _r set [16, _prest];
        _r set [17, _preTal];   // life_cop_talents = PRESTIGE tree (pre_talents col). cop_talents already loaded the cop STANDARD tree into life_side_talents at slot 9. Splitting them stops the periodic-save clobber.
        _r set [18, _vehObjs];
        _r set [19, _sub];
        _r set [20, _swat];
        _r set [21, _title];
        _r set [22, [_qC, _qP]];
        _r set [23, _isDet];   // owner 2026-06-19: cop slot 23 (was -1 placeholder) -> life_isDetective (undercover whitelist)
        _r set [24, _copRet];};
    case independent: {_r set [15, _medLvl];
        _r set [16, _vehObjs];
        _r set [17, _sub];
        _r set [18, _title];
        _r set [19, [_qC, _qP]];
        _r set [20, -1];
        _r set [21, _ff];
        _r set [33, _medPrest];   // LooneyBin: AFD prestige (medic-only wire slots 33/34)
        _r set [34, _medTal];};};

_r set [32, _lic];   // side licenses (index 32 is unused by every side); fn_requestReceived applies them
_r set [35, _beta];  // betatester whitelist flag (all sides; 33/34 are medic-only) -> PLB_betaTester
_r set [36, _ltStats];   // singleevh.md Phase 3a.2: 148-slot lifetime_stats -> client PLB_stats_live. Index 36 = first free slot AFTER the side switch (which OWNS index 15: civ=arrested / cop=coplevel / med=mediclevel).
_r set [37, _casinoBan];  // LooneyBin: casino self-exclusion flag -> client sets plb_casinoBanned (phone/app gate). All-sides shared slot.
_r set [38, _intakeP];   // owner 2026-07-11: THE INTAKE path (0 pending / 1-3 / 9 skipped) -- all-sides shared slot (32 = licenses, 33/34 = medic-only)
_r set [39, _intakeS];   // PAROLE PAPERS step (0-4 active / 255 done)
// server-authoritative enforcement cache (blackJackSRV rejects deals when banned; a tampered client cannot un-ban itself here).
if (isNil "PLB_bjBanned") then { PLB_bjBanned = createHashMap };
PLB_bjBanned set [_uid, _casinoBan isEqualTo 1];
// owner 2026-07-11 (onboarding Phase 2): NEW BLOOD -- under 5h total civ playtime (stats slot 11, minutes)
// = visibly tagged (fn_playerTags cyan [NEW BLOOD]) + kill-log protected (-NEWBLOOD-). Also seed the
// onboarding DIRECTOR's stuck-tracker with the arc state loaded above.
private _civMin = parseNumber format ["%1", _stats param [11, 0]];
_player setVariable ["plb_newBlood", (_side isEqualTo civilian) && {_civMin < 300}, true];
if (isNil "PLB_onboardTrack") then { PLB_onboardTrack = createHashMap; };
if (_intakeP in [1, 2, 3] && {_intakeS <= 5}) then {PLB_onboardTrack set [_uid, [_intakeS, diag_tickTime]];} else {
    PLB_onboardTrack deleteAt _uid;};
// TALENT BRIDGE (talent-overhaul infra): stash the player's STANDARD side-talent array (index 9 = _talents,
// the DB-authoritative civ/cop/med tree) on the unit server-side so server effect code can gate on it
// (`_u getVariable ["plb_talents", []]`). This is the copy the server itself read from the DB -- NOT client-
// asserted. Refreshed live on respec/learn in DB_fnc_updatePartial case 4. Server-local (false); dies with the
// unit on disconnect. NOTE for money-affecting perks: the talent SYSTEM is already client-authoritative (client
// picks -> saves to DB -> server reads back), so a payout gated on this trusts the same boundary as any talent;
// pair high-value payouts with a sanity cap / CLANKR rule.
_player setVariable ["plb_talents", _talents, false];
// CYBERDECK MODULES (permanent shop unlocks -- id array). DB-authoritative, broadcast (public) so both the SERVER
// (ATM cooldown / payout gates) and the CLIENT (breach-timer / wardrive gates) read the same owned list. 2026-07-20.
private _cdMods = parseSimpleArray (_p param [30, "[]"]);
if (isNil "_cdMods") then { _cdMods = [] };
_player setVariable ["plb_cdMods", _cdMods, true];
_r remoteExec ["life_fnc_requestReceived", _client];
// owner 2026-07-11 (Mentor Program): pending offline-payout notifications -> push once the client is
// actually in-world (the login screen eats immediate toasts), then clear. Scheduled, non-blocking.
[_uid, _client] spawn {params ["_uid", "_client"];
    private _rows = [format ["SELECT id, QUOTE(COALESCE(msg,'')) FROM mentor_notify WHERE uid='%1'", _uid], 2, true] call DB_fnc_asyncQuery;
    if (isNil "_rows" || {!(_rows isEqualType [])} || {_rows isEqualTo []}) exitWith {};
    uiSleep 30; {_x params [["_id", 0], ["_msg", ""]];
        [["notify", format ["%1", _msg]], "life_fnc_mentor", _client] call life_fnc_MP;
        [format ["DELETE FROM mentor_notify WHERE id=%1", parseNumber format ["%1", _id]]] call DB_fnc_asyncQuery;} forEach _rows;};

// owner 2026-06-27 ("gangs can't accept wars / make it persist"): the gang-war reload lived in the DEAD
// system/fn_query (the 2020 client never calls it), so life_gang_wars was never restored on login/restart.
// Load this gang's active wars from the PERSISTENT `wars` table here in the real login path and push them to
// the client. fn_updateWar writes the table on accept/surrender; this is the read-back that makes it stick.
if (_gangId > 0) then {
    private _warRows = [format ["SELECT gang1,gang2 FROM wars WHERE gang1 = '%1' OR gang2 = '%1'", _gangId], 2, true] call DB_fnc_asyncQuery;
    private _wars = []; {
        private _enemy = if (_gangId isEqualTo (parseNumber str (_x select 0))) then { parseNumber str (_x select 1) } else { parseNumber str (_x select 0) };
        if (_enemy > 0 && {!(_enemy in _wars)}) then { _wars pushBack _enemy; };} forEach _warRows;
    [["life_gang_wars", _wars], "life_fnc_netSetVar", _client, false, false] spawn life_fnc_MP;};

// owner 2026-06-13: RESTART TALLY -- when the OWNER connects, DM them how many auto-restarts have landed
// in the watch window (server_control.watch_start..watch_until, set to "until 10am tomorrow"). restart_log is
// written by the auto-restart scheduler. Owner-only (targeted to _client), fired after the load push.
if (_uid isEqualTo "76561190000000001") then {[_uid, _client] spawn {params ["_uid", "_client"];
        uiSleep 14;   // let the client finish loading before the box pops
        private _q = "SELECT COUNT(*), QUOTE(DATE_FORMAT((SELECT watch_start FROM server_control WHERE id=1),'%b %e %H:%i')), QUOTE(DATE_FORMAT((SELECT watch_until FROM server_control WHERE id=1),'%b %e %H:%i')) FROM restart_log WHERE ts >= (SELECT watch_start FROM server_control WHERE id=1) AND ts <= (SELECT watch_until FROM server_control WHERE id=1)";
        private _r = [_q, 2] call DB_fnc_asyncQuery;
        if (_r isEqualType [] && {count _r > 0}) then {(_r select 0) params [["_n", 0], ["_start", ""], ["_until", ""]];
            private _msg = format ["Restart watch: %1 restart(s) since %2. Counting until %3 (10am).", _n, _start, _until];
            [[5, "RESTART WATCH", _msg, objNull], "life_fnc_clientMessage", _client, false, false] spawn life_fnc_MP;};};};

// --- LooneyBin daily login bonus: streak compute + push (backend for TON_fnc_loginBonusSRV) ---
// players.lb_days = consecutive days, lb_claimed = today's gift taken, lb_last = last counted day.
// COALESCE(DATEDIFF...,-1): NULL lb_last (never logged in) -> -1 -> treated as a fresh streak.
// diff 0 = already counted today (gift available unless claimed); 1 = consecutive -> streak+1;
// anything else = streak broken -> reset to day 1. Push via netSetVar (approved var, server-origin).
private _lb = [format ["SELECT lb_days, lb_claimed, COALESCE(DATEDIFF(CURDATE(), lb_last), -1) FROM players WHERE playerid='%1'", _uid], 2] call DB_fnc_asyncQuery;
if (_lb isEqualType [] && {count _lb >= 3}) then {private _days    = (_lb select 0) call _num;
    private _claimed = ((_lb select 1) call _num) isEqualTo 1;
    private _diff    = (_lb select 2) call _num;
    private _needsGift = false;
    switch (true) do {case (_diff isEqualTo 0): { _needsGift = !_claimed; };                       // same day: gift if unclaimed
        case (_diff isEqualTo 1): { _days = _days + 1; _needsGift = true;            // consecutive day: streak up
            [format ["UPDATE players SET lb_days='%2', lb_claimed='0', lb_last=CURDATE() WHERE playerid='%1'", _uid, _days]] call DB_fnc_asyncQuery; };
        default                   { _days = 1; _needsGift = true;                    // gap / first login: reset
            [format ["UPDATE players SET lb_days='1', lb_claimed='0', lb_last=CURDATE() WHERE playerid='%1'", _uid]] call DB_fnc_asyncQuery; };
    };
    [["life_loginBonusData", [_uid, _days, _needsGift, false]], "life_fnc_netSetVar", _client, false, false] spawn life_fnc_MP;};

// --- LooneyBin revive-drone battery persistence (medics only): push [revives, support, remainingSecs] ---
if (_side isEqualTo independent) then {
    private _dr = [format ["SELECT drone_revives, drone_support, GREATEST(drone_recharge_until - UNIX_TIMESTAMP(), 0) FROM players WHERE playerid='%1'", _uid], 2] call DB_fnc_asyncQuery;
    if (_dr isEqualType [] && {count _dr >= 3}) then {
        [["life_droneState", [(_dr select 0) call _num, (_dr select 1) call _num, (_dr select 2) call _num]], "life_fnc_netSetVar", _client, false, false] spawn life_fnc_MP;
    };};

diag_log format ["[LooneyBin][PERF] queryRequest for %1 took %2 ms (side %3)", _uid, round ((diag_tickTime - _plb_t0) * 1000), _side];   // [PERF step 1] baseline metric -- watch under load
["-CONNECT-", _player, format ["loaded in %1 ms, side %2, cash %3, bank %4", round ((diag_tickTime - _plb_t0) * 1000), _side, _cash, _bank]] call PLB_fnc_logIt;
