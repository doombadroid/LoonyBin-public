// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only
/*
    File: fn_ringLoadoutMode.sqf  (life_fnc_ringLoadoutMode)
    Flips the loadout editor between RING SLOTS (which 5 tools sit on the wheel) and FIREWALL
    (which 2 counter-chips are live). Two slots is the whole point -- nobody is immune to everything.
*/
PLB_ringLoadMode = if (isNil "PLB_ringLoadMode") then { 1 } else { 1 - PLB_ringLoadMode };
private _d = findDisplay 941400;
if (isNull _d) exitWith {};
(_d displayCtrl 941422) ctrlSetText (if (PLB_ringLoadMode isEqualTo 1) then { "MODE: FIREWALL" } else { "MODE: RING SLOTS" });
PLB_ringLoadSel = 0;
call life_fnc_ringLoadoutRefresh;
