params["_obj_main", "_stance"];
if (_obj_main isKindOf "CAManBase") then {};
_obj_main addAction["Hunting Weapon Shop", life_fnc_weaponShopMenu, "huntingwep", 1.5, false, false, "", 'playerSide isEqualTo civilian', 5];
_obj_main addAction["Hunting Item Shop", life_fnc_virtualShopMenu, "hunting", 1.5, false, false, "", 'playerSide isEqualTo civilian', 5];
_obj_main addAction["<t color='#ADFF2F'>ATM</t>", {[] call life_fnc_atmMenu}, nil, 2, true, true, "", 'isNull objectParent player', 5];