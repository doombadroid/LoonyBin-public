// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only
/*
    File: fn_cyberdeckSeq.sqf
    LooneyBin 2026-07-18: SEQUENCE BREACH minigame (Cyberdeck, light targets).
    Baked deck art (dialog cyberdeck_seq, backdrop.paa) + live hex cells / 4x4 grid / radar flipbook / daemon.
    Match the BUFFER by clicking the matching code in the highlighted row before the trace drains.
    BLOCKING -- returns: 1 = breach, 0 = trace/timeout fail, -1 = aborted.
    Layout coords mirror scratchpad/build_cyberdeck_art.py (regenerate both together).
*/
params [["_bufLen", 4]];   // the buffer length IS the difficulty: 4 default, 6 basic, 10 medium/asylum, 12 advanced
disableSerialization;
// owner 2026-07-20: Breach Kit consumable -- if armed, auto-solve this breach (skip the minigame) and spend the charge.
if (plb_breachKitArmed) exitWith {plb_breachKitArmed = false;
    ["<t color='#c9e21a'>BREACH KIT</t> -- sequence auto-solved.", "basic"] spawn life_fnc_handleMessage;
    1};

private _cols = 4;
private _rows = 4;
_bufLen = _bufLen max 3;
_bufLen = _bufLen max 3 min 12;
private _timeLimit = round (_bufLen * 5 * (2/3));   // ~5s per code base, cut by 1/3 (owner 2026-07-21)
if (1 in (player getVariable ["plb_cdMods", []])) then { _timeLimit = _timeLimit + 4; };   // Overclock Module: +time

private _codes = ["1C","55","BD","E9","7A","FF","0A","3D","C4","9B"];
private _grid = [];
for "_i" from 0 to ((_cols * _rows) - 1) do { _grid pushBack (selectRandom _codes); };
private _allCols = []; for "_c" from 0 to (_cols - 1) do { _allCols pushBack _c; };

// CRITICAL: plant each buffer code into its ACTIVE row (idx % rows) in a DISTINCT column, so the required
// code is ALWAYS clickable in that row. A buffer longer than 4 wraps rows -- two codes in the same row must
// NEVER share a cell (the later plant would overwrite the earlier -> that code vanishes -> unhackable).
private _buffer = [];
private _usedCols = createHashMap;
for "_r" from 0 to (_bufLen - 1) do {private _row = _r % _rows;
    private _taken = _usedCols getOrDefault [_row, []];
    private _avail = _allCols - _taken;
    if (_avail isEqualTo []) then { _avail = +_allCols; };   // safety: rows are 4 wide, <=3 codes/row -> never hit
    private _col = selectRandom _avail;
    _taken pushBack _col;
    _usedCols set [_row, _taken];
    private _code = selectRandom _codes;
    _grid set [(_row * _cols) + _col, _code];
    _buffer pushBack _code;};
// belt-and-suspenders: guarantee every buffer code is findable in its row (force-place if somehow missing)
{private _row = _forEachIndex % _rows;
    private _inRow = false;
    for "_c" from 0 to (_cols - 1) do { if ((_grid select ((_row * _cols) + _c)) isEqualTo _x) exitWith { _inRow = true; }; };
    if (!_inRow) then { _grid set [(_row * _cols) + (floor random _cols), _x]; };} forEach _buffer;

plb_cbGrid = _grid;
plb_cbBuffer = _buffer;
plb_cbIdx = 0;
plb_cbRows = _rows;
plb_cbCols = _cols;
plb_cbResult = -1;
plb_cbDeadline = diag_tickTime + _timeLimit;

// shared render: buffer (target) + injected (entered) cells + active-row grid highlight
life_cbRender = {private _dlg = findDisplay 940000;
    if (isNull _dlg) exitWith {};
    private _idx = plb_cbIdx;
    private _activeRow = _idx % plb_cbRows;
    private _n = count plb_cbBuffer;
    for "_i" from 0 to 11 do {
        // BUFFER (target sequence; bright once reached, amber = current, dim = pending)
        private _bc = _dlg displayCtrl (940050 + _i);
        if (_i < _n) then {_bc ctrlShow true;
            _bc ctrlSetText (plb_cbBuffer select _i);
            if (_i < _idx) then {_bc ctrlSetTextColor [0.79, 0.89, 0.10, 1]; _bc ctrlSetBackgroundColor [0.09, 0.13, 0.05, 0.85];} else {
                if (_i isEqualTo _idx) then {_bc ctrlSetTextColor [1, 0.69, 0.13, 1]; _bc ctrlSetBackgroundColor [0.14, 0.12, 0.03, 0.9];
                } else {_bc ctrlSetTextColor [0.24, 0.29, 0.12, 1]; _bc ctrlSetBackgroundColor [0.05, 0.08, 0.03, 0.6];};};
        } else { _bc ctrlShow false; };
        // INJECTED (what you've entered so far)
        private _ic = _dlg displayCtrl (940070 + _i);
        if (_i < _idx) then {_ic ctrlShow true; _ic ctrlSetText (plb_cbBuffer select _i);
            _ic ctrlSetTextColor [0.79, 0.89, 0.10, 1]; _ic ctrlSetBackgroundColor [0.09, 0.13, 0.05, 0.7];} else {
            if (_i < _n) then { _ic ctrlShow true; _ic ctrlSetText ""; _ic ctrlSetBackgroundColor [0.05, 0.08, 0.03, 0.4]; }
            else { _ic ctrlShow false; };};};
    // GRID -- highlight the active row
    for "_i" from 0 to ((plb_cbRows * plb_cbCols) - 1) do {private _b = _dlg displayCtrl (940100 + _i);
        if ((floor (_i / plb_cbCols)) isEqualTo _activeRow) then {
            _b ctrlSetTextColor [0.82, 1, 0.28, 1]; _b ctrlSetBackgroundColor [0.28, 0.42, 0.08, 0.6];} else {
            _b ctrlSetTextColor [0.55, 0.63, 0.22, 1]; _b ctrlSetBackgroundColor [0.055, 0.08, 0.03, 0.55];};};};

closeDialog 0;
uiSleep 0.05;
if !(createDialog "cyberdeck_seq") exitWith { -1 };
private _dlg = findDisplay 940000;
if (isNull _dlg) exitWith { -1 };

for "_i" from 0 to ((_cols * _rows) - 1) do {private _b = _dlg displayCtrl (940100 + _i);
    _b ctrlSetText (_grid select _i);
    _b ctrlAddEventHandler ["ButtonClick", format ["[%1] call life_fnc_cyberdeckPick", _i]];};
call life_cbRender;

private _radar = _dlg displayCtrl 940200;
private _timer = _dlg displayCtrl 940010;
private _fill  = _dlg displayCtrl 940003;
private _fp = ctrlPosition _fill;   // resolved [x,y,fullW,h] -- aspect-correct; shrink width live

while { plb_cbResult isEqualTo -1 } do {if (isNull (findDisplay 940000)) exitWith { plb_cbResult = 2; };
    private _rem = plb_cbDeadline - diag_tickTime;
    if (_rem <= 0) exitWith { plb_cbResult = 0; };
    private _low = (_rem < 5);

    _timer ctrlSetStructuredText parseText format ["<t size='1.3' align='center' color='%1'>%2</t>",
        (if (_low) then { "#ff3b1e" } else { "#c9e21a" }), (_rem toFixed 2)];

    private _frac = (_rem / _timeLimit) max 0 min 1;
    _fill ctrlSetPosition [(_fp select 0), (_fp select 1), ((_fp select 2) * _frac), (_fp select 3)];
    _fill ctrlCommit 0;
    _fill ctrlSetBackgroundColor (if (_low) then { [1, 0.25, 0.1, 0.95] } else { [0.78, 0.89, 0.10, 0.95] });

    private _fr = floor ((diag_tickTime * 10) mod 16);
    private _fs = if (_fr < 10) then { format ["0%1", _fr] } else { str _fr };
    _radar ctrlSetText format ["images\cyberdeck\radar_%1.paa", _fs];

    if (plb_cbIdx >= (count plb_cbBuffer)) exitWith { plb_cbResult = 1; };
    uiSleep 0.05;};

private _won = (plb_cbResult isEqualTo 1);
if !(isNull (findDisplay 940000)) then {
    (_dlg displayCtrl 940201) ctrlSetText format ["images\cyberdeck\daemon_%1.paa", (["fail","win"] select _won)];
    _timer ctrlSetStructuredText parseText format ["<t size='1.2' align='center' color='%1'>%2</t>",
        (["#ff3b1e","#c9e21a"] select _won), (["FAIL","OK"] select _won)];
    uiSleep 1.1;
    closeDialog 0;};

switch (plb_cbResult) do {case 1: { 1 };
    case 0: { 0 };
    default { -1 };};
