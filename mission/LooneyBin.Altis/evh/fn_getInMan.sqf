params["_unit", "_role", "_vehicle", "_turret"];
if ((_role isEqualTo "driver")) then {[_vehicle, 900] call life_fnc_setVehicleIdle;
    // LoonyBin: silent top-left tip on taking the driver seat (trunk-persistence reminder).
    ["Vehicle inventory saves when garaged, illegal drugs do not.", "basic"] spawn life_fnc_handleMessage;};
[] call life_fnc_updateViewDistance;
if !(isNull life_holding_barrel) then {[] call life_fnc_dropOil};
if ((life_is_arrested param [0,0]) isEqualTo 1) exitWith {moveOut player;};
if (player getVariable["plb_surrendered", false]) exitWith {moveOut player;};
if (playerSide isEqualTo civilian && {_vehicle getVariable["plb_side", ""] == "med"}) exitWith {if (_vehicle isKindOf "Air") then {
        _vehicle enableCopilot false;};
    if (driver _vehicle isEqualTo player || ([player] call life_fnc_isUnitCopilot)) then {moveOut player;
        ["Only trained Medical and Fire personnel are able to operate this vehicle!", "basic"] spawn life_fnc_handleMessage;};};
private _isFrit = typeOf _vehicle isEqualTo "O_MRAP_02_F";
if ((_vehicle getVariable["plb_mentalTruck", false]) && (_vehicle getVariable["plb_mentalCarLocked", true])) exitWith {moveOut player;
    ["The Loony Bin Truck can't be driven whilst the tomb is locked, slacker!", "basic"] spawn life_fnc_handleMessage;};
if ((_vehicle getVariable["plb_mobileHeadQuartersTruckLocked", false])) exitWith {moveOut player;
    ["The mobile headquarters can not be moved whilst it is deployed", "basic"] spawn life_fnc_handleMessage;};
if ((_vehicle getVariable["plb_timeTrialVehicle", false]) && (_vehicle getVariable["plb_vehOwners", []]) isNotEqualTo[]) then {
    if (((_vehicle getVariable["plb_vehOwners", []] param[0]) param[0]) != getPlayerUID player) exitWith {moveOut player;
        ["This is not your time trial vehicle! Get your own!", "basic"] spawn life_fnc_handleMessage;};
    if (((_vehicle getVariable["plb_vehOwners", []] param[0]) param[0]) == getPlayerUID player && !(player getVariable["plb_timeTrialActive", false])) exitWith {
        moveOut player;
        ["You have already finished or failed your time trial, this vehicle is in a 'destructive' state", "basic"] spawn life_fnc_handleMessage;
    };};
if (life_inEvent && !((typeOf _vehicle) isEqualTo "Steerable_Parachute_F")) exitWith {moveOut player;
    ["You cannot enter vehicles during an admin event.", "basic"] spawn life_fnc_handleMessage;};
if (life_action_in_use) exitWith {moveOut player;
    ["You can't get in while doing something else!", "basic"] spawn life_fnc_handleMessage;};
if (typeOf _vehicle isEqualTo "C_Tractor_01_F") then {[_vehicle] spawn life_fnc_tractorMine;};
if (_vehicle isKindOf "Air" && life_inv_goldbar > 0 && !((player getVariable["plb_restrained", false]) && !(player getVariable["plb_civRestrained", false]))) then {
    moveOut player;
    ["You may not enter an air vehicle while carrying gold bars. They're too heavy!", "basic"] spawn life_fnc_handleMessage;};
if (headgear player == "H_PilotHelmetHeli_O" && !(_vehicle isKindOf "Air")) exitWith {removeHeadgear player;};
_vehicle addEventHandler["Killed", {params["_vehicle"];
    [_vehicle] spawn {params["_vehicle"];
        waitUntil {uiSleep 1;
            (speed _vehicle isEqualTo 0) && !(alive _vehicle)};
        uiSleep 5;
        if (life_corpse in (crew _vehicle)) then {life_corpse moveOut _vehicle;};};}];
[_vehicle] spawn {params["_vehicle"];
    private _metersDrove = 0;
    while {!(isNull _vehicle) && (alive _vehicle) && (player in (crew _vehicle)) && !(life_isDead)}
    do {private _startPos = (getPosATL _vehicle);
        uiSleep 1;
        if ((isNull _vehicle) || !(alive _vehicle) || !(player in (crew _vehicle)) || (life_isDead)) exitWith {};
        private _endPos = (getPosATL _vehicle);
        _metersDrove = _metersDrove + (_startPos distance2D _endPos);}; if (_metersDrove isNotEqualTo 0) then {
        ["distancedrove", _metersDrove] call life_fnc_statArrUpdate;};};
life_dynamicMap_lastVehicle = _vehicle;
[_vehicle] spawn life_fnc_dynamicMapVehicleFix;