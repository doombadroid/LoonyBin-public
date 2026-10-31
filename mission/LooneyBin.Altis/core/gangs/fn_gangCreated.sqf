params[["_group", grpNull, [grpNull]], ["_gangName", "", [""]], ["_gangID", -1, [0]]];
if (_group isEqualTo grpNull || _gangName isEqualTo "" || _gangID isEqualTo - 1) exitWith {};
life_gang_data = [_gangID, _gangName, 1, [0, 0, 0]];
life_gang_talents = [];
life_gang_exp = 0;
player setVariable["gang_data", life_gang_data, true];
[format["Congratulations! You have created the gang %1!", _gangName], "basic"] spawn life_fnc_handleMessage;
life_atmcash = life_atmcash - 25000;
life_atmcashCacheB = ((life_atmcash / 4) + 11);