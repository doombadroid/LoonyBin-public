params["_obj_main", "_spawns", "_stance", "_location"];
if (_obj_main isKindOf "CAManBase") then {};
switch (_location) do {case "Kavala": {
            _obj_main addAction["Chop Shop", life_fnc_chopShopMenu, "chop_shop_1", 1.5, false, false, "", 'playerside isEqualTo civilian', 5];
            _obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
            }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
            _obj_main addAction["Gang Garage", {["Car", _this select 3, true] call life_fnc_handleVehicles;
            }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
            _obj_main addAction["RV Shop", life_fnc_vehicleShopMenu, ["civ_special", civilian, _spawns, "civ", "LoonyBin RV"], 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player', 5];
        }; case "Athira": {
                _obj_main addAction["Chop Shop", life_fnc_chopShopMenu, "chop_shop_2", 1.5, false, false, "", 'playerside isEqualTo civilian', 5];
                _obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
                _obj_main addAction["Gang Garage", {["Car", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
                _obj_main addAction["RV Shop", life_fnc_vehicleShopMenu, ["civ_special", civilian, _spawns, "civ", "LoonyBin RV"], 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player', 5];
            };};