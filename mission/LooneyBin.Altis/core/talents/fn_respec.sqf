private _cost = call(life_respec_fee) * (count life_side_talents);
private _action = [format["<t align='center'>If you proceed you will unlearn %1 talent(s) for a total cost of $%2!</t>", count life_side_talents, [_cost] call life_fnc_numberText], "Unlearn Talents", "Yes", "No"] call BIS_fnc_guiMessage;
if !(_action) exitWith {};
if !([_cost] call life_fnc_debitCard) exitWith {};
life_side_talents = [];
["You have forgotten everything you knew.", "basic"] spawn life_fnc_handleMessage;
[4] call life_fnc_ClupdatePartial;