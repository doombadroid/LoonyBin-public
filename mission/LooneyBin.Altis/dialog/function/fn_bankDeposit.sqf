#include "..\..\macro.h"
if (scriptAvailable(5)) exitWith {
    ["Wait a few seconds before depositing more money in your bank account or try the deposit all feature instead.", "basic"] spawn life_fnc_handleMessage;
};
params[["_depositAll", false, [false]]];
private _preBalance = life_atmcash;
private _value = 0;
_value =
if (_depositAll) then {life_cash} else {parseNumber(ctrlText 2702)};
if !(_value isEqualType 0) exitWith {};
if (!_depositAll && (_value > 9999999)) exitWith {["You can't deposit more than $9,999,999", "basic"] spawn life_fnc_handleMessage;};
if (!_depositAll && !([str(_value)] call life_fnc_isNumber)) exitWith {
    ["You can't deposit an expontential value due to the A3 Engine limitations... Try an amount below $9,999,999.", "basic"] spawn life_fnc_handleMessage;
};
if (_value <= 0) exitWith {["You did not enter an amount to deposit!", "basic"] spawn life_fnc_handleMessage;};
if (_value > life_cash) exitWith {["You do not have that much cash on you.", "basic"] spawn life_fnc_handleMessage;};
// ATM SKIMMER: if this ATM is rigged (and not by you), a slice of the deposit is siphoned to the planter.
// owner 2026-07-21: 10% -> 3% (Skim Daemon rebalance, spec band 2-4%). Server rolls the silent alarm.
private _skim = 0;
if (!isNil "life_skimATM" && {!isNull life_skimATM}) then {private _so = life_skimATM call life_fnc_atmSkimOwner;
    if (_so isNotEqualTo "" && {_so isNotEqualTo (getPlayerUID player)}) then { _skim = round (_value * 0.03); };};
life_cash = life_cash - _value;
life_cashCacheB = ((life_cash / 4) + 9);
life_atmcash = life_atmcash + (_value - _skim);
life_atmcashCacheB = ((life_atmcash / 4) + 11);
if (_skim > 0) then {[["credit", getPosATL life_skimATM, _skim], "TON_fnc_atmSkimSRV", 2] spawn life_fnc_MP;
    [format ["An ATM skimmer siphoned $%1 (3%%) off your deposit.", [_skim] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
};
[6] call life_fnc_ClupdatePartial;
[] call life_fnc_atmMenu;
[format["You have deposited $%1 into your bank account", [_value] call life_fnc_numberText]] spawn life_fnc_handleMessage; [
    ["-DEPOSIT-", player, (profileName), format["deposited $%1 into their bank account. Pre Bal: $%2 - Post Bal: $%3", [_value] call life_fnc_numberText, [_preBalance] call life_fnc_numberText, [life_atmcash] call life_fnc_numberText]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
if (playerSide isEqualTo civilian && {A_stats_civTime < 300 && _value >= 74999}) then {[
        ["-MONEYWARNING-", player, profileName, format["deposited $%1 to their bank. Civ time: %2 minutes | Bank: $%3 | Cash: $%4 | Position: %5 | Experience: %6.", [_value] call life_fnc_numberText, A_stats_civTime, [life_atmCash] call life_fnc_numberText, [life_cash] call life_fnc_numberText, getPosATL player, [life_side_exp] call life_fnc_numberText]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
};