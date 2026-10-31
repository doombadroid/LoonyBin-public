params["_obj_main", "_spawns", "_stance", "_type"];
if (_obj_main isKindOf "CAManBase") then {};
_obj_main addAction["African Warlord", life_fnc_virtualShopMenu, "africanwarlord", 1.5, false, false, "", 'playerSide isEqualTo civilian', 5];