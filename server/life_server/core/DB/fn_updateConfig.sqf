 
private ["_query","_update"]; 
 
 {if (isNil "_x") exitWith {};   // LooneyBin: nil hole in life_configuration (short config array) -- skip, don't spam
_update = true;
if (!isNil "(life_configuration_last select _forEachIndex)") then {if (_x == (life_configuration_last select _forEachIndex)) then {
_update = false;};};
 
if (_update) then {if (_forEachIndex in [2,9]) then { _x = [_x,0] call DB_fnc_bool; };
_query = format ["UPDATE `config` SET `value`='%1' WHERE `index`='%2'", _x, _forEachIndex, life_server_instance]; 
[_query] call DB_fnc_asyncQuery;};} forEach life_configuration;
 
life_configuration_last = + life_configuration;