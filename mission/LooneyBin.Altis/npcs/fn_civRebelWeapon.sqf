params["_obj_main", "_stance"];
_obj_main addAction["Rebel Training ($12,500) (replace bounty hunter)", life_fnc_buyLicense, "rebel", 1.5, false, false, "", '!license_civ_rebel && playerSide isEqualTo civilian', 5];
_obj_main addAction["Loadout System", life_fnc_loadoutMenu, "rebel", 1.5, false, false, "", 'license_civ_rebel && playerSide isEqualTo civilian', 5];
_obj_main addAction["Rebel Clothing Shop", life_fnc_clothingMenu, "rebcloth", 1.5, false, false, "", 'license_civ_rebel && playerSide isEqualTo civilian', 5];
_obj_main addAction["Civilian Clothing Shop", life_fnc_clothingMenu, "civ", 1.5, false, false, "", 'license_civ_rebel && playerSide isEqualTo civilian', 5];
_obj_main addAction["Rebel Weapon Shop", life_fnc_weaponShopMenu, "rebelwep", 1.5, false, false, "", 'license_civ_rebel && playerSide isEqualTo civilian', 5];
_obj_main addAction["Rebel Market", life_fnc_virtualShopMenu, "rebel", 1.5, false, false, "", 'license_civ_rebel && playerSide isEqualTo civilian', 5];
_obj_main addAction["New Drachma Clothes", life_fnc_clothingMenu, ["rebcloth", true], 1.5, false, false, "", 'license_civ_rebel && playerSide isEqualTo civilian', 5];
_obj_main addAction["New Drachma Weapons", life_fnc_weaponShopMenu, ["rebelwep", true], 1.5, false, false, "", 'license_civ_rebel && playerSide isEqualTo civilian', 5];
_obj_main addAction["<t color='#5be39c'>ND Heavy Weapons</t>", life_fnc_weaponShopMenu, ["ndheavy", true], 1.5, false, false, "", 'license_civ_rebel && playerSide isEqualTo civilian', 5];
_obj_main addAction["Refill Magazines", life_fnc_refillAmmo, "", 1.5, false, false, "", 'license_civ_rebel && playerSide isEqualTo civilian', 5];
_obj_main addAction["EMT Item Shop", life_fnc_virtualShopMenu, "hospital", 1.5, false, false, "", '', 5];
_obj_main addAction["Medical Assistance", life_fnc_healHospital, "", 1.5, false, false, "", '', 5];
_obj_main addAction["Medical Dispensary", life_fnc_virtualShopMenu, "medicaldispensary", 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player && license_civ_rebel', 5];
_obj_main addAction["<t color='#ADFF2F'>ATM</t>", {[] call life_fnc_atmMenu}, nil, 2, true, true, "", 'isNull objectParent player', 5];
_obj_main addAction["<t color='#FFFF2F'>Gang Account</t>", {[] call life_fnc_gangAtmMenu
}, nil, 2, true, true, "", '(count life_gang_data > 0)', 5];
