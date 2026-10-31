params["_target", "_caller", "_actionId", "_level"];
if !(_level in [0, 1, 2]) exitWith {};
if !(playerSide isEqualTo civilian) exitWith {["You must be a civilian!", "basic"] spawn life_fnc_handleMessage;};
if ((primaryWeapon player) isEqualTo "") exitWith {["You'll need a bigger gun to pull this off...", "basic"] spawn life_fnc_handleMessage;
};
if (SRV_convoy_status select 0) exitWith {["Someone is already stealing a shipment!", "basic"] spawn life_fnc_handleMessage;};
if ([] call life_fnc_activeFederalEvent) exitWith {
    ["There is already another Federal Event happening.", "basic"] spawn life_fnc_handleMessage;};
if ((SRV_convoy_status select 1) > serverTime - 1800) exitWith {
    [format["Altis Shipping has recently been attacked! Try again in %1 minute(s).", ceil((((SRV_convoy_status select 1) + 1800) - serverTime) / 60)], "basic"] spawn life_fnc_handleMessage;
};
if (SRV_lastRobbery > (serverTime - (60 * 15))) exitWith {
    [2, format["Security is high due to a recent robbery and you cannot start the robbery. Try again in %1 minute(s).", ceil((SRV_lastRobbery - (serverTime - (60 * 15))) / 60)]] call life_fnc_broadcast
};
private _copsRequired =
switch (_level) do {case 0: {4};
    case 1: {6};
    case 2: {9};}; _copsRequired = _copsRequired + (SRV_convoy_status select 3);
if !([_copsRequired] call life_fnc_policeRequired) exitWith {};
private _bribeCost =
switch (_level) do {case 0: {10000};
    case 1: {15000};
    case 2: {25000};
}; private _action = [format["You are about to bribe the dock worker for $%1", [_bribeCost] call life_fnc_numberText], "Altis Shipping", "Confirm", "Cancel"] call BIS_fnc_guiMessage;
if !(_action) exitWith {};
if (life_cash < _bribeCost) exitWith {["You do not have enough cash to bribe the worker.", "basic"] spawn life_fnc_handleMessage;};
life_cash = (round(life_cash - _bribeCost)) max 0;
life_cashCacheB = ((life_cash / 4) + 9);
[6] call life_fnc_ClupdatePartial; [[_level], "TON_fnc_convoyRobbery", 2] spawn life_fnc_MP;