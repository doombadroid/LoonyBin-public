/*
    TON_fnc_wantedRemove  (LooneyBin: clear a player's wanted level) -- runs on the SERVER.
    Callers (all pass [_uid]): fn_ticketPay, fn_jailMe (on release), fn_turnedIn, gov pardon. Each of those
    already clears the offender's own A_stats_crimes/plb_wantedAmt locally (life_fnc_wantedListAdd 999) before
    calling here, so this just clears SERVER state: the old passthrough only DELETEd the DB row, leaving the
    offender in life_wanted_list (lingering in the cop Wanted menu) and in life_restrained_players (the
    combat-log re-jail tracker, set by TON_fnc_setJail and read by fn_query on reconnect).
*/
params [["_uid", "", [""]]];
// owner 2026-06-23 SECURITY (security.md §2.2/§2.3): self-only. EVERY legit caller (fn_jailMe on release,
// fn_turnedIn, fn_ticketPay, gov electricChair) passes its OWN getPlayerUID player. Ungated, any civ could
// remoteExec [anyUID] to wipe another player's wanted level, and the raw _uid flowed into the DELETE (SQLi).
// Require subject UID == the real caller's UID (remoteExecutedOwner, non-spoofable); server-internal passes.
// SQL-escape _uid before the DELETE below.
private _src = remoteExecutedOwner;
private _caller = if (_src isEqualTo 0) then { objNull } else { (allPlayers select { owner _x isEqualTo _src }) param [0, objNull] };
private _callerUID = getPlayerUID _caller;
private _san = { (format ["%1", _this]) splitString "\'""" joinString "" };
_uid = _uid call _san;
if (_uid isEqualTo "") exitWith {};
if (_src isNotEqualTo 0 && {_uid isNotEqualTo _callerUID}) exitWith { ["-SEC-", _caller, format ["BLOCKED wantedRemove by %1 on %2", _callerUID, _uid]] call PLB_fnc_logIt; };
if (isNil "life_wanted_list") then { life_wanted_list = []; };
private _i = life_wanted_list findIf { (_x param [1, ""]) isEqualTo _uid };
if (_i != -1) then { life_wanted_list deleteAt _i; };
life_restrained_players = life_restrained_players - [_uid];
[format ["DELETE FROM `%1` WHERE `playerid`='%2'", srv_table_wanted, _uid]] call DB_fnc_asyncQuery;
