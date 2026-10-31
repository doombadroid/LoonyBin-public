params[["_caseType", "", [""]], "_executionData"];
switch (_caseType) do {case ("killerPlayer"): {_executionData params[["_victimObj", objNull, [objNull]]];
            private _currentWeapon = currentWeapon player;
            private _toSend = allPlayers select {(_x distance player) <= 250};
            private _killer = player;
            private _ammoData = [_killer ammo _currentWeapon, (getNumber(configfile >> "CfgMagazines" >> currentMagazine _killer >> "count"))];
            if ((_ammoData param[0, 0]) < 1) exitWith {["You need at least one shot in your handgun!"] spawn life_fnc_handleMessage};
            if (((player distance(getMarkerPos "city") < 1000) || (player distance(getMarkerPos "civ_spawn_3") < 500) || (player distance(getMarkerPos "civ_spawn_4") < 500) || (player distance(getMarkerPos "civ_spawn_2") < 500)) && !((player distance(getMarkerPos "execute_exempt_01") < 4) || (player distance(getMarkerPos "execute_exempt_02") < 5) || (player distance(getMarkerPos "execute_exempt_03") < 4) || (player distance(getMarkerPos "execute_exempt_04") < 3) || (player distance(getMarkerPos "bankMarker") < 250))) exitWith {
                ["You cannot execute someone so close to a populated area.", "basic"] spawn life_fnc_handleMessage;}; [
                ["broadcastEffects", [player, profileName, getPlayerUID player, _victimObj, (_victimObj getVariable["plb_name", [name _victimObj] call life_fnc_cleanName]), getPlayerUID _victimObj, _currentWeapon, _ammoData]], "life_fnc_executionerMove", _toSend] spawn life_fnc_MP;
        }; case ("broadcastEffects"): {
                _executionData params[["_killerObj", objNull, [objNull]], ["_killerName", "", [""]], ["_killerUID", "", [""]], ["_victimObj", objNull, [objNull]], ["_victimName", "", [""]], ["_victimUID", "", [""]], ["_currentWeapon", "", [""]], ["_ammoData", [],
                    [[]]]];
                if (player isEqualTo _victimObj) then {player enableSimulation false;
                    [_victimObj, false] spawn life_fnc_unrestrain;
                    if !((currentWeapon player) isEqualTo "") then {[true] spawn life_fnc_holsterWeapon;} else {
                        [false] spawn life_fnc_holsterWeapon;};
                    _victimObj attachTo[_killerObj, [0, 0.75, 0]];
                    detach player;};
                [_killerObj, _victimObj] spawn {params[["_killerObj", objNull, [objNull]], ["_victimObj", objNull, [objNull]]];
                    _killerObj say3D["executionerAnyLastWords", 200];
                    uiSleep 2.1;
                    _victimObj say3D["executionerWaitWait", 200];
                    uiSleep 3.8;
                    _victimObj say3D["executionerWeDontCare", 200];
                    _killerObj say3D["executionerGunshot", 200];
                    uiSleep 3.9;
                    waitUntil {uiSleep 0.1;
                        !(alive _victimObj)};
                    _killerObj say3D["executionerHeadshot", 200];
                    if ((_victimObj distance2D player) <= 12) then {[9999999] call BIS_fnc_bloodEffect;};
                    _bloodStain = createSimpleObject["BloodSplatter_01_Large_New_F", getPosWorld player, true];
                    _bloodStain setVectorUp surfaceNormal getPosWorld _bloodStain;
                    _killerObj say3D["executionerFatality", 200];
                    uiSleep 1;
                    private _victomPos = getPosWorld _victimObj;
                    waitUntil {isNull _victimObj};
                    _skeleton = createSimpleObject["Land_HumanSkeleton_F", _victomPos, true];
                    _skeleton setVectorUp surfaceNormal getPosWorld _bloodStain;
                    uiSleep 60;
                    deleteVehicle _bloodStain;
                    deleteVehicle _skeleton;};
                uiSleep 1;
                ["Acts_Executioner_Standing", 8, "switchMove", _killerObj] spawn life_fnc_handleAnim;
                ["Acts_ExecutionVictim_Loop", 30, "switchMove", _victimObj] spawn life_fnc_handleAnim;
                uiSleep 0.5;
                if (player isEqualTo _killerObj) then {player setDir(player getDir _victimObj); [
                        [9, player], "TON_fnc_wantedAdd", false, false] spawn life_fnc_MP; [
                        ["-EXECUTE-", player, profileName, format["executed by gunshot %1 (%2), POS: %3", _victimName, _victimUID, getPosATL player]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
                };
                if (player isEqualTo _victimObj) then {_victimObj setDir(_victimObj getDir _killerObj);};
                uiSleep 5;
                ["Acts_Executioner_Kill", 3.35, "switchMove", _killerObj] spawn life_fnc_handleAnim;
                ["Acts_Executioner_Kill", 3.35, "switchMove", _killerObj] spawn life_fnc_handleAnim;
                uiSleep 2.8;
                ["Acts_ExecutionVictim_Kill_End", 3.7, "switchMove", _victimObj] spawn life_fnc_handleAnim;
                ["Acts_ExecutionVictim_Kill_End", 3.7, "switchMove", _victimObj] spawn life_fnc_handleAnim;
                if (player isEqualTo _victimObj) then {life_executioner = +[_killerName, _killerUID];
                    private _plb_dmg = player;
                    _plb_dmg setDamage 1;
                    uiSleep 3.3;
                    [] call life_fnc_doRespawn;
                    player enableSimulation true;} else {uiSleep 3.6;
                    _victimObj switchMove "";};
                uiSleep 0.4;
                if (player isEqualTo _killerObj) then {player setAmmo[_currentWeapon, ((_ammoData param[0, 0]) - 1)];};
                _killerObj switchMove "";
                uiSleep 0.3;
                ["Acts_Executioner_Squat", 7, "switchMove", _killerObj] spawn life_fnc_handleAnim;};};