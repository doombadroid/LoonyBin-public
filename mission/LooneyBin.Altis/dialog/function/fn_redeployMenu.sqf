private _radius = 500;
if ((playerSide isEqualTo civilian)) exitWith {};
if !(isNull objectParent player) exitWith {};
if (life_inCombat) exitWith {["You were recently near or in combat. Leave combat and try again.", "basic"] spawn life_fnc_handleMessage;};
disableSerialization;
["redeploy_selection"] call life_fnc_createDialog;
private _spCfg = [playerSide] call life_fnc_spawnPointCfg; {private _markerName = (_spCfg select _forEachIndex) select 1;
    if (!("phouse_" in ((_spCfg select _forEachIndex) select 0))) then {
        _markerName = _markerName + format[" [%1]", count(allplayers select {
            (_x distance2d(getMarkerPos((_spCfg select _forEachIndex) select 0))) < _radius})];};
    lbAdd[38510, _markerName];}
forEach _spCfg;
if !(life_disabled_spawns isEqualTo[]) then {[] spawn {while {uiSleep 2;
            !(life_disabled_spawns isEqualTo[])}
        do {private _disabledSpawns = count(life_disabled_spawns);
            waitUntil {uiSleep 2;
                _disabledSpawns != (count life_disabled_spawns)};
            lbClear 38510;
            private _spCfg = [playerSide] call life_fnc_spawnPointCfg; {private _markerName = (_spCfg select _forEachIndex) select 1;
                if (!("phouse_" in ((_spCfg select _forEachIndex) select 0))) then {
                    _markerName = _markerName + format[" [%1]", count(allplayers select {
                        (_x distance2d(getMarkerPos((_spCfg select _forEachIndex) select 0))) < _radius})];};
                lbAdd[38510, _markerName];}
            forEach _spCfg;};};};
private _sp = _spCfg select 0;
[(findDisplay 38500) displayCtrl 38502, 1, 0.1, getMarkerPos(_sp select 0)] call life_fnc_setMapPosition;
life_spawn_point = _sp;