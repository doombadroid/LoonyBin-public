params[["_caseType", "", [""]], ["_repairHouseData", [], [[]]]];
switch (_caseType) do {case ("requestRepair"): {private _ruins =
            if ((((typeOf cursorObject) find "ruin") != -1) || (((typeOf cursorObject) find "dam") != -1)) then {cursorObject} else {
                objNull};
            if (isNull _ruins) exitWith {["You must be looking at the ruins of the building!"] spawn life_fnc_handleMessage};
            if ((allPlayers select {(side _x isEqualTo independent) && (_x distance(getMarkerPos "Respawn_west") > 1000)
            }) isEqualTo[]) exitWith {
                ["There's currently no NG medics available to repair your building. Please try again later.", "basic"] spawn life_fnc_handleMessage
            };
            private _building = (nearestTerrainObjects[player, ["House"], 7, true, true]) param[0, objNull];
            private _building =
            if (_building getVariable["plb_terrainObject_repaired", false]) then {
                (nearestObjects[player, ["House"], 7, true, true]) param[0, objNull]} else {_building};
            private _buildingRepairPrice = (([typeOf _building] call life_fnc_houseConfig) param[1, 150000]) * 0.3;
            if (_building getVariable["plb_houseOnFire", false]) exitWith {
                ["You can't request NG repair on a burning building!"] spawn life_fnc_handleMessage};
            if (life_atmCash < _buildingRepairPrice) exitWith {
                [format["You don't have enough money to have this building repaired. It requires $%1.", [_buildingRepairPrice] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage
            };
            private _confirm = [format["Having this building repaired will cost $%1. Are you sure?", [_buildingRepairPrice] call life_fnc_numberText], "NG Building Repair", "Yes", "No"] call BIS_fnc_guiMessage;
            if !(_confirm) exitWith {}; [
                ["requestRepair", [_ruins, _building, player]], "life_fnc_medicRepairBuilding", independent] spawn life_fnc_MP;
            _building setVariable["plb_repairRequested", true, true];
            ["The NG has been notified of your building repair request.", "basic"] spawn life_fnc_handleMessage;};
        case ("kitRepair"): {
            // owner 2026-06-23: CIV self-repairs their OWN destroyed house with a House Repair Kit (Hospital shop,
            // $50k, consumed per repair). Same repair as a medic's actionRepair, minus the NG payment -- the kit IS
            // the cost. Home-owner only. Anti-dupe: re-check the kit at completion before consuming.
            if (life_inv_houserepairkit < 1) exitWith { ["You don't have a House Repair Kit.", "basic"] spawn life_fnc_handleMessage };
            private _ruins = if ((((typeOf cursorObject) find "ruin") != -1) || (((typeOf cursorObject) find "dam") != -1)) then { cursorObject } else { objNull };
            if (isNull _ruins) exitWith { ["You must be looking at the ruins of your building!", "basic"] spawn life_fnc_handleMessage };
            private _building = (nearestTerrainObjects[player, ["House"], 7, true, true]) param[0, objNull];
            if (_building getVariable["plb_terrainObject_repaired", false]) then { _building = (nearestObjects[player, ["House"], 7, true]) param[0, objNull]; };
            if (isNull _building) exitWith {};
            if !(damage _building isEqualTo 1) exitWith { ["This building isn't destroyed.", "basic"] spawn life_fnc_handleMessage };
            if (_building getVariable["plb_houseOnFire", false]) exitWith { ["You can't repair a burning building!", "basic"] spawn life_fnc_handleMessage };
            if !((_building getVariable["plb_homeOwner", ""]) isEqualTo (getPlayerUID player)) exitWith { ["You can only repair a house you own.", "basic"] spawn life_fnc_handleMessage };
            if !(isNull(_building getVariable["plb_repairingBuilding", objNull])) exitWith { ["This building is already being repaired.", "basic"] spawn life_fnc_handleMessage };
            _building setVariable["plb_repairingBuilding", player, true];
            disableSerialization;
            5 cutRsc["life_progress", "PLAIN"];
            private _ui = uiNamespace getVariable "life_progress";
            private _progress = _ui displayCtrl 38201;
            private _pgText = _ui displayCtrl 38202;
            private _text = format["Repairing %1", getText(configFile >> "CfgVehicles" >> typeOf _building >> "displayName")];
            _pgText ctrlSetText format["%2 (1%1)...", "%", _text];
            _progress progressSetPosition 0.01;
            life_action_in_use = true;
            private _cP = 0.01;
            private _success = false;
            private _startPos = getPos player;
            ["Acts_carFixingWheel", 12] spawn life_fnc_handleAnim;
            for "_i" from 0 to 1 step 0 do {uiSleep 0.6;
                _cP = _cP + 0.01;
                _progress progressSetPosition _cP;
                _pgText ctrlSetText format["%3 (%1%2)...", round(_cP * 100), "%", _text];
                if (life_isDowned || !(alive player) || !(life_action_in_use) || isWeaponDeployed player || player getVariable["plb_restrained", false] || player getVariable["plb_surrendered", false]) exitWith {};
                if (player distance _startPos > 4 || !(damage _building isEqualTo 1) || !(player isEqualTo(_building getVariable["plb_repairingBuilding", objNull]))) exitWith {};
                if (_cP >= 1) exitWith { _success = true };};
            5 cutText["", "PLAIN"];
            life_action_in_use = false;
            [] spawn life_fnc_handleAnim;
            _building setVariable["plb_repairingBuilding", nil, true];
            if !(_success) exitWith {};
            if (life_inv_houserepairkit < 1) exitWith {};   // re-check: still hold the kit at completion (anti-dupe)
            life_inv_houserepairkit = (life_inv_houserepairkit - 1) max 0;
            life_carryWeight = (life_carryWeight - (["getItemWeight", "houserepairkit"] call life_fnc_virtItemCfg)) max 0;
            [0] call life_fnc_ClupdatePartial;
            private _index = life_vehicles find _building;
            if !(_index isEqualTo - 1) then { life_vehicles set[_index, -1]; life_vehicles = life_vehicles - [-1]; };
            _index = [str(getPosATL _building), life_houses] call life_fnc_index;
            if !(_index isEqualTo - 1) then { life_houses set[_index, -1]; life_houses = life_houses - [-1]; };
            _building setVariable["plb_repairRequested", false, true];
            [[player, _building, _ruins], "TON_fnc_repairBuildingSRV", 2] spawn life_fnc_MP;
            [format["You repaired your %1 with a House Repair Kit.", getText(configFile >> "CfgVehicles" >> typeOf _building >> "displayName")], "basic"] spawn life_fnc_handleMessage;
            [["-HOUSEREPAIR-", player, (profileName), format["self-repaired with a House Repair Kit. House Type: %1, House ID: %2, House Pos: %3", typeOf _building, _building getVariable["plb_houseID", -1], getPos _building]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
        };
        case ("payForRequest"): {
                _repairHouseData params[["_building", objNull, [objNull]], ["_ruins", objNull, [objNull]], ["_medic", objNull, [objNull]]];
                if (isNull _building || isNull _medic) exitWith {};
                private _buildingBuyPrice = ([typeOf _building] call life_fnc_houseConfig) param[1, 150000];
                private _fee = _buildingBuyPrice * 0.3;
                if (life_atmCash < _fee) exitWith {
                    ["Your building was not successfully repaired due to your lack of funds.", "basic"] spawn life_fnc_handleMessage; [
                        ["The home owner failed to have enough funds to pay you for your repair of the building", "basic"], "life_fnc_handleMessage", _medic] spawn life_fnc_MP;
                }; [["action", "repairhouse", 1], "life_fnc_handleQuest", _medic] spawn life_fnc_MP;
                [format["Your %1 was repaired by %2%3 and a fee of $%4 was taken from your bank account.", getText(configFile >> "CfgVehicles" >> typeOf _building >> "displayName"), [independent, _medic] call life_fnc_getRankString, name _medic, [_fee] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
                _building setVariable["plb_repairRequested", false, true];
                private _index = life_vehicles find _building;
                if !(_index isEqualTo - 1) then {life_vehicles set[_index, -1];
                    life_vehicles = life_vehicles - [-1];};
                _index = [str(getPosATL _building), life_houses] call life_fnc_index;
                if !(_index isEqualTo - 1) then {life_houses set[_index, -1];
                    life_houses = life_houses - [-1];}; [[player, _building, _ruins], "TON_fnc_repairBuildingSRV", 2] spawn life_fnc_MP; [
                    ["repairPayment", [_fee, profileName, getText(configFile >> "CfgVehicles" >> typeOf _building >> "displayName")]], "life_fnc_medicRepairBuilding", _medic] spawn life_fnc_MP;
                [
                    ["-HOUSEREPAIR-", player, (profileName), format["House was repaired by NG Medic: %1, House Type: %2, House ID: %3, Amount Paid to Medic: $%4, House Pos: %5", name _medic, typeOf _building, _building getVariable["plb_houseID", -1], [_fee] call life_fnc_numberText, getPos _building]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
            };
        case ("houseRepaired"): {_repairHouseData params[["_newHouse", objNull, [objNull]], ["_oldHouse", objNull, [objNull]]];
                life_vehicles pushBack _newHouse;
                life_houses pushBack[(str(getPosATL _newHouse)), []]; {if !((_x find "phouse_") isEqualTo - 1) then {deleteMarker _x;};}
                forEach allMapMarkers;
                [] spawn life_fnc_CLinitHouses;};
        case ("gangHouseRepaired"): {_repairHouseData params[["_newHouse", objNull, [objNull]], ["_oldHouse", objNull, [objNull]]];
                if !((life_gang_data param[3, [0, 0, 0]]) isEqualTo[0, 0, 0]) then {if !(isNull _newHouse) then {waitUntil {uiSleep 1;
                            !(isNil {_newHouse getVariable "plb_house_gang"})};
                        private _gangID = _newHouse getVariable["plb_house_gang", -1];
                        private _gangOwner = _newHouse getVariable["plb_homeOwner", ""];
                        private _houseTypes = ["getHouses"] call life_fnc_houseConfig;
                        if (_gangID isEqualTo - 1 || _gangOwner isEqualTo "") exitWith {};
                        if !((typeOf _newHouse) in _houseTypes) exitWith {};
                        life_gangBuilding = [_newHouse, getPosATL _newHouse];
                        if (_gangOwner isEqualTo(getPlayerUID player)) exitWith {};
                        life_vehicles deleteAt(life_vehicles find _oldHouse);
                        life_houses deleteAt(life_houses find(str(getPosATL _oldHouse)));
                        deleteMarkerLocal life_gangBldgMark;
                        life_gangBldgMark = "";
                        private _marker = createMarkerLocal[format["phouse_%1%2", _gangID, _gangOwner], getPosATL _newHouse];
                        _marker setMarkerTextLocal "Gang Building";
                        _marker setMarkerColorLocal "ColorGreen";
                        _marker setMarkerTypeLocal "mil_end";
                        life_gangBldgMark = _marker;};};};};