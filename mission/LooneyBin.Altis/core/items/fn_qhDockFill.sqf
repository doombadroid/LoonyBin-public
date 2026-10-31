// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only.
/*
    File: fn_qhDockFill.sqf  (life_fnc_qhDockFill) -- populate, run from the dialog onLoad
    LooneyBin 2026-07-22: ICEBREAKER / TAL OS VISOR DOCK -- replaces the SHIFT+Y radial with a bottom
    macOS-style magnifying dock, 1:1 with the mockup (scratchpad/vr_dock.html). HUD over the live world:
    baked translucent bar/card chrome + live overlays. The target is whatever the gaze reticle was on when
    you opened (PLB_cdTarget = cursorObject, set by the keybind). Slide the cursor to magnify, click the
    nearest tool to fire (routes to qhCast / the breach fns / the firewall editor), right-click to bail.
*/
if (!hasInterface) exitWith {};
disableSerialization;
private _d = uiNamespace getVariable ["vr_dock", displayNull];
if (isNull _d) exitWith {};
PLB_vrDockOpen = true;
private _cop = playerSide isEqualTo west;

// ---- theme ----
private _accH = if (_cop) then { "#f5a623" } else { "#c8f53a" };
private _utilH= if (_cop) then { "#54b0ff" } else { "#33ffbb" };
private _dangH= if (_cop) then { "#ff4d4d" } else { "#ff5a3c" };
private _inkH = if (_cop) then { "#e2ecf6" } else { "#e4f2e6" };
private _dimH = if (_cop) then { "#8090a0" } else { "#859089" };
PLB_vrToneRGB = createHashMapFromArray (if (_cop) then {[
    ["acc",[0.961,0.651,0.137,1]],["util",[0.329,0.69,1,1]],["danger",[1,0.302,0.302,1]]]} else {[
    ["acc",[0.784,0.961,0.227,1]],["util",[0.2,1,0.733,1]],["danger",[1,0.353,0.235,1]]]});
PLB_vrToneHex = createHashMapFromArray [["acc",_accH],["util",_utilH],["danger",_dangH]];
(_d displayCtrl 941302) ctrlSetText (if (_cop) then { "images\cyberdeck\vrdock_bar_tal.paa" } else { "images\cyberdeck\vrdock_bar_ice.paa" });
(_d displayCtrl 941303) ctrlSetText (if (_cop) then { "images\cyberdeck\vrdock_card_tal.paa" } else { "images\cyberdeck\vrdock_card_ice.paa" });

// ---- HUD strip ----
(_d displayCtrl 941304) ctrlSetStructuredText parseText format [
    "<t font='PuristaBold' color='%1'>NEON AEGEAN</t>   <t color='%2'>%3</t>   <t color='%4'>// QUICKHACK</t>",
    _accH, _utilH, (if (_cop) then { "TAL OS" } else { "ICEBREAKER OS" }), _dimH];
(_d displayCtrl 941305) ctrlSetStructuredText parseText format [
    "<t align='right' color='%1'>$%2      TRACE <t color='%3'>CLEAR</t>      DECK 64%%</t>",
    _inkH, [life_cash] call life_fnc_numberText, _accH];

(_d displayCtrl 941331) ctrlSetStructuredText parseText format ["<t align='center' color='%1'>SLIDE TO MAGNIFY  ·  CLICK TO UPLOAD</t>", (if (_cop) then { "#42505f" } else { "#4a5a51" })];
(_d displayCtrl 941330) ctrlShow false;

// ---- lock card geometry ----
// H-based sizing so 16:9 doesn't squeeze the panel under H-sized text (broke at 1920x1080 in the
// previewer). The card art carries a 20% halo margin on LEFT+BOTTOM (hard body = x[118,589] y[0,420]
// of 589x526): expand the control rect so the VISIBLE panel lands on the logical rect.
private _pxr = pixelW / pixelH;
private _cvH = 0.198 * safezoneH;
private _cvW = 0.320 * safezoneH * _pxr;                       // owner: elements larger -> wider panel so names fit
private _cvX = safezoneX + safezoneW - (0.152 * safezoneH * _pxr) - _cvW;
private _cvY = safezoneY + 0.19 * safezoneH;
private _ccW = _cvW / 0.80; private _ccH = _cvH / 0.80;        // CI_L = CI_B = 0.20
private _lockX = _cvX + 0.031*safezoneH*_pxr;
private _lockR = _cvX + _cvW - 0.031*safezoneH*_pxr;
(_d displayCtrl 941303) ctrlSetPosition [_cvX - _ccW*0.20, _cvY, _ccW, _ccH];
(_d displayCtrl 941320) ctrlSetPosition [_lockX, _cvY + 0.022*safezoneH, _lockR-_lockX, 0.024*safezoneH];
(_d displayCtrl 941321) ctrlSetPosition [_lockX, _cvY + 0.050*safezoneH, 0.036*safezoneH*_pxr, 0.036*safezoneH];
(_d displayCtrl 941322) ctrlSetPosition [_lockX + 0.062*safezoneH*_pxr, _cvY + 0.050*safezoneH, _lockR - _lockX - 0.062*safezoneH*_pxr, 0.072*safezoneH];
(_d displayCtrl 941323) ctrlSetPosition [_lockX, _cvY + 0.122*safezoneH, _lockR-_lockX, 0.034*safezoneH];
(_d displayCtrl 941324) ctrlSetPosition [_lockX, _cvY + _cvH - 0.042*safezoneH, _lockR-_lockX, 0.034*safezoneH];
{ (_d displayCtrl _x) ctrlCommit 0 } forEach [941303,941320,941321,941322,941323,941324];

// ---- lock card ----
private _tgt = missionNamespace getVariable ["PLB_cdTarget", objNull];
(_d displayCtrl 941320) ctrlSetStructuredText parseText format ["<t color='%1'>GAZE LOCK</t>", _dimH];
if (isNull _tgt) then {(_d displayCtrl 941321) ctrlSetText "";
    (_d displayCtrl 941322) ctrlSetStructuredText parseText format ["<t color='%1'>No lock</t>", _dimH];
    (_d displayCtrl 941323) ctrlSetStructuredText parseText format ["<t color='%1'>Aim at a target,<br/>then open the visor.</t>", _dimH];
    (_d displayCtrl 941324) ctrlSetStructuredText parseText "";} else {private _isMan = _tgt isKindOf "CAManBase";
    (_d displayCtrl 941321) ctrlSetText (if (_isMan) then { "images\cyberdeck\qicons\gdetain.paa" } else { "images\cyberdeck\qicons\gkill.paa" });
    (_d displayCtrl 941321) ctrlSetTextColor (PLB_vrToneRGB get "acc");
    private _nm = if (_isMan) then { name _tgt } else { getText (configOf _tgt >> "displayName") };
    private _kd = if (_isMan) then { "person" } else { "vehicle" };
    (_d displayCtrl 941322) ctrlSetStructuredText parseText format ["<t color='%1'>%2</t><br/><t size='0.8' color='%3'>%4 · %5 m</t>", _inkH, _nm, _accH, _kd, round (player distance _tgt)];
    private _r1 = if (_isMan) then { format ["STATUS<t align='right'>%1</t>", if ((vehicle _tgt) isEqualTo _tgt) then { "on foot" } else { "in vehicle" }] } else { format ["DRIVER<t align='right'>%1</t>", if (isNull (driver _tgt)) then { "empty" } else { name (driver _tgt) }] };
    (_d displayCtrl 941323) ctrlSetStructuredText parseText format ["<t color='%1'>%2</t>", _dimH, _r1];
    private _los = ([objNull,"VIEW"] checkVisibility [eyePos player, eyePos _tgt] > 0.3);
    (_d displayCtrl 941324) ctrlSetStructuredText parseText format ["<t color='%1'>[ %2 ]</t>  <t color='%3'>[ in range ]</t>", (if (_los) then { _utilH } else { _dangH }), (if (_los) then { "line of sight" } else { "no LOS" }), _utilH];
};

// ---- catalogue name/stats lookup ----
private _cat = [if (_cop) then { "cop" } else { "civ" }] call life_fnc_qhCfg;
if (!_cop) then { _cat = _cat + PLB_qhUtil; };
PLB_vrCat = _cat;

// ---- build items: [id, name, tone, kind, grp]  kind = cast | breach | fw ; grp = 0 offense / 1 breach / 2 guard
private _items = [];
private _load = call PLB_fnc_qhConsoleGet; {private _id = _x;
    if !(_id in ["unlock","house","atm","cuffs"]) then {private _row = (_cat select { (_x select 0) isEqualTo _id }) param [0, []];
        if (_row isNotEqualTo []) then { _items pushBack [_id, _row select 1, PLB_qhTone getOrDefault [_id,"acc"], "cast", 0]; };};
} forEach _load;
if (!_cop) then {{private _bid = _x;
        private _row = (_cat select { (_x select 0) isEqualTo _bid }) param [0, []];
        if (_row isNotEqualTo []) then { _items pushBack [_bid, _row select 1, "util", "breach", 1]; };
    } forEach ["unlock","house","atm","cuffs"];};
private _fwN = count (call PLB_fnc_fwEquipped);
_items pushBack ["firewall", format ["Firewall: %1/2", _fwN], "util", "fw", 2];

// ---- geometry (0-1 screen; icons square via pixelW/pixelH). The BAR hugs the icons (macOS/the render),
// centred at screen bottom-centre, so it never sprawls across an ultrawide. ----
private _iconH = 0.0385 * safezoneH;            // owner: dock smaller (was 0.048)
private _iconW = _iconH * (pixelW / pixelH);
private _spacing = _iconW * 1.15;
private _divGap  = _iconW * 0.72;

// span = distance first centre .. last centre
private _span = 0;
{ if (_forEachIndex > 0) then { _span = _span + _spacing; if ((_x select 4) isNotEqualTo ((_items select (_forEachIndex-1)) select 4)) then { _span = _span + _divGap; }; }; } forEach _items;

private _pad = _iconW * 0.85;
private _barH = _iconH * 1.8;                       // 1.5 let rest tiles poke out of the band
private _barCx = safezoneX + 0.5 * safezoneW;
private _barBottom = safezoneY + 0.985 * safezoneH;
private _barTop = _barBottom - _barH;
// bar/glow/tiles are positioned by PLB_fnc_vrMag (single layout codepath, called once at the end
// with a far-away cursor for the rest state, then on every MouseMoving)
private _accRGB = PLB_vrToneRGB get "acc";
(_d displayCtrl 941298) ctrlSetTextColor [_accRGB#0, _accRGB#1, _accRGB#2, 0.55];   // softened: full alpha read as a lawn strip
// caption sits just above the bar
(_d displayCtrl 941331) ctrlSetPosition [_barCx - 0.2*safezoneW, _barTop - 0.03*safezoneH, 0.4*safezoneW, 0.022*safezoneH];
(_d displayCtrl 941331) ctrlCommit 0;

private _iconBottom = _barBottom - _barH*0.28;      // 0.22 sat the rest row too high in the band
private _cx = _barCx - _span/2;

PLB_vrCx = []; PLB_vrData = []; PLB_vrIcons = []; PLB_vrGlyphs = []; PLB_vrToneArr = [];
PLB_vrDots = []; PLB_vrDivs = [];
if (isNil "PLB_vrExtra") then { PLB_vrExtra = [] };
{ ctrlDelete _x } forEach PLB_vrExtra; PLB_vrExtra = [];
private _idc = 941350; {_x params ["_id", "_name", "_tone", "_kind", "_grp"];
    if (_forEachIndex > 0 && {_grp isNotEqualTo ((_items select (_forEachIndex-1)) select 4)}) then {
        _cx = _cx + _divGap;                        // open the group gap
        private _dv = _d ctrlCreate ["Life_RscText", _idc]; _idc = _idc + 1;
        _dv ctrlSetBackgroundColor [0.5,0.6,0.55,0.35];
        _dv ctrlSetPosition [_cx - _divGap*0.5 - 0.0004*safezoneW, _iconBottom - _iconH*0.82, 0.0008*safezoneW, _iconH*0.7];
        _dv ctrlCommit 0; PLB_vrExtra pushBack _dv;
        PLB_vrDivs pushBack [_dv, _forEachIndex - 1, _forEachIndex];   // ticks track displaced neighbours
    };
    private _toneRGB = PLB_vrToneRGB getOrDefault [_tone, [1,1,1,1]];
    // dark rounded-square tile (baked dark, NOT tinted -- runtime tint over bright terrain made it glow;
    // only the glyph carries the tone)
    private _tile = _d ctrlCreate ["Life_RscPictureKeepAspect", _idc]; _idc = _idc + 1;
    _tile ctrlSetText "images\cyberdeck\vrtile.paa";
    _tile ctrlSetTextColor [1,1,1,1];
    _tile ctrlSetPosition [_cx - _iconW/2, _iconBottom - _iconH, _iconW, _iconH];
    _tile ctrlCommit 0;
    // glyph inset in the tile
    private _pic = _d ctrlCreate ["Life_RscPictureKeepAspect", _idc]; _idc = _idc + 1;
    _pic ctrlSetText format ["images\cyberdeck\qicons\%1.paa", PLB_qhIcon getOrDefault [_id, "gblank"]];
    _pic ctrlSetTextColor _toneRGB;
    private _gw = _iconW*0.56; private _gh = _iconH*0.56;
    _pic ctrlSetPosition [_cx - _gw/2, (_iconBottom - _iconH/2) - _gh/2, _gw, _gh];
    _pic ctrlCommit 0;
    // running-indicator dot (y static, x follows the displaced centre)
    private _dot = _d ctrlCreate ["Life_RscText", _idc]; _idc = _idc + 1;
    _dot ctrlSetBackgroundColor _toneRGB;
    _dot ctrlSetPosition [_cx - _iconW*0.03, _iconBottom + _iconH*0.055, _iconW*0.06, _iconH*0.06];
    _dot ctrlCommit 0; PLB_vrExtra pushBack _dot;
    PLB_vrDots pushBack _dot;
    PLB_vrIcons pushBack _tile;
    PLB_vrGlyphs pushBack _pic;
    PLB_vrCx pushBack _cx;
    PLB_vrToneArr pushBack _toneRGB;
    private _stat = "";
    private _row = (_cat select { (_x select 0) isEqualTo _id }) param [0, []];
    if (_row isNotEqualTo [] && {_kind isEqualTo "cast"}) then { _stat = format ["%1s up · %2s cd · %3m", _row select 5, _row select 6, _row select 7]; };
    if (_kind isEqualTo "breach") then { _stat = "breach tool · free"; };
    if (_kind isEqualTo "fw") then { _stat = "firewall chips"; };
    PLB_vrData pushBack [_id, _name, _tone, _kind, _stat];
    _cx = _cx + _spacing;} forEach _items;

PLB_vrGeo = [_iconH, _iconW, _iconBottom, _barTop, _pad, _barBottom, _barH];
PLB_vrSel = -1;

// ---- magnify + full dock layout (called on every mouse move; PLB_vrCx = REST centres) ----
PLB_fnc_vrMag = {params ["_mx"];
    disableSerialization;
    private _d = uiNamespace getVariable ["vr_dock", displayNull];
    if (isNull _d) exitWith {};
    (PLB_vrGeo) params ["_iconH", "_iconW", "_iconBottom", "_barTop", "_pad", "_barBottom", "_barH"];
    private _n = count PLB_vrIcons;
    private _boosts = []; private _widths = []; {private _dist = (abs (_mx - _x)) / _iconW;
        private _b = 0.9 * (2.71828 ^ (-(_dist*_dist) / (2*1.3*1.3)));
        _boosts pushBack _b; _widths pushBack (_iconW * (1 + _b));} forEach PLB_vrCx;
    // macOS push-apart: each growing icon shoves every other icon by half its growth, away from itself
    private _centres = [];
    for "_k" from 0 to (_n - 1) do {private _dsp = 0;
        for "_j" from 0 to (_n - 1) do {if (_j != _k) then {private _half = ((_widths select _j) - _iconW) / 2;
                _dsp = _dsp + (if ((PLB_vrCx select _k) > (PLB_vrCx select _j)) then { _half } else { -_half });};};
        _centres pushBack ((PLB_vrCx select _k) + _dsp);};
    // bar hugs the displaced row. Bar art halo margins (hard alpha): L 0.1005 / R 0.0995 / T 0.2554 of
    // the art -- expand the control rect so the VISIBLE band lands on the logical bar rect.
    private _liveL = (_centres select 0) - (_widths select 0)/2;
    private _liveR = (_centres select (_n-1)) + (_widths select (_n-1))/2;
    private _barW = (_liveR - _liveL) + 2*_pad;
    private _bw = _barW / 0.80;  private _bh = _barH / 0.7446;
    private _bx = (_liveL - _pad) - _bw * 0.1005;
    private _by = _barTop - _bh * 0.2554;
    (_d displayCtrl 941302) ctrlSetPosition [_bx, _by, _bw, _bh];
    (_d displayCtrl 941302) ctrlCommit 0;
    private _glowW = _barW * 1.1; private _glowH = _iconH * 1.25;
    (_d displayCtrl 941298) ctrlSetPosition [(_liveL + _liveR)/2 - _glowW/2, _barBottom - _glowH*0.5, _glowW, _glowH];
    (_d displayCtrl 941298) ctrlCommit 0;
    private _best = -1; private _bestB = -1; {private _boost = _boosts select _forEachIndex;
        private _cx = _centres select _forEachIndex;
        private _w = _widths select _forEachIndex; private _h = _iconH * (1 + _boost);
        private _cyc = (_iconBottom - _h/2) - (_boost * _iconH * 0.5);   // rise out of the bar
        _x ctrlSetPosition [_cx - _w/2, _cyc - _h/2, _w, _h];
        _x ctrlCommit 0;
        private _g = PLB_vrGlyphs select _forEachIndex;
        private _gw = _w*0.56; private _gh = _h*0.56;
        _g ctrlSetPosition [_cx - _gw/2, _cyc - _gh/2, _gw, _gh];
        private _br = 1 + _boost*0.4;                                    // glyph (not tile) brightens with focus
        private _tc = PLB_vrToneArr select _forEachIndex;
        _g ctrlSetTextColor [(_tc#0*_br) min 1, (_tc#1*_br) min 1, (_tc#2*_br) min 1, _tc#3];
        _g ctrlCommit 0;
        private _dot = PLB_vrDots select _forEachIndex;
        _dot ctrlSetPosition [_cx - _iconW*0.03, _iconBottom + _iconH*0.055, _iconW*0.06, _iconH*0.06];
        _dot ctrlCommit 0;
        if (_boost > _bestB) then { _bestB = _boost; _best = _forEachIndex; };} forEach PLB_vrIcons; {_x params ["_dv", "_li", "_ri"];
        private _bxm = (((_centres select _li) + (_widths select _li)/2) + ((_centres select _ri) - (_widths select _ri)/2)) / 2;
        _dv ctrlSetPosition [_bxm - 0.0004*safezoneW, _iconBottom - _iconH*0.82, 0.0008*safezoneW, _iconH*0.7];
        _dv ctrlCommit 0;} forEach PLB_vrDivs;
    PLB_vrSel = if (_bestB > 0.06) then { _best } else { -1 };
    private _tip = _d displayCtrl 941330;
    if (PLB_vrSel >= 0) then {(PLB_vrData select PLB_vrSel) params ["", "_nm", "_tone", "", "_stat"];
        // anchor above the RISEN tile top (fixed bar-relative offsets hid the stat line behind the tile)
        private _sb = _boosts select PLB_vrSel;
        private _tileTop = (_iconBottom - _iconH*(1 + _sb)) - (_sb * _iconH * 0.5);
        _tip ctrlSetPosition [(_centres select PLB_vrSel) - 0.2*safezoneW, _tileTop - 0.052*safezoneH, 0.4*safezoneW, 0.05*safezoneH];
        _tip ctrlSetStructuredText parseText format ["<t align='center' font='PuristaBold' color='%1'>%2</t><br/><t align='center' size='0.7' color='%3'>%4</t>", PLB_vrToneHex getOrDefault [_tone, "#c8f53a"], _nm, (if (playerSide isEqualTo west) then { "#8090a0" } else { "#859089" }), _stat];
        _tip ctrlCommit 0; _tip ctrlShow true;
        (_d displayCtrl 941331) ctrlShow false;} else { _tip ctrlShow false; (_d displayCtrl 941331) ctrlShow true; };};

// initial layout: far-away cursor = zero boost everywhere = the rest state
[safezoneX - 2] call PLB_fnc_vrMag;

// ---- wire the full-screen catcher ----
private _catch = _d displayCtrl 941301;
_catch ctrlAddEventHandler ["MouseMoving", { params ["", "_mx"]; [_mx] call PLB_fnc_vrMag; }];
_catch ctrlAddEventHandler ["MouseButtonDown", {params ["", "_btn"];
    if (_btn isEqualTo 1) exitWith { closeDialog 0; };
    if (PLB_vrSel < 0) exitWith {};
    (PLB_vrData select PLB_vrSel) params ["_id", "", "", "_kind"];
    closeDialog 0;
    switch (_kind) do {case "cast": { [_id] call life_fnc_qhCast; };
        case "breach": {[_id] spawn { params ["_id"]; uiSleep 0.1; private _bt = missionNamespace getVariable ["PLB_cdTarget", objNull];
                switch (_id) do { case "atm": { [_bt] spawn life_fnc_cyberdeckATM; }; case "cuffs": { [] spawn life_fnc_qhCuffHack; }; default { [_bt] spawn life_fnc_cyberdeck; }; }; };
        };
        case "fw": { [] spawn life_fnc_ringLoadout; };};}];
