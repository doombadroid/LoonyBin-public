disableSerialization;
if ((lbCurSel 39402) isEqualTo - 1) exitWith {["You didn't select a vehicle to chop.", "basic"] spawn life_fnc_handleMessage;};
private _price = lbValue[39402, lbCurSel 39402];
private _vehicle = lbData[39402, lbCurSel 39402];
_vehicle = objectFromNetId _vehicle;
if (player distance(_vehicle) > 25) exitWith {["The vehicle is too far away.", "basic"] spawn life_fnc_handleMessage;};
if (isNull _vehicle) exitWith {["Null vehicle.", "basic"] spawn life_fnc_handleMessage;};
if !(_vehicle getVariable["plb_canChop", true]) exitWith {
    ["You cannot chop this vehicle as it's not registered with the DMV!", "basic"] spawn life_fnc_handleMessage;};
if !((_vehicle getVariable["plb_side", ""] in ["civ", "cop"]) || {(_vehicle getVariable["plb_dbInfo",[]]) param [2, false] isEqualTo true}) exitWith {   // owner 2026-06-21 (#477): also allow GANG vehicles (plb_dbInfo[2]==true) even if plb_side is unstamped
    ["This vehicle cannot be chopped.", "basic"] spawn life_fnc_handleMessage;};
if (_vehicle getVariable["plb_gettingClaimed", false]) exitWith {
    ["You can't chop this vehicle while it's being claimed.", "basic"] spawn life_fnc_handleMessage;};
if (_vehicle getVariable["plb_gettingChopped", false]) exitWith {
    ["This vehicle is already being chopped.", "basic"] spawn life_fnc_handleMessage;};
if (typeOf _vehicle isEqualTo "I_Plane_Fighter_04_F") exitWith {
    ["This air vehicle cannot be claimed.", "basic"] spawn life_fnc_handleMessage;};
_vehicle setVariable["plb_gettingChopped", true, true];
closeDialog 0;
disableSerialization;
5 cutRsc["life_progress", "PLAIN"];
private _ui = uiNamespace getVariable "life_progress";
private _text = "Chopping vehicle...";
private _progress = _ui displayCtrl 38201;
private _pgText = _ui displayCtrl 38202;
_pgText ctrlSetText format["%2 (1%1)...", "%", _text];
_progress progressSetPosition 0.01;
private _cP = 0.01;
life_action_in_use = true;
private _success = false;
private _startPos = getPosASL player;
for "_i"
from 0 to 1 step 0 do {uiSleep 0.3;
    _cP = _cP + 0.01;
    _progress progressSetPosition _cP;
    _pgText ctrlSetText format["%3 (%1%2)...", round(_cP * 100), "%", _text];
    if !(alive player) exitWith {};
    if !(alive _vehicle) exitWith {};
    if !(isNull objectParent player) exitWith {};
    if (player distance2D _startPos > 2) exitWith {};
    if (player distance2D _vehicle > 22) exitWith {};
    if (player getVariable["plb_downed", false]) exitWith {};
    if (player getVariable["plb_surrendered", false]) exitWith {};
    if (player getVariable["plb_restrained", false]) exitWith {};
    if !(life_action_in_use) exitWith {};
    if (_cp >= 1) exitWith {_success = true;};}; 5 cutText["", "PLAIN"];
life_action_in_use = false;
_vehicle setVariable["plb_gettingChopped", false, true];
if !(_success) exitWith {["The chopping process was interrupted.", "basic"] spawn life_fnc_handleMessage;};
private _price2 = life_cash + _price; [[player, _vehicle, _price, _price2], "TON_fnc_srvChopShopSell", false, false] spawn life_fnc_MP; [
    [getPlayerUID player, "plb_choptrace", time], "TON_fnc_varPersist", 2] spawn life_fnc_MP;
life_lastPersistVar = ["plb_choptrace", (time + 30)];
[] spawn {private _time = time;
    waitUntil {uiSleep 1;
        (life_cash isEqualTo 0) || ((time - _time) > 200)};
    if (life_cash isEqualTo 0) then {[[getPlayerUID player, "plb_choptrace", -1000], "TON_fnc_varPersist", 2] spawn life_fnc_MP;};};
["vehchop", 1] call life_fnc_statArrUpdate;
["The chop shop has consumed the vehicle!", "basic"] spawn life_fnc_handleMessage;
if (_vehicle getVariable["plb_side", ""] == "cop") then {if (typeOf _vehicle isEqualTo "C_Hatchback_01_sport_F") then {
        ["chop", "cophatchback", 1] call life_fnc_handleQuest;};
    if (typeOf _vehicle isEqualTo "B_Heli_Light_01_F") then {["chop", "cophummingbird", 1] call life_fnc_handleQuest;};
    if (typeOf _vehicle isEqualTo "O_MRAP_02_F") then {["chop", "copifrit", 1] call life_fnc_handleQuest;};};
if (_vehicle getVariable["plb_side", ""] == "civ") then {if (typeOf _vehicle isEqualTo "O_Heli_Light_02_unarmed_F") then {
        ["chop", "civorca", 1] call life_fnc_handleQuest;};
    if (typeOf _vehicle isEqualTo "O_MRAP_02_F") then {["chop", "civifrit", 1] call life_fnc_handleQuest;};
    if (typeOf _vehicle isEqualTo "O_Heli_Light_02_unarmed_F") then {["chop", "orcalifetime", 1] call life_fnc_handleQuest;};};