// life_fnc_jackpot -- LooneyBin: lottery jackpot winner receiver (restored 2026-06-11).
// Server PLB_fnc_addToLottery remoteExecs [ _amount ] here to the winning unit only.
// Body mirrors fn_lottoTix case 2 (win UI + bank credit + stat).
params [["_amount", 0, [0]]];
// Server-origin guard: this credits bank cash, so it must run ONLY when the server pushed
// it (remoteExecutedOwner 2). Without this a local call would self-credit an arbitrary jackpot
// (a positive delta always affords + persists via ClUpdatePartial). fn_lottoTix case 2 has the
// identical guard; this receiver was restored without it.
if (remoteExecutedOwner != 2) exitWith {};
if (_amount <= 0) exitWith {};
[format["<t color='#00BFFF'><t size='1'><t align='center'>Lottery Won!</t></t></t><br/>Congratulations! You won the $%1 lottery jackpot! The funds have been added to your bank account.", [_amount] call life_fnc_numberText], "lottoinfo"] spawn life_fnc_handleMessage;
life_atmcash = life_atmcash + _amount;
life_atmcashCacheB = ((life_atmcash / 4) + 11);
[1] call life_fnc_ClUpdatePartial;
["lottowin", _amount] call life_fnc_statArrUpdate;
