#include "..\..\macro.h"
if (scriptAvailable(3)) exitWith {["You cannot dig so fast!", "basic"] spawn life_fnc_handleMessage;};
if (life_action_in_use) exitWith {};
if (life_action_gathering) exitWith {};
if (isNil "life_action_gathering") then {life_action_gathering = false;};
// owner 2026-06-19: must have taken the Den ELEVATOR down to dig. Players were backing a Tempest up to the surface
// rocks above the den and digging there -- the 300m radius guard below reaches the surface, so on-foot alone didn't
// stop it. plb_inFungiDen is set by fn_fungiActions enterDen, cleared on exit/respawn. No elevator = no dig.
if !(player getVariable ["plb_inFungiDen", false]) exitWith {
    ["You must take the Elevator down into the Den to dig Dark Fungi -- you can't gather from the surface.", "basic"] spawn life_fnc_handleMessage;
};
titleText[format["Digging fungi out of den site..."], "PLAIN"];
playSound "gatherLsd";
life_action_gathering = true;
life_action_in_use = true;
private _startPos = getPos player;
private _delay = 4;
private _exit = false;
private _amount = 1;
// ROCKHOUND (223): +1 unit every mining swing.
if (223 in life_side_talents) then { _amount = _amount + 1; };
private _distance = 300;
private _totalGathered = 0;
["AinvPknlMstpSnonWnonDnon_medic_1", 2.5] spawn life_fnc_handleAnim;
for "_i"
from 0 to 1 step 0 do {
    if (_exit || (player distance2D _startPos) > 4 || (player distance[9049.6, 22467.8, 0] > _distance) || !(isNull objectParent player) || !(life_action_in_use)) exitWith {};
    private _item = "fungi";
    uiSleep _delay;
    if ([true, _item, _amount] call life_fnc_handleInv) then {
        titleText[format["Digged %1 %2. %3/%4", _amount, (["getName", _item] call life_fnc_virtItemCfg), life_carryWeight, life_maxWeight], "PLAIN"];
        if (_item isEqualTo "fungi") then {_totalGathered = _totalGathered + _amount;};
        if (life_currentTalents < 15) then {life_side_exp = life_side_exp + 2;};} else {_exit = true;};}; if (_exit) then {
    titleText["Digging done. You can't hold more fungi.", "PLAIN"];} else {titleText["Digging cancelled.", "PLAIN"];};
[] spawn life_fnc_handleAnim;
life_action_gathering = false;
life_action_in_use = false; [
    ["-GATHER-", player, profileName, format["gathered %1 %2 at position %3.", _totalGathered, "Dark Fungi", getPosATL player]], "TON_fnc_logIt", 2] spawn life_fnc_MP;