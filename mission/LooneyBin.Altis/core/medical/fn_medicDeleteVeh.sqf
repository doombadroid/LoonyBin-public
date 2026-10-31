params[["_vehicle", objNull, [objNull]]];
if (alive _vehicle) exitWith {["The vehicle you are trying to clear must be destroyed!", "basic"] spawn life_fnc_handleMessage;};
if (life_action_in_use) exitWith {["You are currently already doing something!", "basic"] spawn life_fnc_handleMessage;};
if !(_vehicle isEqualTo cursorObject) exitWith {};
private _vehicleName = getText(configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName");
private _payout =
if (typeOf _vehicle in ["C_Kart_01_Blu_F", " C_Kart_01_Fuel_F", "C_Kart_01_Red_F", "C_Kart_01_Vrana_F", "B_Quadbike_01_F", "I_Quadbike_01_F", "C_Quadbike_01_black_F", "C_Rubberboat", "B_Boat_Transport_01_F"]) then {
    50} else {500};
life_action_in_use = true;
private _text = format["Clearing %1 Wreckage", _vehicleName];
5 cutRsc["life_progress", "PLAIN"];
private _ui = uiNameSpace getVariable "life_progress";
private _progress = _ui displayCtrl 38201;
private _pgText = _ui displayCtrl 38202;
_pgText ctrlSetText format["%2 (1%1)...", "%", _text];
_progress progressSetPosition 0.01;
private _cP = 0.01;
private _success = false;
private _pos = getPos player;
for "_i"
from 0 to 1 step 0 do {uiSleep 0.2;
    _cP = _cP + 0.02;
    _progress progressSetPosition _cP;
    _pgText ctrlSetText format["%3 (%1%2)...", round(_cP * 100), "%", _text];
    if (player distance _pos > 4 || life_isDowned || player getVariable["plb_restrained", false] || !alive player || speed player > 2) exitWith {};
    if !(life_action_in_use) exitWith {};
    if !(isNull objectParent player) exitWith {};
    if (_cP >= 1) exitWith {_success = true;};}; 5 cutText["", "PLAIN"];
life_action_in_use = false;
if !(_success) exitWith {};
[format["You have removed the wreckage of a %1", _vehicleName], "basic"] spawn life_fnc_handleMessage;
life_side_exp = life_side_exp + 50;
25 call life_fnc_medicEarn;   // NG prestige
["action", "removewreck", 1] call life_fnc_handleQuest;

// find objects
_objects = attachedObjects _vehicle;

// check if vehicle has objects or not
 {
    // delete those objects
    deleteVehicle _x;} forEach _objects;

deleteVehicle _vehicle;
if (805 in life_completedLifetimeQuests) then {life_atmcash = (round(life_atmcash + _payout)) max 0;
    life_atmcashCacheB = ((life_atmcash / 4) + 11);};