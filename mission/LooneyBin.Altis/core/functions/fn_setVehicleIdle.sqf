params[["_vehicle", objNull, [objNull]], ["_time", 900, [0]]];
if (isNull _vehicle) exitWith {};
if !(_vehicle isKindOf "Car" || _vehicle isKindOf "Ship" || _vehicle isKindOf "Air" || _vehicle isKindOf "Tank") exitWith {};   // owner 2026-07-23: + Tank (Nyx)
if (life_idleVehicleCache isEqualTo[]) exitWith {life_idleVehicleCache pushBack[_vehicle, serverTime]; [
        [_vehicle, _time], "TON_fnc_setCleanTime", 2] spawn life_fnc_MP;};
private _exit = false; {_x params["_cachedVehicle", "_lastTimeReset"];
    if (_cachedVehicle isEqualTo _vehicle) exitWith {_exit = true;
        private _resetThreshold = 90;
        if ((serverTime - _lastTimeReset) >= _resetThreshold) then {[[_vehicle, _time], "TON_fnc_setCleanTime", 2] spawn life_fnc_MP;
            _x set[1, serverTime];};};}
forEach life_idleVehicleCache;
if (_exit) exitWith {};
life_idleVehicleCache pushBack[_vehicle, serverTime]; [[_vehicle, _time], "TON_fnc_setCleanTime", 2] spawn life_fnc_MP;
[] spawn {{_x params["_cachedVehicle"];
        if (isNull _cachedVehicle) then {deleteVehicle _cachedVehicle;
            life_idleVehicleCache deleteAt _forEachIndex;};
        uiSleep 0.3;}
    forEach life_idleVehicleCache;};