params[["_unit", objNull, [objNull]]];
if (isNull _unit) exitWith {};
if (player distance(getMarkerPos "jail_marker2") > 70) exitWith {
    ["You can't use this outside of prison!", "basic"] spawn life_fnc_handleMessage};
if (time - life_last_shank < (60 * 3)) exitWith {["You can only shank someone every 3 minutes!", "basic"] spawn life_fnc_handleMessage};
if (player distance _unit > 2) exitWith {};
if (life_inv_shank < 1) exitWith {};
if !(_unit getVariable["plb_arrested", false]) exitWith {};
if (_unit getVariable["plb_downed", false]) exitWith {};
life_last_shank = time;
["shank", 1] call life_fnc_statArrUpdate;
["action", "shank", 1] spawn life_fnc_handleQuest; [[player, true], "life_fnc_handleDowned", _unit] spawn life_fnc_MP; [
    [0, 1, 2], format["You've been shanked by %1!", [profileName] call life_fnc_cleanName]] remoteExec["life_fnc_broadcast", _unit];