// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only.
/*
    File: fn_qhDock.sqf  (life_fnc_qhDock)
    LooneyBin 2026-07-22: VISOR DOCK launcher -- replaces life_fnc_cyberdeckRing on SHIFT+Y. Enforces the same
    gate as the ring (VR goggles + illegal firmware, or APD), captures the gaze target, then opens the dock.
    The dialog onLoad fills it (life_fnc_qhDockFill).
*/
if (!hasInterface) exitWith {};
if (!alive player) exitWith {};
if (dialog) exitWith {};
private _cop = playerSide isEqualTo west;
if !((goggles player) isEqualTo "G_Goggles_VR") exitWith {
    ["You need your VR goggles on for the visor overlay.", "basic"] spawn life_fnc_handleMessage;};
if (!_cop && {!(call PLB_fnc_hasDeck)}) exitWith {
    ["No deck firmware. Flash it at an electronics shop first.", "basic"] spawn life_fnc_handleMessage;};
if (!isNull (findDisplay 941300)) exitWith {};
PLB_cdTarget = cursorObject;
createDialog "vr_dock";
