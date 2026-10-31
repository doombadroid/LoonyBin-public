params[["_deadLoadoutPrice", -1, [0]], ["_killerLoadoutPrice", -1, [0]]];
if ((_deadLoadoutPrice >= 20000) && (_killerLoadoutPrice >= 20000)) exitWith {10};
if ((_deadLoadoutPrice >= 20000) && (_killerLoadoutPrice <= 5000)) exitWith {15};
if ((_deadLoadoutPrice <= 20000) && (_deadLoadoutPrice >= 5000) && (_killerLoadoutPrice <= 20000) && (_killerLoadoutPrice >= 5000)) exitWith {
    7};
if ((_deadLoadoutPrice <= 5000) && (_killerLoadoutPrice >= 20000)) exitWith {5};
if ((_deadLoadoutPrice <= 5000) && (_killerLoadoutPrice <= 5000)) exitWith {5};
if (true) exitWith {5};