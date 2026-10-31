params["_target", "_caller", "_actionId", ["_mode", -1, [0]]];
if (_mode isEqualTo - 1) exitWith {};
if (playerSide isEqualTo civilian && _mode in [1, 3, 4]) exitWith {};
if (playerSide isEqualTo west && _mode in [0, 2]) exitWith {};
if (isRemoteExecuted && !(_mode isEqualTo 4)) exitWith {};
private _laptopStatus = evidenceLaptop getVariable["plb_laptopstatus", 1];
private _domeOpen = life_evidence_dome getVariable["plb_evidenceOpen", false];
private _plantedBomb = life_evidence_dome getVariable["plb_bombPlanted", false];
private _startPosition = getPos player;
switch (_mode) do {case 0: {if !([SRV_evidence_status select 4] call life_fnc_policeRequired) exitWith {};
            if ([] call life_fnc_activeFederalEvent) exitWith {
                ["There is already another Federal Event happening.", "basic"] spawn life_fnc_handleMessage;};
            if !(_laptopStatus in [1, 3]) exitWith {
                ["The defense system is already being disabled or is disabled.", "basic"] spawn life_fnc_handleMessage;};
            if (toLower(primaryWeapon player) in life_nonCartelGuns) exitWith {
                ["You'll need a bigger gun to pull this off...", "basic"] spawn life_fnc_handleMessage;};
            if ((SRV_evidence_status select 3) > serverTime - 1800) exitWith {
                [format["The armory has recently been attacked! Try again in %1 minute(s).", ceil((((SRV_evidence_status select 3) + 1800) - serverTime) / 60)], "basic"] spawn life_fnc_handleMessage;
            }; [["", "", "", 4], "life_fnc_evidenceSystems", west] spawn life_fnc_MP;
            disableSerialization;
            5 cutRsc["life_progress", "PLAIN"];
            private _display = uiNameSpace getVariable["life_progress", displayNull];
            private _progressBar = _display displayCtrl 38201;
            private _progressText = _display displayCtrl 38202;
            life_action_in_use = true;
            private _increment = 1;
            private _totalTime = 90;
            private _currentPoint = 0;
            private _loopDelay = _totalTime / floor(100 / _increment);
            private _text = "Infecting Security System";
            private _startCount = 0;
            _progressBar progressSetPosition _startCount;
            _progressText ctrlSetText format["%1 (%2%3)", _text, _startCount, "%"];
            private _duration = 20;
            private _animation = "AinvPknlMstpSnonWnonDnon_medic_1";
            [_animation, _duration] spawn life_fnc_handleAnim;
            private _isSuccess =
            for "_i"
            from 0 to 1 step 0 do {uiSleep _loopDelay;
                if (isNull _progressBar) exitWith {false};
                _currentPoint = (progressPosition _progressBar) + (_increment / 100);
                _progressBar progressSetPosition _currentPoint;
                _progressText ctrlSetText format["%1 (%2%3)", _text, round(_currentPoint * 100), "%"];
                if (_currentPoint >= 1) exitWith {true};
                if ((speed player) >= 3) exitWith {false};
                if (player distance _startPosition > 5) exitWith {false};
                if !(isNull objectParent player) exitWith {false};
                if (!life_action_in_use || !alive player) exitWith {false};
                false;}; life_action_in_use = false;
            [] spawn life_fnc_handleAnim;
            5 cutText["", "PLAIN"];
            if !(_isSuccess) exitWith {
                ["You have failed to upload the virus in to the defense systems.", "basic"] spawn life_fnc_handleMessage;};
            ["You have infected the defense system with a virus. The defenses will go down in 5 minutes. Defend the computer from the police.", "basic"] spawn life_fnc_handleMessage;
            [[0, 300], "TON_fnc_handleTimer", 2] call life_fnc_MP;};
    case 1: {if (_laptopStatus isEqualTo 1) exitWith {
                ["The defense system is already being enabled or is enabled.", "basic"] spawn life_fnc_handleMessage;};
            private _rebelsInPoly = allPlayers select {
                getPos _x inPolygon life_eviFencePoly && side _x isEqualTo civilian && alive _x && !(_x getVariable["plb_restrained", false])
            };
            if !(_rebelsInPoly isEqualTo[]) exitWith {
                ["There are rebels within the the fence that need to be removed out before repairing the defense system!", "basic"] spawn life_fnc_handleMessage;
            };
            if (_domeOpen || _plantedBomb) exitWith {["Please secure the Evidence Lockup first.", "basic"] spawn life_fnc_handleMessage;};
            disableSerialization;
            5 cutRsc["life_progress", "PLAIN"];
            private _display = uiNameSpace getVariable["life_progress", displayNull];
            private _progressBar = _display displayCtrl 38201;
            private _progressText = _display displayCtrl 38202;
            life_action_in_use = true;
            private _increment = 1;
            private _totalTime = 90;
            private _currentPoint = 0;
            private _loopDelay = _totalTime / floor(100 / _increment);
            private _text = "Repairing Defense Systems";
            private _startCount = 0;
            _progressBar progressSetPosition _startCount;
            _progressText ctrlSetText format["%1 (%2%3)", _text, _startCount, "%"];
            private _duration = 20;
            private _animation = "AinvPknlMstpSnonWnonDnon_medic_1";
            [_animation, _duration] spawn life_fnc_handleAnim;
            private _isSuccess =
            for "_i"
            from 0 to 1 step 0 do {uiSleep _loopDelay;
                if (isNull _progressBar) exitWith {false};
                _currentPoint = (progressPosition _progressBar) + (_increment / 100);
                _progressBar progressSetPosition _currentPoint;
                _progressText ctrlSetText format["%1 (%2%3)", _text, round(_currentPoint * 100), "%"];
                if (_currentPoint >= 1) exitWith {true};
                if ((speed player) >= 3) exitWith {false};
                if (player distance _startPosition > 5) exitWith {false};
                if !(isNull objectParent player) exitWith {false};
                if (!life_action_in_use || !alive player) exitWith {false};
                false;}; life_action_in_use = false;
            [] spawn life_fnc_handleAnim;
            5 cutText["", "PLAIN"];
            if !(_isSuccess) exitWith {["You have failed to repair the defense system.", "basic"] spawn life_fnc_handleMessage;};
            if (life_evidence_dome getVariable["plb_evidenceOpen", false] || life_evidence_dome getVariable["plb_bombPlanted", false]) exitWith {
                ["Please secure the Evidence Lockup first.", "basic"] spawn life_fnc_handleMessage;};
            private _rebelsInPoly = allPlayers select {
                getPos _x inPolygon life_eviFencePoly && side _x isEqualTo civilian && alive _x && !(_x getVariable["plb_restrained", false])
            };
            if !(_rebelsInPoly isEqualTo[]) exitWith {
                ["There are rebels within the the fence that need to be removed out before repairing the defense system!", "basic"] spawn life_fnc_handleMessage;
            };
            ["You have brought the defense systems back online.", "basic"] spawn life_fnc_handleMessage; [
                [1, 0], "TON_fnc_handleTimer", 2] call life_fnc_MP;};
    case 2: {life_evidence_dome = nearestObject[[20898.6, 19221.7, 0.00143909], "Land_Dome_Big_F"];
            if (life_inv_demoCharge <= 0) exitWith {["You need a demo charge to breach.", "basic"] spawn life_fnc_handleMessage;};
            if ((SRV_evidence_status select 1) || !(SRV_evidence_status select 0)) exitWith {
                ["You must hack the electric fence first.", "basic"] spawn life_fnc_handleMessage;};
            private _time = 900;
            private _extraTime =
            if ((life_bank_robbed select 0) || (life_fed_robbed select 0) || (SRV_prisonData select 1)) then[{600}, {0}];
            disableSerialization;
            5 cutRsc["life_progress", "PLAIN"];
            private _display = uiNameSpace getVariable["life_progress", displayNull];
            private _progressBar = _display displayCtrl 38201;
            private _progressText = _display displayCtrl 38202;
            life_action_in_use = true;
            private _increment = 1;
            private _totalTime = 90;
            private _currentPoint = 0;
            private _loopDelay = _totalTime / floor(100 / _increment);
            private _text = "Placing Explosives";
            private _startCount = 0;
            _progressBar progressSetPosition _startCount;
            _progressText ctrlSetText format["%1 (%2%3)", _text, _startCount, "%"];
            private _duration = 20;
            private _animation = "AinvPknlMstpSnonWnonDnon_medic_1";
            [_animation, _duration] spawn life_fnc_handleAnim;
            private _isSuccess =
            for "_i"
            from 0 to 1 step 0 do {uiSleep _loopDelay;
                if (isNull _progressBar) exitWith {false};
                _currentPoint = (progressPosition _progressBar) + (_increment / 100);
                _progressBar progressSetPosition _currentPoint;
                _progressText ctrlSetText format["%1 (%2%3)", _text, round(_currentPoint * 100), "%"];
                if (_currentPoint >= 1) exitWith {true};
                if ((speed player) >= 2) exitWith {false};
                if (player distance _startPosition > 5) exitWith {false};
                if !(isNull objectParent player) exitWith {false};
                if (!life_action_in_use || !alive player) exitWith {false};
                false;}; life_action_in_use = false;
            [] spawn life_fnc_handleAnim;
            5 cutText["", "PLAIN"];
            if !(_isSuccess) then {["You have failed to place the explosives.", "basic"] spawn life_fnc_handleMessage;};
            _time = _time + _extraTime;
            [format["The explosives have been placed. The bomb will detonate in %1 minutes.", (_time / 60)], "basic"] spawn life_fnc_handleMessage;
            [[2, _time], "TON_fnc_handleTimer", 2] call life_fnc_MP;};
    case 3: {private _rebelsInPoly = allPlayers select {
                _x distance(getMarkerPos "armory_marker") <= 28 && side _x isEqualTo civilian && alive _x && !(_x getVariable["plb_restrained", false])
            };
            if !(_rebelsInPoly isEqualTo[]) exitWith {["Secure the Evidence Lockup first!", "basic"] spawn life_fnc_handleMessage;};
            if !(life_evidence_dome getVariable["plb_evidenceOpen", false]) exitWith {
                ["The evidence lockup doesn't require securing.", "basic"] spawn life_fnc_handleMessage;};
            disableSerialization;
            5 cutRsc["life_progress", "PLAIN"];
            private _display = uiNameSpace getVariable["life_progress", displayNull];
            private _progressBar = _display displayCtrl 38201;
            private _progressText = _display displayCtrl 38202;
            life_action_in_use = true;
            private _increment = 1;
            private _totalTime = 90;
            private _currentPoint = 0;
            private _loopDelay = _totalTime / floor(100 / _increment);
            private _text = "Securing the Lockup";
            private _startCount = 0;
            _progressBar progressSetPosition _startCount;
            _progressText ctrlSetText format["%1 (%2%3)", _text, _startCount, "%"];
            private _duration = 20;
            private _animation = "AinvPknlMstpSnonWnonDnon_medic_1";
            [_animation, _duration] spawn life_fnc_handleAnim;
            private _isSuccess =
            for "_i"
            from 0 to 1 step 0 do {uiSleep _loopDelay;
                if (isNull _progressBar) exitWith {false};
                _currentPoint = (progressPosition _progressBar) + (_increment / 100);
                _progressBar progressSetPosition _currentPoint;
                _progressText ctrlSetText format["%1 (%2%3)", _text, round(_currentPoint * 100), "%"];
                if (_currentPoint >= 1) exitWith {true};
                if ((speed player) >= 2) exitWith {false};
                if (player distance _startPosition > 5) exitWith {false};
                if !(isNull objectParent player) exitWith {false};
                if (!life_action_in_use || !alive player) exitWith {false};
                false;}; life_action_in_use = false;
            [] spawn life_fnc_handleAnim;
            5 cutText["", "PLAIN"];
            if !(_isSuccess) then {["You have failed to secure the lockup.", "basic"] spawn life_fnc_handleMessage;};
            if !(life_evidence_dome getVariable["plb_evidenceOpen", false]) exitWith {
                ["The evidence lockup doesn't require securing.", "basic"] spawn life_fnc_handleMessage;}; [
                [3, 180], "TON_fnc_handleTimer", 2] call life_fnc_MP;
            uiSleep 180; [
                [0, format["APD Officer %1 has stopped the Evidence Locker Robbery!", profileName]], "life_fnc_broadcast", -2] spawn life_fnc_MP;
        };
    case 4: {life_copEviReq = true;
            ["Someone has been detected tampering with the defense systems at the Evidence Lockup! Your response is needed immediately! Press 9 on your keyboard within the next 5 minutes to redeploy to the Evidence Lockup.", "copalert"] spawn life_fnc_handleMessage;
        };};