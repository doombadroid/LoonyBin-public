/*
    TON_fnc_shedHelipadSRV  (LooneyBin, owner 2026-07-10)
    SHED HELIPAD UPGRADE -- owner-designed 3DEN composition (a raised concrete deck w/ guardrails, two pier
    ladders, wall poles + the pad decal) bolted onto any owned industrial shed, plus the flag that turns the
    shed into an AIR garage spawn point.

    DATA: PLB_heliPadComp members are SHED-RELATIVE [class, [dx,dy,dz], relDirDeg], captured from the owner's
    Eden composition via tools/compExport.sqf with the reference shed at heading 0. Spawn = rigid transform:
    world = shedPosWorld + Rz(shedDir)*offset, setPosWorld (exact round-trip of the capture frame, slope-proof).

    PERMANENT (owner 2026-07-10, v2): pads spawn at BOOT for every helipad=1 shed and stay up -- the pieces
    are sim-disabled statics (zero per-frame cost; only a one-time spawn + JIP sync burst), so presence
    despawning saved nothing and dropped parked helicopters to their death when the deck vanished under
    them. Spawns instantly on purchase. The only teardown is a server restart.

    Modes:
      ["buy", _house, _player]   owner-gated purchase: writes houses.helipad=1, tags plb_helipad, spawns now
      ["presenceStart"]          boot: build the cache from the DB + start the watcher
    The AIR pull itself rides the standard property garage (fn_vehicleGaragePull): an upgraded shed spawns
    Air pulls dead-centre on the pad, nose along the shed's facing.
*/
params [["_mode", "", [""]]];

PLB_heliPadComp = [["Land_ConcretePanels_02_single_v2_F", [-8.799, 7.246, 4.791], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [-7.055, 7.252, 4.795], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [-3.672, 7.264, 4.799], 180.0],
    ["Land_ConcretePanels_02_single_v2_F", [-5.416, 7.258, 4.803], 180.0],
    ["Land_ConcretePanels_02_single_v2_F", [-1.822, 7.266, 4.791], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [-0.078, 7.272, 4.795], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [3.305, 7.284, 4.799], 180.0],
    ["Land_ConcretePanels_02_single_v2_F", [1.561, 7.278, 4.803], 180.0],
    ["Land_ConcretePanels_02_single_v2_F", [-8.789, 3.407, 4.791], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [-7.045, 3.412, 4.795], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [-8.791, -0.441, 4.799], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [-7.047, -0.435, 4.803], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [-3.664, -0.423, 4.791], 180.0],
    ["Land_ConcretePanels_02_single_v2_F", [-5.408, -0.429, 4.795], 180.0],
    ["Land_ConcretePanels_02_single_v2_F", [-3.662, 3.424, 4.799], 180.0],
    ["Land_ConcretePanels_02_single_v2_F", [-5.406, 3.418, 4.803], 180.0],
    ["Land_ConcretePanels_02_single_v2_F", [-1.812, 3.426, 4.791], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [-0.068, 3.432, 4.795], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [-1.814, -0.421, 4.799], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [-0.070, -0.416, 4.803], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [3.313, -0.404, 4.791], 180.0],
    ["Land_ConcretePanels_02_single_v2_F", [1.569, -0.410, 4.795], 180.0],
    ["Land_ConcretePanels_02_single_v2_F", [3.315, 3.444, 4.799], 180.0],
    ["Land_ConcretePanels_02_single_v2_F", [1.571, 3.438, 4.803], 180.0],
    ["Land_ConcretePanels_02_single_v2_F", [5.121, 7.278, 4.791], 0.0], ["Land_ConcretePanels_02_single_v2_F", [6.865, 7.284, 4.795], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [10.248, 7.295, 4.799], 180.0],
    ["Land_ConcretePanels_02_single_v2_F", [8.504, 7.289, 4.803], 180.0],
    ["Land_ConcretePanels_02_single_v2_F", [12.098, 7.297, 4.791], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [13.842, 7.303, 4.795], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [15.481, 7.309, 4.799], 180.0],
    ["Land_ConcretePanels_02_single_v2_F", [5.131, 3.438, 4.803], 0.0], ["Land_ConcretePanels_02_single_v2_F", [6.875, 3.444, 4.791], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [5.129, -0.410, 4.795], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [6.873, -0.404, 4.799], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [10.256, -0.392, 4.803], 180.0],
    ["Land_ConcretePanels_02_single_v2_F", [8.512, -0.398, 4.791], 180.0],
    ["Land_ConcretePanels_02_single_v2_F", [10.258, 3.455, 4.795], 180.0],
    ["Land_ConcretePanels_02_single_v2_F", [8.514, 3.450, 4.799], 180.0],
    ["Land_ConcretePanels_02_single_v2_F", [12.108, 3.457, 4.803], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [13.852, 3.463, 4.791], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [12.106, -0.390, 4.795], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [13.850, -0.384, 4.799], 0.0],
    ["Land_ConcretePanels_02_single_v2_F", [15.488, -0.379, 4.803], 180.0],
    ["Land_ConcretePanels_02_single_v2_F", [15.490, 3.469, 4.791], 180.0], ["Land_PipeFence_02_s_4m_F", [14.356, -2.236, 4.139], 0.0],
    ["Land_PipeFence_02_s_4m_F", [14.340, 9.075, 4.139], 358.8], ["Land_PipeFence_02_s_4m_F", [-7.652, 9.045, 4.139], 180.3],
    ["Land_PipeFence_02_s_4m_F", [-7.527, -2.142, 4.139], 179.0], ["Land_PipeFence_02_s_4m_F", [-2.732, 9.090, 4.139], 180.3],
    ["Land_PipeFence_02_s_4m_F", [2.328, 9.088, 4.139], 180.3], ["Land_PipeFence_02_s_4m_F", [6.326, 9.069, 4.139], 180.3],
    ["Land_PipeFence_02_s_4m_F", [10.326, 9.045, 4.139], 180.3], ["Land_PipeFence_02_s_4m_F", [10.340, -2.230, 4.139], 180.3],
    ["Land_PipeFence_02_s_4m_F", [6.332, -2.226, 4.139], 180.3], ["Land_PipeFence_02_s_4m_F", [2.330, -2.207, 4.139], 180.3],
    ["Land_PierLadder_F", [-10.193, 3.061, 2.237], 89.3], ["Land_HelipadSquare_F", [3.351, 3.436, 5.341], 0.0]];

if (isNil "PLB_heliPads") then { PLB_heliPads = createHashMap; };   // oid -> [shed, ownerUID, spawned[], gangMembers[], gangTs]

// rigid spawn of the whole comp anchored to a shed -> returns spawned objects
PLB_fnc_heliPadSpawn = {params ["_shed"];
    private _a = getPosWorld _shed;
    private _dir = getDir _shed;
    private _c = cos _dir; private _s = sin _dir;
    private _made = []; {_x params ["_cls", "_off", "_rel"];
        _off params ["_ox", "_oy", "_oz"];
        private _o = createVehicle [_cls, [0, 0, -100], [], 0, "CAN_COLLIDE"];
        _o setDir (_dir + _rel);
        _o setPosWorld [(_a select 0) + (_ox * _c) + (_oy * _s), (_a select 1) - (_ox * _s) + (_oy * _c), (_a select 2) + _oz];
        _o enableSimulationGlobal false;
        _o allowDamage false;
        _o setVariable ["owner", "plb_helipad"];   // exempt from the ownerless-object reap (fn_cleanup)
        _made pushBack _o;} forEach PLB_heliPadComp;
    _made};

switch (toLower _mode) do {case "buy": {params ["", ["_house", objNull, [objNull]], ["_player", objNull, [objNull]]];
        if (isNull _house || isNull _player) exitWith {};
        private _uid = getPlayerUID _player;
        if !(typeOf _house isEqualTo "Land_i_Shed_Ind_F") exitWith {};
        if ((_house getVariable ["plb_homeOwner", ""]) isNotEqualTo _uid) exitWith {
            ["-SEC-", _player, format ["BLOCKED helipad buy (not owner) oid=%1", _house getVariable ["plb_houseID", "?"]]] call PLB_fnc_logIt;
        };
        if (_house getVariable ["plb_helipad", false]) exitWith {};
        private _oid = format ["%1", _house getVariable ["plb_houseID", -1]];
        if (_oid in ["-1", ""]) exitWith {
            [["The realtor can't register a helipad on this building (no house record).", "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
        };
        [format ["UPDATE houses SET helipad=1 WHERE oid='%1'", _oid]] call DB_fnc_asyncQuery;
        _house setVariable ["plb_helipad", true, true];
        private _objs = [_house] call PLB_fnc_heliPadSpawn;   // buyer is online -> occupied -> spawn NOW
        PLB_heliPads set [_oid, [_house, _uid, _objs, [], -1e9]];
        ["-HELIPAD-", _player, format ["bought shed helipad oid=%1 (%2 pieces up)", _oid, count _objs]] call PLB_fnc_logIt;
        [["Helipad constructed! Your air vehicles can now be pulled from this shed's Helipad Garage.", "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
        diag_log format ["[LooneyBin][helipad] BUY oid=%1 by %2 -> %3 pieces", _oid, _uid, count _objs];};
    case "presencestart": {
        private _rows = ["SELECT QUOTE(oid), QUOTE(worldspace), QUOTE(owners) FROM houses WHERE helipad=1", 2, true] call DB_fnc_asyncQuery;
        if (_rows isEqualType []) then {{private _oid = format ["%1", _x param [0, ""]];
                private _ws = parseSimpleArray format ["%1", _x param [1, "[]"]];
                private _own = format ["%1", _x param [2, ""]];
                if (_ws isEqualType [] && {count _ws >= 2}) then {
                    private _shed = (nearestObjects [_ws, ["Land_i_Shed_Ind_F"], 18]) param [0, objNull];
                    if (!isNull _shed) then {_shed setVariable ["plb_helipad", true, true];
                        private _objs = [_shed] call PLB_fnc_heliPadSpawn;
                        PLB_heliPads set [_oid, [_shed, _own, _objs, [], -1e9]];} else {
                        diag_log format ["[LooneyBin][helipad] presenceStart: no shed at %1 for oid=%2", _ws, _oid];};};} forEach _rows;};
        private _up = 0;
        { _up = _up + count (_y select 2); } forEach PLB_heliPads;
        diag_log format ["[LooneyBin][helipad] boot: %1 upgraded shed(s), %2 pieces spawned (permanent)", count PLB_heliPads, _up];};};
