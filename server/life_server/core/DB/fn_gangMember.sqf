 
private["_uid","_gang","_rank"]; 
if (life_server_training) exitWith {}; 
_uid = [_this,0,"0",["0"]] call BIS_fnc_param; 
_gang = [_this,1,"0",["0"]] call BIS_fnc_param; 
_rank = [_this,2,3,[3]] call BIS_fnc_param; 
 
if (_rank < 0) exitWith {}; 
 
 
_query = format["UPDATE `%5` SET gang0='%2',gangrank0='%3' WHERE playerid='%1'",_uid,_gang,_rank,life_server_instance,srv_table_players]; 
[_query] call DB_fnc_asyncQuery;