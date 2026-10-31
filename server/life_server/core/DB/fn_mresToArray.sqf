 
private["_array"]; 
_array = [_this,0,"",[""]] call BIS_fnc_param; 
if(_array == "") exitWith {[]}; 
_array = toArray(_array); 
 
for "_i" from 0 to (count _array)-1 do {_sel = _array select _i;
if(_sel == 96) then {
// LooneyBin: backtick(96) -> DOUBLE-quote(34), NOT single-quote(39). The encoder (mresArray) does
// str(str(x)) then 34->96; the proper inverse restores 34. Using 39 turned "" (empty strings, which
// str() to """") into '''' -> a stray ' or syntax error -> the whole decode returned nil. Arrays full
// of empty strings (gear loadouts: empty muzzle/optic/etc slots) therefore failed to decode -> player
// got the default loadout every spawn. Non-empty strings (licenses) and numbers (talents) round-trip
// fine either way, which is why only gear was broken.
_array set[_i,34];};};
 
_array = toString(_array);
// LooneyBin: DB_fnc_asyncQuery call-compiles the whole extDB3 result, which CONSUMES this value's
// outer quotes (mresArray keeps them so the column reads back as a string). So by the time we get here
// the str(str(x)) wrapping is already one level down: _array is str(x) with its quotes DOUBLED (the
// 2nd str's artifact). Compiling it directly as an array makes bareword strings (e.g. a uniform
// classname) parse as undefined variables -> nil -> []  (= naked gear, the real bug). Re-wrap in quotes
// so it parses as the intermediate STRING (un-doubling the quotes); the caller's 2nd compile (queryRequest
// _dec / gang _dec / restoreVehicles) then yields the value. Pure-number arrays (talents/position) are
// unaffected (no inner quotes to double).
_array = call compile format["""%1""", _array];
// owner 2026-06-20: belt-and-suspenders. A malformed input (e.g. a double-QUOTE'd mres column -- the houses-
// keyholders / gangfort-leaderboard bug) makes the `call compile` above return nil, which UNDEFINES _array ->
// the bare `_array;` below threw "Undefined variable in expression: _array" (was firing 76x every 5 min). Never
// throw: nil -> []. No-op on every valid decode (a good compile yields a string, never nil), so zero regression
// risk for loadouts/vehicles/gangs that round-trip this fn. The real fixes are at the callers (drop the QUOTE).
if (isNil "_array") then { _array = []; };
_array;