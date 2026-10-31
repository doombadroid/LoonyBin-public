// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only.
/*
    File: fn_qhConsolePick.sqf  (life_fnc_qhConsolePick)
    LooneyBin 2026-07-22: lock a target from the scope's switch bar (the render's tap-to-pick). Sets PLB_cdTarget
    (the same lock fn_qhCast reads), paints the TARGET SCOPE overlays 1:1 with the render, and re-states the tiles
    so wrong-kind hacks grey out. Index is into PLB_qhConsoleTargets (the 4 nearest).
*/
if (!hasInterface) exitWith {};
params [["_idx", 0, [0]]];
disableSerialization;
private _d = uiNamespace getVariable ["qh_console", displayNull];
if (isNull _d) exitWith {};
PLB_qhConsoleSel = _idx;
private _t = PLB_qhConsoleTargets param [_idx, objNull];

// v2: selection wash on the active NEARBY row + tint rows (selected acc, rest ink/dim)
private _accRGB = PLB_qhcRGB getOrDefault ["acc", [1,1,1,1]];
private _S = 1.2;   // MUST match QS in qh_console.hpp
private _GW = 2.5 * pixelW * pixelGrid; private _GH = 2.5 * pixelH * pixelGrid; private _GX = 0.5; private _GY = 0.5;
private _sel = _d displayCtrl 941529;
if (!isNull (PLB_qhConsoleTargets param [_idx, objNull])) then {(PLB_qhcRows param [_idx, [0,0,0,0]]) params ["_rx", "_ry", "_rw", "_rh"];
    _sel ctrlSetPosition [_rx*_S*_GW + _GX, _ry*_S*_GH + _GY, _rw*_S*_GW, _rh*_S*_GH];
    _sel ctrlSetBackgroundColor [_accRGB#0, _accRGB#1, _accRGB#2, 0.10];} else { _sel ctrlSetPosition [0,0,0,0]; };
_sel ctrlCommit 0; {private _row = PLB_qhConsoleTargets param [_forEachIndex, objNull];
    private _on = (_forEachIndex isEqualTo _idx) && {!isNull _row};
    if (!isNull _row) then {private _rMan = _row isKindOf "CAManBase";
        private _lbl = if (_rMan) then { name _row } else { getText (configOf _row >> "displayName") };
        (_d displayCtrl (941524 + _forEachIndex)) ctrlSetStructuredText parseText format ["<t color='%1'>%2</t>", (if (_on) then { PLB_qhc get "acc" } else { PLB_qhc get "ink" }), _lbl];
        (_d displayCtrl (941532 + _forEachIndex)) ctrlSetStructuredText parseText format ["<t align='right' color='%1'>%2 m</t>", (if (_on) then { PLB_qhc get "acc" } else { PLB_qhc get "dim" }), round (player distance _row)];
        (_d displayCtrl (941536 + _forEachIndex)) ctrlSetTextColor (if (_on) then { _accRGB } else { [0.55,0.62,0.58,1] });};
} forEach [0,1,2,3];

if (isNull _t) exitWith {PLB_cdTarget = objNull;
    (_d displayCtrl 941506) ctrlSetText "";
    (_d displayCtrl 941511) ctrlSetStructuredText parseText format ["<t color='%1'>No lock</t>", PLB_qhc get "dim"];
    { (_d displayCtrl _x) ctrlSetStructuredText parseText ""; } forEach [941512,941513,941514,941515,941516];
    call PLB_fnc_qhConsoleTiles;};
PLB_cdTarget = _t;

private _isMan = _t isKindOf "CAManBase";
private _dist = round (player distance _t);
private _accH = PLB_qhc get "acc"; private _dimH = PLB_qhc get "dim"; private _inkH = PLB_qhc get "ink"; private _goodH = PLB_qhc get "util"; private _hotH = PLB_qhc get "danger";

// reticle icon (tinted)
(_d displayCtrl 941506) ctrlSetText (if (_isMan) then { "images\cyberdeck\qicons\gdetain.paa" } else { "images\cyberdeck\qicons\gkill.paa" });
(_d displayCtrl 941506) ctrlSetTextColor _accRGB;

// name + meta line (v2: kind and distance merged under the name; 941513 parked)
private _nm = if (_isMan) then { name _t } else { getText (configOf _t >> "displayName") };
(_d displayCtrl 941511) ctrlSetStructuredText parseText format ["<t color='%1'>%2</t>", _inkH, _nm];
private _kind = if (_isMan) then { if ((side group _t) isEqualTo west) then { "APD" } else { "person" } } else { "vehicle" };
(_d displayCtrl 941512) ctrlSetStructuredText parseText format ["<t color='%1'>%2 · %3 m</t>", _accH, _kind, _dist];
(_d displayCtrl 941513) ctrlSetStructuredText parseText "";

// L2 label/value
private _l2l = if (_isMan) then { "STATUS" } else { "DRIVER" };
private _l2v = if (_isMan) then {
    if (vehicle _t isEqualTo _t) then { "on foot" } else { format ["in %1", getText (configOf (vehicle _t) >> "displayName")] }} else {
    if (isNull (driver _t)) then { "empty" } else { name (driver _t) }};
(_d displayCtrl 941514) ctrlSetStructuredText parseText format ["<t color='%1'>%2</t>", _dimH, _l2l];
(_d displayCtrl 941515) ctrlSetStructuredText parseText format ["<t align='right' color='%1'>%2</t>", _inkH, _l2v];

// flags: LOS + wanted (person) / crew (vehicle)
private _flags = [];
if ([objNull, "VIEW"] checkVisibility [eyePos player, eyePos _t] > 0.3) then { _flags pushBack format ["<t color='%1'>line of sight</t>", _goodH]; } else { _flags pushBack format ["<t color='%1'>no LOS</t>", _hotH]; };
if (_isMan) then {
    if (!( (_t getVariable ["wantedLevel", 0]) isEqualTo 0 ) || {!( (_t getVariable ["life_wantedbounty", 0]) isEqualTo 0 )}) then { _flags pushBack format ["<t color='%1'>wanted</t>", _hotH]; };
} else {_flags pushBack format ["<t color='%1'>%2 aboard</t>", _dimH, count (crew _t)];};
(_d displayCtrl 941516) ctrlSetStructuredText parseText ((_flags apply { format ["[ %1 ]", _x] }) joinString "  ");

call PLB_fnc_qhConsoleTiles;
