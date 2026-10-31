 
private["_query","_result","_ret","_pageNo"]; 
 
_pageNo = [_this,0,0,[0]] call BIS_fnc_param; 
 
// QUOTE the varchar cols or asyncQuery's call-compile mangles them: the 17-digit `owners` UID
// compiles to a float (precision-lost -> wrong uid) and `worldspace` becomes an array (receiveHouses
// does `call compile (_x select 2)` which then errors). QUOTE keeps all three as strings.
_query = format["SELECT QUOTE(`oid`),QUOTE(`owners`),QUOTE(`worldspace`),`locked`,`id`,`vcap`,`phys_cap`,`keycap`,`barrel`,`greenhouse`,`leadcontainer`,`keyholders`,`vinv`,`pinv`,QUOTE(COALESCE(`custom_name`,'')) FROM `houses` ORDER BY `oid` LIMIT %1,30", (_pageNo * 30),life_server_instance];
_ret = [_query,2,true] call DB_fnc_asyncQuery; 
 
_ret;