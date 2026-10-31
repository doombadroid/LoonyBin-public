#include "..\..\macro.h"
/*
    life_fnc_medSupplyEarn — credit the local player (a med-supply crate / revive-drone owner) for a sale.
    Pushed by TON_fnc_medSupplyPay (server) to the owner's client. Money goes to BANK (life_atmcash).
*/
params [["_amt", 0, [0]]];
// Server-origin guard: TON_fnc_medSupplyPay (server, owner 2) is the only legit caller; this credits
// bank cash, so a local call must not self-award a med-supply sale.
if (remoteExecutedOwner != 2) exitWith {};
if (_amt <= 0) exitWith {};
life_atmcash = life_atmcash + _amt;
life_atmcashCacheB = ((life_atmcash / 4) + 11);
[0] call life_fnc_ClupdatePartial;
[format ["Your medical drone sold supplies — earned $%1 (bank).", [_amt] call life_fnc_numberText], "info"] spawn life_fnc_handleMessage;
