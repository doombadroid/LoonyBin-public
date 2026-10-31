 
private["_query","_sql"]; 
 
if (life_server_training) exitWith {}; 
 {if (!isNil "_x") then {
// owner 2026-06-13: REPLACE not UPDATE -- the turf table started EMPTY, so UPDATE matched nothing and turf
// ownership NEVER persisted (reset every reboot, same bug as captures). REPLACE self-seeds the row by id.
_query = format["REPLACE INTO `turf` (`id`,`gang`) VALUES ('%2','%1')", (_x select 1), _forEachIndex + 1];
[_query] call DB_fnc_asyncQuery;};} foreach life_turf_list;