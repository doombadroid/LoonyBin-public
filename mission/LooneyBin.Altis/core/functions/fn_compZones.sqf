/*
    life_fnc_compZones  (LooneyBin, owner 2026-07-10)
    COMPOSITION ZONES -- code-spawned object compositions (bases, HQ props, decoration sets) streamed by
    proximity instead of living in mission.sqm.

    WHY: Eden/mission.sqm objects are networked + always-present; a big composition placed there costs every
    machine all the time. Zone objects live as DATA (compositions\zone_*.sqf) and get spawned LOCAL on each
    machine (createSimpleObject = no network, no sim, no AI/physics cost) and, for clients, only while the
    player is actually near (streamed in/out as you travel). Only a handful of special objects should stay in
    mission.sqm. Visual editing round-trips through the 3DEN editor via tools/compExport.sqf +
    tools/compImport.sqf.

    TRANSFORMS: posWorld + vectorDir/vectorUp END-TO-END. posWorld is the raw world frame -- no ATL/ASL
    conversion anywhere in the pipeline, so land-vs-sea elevation can never skew a piece (the classic
    porting footgun: ATL over water measures from the SEABED).

    ZONE FILE (compositions\zone_<name>.sqf) returns ONE array:
        [ "name", [cx, cy], radius, enabled, serverSide, [
            [class, [px,py,pz] (posWorld), [dirX,dirY,dirZ], [upX,upY,upZ], simple?(optional, default true)],
            ...
        ]]
      radius <= 0  -> always loaded (spawned once at init, never despawned)
      radius > 0   -> streamed with the reference loader's distances: small zones (r<=200) IN at r+400 /
                      OUT at r+550, big zones IN at r+1000 / OUT at r+1250 (2s poll, distance2D)
      enabled=false-> zone is dead data (register it, ship it, spawn nothing)
      serverSide   -> ALSO spawned on the dedicated server at boot (only needed when server-side logic must
                      collide with / nearestObjects-find the pieces; clients stream it either way)
      simple=false -> createVehicleLocal instead of createSimpleObject (working doors/animation; still
                      local-only). Use sparingly -- simple objects are the whole point.

    Modes:
        ["server"] call  life_fnc_compZones;   // initServer -- spawn enabled serverSide zones once
        ["client"] spawn life_fnc_compZones;   // initPlayerLocal -- streaming loop (MUST be spawned)
*/
params [["_mode", "client", [""]]];

// ── one-time zone registry load (per machine) ────────────────────────────────────────────────
if (isNil "PLB_compZones") then {PLB_compZones = [];
    private _reg = call compile preprocessFileLineNumbers "compositions\zones.sqf";
    if (isNil "_reg" || {!(_reg isEqualType [])}) then { _reg = []; }; {private _z = call compile preprocessFileLineNumbers _x;
        if (!isNil "_z" && {_z isEqualType []} && {count _z >= 6}) then {PLB_compZones pushBack _z;} else {
            diag_log format ["[LooneyBin][compzones] BAD/missing zone file %1 -- skipped", _x];};} forEach _reg;
    diag_log format ["[LooneyBin][compzones] %1 zone(s) registered", count PLB_compZones];};

// spawn every object of one zone on THIS machine -> returns the spawned objects
private _spawnZone = {params ["_z"];
    _z params ["_zName", "_zC", "_zR", "_zEn", "_zSrv", "_zObjs"];
    private _made = []; {
        _x params [["_cls", "", [""]], ["_pw", [0,0,0], [[]]], ["_vd", [0,1,0], [[]]], ["_vu", [0,0,1], [[]]], ["_simple", true, [true]]];
        if (_cls isNotEqualTo "") then {
            if (canSuspend) then { uiSleep 0.0005; };   // a1013 idiom: spread big-zone creation over frames (no hitch)
            private _o = objNull;
            if (_simple) then {
                // POSITION DIRECT into createSimpleObject -- the proven custom_buildings\load.sqf pattern
                // (creating at [0,0,0] then repositioning left objects stuck at the map corner).
                _o = createSimpleObject [_cls, _pw];} else {
                // needs animation/doors -> local vehicle object (still zero network traffic). Sim stays ON
                // (enableSimulation false would kill door interaction); damage off so it can't be wrecked.
                _o = createVehicleLocal [_cls, [_pw select 0, _pw select 1, 0], [], 0, "CAN_COLLIDE"];
                _o allowDamage false;};
            _o setPosWorld _pw;                 // re-affirm the exact world transform
            _o setVectorDirAndUp [_vd, _vu];
            // exempt server-side copies from the ownerless-object reap (fn_cleanup); local var is enough --
            // the sweep runs where the object lives.
            _o setVariable ["owner", "plb_compzone"];
            _made pushBack _o;};} forEach _zObjs;
    _made};

// ── SERVER: spawn enabled serverSide zones once at boot ─────────────────────────────────────
if (_mode isEqualTo "server") exitWith {if (!isServer) exitWith {}; {_x params ["_zName", "_zC", "_zR", "_zEn", "_zSrv"];
        if (_zEn && _zSrv) then {private _objs = [_x] call _spawnZone;
            diag_log format ["[LooneyBin][compzones] SERVER spawned '%1' (%2 object(s))", _zName, count _objs];};} forEach PLB_compZones;};

// ── CLIENT: always-on zones once, then the proximity streaming loop ─────────────────────────
if (!hasInterface) exitWith {};
waitUntil { !isNull player };
uiSleep 3;   // let the world/terrain settle on this machine (mirrors custom_buildings\load.sqf)

private _state = [];   // per-zone spawned-object list ([] = not streamed in)
private _heldLogged = PLB_compZones apply { false };   // per-zone hold-log dedupe
{_x params ["_zName", "_zC", "_zR", "_zEn"];
    private _objs = [];
    if (_zEn && {_zR <= 0}) then {_objs = [_x] call _spawnZone;
        diag_log format ["[LooneyBin][compzones] '%1' always-on: %2 object(s)", _zName, count _objs];};
    _state pushBack _objs;} forEach PLB_compZones;

// nothing to stream? (all zones always-on / disabled) -> no loop needed
if ((PLB_compZones findIf { _x params ["", "", "_zR", "_zEn"]; _zEn && {_zR > 0} }) isEqualTo -1) exitWith {};

while {true} do {private _pp = getPosWorld player;
    // a1013 "lastVehicle" tracking: remember the last vehicle the player occupied (2s granularity is
    // plenty); forget it once it's dead. Used by the unload guard below.
    if (!isNull objectParent player) then { PLB_compLastVehicle = objectParent player; };
    if (!isNull (missionNamespace getVariable ["PLB_compLastVehicle", objNull]) && {!alive PLB_compLastVehicle}) then { PLB_compLastVehicle = objNull; };
    {_x params ["_zName", "_zC", "_zR", "_zEn"];
        if (_zEn && {_zR > 0}) then {private _cur = _state select _forEachIndex;
            private _d = _pp distance2D _zC;
            // streaming distances lifted from the reference dynamic-map loader: small zones (r<=200)
            // load at r+400 / unload at r+550; big zones load at r+1000 / unload at r+1250. The wide
            // in-margin means aircraft see comps from the sky; the 150/250m hysteresis kills boundary thrash.
            private _inM  = [1000, 400] select (_zR <= 200);
            private _outM = [1250, 550] select (_zR <= 200);
            if (_d <= (_zR + _inM) && {_cur isEqualTo []}) then {private _objs = [_x] call _spawnZone;
                _state set [_forEachIndex, _objs];
                diag_log format ["[LooneyBin][compzones] '%1' streamed IN (%2 object(s) @ %3m)", _zName, count _objs, round _d];};
            if (_d > (_zR + _outM) && {!(_cur isEqualTo [])}) then {
                // a1013 parked-vehicle guard, WIDENED: never pull a zone out from under the player's last
                // ride OR any of their keyed vehicles -- local physics would drop a parked vehicle straight
                // through the vanished client-side geometry. (isKindOf AllVehicles: life_vehicles also
                // carries HOUSE objects -- a house must never pin a zone loaded.)
                private _lv = missionNamespace getVariable ["PLB_compLastVehicle", objNull];
                private _held = (!isNull _lv && {alive _lv} && {((getPosATL _lv) distance2D _zC) <= (_zR + _outM)})
                    || {(life_vehicles findIf {!isNull _x && {_x isKindOf "AllVehicles"} && {!(_x isKindOf "Man")} && {alive _x}
                        && {((getPosATL _x) distance2D _zC) <= (_zR + _outM)}}) isNotEqualTo -1};
                if (_held) then {if !(_heldLogged select _forEachIndex) then {   // once per hold episode, not every 2s
                        diag_log format ["[LooneyBin][compzones] '%1' unload HELD (parked vehicle inside)", _zName];
                        _heldLogged set [_forEachIndex, true];};} else {
                    { deleteVehicle _x; if (canSuspend) then { uiSleep 0.002; }; } forEach _cur;
                    _state set [_forEachIndex, []];
                    _heldLogged set [_forEachIndex, false];
                    diag_log format ["[LooneyBin][compzones] '%1' streamed OUT", _zName];};};};} forEach PLB_compZones;
    uiSleep 2;};
