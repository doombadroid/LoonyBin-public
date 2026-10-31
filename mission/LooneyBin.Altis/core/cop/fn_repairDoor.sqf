params[["_building", objNull, [objNull]]];
if (isNull _building) exitWith {};
if (!(_building isKindOf "House_F")) exitWith {["You are not looking at a house door.", "basic"] spawn life_fnc_handleMessage};
private _doors = 1;
while {true}
do {if (!isClass(configFile >> "CfgVehicles" >> (typeOf _building) >> "AnimationSources" >> format["Door_%1_source", _doors])) exitWith {};
    _doors = _doors + 1;}; private _door = 0;
for "_i"
from 1 to _doors do {private _selPos = _building selectionPosition format["Door_%1_trigger", _i];
    private _worldSpace = _building modelToWorld _selPos;
    if (player distance _worldSpace < 5) exitWith {_door = _i;};}; if (_door isEqualTo 0) exitWith {
    ["You are not near a door!", "basic"] spawn life_fnc_handleMessage};
if ((_building getVariable[format["bis_disabled_Door_%1", _door], 0]) == 1) exitWith {
    ["The door is already unlocked!", "basic"] spawn life_fnc_handleMessage};
life_action_in_use = true;
closeDialog 0;
disableSerialization;
private _title = "Repairing Door...";
5 cutRsc["life_progress", "PLAIN"];
private _ui = uiNamespace getVariable "life_progress";
private _progressBar = _ui displayCtrl 38201;
private _titleText = _ui displayCtrl 38202;
_titleText ctrlSetText format["%2 (1%1)...", "%", _title];
_progressBar progressSetPosition 0.01;
private _cP = 0.01;
private _cpRate =
switch (typeOf _building) do {case "Land_Dome_Big_F": {0.008;}; case "Land_Research_house_V1_F": {0.005;};
        default {0.08;}}; while {true}
do {if (animationState player != "AinvPknlMstpSnonWnonDnon_medic_1") then {[
            [player, "AinvPknlMstpSnonWnonDnon_medic_1"], "life_fnc_animSync", true, false] spawn life_fnc_MP;
        player playMoveNow "AinvPknlMstpSnonWnonDnon_medic_1";};
    uiSleep 0.26;
    if (isNull _ui) then {5 cutRsc["life_progress", "PLAIN"];
        _ui = uiNamespace getVariable "life_progress";};
    _cP = _cP + _cpRate;
    _progressBar progressSetPosition _cP;
    _titleText ctrlSetText format["%3 (%1%2)...", round(_cP * 100), "%", _title];
    if (_cP >= 1 || !alive player) exitWith {};
    if (life_interrupted) exitWith {};}; 5 cutText["", "PLAIN"];
player playActionNow "stop";
if (!alive player) exitWith {life_action_in_use = false;};
if (life_interrupted) exitWith {life_interrupted = false;
    titleText["Action Cancelled", "PLAIN"];
    life_action_in_use = false;};
life_action_in_use = false;
_building animate[format["door_%1_rot", _door], 0];
_building setVariable[format["bis_disabled_Door_%1", _door], 1, true];