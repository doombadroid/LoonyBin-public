params["_type"];
switch (_type) do {case "init": {if (!isNil "life_light") then {deleteVehicle life_light};
            life_light = "#lightpoint"
            createVehicleLocal[0, 0, 0];
            life_light setLightBrightness 1;
            life_light setLightDayLight false;
            ["update"] call life_fnc_brightNight;}; case "update": {life_nightBrightness = life_nightBrightness max 0 min 1;
                private _brightness =
                if (life_nightBrightness > 0) then {600 * abs(1 - (2 ^ life_nightBrightness))} else {0};
                life_light setLightAttenuation[10e10, (30000 / (_brightness max 10e-10)), 4.31918e-005, 4.31918e-005];
                life_light setLightAmbient[0.3, 0.5, 1];};
        default {};};