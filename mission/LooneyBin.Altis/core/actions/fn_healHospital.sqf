if !([50] call life_fnc_debitCard) exitWith {};
["The doctor is healing you... don't be scared.", "basic"] spawn life_fnc_handleMessage;
uiSleep 7;
if (player distance(_this select 0) > 5) exitWith {
    ["You need to be within 5m while the doctor is healing you.", "basic"] spawn life_fnc_handleMessage;};
["You are now fully healed!", "basic"] spawn life_fnc_handleMessage;
private _plb_dmg = player;
_plb_dmg setDamage 0;
player setVariable["plb_can_revive", nil, true];
[] call life_fnc_hudUpdate;