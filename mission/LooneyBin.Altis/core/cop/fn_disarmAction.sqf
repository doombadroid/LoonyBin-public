params[["_unit", objNull, [objNull]]];
if (isNull _unit || alive _unit || _unit getVariable["plb_disarmed", false] || !(_unit isKindOf "CAManBase")) exitWith {};
if (player getVariable["plb_surrendered", false]) exitWith {
    ["Hands in the air like you just don't care?", "basic"] spawn life_fnc_handleMessage;};
private _nearVehicles = (nearestObjects[_unit, ["Car", "Air", "Ship"], 30]) select {_x getVariable["plb_side", ""] isEqualTo "cop"};
private _vehicle = _nearVehicles param[_nearVehicles findIf {!isNull _x}, objNull];
private _nearStation = ({(position player) inPolygon(life_police_hq_polys select _x)}
count[0, 1, 2, 3, 4, 5, 6] > 0);
if (isNull _vehicle && !(_nearStation)) exitWith {
    ["There aren't any nearby Police vehicles to seize this player's gear into!", "basic"] spawn life_fnc_handleMessage;};
if (!alive _vehicle && !(_nearStation)) exitWith {
    ["You cannot store items in a vehicle which has been destroyed!", "basic"] spawn life_fnc_handleMessage;};
private _targetName = _unit getVariable["plb_name", "Unknown"];
player playMoveNow "AinvPknlMstpSnonWnonDnon_medic1";
disableSerialization;
5 cutRsc["life_progress", "PLAIN"];
private _ui = uiNamespace getVariable "life_progress";
private _progress = _ui displayCtrl 38201;
private _pgText = _ui displayCtrl 38202;
private _text = format["Disarming %1.", _targetName];
_pgText ctrlSetText format["%2 (1%1)...", "%", _text];
_progress progressSetPosition 0.01;
private _cP = 0.01;
life_action_in_use = true;
private _success = false;
for "_i"
from 0 to 1 step 0 do {uiSleep 0.038;
    _cP = _cP + 0.01;
    _progress progressSetPosition _cP;
    _pgText ctrlSetText format["%3 (%1%2)...", round(_cP * 100), "%", _text];
    if (isNull _unit) exitWith {};
    if (alive _unit) exitWith {};
    if (player distance _unit > 3) exitWith {};
    if !(life_action_in_use) exitWith {};
    if (_cp >= 1) exitWith {_success = true;};}; 5 cutText["", "PLAIN"];
life_action_in_use = false;
player playActionNow "stop";
if !(_success) exitWith {};
[format["You removed all weapons from %1!", _targetName], "basic"] spawn life_fnc_handleMessage;
private _vehicle =
if (_nearStation) then {"HQ"} else {_vehicle};
["action", "disarm", 1] call life_fnc_handleQuest; [[player, _vehicle], "life_fnc_disarmed", _unit, false, false] spawn life_fnc_MP;