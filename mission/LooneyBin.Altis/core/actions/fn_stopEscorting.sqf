private _escortee = life_escort;
if (isNull _escortee) exitWith {};
if !(_escortee getVariable["plb_escorting", false]) exitWith {};
_escortee setVariable["plb_escorting", nil, true];
player setVariable["plb_escortObj", nil];
detach _escortee;
life_escort = objNull;