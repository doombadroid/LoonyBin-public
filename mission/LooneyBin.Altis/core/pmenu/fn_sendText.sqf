if !(params[["_button", controlNull], ["_mode", -1]]) exitWith {};
disableSerialization;
private _message = ctrlText 3001;
if ((!alive player) || (isNull player)) exitWith {};
// Silence Cell quickhack: outgoing comms are jammed (all modes -- DM, police, medic, gang)
if (diag_tickTime < (missionNamespace getVariable ["plb_qhSilencedUntil", 0])) exitWith {
    [format ["<t color='#ff3b1e'>SIGNAL JAMMED</t> -- your comms are muted for another %1s.",
        ceil ((missionNamespace getVariable ["plb_qhSilencedUntil", 0]) - diag_tickTime)], "basic"] spawn life_fnc_handleMessage;};
if (_mode isEqualTo 4) exitWith {["This message type is currently disabled.", "basic"] spawn life_fnc_handleMessage;};
if ((_message isEqualTo "") && !(_mode in [4])) exitWith {["You must enter a message to send!", "basic"] spawn life_fnc_handleMessage;};
private _disallowedContent = ["<br/>", "<t", "<img", "<a"] apply {toLower _x};
if !(_disallowedContent findIf {_x in toLower _message}
isEqualTo - 1) exitWith {systemChat format["Your message contains disallowed content: %1", _disallowedContent select {
        _x in toLower _message}
    joinString ", "]};
switch (_mode) do {case 0: {if !((lbCurSel 3002) >= 0) exitWith {
                ["You must select a player you are sending the text to!", "basic"] spawn life_fnc_handleMessage;};
            if ((count _message) > 500) exitWith {["The message you entered is too long to send!", "basic"] spawn life_fnc_handleMessage;};
            if ((lbData[3002, lbCurSel 3002]) isEqualTo "BENBONES") exitWith {   // AI DM, not a player
                ["Ben Bones Official", 1, _message] call PLB_fnc_msgAppend;   // threads store
                [] spawn life_fnc_cellphone;
                [["send", _message], "TON_fnc_bonesDM", 2, false, false] spawn life_fnc_MP;
                ["You texted Ben Bones Official. He's in the bunker -- give him a minute to reply.", "basic"] spawn life_fnc_handleMessage;
            };
            private _target = allPlayers param[allPlayers findIf {(lbData[3002, lbCurSel 3002]) isEqualTo(getPlayerUID _x)}, objNull];
            if (isNull _target) exitWith {["The player you are trying to message can't be found", "basic"] spawn life_fnc_handleMessage;};
            if (((side _target) isEqualTo west) && ((life_is_arrested select 0) isEqualTo 1)) exitWith {
                ["Prison inmates are not allowed to message officers of the law!", "basic"] spawn life_fnc_handleMessage;};
            [[name _target] call life_fnc_cleanName, 1, _message] call PLB_fnc_msgAppend;   // threads store
            [] spawn life_fnc_cellphone; [[_mode, player, _target, _message], "TON_fnc_handlePhoneMsg", false] call life_fnc_MP;
            [format["You sent %1 a message: %2", [name _target] call life_fnc_cleanName, _message], "basic"] spawn life_fnc_handleMessage;
        };
    case 1: {if ((count _message) > 500) exitWith {["The message you entered is too long to send!", "basic"] spawn life_fnc_handleMessage;
            };
            private _target = "The Police";
            if ((life_is_arrested select 0) isEqualTo 1) exitWith {
                ["Prison inmates are not allowed to message officers of the law!", "basic"] spawn life_fnc_handleMessage;};
            [] spawn life_fnc_cellphone; [[_mode, player, objNull, _message], "TON_fnc_handlePhoneMsg", false] call life_fnc_MP;
            [format["You sent %1 a message: %2", _target, _message], "basic"] spawn life_fnc_handleMessage;};
    case 2: {if ((count _message) > 500) exitWith {["The message you entered is too long to send!", "basic"] spawn life_fnc_handleMessage;
            };
            private _target = "Emergency Medical";
            [] spawn life_fnc_cellphone; [[_mode, player, objNull, _message], "TON_fnc_handlePhoneMsg", false] call life_fnc_MP;
            [format["You sent %1 a message: %2", _target, _message], "basic"] spawn life_fnc_handleMessage;};
    case 3: {if ((count _message) > 500) exitWith {["The message you entered is too long to send!", "basic"] spawn life_fnc_handleMessage;
            };
            private _target = "The Admins";
            [] spawn life_fnc_cellphone; [[_mode, player, objNull, _message], "TON_fnc_handlePhoneMsg", false] call life_fnc_MP;
            [format["You sent %1 a message: %2", _target, _message], "basic"] spawn life_fnc_handleMessage;};
    case 4: {if ((life_last_taxi > 0) && ((time - life_last_taxi) < 300)) exitWith {
                ["You may only call for a taxi once every 5 minutes.", "basic"] spawn life_fnc_handleMessage;};
            life_last_taxi = time;
            ["A taxi has been called.	Note that taxis are not always available.", "basic"] spawn life_fnc_handleMessage;};
    case 5: {if ((count _message) > 500) exitWith {["The message you entered is too long to send!", "basic"] spawn life_fnc_handleMessage;
            };
            if ((call life_adminLevel) <= 1) exitWith {["You are not an admin!", "basic"] spawn life_fnc_handleMessage;};
            [] spawn life_fnc_cellphone;
            [format["Message Sent To All: %1", _message], "basic"] spawn life_fnc_handleMessage; [
                [_mode, player, objNull, _message], "TON_fnc_handlePhoneMsg", false] call life_fnc_MP;};
    case 6: {if ((call life_adminLevel) <= 1) exitWith {["You are not an admin!", "basic"] spawn life_fnc_handleMessage;};
            if !((lbCurSel 3002) >= 0) exitWith {
                ["You must select a player you are sending the text to!", "basic"] spawn life_fnc_handleMessage;};
            if ((count _message) > 500) exitWith {["The message you entered is too long to send!", "basic"] spawn life_fnc_handleMessage;};
            private _target = allPlayers param[allPlayers findIf {(lbData[3002, lbCurSel 3002]) isEqualTo(getPlayerUID _x)}, objNull];
            if (isNull _target) exitWith {["The player you are trying to message can't be found", "basic"] spawn life_fnc_handleMessage;};
            [[name _target] call life_fnc_cleanName, 1, _message] call PLB_fnc_msgAppend;   // threads store
            [] spawn life_fnc_cellphone; [[_mode, player, _target, _message], "TON_fnc_handlePhoneMsg", false] call life_fnc_MP;
            [format["Admin Message Sent To: %1 - Message: %2", [name _target] call life_fnc_cleanName, _message], "basic"] spawn life_fnc_handleMessage;
        };
    case 7: {if ((getPlayerUID player) isNotEqualTo(SRV_governorData param[0, "GovUID"])) exitWith {
                ["You are not the governor!", "basic"] spawn life_fnc_handleMessage;};
            if ((count _message) > 500) exitWith {["The message you entered is too long to send!", "basic"] spawn life_fnc_handleMessage;};
            if (serverTime < (profileNamespace getVariable["plb_lastgov_message", [0, 0]] param[1, 0])) exitWith {
                [format["You have sent a recent governor message! Try again in %1 second(s).", round((profileNamespace getVariable["plb_lastgov_message", [0, 0]] param[1, 0]) - serverTime)], "basic"] spawn life_fnc_handleMessage;
            };
            [] spawn life_fnc_cellphone;
            [format["Message Sent To All: %1", _message], "basic"] spawn life_fnc_handleMessage; [
                [10, player, objNull, _message], "TON_fnc_handlePhoneMsg", false] call life_fnc_MP;
            profileNameSpace setVariable["plb_lastgov_message", [PLB_instance_id, serverTime + 1800]];};
    case 8: {if ((call life_eventCoordinatorLevel) <= 0) exitWith {};
            if ((count _message) > 500) exitWith {["The message you entered is too long to send!", "basic"] spawn life_fnc_handleMessage;};
            [] spawn life_fnc_cellphone;
            [format["Message Sent To All: %1", _message], "basic"] spawn life_fnc_handleMessage; [
                [11, player, objNull, _message], "TON_fnc_handlePhoneMsg", false] call life_fnc_MP;};};