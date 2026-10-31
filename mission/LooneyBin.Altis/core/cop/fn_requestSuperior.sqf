#include "..\..\macro.h"
if (scriptAvailable(60)) exitWith {["You can only request a superior once every minute"] spawn life_fnc_handleMessage;};
private _message = "Officer is requesting a higher up at their location!";
private _playerName = name player; [[1, player, call life_copLevel, _message], "TON_fnc_handleDispatch", false] call life_fnc_MP;
["You've sent a higher up request!", "basic"] spawn life_fnc_handleMessage;