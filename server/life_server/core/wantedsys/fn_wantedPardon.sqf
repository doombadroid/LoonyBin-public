/*
    TON_fnc_wantedPardon  (LooneyBin: pardon a player, clearing all their charges) -- runs on the SERVER.
    Caller: fn_pardon (cop/governor Wanted-menu Pardon button), passes [_uid].
    The old version dropped the life_wanted_list entry but "cleared" the wanted level via the dead `life_wanted`
    var + publicVariableClient to (_x getVariable "ownerID") -- 2020 units never set ownerID, so it published
    to -1 (dropped) and the offender stayed wanted on their own HUD. Clear it on the offender's client through
    life_fnc_wantedListAdd 999 (zeroes A_stats_crimes + republishes plb_wantedAmt), drop the cop-menu and
    combat-log entries, lift any active bounty, and wipe the DB row.
*/
params [["_uid", "", [""]]];
// owner 2026-06-23 SECURITY (security.md §2.2/§2.3): two legit callers -- fn_pardon (a COP pardoning someone:
// side==west) and fn_govPardon (the player BEING pardoned triggers it themselves after the governor approved:
// _uid == own UID, caller is civilian). Ungated, any civ could remoteExec [anyUID] to clear any wanted level,
// AND the raw _uid flowed into `DELETE FROM wanted WHERE playerid='_uid'` -> `' OR '1'='1` wipes the whole
// table. Derive the real caller (remoteExecutedOwner, non-spoofable); allow cop OR self-pardon OR server-
// internal; SQL-escape _uid before the DELETE below.
// NEEDS OWNER REVIEW: self-pardon is permitted so the governor flow works, but the server can't verify the gov
// actually approved -- a scripter could clear their OWN wanted level without a real pardon. To fully close,
// have the server issue a one-shot gov-pardon token (SRV var) and require it here for the self path.
private _src = remoteExecutedOwner;
private _caller = if (_src isEqualTo 0) then { objNull } else { (allPlayers select { owner _x isEqualTo _src }) param [0, objNull] };
private _callerUID = getPlayerUID _caller;
private _san = { (format ["%1", _this]) splitString "\'""" joinString "" };
_uid = _uid call _san;
if (_uid isEqualTo "") exitWith {};
if (_src isNotEqualTo 0 && {!(side _caller isEqualTo west)} && {_uid isNotEqualTo _callerUID}) exitWith { ["-SEC-", _caller, format ["BLOCKED wantedPardon by %1 on %2", _callerUID, _uid]] call PLB_fnc_logIt; };
if (isNil "life_wanted_list") then { life_wanted_list = []; };

private _i = life_wanted_list findIf { (_x param [1, ""]) isEqualTo _uid };
if (_i != -1) then { life_wanted_list deleteAt _i; };
life_restrained_players = life_restrained_players - [_uid];

private _unit = allPlayers param [allPlayers findIf { (getPlayerUID _x) isEqualTo _uid }, objNull];
if (!isNull _unit) then {[[999, _uid], "life_fnc_wantedListAdd", _unit, false, false] spawn life_fnc_MP;
    if (_unit getVariable ["paroleViolated", false]) then {_unit setVariable ["parole", nil, true];
        _unit setVariable ["paroleViolated", nil, true];};};

[[_uid], "life_fnc_removeBounty", true, false] spawn life_fnc_MP;
[format ["DELETE FROM `%1` WHERE `playerid`='%2'", srv_table_wanted, _uid]] call DB_fnc_asyncQuery;
