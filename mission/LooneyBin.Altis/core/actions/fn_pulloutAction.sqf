params[["_vehicle", objNull, [objNull]]];
if (player distance _vehicle > 8) exitWith {};
private _crew = crew _vehicle;
private _toPull = 0; {if !(alive _x) then {private _plb_pos = (vehicle _x) modelToWorld[-2, 0, 0];
        _x setPos _plb_pos;} else {
        if ((_x getVariable["plb_restrained", false]) || (_x getVariable["plb_downed", false]) || playerSide isEqualTo west || ((playerSide isEqualTo civilian) && {
            cursorTarget in life_vehicles})) then {_x setVariable["plb_transporting", nil, true];
            _x setVariable["plb_escorting", nil, true]; [[player], "life_fnc_pullOutVeh", _x, false, false] spawn life_fnc_MP;
            _toPull = _toPull + 1;};}}
forEach _crew;
if (_toPull isEqualTo 0) then {["There is nobody in this vehicle who you're able to remove!", "basic"] spawn life_fnc_handleMessage;};