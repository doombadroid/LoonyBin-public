if (life_inv_debitcard > 0) exitWith {["You already have a debit card.", "basic"] spawn life_fnc_handleMessage;};
if (life_atmcash < 0) exitWith {
    ["You don't have any money in your bank account, so why do you need a debit card?", "basic"] spawn life_fnc_handleMessage;};
[true, "debitcard", 1] call life_fnc_handleInv;
["You've obtained a brand new debit card. The letters aren't even worn off yet.", "basic"] spawn life_fnc_handleMessage;
closeDialog 0;