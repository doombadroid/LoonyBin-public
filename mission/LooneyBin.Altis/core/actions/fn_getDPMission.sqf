params[["_dpID", -1, [0]], ["_type", -1, [0]], ["_npcObj", objNull, [objNull]]];
if (_dpID isEqualTo - 1 || _type isEqualTo - 1 || isNull _npcObj) exitWith {};
if (life_delivery_inProg) exitWith {
    ["You're currently on a delivery! Complete that delivery and come back!", "basic"] spawn life_fnc_handleMessage;};
if (time < (life_last_sold + 2)) exitWith {["Please try again in a few seconds.", "basic"] spawn life_fnc_handleMessage};
private _typeText =
switch (_type) do {case 1: {"Ground Cargo Shipment"};
    case 2: {"Air Shipment"};
    case 3: {"Small Parcel"};
    case 4: {"Organ Transplant"}}; private _requirement = "truck that can load containers like an Offroad or Hemmt Transport";
if (_type isEqualTo 2) then {_requirement = "heavy lift helicopter like the Taru to lift the container";};
private _exit = false;
if (_type in [1, 2]) then {
    private _confirm = [format["<t align='center'>The %1 delivery mission requires a %2. Would you like to continue?</t>", _typeText, _requirement], "Special Vehicle Required!", "Yes", "No"] call BIS_fnc_guiMessage;
    if !(_confirm) exitWith {_exit = true;};};
if (_exit) exitWith {["You have decided to cancel the delivery mission.", "basic"] spawn life_fnc_handleMessage;};
private _availablePoints = [];
private _deliveryPoint = -1;
private _dpSpawn = format["dp_%1_spawn", _dpID];
for "_i"
from 1 to 26 do {if !(_i isEqualTo _dpID) then {_availablePoints pushBack _i;};}; _deliveryPoint = selectRandom _availablePoints;
if (_deliveryPoint isEqualTo - 1) exitWith {};
if !(isNull life_delivery_object) then {deleteVehicle life_delivery_object;};
private _action = true;
private _nearVehicles = nearestObjects[getMarkerPos _dpSpawn, ["Car", "Truck", "Air", "Ship"], 10];
if (count _nearVehicles > 0) then {
    _action = ["<t align='center'>There appears to be a vehicle near the Delivery Point. It is recommended that you press cancel and move the vehicle away before beginning this mission. Continue anyway?</t>", "Vehicle Nearby!", "Continue", "Cancel"] call BIS_fnc_guiMessage;
};
if !(_action) exitWith {
    ["You have canceled the mission. Move the nearby vehicle and retry the mission", "basic"] spawn life_fnc_handleMessage;};
if (life_delivery_inProg) exitWith {
    ["You're currently on a delivery! Complete that delivery and come back!", "basic"] spawn life_fnc_handleMessage;};
life_delivery_inProg = true;
life_delivery_type = _type;
life_dp_end = missionNamespace getVariable format["dp_%1", _deliveryPoint];
life_dp_start = (getPos _npcObj);
life_delivery_StartTime = time;
life_delivery_object = objNull;
life_cur_task = player createSimpleTask[format["Deliver the %1 to Delivery Point %2.", _typeText, _deliveryPoint]];
life_delivery_EndTime = time + (floor(((life_dp_start distance(getPos life_dp_end)) * (2.2 / 1000)) * 60));
switch (_type) do {case 1: {life_delivery_EndTime = time + (floor(((life_dp_start distance(getPos life_dp_end)) * (2.2 / 1000)) * 60));
            if (life_delivery_EndTime < (time + 300)) then {life_delivery_EndTime = time + 300;};
            // owner 2026-07-13: Slow Poke (72) pruned -- deliveries use base time.
            life_delivery_object = "Land_CargoBox_V1_F"
            createVehicle(getMarkerPos _dpSpawn);
            life_delivery_object enableRopeAttach true;
            [life_delivery_object, (life_delivery_EndTime - time)] call life_fnc_setVehicleIdle;
            life_cur_task setSimpleTaskDescription[format["You are to deliver this Ground Cargo Shipment, using a truck which can haul it, to Delivery Point %1 within %2 minutes. Unload the parcel at the destination when you arrive.", _deliveryPoint, floor((life_delivery_EndTime - time) / 60)], "Delivery Job", "Delivery Job"];
        };
    case 2: {life_delivery_EndTime = time + (floor(((life_dp_start distance(getPos life_dp_end)) * (1.2 / 1000)) * 60));
            if (life_delivery_EndTime < (time + 180)) then {life_delivery_EndTime = time + 180;};
            // owner 2026-07-13: Slow Poke (72) pruned -- deliveries use base time.
            life_delivery_object = "Land_Cargo10_brick_red_F"
            createVehicle(getMarkerPos _dpSpawn);
            life_delivery_object setMass 2600;
            life_delivery_object enableRopeAttach true;
            [life_delivery_object, (life_delivery_EndTime - time)] call life_fnc_setVehicleIdle;
            [life_delivery_object, (floor(((life_dp_start distance(getPos life_dp_end)) * (1.2 / 1000)) * 60))] call life_fnc_setVehicleIdle;
            life_cur_task setSimpleTaskDescription[format["You are to deliver this Air Shipment, using a powerful Helicopter, to Delivery Point %1 within %2 minutes. Drop the shipment at the destination when you arrive.", _deliveryPoint, floor((life_delivery_EndTime - time) / 60)], "Delivery Job", "Delivery Job"];
        };
    case 3: {life_delivery_EndTime = time + (floor(((life_dp_start distance(getPos life_dp_end)) * (1.8 / 1000)) * 60));
            if (life_delivery_EndTime < (time + 300)) then {life_delivery_EndTime = time + 300;};
            // owner 2026-07-13: Slow Poke (72) pruned -- deliveries use base time.
            life_delivery_object = objNull;
            life_cur_task setSimpleTaskDescription[format["Deliver this Small Parcel to Delivery Point %1 within %2 minutes.", _deliveryPoint, floor((life_delivery_EndTime - time) / 60)], "Delivery Job", "Delivery Job"];
        };
    case 4: {life_delivery_EndTime = time + (floor(((life_dp_start distance(getPos life_dp_end)) * (2.2 / 1000)) * 60));
            if (life_delivery_EndTime < (time + 300)) then {life_delivery_EndTime = time + 300;};
            life_delivery_object = objNull;
            life_cur_task setSimpleTaskDescription[format["Deliver this Human Organ to Delivery Point %1 within %2 minutes.", _deliveryPoint, floor((life_delivery_EndTime - time) / 60)], "Delivery Job", "Delivery Job"];
        };}; life_cur_task setSimpleTaskDestination(getPos life_dp_end);
life_cur_task setTaskState "Assigned";
player setCurrentTask life_cur_task;
["DeliveryAssigned", [format["Deliver this package to DP %1.", _deliveryPoint]]] call BIS_fnc_showNotification; [
    ["-DPMISSION-", player, (profileName), format["started a dp mission from %3(%1) to %4(%2).", life_dp_start, (getPos life_dp_end), _dpID, _deliveryPoint]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
[] spawn {disableSerialization;
    8 cutRsc["dp_timer", "PLAIN"];
    private _color = [0.36, 0.14, 0.69, 1];
    private _display = uiNamespace getVariable "dp_timer";
    private _timer = _display displayCtrl 38311;
    _timer ctrlSetTextColor _color;
    while {life_delivery_inProg}
    do {if (isNull _display) then {8 cutRsc["dp_timer", "PLAIN"];
            _display = uiNamespace getVariable "dp_timer";
            _timer = _display displayCtrl 38312;
            _timer ctrlSetTextColor _color;};
        if !(life_delivery_inProg) exitWith {};
        if (round(life_delivery_EndTime - time) < 1) exitWith {};
        _timer ctrlSetText format["%1", [(life_delivery_EndTime - time), "MM:SS"] call BIS_fnc_secondsToString];
        uiSleep 0.09;}; 8 cutText["", "PLAIN"];};
uiSleep 1;
[] spawn {
    (findDisplay 12 displayCtrl 51) ctrlAddEventHandler["Draw", "(_this select 0) drawLine [getPos player,getPos life_dp_end,[0,0,1,1]];"];
    while {
        life_delivery_inProg && alive player && time <= life_delivery_EndTime && (life_delivery_type in [3, 4] || !isNull life_delivery_object)
    }
    do {uiSleep 1;
        if (vehicle player != player) then {life_dp_vehicle = vehicle player};}; waitUntil {uiSleep 1;
        !alive player;
        if !(life_delivery_inProg) exitWith {true};
        if (time >= life_delivery_EndTime) exitWith {true};
        if (life_delivery_type in [1, 2] && isNull life_delivery_object) exitWith {true};};
    (findDisplay 12 displayCtrl 51) ctrlRemoveAllEventHandlers "Draw";
    if (life_delivery_inProg) then {life_cur_task setTaskState "Failed";
        player removeSimpleTask life_cur_task;
        life_delivery_inProg = false;
        8 cutText["", "PLAIN"];
        switch (true) do {case !(alive player): {
                    ["DeliveryFailed", ["You failed to deliver the package because you died."]] call BIS_fnc_showNotification;};
            case (time >= life_delivery_EndTime): {
                    ["DeliveryFailed", ["Your package is late. You've failed!"]] call BIS_fnc_showNotification;};
            case (isNull life_delivery_object): {
                    ["DeliveryFailed", ["Your cargo has been lost. You've failed!"]] call BIS_fnc_showNotification;};
            default {["DeliveryFailed", ["You've failed to deliver the package!"]] call BIS_fnc_showNotification;};
        }; if !(isNull life_delivery_object) then {deleteVehicle life_delivery_object;
            life_delivery_object = objNull;};
        life_dp_start = [0, 0, 0];
        life_dp_end = objNull;
        life_delivery_object = objNull;
        life_delivery_inProg = false;
        life_delivery_type = -1;
        life_delivery_StartTime = -1;
        life_delivery_EndTime = -1;
        life_cur_task = taskNull;};};