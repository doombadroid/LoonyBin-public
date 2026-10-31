// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only.
/*
    File: fn_qhConsoleLoad.sqf  (life_fnc_qhConsoleLoad)
    LooneyBin 2026-07-22: tap a library chip -> toggle it in/out of the 6-slot loadout, 1:1 with the render's
    handler: already loaded -> remove; not loaded -> append, and if the six are full, drop the oldest first.
    IDs only, persisted (profileNamespace, security.md). Redraws tiles + chips.
*/
if (!hasInterface) exitWith {};
params [["_id", "", [""]]];
if (_id isEqualTo "") exitWith {};
private _i = PLB_qhConsoleLoad find _id;
if (_i > -1) then {PLB_qhConsoleLoad deleteAt _i;} else {if (count PLB_qhConsoleLoad >= 6) then { PLB_qhConsoleLoad deleteAt 0; };
    PLB_qhConsoleLoad pushBack _id;};
[PLB_qhConsoleLoad] call PLB_fnc_qhConsoleSave;
call PLB_fnc_qhConsoleTiles;
call PLB_fnc_qhConsoleChips;
