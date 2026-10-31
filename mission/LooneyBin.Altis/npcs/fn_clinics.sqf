params["_obj_main", "_stance", "_type"];
if (_obj_main isKindOf "CAManBase") then {};
switch (_type) do {case "clinic": {_obj_main addAction["<t color='#ADFF2F'>ATM</t>", {[] call life_fnc_atmMenu
            }, nil, 2, true, true, "", 'isNull objectParent player', 5];
            _obj_main addAction["Medical Assistance", life_fnc_healHospital, "", 1.5, false, false, "", '', 5];
            _obj_main addAction["NG Item Shop", life_fnc_virtualShopMenu, "hospital", 1.5, false, false, "", 'playerSide isEqualTo civilian', 5];
            _obj_main addAction["NG Item Shop", life_fnc_virtualShopMenu, "meditemshop", 1.5, false, false, "", 'playerSide isEqualTo independent', 5];
            _obj_main addAction["NG Equipment Shop", life_fnc_weaponShopMenu, "med_basic", 1.5, false, false, "", 'playerSide isEqualTo independent', 5];
            _obj_main addAction["Check in to Rehab", {[] spawn life_fnc_rehab}, "", 0, false, false, "", '', 5];}; case "hospital": {
                _obj_main addAction["<t color='#ADFF2F'>ATM</t>", {[] call life_fnc_atmMenu
                }, nil, 2, true, true, "", 'isNull objectParent player', 5];
                _obj_main addAction["Medical Assistance", life_fnc_healHospital, "", 1.5, false, false, "", '', 5];
                _obj_main addAction["NG Item Shop", life_fnc_virtualShopMenu, "hospital", 1.5, false, false, "", 'playerSide isEqualTo civilian', 5];
                _obj_main addAction["NG Item Shop", life_fnc_virtualShopMenu, "meditemshop", 1.5, false, false, "", 'playerSide isEqualTo independent', 5];
                _obj_main addAction["NG Equipment Shop", life_fnc_weaponShopMenu, "med_basic", 1.5, false, false, "", 'playerSide isEqualTo independent', 5];
                _obj_main addAction["Check in to Rehab", {[] spawn life_fnc_rehab}, "", 0, false, false, "", '', 5];};
        case "clothing": {
                _obj_main addAction["Loadout System", life_fnc_loadoutMenu, "medic", 1.5, false, false, "", 'playerSide isEqualTo independent', 5];
                _obj_main addAction["NG Uniform Shop", life_fnc_clothingMenu, "med", 1.5, false, false, "", 'playerSide isEqualTo independent', 5];
                _obj_main addAction["Redeploy Me!", life_fnc_redeployMenu, "", 1.5, false, false, "", 'playerSide isEqualTo independent', 5];
                // owner 2026-07-13: firefighting opened to ALL independent-whitelisted NG. Removed the separate
                // Register/Resign firefighter whitelist (life_isFirefighter) and the medic-level requirement --
                // any NG can now respond to an active fire directly from the clinic.
                _obj_main addAction["<t color='#8b2b13'>Respond to Active Fire</t>", {
                    ["toggleFirefighter", [SRV_houseOnFire]] spawn life_fnc_medicFireClient
                }, "", 1.5, false, false, "", '(playerSide isEqualTo independent) && !life_isActiveFirefighter && (count SRV_houseOnFire != 0)', 5];
            };};
"<img image='mpmissions\__cur_mp.altis\icons\canna_rawpapers.paa' /> <t color='#8b2b13'>Sign Up As Firefighter</t>"
