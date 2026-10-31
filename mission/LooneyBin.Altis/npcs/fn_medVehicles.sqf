params["_obj_main", "_spawns", "_stance", ["_type", "", [""]]];
if (_obj_main isKindOf "CAManBase") then {};
switch (_type) do {case "ground": {
            _obj_main addAction["NG Vehicle Shop", life_fnc_vehicleShopMenu, ["med_car", independent, _spawns, "med", "NG Motorpool"], 1.5, false, false, "", 'playerSide isEqualTo independent', 5];
            _obj_main addAction["Firefighter Garage", life_fnc_vehicleShopMenu, ["firefighter_car", independent, _spawns, "med", "Firefighter Garage"], 1.5, false, false, "", 'playerSide isEqualTo independent && life_isActiveFirefighter', 5];
            _obj_main addAction["NG Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
            }, _spawns, 1.5, false, false, "", 'playerSide isEqualTo independent', 5];
            _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && playerSide isEqualTo independent', 5];
        }; case "air": {
                _obj_main addAction["NG Air Shop", life_fnc_vehicleShopMenu, ["med_air", independent, _spawns, "med", "NG Helicopters"], 1.5, false, false, "", 'playerSide isEqualTo independent', 5];
                _obj_main addAction["NG Air Garage", {["Air", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'playerSide isEqualTo independent', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && playerSide isEqualTo independent', 5];
            };
        case "boat": {
                _obj_main addAction["NG Boat Shop", life_fnc_vehicleShopMenu, ["med_ship", independent, _spawns, "med", "NG Boat Shop"], 1.5, false, false, "", 'playerSide isEqualTo independent && isNull objectParent player', 5];
                _obj_main addAction["NG Boat Garage", {["Ship", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'playerSide isEqualTo independent && isNull objectParent player', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && playerSide isEqualTo independent && isNull objectParent player', 5];
            };
        case "boatGround": {
                _obj_main addAction["NG Boat Shop", life_fnc_vehicleShopMenu, ["med_ship", independent, _spawns, "med", "NG Boat Shop"], 1.5, false, false, "", 'playerSide isEqualTo independent && isNull objectParent player', 5];
                _obj_main addAction["NG Boat Garage", {["Ship", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'playerSide isEqualTo independent && isNull objectParent player', 5];
                _obj_main addAction["NG Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'playerSide isEqualTo independent', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && playerSide isEqualTo independent && isNull objectParent player', 5];
            };};
