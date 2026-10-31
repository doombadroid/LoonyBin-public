
params[["_mode", "", [""]], ["_spawnPoints", "", ["", [], objNull]], ["_playerObj", objNull, [objNull]], ["_centerVehicle", objNull, [objNull]]];
private _buyPrice = 40000;
switch (_mode) do {case ("buyMobileHQ"): {if !(35 in life_cop_talents) exitWith {
                ["You do not have the prestige talent to pull this vehicle.", "basic"] spawn life_fnc_handleMessage;};
            private _action = [format["Are you sure you want to buy the mobile HQ for %1?", _buyPrice], "Mobile HQ", "Yes", "No"] call BIS_fnc_guiMessage;
            if !(_action) exitWith {};
            private _spawnPoint = "";
            if (_spawnPoints isEqualType[]) then {_spawnPoints = _spawnPoints select {"_g_" in (str _x)};
                _spawnPoint = _spawnPoints param[_spawnPoints findIf {
                    nearestObjects[getMarkerPos _x, ["Car", "Ship"], 5] isEqualTo[] && nearestObjects[getMarkerPos _x, ["Air"], 14] isEqualTo[]
                }, ""];} else {if (_spawnPoints isEqualType "") then {
                    if (nearestObjects[getMarkerPos _spawnPoints, ["Car", "Ship"], 5] isEqualTo[] && nearestObjects[getMarkerPos _spawnPoints, ["Air"], 14] isEqualTo[]) then {
                        _spawnPoint = _spawnPoints};} else {
                    if (nearestObjects[getPosATL _spawnPoints, ["Car", "Ship"], 5] isEqualTo[] && nearestObjects[getPosATL _spawnPoints, ["Air"], 14] isEqualTo[]) then {
                        _spawnPoint = _spawnPoints};};};
            if (_spawnPoint isEqualTo "") exitWith {
                ["There is a vehicle currently blocking the spawn point(s).", "basic"] spawn life_fnc_handleMessage;};
            if !([_buyPrice] call life_fnc_debitCard) exitWith {
                ["You do not have enough money to buy this", "basic"] spawn life_fnc_handleMessage;};
            if (_spawnPoint in [civ_air_carrier_1, civ_air_carrier_2, civ_air_carrier_3]) exitWith {
                ["You can not spawn a mobile HQ here", "basic"] spawn life_fnc_handleMessage;};
            [6] call life_fnc_ClupdatePartial;
            private _markerPos =
            if (_spawnPoint isEqualType objNull) then {getPosATL _spawnPoint} else {getMarkerPos _spawnPoint};
            _markerPos set[2, (_markerPos select 2) + 1.5];
            private _vehicle = createVehicle["B_Truck_01_covered_F", [random 999, random 999, 999], [], 0, "CAN_COLLIDE"];
            waitUntil {!isNil "_vehicle" && {!isNull _vehicle}};
            _vehicle lock true;
            _vehicle allowDamage false;
            if (_spawnPoint isEqualType objNull) then {
                _vehicle setDir([((direction _spawnPoint) - 90), direction _spawnPoint] select("VR" in typeOf _spawnPoint))} else {
                _vehicle setDir(markerDir _spawnPoint)};
            _vehicle setPos _markerPos;
            _vehicle setVectorUp(surfaceNormal _markerPos);
            playSound "purchase";
            [_vehicle] call life_fnc_clearVehicleAmmo;
            clearItemCargoGlobal _vehicle;
            clearBackpackCargoGlobal _vehicle;
            uiSleep 1;
            [_vehicle, [0, 0, 0, 0], 0, "", [0, 1], false, false, false, false, true] spawn life_fnc_prepareVehicle;   // owner 2026-06-13: full fuel (was 0.5)
        }; case ("setupMobileHQ"): {if (isNull _centerVehicle) exitWith {};
                if !(alive _centerVehicle) exitWith {};
                if (speed _centerVehicle > 0) exitWith {[1, "The vehicle has to be stationary to set up the HQ."] spawn life_fnc_broadcast;
                };
                private _exit = false; {if (_centervehicle distance2D(getMarkerPos _x) < 1500) exitWith {
                        ["You must be 1500m from a federal event to set up the HQ.", "basic"] spawn life_fnc_handleMessage;
                        _exit = true;};}
                forEach["life_mentalHospital", "fed_reserve", "life_convoy_start", "armory_marker", "life_bank", "corrections"];
                if (_exit) exitWith {}; {if (_centervehicle distance2D(getMarkerPos _x) < 1000) exitWith {
                        ["This area is controlled by a gang (Move 1000m away)", "basic"] spawn life_fnc_handleMessage;
                        _exit = true;};}
                forEach["illegal_warlord", "gang_fortress_marker", "turf_area_panagia_flag", "turf_area_rodo_flag", "turf_area_zaros_flag", "arms_cartel", "drug_cartel", "oil_cartel", "wongs_cartel"];
                if (_exit) exitWith {};
                private _nearBuildings = nearestObjects[_centerVehicle, ["house"], 30];
                if !(_nearBuildings isEqualTo[]) exitWith {
                    [1, "You need to be 30m+ from a building to set the Mobile HQ up."] spawn life_fnc_broadcast;};
                if ((SRV_mobileHQ param[0, -1800]) > (serverTime - (60 * 30))) exitWith {
                    [1, format["The APD is out of building supplies for another mobile HQ. Try again in %1 minute(s).", ceil(((SRV_mobileHQ param[0, -1800]) - (serverTime - (60 * 30))) / 60)]] spawn life_fnc_broadcast;
                };
                if (SRV_mobileHQ select 2) exitWith {[1, "There is already a Mobile HQ being set up."] spawn life_fnc_broadcast;};
                private _action = [format["Are you sure you want to setup the mobile HQ?"], "Mobile HQ", "Yes", "No"] call BIS_fnc_guiMessage;
                if !(_action) exitWith {};
                _centerVehicle setVariable["plb_mobileHeadQuartersTruckLocked", true, true];
                (_playerObj) moveOut _centerVehicle;
                SRV_mobileHQ set[2, true];
                publicVariable "SRV_mobileHQ";
                private _level =
                switch (true) do {case (37 in life_cop_talents): {2};
                    case (36 in life_cop_talents): {1};
                    default {0};}; [[ _playerObj , _centerVehicle, _level], "TON_fnc_srvMobileHQ", 2] spawn life_fnc_MP;
                [1, "Setting up the APD Mobile HQ. Keep the surrounding area clear!"] spawn life_fnc_broadcast;};
        case ("setupShops"): {private _data = SRV_mobileHQ select 3;
                private _level = ((_data) select 0);
                private _gearNPC = ((_data) select 1);
                private _vehicleNPC = ((_data) select 2);
                private _base = _data param [3, objNull];                  // owner 2026-06-20: HQ base building (pack-up action target)
                private _vehSpawns = _data param [5, ["cop_g_mobile"]];     // owner 2026-06-20: per-deploy spawn markers -- ground motor pool (right) + air helipad (left)
                if !(isNull _gearNPC) then {[_gearNPC, 'STAND_U1', 'general'] call NPC_fnc_copShops;
                    [_gearNPC, 'STAND_U1', 'copdive'] call NPC_fnc_copShops;};
                if !(isNull _vehicleNPC) then {if (_level == 1) then {
                        [_vehicleNPC, _vehSpawns, 'STAND_U1', 'ground'] call NPC_fnc_copVehicles;};
                    if (_level == 2) then {[_vehicleNPC, _vehSpawns, 'STAND_U1', 'airground'] call NPC_fnc_copVehicles;};};
                // owner 2026-06-20 (item 2): scroll-wheel "Pack Up" on the HQ base. Sets a public flag the server's
                // teardown waitUntil catches -> despawns the whole HQ (base/NPCs/helipad/markers). West-only +
                // confirm dialog so a stray scroll can't nuke the HQ.
                if (!isNull _base) then {_base addAction ["<t color='#FF6666'>Pack Up Mobile HQ</t>", {params ["_tgt", "_caller"];
                            private _ok = ["Pack up and despawn the Mobile HQ? This removes the base, NPCs and helipad.", "Mobile HQ", "Yes", "No"] call BIS_fnc_guiMessage;
                            if (_ok) then {_tgt setVariable ["plb_mobileHQPackup", true, true];
                                ["Packing up the Mobile HQ...", "basic"] spawn life_fnc_handleMessage;};}, nil, 1.5, true, true, "",
                        'playerSide isEqualTo west && (_target distance _this < 8)', 5];};};};