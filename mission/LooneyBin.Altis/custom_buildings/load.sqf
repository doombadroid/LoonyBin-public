/*
    custom_buildings\load.sqf   (LooneyBin Altis)
    Mission-embedded custom .p3d buildings -- NO mod. Clients receive the models via the normal
    mission download. Runs on EVERY machine (createSimpleObject is LOCAL) -> execVM'd from init.sqf.
    Proven path form on this box (memory loonybin-mission-embedded-p3d):
        mpmissions\__cur_mp.Altis\custom_buildings\<model>.p3d

    PLACEMENT TABLE (_B) entries -- owner fills these (coords as [model, x, y, dirDeg]):
        ["HQMesh",        x, y, dir]          single building (z = terrain + catalog offset)
        ["FederalReserveSign", x, y, dir]     "
        ["BridgeStraight", x, y, dir, 0]      5th elem = ABSOLUTE z(ASL); bridges sit at sea level (0)
        ["HQ",            cx, cy, dir]         POLICE HQ COMPOUND: HQMesh + the 13-wall ring, rotated to dir
*/
if (missionNamespace getVariable ["PLB_customBuildingsDone", false]) exitWith {};
PLB_customBuildingsDone = true;
uiSleep 3;   // let the world/terrain finish loading on THIS machine before spawning local simple objects
private _cat = [["HQMesh", 3.1, 1], ["PoliceHQWallLong", 2.75, 1], ["FederalReserveSign", 1.8, 1.5],
    ["EvidenceSign", 1.3, 1.5], ["RebelRig", 0, 1], ["ShopBuildingTrini", 0, 1],   // RebelRig offset 40->0 (owner 2026-06-23): 40 was the Athira float TEST; 0 grounds the base on terrain (its origin == base, proven by the float test lifting the whole rig +40).
    ["BridgeStraight", 0, 1], ["BridgeMiddle", 0, 1]];
// police-HQ wall ring: each = [dx, dy, relDir] relative to the HQ building centre (from the Malden layout)
private _hqWalls = [[6.63,22.55,140],[-0.31,30.8,140],[-9.21,35.14,91.9],[-20.07,35.48,91.9],[-31.02,35.81,91.9],
    [-32.49,-26.04,89.1],[-21.53,-25.81,89.1],[-10.56,-25.61,89.1],[0.35,-25.43,89.1],
    [-37.03,30.79,1.9],[-37.37,19.8,1.9],[-37.77,8.85,1.9],[-38.42,-20.85,1.9]];

private _spawn = {params ["_m", "_x0", "_y0", "_dir", ["_zabs", -99999]];
    private _ci  = _cat findIf { (_x select 0) isEqualTo _m };
    private _off = if (_ci > -1) then { (_cat select _ci) select 1 } else { 0 };
    private _scl = if (_ci > -1) then { (_cat select _ci) select 2 } else { 1 };
    private _z = if (_zabs > -99998) then { _zabs } else { (getTerrainHeightASL [_x0, _y0]) + _off };
    // POSITION DIRECT into createSimpleObject -- the proven Malden pattern. Creating at [0,0,0] then setPosASL
    // left the simple object stuck at the map corner [0,0,0] = "rig not there" even though it spawned (placed=1).
    private _o = createSimpleObject [format ["mpmissions\__cur_mp.Altis\custom_buildings\%1.p3d", _m], [_x0, _y0, _z]];
    _o setPosASL [_x0, _y0, _z];   // re-affirm (no-op if createSimpleObject already placed it)
    _o setDir _dir;
    _o setObjectScale _scl;
    _o setVariable ["owner", "plb_customBuilding", true];   // exempt from server-side ownerless-reap (fn_cleanup)
    _o};

// HQ compound: building + wall ring rotated to _dir (relative offsets were captured at the Malden HQ's 180deg)
private _spawnHQ = {params ["_cx", "_cy", "_dir"];
    ["HQMesh", _cx, _cy, _dir] call _spawn;
    private _a = (_dir - 180);
    private _ca = cos _a; private _sa = sin _a; {_x params ["_dx", "_dy", "_rel"];
        private _wx = _cx + (_dx * _ca - _dy * _sa);
        private _wy = _cy + (_dx * _sa + _dy * _ca);
        ["PoliceHQWallLong", _wx, _wy, _dir + _rel] call _spawn;} forEach _hqWalls;};

// >>> OWNER COORDS GO HERE (pushBack form -- large literals trip the SQF GIAR compiler) <<<
private _B = [];
_B pushBack ["RebelRig", 15017.28, 6838.09, 117.1];   // owner 2026-06-23: at the OIL CARTEL, dir 117.1, auto-grounds to terrain (getTerrainHeightASL+0). The cartel is low coastal LAND (~+4m ASL, per oil_flag's setPosATL 0), NOT deep water. **2026-06-24 (#524): moved 13m along the rig's -X model axis (world bearing 117.1, i.e. from [15011.36,6849.66] -> [15017.28,6838.09]) because dir-117.1 put oil_flag DEAD-CENTER in the rig's solid base column (MLOD footprint: dense geometry AT model origin 0,0; +X structural edge ends at model x=+7.97). Players could only reach the flag by going UNDER the rig base. New pos sits oil_flag at model x=+13 (5m past the +X edge, confirmed-empty zone) so the "Get Cartel Rubber" addAction (3m engine radius / 8m script distance2D) + the garage actions are clear, with the rig still an adjacent landmark. Flag itself is UNCHANGED (drives the oil_cartel marker + cap zone + rubber gen). If it still clips, increase the move along bearing 117.1.
// _B pushBack ["HQ", 0000, 0000, 0];                  // police HQ compound (building + walls)
// _B pushBack ["FederalReserveSign", 0000, 0000, 0];
// _B pushBack ["RebelRig", 0000, 0000, 180];
// _B pushBack ["BridgeStraight", 0000, 0000, 0, 0];   // bridge piece at sea level
 {if ((_x select 0) isEqualTo "HQ") then {[_x select 1, _x select 2, _x select 3] call _spawnHQ;} else {_x call _spawn;};} forEach _B;
