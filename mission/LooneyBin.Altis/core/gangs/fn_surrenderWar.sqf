private _enemyGang = parseNumber(lbData[9581, lbCurSel 9581]);
if (life_gang_data isEqualTo[]) exitWith {};
if !(_enemyGang in life_gang_wars) exitWith {};
["Ending the gang war...", "basic"] spawn life_fnc_handleMessage;
closeDialog 0; [[life_gang_data select 0, _enemyGang, false], "TON_fnc_updateWar", 2] spawn life_fnc_MP;