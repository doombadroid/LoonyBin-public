// extDB3 (LooneyBin): elect new governor from vote tally
private ["_query","_candidate","_currentTimeStr","_currentTime","_row"];

_row = ["SELECT UNIX_TIMESTAMP()",2] call DB_fnc_asyncQuery;
_currentTimeStr = format ["%1", _row select 0];
_currentTime = parseNumber _currentTimeStr;

// LooneyBin: extDB3 auto-types numeric text -> config slot may already be a NUMBER; parseNumber on a
// number THROWS and (called from init.sqf line 72) aborted the whole server init. format-coerce.
if (_currentTime - (parseNumber format ["%1", life_configuration select 1]) < 432000) exitWith { diag_log "Not yet time for a new governor." };

_query = format["SELECT COUNT(*) as `count`, `votes`.`candidate`, `%2`.`name` FROM `votes`,`%2` WHERE `%2`.`playerid` != '%1' AND `votes`.`candidate`=`%2`.`playerid` GROUP BY `votes`.`candidate` ORDER BY `count` DESC LIMIT 1", life_configuration select 0, srv_table_players];
_candidate = [_query,2] call DB_fnc_asyncQuery;
if (_candidate isEqualTo []) exitWith { diag_log "No candidates found for the new office!" };
if (count _candidate < 1) exitWith {};

life_configuration set [4, life_configuration select 0];
life_configuration set [0, _candidate select 1];
life_configuration set [1, _currentTimeStr];

publicVariable "life_configuration";
[] spawn DB_fnc_updateConfig;

["DELETE FROM `candidates`"] call DB_fnc_asyncQuery;
["DELETE FROM `votes`"] call DB_fnc_asyncQuery;

diag_log format["The new governor has been set to %1!", _candidate select 2];
// owner 2026-06-13: pass the name INTO the spawn -- a spawned scope doesn't inherit parent locals, so the
// old `[] spawn { ... _candidate select 2 ... }` threw "Undefined variable _candidate" 300s later.
[_candidate select 2] spawn { params ["_govName"]; sleep 300; [[[0,2], format["A new governor, %1, has been elected into office!", _govName]], "life_fnc_broadcast", nil, false] spawn life_fnc_MP; };
