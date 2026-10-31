params["_obj_main", "_stance", "_applyCop"];
if (_obj_main isKindOf "CAManBase") then {};
switch (_applyCop) do {case true: {_obj_main addAction["Skydive! ($200)", life_fnc_skyDive, "", 1.5, false, false, "", '', 5];
            _obj_main addAction["Join the Police", life_fnc_policeRecruit, "", 1.5, false, false, "", 'playerSide isEqualTo civilian', 5];
        };
    case false: {_obj_main addAction["Skydive! ($200)", life_fnc_skyDive, "", 1.5, false, false, "", 'playerSide isEqualTo civilian', 5];
            _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store', 5];}}