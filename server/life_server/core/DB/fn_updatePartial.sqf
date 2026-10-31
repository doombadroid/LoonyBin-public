/*
    DB_fnc_updatePartial  (LooneyBin: 2020 per-slot save)
    client fn_ClupdatePartial -> [player, side, uid, mode, ...data]
    mode -> column map mirrors core/session/fn_ClupdatePartial.sqf. Arrays are
    backtick-encoded (DB_fnc_mresArray); numbers stored raw; quest strings stored flat.
*/
params [["_player",objNull,[objNull]],["_side",civilian,[civilian]],["_uid","",[""]],["_mode",-1,[0]]];
if (_uid == "" || _mode < 0) exitWith {};
// owner 2026-06-23 SECURITY (security.md §2.3 — SQLi): the client _uid is interpolated into EVERY partial-save
// WHERE playerid clause (and DB_fnc_asyncQuery is unparameterized), so a crafted _uid (e.g. ' OR '1'='1)
// rewrote every player's row. Escape it once here. Cases 20 (quest arrays) and 24 (firefighter flag) also
// interpolated their client values (_d/_e) RAW -- those are sanitized inline below.
private _san = { (format ["%1", _this]) splitString "\'""" joinString "" };
_uid = _uid call _san;
// LooneyBin: DB_fnc_mresArray already does `_this select 0`, and every caller below passes `[_d]`.
// The old `[_this]` here added a SECOND wrap -> every _enc field was stored double-nested
// (civ_gear='[[gear]]', position='[[x,y,z]]', ...). On load the 2020 client got `[gear]` instead of
// `gear` -> setUnitLoadout failed -> player spawned NAKED; position needed a load-unwrap; etc.
// Pass through so mresArray's own select-0 unwrap yields the single, correct value.
private _enc = { _this call DB_fnc_mresArray };            // [value] -> backtick string of value
private _d   = if (count _this > 4) then { _this select 4 } else { nil };
private _e   = if (count _this > 5) then { _this select 5 } else { nil };
// every mode below reads _d; a short/malformed client packet left it nil -> "Undefined variable _d"
// in the format call and the UPDATE ran with garbage. Drop the packet instead.
if (isNil "_d") exitWith {};
private _sideFlag = switch (_side) do { case west:{"cop"}; case independent:{"med"}; default {"civ"} };
private _qP = ""; private _qG = "";   // player / players_global UPDATE bodies

switch (_mode) do {case 0:  { _qP = format ["cash='%1'", _d call DB_fnc_numberSafe]; };
    case 1:  { _qP = format ["bankacc='%1'", _d call DB_fnc_numberSafe]; };
    case 2:  { _qP = format ["%2_licenses='%1'", [_d] call _enc, _sideFlag]; };
    case 3:  { _qP = format ["%2_gear='%1'", [_d] call _enc, _sideFlag]; };
    case 4:  { _qP = format ["%2_talents='%1', %2_exp='%3'", [_d] call _enc, _sideFlag, _e call DB_fnc_numberSafe];
               // TALENT BRIDGE: keep the server-side unit copy in sync with the standard-tree save (respec/learn)
               // so server payout/yield perks see the new build without a relog. Mirrors the login stash in
               // DB_fnc_queryRequest. _d = the array just persisted for this side; _player = the caller's unit.
               if (!isNull _player) then { _player setVariable ["plb_talents", _d, false]; }; };
    case 5:  { _qP = format ["arrested='%1'", [_d] call _enc]; };
    case 6:  { _qP = format ["cash='%1', bankacc='%2'", _d call DB_fnc_numberSafe, _e call DB_fnc_numberSafe]; };
    case 7:  { _qG = format ["achievements='%1'", [_d] call _enc]; };
    case 8:  { _qP = format ["crimes='%1'", [_d] call _enc]; };
    case 9:  { _qG = format ["stats='%1'", [_d] call _enc]; };
    case 10: { _qP = format ["position='%1'", [_d] call _enc]; };
    case 11: { _qP = format ["civ_gear='%1'", [_d] call _enc]; };   // LooneyBin #63: death-gear reset (civ/cop/med). Client pushes the side-default life_gear on death; without these cases the DB kept pre-death gear -> combat-log dupe.
    case 12: { _qP = format ["cop_gear='%1'", [_d] call _enc]; };
    case 13: { _qP = format ["med_gear='%1'", [_d] call _enc]; };
    case 14: { _qG = format ["honor_exp='%1', honor_talents='%2'", _d call DB_fnc_numberSafe, [_e] call _enc]; };
    case 15: { _qP = format ["prefix='%1'", (format ["%1", _d]) splitString "\'""`" joinString ""]; };   // LooneyBin: prefix is PLAYER TEXT -- stored raw, an exotic value (quotes/spaces, e.g. "The Eminent %1") broke the load-row compile and bricked that account's connect
    case 16: { _qP = format ["prestige='%1', pre_talents='%2'", _d call DB_fnc_numberSafe, [_e] call _enc]; };   // LooneyBin: cop prestige TREE -> its OWN pre_talents column. Was cop_talents, but cop_talents ALSO holds the cop STANDARD talent tree (life_side_talents, talentCfg west IDs 73-129), which fn_updateRequest rewrites EVERY periodic save -> the prestige unlocks (life_cop_talents, prestigeCfg cop IDs 1-41) got clobbered each sync = "prestige doesn't persist on cop". Medic dodged this (medic_talents != med_talents). prestige currency is a NUMBER (numberSafe); talents array via _enc.
    case 17: { _qP = format ["cop_gear='%1'", [_d] call _enc]; };
    case 18: {   // LooneyBin 2026-07-23 NEW DRACHMA: new_drachma is SERVER-authoritative now (TON_fnc_ndSRV owns
        // every write -- exact DECIMAL(20,4) ledger). A client still sending partial-18 is either a stale
        // mission PBO or a tamper attempt; either way it must never touch the ledger. _qP stays "" -> no query.
        diag_log format ["[LooneyBin][ND][TAMPER] partial-18 new_drachma write IGNORED from %1 (value %2)", _uid, _d];};
    case 19: { _qP = format ["title='%1'", _d call DB_fnc_numberSafe]; };
    case 20: { _qP = format ["completed_quests='%1', progress_quests='%2'", (format ["%1", _d]) splitString "\'""`" joinString "", (format ["%1", _e]) splitString "\'""`" joinString ""]; };   // quest arrays of numbers -- strip quotes/backtick as a SQL guard (lossless for numeric arrays)
    case 21: { _qP = format ["gov_data='%1'", [_d] call _enc]; };
    case 22: { _qP = format ["infamy_exp='%1', infamy_talents='%2'", _d call DB_fnc_numberSafe, [_e] call _enc]; };
    case 23: { _qP = format ["medic_prestige='%1', medic_talents='%2'", _d call DB_fnc_numberSafe, [_e] call _enc]; };   // LooneyBin AFD prestige
    case 24: { _qP = format ["isfirefighter='%1'", _d call DB_fnc_numberSafe]; };   // LooneyBin: firefighter registration persistence (1/0) -- coerce numeric (SQL guard)
    default  { };};

if (_qP != "") then { [format ["UPDATE players SET %1 WHERE playerid='%2'", _qP, _uid]] call DB_fnc_asyncQuery; };
if (_qG != "") then { [format ["UPDATE players_global SET %1 WHERE playerid='%2'", _qG, _uid]] call DB_fnc_asyncQuery; };
