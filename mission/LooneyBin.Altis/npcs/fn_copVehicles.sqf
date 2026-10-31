params["_obj_main", "_spawns", "_stance", ["_type", "", [""]]];
// owner 2026-06-15: de-brand the cop VEHICLE vendor (ground/air/sea) -> OUR sgt_grumpy APD skin (was the bare
// stock B_Survivor_F/B_Pilot_F uniform = the stock upstream APD look).
if (_obj_main isKindOf "CAManBase") then {
    // owner 2026-06-16: strip uniform (naked) -- U_Rangemaster IS the APD look & the sgt_grumpy texture
    // override no-ops on it. owner 2026-07-10: SKIP when the map data dressed this NPC with a custom
    // loadout (Eden round-trip, fn_createVehicleLocal tags plb_hasLoadout) -- stripping undid the outfit.
    if !(_obj_main getVariable ["plb_hasLoadout", false]) then { removeUniform _obj_main; };};
private _type =
_type;
switch (_type) do {case "ground": {
            _obj_main addAction["Report for SWAT Duty", life_fnc_swatEnroll, nil, 2, false, true, "", 'playerSide isEqualTo west && SRV_SWATrequested && life_isSwat && !life_activeSWAT', 5];
            _obj_main addAction["<t color='#1E90FF'>SWAT Garage</t>", life_fnc_vehicleShopMenu, ["swat_car", west, _spawns, "cop", "SWAT Garage"], 1.5, false, false, "", 'playerSide isEqualTo west && life_isSwat', 5];
            _obj_main addAction["Car Shop", life_fnc_vehicleShopMenu, ["cop_car", west, _spawns, "cop", "LoonyBin Car"], 1.5, false, false, "", 'playerSide isEqualTo west', 5];
            _obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
            }, _spawns, 1.5, false, false, "", 'playerSide isEqualTo west', 5];
            _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && playerSide isEqualTo west', 5];
            if !("cop_g_mobile" in _spawns) then {_obj_main addAction["Buy mobile HQ", {
                    ["buyMobileHQ", _this select 3] spawn life_fnc_clientMobileHQ;
                }, _spawns, 1.5, false, false, "", 'playerSide isEqualTo west && (call life_copLevel >= 4)', 5];};}; case "srt": {
                _obj_main addAction["SRT Vehicle Shop", life_fnc_vehicleShopMenu, ["srt_car", west, _spawns, "cop", "SRT Garage"], 1.5, false, false, "", 'playerSide isEqualTo west', 5];
                _obj_main addAction["SRT Ground Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'playerSide isEqualTo west', 5];
                _obj_main addAction["SRT Air Garage", {["Air", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'playerSide isEqualTo west', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && playerSide isEqualTo west', 5];
            };
        case "airground": {
                _obj_main addAction["Report for SWAT Duty", life_fnc_swatEnroll, nil, 2, false, true, "", 'playerSide isEqualTo west && SRV_SWATrequested && life_isSwat && !life_activeSWAT', 5];
                _obj_main addAction["<t color='#1E90FF'>SWAT Garage</t>", life_fnc_vehicleShopMenu, ["swat_car", west, _spawns, "cop", "SWAT Garage"], 1.5, false, false, "", 'playerSide isEqualTo west && life_isSwat', 5];
                _obj_main addAction["Car Shop", life_fnc_vehicleShopMenu, ["cop_car", west, _spawns, "cop", "LoonyBin Car"], 1.5, false, false, "", 'playerSide isEqualTo west', 5];
                _obj_main addAction["Helicopter Shop", life_fnc_vehicleShopMenu, ["cop_air", west, _spawns, "cop", "LoonyBin Helicopter"], 1.5, false, false, "", 'playerSide isEqualTo west', 5];
                _obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'playerSide isEqualTo west', 5];
                _obj_main addAction["Helicopter Garage", {["Air", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'playerSide isEqualTo west', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && playerSide isEqualTo west', 5];
            };
        case "boatGround": {
                _obj_main addAction["Report for SWAT Duty", life_fnc_swatEnroll, nil, 2, false, true, "", 'playerSide isEqualTo west && SRV_SWATrequested && life_isSwat', 5];
                _obj_main addAction["Boat Shop", life_fnc_vehicleShopMenu, ["cop_ship", west, _spawns, "cop", "Cop Boat Shop"], 1.5, false, false, "", 'playerSide isEqualTo west && license_cop_cg', 5];
                _obj_main addAction["Boat Garage", {["Ship", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'playerSide isEqualTo west && license_cop_cg', 5];
                _obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'playerSide isEqualTo west', 5];
                _obj_main addAction["Cop Boat License ($800)", life_fnc_buyLicense, "cg", 1.5, false, false, "", '!license_cop_cg && playerSide isEqualTo west', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && playerSide isEqualTo west', 5];
            };
        case "air": {
                _obj_main addAction["Report for SWAT Duty", life_fnc_swatEnroll, nil, 2, false, true, "", 'playerSide isEqualTo west && SRV_SWATrequested && life_isSwat && !life_activeSWAT', 5];
                _obj_main addAction["Helicopter Shop", life_fnc_vehicleShopMenu, ["cop_air", west, _spawns, "cop", "LoonyBin Helicopter"], 1.5, false, false, "", 'playerSide isEqualTo west', 5];
                _obj_main addAction["Helicopter Garage", {["Air", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'playerSide isEqualTo west', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && playerSide isEqualTo west', 5];
            };
        case "sea": {
                _obj_main addAction["Report for SWAT Duty", life_fnc_swatEnroll, nil, 2, false, true, "", 'playerSide isEqualTo west && SRV_SWATrequested && life_isSwat && !life_activeSWAT', 5];
                _obj_main addAction["Boat Shop", life_fnc_vehicleShopMenu, ["cop_ship", west, _spawns, "cop", "Cop Boat Shop"], 1.5, false, false, "", 'playerSide isEqualTo west && license_cop_cg', 5];
                _obj_main addAction["Boat Garage", {["Ship", _this select 3] call life_fnc_handleVehicles;
                }, _spawns, 1.5, false, false, "", 'playerSide isEqualTo west && license_cop_cg', 5];
                _obj_main addAction["Cop Boat License ($800)", life_fnc_buyLicense, "cg", 1.5, false, false, "", '!license_cop_cg && playerSide isEqualTo west', 5];
                _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store && playerSide isEqualTo west', 5];
            };};