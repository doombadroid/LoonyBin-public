#include "..\..\macro.h"
if (scriptAvailable(3)) exitWith {["Wait a few seconds before withdrawing more money.", "basic"] spawn life_fnc_handleMessage;};
private _val = parseNumber(ctrlText 2702);
private _preBalance = life_atmcash;
if (_val > 9999999) exitWith {["You can't withdraw more than $9,999,999", "basic"] spawn life_fnc_handleMessage;};
if (_val <= 0) exitWith {["You did not enter an amount to withdraw!", "basic"] spawn life_fnc_handleMessage;};
if !([str _val] call life_fnc_isNumber) exitWith {
    ["You can't deposit an expontential value due to the A3 Engine limitations... Try an amount below $9,999,999.", "basic"] spawn life_fnc_handleMessage;
};
if (_val < 100 && life_atmcash > 20000000) exitWith {["You can't withdraw less than $100.", "basic"] spawn life_fnc_handleMessage};
if (_val > life_atmcash) exitWith {["You do not have that much money to withdraw!", "basic"] spawn life_fnc_handleMessage;};
// ATM SKIMMER: if this ATM is rigged (and not by you), a slice of the withdrawal is siphoned to the planter.
// owner 2026-07-21: 10% -> 3% (Skim Daemon rebalance, spec band 2-4%). Server rolls the silent alarm.
private _skim = 0;
if (!isNil "life_skimATM" && {!isNull life_skimATM}) then {private _so = life_skimATM call life_fnc_atmSkimOwner;
    if (_so isNotEqualTo "" && {_so isNotEqualTo (getPlayerUID player)}) then { _skim = round (_val * 0.03); };};
life_cash = life_cash + (_val - _skim);
life_cashCacheB = ((life_cash / 4) + 9);
life_atmcash = life_atmcash - _val;
life_atmcashCacheB = ((life_atmcash / 4) + 11);
if (_skim > 0) then {[["credit", getPosATL life_skimATM, _skim], "TON_fnc_atmSkimSRV", 2] spawn life_fnc_MP;
    [format ["An ATM skimmer siphoned $%1 (3%%) off your withdrawal.", [_skim] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
};
[6] call life_fnc_ClupdatePartial;
[] call life_fnc_atmMenu;
[format["You have withdrawn $%1 from your bank account.", [_val] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage; [
    ["-WITHDRAW-", player, (profileName), format["withdrew $%1 from their bank account. Pre Bal: $%2 - Post Bal: $%3", [_val] call life_fnc_numberText, [_preBalance] call life_fnc_numberText, [life_atmcash] call life_fnc_numberText]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;