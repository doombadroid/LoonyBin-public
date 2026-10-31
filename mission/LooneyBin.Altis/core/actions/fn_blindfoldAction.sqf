params[["_mode", 0, [0]], ["_targetPlayer", objNull, [objNull]]];
if !(_mode in [1, 2]) exitWith {};
if !(_targetPlayer in allPlayers) exitWith {};
if !(alive _targetPlayer) exitWith {};
if (isNull _targetPlayer) exitWith {};
switch (_mode) do {case 1: {if !(_targetPlayer getVariable["plb_restrained", false]) exitWith {};
            if (_targetPlayer getVariable["plb_blinded", false]) exitWith {};
            if ([false, "blindfold", 1] call life_fnc_handleInv) then {[
                    [1, player], "life_fnc_blindfoldClient", _targetPlayer, false, false] spawn life_fnc_MP;} else {
                ["You do not have a blindfold.", "basic"] spawn life_fnc_handleMessage;};};
    case 2: {
            if !(((goggles _targetPlayer) isEqualTo "G_blindfold_01_black_F") || ((goggles _targetPlayer) isEqualTo "G_blindfold_01_white_F")) exitWith {};
            if ([true, "blindfold", 1] call life_fnc_handleInv) then {[
                    [2, player], "life_fnc_blindfoldClient", _targetPlayer, false, false] spawn life_fnc_MP;} else {
                ["You do not have room to hold the blindfold.", "basic"] spawn life_fnc_handleMessage;};};};