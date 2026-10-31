 
private["_array"]; 
_array = [_this,0,[],[[]]] call BIS_fnc_param; 
_array = str(str(_array));
_array = toArray(_array);
_array = _array - [96];   // SECURITY (root): drop any SOURCE backtick(96) before it becomes this codec's delimiter. Otherwise a backtick in free-text (e.g. a loadout/gang/name) survives encode and mresToArray turns it into a " that breaks out at a consumer's call compile = server RCE (Lystic class). Legit data never contains backticks.

for "_i" from 0 to (count _array)-1 do {_sel = _array select _i;
if((_i != 0 && _i != ((count _array)-1))) then {if(_sel == 34) then {_array set[_i,96];};};};
 
_array = toString(_array); 
_array;