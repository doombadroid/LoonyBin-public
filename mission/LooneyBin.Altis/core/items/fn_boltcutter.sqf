private["_building", "_door", "_doors", "_cpRate", "_title", "_progressBar", "_titleText", "_cp", "_ui"];
params[["_building", objNull, [objNull]]];
if (isNull _building) exitWith {};
if (!(_building isKindOf "House_F")) exitWith {["You are not looking at a house door.", "basic"] spawn life_fnc_handleMessage};
if (isNil "life_boltcutter_uses") then {life_boltcutter_uses = 0;};
if ((nearestObject[[16019.5, 16952.9, 0], "Land_Dome_Big_F"]) == _building || (nearestObject[[16019.5, 16952.9, 0], "Land_Research_house_V1_F"]) == _building) then {
    [[[1, 2], "!!!!! SOMEONE IS BREAKING INTO THE FEDERAL RESERVE !!!!!!", true, []], "life_fnc_broadcast", true, false] spawn life_fnc_MP;
} else {[[0, "%1 was seen breaking into a house.", true, [profileName]], "life_fnc_broadcast", true, false] spawn life_fnc_MP;};
_doors = 1;
while {true}
do {if (!isClass(configFile >> "CfgVehicles" >> (typeOf _building) >> "AnimationSources" >> format["Door_%1_source", _doors])) exitWith {};
    _doors = _doors + 1;}; _door = 0;
for "_i"
from 1 to _doors do {_selPos = _building selectionPosition format["Door_%1_trigger", _i];
    _worldSpace = _building modelToWorld _selPos;
    if (player distance _worldSpace < 5) exitWith {_door = _i;};}; if (_door isEqualTo 0) exitWith {
    ["You are not near a door!", "basic"] spawn life_fnc_handleMessage};
if ((_building getVariable[format["bis_disabled_Door_%1", _door], 0]) isEqualTo 0) exitWith {
    ["The door is already unlocked!", "basic"] spawn life_fnc_handleMessage};
life_action_in_use = true;
disableSerialization;
_title = "Cutting lock on door";
5 cutRsc["life_progress", "PLAIN"];
_ui = uiNamespace getVariable "life_progress";
_progressBar = _ui displayCtrl 38201;
_titleText = _ui displayCtrl 38202;
_titleText ctrlSetText format["%2 (1%1)...", "%", _title];
_progressBar progressSetPosition 0.01;
_cP = 0.01;
switch (typeOf _building) do {case "Land_Dome_Big_F": {_cpRate = 0.003;}; case "Land_Research_house_V1_F": {_cpRate = 0.0015;};
        default {_cpRate = 0.08;}}; while {true}
do {if (animationState player != "AinvPknlMstpSnonWnonDnon_medic_1") then {[
            [player, "AinvPknlMstpSnonWnonDnon_medic_1"], "life_fnc_animSync", true, false] spawn life_fnc_MP;
        player playMoveNow "AinvPknlMstpSnonWnonDnon_medic_1";};
    uiSleep 0.26;
    if (isNull _ui) then {5 cutRsc["life_progress", "PLAIN"];
        _ui = uiNamespace getVariable "life_progress";
        _progressBar = _ui displayCtrl 38201;
        _titleText = _ui displayCtrl 38202;};
    _cP = _cP + _cpRate;
    _progressBar progressSetPosition _cP;
    _titleText ctrlSetText format["%3 (%1%2)...", round(_cP * 100), "%", _title];
    if (_cP >= 1 || !alive player) exitWith {};
    if (life_istazed) exitWith {};
    if (life_interrupted) exitWith {};}; 5 cutText["", "PLAIN"];
player playActionNow "stop";
if (!alive player || life_istazed) exitWith {life_action_in_use = false;};
if ((player getVariable["plb_restrained", false])) exitWith {life_action_in_use = false;};
if (life_interrupted) exitWith {life_interrupted = false;
    titleText["Action Cancelled", "PLAIN"];
    life_action_in_use = false;};
life_boltcutter_uses = life_boltcutter_uses + 1;
life_action_in_use = false;
if (life_boltcutter_uses >= 5) then {[false, "boltcutter", 1] call life_fnc_handleInv;
    life_boltcutter_uses = 0;};
_building setVariable[format["bis_disabled_Door_%1", _door], 0, true];
if ((_building getVariable["plb_locked", false])) then {_building setVariable["plb_locked", false, true];}; [
    [getPlayerUID player, profileName, "459"], "TON_fnc_wantedAdd", false, false] spawn life_fnc_MP;