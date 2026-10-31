params["_obj_main", "_stance", "_turf"];
if (_obj_main isKindOf "CAManBase") then {};
_obj_main setVariable["plb_turfCloth", true];
switch (_turf) do {case "Rodopoli": {_obj_main addAction["<t color='#ADFF2F'>ATM</t>", {[] call life_fnc_atmMenu
            }, nil, 2, true, true, "", 'isNull objectParent player && playerSide isEqualTo civilian && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (rodo_flag getVariable ["plb_turf_data", []] select 0)}', 5];
            _obj_main addAction["<t color='#FFFF2F'>Gang Account</t>", {[] call life_fnc_gangAtmMenu
            }, nil, 2, true, true, "", '(count life_gang_data > 0)', 5];
            _obj_main addAction["Turf Clothing Shop", life_fnc_clothingMenu, "rebcloth", 1.5, false, false, "", 'playerSide isEqualTo civilian && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (rodo_flag getVariable ["plb_turf_data", []] select 0)}', 5];
            _obj_main addAction["Turf Weapon Shop", life_fnc_weaponShopMenu, "turf", 1.5, false, false, "", 'playerSide isEqualTo civilian && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (rodo_flag getVariable ["plb_turf_data", []] select 0)}', 5];
            _obj_main addAction["Turf Market", life_fnc_virtualShopMenu, "turf", 1.5, false, false, "", 'playerSide isEqualTo civilian && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (rodo_flag getVariable ["plb_turf_data", []] select 0)}', 5];
            _obj_main addAction["EMT Item Shop", life_fnc_virtualShopMenu, "hospital", 1.5, false, false, "", '(life_gang_data param [0, -45] isEqualTo (rodo_flag getVariable ["plb_turf_data", [-55]] select 0))', 5];
            _obj_main addAction["Medical Assistance", life_fnc_healHospital, "", 1.5, false, false, "", '(life_gang_data param [0, -45] isEqualTo (rodo_flag getVariable ["plb_turf_data", [-55]] select 0))', 5];
        }; case "Zaros": {_obj_main addAction["<t color='#ADFF2F'>ATM</t>", {[] call life_fnc_atmMenu
                }, nil, 2, true, true, "", 'isNull objectParent player && playerSide isEqualTo civilian && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (	zaros_flag getVariable ["plb_turf_data", []] select 0)}', 5];
                _obj_main addAction["<t color='#FFFF2F'>Gang Account</t>", {[] call life_fnc_gangAtmMenu
                }, nil, 2, true, true, "", '(count life_gang_data > 0)', 5];
                _obj_main addAction["Turf Clothing Shop", life_fnc_clothingMenu, "rebcloth", 1.5, false, false, "", 'playerSide isEqualTo civilian && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (zaros_flag getVariable 	["plb_turf_data", []] select 0)}', 5];
                _obj_main addAction["Turf Weapon Shop", life_fnc_weaponShopMenu, "turf", 1.5, false, false, "", 'playerSide isEqualTo civilian && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (zaros_flag getVariable ["plb_turf_data", []] select 0)}', 5];
                _obj_main addAction["Turf Market", life_fnc_virtualShopMenu, "turf", 1.5, false, false, "", 'playerSide isEqualTo civilian && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (zaros_flag getVariable ["plb_turf_data", []] select 0)}', 5];
                _obj_main addAction["EMT Item Shop", life_fnc_virtualShopMenu, "hospital", 1.5, false, false, "", '(life_gang_data param [0, -45] isEqualTo (zaros_flag getVariable ["plb_turf_data", [-55]] select 0))', 5];
                _obj_main addAction["Medical Assistance", life_fnc_healHospital, "", 1.5, false, false, "", '(life_gang_data param [0, -45] isEqualTo (zaros_flag getVariable ["plb_turf_data", [-55]] select 0))', 5];
            };
        case "Panagia": {_obj_main addAction["<t color='#ADFF2F'>ATM</t>", {[] call life_fnc_atmMenu
                }, nil, 2, true, true, "", 'isNull objectParent player && playerSide isEqualTo civilian && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (panagia_flag getVariable ["plb_turf_data", []] select 0)}', 5];
                _obj_main addAction["<t color='#FFFF2F'>Gang Account</t>", {[] call life_fnc_gangAtmMenu
                }, nil, 2, true, true, "", '(count life_gang_data > 0)', 5];
                _obj_main addAction["Turf Clothing Shop", life_fnc_clothingMenu, "rebcloth", 1.5, false, false, "", 'playerSide isEqualTo civilian && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (panagia_flag getVariable ["plb_turf_data", []] select 0)}', 5];
                _obj_main addAction["Turf Weapon Shop", life_fnc_weaponShopMenu, "turf", 1.5, false, false, "", 'playerSide isEqualTo civilian && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (panagia_flag getVariable ["plb_turf_data", []] select 0)}', 5];
                _obj_main addAction["Turf Market", life_fnc_virtualShopMenu, "turf", 1.5, false, false, "", 'playerSide isEqualTo civilian && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (panagia_flag getVariable ["plb_turf_data", []] select 0)}', 5];
                _obj_main addAction["EMT Item Shop", life_fnc_virtualShopMenu, "hospital", 1.5, false, false, "", '(life_gang_data param [0, -45] isEqualTo (panagia_flag getVariable ["plb_turf_data", [-55]] select 0))', 5];
                _obj_main addAction["Medical Assistance", life_fnc_healHospital, "", 1.5, false, false, "", '(life_gang_data param [0, -45] isEqualTo (panagia_flag getVariable ["plb_turf_data", [-55]] select 0))', 5];
            };};