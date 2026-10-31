params["_obj_main", "_spawns", "_stance", "_type"];
if (_obj_main isKindOf "CAManBase") then {};
private _buyPilotLoadout = {private _plb_player = player;
    private _action = ["Do you want to purchase a pilot outfit for $5,000? This will replace your current outfit entirely!", "Pilot Outfit", "Yes", "No"] call BIS_fnc_GUIMessage;
    if !(_action) exitWith {};
    if !([5000] call life_fnc_debitCard) exitWith {};
    _plb_player setUnitLoadout[[], [], [], ["U_Tank_green_F", []], [], ["B_Parachute", []], "H_HelmetB_Light_tna_F", "G_RegulatorMask_F", ["Rangefinder", "", "", "", [],
        [], ""], ["ItemMap", "", "", "ItemCompass", "ItemWatch", "Integrated_NVG_F"]];;};
switch (_type) do {case "carShop": {
            _obj_main addAction["Car Shop", life_fnc_vehicleShopMenu, ["civ_car", civilian, _spawns, "civ", "LoonyBin Autos"], 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player', 5];
            _obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
            }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
            _obj_main addAction["Gang Garage", {["Car", _this select 3, true] call life_fnc_handleVehicles;
            }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
            _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && isNull objectParent player', 5];
        }; case "heliGarage": {_obj_main addAction["Helicopter Garage", {["Air", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", '(playerSide isEqualTo civilian || playerSide isEqualTo west) && isNull objectParent player', 5];
                _obj_main addAction["Gang Garage", {["Air", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && isNull objectParent player', 5];
            };
        case "airshop": {
                _obj_main addAction["Helicopter Shop", life_fnc_vehicleShopMenu, ["civ_air", civilian, _spawns, "civ", "LoonyBin Air"], 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player', 5];
                _obj_main addAction["Helicopter Garage", {["Air", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", '(playerSide isEqualTo civilian || playerSide isEqualTo west) && isNull objectParent player', 5];
                _obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
                _obj_main addAction["Gang Ground Garage", {["Car", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
                _obj_main addAction["Gang Air Garage", {["Air", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && isNull objectParent player', 5];
            };
        case "boat": {
                _obj_main addAction["Boat Shop", life_fnc_vehicleShopMenu, ["civ_ship", civilian, _spawns, "civ", "LoonyBin Boat Marina"], 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player', 5];
                _obj_main addAction["Boat Shop", life_fnc_vehicleShopMenu, ["med_ship", independent, _spawns, "med", "NG Boat Shop"], 1.5, false, false, "", 'playerSide isEqualTo independent && isNull objectParent player', 5];
                _obj_main addAction["Boat Garage", {["Ship", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
                _obj_main addAction["Gang Garage", {["Ship", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && isNull objectParent player', 5];
            };
        case "boatGround": {
                _obj_main addAction["Boat Shop", life_fnc_vehicleShopMenu, ["civ_ship", civilian, _spawns, "civ", "LoonyBin Boat Marina"], 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player', 5];
                _obj_main addAction["Boat Shop", life_fnc_vehicleShopMenu, ["med_ship", independent, _spawns, "med", "NG Boat Shop"], 1.5, false, false, "", 'playerSide isEqualTo independent && isNull objectParent player', 5];
                _obj_main addAction["Boat Garage", {["Ship", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
                _obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
                _obj_main addAction["Gang Boat Garage", {["Ship", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
                _obj_main addAction["Gang Ground Garage", {["Car", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && isNull objectParent player', 5];
            };
        case "gokart": {_obj_main addAction["<t color='#ADFF2F'>ATM</t>", {[] call life_fnc_atmMenu
                }, nil, 2, true, true, "", 'isNull objectParent player', 5];
                _obj_main addAction["<t color='#FFFF2F'>Gang Account</t>", {[] call life_fnc_gangAtmMenu
                }, nil, 2, true, true, "", '(count life_gang_data > 0)', 5];
                _obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
                _obj_main addAction["Gang Garage", {["Car", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
                _obj_main addAction["Go-Kart Shop", life_fnc_vehicleShopMenu, ["civ_kart", civilian, _spawns, "civ", "LoonyBin Karts"], 1.5, false, false, "", '', 5];
                _obj_main addAction["Go-Kart Garage", {["Kart", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
                _obj_main addAction["Kart Clothing Store", life_fnc_clothingMenu, "kart", 1.5, false, false, "", '', 5];
                _obj_main addAction["Purchase Pilot Outfit", _buyPilotLoadout, "", 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && isNull objectParent player', 5];
            };
        case "groundAir": {
                _obj_main addAction["Helicopter Shop", life_fnc_vehicleShopMenu, ["civ_air", civilian, _spawns, "civ", "LoonyBin Air"], 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player', 5];
                _obj_main addAction["Helicopter Garage", {["Air", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", '(playerSide isEqualTo civilian || playerSide isEqualTo west) && isNull objectParent player', 5];
                _obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
                _obj_main addAction["Gang Ground Garage", {["Car", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
                _obj_main addAction["Gang Air Garage", {["Air", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && isNull objectParent player', 5];
            };
        case "truckShop": {
                _obj_main addAction["Truck Shop", life_fnc_vehicleShopMenu, ["civ_truck", civilian, _spawns, "civ", "LoonyBin Truck"], 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player', 5];
                _obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
                _obj_main addAction["Gang Garage", {["Car", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && isNull objectParent player', 5];
            };
        case "groundGarage": {_obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
                _obj_main addAction["Gang Garage", {["Car", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && isNull objectParent player', 5];
            };
        case "airground": {_obj_main addAction["Helicopter Garage", {["Air", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", '(playerSide isEqualTo civilian || playerSide isEqualTo west) && isNull objectParent player', 5];
                _obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
                _obj_main addAction["Gang Ground Garage", {["Car", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
                _obj_main addAction["Gang Air Garage", {["Air", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && isNull objectParent player', 5];
            };
        case "mechanic": {
                _obj_main addAction["Car Shop", life_fnc_vehicleShopMenu, ["civ_car", civilian, _spawns, "civ", "LoonyBin Autos"], 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player', 5];
                _obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
                _obj_main addAction["Gang Garage", {["Car", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
                _obj_main addAction["Mechanic Shop", life_fnc_virtualShopMenu, "gas", 1.5, false, false, "", 'isNull objectParent player', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && isNull objectParent player', 5];
            };
        case "RV": {
                _obj_main addAction["RV Shop", life_fnc_vehicleShopMenu, ["civ_special", civilian, _spawns, "civ", "LoonyBin RV"], 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player', 5];
                _obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
                _obj_main addAction["Gang Garage", {["Car", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && isNull objectParent player', 5];
            };
        case "vigi": {
                _obj_main addAction["Bounty Hunter Car Shop", life_fnc_vehicleShopMenu, ["bh_car", civilian, _spawns, "civ", "LoonyBin Autos"], 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player && license_civ_bounty', 5];
                _obj_main addAction["Helicopter Shop", life_fnc_vehicleShopMenu, ["civ_air", civilian, _spawns, "civ", "LoonyBin Air"], 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player && license_civ_bounty', 5];
                _obj_main addAction["Helicopter Garage", {["Air", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player && license_civ_bounty', 5];
                _obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
                _obj_main addAction["Gang Ground Garage", {["Car", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
                _obj_main addAction["Gang Air Garage", {["Air", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && isNull objectParent player', 5];
            };
        case "gov": {_obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
                _obj_main addAction["Gang Garage", {["Car", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && isNull objectParent player', 5];
            };
        case "sofiaGas": {_obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
                _obj_main addAction["Gang Garage", {["Car", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && isNull objectParent player', 5];
                _obj_main addAction["Gas Station", life_fnc_weaponShopMenu, "gas", 1.5, false, false, "", 'isNull objectParent player', 5];
                _obj_main addAction["<t color='#ADFF2F'>ATM</t>", {[] call life_fnc_atmMenu
                }, nil, 2, true, true, "", 'isNull objectParent player', 5];
                _obj_main addAction["<t color='#FFFF2F'>Gang Account</t>", {[] call life_fnc_gangAtmMenu
                }, nil, 2, true, true, "", '(count life_gang_data > 0)', 5];
                _obj_main addAction["Gas Market", life_fnc_virtualShopMenu, "gas", 1.5, false, false, "", '', 5];
                _obj_main addAction["Get Lottery Jackpot", {[0] call life_fnc_lottoTix
                }, "", 1.5, false, false, "", 'isNull objectParent player', 5];
                _obj_main addAction["<t color='#00BFFF'>Buy Lottery Ticket ($2,000)</t>", {[1] spawn life_fnc_lottoTix
                }, "", 0, false, false, "", 'isNull objectParent player', 5];};
        case "aircraftCarrier": {
                _obj_main addAction["Helicopter Shop", life_fnc_vehicleShopMenu, ["civ_air", civilian, _spawns, "civ", "LoonyBin Air"], 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player', 5];
                _obj_main addAction["Helicopter Garage", {["Air", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", '(playerSide isEqualTo civilian || playerSide isEqualTo west) && isNull objectParent player', 5];
                _obj_main addAction["Gang Air Garage", {["Air", _this select 3, true] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'isNull objectParent player && ((life_gang_data param [0, -1]) isNotEqualTo -1) && ((life_gang_data param [2, 5]) <= 3)', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && isNull objectParent player', 5];
            };};
