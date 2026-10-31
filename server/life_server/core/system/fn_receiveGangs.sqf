 
private["_session","_index","_talents","_members"]; 
_session = _this select 0;
diag_log format ["[LooneyBin][receiveGangs] received %1 row(s)", if (isNil "_session") then {-1} else {count _session}];

if(isNil "_session") exitWith {};
 {_sess = _x;
_index = -1; 
{ if ((_sess select 0) == (_x select 0)) then { _index = _forEachIndex; }; } foreach life_server_gangs; 
if (_index < 0) then { _index = count life_server_gangs; }; 
_members = _x param [6, 0]; if (_members isEqualType "") then { _members = parseNumber _members };
_talents = _x param [8, "[]"]; if (_talents isEqualType "") then { _talents = parseSimpleArray (format ["%1", _talents]) }; if (isNil "_talents" || {!(_talents isEqualType [])}) then { _talents = [] };
if (count _x > 1) then { life_server_gangs set [_index, [(_x param [0,-1]),(_x param [1,""]),(_x param [2,0]),parseNumber(format["%1",_x param [3,0]]),parseNumber(format["%1",_x param [4,0]]),parseNumber(format["%1",_x param [5,0]]),_members,parseNumber(format["%1",_x param [7,0]]),_talents]]; };
} foreach (_session);
diag_log format ["[LooneyBin][receiveGangs] life_server_gangs now %1 gang(s)", count life_server_gangs];
 