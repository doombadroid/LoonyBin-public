params[["_amount", 0, [0]]];
private _success = false;
if (life_cash >= _amount) then {life_cash = (round(life_cash - _amount)) max 0;
    life_cashCacheB = ((life_cash / 4) + 9);
    systemChat format["You paid $%1 from cash on hand.", [_amount] call life_fnc_numberText];
    _success = true;} else {if (life_inv_debitcard > 0) then {if (life_atmcash < _amount) then {
            [format["You do not have $%1 in your bank account for this debit transaction.", [_amount] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
        } else {life_atmcash = (round(life_atmcash - _amount)) max 0;
            life_atmcashCacheB = ((life_atmcash / 4) + 11);
            systemChat format["You paid $%1 from your bank account using a debit card.", [_amount] call life_fnc_numberText];
            _success = true;};
        if (((A_stats_crimes param[0, 0]) > 500) && ((time - life_last_wanted) > 240)) then {life_last_wanted = time;
            private _toSend = allPlayers - [allDeadMen] select {
                ((side _x isEqualTo civilian && !(((_x getVariable["plb_myBounties", []]) findIf {getPlayerUID player in _x
                }) isEqualTo - 1)) || side _x isEqualTo west)};
            if !(_toSend isEqualTo[]) then {[
                    [9, profileName, str(A_stats_crimes select 0), player], "life_fnc_clientMessage", _toSend, false, false] spawn life_fnc_MP;
            };};} else {
        [format["You do not have $%1 in cash, nor do you have a debit card.", [_amount] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
    };};
_success;