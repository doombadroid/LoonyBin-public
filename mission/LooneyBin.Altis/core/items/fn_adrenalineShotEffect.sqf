params[["_unit", objNull, [objNull]]];
if (player getVariable["plb_downed", false]) then {player setVariable["plb_adrenaline", true, true]};
[] call life_fnc_hudUpdate;
if (!isNull _unit) then {titleText[format["%1 has injected you with an Adrenaline Shot", [name _unit] call life_fnc_cleanName], "PLAIN"]};