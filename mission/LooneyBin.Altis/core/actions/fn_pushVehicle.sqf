private _target = cursorTarget;
private _caller = player;
private _posCaller = getPos _caller;
private _dir = getDir _caller;
if (isNull _target) exitWith {};
if (_caller distance _target > 5) exitWith {};
if (local _target) then {[_caller, _target, _posCaller, _dir] spawn life_fnc_pushFunction;} else {[
        [_caller, _target, _posCaller, _dir], "life_fnc_pushFunction", _target, false] spawn life_fnc_MP;};