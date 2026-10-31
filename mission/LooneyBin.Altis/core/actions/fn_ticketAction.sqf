disableSerialization;
private _unit = cursorTarget;
if (isNull _unit || !isPlayer _unit) exitWith {};
if (player distance _unit > 8) exitWith {};
["life_ticket_give"] call life_fnc_createDialog;
ctrlSetText[2651, format["Ticketing %1", [name _unit] call life_fnc_cleanName]];
life_ticket_unit = _unit;