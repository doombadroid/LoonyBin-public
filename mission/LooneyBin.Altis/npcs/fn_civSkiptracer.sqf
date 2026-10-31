params["_obj_main", "_stance"];
if (_obj_main isKindOf "CAManBase") then {};
_obj_main addAction["<t color='#ADFF2F'>ATM</t>", {[] call life_fnc_atmMenu}, nil, 2, true, true, "", 'isNull objectParent player', 5];
_obj_main addAction["Loadout System", life_fnc_loadoutMenu, "skiptracer", 1.5, false, false, "", 'license_civ_bounty && playerSide isEqualTo civilian && (8 in life_side_talents)', 5];
_obj_main addAction["Bounty Hunter Shop", life_fnc_weaponShopMenu, "bounty", 1.5, false, false, "", 'license_civ_bounty && playerSide isEqualTo civilian', 5];
_obj_main addAction["Bounty Hunter Item Shop", life_fnc_virtualShopMenu, "vig", 1.5, false, false, "", 'license_civ_bounty && playerSide isEqualTo civilian', 5];
_obj_main addAction["Skiptracer Clothing Shop", life_fnc_clothingMenu, "skip", 1.5, false, false, "", ' license_civ_bounty && playerSide isEqualTo civilian && 8 in life_side_talents', 5];
_obj_main addAction["Skiptracer Weapon Shop", life_fnc_weaponShopMenu, "skiptracer", 1.5, false, false, "", 'license_civ_bounty && playerSide isEqualTo civilian && (8 in life_side_talents)', 5];
_obj_main addAction["Bounty Hunter Training ($12,500) <t color='#FF0000'>(replace rebel)</t>", life_fnc_buyLicense, "bounty", 1.5, false, false, "", '!license_civ_bounty && playerSide isEqualTo civilian && (1 in life_side_talents)', 5];
_obj_main addAction["Skiptracer Item Shop", life_fnc_virtualShopMenu, "skiptracer", 1.5, false, false, "", ' license_civ_bounty && playerSide isEqualTo civilian && (8 in life_side_talents)', 5];
_obj_main addAction["Request Bounty", {[] call life_fnc_requestBounty
}, nil, 1.5, false, false, "", ' license_civ_bounty && playerSide isEqualTo civilian && (8 in life_side_talents)', 5];
_obj_main addAction["General Store", life_fnc_weaponShopMenu, "genstore", 1.5, false, false, "", 'isNull objectParent player', 5];
_obj_main addAction["Refill Magazines", life_fnc_refillAmmo, "", 1.5, false, false, "", 'license_civ_bounty && playerSide isEqualTo civilian', 5];
_obj_main addAction["EMT Item Shop", life_fnc_virtualShopMenu, "hospital", 1.5, false, false, "", '', 5];
_obj_main addAction["Medical Assistance", life_fnc_healHospital, "", 1.5, false, false, "", '', 5];