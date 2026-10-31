// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only
/*
    File: fn_talHomeLaunch.sqf  (life_fnc_talHomeLaunch)
    LooneyBin 2026-07-20: TAL OS app-grid tile dispatcher. Closes the terminal first (the cursor-reading
    tools need the aim back) then runs the tool. Tile index == life_fnc_talAction id.
*/
params [["_id", -1, [0]]];
if (_id < 0 || {_id > 7}) exitWith {};
closeDialog 0;
[_id] spawn life_fnc_talAction;
