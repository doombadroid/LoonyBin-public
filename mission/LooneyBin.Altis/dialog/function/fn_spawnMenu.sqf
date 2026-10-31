private _radius = 500;
if ((life_is_arrested param [0,0]) isEqualTo 1) exitWith {[] spawn life_fnc_respawned;};
private _exit = false;
// owner 2026-06-13: "Resilient Respawn" (lucky hospital revive) made SEMI-RARE -- was 1/8 (12.5%) gated on
// talent 50, but the talent system was removed so every god-stat player passed the gate -> it fired
// constantly. Now a flat ~5% roll for everyone (1 in 20), no dead talent gate.
if (life_respawned) then {private _lucky = floor(random 20) isEqualTo 0;
    if (_lucky && isNil "life_suicide") exitWith {
        private _action = ["You were lucky and NG medics saved your life, respawn at the nearest NG Hospital?", "Resilient Respawn", "Yes", "No"] call BIS_fnc_guiMessage;
        if (_action) exitWith {[player, true] spawn life_fnc_revived;
            _exit = true;};};};
if (_exit) exitWith {};
if (life_respawned) then {[] spawn life_fnc_respawned;};
if (!isNull(findDisplay 17000)) then {closeDialog 0;};
disableSerialization;
"loadingScreen"
cutRsc["life_loadingScreen", "PLAIN", -1, true];
life_suicide = nil;
// owner 2026-07-19: hold connecting / dead / waiting players at map-center @ 50km with simulation OFF (so they
// don't fall) while they pick a spawn -- replaces them lingering on the northmost "debug" island proxy cluster.
// Simulation is restored at the real teleport in fn_spawnConfirm (+ initPlayerLocal failsafe loop).
player setPosASL [worldSize / 2, worldSize / 2, 50000];
player enableSimulation false;
["life_spawn_selection"] call life_fnc_createDialog;
(findDisplay 38500) displaySetEventHandler["keyDown", "_this call life_fnc_displayHandler"];
private _spCfg = [playerSide] call life_fnc_spawnPointCfg; {private _markerName = (_spCfg select _forEachIndex) select 1;
    if (!("phouse_" in ((_spCfg select _forEachIndex) select 0))) then {
        _markerName = _markerName + format[" [%1]", count(allplayers select {
            (_x distance2d(getMarkerPos((_spCfg select _forEachIndex) select 0))) < _radius})];};
    lbAdd[38510, _markerName];}
forEach _spCfg;
[] spawn {private _display = findDisplay 38500;
    while {uiSleep 1;
        !(isNull _display)}
    do {private _disabledCount = count life_disabled_spawns;
        private _spawnableTurfCount = {
            (_x getVariable["plb_turf_data", []] param[0, -1]) isEqualTo(life_gang_data param[0, -2]) && !(_x getVariable["plb_turf_data", []] param[2, false])
        }
        count[panagia_flag, zaros_flag, rodo_flag];
        waitUntil {uiSleep 1;
            isNull _display || !(_disabledCount isEqualTo(count life_disabled_spawns)) || !(_spawnableTurfCount isEqualTo({
                (_x getVariable["plb_turf_data", []] param[0, -1]) isEqualTo(life_gang_data param[0, -2]) && !(_x getVariable["plb_turf_data", []] param[2, false])
            }
            count[panagia_flag, zaros_flag, rodo_flag]))};
        if (isNull _display) exitWith {};
        private _spCfg = [playerSide] call life_fnc_spawnPointCfg;
        lbClear 38510; {lbAdd[38510, (_spCfg select _forEachIndex) select 1];}
        forEach _spCfg;};};
private _sp = _spCfg param[0, []];
[(findDisplay 38500) displayCtrl 38502, 1, 0.1, getMarkerPos(_sp param[0, ""])] call life_fnc_setMapPosition;
life_spawn_point = _sp;
