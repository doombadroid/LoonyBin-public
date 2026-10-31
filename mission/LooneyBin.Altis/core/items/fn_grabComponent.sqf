/*
    life_fnc_grabComponent  (client) -- pick a crypto component out of a federal-event hardware case.
*/
params [["_crate", objNull, [objNull]]];
if (isNull _crate) exitWith {};
if ((_crate getVariable ["plb_componentCrate", ""]) isEqualTo "") exitWith {};
[["grab", player, _crate], "TON_fnc_miningSRV", 2] spawn life_fnc_MP;
