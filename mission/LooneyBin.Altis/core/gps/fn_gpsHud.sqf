/*
    life_fnc_gpsHud  (LooneyBin, owner 2026-07-12)
    Turn-by-turn banner (dialog\gpsHUD.hpp). v2: driven by an EachFrame mission EH throttled to
    2Hz -- the v1 uiSleep loop lived in the scheduler, which this mission saturates, so "0.7s"
    ticks stretched to many seconds. Unscheduled = the banner and reroute react instantly.

    Modes:
        ["start"]   (re)install the EachFrame driver + show the banner layer
        ["stop"]    remove the driver + fade the banner
        ["tick"]    one update: banner text, arrival auto-clear, off-route auto-reroute
                    (>60m off for >2.5s)
*/
if (!hasInterface) exitWith {};
params [["_mode", "", [""]]];

switch (toLower _mode) do {case "start": {["stop"] call life_fnc_gpsHud;
        (("plb_gpsHud" call BIS_fnc_rscLayer)) cutRsc ["PLB_GpsHud", "PLAIN", 0.2, false];
        PLB_gpsHudNext = 0;
        PLB_gpsOffSince = -1;
        PLB_gpsHudEF = addMissionEventHandler ["EachFrame", {
            if (diag_tickTime >= (missionNamespace getVariable ["PLB_gpsHudNext", 0])) then {PLB_gpsHudNext = diag_tickTime + 0.5;
                ["tick"] call life_fnc_gpsHud;};}];
        // in-world guidance: faint cyan breadcrumbs + occasional chevrons hugging the road ahead,
        // local to this client only (drawIcon3D renders nothing for anyone else)
        PLB_gpsD3D = addMissionEventHandler ["Draw3D", {private _pts = missionNamespace getVariable ["PLB_gpsRoutePts", []];
            if (_pts isEqualTo []) exitWith {};
            private _n = count _pts;
            private _i0 = (missionNamespace getVariable ["PLB_gpsProgressIdx", 0]) min (_n - 1);
            private _acc = 0;
            private _next = 10;   // first crumb 10m along
            private _k = 0;
            for "_i" from (_i0 max 0) to (_n - 2) do {private _a = _pts select _i;
                private _b = _pts select (_i + 1);
                private _sl = (_a distance2D _b) max 0.01;
                while {_next <= _acc + _sl && {_acc < 240}} do {private _t = (_next - _acc) / _sl;
                    private _wx = (_a select 0) + ((_b select 0) - (_a select 0)) * _t;
                    private _wy = (_a select 1) + ((_b select 1) - (_a select 1)) * _t;
                    private _pos = [_wx, _wy, (getTerrainHeightASL [_wx, _wy]) + 0.9];
                    private _fade = (1 - _next / 260) max 0.15;
                    if (_k mod 3 isEqualTo 0) then {
                        // world-anchored chevron: arms built from overlapping dot icons (drawLine3D
                        // is locked to 1px) -- thick neon ">" that points down the road in real 3D
                        private _dx = ((_b select 0) - (_a select 0)) / _sl;
                        private _dy = ((_b select 1) - (_a select 1)) / _sl;
                        private _tx = _wx + _dx * 1.6; private _ty = _wy + _dy * 1.6;
                        private _col = [0.0, 0.83, 1.0, 0.9 * _fade]; {_x params ["_ex", "_ey"];   // wing endpoint of this arm
                            for "_s" from 0 to 13 do {   // 0.2m dot pitch = reads as one thick stroke
                                private _f2 = _s / 13;
                                private _px2 = _tx + (_ex - _tx) * _f2;
                                private _py2 = _ty + (_ey - _ty) * _f2;
                                drawIcon3D ["\A3\ui_f\data\map\markers\military\dot_CA.paa",
                                    _col, ASLToAGL [_px2, _py2, (getTerrainHeightASL [_px2, _py2]) + 0.9], 0.42, 0.42, 0, "", 0];};
                        } forEach [[_wx - _dx * 1.0 - _dy * 1.4, _wy - _dy * 1.0 + _dx * 1.4],
                            [_wx - _dx * 1.0 + _dy * 1.4, _wy - _dy * 1.0 - _dx * 1.4]];} else {
                        drawIcon3D ["\A3\ui_f\data\map\markers\military\dot_CA.paa",
                            [0.0, 0.83, 1.0, 0.45 * _fade], ASLToAGL _pos, 0.55, 0.55, 0, "", 0];};
                    _k = _k + 1;
                    _next = _next + 16;};
                _acc = _acc + _sl;
                if (_acc >= 240) exitWith {};};}];};
    case "stop": {if (!isNil "PLB_gpsHudEF") then {removeMissionEventHandler ["EachFrame", PLB_gpsHudEF];
            PLB_gpsHudEF = nil;};
        if (!isNil "PLB_gpsD3D") then {removeMissionEventHandler ["Draw3D", PLB_gpsD3D];
            PLB_gpsD3D = nil;};
        (("plb_gpsHud" call BIS_fnc_rscLayer)) cutText ["", "PLAIN", 0.3];};
    case "tick": {private _pts = missionNamespace getVariable ["PLB_gpsRoutePts", []];
        if (_pts isEqualTo []) exitWith { ["stop"] call life_fnc_gpsHud; };
        private _n = count _pts;
        private _me = getPosATL player;

        // progress = nearest route vertex, searched in a window around last progress so a
        // self-crossing route can't teleport you forward; the draw EH consumes this to trim
        // the already-driven tail (no more mile-long leg back to the original start)
        private _prevIdx = (missionNamespace getVariable ["PLB_gpsProgressIdx", 0]) min (_n - 1);
        private _best = _prevIdx;
        private _bd = 1e12;
        for "_i" from (0 max (_prevIdx - 25)) to ((_n - 1) min (_prevIdx + 120)) do {private _d = _me distance2D (_pts select _i);
            if (_d < _bd) then { _bd = _d; _best = _i; };};
        PLB_gpsProgressIdx = _best;

        private _remain = _bd;
        for "_i" from _best to (_n - 2) do {_remain = _remain + ((_pts select _i) distance2D (_pts select (_i + 1)));};

        private _dest = missionNamespace getVariable ["PLB_gpsDest", []];
        if (_dest isNotEqualTo [] && {(_me distance2D _dest) < 40 || {_remain < 40}}) exitWith {
            ["<t color='#00d4ff'>GPS:</t> you have arrived.", "basic"] spawn life_fnc_handleMessage;
            PLB_gpsRoutePts = [];
            PLB_gpsDest = [];
            ["stop"] call life_fnc_gpsHud;};

        // off-route -> recalc fast ("set" reinstalls this driver, so state resets cleanly)
        if (_bd > 60) then {if ((missionNamespace getVariable ["PLB_gpsOffSince", -1]) < 0) then { PLB_gpsOffSince = time; };
            if (time - PLB_gpsOffSince > 2.5) exitWith {PLB_gpsOffSince = -1;
                ["<t color='#00d4ff'>GPS:</t> recalculating...", "basic"] spawn life_fnc_handleMessage;
                ["set", _dest] call life_fnc_gps;};} else { PLB_gpsOffSince = -1; };

        // next turn: first 22deg+ bearing change ahead (severity classified from the angle)
        private _turnDist = -1;
        private _turnDir = 0;
        private _acc = _bd;
        for "_i" from (_best max 1) to (_n - 2) do {private _p0 = _pts select (_i - 1);
            private _p1 = _pts select _i;
            private _p2 = _pts select (_i + 1);
            _acc = _acc + (_p0 distance2D _p1);
            if (_acc > 1200) exitWith {};
            private _b1 = ((_p1 select 0) - (_p0 select 0)) atan2 ((_p1 select 1) - (_p0 select 1));
            private _b2 = ((_p2 select 0) - (_p1 select 0)) atan2 ((_p2 select 1) - (_p1 select 1));
            private _dv = ((_b2 - _b1 + 540) mod 360) - 180;
            if (abs _dv > 22 && {_acc > 15}) exitWith {_turnDist = _acc;
                _turnDir = _dv;};};

        // U-turn: the route continues BEHIND you (dead-end starts, wrong-way driving)
        private _uturn = false;
        if (_bd < 60 && {_best < _n - 2}) then {private _tgt = _pts select ((_best + 2) min (_n - 1));
            private _acc2 = 0;
            for "_i" from _best to ((_n - 2) min (_best + 20)) do {   // aim ~25m ahead
                _acc2 = _acc2 + ((_pts select _i) distance2D (_pts select (_i + 1)));
                if (_acc2 > 25) exitWith { _tgt = _pts select (_i + 1); };};
            private _brg = ((_tgt select 0) - (_me select 0)) atan2 ((_tgt select 1) - (_me select 1));
            private _dd = ((_brg - getDir vehicle player + 540) mod 360) - 180;
            _uturn = abs _dd > 120;};

        private _kmTxt = if (_remain >= 1000) then { format ["%1 km", (_remain / 1000) toFixed 1] } else { format ["%1 m", round _remain] };
        private _line = if (_uturn) then {
            "<t size='1.2' color='#00d4ff'>((</t>  <t size='1.1'>MAKE A U-TURN</t>"} else { if (_turnDist < 0) then {
            "<t size='1.2' color='#00d4ff'>/\</t>  <t size='1.1'>FOLLOW THE ROAD</t>"} else {
            // severity bands: 22-45 bear, 45-110 turn, 110+ sharp
            private _mag = abs _turnDir;
            private _sev = if (_mag < 45) then { 0 } else { if (_mag < 110) then { 1 } else { 2 } };
            private _verb = ["BEAR", "TURN", "SHARP"] select _sev;
            private _way = if (_turnDir < 0) then {
                format ["<t size='1.2' color='#00d4ff'>%1</t>  <t size='1.1'>%2 LEFT</t>", ["&lt;", "&lt;&lt;", "&lt;&lt;&lt;"] select _sev, _verb]
            } else {
                format ["<t size='1.1'>%2 RIGHT</t>  <t size='1.2' color='#00d4ff'>%1</t>", ["&gt;", "&gt;&gt;", "&gt;&gt;&gt;"] select _sev, _verb]
            };
            private _dTxt = if (_turnDist >= 1000) then { format ["%1 km", (_turnDist / 1000) toFixed 1] } else { format ["%1 m", 10 * ceil (_turnDist / 10)] };
            format ["%1  <t color='#9fb2c2'>in %2</t>", _way, _dTxt]} };
        private _ctrl = (uiNamespace getVariable ["PLB_GpsHud", displayNull]) displayCtrl 91510;
        if (!isNull _ctrl) then {
            _ctrl ctrlSetStructuredText parseText format ["%1<br/><t size='0.85' color='#7c8a98'>%2 to destination</t>", _line, _kmTxt];};
    };};
