 
private["_query","_sql"]; 
 
if (life_server_training) exitWith {}; 
 
 {if (!isNil "_x") then {_contents = 0;
if (!isNil "life_capture_containers select _forEachIndex") then {
_contents = ((life_capture_containers select _forEachIndex) getVariable "gangContainer") select 1;};
// owner 2026-06-13: REPLACE not UPDATE -- the captures table started EMPTY (no id 1-4 rows), so the old
// UPDATE matched nothing and cartel ownership NEVER persisted (reset to neutral every reboot). REPLACE
// self-seeds the row by its primary key, so capture state now saves + reloads across restarts.
_query = format["REPLACE INTO `captures` (`id`,`gang`,`percent`,`container`,`level`) VALUES ('%3','%1','%2','%4','%5')", (_x select 1), ((_x select 2) * 100), _forEachIndex + 1, _contents, (_x select 6)];
[_query] call DB_fnc_asyncQuery;};} foreach life_capture_changed;
 
life_capture_changed = [];