 
private["_query","_result","_ret","_pageNo"]; 
 
_pageNo = [_this,0,0,[0]] call BIS_fnc_param; 
 
_query = format["SELECT DISTINCT `id`,QUOTE(`name`),QUOTE(COALESCE(`wars`,'')),`inviterank`,`kickrank`,`bank`, (SELECT COUNT(*) FROM `%3` WHERE `gang0`=`gangs`.`id`) as `members`,`experience`,QUOTE(COALESCE(`talents`,'[]')) FROM `gangs` ORDER BY `id` LIMIT %1,50", (_pageNo * 50), life_server_instance, srv_table_players];   // LooneyBin: QUOTE the string columns (name/wars/talents) -- unquoted names with spaces broke call-compile of the result -> empty gang cache (every gang system failed).
diag_log format["SQL Query: %1", _query]; 
_ret = [_query,2,true] call DB_fnc_asyncQuery; 
 
_ret;