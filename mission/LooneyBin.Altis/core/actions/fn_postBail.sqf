params[["_unit", objNull, [objNull]]];
if (life_bail_paid) exitWith {};
if (isNil {"life_bail_amount"}) then {life_bail_amount = 3500;};
if (life_atmcash < life_bail_amount) exitWith {
    systemChat format["You do not have $%1 in your bank account to pay bail.", life_bail_amount];};
private _action = [format["Do you wish to pay $%1 to be release from jail?", [life_bail_amount] call life_fnc_numberText], "Pay Bail", "Yes", "No"] call BIS_fnc_guiMessage;
if !(_action) exitWith {};
life_atmcash = life_atmcash - life_bail_amount;
life_atmcashCacheB = ((life_atmcash / 4) + 11);
[1] call life_fnc_ClUpdatePartial;
life_bail_paid = true; [[0, format["%1 has posted bail!", name _unit]], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
["moneyspentbail", life_bail_amount] call life_fnc_statArrUpdate;