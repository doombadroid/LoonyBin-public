/*
    File: fn_medicEarn.sqf  (LooneyBin)
    NG prestige earn helper. Call:  <amount> call life_fnc_medicEarn;
    Adds prestige points (life_medic_exp) for NG actions (revive / bloodbag / FAK / clearing
    wreckage / repairing houses / putting out fires) and saves via ClupdatePartial case 23.
    Independent-only so non-medics using a FAK/bloodbag don't earn NG prestige.
*/
params [["_amount", 0, [0]]];
if ((playerSide isEqualTo independent) && {!isNil "life_medic_exp"} && {_amount > 0}) then {life_medic_exp = life_medic_exp + _amount;
    // owner 2026-06-13 (#158): notify -- the grant was silent, so medics thought revives/narcan/bloodbag
    // gave no prestige. Spend it in the NG prestige tree (AEMT+).
    systemChat format["You've earned %1 NG prestige.", _amount];
    [23] call life_fnc_ClupdatePartial;};
