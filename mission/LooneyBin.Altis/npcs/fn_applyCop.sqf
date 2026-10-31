params["_obj_main", "_stance"];
if (_obj_main isKindOf "CAManBase") then {
    // LoonyBin (owner 2026-06-13): cop NPCs wear the "SGT Grumpy" APD rank uniform (was SWAT combat uniform)
    // owner 2026-06-16: strip uniform (naked) -- U_Rangemaster IS the APD look & the sgt_grumpy texture
    // override no-ops on it. owner 2026-07-10: SKIP when the map data dressed this NPC with a custom
    // loadout (Eden round-trip, fn_createVehicleLocal tags plb_hasLoadout) -- stripping undid the outfit.
    if !(_obj_main getVariable ["plb_hasLoadout", false]) then { removeUniform _obj_main; };};
_obj_main addAction["Join the Police", life_fnc_policeRecruit, "", 1.5, false, false, "", ' playerSide isEqualTo civilian ', 5];