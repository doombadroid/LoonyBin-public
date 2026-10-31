private _meatAmount = life_inv_dog + life_inv_sheep + life_inv_goat + life_inv_chicken + life_inv_snake + life_inv_rabbit + life_inv_manflesh;
private _meatTypes = ["manflesh", "chicken", "dog", "sheep", "goat", "snake", "rabbit"];
private _num = 0;
if (_meatAmount isEqualTo 0) exitWith {["You don't have any raw meat to be cooked!", "basic"] spawn life_fnc_handleMessage};
if !(alive player) exitWith {}; {_num = missionNamespace getVariable format["life_inv_%1", _x];
    if (_num > 0) then {[false, _x, _num] call life_fnc_handleInv;
        [true, format["%1p", _x], _num] call life_fnc_handleInv;
        if (_x isEqualTo "manflesh") then {["The scent of burning man flesh is in the air!", "basic"] spawn life_fnc_handleMessage; {
                private _target = _x;
                if (side _target isEqualTo west || player distance _target < 3000) then {
                    private _vectorDiff = (getPosASL player) vectorDiff(getPosASL _target);
                    private _direction = (_vectorDiff select 0) atan2(_vectorDiff select 1);
                    if (_direction < 0) then {_direction = 360 + _direction};
                    private _compass = ["north", "north east", "east", "south east", "south", "south west", "west", "north west", "north"];
                    private _bearing = _compass select(round(_direction / 45)); [[
                            [0, 1], format["You smell burning flesh %1 meters to the %2!", round(player distance _target), _bearing]
                        ], "life_fnc_broadcast", _target, false, false] spawn life_fnc_MP;};}
            forEach allPlayers;};
        titleText[format["You cooked %1 raw %2 meat.", _num, _x], "PLAIN"];
        ["meatcooked", _num] call life_fnc_statArrUpdate;
        player switchMove "AinvPknlMstpSnonWnonDnon_medic_2";
        uiSleep 2.3;};}
forEach _meatTypes;