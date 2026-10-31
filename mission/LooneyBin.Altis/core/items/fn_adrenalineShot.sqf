if ((player getVariable["plb_restrained", false]) || (player getVariable["plb_downed", false])) exitWith {};
if ((!alive player) || ((player distance(getMarkerPos "Respawn_west"))) <= 500) exitWith {};
params[["_target", player], ["_caller", player], ["_actionID", 0], ["_unit", objNull, [objNull]]];
private _unit =
if (isNull _unit) then {cursorTarget} else {_unit};
if ((isNull _unit) || (!isPlayer _unit) || (!alive _unit)) exitWith {};
private _useAdrenaline =
switch (true) do {case (life_coprole in ["all", "medic"] && 21 in life_cop_talents && (call life_copLevel >= 4)): {false};
    case (life_coprole in ["all", "detective"] && {32 in life_cop_talents}): {(random 10) < 7.5};
    case (116 in life_side_talents && call(life_medicLevel) >= 4 && floor(random 3) isEqualTo 0): {false};
    case (804 in life_completedLifetimeQuests && playerSide isEqualTo independent): {(random 10) < 5};
    case (456 in life_completedLifetimeQuests && playerSide isEqualTo civilian): {(random 10) <= 2};
    default {true};}; if (_useAdrenaline && {!([false, "adrenalineShot", 1] call life_fnc_handleInv)}) exitWith {
    ["You don't have a adrenaline shot to give!", "basic"] spawn life_fnc_handleMessage;};
life_action_in_use = true;
disableSerialization;
5 cutRsc["life_progress", "PLAIN"];
private _display = uiNamespace getVariable["life_progress", displayNull];
if (isNull _display) exitWith {};
private _progressBar = _display displayCtrl 38201;
private _progressText = _display displayCtrl 38202;
private _unitText =
if (_unit isEqualTo player) then {"yourself"} else {name _unit};
private _text = format["Injecting %1 with adrenaline", _unitText];
_progressText ctrlSetText format["%2 (0%1)...", "%", _text];
_progressBar progressSetPosition 0.00;
private _counter = progressPosition _progressBar;
private _animationState = animationState player;
if (_unit isEqualTo player) then {player playActionNow "Medic"} else {player playActionNow "MedicOther"};
private _isSuccess =
for "_i"
from 0 to 1 step 0 do {uiSleep 0.20;
    _counter = _counter + 0.10;
    _progressBar progressSetPosition _counter;
    _progressText ctrlSetText format["%3 (%1%2)...", round(_counter * 100), "%", _text];
    if (_counter >= 1) exitWith {true};
    if (!life_action_in_use) exitWith {false};
    if (isWeaponDeployed player) exitWith {false};
    if (player getVariable["plb_restrained", false]) exitWith {false};
    if (player getVariable["plb_downed", false]) exitWith {false};
    if (!alive player) exitWith {false};
    false;}; 5 cutText["", "PLAIN"];
life_action_in_use = false;
player switchMove "stop";
if !(_isSuccess) exitWith {["Adrenaline shot failed.", "basic"] spawn life_fnc_handleMessage;
    if (_useAdrenaline) then {[true, "adrenalineShot", 1] call life_fnc_handleInv;};};
if (_unit isEqualTo player) then {[] call life_fnc_adrenalineShotEffect} else {[
        [player], "life_fnc_adrenalineShotEffect", _unit, false, false] spawn life_fnc_MP;};
life_side_exp = life_side_exp + 15;
// owner 2026-06-13 (#158): NG medics earn prestige for adrenaline-shotting ("narcan") ANOTHER player awake
// -- this path only gave side_exp, so medics got no NG prestige from it (revive/medkit/bloodbag already do).
if (_unit isNotEqualTo player) then { 25 call life_fnc_medicEarn; };   // medicEarn is independent-gated internally
["adrenaline", 1] call life_fnc_statArrUpdate;
["action", "adrenaline", 1] spawn life_fnc_handleQuest;
player switchMove "stop";