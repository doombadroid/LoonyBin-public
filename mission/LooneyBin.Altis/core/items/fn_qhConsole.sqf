// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only.
/*
    File: fn_qhConsole.sqf  (life_fnc_qhConsole)
    LooneyBin 2026-07-22: ICEBREAKER OS (civ) / TAL OS (cop) QUICKHACK CONSOLE -- fire quickhacks from the phone
    app with no VR goggles. Built 1:1 against the approved deck render (scratchpad/deck_apps.html): the chassis
    is a baked backdrop (deck_ice|tal.paa) and this fills the live overlays measured from that render.
    Firing routes through the untouched authority path: sets PLB_cdTarget then life_fnc_qhCast -> TON_fnc_qhSRV.
*/
if (!hasInterface) exitWith {};
disableSerialization;
private _d = uiNamespace getVariable ["qh_console", displayNull];
if (isNull _d) exitWith {};
PLB_qhConsoleOpen = true;
private _cop = playerSide isEqualTo west;
PLB_qhcCop = _cop;

// ---- theme (hex for structured text) ----
PLB_qhc = createHashMapFromArray (if (_cop) then {[
    ["acc","#f5a623"],["util","#54b0ff"],["danger","#ff4d4d"],["dim","#7d8b9e"],["ink","#dbe6f2"],["faint","#3c4a5c"],["acc2","#54b0ff"]
]} else {[
    ["acc","#c8f53a"],["util","#33ffbb"],["danger","#ff5a3c"],["dim","#7f938a"],["ink","#dcefe0"],["faint","#465a51"],["acc2","#33ffbb"]
]});
PLB_qhcRGB = createHashMapFromArray (if (_cop) then {[["acc",[0.961,0.651,0.137,1]],["util",[0.329,0.69,1,1]],["danger",[1,0.302,0.302,1]]
]} else {[["acc",[0.784,0.961,0.227,1]],["util",[0.2,1,0.733,1]],["danger",[1,0.353,0.235,1]]]});
(_d displayCtrl 941504) ctrlSetText (if (_cop) then { "images\cyberdeck\deck_tal.paa" } else { "images\cyberdeck\deck_ice.paa" });

// ---- catalogue + tone map (matches the render's per-item tone) ----
// 0.2.0: the LIBRARY lists only hacks you've UNLOCKED -- a civ hack's chip (reqMod, catalogue field 13)
// must be installed in plb_cdMods. Cop hacks + anything with reqMod -1 have no chip and always show.
PLB_qhConsoleCat = ([if (_cop) then { "cop" } else { "civ" }] call life_fnc_qhCfg) select {private _rm = _x param [12, -1];
    (_rm isEqualTo -1) || {_rm in (player getVariable ["plb_cdMods", []])}};
if (!_cop) then { PLB_qhConsoleCat = PLB_qhConsoleCat + PLB_qhUtil; };   // civ: breach tools (car/house/ATM/cuffs) loadable too
PLB_qhTone = createHashMapFromArray [
    ["ping","acc"],["static","acc"],["whiteout","acc"],["sticky","acc"],["synapse","acc"],["distract","util"],
    ["plateghost","util"],["jam","util"],["wiretap","util"],["crybaby","util"],["leech","util"],["short","danger"],
    ["eyespy","util"],["chauffeur","danger"],["valet","util"],["gridout","util"],["flatline","danger"],["memhole","danger"],["puppet","danger"],
    ["pursuit","util"],["pa","acc"],["dazzle","acc"],["silence","acc"],["interlock","acc"],["blackout","acc"],["warranttap","util"],["decoy","util"],["recall","util"],
    ["unlock","util"],["house","util"],["atm","util"],["cuffs","danger"]];
// id -> artifact SVG glyph (baked to images\cyberdeck\qicons\<glyph>.paa). Ids the render had map exactly;
// the rest map to the closest artifact glyph.
PLB_qhIcon = createHashMapFromArray [
    ["ping","gping"],["distract","gjam"],["static","gstatic"],["whiteout","gwhiteout"],["sticky","gsticky"],
    ["plateghost","gplate"],["jam","gjam"],["wiretap","gwiretap"],["crybaby","gwiretap"],["synapse","gsynapse"],
    ["leech","gleech"],["short","gshort"],["eyespy","geye"],["chauffeur","gvalet"],["valet","gvalet"],
    ["gridout","gjam"],["flatline","gflatline"],["memhole","gmem"],["puppet","gpuppet"],
    ["pursuit","gping"],["pa","gwhiteout"],["dazzle","gstatic"],["silence","gwhiteout"],["interlock","gsafestop"],
    ["blackout","gjam"],["warranttap","gwiretap"],["decoy","gdecoy"],["recall","gvalet"],
    ["unlock","gcarlock"],["house","ghouse"],["atm","gatm"],["cuffs","gcuffs"]];

// ---- status strip (right): cash / clock / count ----
(_d displayCtrl 941502) ctrlSetStructuredText parseText format ["<t align='right' color='%2'>$%1     <t color='%3'>%4</t></t>",
    [life_cash] call life_fnc_numberText, (PLB_qhc get "ink"), (PLB_qhc get "acc"), (if (_cop) then { "ON DUTY" } else { "GHOST" })];

PLB_qhConsoleLoad = call PLB_fnc_qhConsoleGet;

// ---- format helpers ----
PLB_fnc_qhcCd = { params ["_cd"]; if (_cd <= 0) then { "--" } else { if (_cd >= 60) then { format ["%1m", _cd / 60] } else { format ["%1s", _cd] } } };
PLB_fnc_qhcRng = { params ["_r"]; if (_r > 900) then { "--" } else { format ["%1m", _r] } };

// ---- target-kind validity (mirror of fn_qhCast, for the tile state) ----
PLB_fnc_qhcValid = {params ["_kind"];
    private _t = missionNamespace getVariable ["PLB_cdTarget", objNull];
    if (_kind isEqualTo "area") exitWith { true };
    if ((_kind select [0,6]) isEqualTo "breach") exitWith { true };   // breach tools do their own target check on cast
    if (isNull _t) exitWith { false };
    switch (_kind) do {case "player": { (_t isKindOf "CAManBase") && {isPlayer _t} && {_t isNotEqualTo player} };
        case "vehicle";
        case "anyveh";
        case "drivable";
        case "occupied": { private _v = if (_t isKindOf "CAManBase") then { vehicle _t } else { _t }; (_v isKindOf "Car") || (_v isKindOf "Air") || (_v isKindOf "Ship") || (_v isKindOf "Tank") };
        default { false };};};

// ---- TILE RENDER (6 loadout tiles) ----
PLB_fnc_qhConsoleTiles = {disableSerialization;
    private _d = uiNamespace getVariable ["qh_console", displayNull];
    if (isNull _d) exitWith {};
    private _cat = PLB_qhConsoleCat; {private _id = PLB_qhConsoleLoad param [_forEachIndex, ""];
        private _row = (_cat select { (_x select 0) isEqualTo _id }) param [0, []];
        private _ic = _d displayCtrl (941540 + _forEachIndex);
        private _nm = _d displayCtrl (941550 + _forEachIndex);
        private _bl = _d displayCtrl (941560 + _forEachIndex);
        private _ft = _d displayCtrl (941570 + _forEachIndex);
        private _fr = _d displayCtrl (941580 + _forEachIndex);
        if (_row isEqualTo []) then {
            _ic ctrlSetText ""; _nm ctrlSetStructuredText parseText ""; _bl ctrlSetStructuredText parseText format ["<t align='center' color='%1'>EMPTY SLOT</t>", PLB_qhc get "faint"]; _ft ctrlSetStructuredText parseText ""; _fr ctrlSetStructuredText parseText "";
        } else {_row params ["", "_name", "_blurb", "_icon", "", "_up", "_cd", "_rng", "", "", "_kind"];
            private _tone = PLB_qhTone getOrDefault [_id, "acc"];
            private _tc = PLB_qhc get _tone;
            _ic ctrlSetText format ["images\cyberdeck\qicons\%1.paa", PLB_qhIcon getOrDefault [_id, "gblank"]];
            _ic ctrlSetTextColor (PLB_qhcRGB getOrDefault [_tone, [1,1,1,1]]);
            _nm ctrlSetStructuredText parseText format ["<t color='%1'>%2</t>", PLB_qhc get "ink", _name];
            // state: cooling / invalid / ready
            private _cdKey = "plb_qhCd_" + _id;
            private _left = (missionNamespace getVariable [_cdKey, 0]) - diag_tickTime;
            private _valid = [_kind] call PLB_fnc_qhcValid;
            private _fireTxt = "FIRE"; private _fireCol = _tc;
            if (_left > 0) then {
                _bl ctrlSetStructuredText parseText format ["<t color='%1'>recharging %2s</t>", PLB_qhc get "faint", ceil _left];
                _fireTxt = "WAIT"; _fireCol = PLB_qhc get "faint";} else {if (!_valid) then {
                    private _why = if (_kind isEqualTo "player") then { "NEED A PERSON" } else { "NEED A VEHICLE" };
                    _bl ctrlSetStructuredText parseText format ["<t color='%1'>%2</t>", PLB_qhc get "danger", _why];
                    _fireTxt = "N/A"; _fireCol = PLB_qhc get "danger";} else {
                    _bl ctrlSetStructuredText parseText format ["<t color='%1'>%2</t>", PLB_qhc get "dim", _blurb];};};
            _ft ctrlSetStructuredText parseText format ["<t color='%1'>%2s up  ·  %3 cd  ·  %4</t>", PLB_qhc get "faint", _up, [_cd] call PLB_fnc_qhcCd, [_rng] call PLB_fnc_qhcRng];
            _fr ctrlSetStructuredText parseText format ["<t align='right' color='%1'>%2</t>", _fireCol, _fireTxt];};
    } forEach [0,1,2,3,4,5];};

// ---- LIBRARY chips (dynamic flow inside the baked lib panel) ----
PLB_fnc_qhConsoleChips = {disableSerialization;
    private _d = uiNamespace getVariable ["qh_console", displayNull];
    if (isNull _d) exitWith {};
    if (isNil "PLB_qhConsoleChipCtrls") then { PLB_qhConsoleChipCtrls = [] };
    { ctrlDelete _x } forEach PLB_qhConsoleChipCtrls;
    PLB_qhConsoleChipCtrls = [];
    // libgrid bounds (cells, from the render) scaled by _S -- MUST match QS in qh_console.hpp
    private _S = 1.2;
    // UI_GRID_* are config macros -- undefined in SQF. Compute the grid from engine commands for ctrlSetPosition.
    private _GW = 2.5 * pixelW * pixelGrid; private _GH = 2.5 * pixelH * pixelGrid; private _GX = 0.5; private _GY = 0.5;
    private _x0 = -5.422*_S; private _y0 = 3.259*_S; private _right = (-5.422 + 18.904)*_S; private _bottom = (3.259 + 5.348)*_S;
    private _cx = _x0; private _cy = _y0; private _pitch = 1.02*_S; private _idc = 942000;
    // one off-screen measure ctrl: ctrlCreate z-order is CREATION order, so the visible name ctrl must
    // be created after its bg card -- measure real rendered widths here instead of guessing per-char
    // (the guess clipped long names at BOTH ends: RscActiveText centres its text)
    private _meas = _d ctrlCreate ["Life_RscActiveText", 941999];
    _meas ctrlSetPosition [-2, -2, 2, 0.889*_S*_GH];
    _meas ctrlSetFontHeight 0.56*_S*_GH;
    _meas ctrlCommit 0; {_x params ["_id", "_name", "_blurb", "_icon"];
        private _tone = PLB_qhTone getOrDefault [_id, "acc"];
        private _loaded = _id in PLB_qhConsoleLoad;
        _meas ctrlSetText _name;
        private _twC = (ctrlTextWidth _meas) / _GW;                  // rendered width in grid cells
        if (_twC <= 0) then { _twC = 0.20 * (count toArray _name) * _S; };   // engine fallback
        private _cw = (0.86*_S + _twC + 0.30*_S) max (2.2*_S);
        if (_cx + _cw > _right) then { _cx = _x0; _cy = _cy + _pitch; };
        if (_cy + 0.889*_S > _bottom + 0.4*_S) exitWith {};          // out of room -> stop
        // bg card (bottom)
        private _bg = _d ctrlCreate ["Life_RscText", _idc];
        _bg ctrlSetPosition [_cx*_GW + _GX, _cy*_GH + _GY, _cw*_GW, 0.889*_S*_GH];
        _bg ctrlSetBackgroundColor (if (_loaded) then {[0.05,0.08,0.065,0.3]} else {[0.055,0.10,0.082,0.7]});
        _bg ctrlSetTooltip _blurb;                                   // 0.2.0: hover any part of a library card for what the hack does
        _bg ctrlCommit 0;
        // icon
        private _pic = _d ctrlCreate ["Life_RscPictureKeepAspect", _idc + 1];
        _pic ctrlSetPosition [(_cx + 0.16*_S)*_GW + _GX, (_cy + 0.19*_S)*_GH + _GY, 0.52*_S*_GW, 0.52*_S*_GH];
        _pic ctrlSetText format ["images\cyberdeck\qicons\%1.paa", PLB_qhIcon getOrDefault [_id, "gblank"]];
        _pic ctrlSetTextColor (PLB_qhcRGB getOrDefault [_tone, [1,1,1,1]]);
        _pic ctrlSetTooltip _blurb;
        _pic ctrlCommit 0;
        // name = clickable active text (no button skin), sized to the measured text
        private _txt = _d ctrlCreate ["Life_RscActiveText", _idc + 2];
        _txt ctrlSetPosition [(_cx + 0.74*_S)*_GW + _GX, _cy*_GH + _GY, (_cw - 0.86*_S)*_GW, 0.889*_S*_GH];
        _txt ctrlSetText _name;
        _txt ctrlSetFontHeight 0.56*_S*_GH;
        _txt ctrlSetTextColor (if (_loaded) then { PLB_qhcRGB getOrDefault ["acc",[1,1,1,1]] } else { [0.86,0.9,0.87,1] });
        _txt ctrlAddEventHandler ["ButtonClick", compile format ["['%1'] call life_fnc_qhConsoleLoad", _id]];   // ctrlSetVariable doesn't exist here -> bake the id in
        _txt ctrlSetTooltip _blurb;
        _txt ctrlCommit 0;
        PLB_qhConsoleChipCtrls append [_bg, _pic, _txt];
        _cx = _cx + _cw + 0.24*_S;
        _idc = _idc + 3;} forEach PLB_qhConsoleCat;
    ctrlDelete _meas;};

// ---- NEARBY SCAN -> v2 target list rows (nearest 4), lock nearest ----
// row plates are baked; glyph 941536+, name 941524+, dist 941532+ are live; Sw hit buttons sit on top
PLB_fnc_qhConsoleScan = {disableSerialization;
    private _d = uiNamespace getVariable ["qh_console", displayNull];
    if (isNull _d) exitWith {};
    private _prev = PLB_qhConsoleTargets param [PLB_qhConsoleSel, objNull];
    private _found = [];
    { if (alive _x && {isPlayer _x} && {_x isNotEqualTo player}) then { _found pushBackUnique _x }; } forEach (player nearEntities [["CAManBase"], 220]);
    { if (alive _x && {(_x isKindOf "Car") || (_x isKindOf "Air") || (_x isKindOf "Ship") || (_x isKindOf "Tank")} && {_x isNotEqualTo (vehicle player)}) then { _found pushBackUnique _x }; } forEach (nearestObjects [player, ["Car","Air","Ship","Tank"], 220]);
    _found = [_found, [], { player distance _x }, "ASCEND"] call BIS_fnc_sortBy;
    if (count _found > 4) then { _found resize 4 };
    PLB_qhConsoleTargets = _found; {private _isMan = _x isKindOf "CAManBase";
        private _lbl = if (_isMan) then { name _x } else { getText (configOf _x >> "displayName") };
        (_d displayCtrl (941536 + _forEachIndex)) ctrlSetText (if (_isMan) then { "images\cyberdeck\qicons\gdetain.paa" } else { "images\cyberdeck\qicons\gvalet.paa" });
        (_d displayCtrl (941524 + _forEachIndex)) ctrlSetStructuredText parseText format ["<t color='%1'>%2</t>", PLB_qhc get "ink", _lbl];
        (_d displayCtrl (941532 + _forEachIndex)) ctrlSetStructuredText parseText format ["<t align='right' color='%1'>%2 m</t>", PLB_qhc get "dim", round (player distance _x)];
    } forEach _found;
    for "_i" from (count _found) to 3 do {(_d displayCtrl (941536 + _i)) ctrlSetText "";
        (_d displayCtrl (941524 + _i)) ctrlSetStructuredText parseText "";
        (_d displayCtrl (941532 + _i)) ctrlSetStructuredText parseText "";};
    if (_found isEqualTo []) then {
        (_d displayCtrl 941524) ctrlSetStructuredText parseText format ["<t color='%1'>-- none in range --</t>", PLB_qhc get "faint"];};
    // keep prior lock if still present, else nearest
    private _keep = _found find _prev;
    PLB_qhConsoleSel = if (_keep >= 0) then { _keep } else { 0 };
    [PLB_qhConsoleSel] call life_fnc_qhConsolePick;};

// ---- v2 footer strip (rule is baked) ----
(_d displayCtrl 941530) ctrlSetStructuredText parseText format ["<t color='%1'>UPLINK READY</t>", PLB_qhc get "util"];
(_d displayCtrl 941531) ctrlSetStructuredText parseText format ["<t align='right' color='%1'>TRACE CLEAR</t>", PLB_qhc get "dim"];
// NEARBY row rects in bake cells (x,y,w,h) for the selection wash -- keep in sync with qh_console.hpp
PLB_qhcRows = [[-14.756,2.230,8.119,1.244],[-14.756,3.681,8.119,1.244],[-14.756,5.133,8.119,1.244],[-14.756,6.585,8.119,1.244]];

PLB_qhConsoleTargets = [];
PLB_qhConsoleSel = 0;
PLB_qhConsoleChipCtrls = [];
call PLB_fnc_qhConsoleTiles;
call PLB_fnc_qhConsoleScan;   // paints scope + locks nearest target
call PLB_fnc_qhConsoleChips;  // last: dynamic ctrlCreate, so it can never block the scope/tiles/target list

// ---- refresh loop while open ----
[] spawn {while { !isNull findDisplay 941500 } do {uiSleep 1.5;
        if (isNull findDisplay 941500) exitWith {};
        call PLB_fnc_qhConsoleScan;
        call PLB_fnc_qhConsoleTiles;};};
