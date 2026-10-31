params[["_amount", 0, [0]]];
private _amount = round _amount;
if !(playerSide isEqualTo west) exitWith {};
private _toSend = allPlayers select {!(_x getVariable["plb_copRole", ""] isEqualTo "")};
[player, _amount] remoteExec["life_fnc_addPrestige", _toSend];
if (life_coprole isEqualTo "" || isNil "life_prestige" || !(life_session_completed)) exitWith {};
life_prestige = life_prestige + (_amount * 0.4);
systemChat format["You've earned %1 prestige.", (_amount * 0.4)];
[16] call life_fnc_ClupdatePartial;