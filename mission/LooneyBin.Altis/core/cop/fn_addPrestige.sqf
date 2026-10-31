params[["_unit", objNull, [objNull]], ["_amount", 0, [0]], ["_full", false, [false]]];
if (life_coprole isEqualTo "" || isNull _unit || !(playerSide isEqualTo west) || isNil "life_prestige" || isNil "life_cop_talents" || !(life_session_completed)) exitWith {};
if (_unit isEqualTo player && !(_full)) exitWith {};
if !(_full) then {private _multiplier =
    switch (call life_copLevel) do {case 7: {0.15};
        case 6: {0.15};
        case 5: {0.125};
        case 4: {0.075};
        case 3: {0.05};
        default {0};}; _amount = _amount * _multiplier;
    systemChat format["You've earned %1 prestige for the actions of %2.", _amount, name _unit];} else {
    systemChat format["You've earned %1 prestige.", _amount];};
life_prestige = life_prestige + _amount;
[16] call life_fnc_ClupdatePartial;