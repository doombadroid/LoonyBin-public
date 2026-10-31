/*
    life_fnc_talentPointsRecv  (LooneyBin, owner 2026-07-16) -- server pushes the player's PURCHASED talent-point
    count (login load + after each buy). Stores it and recalculates the available-points pool.
*/
if (!hasInterface) exitWith {};
params [["_pts", 0, [0]]];
life_boughtTalents = _pts max 0;
[] call life_fnc_calTalents;
