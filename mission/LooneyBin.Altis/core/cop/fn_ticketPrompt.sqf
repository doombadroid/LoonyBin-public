params[["_cop", objNull, [objNull]], ["_val", 0, [0]]];
if (isNull _cop) exitWith {};
if (!isNull(findDisplay 2600)) exitWith {[
        [1, format["%1 currently has an active ticket displayed.", [profileName] call life_fnc_cleanName]], "life_fnc_broadcast", _cop] call life_fnc_MP;
};
disableSerialization;
["life_ticket_pay"] call life_fnc_createDialog;
waitUntil {!isNull(findDisplay 2600)};
private _display = findDisplay 2600;
private _control = _display displayCtrl 2601;
life_ticket_paid = false;
life_ticket_attempted = false;
life_ticket_val = _val;
life_ticket_cop = _cop;
_control ctrlSetStructuredText parseText format["<t align='center'><t size='.8px'>%1 has given you a ticket for $%2", [name _cop] call life_fnc_cleanName, [life_ticket_val] call life_fnc_numberText];
[] spawn {disableSerialization;
    waitUntil {life_ticket_paid || life_ticket_attempted || (isNull(findDisplay 2600)) || ((life_is_arrested param [0,0]) isEqualTo 1)};
    if ((life_is_arrested param [0,0]) isEqualTo 1) exitWith {};
    if (isNull(findDisplay 2600) && !life_ticket_attempted) then {[
            [0, format["%1 refused to pay the ticket.", [profileName] call life_fnc_cleanName]], "life_fnc_broadcast", west] spawn life_fnc_MP;
        [
            [1, format["%1 refused to pay the ticket.", [profileName] call life_fnc_cleanName]], "life_fnc_broadcast", life_ticket_cop] spawn life_fnc_MP;
    };};