params[["_caseType", "", [""]], ["_vehicle", objNull, [objNull]]];
if (_caseType isEqualTo "" || isNull _vehicle) exitWith {};
switch (_caseType) do {case ("attachBomb"): {
            if !((_vehicle isKindOf "Car") || (_vehicle isKindOf "Air") || (_vehicle isKindOf "Ship") || (_vehicle isKindOf "Tank")) exitWith {
                ["The explosive cannot be fitted to this vehicle!"] spawn life_fnc_handleMessage};
            if (speed(vehicle player) > 0) exitWith {
                ["This vehicle must be at a standstill before you start adding explosives!"] spawn life_fnc_handleMessage};
            if !([false, "phonebomb", 1] call life_fnc_handleInv) exitWith {
                ["You don't have an remote explosive in your inventory!"] spawn life_fnc_handleMessage};
            if (_vehicle getVariable["plb_phoneBombActive", false]) exitWith {
                ["There is already a remote explosive attached to this vehicle!"] spawn life_fnc_handleMessage};
            if (life_remoteExplosive isNotEqualTo[objnull, -1]) exitWith {
                ["You already have a remote explosive active!"] spawn life_fnc_handleMessage};
            private _displayName = (getText(configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName"));
            disableSerialization;
            5 cutRsc["life_progress", "PLAIN"];
            private _text = format["Priming Remote Explosive to %1", _displayName];
            private _ui = uiNamespace getVariable "life_progress";
            private _progress = _ui displayCtrl 38201;
            private _pgText = _ui displayCtrl 38202;
            _pgText ctrlSetText format["%2 (1%1)...", "%", _text];
            _progress progressSetPosition 0.01;
            private _cP = 0.01;
            private _success = false;
            life_action_in_use = true; [["Acts_TerminalOpen", 30, "switchMove", player], "life_fnc_handleAnim", (allPlayers select {
                    (_x distance player) <= 100})] spawn life_fnc_MP;
            for "_i"
            from 0 to 1 step 0 do {uiSleep 0.15;
                _cP = _cP + 0.01;
                _progress progressSetPosition _cP;
                _pgText ctrlSetText format["%3 (%1%2)...", round(_cP * 100), "%", _text];
                if (_cP >= 1) exitWith {_success = true;};
                if !(isNull objectParent player) exitWith {
                    ["You cannot enter a vehicle while planting the explosives."] spawn life_fnc_handleMessage};
                if (speed(vehicle player) > 0) exitWith {
                    ["The vehicle cannot move while planting the explosives."] spawn life_fnc_handleMessage};
                if !(alive player) exitWith {};
                if !(life_action_in_use) exitWith {};};
            ["", 0 , "switchMove", player] spawn life_fnc_handleAnim;
            5 cutText["", "PLAIN"];
            life_action_in_use = false;
            if !(_success) exitWith {[true, "phonebomb", 1] call life_fnc_handleInv;};
            life_side_exp = life_side_exp + 20;
            (_vehicle getVariable["plb_dbInfo", []]) params[["_vehOwner", "", [""]], ["_plateID", -1, [0]]]; [
                ["-PHONEBOMB-", player, profileName, format["attached a remote explosive to a %1, Plate: %2, belonging to %3, POS: %4.", (getText(configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName")), _plateID, _vehOwner, getPosATL _vehicle]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
            [format["You have inserted a remote explosive to this %1. Call your remote detonator via the cellphone app!", _displayName]] spawn life_fnc_handleMessage;
            life_remoteExplosive = +[_vehicle, _plateID];
            _vehicle setVariable["plb_phoneBombActive", true, true];
            profileNamespace setVariable["plb_cellphone_bomb", [PLB_instance_id, _vehicle, _plateID]];}; case ("callInBomb"): {
                if (_vehicle isNotEqualTo(life_remoteExplosive param[0, objNull])) exitWith {};
                private _distanceMeters = round(player distance2D _vehicle);
                private _damageRadius = 15;
                if (_distanceMeters >= 1000) exitWith {
                    [format["You must be within 1km of your remote explosive to reach it's signal. You are currently %1 meters away.", _distanceMeters], "basic"] spawn life_fnc_handleMessage
                };
                (_vehicle getVariable["plb_dbInfo", []]) params[["_vehOwner", "", [""]], ["_plate", -1, [0]]];
                [] spawn {life_phoneCallStatus = 1;
                    if !(isNull(findDisplay 9500)) then {[] spawn life_fnc_cellphone_call;};
                    uiSleep 3;
                    life_phoneCallStatus = 2;
                    if !(isNull(findDisplay 9500)) then {[] spawn life_fnc_cellphone_call;};
                    uiSleep 5;
                    life_phoneCallStatus = 0;
                    if !(isNull(findDisplay 9500)) then {[] spawn life_fnc_cellphone_call;};};
                ["You have started calling your remote detonator...", "basic"] spawn life_fnc_handleMessage;
                playSound "bombPhoneInit";
                uiSleep 3.7;
                playSound "bombPhoneAnswer";
                uiSleep 0.5;
                playSound "bombPhoneAnswerTalk";
                uiSleep 2;
                playSound "bombPhoneLoop";
                uiSleep 1;
                private _bomb = "Bo_Mk82"
                createVehicle[0, 0, 9999];
                private _plb_pos = getPosATL _vehicle;
                _bomb setPosATL _plb_pos;
                _bomb setVelocity[100, 0, 0];
                private _nearVehicles = nearestObjects[_vehicle, ["Car", "Truck", "Air", "Ship"], 15]; {private _plb_dmg = _x;
                    _plb_dmg setDamage 1;}
                forEach _nearVehicles; [
                    ["-PHONEBOMB-", player, profileName, format["detonated their remote explosive attached to a %1, Plate: %2, belonging to %3, POS: %4.", (getText(configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName")), _plate, _vehOwner, getPos _vehicle]], "TON_fnc_logIt", 2, false, false] call life_fnc_MP;
                [[0, format["A remote explosive planted by %1 has detonated!", profileName]], "life_fnc_broadcast", -2] spawn life_fnc_MP; [
                    [2, player], "TON_fnc_wantedAdd", 2] spawn life_fnc_MP;
                ["remotecarexplosive", 1] call life_fnc_statArrUpdate;
                life_remoteExplosive = +[objNull, -1];
                profileNamespace setVariable["plb_cellphone_bomb", [PLB_instance_id, objNull, -1]];};};