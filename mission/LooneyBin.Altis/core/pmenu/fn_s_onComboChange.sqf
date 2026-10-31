params[["_mode", -1], ["_control", controlNull], ["_selectedIndex", -1]];
if (_mode isEqualTo - 1) exitWith {};
switch (_mode) do {case 0: {[2] spawn life_fnc_coloredHexesMenu;};
    case 1: {[1] spawn life_fnc_coloredHexesMenu;};
    case 2: {[1] spawn life_fnc_sprayPaintMenu;};
    case 3: {[1] spawn life_fnc_titleColorMenu;};};