/*
    life_fnc_wantedPerson (LooneyBin)  -- return a unit's wanted-list entry, or [] if not wanted.
    Entry shape (see server vars.sqf): [name, uid, [chargeIDs], bounty, jailTime]. Index 3 = bounty.

    Was a reverse-drift no-op stub (`if (true) exitWith {}`), which -- because the mission registers
    life_fnc_wantedPerson too -- SHADOWED the real life_server impl on the server. So server callers
    (TON_fnc_handleJail, life_fnc_jailSys) always got [] -> jailMe's _bounty fell to its 1500 default ->
    every prisoner bailed for a flat $1500. Restore a real lookup so the entry (and its index-3 bounty)
    resolves wherever this copy wins. life_wanted_list is authoritative on the server and cop-synced on
    clients; a non-cop client simply has an empty list -> [].
*/
params [["_unit", objNull, [objNull]]];
if (isNull _unit) exitWith { [] };
if (isNil "life_wanted_list") exitWith { [] };
private _uid = getPlayerUID _unit;
if (_uid isEqualTo "") exitWith { [] };
private _i = life_wanted_list findIf { (_x isEqualType []) && {(_x param [1, ""]) isEqualTo _uid} };
if (_i isEqualTo -1) exitWith { [] };
life_wanted_list select _i
