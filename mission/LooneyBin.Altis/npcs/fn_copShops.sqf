params["_obj_main", "_stance", "_type"];
// owner 2026-06-13 (#170): same shop-building protection as fn_shops -- block the cop-shop building from
// being bought as a house (plb_restricted_house was never set anywhere).
if (!isNull _obj_main) then {private _ht = if (isNil "life_houseTypes") then { ["House_F"] } else { life_houseTypes };
    // owner 2026-06-20: flag the nearest UN-OWNED house-type building, skipping registered player houses (see fn_shops)
    // -- a player house within 10m of a cop-shop NPC was being grabbed + restricted, killing the owner's house menu.
    {if ((_x getVariable ["plb_homeOwner", ""]) isEqualTo "") exitWith { _x setVariable ["plb_restricted_house", true]; };
    } forEach (nearestObjects [getPosATL _obj_main, _ht, 10]);};
// owner 2026-06-15: de-brand EVERY cop-shop NPC (gear vendor 'general', diving, copdive). They wore the bare
// stock Rangemaster -- the stock upstream APD look -> dress them all in OUR own sgt_grumpy APD skin (the
// owner's asset), matching the cop recruiter (NPC_fnc_applyCop). U_Rangemaster is vanilla; the .jpg is ours.
if (_obj_main isKindOf "CAManBase") then {
    // owner 2026-06-16: strip uniform (naked) -- U_Rangemaster IS the APD look & the sgt_grumpy texture
    // override no-ops on it. owner 2026-07-10: SKIP when the map data dressed this NPC with a custom
    // loadout (Eden round-trip, fn_createVehicleLocal tags plb_hasLoadout) -- stripping undid the outfit.
    if !(_obj_main getVariable ["plb_hasLoadout", false]) then { removeUniform _obj_main; };};
switch (_type) do {case "general": {
            _obj_main addAction["Report for SWAT Duty", life_fnc_swatEnroll, nil, 2, false, true, "", 'playerSide isEqualTo west && SRV_SWATrequested && life_isSwat && !life_activeSWAT', 5];
            _obj_main addAction["<t color='#1E90FF'>SWAT Armory</t>", life_fnc_weaponShopMenu, "swat_weapons", 2, false, false, "", 'playerSide isEqualTo west && life_isSwat', 5];
            _obj_main addAction["<t color='#ADFF2F'>ATM</t>", {[] call life_fnc_atmMenu
            }, nil, 2, true, true, "", 'isNull objectParent player', 5];
            _obj_main addAction["Loadout System", life_fnc_loadoutMenu, "cop", 1.5, false, false, "", 'playerSide isEqualTo west && !life_activeSWAT', 5];
            _obj_main addAction["Redeploy Me!", life_fnc_redeployMenu, "", 1.5, false, false, "", 'playerSide isEqualTo west && (PLB_Server isEqualTo 1)', 5];
            _obj_main addAction["Gear Up!", life_fnc_reGear, "", 1.5, false, false, "", 'playerSide isEqualTo west && count life_dead_gear > 0 && !life_activeSWAT && !life_eviSpawn && (PLB_Server isEqualTo 1)', 5];
            _obj_main addAction["Police Items Shop", life_fnc_virtualShopMenu, "cop", 1.5, false, false, "", 'playerSide isEqualTo west', 5];
            // owner 2026-07-20: APD-issue VR goggles -- the hardware gate for the TAL OS quick-hack ring (SHIFT+Y). See talos.md.
            _obj_main addAction["<t color='#33ffbb'>APD VR Goggles</t> <t color='#c9e21a'>($1,000)</t> <t color='#7f918a'>-- TAL OS visor ring</t>",
                {private _paid = if (life_cash >= 1000) then { ["cash", "take", 1000] call life_fnc_uC }
                                    else { (life_inv_debitcard >= 1) && {["atm", "take", 1000] call life_fnc_uC} };
                    if !(_paid) exitWith { ["You need $1,000 -- cash, or bank with a debit card.", "basic"] spawn life_fnc_handleMessage; };
                    player addGoggles "G_Goggles_VR";
                    ["<t color='#33ffbb'>APD VR GOGGLES</t> -- visor online. Wear them and press <t color='#c9e21a'>SHIFT+Y</t> for TAL OS.", "basic"] spawn life_fnc_handleMessage;
                }, nil, 1.5, false, false, "",
                'playerSide isEqualTo west && isNull objectParent player && !((goggles player) isEqualTo "G_Goggles_VR")', 5];
            _obj_main addAction["Police Uniform Shop", life_fnc_clothingMenu, "cop", 1.5, false, false, "", 'playerSide isEqualTo west  && !life_activeSWAT', 5];
            _obj_main addAction["Police Equipment Shop", life_fnc_weaponShopMenu, "police_equipment", 1.5, false, false, "", 'playerSide isEqualTo west', 5];
            _obj_main addAction["Police Weapons Shop", life_fnc_weaponShopMenu, "police_weapons", 1.5, false, false, "", 'playerSide isEqualTo west && !life_activeSWAT', 5];
            _obj_main addAction["Air Training ($1,500)", life_fnc_buyLicense, "pilot", 1.5, false, false, "", '!license_cop_air && playerSide isEqualTo west && (call life_copLevel) > 1', 5];
            _obj_main addAction["EMT Item Shop", life_fnc_virtualShopMenu, "hospital", 1.5, false, false, "", 'isNull objectParent player && playerSide isEqualTo west', 5];
            _obj_main addAction["Medical Assistance", life_fnc_healHospital, "", 1.5, false, false, "", '', 5];
            _obj_main addAction["Refill Magazines", life_fnc_refillAmmo, "", 1.5, false, false, "", 'playerSide isEqualTo west', 5];
}; case "diving": {
                _obj_main addAction["Refill Magazines", life_fnc_refillAmmo, "", 1.5, false, false, "", 'playerSide isEqualTo west && (call life_copLevel) > 1', 5];
            };
        case "copdive": {
                _obj_main addAction["Diving Shop", life_fnc_clothingMenu, "copdive", 1.5, false, false, "", 'playerSide isEqualTo west && (call life_copLevel) > 1', 5];
            };};