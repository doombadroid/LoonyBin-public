params["_obj_main", "_spawns", "_stance", "_turf"];
if (_obj_main isKindOf "CAManBase") then {};
switch (_turf) do {case "Rodopoli": {
            _obj_main addAction["Turf Car Shop", life_fnc_vehicleShopMenu, ['civ_car', civilian, _spawns, 'civ', "LoonyBin Turf Vehicles"], 1.5, false, false, "", 'playerSide isEqualTo civilian && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (rodo_flag getVariable ["plb_turf_data", []] select 0)}', 5];
            _obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
            }, _spawns, 1.5, false, false, "", '!life_garage_store && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (rodo_flag getVariable ["plb_turf_data", []] select 0)}', 5];
            _obj_main addAction["Helicopter Garage", {["Air", _this select 3] call life_fnc_handleVehicles;
            }, _spawns, 1.5, false, false, "", '!life_garage_store && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (rodo_flag getVariable ["plb_turf_data", []] select 0)} && 7 in life_gang_talents', 5];
            _obj_main addAction["Gang Ground Garage", {["Car", _this select 3, true] call life_fnc_handleVehicles;
            }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3) && {(life_gang_data select 0) isEqualTo (rodo_flag getVariable ["plb_turf_data", []] select 0)} && 7 in life_gang_talents', 5];
            _obj_main addAction["Gang Air Garage", {["Air", _this select 3, true] call life_fnc_handleVehicles;
            }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3) && {(life_gang_data select 0) isEqualTo (rodo_flag getVariable ["plb_turf_data", []] select 0)} && 7 in life_gang_talents', 5];
            _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 0, false, false, "", '!life_garage_store && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (rodo_flag getVariable ["plb_turf_data", []] select 0)}', 5];
        }; case "Zaros": {
                _obj_main addAction["Turf Car Shop", life_fnc_vehicleShopMenu, ['civ_car', civilian, _spawns, 'civ', "LoonyBin Turf Vehicles"], 1.5, false, false, "", 'playerSide isEqualTo civilian && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (zaros_flag getVariable ["plb_turf_data", []] select 0)}', 5];
                _obj_main addAction["Ground Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", '!life_garage_store && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (zaros_flag getVariable ["plb_turf_data", []] select 0)}', 5];
                _obj_main addAction["Helicopter Garage", {["Air", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", '!life_garage_store && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (zaros_flag getVariable ["plb_turf_data", []] select 0)} && 7 in life_gang_talents', 5];
                _obj_main addAction["Gang Ground Garage", {["Car", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3) && {(life_gang_data select 0) isEqualTo (zaros_flag getVariable ["plb_turf_data", []] select 0)} && 7 in life_gang_talents', 5];
                _obj_main addAction["Gang Air Garage", {["Air", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3) && {(life_gang_data select 0) isEqualTo (zaros_flag getVariable ["plb_turf_data", []] select 0)} && 7 in life_gang_talents', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 0, false, false, "", '!life_garage_store && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (zaros_flag getVariable ["plb_turf_data", []] select 0)}', 5];
            };
        case "Panagia": {
                _obj_main addAction["Turf Car Shop", life_fnc_vehicleShopMenu, ['civ_car', civilian, _spawns, 'civ', "LoonyBin Turf Vehicles"], 1.5, false, false, "", 'playerSide isEqualTo civilian && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (panagia_flag getVariable ["plb_turf_data", []] select 0)}', 5];
                _obj_main addAction["Ground Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", '!life_garage_store && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (panagia_flag getVariable ["plb_turf_data", []] select 0)}', 5];
                _obj_main addAction["Helicopter Garage", {["Air", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", '!life_garage_store && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (panagia_flag getVariable ["plb_turf_data", []] select 0)} && 7 in life_gang_talents', 5];
                _obj_main addAction["Gang Ground Garage", {["Car", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3) && {(life_gang_data select 0) isEqualTo (panagia_flag getVariable ["plb_turf_data", []] select 0)} && 7 in life_gang_talents', 5];
                _obj_main addAction["Gang Air Garage", {["Air", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3) && {(life_gang_data select 0) isEqualTo (panagia_flag getVariable ["plb_turf_data", []] select 0)} && 7 in life_gang_talents', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 0, false, false, "", '!life_garage_store && !(life_gang_data isEqualTo []) && {(life_gang_data select 0) isEqualTo (panagia_flag getVariable ["plb_turf_data", []] select 0)}', 5];
            };};