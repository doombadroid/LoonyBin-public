params[["_zone", "", [""]], ["_distance", 0, [0]]];
if (life_action_in_use) exitWith {};
if (life_inv_pickaxe < 1) exitWith {["You must have a pickaxe in order to gather this resource.", "basic"] spawn life_fnc_handleMessage;};
private _yield =
switch (true) do {case (_zone in ["mine_2", "mine_3", "mine_4", "mine_5"]): {1};
    case (_zone in ["mine_1", "mine_6"]): {2};}; titleText [format["Mining..."], "PLAIN"];
PlaySound "pickaxe";
life_action_gathering = true;
life_action_in_use = true;
private _startPos = getPos player;
private _delay =
if (52 in life_side_talents) then {3} else {4};
private _ironChance =
if (53 in life_side_talents) then {4} else {5};
private _diamondChance =
if (54 in life_side_talents) then {4} else {5};
private _random = "";
private _gathered = [];
private _exit = false;
["AinvPercMstpSnonWnonDnon_Putdown_AmovPercMstpSnonWnonDnon", 2.5] spawn life_fnc_handleAnim;
for "_i"
from 0 to 1 step 0 do {private _amount = 1;
    uiSleep _delay;
    _random =
    if ((life_is_arrested param [0,0]) isEqualTo 0) then {switch (true) do {case (random 2000 < 1): {"treasuremap";};
            // owner 2026-06-14 (#226): gold nuggets + flawless diamonds were near-unobtainable from the
            // quarry. 5x the drop rate for both (random N<K has prob K/N -> 5x the K). goldnugget 2->10
            // (0.04%->0.2%), diamondf 3->15 (1.2%->6%); the 2nd diamondf path below also 5x'd.
            case (random 5000 < 10): {"goldnugget";};
            case (random 250 < 15): {"diamondf";};
            case (floor(random 5 * _yield) < 1 && !(51 in life_side_talents)): {"rock";};
            case (floor(random(100 / _yield)) < 1):   // #226: 2nd flawless-diamond path 5x'd (500/_yield -> 100/_yield)
                {"diamondf";};
            case (floor(random(_ironChance / _yield)) < 1): {"ironore";};
            case (floor(random(_diamondChance / _yield)) < 1): {"diamond";};
            case (floor(random(3 / _yield)) < 1): {"copperore";};
            case (floor(random(4 / _yield)) < 1): {"sand";};
            default {"rock"};};};
    if (_random isEqualTo "copperore" && 51 in life_side_talents) then {_amount = 2};
    if ([true, _random, _amount] call life_fnc_handleInv) then {
        titleText[format["Mined %1 %2. %3/%4", _amount, ["getName", _random] call life_fnc_virtItemCfg, life_carryWeight, life_maxWeight], "PLAIN"];
        if (life_currentTalents < 10) then {life_side_exp = life_side_exp + 2;};
        private _index = _gathered findIf {(_x select 0) isEqualTo _random};
        if (_index isEqualTo - 1) then {_gathered pushBack[_random, _amount];} else {
            private _currentAmount = (_gathered select _index) select 1;
            (_gathered select _index) set[1, _currentAmount + _amount];};
        [_random, _amount] call life_fnc_statArrUpdate;} else {_exit = true;
        // BUGS.md #91 ("still broken"): tell the server WHY the add was refused so we can see the
        // real limiter in the RPT/log table (weight vs item-monitor vs nil roll).
        private _tot = 0; { _tot = _tot + (missionNamespace getVariable [_x, 0]); } forEach life_invMonVars; [
            ["-MINE-", player, profileName, format ["handleInv REFUSED item=%1 x%2 | carry %3/%4 (itemW %5) | items %6 | monitor-slack %7 | arrested %8", if (isNil "_random") then {"<nil>"} else {_random}, _amount, life_carryWeight, life_maxWeight, ["getItemWeight", if (isNil "_random") then {"rock"} else {_random}] call life_fnc_virtItemCfg, _tot, life_invMonitor - life_invRVar, life_is_arrested param [0,0]]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
    };
    if (_exit || (player distance2D _startPos) > 4 || (player distance(getMarkerPos _zone) > _distance) || !(isNull objectParent player) || !life_action_in_use) exitWith {};
}; if (_exit) then {titleText["Mining done. You can't hold more minerals.", "PLAIN"];
    playSound "ziptie";
    playSound "ziptie";
    playSound "ziptie";} else {titleText["Mining cancelled.", "PLAIN"];};
[] spawn life_fnc_handleAnim;
life_action_gathering = false;
life_action_in_use = false; [["-GATHER-", player, profileName, format["mined %1 at position %2.", _gathered apply {[
            ["getName", _x select 0] call life_fnc_virtItemCfg, _x select 1]}, getPosATL player]], "TON_fnc_logIt", 2] spawn life_fnc_MP;