/*
    DB_fnc_updateRequest  (LooneyBin: 2020 full save)
    client fn_ClupdateRequest -> [player, name, side, cash, atmcash, side_talents, side_exp, (civ)pos]
    Core periodic/disconnect save. Per-field state goes via DB_fnc_updatePartial.
*/
params [["_player",objNull,[objNull]],["_name","",[""]],["_side",civilian,[civilian]],["_cash",0,[0]],["_bank",0,[0]],["_talents",[],[[]]],["_exp",0,[0]]];
if (isNull _player) exitWith {};
private _uid = getPlayerUID _player;
if (_uid == "") exitWith {};
// owner 2026-06-21 (Vista money-wipe, root cause): the client packet's cash/bank arrive as nil/`any` when
// fn_ClupdateRequest fires BEFORE the session loads life_cash/life_atmcash -- life_session_completed goes
// stale-TRUE across sessions, so at reconnect it ran at connect-time. `params` above then SILENTLY defaults a
// nil cash/bank to 0, and this UPDATE wrote bankacc=0 over the real balance a split-second before the login
// query read it back (Vista 423,432 -> 0). When the money is non-numeric, EVERY field of this packet is a
// default/stale placeholder (talents=[], exp=0, ...), not just money -- so persisting ANY of it is corruption.
// Abort the whole save. The real periodic save fires again once the session is actually loaded.
if ((count _this < 5) || {isNil {_this select 3}} || {isNil {_this select 4}}
        || {!((_this select 3) isEqualType 0)} || {!((_this select 4) isEqualType 0)}) exitWith {
    ["-MONEYGUARD-", _uid, "blocked a nil/uninitialised full-save at connect (would have zeroed bank + wiped talents/exp)"] call PLB_fnc_logIt;
};
private _sideFlag = switch (_side) do { case west:{"cop"}; case independent:{"med"}; default {"civ"} };
// owner 2026-06-23 SECURITY (security.md §2.3): KRON_Replace is mission-only -> UNDEFINED on the dedicated
// server, so these calls threw / nil-corrupted the name and it reached the UPDATE unescaped. Replace with the
// in-repo _san strip. (_uid is getPlayerUID _player above = server-derived, digits-only -- not client-spoofable.)
private _san = { (format ["%1", _this]) splitString "\'""" joinString "" };
_name = _name call _san;

private _set = format ["name='%1', cash='%2', bankacc='%3', %4_talents='%5', %4_exp='%6'",
    _name, _cash call DB_fnc_numberSafe, _bank call DB_fnc_numberSafe,
    _sideFlag, [_talents] call DB_fnc_mresArray, _exp call DB_fnc_numberSafe];

if (_side isEqualTo civilian && count _this > 7) then {_set = _set + format [", position='%1'", [_this select 7] call DB_fnc_mresArray];};

[format ["UPDATE players SET %1 WHERE playerid='%2'", _set, _uid]] call DB_fnc_asyncQuery;
