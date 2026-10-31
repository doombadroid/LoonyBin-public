params[["_requester", objNull, [objNull]]];
if (isNull _requester) exitWith {};
if (isNil "_requester") exitWith {}; [
    [life_atmCash, life_cash, getPlayerUID player, profileName, profileNameSteam, owner player, player], "life_fnc_adminInfo", _requester] spawn life_fnc_MP;