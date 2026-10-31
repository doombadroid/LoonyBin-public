// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only
/*
    File: fn_cyberdeckBuyModule.sqf  (life_fnc_cyberdeckBuyModule)
    LooneyBin 2026-07-20: buy a PERMANENT cyberdeck module at the Tech shop. Client deducts the price
    (client-authoritative money, same trust boundary as the virtual shop), then the server validates
    not-owned, grants it, and persists to players.cyberdeck_modules (TON_fnc_cyberdeckSRV "buyModule").
    Defs live in PLB_cdModules (configuration.sqf): [id, name, price, desc].
*/
params [["_id", -1, [0]]];
private _def = (PLB_cdModules select { (_x select 0) isEqualTo _id }) param [0, []];
if (_def isEqualTo []) exitWith {};
_def params ["", "_name", "_price"];
// DROP-ONLY guard (owner 2026-07-21): Tier 4 chips carry price -1 so they can never be shelved. Belt and
// braces with the shop filter -- a negative price reaching life_fnc_uC "take" would CREDIT the buyer.
if (_price <= 0) exitWith {[format ["The %1 isn't for sale. You'd have to find one.", _name], "basic"] spawn life_fnc_handleMessage;};

if (_id in (player getVariable ["plb_cdMods", []])) exitWith {
    [format ["You already own the %1.", _name], "basic"] spawn life_fnc_handleMessage;};

// prefer bank (needs a debit card) for these big-ticket buys, else cash. life_fnc_uC "take" only deducts on success.
private _paid = if (life_atmcash >= _price && {life_inv_debitcard >= 1}) then {["atm", "take", _price] call life_fnc_uC} else {
    ["cash", "take", _price] call life_fnc_uC};
if !(_paid) exitWith {
    [format ["You need $%1 -- cash on hand, or bank funds with a debit card.", [_price] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
};

[["buyModule", _id, player], "TON_fnc_cyberdeckSRV", 2] spawn life_fnc_MP;   // server grants + persists (toast on install)
