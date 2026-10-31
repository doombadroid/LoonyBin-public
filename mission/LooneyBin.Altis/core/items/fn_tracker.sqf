params[["_vehicle", objNull, [objNull]]];
if !(_vehicle isKindOf "Air" || _vehicle isKindOf "Ship" || _vehicle isKindOf "LandVehicle") exitWith {
    ["You cannot add a tracking unit to this.", "basic"] spawn life_fnc_handleMessage};
if (player distance _vehicle > 7) exitWith {["You need to be within 7 meters!", "basic"] spawn life_fnc_handleMessage};
if (_vehicle in life_tracked) exitWith {["You are already tracking this vehicle.", "basic"] spawn life_fnc_handleMessage};
if !([false, "tracker", 1] call life_fnc_handleInv) exitWith {};
if !(isNull objectParent player) exitWith {["You cannot perform this action from within a vehicle.", "basic"] spawn life_fnc_handleMessage
};
if (isWeaponDeployed player) exitWith {
    ["You probably need your hands free to attach a tracker to this.", "basic"] spawn life_fnc_handleMessage};
if (player getVariable["plb_surrendered", false]) exitWith {
    ["You probably need your hands free to attach a tracker to this.", "basic"] spawn life_fnc_handleMessage};
closeDialog 0;
life_action_in_use = true;
player playMove "AinvPknlMstpSnonWnonDnon_medic_1";
uiSleep 1.5;
life_action_in_use = false;
if (player distance _vehicle > 7) exitWith {titleText["You are not in range!", "PLAIN"]};
life_tracked pushBack _vehicle;
private _trackedPlayers = _vehicle getVariable["plb_tracked", []];
_trackedPlayers pushBack[playerSide, getPlayerUID player];
_vehicle setVariable["plb_tracked", _trackedPlayers, true];
titleText["You have attached a tracking device to this vehicle.", "PLAIN"];
life_side_exp = life_side_exp + 15;
["action", "applytracker", 1] call life_fnc_handleQuest;