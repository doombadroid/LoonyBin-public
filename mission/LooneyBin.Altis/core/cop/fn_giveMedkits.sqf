if (playerSide isEqualTo civilian && (PLB_Server isEqualTo 1)) exitWith {};
[] call life_fnc_calWeight;
private _num = missionNamespace getVariable(format["life_inv_%1", "firstAidKit"]);
private _amount =
switch (true) do {case (_num >= 4): {0};
    case (_num isEqualTo 3): {1};
    case (_num isEqualTo 2): {2};
    case (_num isEqualTo 1): {3};
    case (_num isEqualTo 0): {4};}; if ((life_maxWeight - life_carryWeight) < _amount) exitWith {};
if (_amount in [1, 2, 3, 4]) then {[true, "firstAidKit", _amount] call life_fnc_handleInv;};