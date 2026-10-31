 
private["_uid","_unit","_side","_ret","_ownerID","_guid","_instance","_timeDiff","_adminLevel","_i","_exit"]; 
_unit = [_this,0,ObjNull,[Objnull]] call BIS_fnc_param; 
_side = [_this,1,civilian,[sideUnknown]] call BIS_fnc_param; 
_uid = [_this,2,"",[""]] call BIS_fnc_param; 
 
if (!isServer) then {[_unit,"PLB_fnc_setOwnerID",false,false] spawn BIS_fnc_MP;
waitUntil {_unit getVariable ["ownerID",-1] != -1};}
else {_unit call PLB_fnc_setOwnerID;};
 
if(isNull _unit OR _uid == "") exitWith {if(!isNull _unit) then {
["Either your player was null or your PlayerID sent was invalid. Try re-logging in.","life_fnc_sessionReceive",_unit,false] spawn life_fnc_MP; 
};};
_exit = false; {if ((_x select 0) == _uid && (_x select 1) != _side) exitWith {if (time - (_x select 2) < 360 && time > 300) then
{ _exit = true; };};} forEach life_disconnects;
_exitnow = false; 
if (_exit) then {_admin = [_uid] call PLB_fnc_getAdmin;
if(_admin < 1) exitWith {
["You've recently played on another side (civilian or cop) and cannot switch so soon. Return to lobby.","life_fnc_sessionReceive",_unit,false] spawn life_fnc_MP; 
_exitnow = true;};};
if(_exitnow) exitWith {}; 
_ownerID = owner _unit; 
 
_i = count life_connected; 
{ if (_x select 0 == _uid) then { _i = _forEachIndex } } forEach life_connected; 
life_connected set [_i, [_uid, _side, time]]; 
 
_unit removeAllMPEventHandlers "MPKilled";  
_unit addMPEventHandler ["MPKilled", { if (!X_Server) exitWith {}; [getPlayerUID (_this select 1), false] call DB_fnc_setDeadState; }]; 
 
_ret = [_uid,_side,_unit] call DB_fnc_query; 
waitUntil {typeName _ret == "ARRAY" OR typeName _ret == "STRING" OR isNil "_ret"}; 
 
if(!isNil "_ret") then {if (count _ret > 0) then {_instance = 1;
_timeDiff = 10000; 
_adminLevel = 0; 
 
switch (_side) do {case west: {if ((count _ret) > 0) then {
 
_adminLevel = _ret select 7; 
_precinct = _ret select 21; 
_ret set [21, (worldName != "Altis" || life_server_instance == _precinct)];};};
case civilian: {
 
_adminLevel = _ret select 6; 
 
if ((_ret select 19) != "0") then {_gangRow = [];
{ if ((_ret select 19) == (_x select 0)) then { _gangRow = _x; }; } foreach life_server_gangs; 
if (count _gangRow > 0) then { [[(_ret select 19), (_ret select 20), _gangRow select 1, false],"life_fnc_addToGang",_unit,false] spawn life_fnc_MP; }; 
};};
case sideLogic: {_instance = 1;
_timeDiff = 22222; 
_adminLevel = _ret select 2;};};
 
[_ret,"life_fnc_sessionReceive",_unit,false] spawn life_fnc_MP; 
 
if (_side == civilian) then {if (count (_ret select 11) > 0) then {
 
_page = 0; 
while {true} do {_ret2 = [_page,(_ret select 11)] call DB_fnc_queryStorage;
_page = _page + 1; 
waitUntil {typeName _ret2 == "ARRAY" OR typeName _ret2 == "STRING" OR isNil "_ret"}; 
 {_houseId = parseNumber(_x select 0);
_houseWorldspace = [(_x select 1)] call DB_fnc_mresToArray; 
_houseWorldspace = parseSimpleArray (format["%1", _houseWorldspace]); 
if (({_houseWorldspace distance (getMarkerPos format["capture_area_%1",_x]) < 200 } count [1,2,3,4]) == 0) then {
_building = _houseWorldspace nearestObject "House_F"; 
_worldspace = [(_x select 2)] call DB_fnc_mresToArray; 
_worldspace = parseSimpleArray (format["%1", _worldspace]); 
 
_contents = [(_x select 5)] call DB_fnc_mresToArray; 
_contents = parseSimpleArray (format["%1", _contents]); 
_virtual = [(_x select 7)] call DB_fnc_mresToArray; 
_virtual = parseSimpleArray (format["%1", _virtual]); 
[(_x select 4), _worldspace, parseNumber(_x select 3), _building, _contents, _virtual, getPlayerUID _unit, ((_x select 0) == (_ret select 19)), parseNumber (_x select 6), _x select 0] spawn PLB_fnc_addStorage; 
};} foreach (_ret2);
 
if ((count _ret2) < 2) exitWith {};};
// owner 2026-06-17 (#325): REMOVED the 5s-delayed life_scanned_houses marking. It raced the async
// PLB_fnc_addStorage aging spawned above and usually won at a congested boot -> the aging guard saw the house
// already "scanned" -> scotch never aged. The marking now happens ATOMICALLY inside fn_addStorage's aging
// block, so it can't pre-empt the aging. (Full time-based aging is logged in features.md.)
}; 
 
if ((_ret select 19) != "0") then {[_ret select 19,_unit] spawn {
_query = format["SELECT `gang1`,`gang2` FROM wars WHERE gang1 = '%2' OR gang2 = '%2'",life_server_instance, _this select 0]; 
_sql = [_query,2,true] call DB_fnc_asyncQuery; 
if(count _sql > 0) then {_wars = [];
// owner 2026-06-23: normalize gang IDs to NUMBERS before comparing. extDB3 may return the gang1/gang2 INT columns
// as numbers while `_this select 0` (the player's gang id) arrives as a string -> the old `==` mismatched types and
// could push the player's OWN gang into life_gang_wars (or miss the enemy). life_gang_wars is numeric everywhere
// else (fn_warStatus pushBackUnique, the `in life_gang_wars` UI checks), so store numbers.
private _meGang = parseNumber (str (_this select 0)); {private _g1 = parseNumber (str (_x select 0));
private _g2 = parseNumber (str (_x select 1));
private _war = if (_meGang isEqualTo _g1) then { _g2 } else { _g1 };
if (!(_war in _wars)) then { _wars pushBack _war; };} forEach _sql;
life_gang_wars = _wars;
((_this select 1) getVariable ["ownerID", -1]) publicVariableClient "life_gang_wars";};};};};}
else {[[],"life_fnc_sessionReceive",_unit,false] spawn life_fnc_MP;};}
else {[nil,"life_fnc_sessionReceive",_unit,false] spawn life_fnc_MP;};
 
[life_lastWeather,"life_fnc_applyWeather",_unit,false] spawn life_fnc_MP; 
(_unit getVariable ["ownerID", -1]) publicVariableClient "life_price_index"; 
(_unit getVariable ["ownerID", -1]) publicVariableClient "life_topWealth"; 
 
if (_uid in life_restrained_players) then {[[],"life_fnc_jail",_unit,false] spawn life_fnc_MP;};
 
_query = format["INSERT INTO `online` (`playerid`,`instance`) VALUES ('%1','%2')", _uid, life_server_instance]; 
[_query,1] call DB_fnc_asyncQuery;