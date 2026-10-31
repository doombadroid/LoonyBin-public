params["_obj_main", "_stance"];
// owner 2026-06-15: de-brand the cop BOUNTY NPC -> OUR sgt_grumpy APD skin (was the bare stock uniform = the
// stock upstream APD look). Was an empty CAManBase block.
if (_obj_main isKindOf "CAManBase") then {
    // owner 2026-06-16: strip uniform (naked) -- U_Rangemaster IS the APD look & the sgt_grumpy texture
    // override no-ops on it. owner 2026-07-10: SKIP when the map data dressed this NPC with a custom
    // loadout (Eden round-trip, fn_createVehicleLocal tags plb_hasLoadout) -- stripping undid the outfit.
    if !(_obj_main getVariable ["plb_hasLoadout", false]) then { removeUniform _obj_main; };};
_obj_main addAction["Track Fugitive", {[] call life_fnc_requestBounty
}, false, 1.5, false, false, "", 'playerSide isEqualTo west && life_coprole in ["warrant","all"]', 5];