if !(vehicle player isKindOf "Ship" || typeOf(vehicle player) isEqualTo "I_MRAP_03_F") exitWith {};
private _range =
switch (true) do {case (65 in life_side_talents): {60};
    case (64 in life_side_talents): {45};
    default {30};}; private _fish = nearestObjects[vehicle player, ["Fish_Base_F"], _range];
life_net_dropped = true;
titleText["Dropping fishing net....", "PLAIN"];
uiSleep 5;
if (_fish isEqualTo[]) exitWith {titleText["Didn't catch any fish...", "PLAIN"];
    life_net_dropped = false;}; {(switch (true) do {case ((typeOf _x) isEqualTo "Salema_F"): {["salema", 1, "Salema"]};
        case ((typeOf _x) isEqualTo "Ornate_random_F"): {["ornate", 5, "Ornate"]};
        case ((typeOf _x) isEqualTo "Mackerel_F"): {["mackerel", 2.5, "Mackerel"]};
        case ((typeOf _x) isEqualTo "Tuna_F"): {["tuna", 35, "Tuna"]};
        case ((typeOf _x) isEqualTo "Mullet_F"): {["mullet", 7, "Mullet"]};
        case ((typeOf _x) isEqualTo "Catshark_F"): {["catshark", 2, "Catshark"]};
        default {["", 0, ""]};}) params["_type", "_maxWeight", "_name"];
    if !(_type isEqualTo "") then {uiSleep 3;
        if ([true, _type, 1] call life_fnc_handleInv) then {deleteVehicle _x;
            private _weight = round(((random _maxweight) * 100) / 100);
            titleText[format["You caught a %1kg %2", _weight, _name], "PLAIN"];
            life_side_exp = life_side_exp + 2;
            if (_weight > 1 && !(13 in life_achievements)) then {[13] call life_fnc_achievementGrant};
            if (_weight > 5 && !(14 in life_achievements)) then {[14] call life_fnc_achievementGrant};
            if (_weight > 25 && !(15 in life_achievements)) then {[15] call life_fnc_achievementGrant};
            ["fishcaught", 1] call life_fnc_statArrUpdate;};};}
forEach _fish;
uiSleep 1.5;
titleText["Fishing net pulled up.", "PLAIN"];
life_net_dropped = false;