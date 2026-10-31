params[["_unit", objNull, [objNull]], ["_trigger", "", [""]], ["_recipent", "", [""]], ["_msg", [], [[]]]];
if (isNull _unit || _trigger isEqualTo "" || _recipent isEqualTo "" || _msg isEqualTo[]);
if !(_unit isEqualTo player) exitWith {};
_msg = _msg joinString " ";
private _trigger = toLower(_trigger);
switch (_trigger) do {case ("text"): {private _toSend = allPlayers param[allPlayers findIf {name _x isEqualTo _recipent}, objNull];
            if (isNull _toSend) exitWith {systemChat format["Player '%1' not found.", _recipent]}; [
                [0, player, _toSend, _msg], "TON_fnc_handlePhoneMsg", 2] call life_fnc_MP;
            systemChat format["You sent %1 a message: %2", name _toSend, _msg];}; case ("reply"): {
                if (isNil "life_last_message") exitWith {
                    ["You can't reply when nobody has texted you yet. Are you lonely?", "basic"] spawn life_fnc_handleMessage;};
                private _toSend = allPlayers param[allPlayers findIf {name _x isEqualTo life_last_message}, objNull];
                if (isNull _toSend) exitWith {systemChat format["%1's cell phone is turned off.", life_last_message]}; [
                    [0, player, _toSend, _msg], "TON_fnc_handlePhoneMsg", 2] call life_fnc_MP;
                systemChat format["You sent %1 a message: %2", name _toSend, _msg];};
        case ("911"): {if (!alive player || player getVariable["plb_restrained", false] || life_isDowned) exitWith {}; [
                    [1, player, objNull, _msg], "TON_fnc_handlePhoneMsg", 2] call life_fnc_MP;
                systemChat format["You sent the Police a message: %1", _msg];};
        case ("311"): {if (!alive player || player getVariable["plb_restrained", false] || life_isDowned) exitWith {}; [
                    [2, player, objNull, _msg], "TON_fnc_handlePhoneMsg", 2] call life_fnc_MP;
                systemChat format["You sent the Medics a message: %1", _msg];};};