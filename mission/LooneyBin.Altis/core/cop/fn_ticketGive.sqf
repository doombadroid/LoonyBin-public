if (isNil {life_ticket_unit}) exitWith {["Person to ticket is nil", "basic"] spawn life_fnc_handleMessage;};
if (isNull life_ticket_unit) exitWith {["Person to ticket doesn't exist.", "basic"] spawn life_fnc_handleMessage;};
private _val = ctrlText 2652;
if !([_val] call life_fnc_isNumber) exitWith {["You didn't enter a positive integer.", "basic"] spawn life_fnc_handleMessage;};
_val = parseNumber _val;
if (_val <= 0) exitWith {["The ticket must be atleast $1.", "basic"] spawn life_fnc_handleMessage;};
if (_val > 1500000) exitWith {
    [format["You can't give tickets higher than %1.", [1500000] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;}; [
    [0, format["%1 gave a ticket of $%2 to %3", profileName, [_val] call life_fnc_numberText, name life_ticket_unit]], "life_fnc_broadcast", -2] spawn life_fnc_MP;
[
    ["-TICKET-", player, profileName, format["gave a ticket of $%1 to %2 (%3) at POS: %4", [_val] call life_fnc_numberText, name life_ticket_unit, getPlayerUID life_ticket_unit, getPosATL player]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
[[player, _val], "life_fnc_ticketPrompt", life_ticket_unit, false, false] spawn life_fnc_MP;
closeDialog 0;
["action", "giveticketvalue", _val] call life_fnc_handleQuest;
["action", "ticket", 1] call life_fnc_handleQuest;
["ticketsgiven", 1] call life_fnc_statArrUpdate;
["ticketsgivenamount", _val] call life_fnc_statArrUpdate;