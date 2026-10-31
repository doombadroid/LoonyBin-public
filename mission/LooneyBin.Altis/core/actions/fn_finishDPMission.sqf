params[["_dpID", -1, [0]], ["_npcObj", objNull, [objNull]]];
if (_dpID isEqualTo - 1 || isNull _npcObj) exitWith {};
if !(_npcObj isEqualTo life_dp_end) exitWith {["You are not at the correct delivery mission npc!", "basic"] spawn life_fnc_handleMessage;};
if !(life_delivery_inProg) exitWith {["You are not on a delivery right now!", "basic"] spawn life_fnc_handleMessage;};
if !(life_delivery_type in [1, 2, 3, 4]) exitWith {};
if (!(life_delivery_type in [3, 4]) && {isNull life_delivery_object}) exitWith {
    ["Your cargo to deliver seems to have been lost or has disappeared...", "basic"] spawn life_fnc_handleMessage;};
if (life_delivery_type in [1, 2] && {(life_delivery_object distance _npcObj) > 30}) exitWith {
    ["Your cargo is too far away from me! Please move the cargo container closer.", "basic"] spawn life_fnc_handleMessage;};
if (life_delivery_type in [1, 2] && {((getPos life_delivery_object) select 2) > 0.15}) exitWith {
    ["Your cargo is too high in the air, please bring it closer to the ground.", "basic"] spawn life_fnc_handleMessage;};
if (life_delivery_type in [1, 2] && {!(isNull(ropeAttachedTo life_delivery_object))}) exitWith {
    ["Your container is still attached to the vehicle, please release it first.", "basic"] spawn life_fnc_handleMessage;};
if !(isNull life_delivery_object) then {deleteVehicle life_delivery_object;
    life_delivery_object = objNull;};
private _distance = life_dp_start distance(getPos life_dp_end);
private _payOut = round(0.3 * _distance);
private _payIncrease = 1;
if (32 in life_side_talents) then {_payIncrease = _payIncrease + 0.10;};
if (life_delivery_type isEqualTo 3 && {125 in life_side_talents}) then {_payIncrease = _payIncrease + 0.15;};
if (life_delivery_type isEqualTo 1 && {33 in life_side_talents}) then {_payIncrease = _payIncrease + 0.20;};
if (life_delivery_type isEqualTo 2 && {34 in life_side_talents}) then {_payIncrease = _payIncrease + 0.25;};
_payOut = (_payOut * _payIncrease);
private _timeToDeliver = [(time - life_delivery_StartTime), "MM:SS", true] call BIS_fnc_secondsToString;
["DeliverySucceeded", [format["You have earned $%1.", [_payOut] call life_fnc_numberText]]] call BIS_fnc_showNotification;
if (127 in life_side_talents) then {
    [format["You have completed the delivery mission in %1 Minutes %2 seconds! You have recieved $%3 for your delivery efforts! Due to your talent configuration half the payment has been sent to your bank account and the other half is on-hand.", _timeToDeliver select 0, _timeToDeliver select 1, [_payOut] call life_fnc_numberText]] spawn life_fnc_handleMessage;
    life_atmcash = round(life_atmcash + round(_payOut / 2)) max 0;
    life_atmcashCacheB = ((life_atmcash / 4) + 11);
    life_cash = round(life_cash + round(_payOut / 2)) max 0;
    life_cashCacheB = ((life_cash / 4) + 9);} else {
    [format["You have completed the delivery mission in %1 Minutes %2 seconds! You have recieved $%3 for your delivery efforts!", _timeToDeliver select 0, _timeToDeliver select 1, [_payOut] call life_fnc_numberText]] spawn life_fnc_handleMessage;
    life_cash = round(life_cash + _payOut) max 0;
    life_cashCacheB = ((life_cash / 4) + 9);};
[6] call life_fnc_ClUpdatePartial;
life_side_exp = life_side_exp + 25;
life_cur_task setTaskState "Succeeded";
player removeSimpleTask life_cur_task;
["action", "dpmission", 1] call life_fnc_handleQuest; [
    ["-DPMISSION-", player, (profileName), format["completed a Delivery Mission (%1) from %2 to %3 in %4 Mins %5 Seconds and recieved $%6", life_delivery_type, life_dp_start, (getPos life_dp_end), _timeToDeliver select 0, _timeToDeliver select 1, [_payOut] call life_fnc_numberText]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
life_delivery_inProg = false;
life_dp_start = [0, 0, 0];
life_dp_end = objNull;
life_delivery_object = objNull;
life_delivery_type = -1;
life_delivery_StartTime = -1;
life_delivery_EndTime = -1;
life_cur_task = taskNull;
life_last_sold = time;