 
if (life_server_training) exitWith {}; 
private["_id","_query","_sql"]; 
_id = [_this,0,"",[""]] call BIS_fnc_param; 
 
_query = format["DELETE FROM gangs WHERE `id`='%1' LIMIT 1",_id]; 
[_query] call DB_fnc_asyncQuery; 
 
_query = format["UPDATE %3 SET gang0='0', gangrank0='3' WHERE gang0='%1'",_id, life_server_instance, srv_table_players]; 
[_query] call DB_fnc_asyncQuery;