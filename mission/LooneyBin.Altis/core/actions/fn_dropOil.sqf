if (isNull life_holding_barrel) exitWith {["You are not holding a barrel!", "basic"] spawn life_fnc_handleMessage};
life_holding_barrel attachTo[player, [0, 1, 0.5]];
detach life_holding_barrel;
life_holding_barrel = objNull;
player forceWalk false;