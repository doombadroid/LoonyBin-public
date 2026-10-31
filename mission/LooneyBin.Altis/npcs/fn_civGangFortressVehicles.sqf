params["_obj_main", "_spawns", "_stance"];
if (_obj_main isKindOf "CAManBase") then {};
_obj_main addAction["Rebel Car Shop", life_fnc_vehicleShopMenu, ['reb_car', civilian, _spawns, 'reb', "LoonyBin Rebel Vehicles"], 1.5, false, false, "", 'license_civ_rebel && isNull objectParent player && (life_gang_data isNotEqualTo []) && (!((gang_fortress_flag getVariable ["plb_gang_fortress_data", [-1, "Unknown", false]]) param [2, false]) && ((gang_fortress_flag getVariable ["plb_gang_fortress_data", [-1, "Unknown", false]]) param [0, -1]) isEqualTo (life_gang_data param [0, -1]))
', 5];
_obj_main addAction["New Drachma Car Shop", life_fnc_vehicleShopMenu, ['nd_car', civilian, _spawns, 'reb', "LoonyBin New Drachma Vehicles"], 1.5, false, false, "", 'license_civ_rebel && isNull objectParent player && (life_gang_data isNotEqualTo []) && (!((gang_fortress_flag getVariable ["plb_gang_fortress_data", [-1, "Unknown", false]]) param [2, false]) && ((gang_fortress_flag getVariable ["plb_gang_fortress_data", [-1, "Unknown", false]]) param [0, -1]) isEqualTo (life_gang_data param [0, -1]))
', 5];
_obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
}, _spawns, 1.5, false, false, "", 'isNull objectParent player && (life_gang_data isNotEqualTo []) && (!((gang_fortress_flag getVariable ["plb_gang_fortress_data", [-1, "Unknown", false]]) param [2, false]) && ((gang_fortress_flag getVariable ["plb_gang_fortress_data", [-1, "Unknown", false]]) param [0, -1]) isEqualTo (life_gang_data param [0, -1]))
', 5];
_obj_main addAction["Helicopter Garage", {["Air", _this select 3] call life_fnc_handleVehicles;
}, _spawns, 1.5, false, false, "", 'isNull objectParent player && (life_gang_data isNotEqualTo []) && (!((gang_fortress_flag getVariable ["plb_gang_fortress_data", [-1, "Unknown", false]]) param [2, false]) && ((gang_fortress_flag getVariable ["plb_gang_fortress_data", [-1, "Unknown", false]]) param [0, -1]) isEqualTo (life_gang_data param [0, -1]))
', 5];
_obj_main addAction["Gang Ground Garage", {["Car", _this select 3, true] call life_fnc_handleVehicles;
}, _spawns, 1.5, false, false, "", 'isNull objectParent player && (life_gang_data isNotEqualTo []) && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3) && (!((gang_fortress_flag getVariable ["plb_gang_fortress_data", [-1, "Unknown", false]]) param [2, false]) && ((gang_fortress_flag getVariable ["plb_gang_fortress_data", [-1, "Unknown", false]]) param [0, -1]) isEqualTo (life_gang_data param [0, -1]))
', 5];
_obj_main addAction["Gang Air Garage", {["Air", _this select 3, true] call life_fnc_handleVehicles;
}, _spawns, 1.5, false, false, "", 'isNull objectParent player && (life_gang_data isNotEqualTo []) && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3) && (!((gang_fortress_flag getVariable ["plb_gang_fortress_data", [-1, "Unknown", false]]) param [2, false]) && ((gang_fortress_flag getVariable ["plb_gang_fortress_data", [-1, "Unknown", false]]) param [0, -1]) isEqualTo (life_gang_data param [0, -1]))
', 5];
_obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && isNull objectParent player && (life_gang_data isNotEqualTo []) && (!((gang_fortress_flag getVariable ["plb_gang_fortress_data", [-1, "Unknown", false]]) param [2, false]) && ((gang_fortress_flag getVariable ["plb_gang_fortress_data", [-1, "Unknown", false]]) param [0, -1]) isEqualTo (life_gang_data param [0, -1]))
', 5];