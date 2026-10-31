#include "..\..\macro.h"
if (scriptAvailable(60)) exitWith {["You can only request backup once every minute"] spawn life_fnc_handleMessage;};
private _message = "Officer is requesting backup at their location!";
private _playerName = name player; [[0, player, call life_copLevel, _message], "TON_fnc_handleDispatch", false] call life_fnc_MP;
["You have requested backup!", "basic"] spawn life_fnc_handleMessage;