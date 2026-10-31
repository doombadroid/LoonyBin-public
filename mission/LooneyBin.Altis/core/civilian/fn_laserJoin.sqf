if !(playerSide isEqualTo civilian) exitWith {
    ["You can't play laser tag while on duty! GET TO WORK!", "basic"] spawn life_fnc_handleMessage};
["You have joined the laser tag queue. The next game will start any time within the next few minutes. Stay nearby or joining will fail!", "basic"] spawn life_fnc_handleMessage;
player setVariable["plb_laserPos", getPosATL player, true];
life_old_group = group player; [[player], "TON_fnc_laserQueue", 2] spawn life_fnc_MP;