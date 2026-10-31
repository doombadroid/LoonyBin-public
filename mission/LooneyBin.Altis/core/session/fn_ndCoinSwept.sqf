/*
    fn_ndCoinSwept.sqf  (life_fnc_ndCoinSwept)  — login coin-sweep toast.
    The server already converted the player's legacy loonycoin to wallet ND (see fn_queryRequest) and the
    new balance is in the login payload; this is the cosmetic "it happened" notice. Called via life_fnc_MP.
      [ coinCount ]
*/
params [["_n", 0, [0]]];
if (_n <= 0) exitWith {};
[format ["<t size='1.1' color='#5be39c'>%1 New Drachma</t><br/>Your %2 mined coin%3 converted to New Drachma.", [str _n] call PLB_fnc_ndText, _n, [".", "s."] select (_n != 1)], "basic"] spawn life_fnc_handleMessage;
