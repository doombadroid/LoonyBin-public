params[["_caseType", "", [""]], "_sprayCanData"];

switch (_caseType) do {case ("createSpray"): {_sprayCanData params[["_cursorObject", objNull, [objNull]]];
            if (serverTime < (profileNamespace getVariable["plb_recent_spray", [0, 0]] param[1, 0])) exitWith {
                [format["You have a recent spray active! Try again in %1 second(s).", round((profileNamespace getVariable["plb_recent_spray", [0, 0]] param[1, 0]) - serverTime)], "basic"] spawn life_fnc_handleMessage;
            };
            private _savedSprayImage = profileNameSpace getVariable["plb_savedSprayImage", [0, "Dog Poop", "images\spraycan\sprayPoopDog.paa", true]];
            _savedSprayImage params["_IDX", "_Name", "_Path", "_Unlocked"];
            if !(_Unlocked) exitWith {};
            if ((player distance2D _cursorObject >= 20) || (isNull _cursorObject)) then {
                _sprayObject = createVehicle["UserTexture1m_F", [(getPosATL player param[0, 0]), (getPosATL player param[1, 0]), ((getPosATL player param[2, 0]) + 0.02)], [], 0, "CAN_COLLIDE"];
                _sprayObject setVectorUp surfaceNormal getPosWorld _sprayObject;
                private _y = 45;
                private _p = -90;
                private _r = 0;
                _sprayObject setVectorDirAndUp[[sin _y * cos _p, cos _y * cos _p, sin _p], [
                    [sin _r, -sin _p, cos _r * cos _p], -_y] call BIS_fnc_rotateVector2D];
                _sprayObject setPosATL[(getPosATL player param[0, 0]), (getPosATL player param[1, 0]), (getPosATL player param[2, 0]) + 0.05];
                _sprayObject setObjectTextureGlobal[0, _Path];
                playSound "sprayCanStart"; [[player, "sprayCanEnd"], "life_fnc_playSound", (allPlayers select {(_x distance player) <= 25
                    })] spawn life_fnc_MP; [[_sprayObject, 120], "TON_fnc_setCleanTime", 2] spawn life_fnc_MP;
                profileNameSpace setVariable["plb_recent_spray", [PLB_instance_id, serverTime + 120]];} else {
                private _sprayObject = "UserTexture1m_F"
                createVehicleLocal[getPosATL player param[0, 0], getPosATL player param[1, 0], (getPosATL player param[2, 0]) + 0.02];
                _sprayObject setObjectTexture[0, _Path];
                _sprayObject attachTo[player, [0, 1, 1.10]];
                _sprayObject addEventHandler["handleDamage", {private _damage = 0.5;
                    private _plb_dmg = player;
                    _plb_dmg setDamage(damage player + _damage)}];
                life_sprayObject = _sprayObject; [[player, "sprayCanStart"], "life_fnc_playSound", (allPlayers select {
                        (_x distance player) <= 25})] spawn life_fnc_MP;
                waitUntil {uiSleep 0.1;
                    !(_sprayObject in (attachedObjects player))};
                private _globalSprayObj = createVehicle["UserTexture1m_F", [(getPosATL player param[0, 0]), (getPosATL player param[1, 0]), ((getPosATL player param[2, 0]) + 0.02)], [], 0, "CAN_COLLIDE"];
                _globalSprayObj setVectorDirAndUp[vectorDir _sprayObject, vectorUp _sprayObject];
                _globalSprayObj setDir(getDir _sprayObject);
                _globalSprayObj setPosATL(getPosATL _sprayObject);
                _savedSprayImage params["_IDX", "_Name", "_Path", "_Unlocked"];
                _globalSprayObj setObjectTextureGlobal[0, _Path]; [[_globalSprayObj, 120], "TON_fnc_setCleanTime", 2] spawn life_fnc_MP; [
                    [player, "sprayCanEnd"], "life_fnc_playSound", (allPlayers select {(_x distance player) <= 25})] spawn life_fnc_MP;
                profileNameSpace setVariable["plb_recent_spray", [PLB_instance_id, time + 120]];
                deleteVehicle life_sprayObject;};}; case ("setSpray"): {_sprayCanData params[["_localPicture", objNull, [objNull]]];
                if (_localPicture isNotEqualTo life_sprayObject) exitWith {};
                detach life_sprayObject;};};