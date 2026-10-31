params[["_caseType", "", [""]], "_jewelryData"];
switch (_caseType) do {case ("startDrill"): {if (SRV_jewelryEmporiumSRV param[1, false]) exitWith {
                ["The Jewelry Emporium is already being drilled!"] spawn life_fnc_handleMessage};
            if !(playerSide isEqualTo civilian) exitWith {};
            if (!(call PLB_fnc_hasDeck)) exitWith {[2, "You need a Cyberdeck to do this."] call life_fnc_broadcast};
            if !((vehicle player) isEqualTo player) exitWith {[2, "You cannot do this from within a vehicle."] call life_fnc_broadcast};
            if ([] call life_fnc_activeFederalEvent) exitWith {
                ["There is already another Federal Event happening.", "basic"] spawn life_fnc_handleMessage;};
            if !([SRV_jewelryEmporiumSRV select 6] call life_fnc_policeRequired) exitWith {};
            if (SRV_lastRobbery > (serverTime - (60 * 15))) exitWith {
                [2, format["Security is high due to a recent robbery and you cannot start the robbery. Try again in %1 minute(s).", ceil((SRV_lastRobbery - (serverTime - (60 * 15))) / 60)]] call life_fnc_broadcast
            };
            if ((SRV_jewelryEmporiumSRV param[0, -1800]) > serverTime - 1800) exitWith {
                [format["The Jewelry Emporium has recently been breached! Try again in %1 minute(s).", ceil((((SRV_jewelryEmporiumSRV param[0, -1800]) + 1800) - serverTime) / 60)], "basic"] spawn life_fnc_handleMessage;
            };
            disableSerialization;
            5 cutRsc["life_progress", "PLAIN"];
            private _display = uiNameSpace getVariable["life_progress", displayNull];
            private _progressBar = _display displayCtrl 38201;
            private _progressText = _display displayCtrl 38202;
            life_action_in_use = true;
            private _increment = 1;
            private _totalTime = 10;
            private _currentPoint = 0;
            private _loopDelay = _totalTime / floor(100 / _increment);
            private _text = format["Placing Drill On Emporium Back Door"];
            private _startCount = 0;
            _progressBar progressSetPosition _startCount;
            _progressText ctrlSetText format["%1 (%2%3)", _text, _startCount, "%"]; [
                ["Acts_TerminalOpen", (_totalTime * 5), "switchMove", player], "life_fnc_handleAnim", (allPlayers select {
                    (_x distance player) <= 40})] spawn life_fnc_MP;
            private _isSuccess =
            for "_i"
            from 0 to 1 step 0 do {uiSleep _loopDelay;
                if (isNull _progressBar) exitWith {["You have failed to start the drill", "basic"] spawn life_fnc_handleMessage;
                    false};
                _currentPoint = (progressPosition _progressBar) + (_increment / 100);
                _progressBar progressSetPosition _currentPoint;
                _progressText ctrlSetText format["%1 (%2%3)", _text, round(_currentPoint * 100), "%"];
                if (_currentPoint >= 1) exitWith {true};
                if (player getVariable ["plb_surrendered", false]) exitWith {   // #361: hands-up (TAB) cancels the drill so you can comply
                    ["Drill interrupted -- hands up.", "basic"] spawn life_fnc_handleMessage;
                    false};
                if ((speed player) >= 3) exitWith {["You have failed to start the drill", "basic"] spawn life_fnc_handleMessage;
                    false};
                if !(isNull objectParent player) exitWith {["You have failed to start the drill", "basic"] spawn life_fnc_handleMessage;
                    false};
                if (!life_action_in_use || !alive player) exitWith {
                    ["You have failed to start the drill", "basic"] spawn life_fnc_handleMessage;
                    false};
                false;};
            ["", 0 , "switchMove", player] spawn life_fnc_handleAnim;
            life_action_in_use = false;
            5 cutText["", "PLAIN"];
            if !(_isSuccess) exitWith {};
            uiSleep(random 2);
            uiSleep(random 1);
            if (SRV_jewelryEmporiumSRV param[1, false]) exitWith {
                ["The Jewelry Emporium is already being drilled!"] spawn life_fnc_handleMessage};
            ["jewelrydrilled", 1] call life_fnc_statArrUpdate; [
                ["robberyStarted", [player]], "TON_fnc_jewelryEmporiumSRV", 2] spawn life_fnc_MP;}; case ("weldSafe"): {
                _jewelryData params[["_safeObj", objNull, [objNull]]];
                if (life_inv_jewelLaser <= 0) exitWith {[2, "You need a Plasma Cutter to open this safe."] call life_fnc_broadcast};
                if (_safeObj isNotEqualTo life_jewerlySafe) exitWith {};
                if !(SRV_jewelryEmporiumSRV param[2, false]) exitWith {   // #149: gate on safeDrilled [2], not the post-weld flag [3] (was unreachable -> no timer bar)
                    ["You have yet to meet the requirments for torching the safe!"] spawn life_fnc_handleMessage};
                if (isNull(_safeObj getVariable["plb_jewelWelder", objNull])) then {_safeObj setVariable["plb_jewelWelder", player, true];
                };
                disableSerialization;
                5 cutRsc["life_progress", "PLAIN"];
                private _display = uiNameSpace getVariable["life_progress", displayNull];
                private _progressBar = _display displayCtrl 38201;
                private _progressText = _display displayCtrl 38202;
                life_action_in_use = true;
                private _increment = 1;
                private _totalTime = 12;
                private _currentPoint = 0;
                private _loopDelay = _totalTime / floor(100 / _increment);
                private _text = format["Starting Plasma Cutter On Safe Door"];
                private _startCount = 0;
                _progressBar progressSetPosition _startCount;
                _progressText ctrlSetText format["%1 (%2%3)", _text, _startCount, "%"];
                player playMoveNow "Acts_carFixingWheel";
                private _isSuccess =
                for "_i"
                from 0 to 1 step 0 do {uiSleep _loopDelay;
                    if (isNull _progressBar) exitWith {
                        ["You have failed to start the plasma cutter", "basic"] spawn life_fnc_handleMessage;
                        false};
                    _currentPoint = (progressPosition _progressBar) + (_increment / 100);
                    _progressBar progressSetPosition _currentPoint;
                    _progressText ctrlSetText format["%1 (%2%3)", _text, round(_currentPoint * 100), "%"];
                    if (_currentPoint >= 1) exitWith {true};
                    if ((speed player) >= 3) exitWith {
                        ["You have failed to start the plasma cutter", "basic"] spawn life_fnc_handleMessage;
                        false};
                    if !(isNull objectParent player) exitWith {
                        ["You have failed to start the plasma cutter", "basic"] spawn life_fnc_handleMessage;
                        false};
                    if (!life_action_in_use || !alive player) exitWith {
                        ["You have failed to start the plasma cutter", "basic"] spawn life_fnc_handleMessage;
                        false};
                    false;}; player switchMove "";
                life_action_in_use = false;
                5 cutText["", "PLAIN"];
                if !(_isSuccess) exitWith {};
                uiSleep(random 1);
                uiSleep(random 2);
                if (!(isNull(_safeObj getVariable["plb_jewelWelder", objNull])) && ((_safeObj getVariable["plb_jewelWelder", objNull]) isNotEqualTo player)) exitWith {};
                [["weldSafe", [life_jewerlySafe, player]], "TON_fnc_jewelryEmporiumSRV", 2] spawn life_fnc_MP;};
        case ("breakGlassCase"): {_jewelryData params[["_oldCase", objNull, [objNull]]];
                if (life_inv_jewelCrowbar <= 0) exitWith {[2, "You need a Crow Bar to open this safe."] call life_fnc_broadcast};
                if !(SRV_jewelryEmporiumSRV param[2, false]) exitWith {
                    ["You can't open this until the drilling has completed!", "basic"] spawn life_fnc_handleMessage;};
                if (life_action_in_use) exitWith {};
                if (isObjectHidden _oldCase) exitWith {};
                if (_oldCase getVariable["plb_jewelCaseLooted", false]) exitWith {};
                // #152: was a whitelist of the 14 Eden-named cases -- any OTHER Coffin_02_F display case
                // in the emporium silently no-op'd ("some glass cases do not give option to crack").
                // Accept any display case inside the emporium polygon instead.
                if !(((typeOf _oldCase) isEqualTo "Coffin_02_F") && {(getPosATL _oldCase) inPolygon life_jewelryEmporiumPoly}) exitWith {};
                disableSerialization;
                5 cutRsc["life_progress", "PLAIN"];
                private _display = uiNameSpace getVariable["life_progress", displayNull];
                private _progressBar = _display displayCtrl 38201;
                private _progressText = _display displayCtrl 38202;
                life_action_in_use = true;
                private _increment = 1;
                private _totalTime = 25;
                private _currentPoint = 0;
                private _loopDelay = _totalTime / floor(100 / _increment);
                private _text = format["Prying Open Jewelry Case"];
                private _startCount = 0;
                _progressBar progressSetPosition _startCount;
                _progressText ctrlSetText format["%1 (%2%3)", _text, _startCount, "%"];
                player switchMove "acts_millerDisarming_deskCrouch_loop";
                private _isSuccess =
                for "_i"
                from 0 to 1 step 0 do {uiSleep _loopDelay;
                    if (isNull _progressBar) exitWith {["You have failed to break open the case", "basic"] spawn life_fnc_handleMessage;
                        false};
                    _currentPoint = (progressPosition _progressBar) + (_increment / 100);
                    _progressBar progressSetPosition _currentPoint;
                    _progressText ctrlSetText format["%1 (%2%3)", _text, round(_currentPoint * 100), "%"];
                    if (_currentPoint >= 1) exitWith {true};
                    if ((speed player) >= 3) exitWith {["You have failed to break open the case", "basic"] spawn life_fnc_handleMessage;
                        false};
                    if !(isNull objectParent player) exitWith {
                        ["You have failed to break open the case", "basic"] spawn life_fnc_handleMessage;
                        false};
                    if (!life_action_in_use || !alive player) exitWith {
                        ["You have failed to break open the case", "basic"] spawn life_fnc_handleMessage;
                        false};
                    false;}; player switchMove "";
                life_action_in_use = false;
                5 cutText["", "PLAIN"];
                if !(_isSuccess) exitWith {};
                ["jewelrycasesopened", 1] call life_fnc_statArrUpdate; [
                    ["createCase", [_oldCase]], "TON_fnc_jewelryEmporiumSRV", 2] spawn life_fnc_MP;};
        case ("takeJewelryContents"): {_jewelryData params[["_cursorObject", objNull, [objNull]]];
                if ((typeOf _cursorObject) isNotEqualTo "Land_Trophy_01_gold_F") exitWith {};
                if ([true, "jewelBag", 1] call life_fnc_handleInv) then {deleteVehicle _cursorObject;
                    ["Put this bag of jewelry inside the loading container!", "basic"] spawn life_fnc_handleMessage;} else {
                    ["You do not have room to grab the jewelry!", "basic"] spawn life_fnc_handleMessage;};};
        case ("takeSafeContents"): {_jewelryData params[["_openSafe", objNull, [objNull]]];
                if (typeOf _openSafe isNotEqualTo "Fridge_01_open_F") exitWith {};
                if (_openSafe getVariable["plb_safeLooted", false]) exitWith {
                    ["This safe has already been looted!", "basic"] spawn life_fnc_handleMessage;};
                if !(SRV_jewelryEmporiumSRV param[3, false]) exitWith {   // #149: safe contents need the safe WELDED [3] (was [4], let you skip welding)
                    ["You are not able to open this safe!", "basic"] spawn life_fnc_handleMessage;};
                if ([true, "jewelBag", 1] call life_fnc_handleInv) then {_openSafe setVariable["plb_safeLooted", true, true];
                    ["You have taken the heavy and expensive jewelry bag from this coveted safe!", "basic"] spawn life_fnc_handleMessage;
                } else {["You do not have room to grab the jewelry bag!", "basic"] spawn life_fnc_handleMessage;};};
        case ("loadOutsideContainer"): {_jewelryData params[["_outsideContainer", objNull, [objNull]]];
                if (_outsideContainer isNotEqualTo life_jewerlyContainer) exitWith {};
                private _itemsForStore = ["jewelBag"];
                private _itemToStore = []; {_invCount = missionNamespace getVariable[format["life_inv_%1", _x], 0];
                    if (_invCount >= 1) then {_itemToStore pushBack[_x, _invCount];};}
                forEach _itemsForStore;
                private _itemToStore =
                switch (true) do {case (count _itemToStore isEqualTo 0): {[]};
                    case (count _itemToStore isEqualTo 1): {_itemToStore param[0, []]};
                    case (count _itemToStore > 1): {selectRandom _itemToStore};}; if (_itemToStore isEqualTo[]) exitWith {};
                _itemToStore params["_invItem", "_invCount"];
                if ([false, _invItem, _invCount] call life_fnc_handleInv) then {
                    [format["You have stored %1 %2(s) inside the jewelry loading container!", _invCount, ["getName", _invItem] call life_fnc_virtItemCfg], "basic"] spawn life_fnc_handleMessage;
                    private _storedCount = life_jewerlyContainer getVariable["plb_jewelContainerItems", 0];
                    life_jewerlyContainer setVariable["plb_jewelContainerItems", (_storedCount + _invCount), true];} else {
                    ["You do not have any jewelry bags to load!", "basic"] spawn life_fnc_handleMessage;};};
        case ("clientInit"): {[{if (SRV_jewelryEmporiumSRV param[1, false]) then {life_jewerlyEmporium say3D["jewelryAlarm", 500];};
                }, [], 1.212] call life_fnc_addPerFrameHandler; [{if ((SRV_jewelryEmporiumSRV param[4, false]) && {
                        !(isNull((nearestObjects[life_jewerlySafe, ["Land_ButaneTorch_F"], 3]) param[0, objNull]))}) then {
                        life_jewerlySafe say3D["jewelrySafeTorchLoop", 100];};}, [], 1.1] call life_fnc_addPerFrameHandler;};};