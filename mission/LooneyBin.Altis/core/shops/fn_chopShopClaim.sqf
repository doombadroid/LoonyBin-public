if ((lbCurSel 39402) isEqualTo - 1) exitWith {["You didn't select a vehicle to claim.", "basic"] spawn life_fnc_handleMessage;};
private _zarosOwner = life_gang_data param[0, -99] isEqualTo(zaros_flag getVariable["plb_turf_data", [-44]] select 0);
private _claimPrice =
if (_zarosOwner) then {0} else {lbValue[39402, lbCurSel 39402]};
private _vehicle = lbData[39402, lbCurSel 39402];
_vehicle = objectFromNetId _vehicle;
if !(_vehicle getVariable["plb_canChop", true]) exitWith {
    ["You cannot claim this vehicle as it's not registered with the DMV!", "basic"] spawn life_fnc_handleMessage;};
if !(_vehicle getVariable["plb_side", ""] isEqualTo "civ") exitWith {
    ["This vehicle cannot be claimed.", "basic"] spawn life_fnc_handleMessage;};
if (_vehicle getVariable["plb_isSwat", false]) exitWith {["This SWAT vehicle cannot be claimed.", "basic"] spawn life_fnc_handleMessage;};
if (_vehicle getVariable["plb_isFirefighter", false]) exitWith {
    ["This NG firefighting vehicle cannot be claimed.", "basic"] spawn life_fnc_handleMessage;};
if (_vehicle getVariable["plb_vehicleAirdrop", false]) exitWith {
    ["This airdropped vehicle cannot be claimed.", "basic"] spawn life_fnc_handleMessage;};
if (typeOf _vehicle isEqualTo "I_Plane_Fighter_04_F") exitWith {
    ["This air vehicle cannot be claimed.", "basic"] spawn life_fnc_handleMessage;};
private _action = [format["Do you wish to claim this vehicle for $%1?", [_claimPrice] call life_fnc_numberText], "Claim Vehicle", "Yes", "No"] call BIS_fnc_guiMessage;
if !(_action) exitWith {};
if (player distance(_vehicle) > 25) exitWith {["The vehicle is too far away.", "basic"] spawn life_fnc_handleMessage;};
if (_vehicle getVariable["plb_dbInfo", []] isEqualTo[]) exitWith {["Failed to find vehicle data.", "basic"] spawn life_fnc_handleMessage;};
(_vehicle getVariable["plb_dbInfo", []]) params[["_vehicleOwnerUID", "", [""]], ["_vehiclePlateID", 0, [0]], ["_isGang", false, [false]]];
if (isNull _vehicle) exitWith {};
if (life_atmcash < _claimPrice) exitWith {["You don't have enough money to claim this vehicle.", "basic"] spawn life_fnc_handleMessage;};
if !(_vehicle getVariable["plb_side", -1] isEqualTo "civ") exitWith {
    ["This vehicle cannot be claimed.", "basic"] spawn life_fnc_handleMessage;};
if (_vehicleOwnerUID isEqualTo(getPlayerUID player)) exitWith {["This vehicle is already yours.", "basic"] spawn life_fnc_handleMessage;};
if (_vehicle getVariable["plb_gettingClaimed", false]) exitWith {
    ["Someone is already claiming this vehicle.", "basic"] spawn life_fnc_handleMessage;};
_vehicle setVariable["plb_gettingClaimed", true, true];
closeDialog 0;
disableSerialization;
5 cutRsc["life_progress", "PLAIN"];
private _ui = uiNamespace getVariable "life_progress";
private _text = "Claiming vehicle...";
private _progress = _ui displayCtrl 38201;
private _pgText = _ui displayCtrl 38202;
_pgText ctrlSetText format["%2 (1%1)...", "%", _text];
_progress progressSetPosition 0.01;
private _cP = 0.01;
life_action_in_use = true;
private _success = false;
private _startPos = getPosASL player;
for "_i"
from 0 to 1 step 0 do {uiSleep 0.6;
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
_vehicle setVariable["plb_gettingClaimed", false, true];
if !(_success) exitWith {["The claiming process was interrupted.", "basic"] spawn life_fnc_handleMessage;};
private _keyHolders = (_vehicle getVariable["plb_vehOwners", [["", ""]]]) apply {_x select 0};
private _toSend = (allPlayers select {(getPlayerUID _x) in _keyHolders}) - [player]; [
    [_vehicle], "life_fnc_removeVehKey", _toSend] spawn life_fnc_MP; [
    [_toSend, _vehicle, 3], "TON_fnc_keyManagement", 2] spawn life_fnc_MP;
life_atmcash = life_atmcash - _claimPrice;
life_atmcashCacheB = ((life_atmcash / 4) + 11);
[1] call life_fnc_ClupdatePartial; [[player, _vehicle, _claimPrice], "TON_fnc_vehOwnerSwap", 2] spawn life_fnc_MP;
uiSleep 1;
life_vehicles pushBackUnique _vehicle;
titleText[format["You have claimed this vehicle for a price of $%1", [_claimPrice] call life_fnc_numberText], "PLAIN"];
["vehclaim", 1] call life_fnc_statArrUpdate;
if (typeOf _vehicle isEqualTo "O_MRAP_02_F") then {["claim", "ifrit", 1] call life_fnc_handleQuest;};