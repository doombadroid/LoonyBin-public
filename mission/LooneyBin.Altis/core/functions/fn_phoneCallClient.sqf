params[["_caseType", "", [""]], "_phoneData"];
switch (_caseType) do {case ("startPhoneCall"): {_phoneData params[["_button", controlNull, [controlNull]]];
            if (_button isEqualTo controlNull) exitWith {[format["fucked %1", _this], "warning"] spawn life_fnc_handleMessage;};
            if !((lbCurSel 9501) >= 0) exitWith {
                ["You must select a player you are trying to call!", "basic"] spawn life_fnc_handleMessage;};
            private _data = (lbData[9501, lbCurSel 9501]);
            if (_data in ["enginekillswitch", "remotebomb"]) exitWith {
                // LooneyBin: use the STORED vehicle object directly. The old plate-lookup (vehicles findIf
                // plb_dbInfo[1] == plate) returned objNull / the wrong vehicle when the plate was -1, non-DB, or
                // re-plated -> callInBomb's "_vehicle == life_remoteExplosive#0" guard failed -> detonator did nothing.
                private _target = if (_data == "enginekillswitch") then {life_engineKillSwitch param[0, objNull]} else {
                    life_remoteExplosive param[0, objNull]};
                if !(isNull _target) exitWith {if (_data == "enginekillswitch") then {
                        ["callInKillSwitch", _target] spawn life_fnc_remoteEngineKillSwitch;} else {
                        ["callInBomb", _target] spawn life_fnc_remoteExplosive;};};};
            private _target = allPlayers param[allPlayers findIf {_data isEqualTo(getPlayerUID _x)}, objNull];
            if (isNull _target) exitWith {["The player you are trying to call can't be found", "basic"] spawn life_fnc_handleMessage;};
            if (((side _target) isEqualTo west) && ((life_is_arrested param[0, 0]) isEqualTo 1)) exitWith {
                ["Prison inmates are not allowed to call officers of the law!", "basic"] spawn life_fnc_handleMessage;};
            if ((_target distance(getMarkerPos "respawn_west")) < 1000) exitWith {
                ["The player you are trying to call is currently not available."] spawn life_fnc_handleMessage};
            life_phoneCallStatus = 1;
            [] spawn life_fnc_cellphone_call; [
                ["receivePhoneCall", [profileName, player]], "life_fnc_phoneCallClient", _target] spawn life_fnc_MP;
            [format["You have started calling %1", [name _target] call life_fnc_cleanName], "basic"] spawn life_fnc_handleMessage;
            [] spawn {for "_i"
                from 1 to 4 do {if (life_phoneCallStatus isNotEqualTo 1) exitWith {};
                    if !(life_isRingEnabled) exitWith {};
                    playSound "PhoneDial";
                    uiSleep 3;};};
            private _ringStart = time;
            waitUntil {uiSleep 1;
                ((_ringStart < time - 30) || (life_phoneCallStatus isNotEqualTo 1))};
            if ((_ringStart < time - 30) && (life_phoneCallStatus isEqualTo 1)) then {
                ["declinePhoneCallReciever"] spawn life_fnc_phoneCallClient;};
            if !(isNull(findDisplay 9500)) then {[] spawn life_fnc_cellphone_call;};
            [] spawn {waitUntil {uiSleep 0.5;
                    (life_phoneCallStatus isEqualTo - 1)};
                if !(isNull(findDisplay 9500)) then {[] spawn life_fnc_cellphone_call;};};}; case ("receivePhoneCall"): {
                _phoneData params[["_callerName", "", [""]], ["_callerObj", objNull, [objNull]]];
                if (life_phoneCallStatus isEqualTo 2) exitWith {};
                if !(life_incomingCallsIgnored) then {
                    [format["%1 is calling your phone! Press 8 to answer or 9 to decline.", _callerName], "phone_call"] spawn life_fnc_handleMessage;
                    systemChat "You can also disable all incoming calls in your phone settings";
                    [] spawn {for "_i"
                        from 1 to 4 do {if !(life_isRingEnabled) exitWith {};
                            if (life_phoneCallStatus isNotEqualTo 1) exitWith {};
                            playSound "PhoneRing";
                            uiSleep 3;};};};
                life_phoneCallStatus = 1;
                life_phoneCallData = [_callerObj, _callerName, player, profileName];
                private _ringStart = time;
                waitUntil {uiSleep 1;
                    ((_ringStart < time - 30) || (life_phoneCallStatus isNotEqualTo 1))};
                if ((_ringStart < time - 30) && (life_phoneCallStatus isEqualTo 1)) then {if !(life_incomingCallsIgnored) then {
                        [format["You ignored the incoming phone call from %1", _callerName], "basic"] spawn life_fnc_handleMessage;};
                    life_phoneCallStatus = 3;
                    life_phoneCallData = [objNull, "", objNull, ""];
                    if !(isNull(findDisplay 9500)) then {[] spawn life_fnc_cellphone_call;};
                    [] spawn {uiSleep 10;
                        life_phoneCallStatus = 0;
                        if !(isNull(findDisplay 9500)) then {[] spawn life_fnc_cellphone_call;};};};};
        case ("answerPhoneCall"): {
                life_phoneCallData params[["_callerObj", objNull, [objNull]], ["_callerName", "", [""]], ["_recieverObj", objNull, [objNull]], ["_recieverName", "", [""]]];
                if (isNull _callerObj || _callerName isEqualTo "") exitWith {};
                [format["You have answered the phone call from %1", _callerName], "basic"] spawn life_fnc_handleMessage; [
                    ["startPhoneCall", [_callerObj, player]], "TON_fnc_handlePhoneCallSRV", 2] spawn life_fnc_MP;};
        case ("declinePhoneCallReciever"): {
                life_phoneCallData params[["_callerObj", objNull, [objNull]], ["_callerName", "", [""]], ["_recieverObj", objNull, [objNull]], ["_recieverName", "", [""]]];
                life_phoneCallStatus = 3;
                life_phoneCallData = [objNull, "", objNull, ""];
                if !(isNull(findDisplay 9500)) then {[] spawn life_fnc_cellphone_call;};
                if (isNull _callerObj) exitWith {["Your phone call wasn't answered in time", "basic"] spawn life_fnc_handleMessage;
                    if !(isNull(findDisplay 9500)) then {[] spawn life_fnc_cellphone_call;};
                    [] spawn {uiSleep 10;
                        life_phoneCallStatus = 0;
                        if !(isNull(findDisplay 9500)) then {[] spawn life_fnc_cellphone_call;};};};
                if (_recieverObj isNotEqualTo player) exitWith {};
                [format["You declined the incoming phone call from %1", _callerName], "basic"] spawn life_fnc_handleMessage; [
                    ["declinePhoneCallCaller", [profileName]], "life_fnc_phoneCallClient", _callerObj] spawn life_fnc_MP;
                [] spawn {uiSleep 10;
                    life_phoneCallStatus = 0;
                    if !(isNull(findDisplay 9500)) then {[] spawn life_fnc_cellphone_call;};};};
        case ("declinePhoneCallCaller"): {_phoneData params[["_recieverName", "", [""]]];
                [format["%1 has declined your phone call!", _recieverName], "basic"] spawn life_fnc_handleMessage;
                life_phoneCallStatus = 3;
                life_phoneCallData = [objNull, "", objNull, ""];
                if !(isNull(findDisplay 9500)) then {[] spawn life_fnc_cellphone_call;};
                [] spawn {uiSleep 10;
                    life_phoneCallStatus = 0;
                    if !(isNull(findDisplay 9500)) then {[] spawn life_fnc_cellphone_call;};};};
        case ("endPhoneCall"): {_phoneData params[["_button", controlNull, [controlNull]]];
                if (_button isEqualTo controlNull) exitWith {};
                if (life_phoneCallStatus isNotEqualTo 2) exitWith {};
                private _dialogQuestion = ["Do you want to hang up your phone call?", "Hang Up", "Yes", "No"] call BIS_fnc_guiMessage;
                if !(_dialogQuestion) exitWith {}; [
                    ["endPhoneCall", [life_phoneCallID, player]], "TON_fnc_handlePhoneCallSRV", 2] spawn life_fnc_MP;
                ["phoneCallEnded"] call life_fnc_phoneCallClient;
                uiSleep 0.5;
                if !(isNull(findDisplay 9500)) then {[] spawn life_fnc_cellphone_call;};};
        case ("phoneCallEstablished"): {_phoneData params[["_channelID", -1, [0]]];
                if (_channelID isEqualTo - 1) exitWith {};
                life_phoneCallID = _channelID;
                life_phoneCallStatus = 2;
                ["Phone link established!"] spawn life_fnc_handleMessage;
                if !(isNull(findDisplay 9500)) then {[] spawn life_fnc_cellphone_call;};};
        case ("phoneLinesMaxed"): {life_phoneCallStatus = 0;
                life_phoneCallID = -1;
                life_phoneCallData = [objNull, "", objNull, ""];
                ["Phone lines are currently at maximum capacity, try again later!"] spawn life_fnc_handleMessage;
                if !(isNull(findDisplay 9500)) then {[] spawn life_fnc_cellphone_call;};};
        case ("phoneCallEnded"): {life_phoneCallStatus = 0;
                life_phoneCallID = -1;
                life_phoneCallData = [objNull, "", objNull, ""];
                ["Your phone call has ended"] spawn life_fnc_handleMessage;
                if !(isNull(findDisplay 9500)) then {[] spawn life_fnc_cellphone_call;};};};