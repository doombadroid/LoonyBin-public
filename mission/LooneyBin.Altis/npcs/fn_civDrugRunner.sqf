params["_obj_main", "_spawns", "_stance", "_location"];
if (_obj_main isKindOf "CAManBase") then {};
switch (_location) do {case 1: {
            _obj_main addAction["Get Plane Drug Runner Job", life_fnc_airplaneDrugRunner, 1, 1.5, false, false, "", 'life_drug_stage isEqualTo 0', 5];
            _obj_main addAction["Load Drugs on Plane", {life_drug_stage = 2
            }, "", 1.5, false, false, "", '(life_drug_stage isEqualTo 1) && (life_drug_end isEqualTo _target)', 5];
            _obj_main addAction["Deliver to Smuggler", {life_drug_stage = 3
            }, "", 1.5, false, false, "", '(life_drug_stage isEqualTo 2) && (life_drug_end isEqualTo _target)', 5];
            _obj_main addAction["Abandon Job!", life_fnc_airplaneDrugRunner, 0, 1.5, false, false, "", '(life_drug_stage >= 1)', 5];
            _obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
            }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
            _obj_main addAction["Helicopter Garage", {["Air", _this select 3] call life_fnc_handleVehicles;
            }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
            _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 1.5, false, false, "", '!life_garage_store'];};
    case 2: {
            _obj_main addAction["Get Plane Drug Runner Job", life_fnc_airplaneDrugRunner, 2, 1.5, false, false, "", 'life_drug_stage isEqualTo 0', 5];
            _obj_main addAction["Load Drugs on Plane", {life_drug_stage = 2
            }, "", 1.5, false, false, "", '(life_drug_stage isEqualTo 1) && (life_drug_end isEqualTo _target)', 5];
            _obj_main addAction["Deliver to Smuggler", {life_drug_stage = 3
            }, "", 1.5, false, false, "", '(life_drug_stage isEqualTo 2) && (life_drug_end isEqualTo _target)', 5];
            _obj_main addAction["Abandon Job!", life_fnc_airplaneDrugRunner, 0, 1.5, false, false, "", '(life_drug_stage >= 1)', 5];
            _obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
            }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
            _obj_main addAction["Helicopter Garage", {["Air", _this select 3] call life_fnc_handleVehicles;
            }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
            _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 0, false, false, "", '!life_garage_store', 5];};
    case 3: {
            _obj_main addAction["Get Plane Drug Runner Job", life_fnc_airplaneDrugRunner, 3, 1.5, false, false, "", 'life_drug_stage isEqualTo 0', 5];
            _obj_main addAction["Load Drugs on Plane", {life_drug_stage = 2
            }, "", 1.5, false, false, "", '(life_drug_stage isEqualTo 1) && (life_drug_end isEqualTo _target)', 5];
            _obj_main addAction["Deliver to Smuggler", {life_drug_stage = 3
            }, "", 1.5, false, false, "", '(life_drug_stage isEqualTo 2) && (life_drug_end isEqualTo _target)', 5];
            _obj_main addAction["Abandon Job!", life_fnc_airplaneDrugRunner, 0, 1.5, false, false, "", '(life_drug_stage >= 1)', 5];
            _obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
            }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
            _obj_main addAction["Helicopter Garage", {["Air", _this select 3] call life_fnc_handleVehicles;
            }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
            _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 0, false, false, "", '!life_garage_store', 5];};
    case 4: {
            _obj_main addAction["Get Plane Drug Runner Job", life_fnc_airplaneDrugRunner, 4, 1.5, false, false, "", 'life_drug_stage isEqualTo 0', 5];
            _obj_main addAction["Load Drugs on Plane", {life_drug_stage = 2
            }, "", 1.5, false, false, "", '(life_drug_stage isEqualTo 1) && (life_drug_end isEqualTo _target)', 5];
            _obj_main addAction["Deliver to Smuggler", {life_drug_stage = 3
            }, "", 1.5, false, false, "", '(life_drug_stage isEqualTo 2) && (life_drug_end isEqualTo _target)', 5];
            _obj_main addAction["Abandon Job!", life_fnc_airplaneDrugRunner, 0, 1.5, false, false, "", '(life_drug_stage >= 1)', 5];
            _obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
            }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
            _obj_main addAction["Helicopter Garage", {["Air", _this select 3] call life_fnc_handleVehicles;
            }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
            _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 0, false, false, "", '!life_garage_store', 5];};
    case 5: {
            _obj_main addAction["Get Plane Drug Runner Job", life_fnc_airplaneDrugRunner, 5, 1.5, false, false, "", 'life_drug_stage isEqualTo 0', 5];
            _obj_main addAction["Load Drugs on Plane", {life_drug_stage = 2
            }, "", 1.5, false, false, "", '(life_drug_stage isEqualTo 1) && (life_drug_end isEqualTo _target)', 5];
            _obj_main addAction["Deliver to Smuggler", {life_drug_stage = 3
            }, "", 1.5, false, false, "", '(life_drug_stage isEqualTo 2) && (life_drug_end isEqualTo _target)', 5];
            _obj_main addAction["Abandon Job!", life_fnc_airplaneDrugRunner, 0, 1.5, false, false, "", '(life_drug_stage >= 1)', 5];
            _obj_main addAction["Vehicle Garage", {["Car", _this select 3] call life_fnc_handleVehicles;
            }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
            _obj_main addAction["Helicopter Garage", {["Air", _this select 3] call life_fnc_handleVehicles;
            }, _spawns, 1.5, false, false, "", 'isNull objectParent player', 5];
            _obj_main addAction["Store vehicle in Garage", life_fnc_storeVehicle, "", 0, false, false, "", '!life_garage_store', 5];};};