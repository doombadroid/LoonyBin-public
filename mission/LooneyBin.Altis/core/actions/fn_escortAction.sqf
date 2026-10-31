params[["_unit", objNull, [objNull]]];
if !(isNull life_escort) exitWith {["You can only escort one person at a time.", "basic"] spawn life_fnc_handleMessage;};
if (isNull _unit || {!isPlayer _unit} || {!(_unit isKindOf "CAManBase")}) exitWith {};
if !(_unit getVariable["plb_restrained", false]) exitWith {};
if (player distance2D[24973.1, 16740, 1] <= 25) exitWith {
    ["You can't escort people while in the courtroom", "basic"] spawn life_fnc_handleMessage};
if (life_passiveModeJIP) exitWith {
    ["You cannot escort people while in passive mode! You can disable it on your phone (Y).", "basic"] spawn life_fnc_handleMessage;};
_unit attachTo[player, [0, 1, 0]];
_unit setVariable["plb_transporting", nil, true];
_unit setVariable["plb_escorting", true, true];
_unit setVariable["plb_escortee", player, true];
player setVariable["plb_escortObj", _unit];
life_escort = _unit;
player reveal _unit;
if (playerSide isEqualTo civilian && isNil {_unit getVariable "plb_civRestrained"}) then {[
        [24, player], "TON_fnc_wantedAdd", 2] spawn life_fnc_MP;};
[] spawn {waitUntil {!isNull objectParent player || isNull life_escort};
    if (!isNull objectParent player || isNull attachedTo life_escort) then {detach life_escort;
        life_escort setVariable["plb_escorting", false, true]};
    life_escort = objNull;
    player setVariable["plb_escortObj", objNull];};