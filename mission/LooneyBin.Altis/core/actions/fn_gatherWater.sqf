if !(surfaceIsWater position player) exitWith {};
life_action_gathering = true;
life_action_in_use = true;
private _startPos = getPos player;
private _exit = false;
titleText["Collecting...", "PLAIN"];
for "_i"
from 0 to 1 step 0 do {uiSleep 5;
    if (_exit || (player distance2D _startPos) > 2 || !(isNull objectParent player)) exitWith {};
    if !(life_action_in_use) exitWith {};
    if !(surfaceIsWater position player) exitWith {};
    if ([true, "saltwater", 1] call life_fnc_handleInv) then {titleText["Collected 2 Salt Water.", "PLAIN"];
        life_side_exp = life_side_exp + 1;} else {_exit = true;};}; if (_exit) then {
    titleText["Collecting done. You can't hold more Salt Water.", "PLAIN", 0.3];} else {titleText["Collecting cancelled.", "PLAIN"];};
life_action_gathering = false;
life_action_in_use = false;