params[["_caseType", "", [""]], "_govData"];
switch (_caseType) do {case ("initGovClient"): {_govData params["_thisSelect29"];
            _thisSelect29 =
            if (_thisSelect29 isEqualTo[]) then {[false, false, false, false, 12391021, "ASSADFT3", -2200]} else {_thisSelect29};
            _thisSelect29 params["_isGov", "_isCandidate", "_hasVoted", "_hasPardoned", "_lastSessionID", "_lastElectionID", "_lastTimeConfigChanged"];
            private _newElection = !((SRV_governorData param[6, 0]) isEqualTo _lastElectionID);   // electedAt = per-term identity
            private _serverRestarted = !(PLB_instance_id isEqualTo _lastSessionID);
            private _isGov = ((SRV_governorData param[0, "GovUID"]) isEqualTo(getPlayerUID player));
            private _hasPardoned =
            switch (true) do {case (!_hasPardoned && _serverRestarted): {false};
                case (_hasPardoned && !_serverRestarted): {true};
                case (_hasPardoned && _serverRestarted): {false};
                default {false};}; private _hasVoted =
            switch (true) do {case (!_hasVoted && _newElection): {false};
                case (_hasVoted && !_newElection): {true};
                case (_hasVoted && _newElection): {false};
                default {false};}; private _isCandidate =
            switch (true) do {case (!_isCandidate && _newElection): {false};
                case (_isCandidate && !_newElection): {true};
                case (_isCandidate && _newElection): {false};
                default {false};}; private _lastTimeConfigChanged =
            if (_serverRestarted) then {-2200} else {_lastTimeConfigChanged};
            life_govTax set[0, _isGov];
            life_govClientData = [_isGov, _isCandidate, _hasVoted, _hasPardoned, PLB_instance_id, (SRV_governorData param[6, 0]), _lastTimeConfigChanged];
            // owner 2026-06-13: apply current weed legality on join. Markers are LOCAL and only configChanged
            // updates them (on change), so a fresh/JIP client must set the current state here.
            if (SRV_governorData param[3, false]) then {
                { _x setMarkerColorLocal "ColorGreen" } forEach ["weed_1", "weed_2"]; "Weed_p_2" setMarkerAlphaLocal 1;} else {
                { _x setMarkerColorLocal "ColorRed" } forEach ["weed_1", "weed_2"]; "Weed_p_2" setMarkerAlphaLocal 0;};
        }; case ("newGovChosen"): {_govData params["_newGovData"];
                _newGovData params["_xPlayerUID", "_xPlayerName", "_voteCount"];
                ["GovMessage", [format["%1 has been elected into Office of %2!", _xPlayerName, worldName]]] call BIS_fnc_showNotification;
            };
        case ("updateConfig"): {_govData params["_updatedArray"];
                // owner 2026-06-13: pass player so the server can verify the caller IS the governor (security).
                [["updateGovConfig", [player, _updatedArray]], "TON_fnc_govSystemSRV", 2] spawn life_fnc_MP; [
                    ["configChanged", [_updatedArray]], "life_fnc_govSystem", -2] spawn life_fnc_MP;};
        case ("payGovernor"): {_govData params[["_moneyToSend", 0, [0]]];
                if (_moneyToSend <= 0) exitWith {};
                // owner 2026-06-13: tax now reliably funds the governor. Was gated behind a 15% RNG roll
                // (`random 100 <= 15`) so 85% of collected tax vanished -> the treasury barely filled. RNG
                // removed; cap raised to $5m so legit tax on big purchases isn't clipped. -> gang 50000.
                if (_moneyToSend > 5000000) then { _moneyToSend = 5000000 }; [
                    ["addTaxToCache", [_moneyToSend]], "TON_fnc_govSystemSRV", 2] spawn life_fnc_MP;};
        case ("toggleGovBuildingLocks"): {_govData params["_govBuilding"];
                private _isLocked = _govBuilding getVariable["plb_locked", false];
                private _buildingName = getText(configFile >> "CfgVehicles" >> typeOf _govBuilding >> "displayName");
                private _numDoors = getNumber(configFile >> "CfgVehicles" >> typeOf _govBuilding >> "numberOfDoors");
                if (_isLocked) then {_isLocked = false;
                    [format["Unlocked all doors of the Governor Office", _buildingName], "basic"] spawn life_fnc_handleMessage;} else {
                    _isLocked = true;
                    [format["Locked all doors of the Governor Office", _buildingName], "basic"] spawn life_fnc_handleMessage;};
                _govBuilding setVariable["plb_locked", _isLocked, true];
                private _num =
                if (_isLocked) then {1} else {0};
                for "_i"
                from 1 to _numDoors do {_govBuilding setVariable[format["bis_disabled_Door_%1", _i], _num, true];
                    if (_isLocked) then {_govBuilding animate[format["door_%1_rot", _i], 0]; {_govBuilding animate[_x, 0]}
                        forEach(animationNames _govBuilding);};}; private _soundFile =
                if (_isLocked) then {"lock"} else {"unlock"};
                private _toSend = (allPlayers - [allDeadMen]) select {(_x distance player) <= 10}; [
                    [player, _soundFile], "life_fnc_playSound", _toSend, false, false] spawn life_fnc_MP;};
        case ("configChanged"): {
                // owner 2026-06-13: payload is now [tax, weedLegal, sparLegal] (matches the law menu + server).
                _govData params["_updatedArray"];
                _updatedArray params[["_govTax", 0], ["_govIsWeedLegal", false], ["_govIsSparLegal", false]];
                if (_govIsWeedLegal) then {"weed_1" setMarkerColorLocal "ColorGreen";
                    "weed_2" setMarkerColorLocal "ColorGreen";
                    "Weed_p_2" setMarkerAlphaLocal 1;} else {"weed_1" setMarkerColorLocal "ColorRed";
                    "weed_2" setMarkerColorLocal "ColorRed";
                    "Weed_p_2" setMarkerAlphaLocal 0;};
                if !(isNull life_govSpeaker) then {life_govSpeaker say3D["govSpeaker", 1200];};
                private _weedText = ["Weed is now illegal", "Weed is now legal"] select _govIsWeedLegal;
                private _sparText = ["SPAR-16s are now illegal", "SPAR-16s are now legal"] select _govIsSparLegal;
                private _taxRate  = format["Sales tax is now %1%2", _govTax, "%"];
                [format["<t color='#FF0000'><t size='1.5'><t align='center'>Government Laws Changed<br/><br/></t></t></t>The Governor has changed the laws of %1!<br/><br/>%2<br/><br/>%3<br/><br/>%4", worldName, _taxRate, _weedText, _sparText], "shortwarning"] spawn life_fnc_handleMessage;
            };
        case ("electricChairEffects"): {
                _govData params["_plb_dmg", "_profileName", "_plb_pos", "_chair", "_posATL", "_zCoord", "_chairDirection"];
                _plb_dmg say3D["handcuffs", 100];
                [format["%1 will be executed by electric chair in 30 seconds!", _profileName]] spawn life_fnc_handleMessage;
                uiSleep 30;
                _plb_dmg say3D["elechair", 1000];
                uiSleep 21;
                for "_i"
                from 1 to 7 do {private _radius = 1;
                    private _dir = _plb_dmg getDir life_electricChair;
                    private _centre = getPosATL life_electricChair;
                    private _pos = _centre getPos[_radius, _dir];
                    private _light = "#lightpoint"
                    createVehicleLocal _pos;
                    _light setPosATL(_pos vectorAdd[0, 0, 10]);
                    _light setLightDayLight true;
                    _light setLightBrightness 300;
                    _light setLightAmbient[0.05, 0.05, 0.1];
                    _light setlightcolor[1, 1, 2];
                    uiSleep 0.1;
                    _light setLightBrightness 0;
                    uiSleep(random 0.1);
                    for "_i"
                    from 0 to(3 + random 1) do {private _time = time + 0.1;
                        _light setLightBrightness(100 + random 100);
                        waituntil {time > _time};}; deleteVehicle _light;
                    uiSleep 2.5;};};
        case ("electricChair"): {[999, getPlayerUID player] call life_fnc_wantedListAdd; [
                    [getPlayerUID player], "TON_fnc_wantedRemove", 2] spawn life_fnc_MP;
                private _createCamera = {life_electricChairCamera =
                    if (isNull life_electricChairCamera) then {
                        "camera"
                        camCreate(getPosATL player)} else {life_electricChairCamera};
                    waitUntil {!isNull life_electricChairCamera};
                    private _distance = 4;
                    while {_distance > 1}
                    do {
                        if (!lineIntersects[ATLToASL(player modelToWorld[1, _distance, 2]), ATLToASL(player modelToWorld[0, 0, 1]), player]) exitWith {};
                        _distance = _distance - 0.5;}; life_electricChairCamera camSetTarget(player modelToWorld[0, 0, 1]);
                    life_electricChairCamera camSetPos(player modelToWorld[1, _distance, 2]);
                    life_electricChairCamera camSetFOV 0.33;
                    life_electricChairCamera camSetFocus[50, 0];
                    life_electricChairCamera camCommit 0;
                    showCinemaBorder false;
                    life_electricChairCamera cameraEffect["internal", "back"];};
                private _destroyCamera = {life_electricChairCamera cameraEffect["terminate", "back"];
                    camDestroy life_electricChairCamera;
                    life_electricChairCamera = objNull;};
                life_electricChairCamera = objNull;
                private _plb_dmg = player;
                private _plb_pos = (getPosATL life_electricChair);
                private _chair = life_electricChair;
                private _posATL = getPosATL life_electricChair;
                private _chairDirection = 0;
                private _zCoord = 0;
                private _hiddenObject = "Land_ClutterCutter_small_F"
                createVehicle _posATL;
                _hiddenObject setPosATL _posATL;
                _hiddenObject setDir((direction _chair) - _chairDirection);
                private _headBucket = "Land_Bucket_F"
                createVehicle(getPos player);
                _headBucket attachTo[player, [-0.05, -0.07, 0.1], "Head"];
                _headBucket setVectorUp[0, 0, -1];
                player attachTo[_hiddenObject, [0, 0, _zCoord]];
                player forceAddUniform "U_C_Scientist";
                [] spawn {uiSleep 0.5;
                    [uniform player, "setIdx", 28] call life_fnc_clothingTextures;};
                life_killedByElectricChair = true;
                [] spawn _createCamera;
                _plb_dmg say3D["handcuffs", 100];
                ["You will be put down like a dog, momentarily. Thank you for cooperating with your Governor!"] spawn life_fnc_handleMessage;
                private _toSend = (allPlayers - [player]) select {(_x distance player) <= 75}; [
                    ["electricChairEffects", [player, profileName, _plb_pos, _chair, _posATL, _zCoord, _chairDirection]], "life_fnc_govSystem", _toSend, false, false] spawn life_fnc_MP;
                if (isWeaponDeployed player) then {player playMove "";};
                _plb_dmg setPosATL _plb_pos; [["crew", 75, "switchMove", player], "life_fnc_handleAnim", allPlayers select {
                        (_x distance player) <= 75}] spawn life_fnc_MP;
                uiSleep 30;
                player say3D["elechair", 1000];
                uiSleep 21;
                for "_i"
                from 1 to 7 do {private _radius = 1;
                    private _dir = player getDir life_electricChair;
                    private _centre = getPosATL life_electricChair;
                    private _pos = _centre getPos[_radius, _dir];
                    private _light = "#lightpoint"
                    createVehicleLocal _pos;
                    _light setPosATL(_pos vectorAdd[0, 0, 10]);
                    _light setLightDayLight true;
                    _light setLightBrightness 300;
                    _light setLightAmbient[0.05, 0.05, 0.1];
                    _light setlightcolor[1, 1, 2];
                    uiSleep 0.1;
                    _light setLightBrightness 0;
                    uiSleep(random 0.1);
                    for "_i"
                    from 0 to(3 + random 1) do {private _time = time + 0.1;
                        _light setLightBrightness(100 + random 100);
                        waitUntil {time > _time};}; deleteVehicle _light;
                    uiSleep 2.5;}; uiSleep 6;
                _plb_dmg setDamage 1;
                detach player; {deleteVehicle _x}
                forEach[_headBucket, _hiddenObject];
                uiSleep 2;
                ["You have been pardoned from prison and life.", "basic"] spawn life_fnc_handleMessage;
                ["payGovernor", [5000]] spawn life_fnc_govSystem;
                uiSleep 15;
                [] spawn _destroyCamera;
                [] call life_fnc_doRespawn;
                life_killedByElectricChair = false;
                ["executedelectricchair", 1] call life_fnc_statArrUpdate;};};