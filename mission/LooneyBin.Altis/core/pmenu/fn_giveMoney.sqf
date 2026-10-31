#include "..\..\macro.h"
if (scriptAvailable(3)) exitWith {};
disableSerialization;
if ((lbCurSel 341003) isEqualTo - 1) exitWith {["You didn't selected anyone to give this to", "basic"] spawn life_fnc_handleMessage;
    false};
private _unit = allUnits param[allUnits findIf {(getPlayerUID _x) isEqualTo(lbData[341003, lbCurSel 341003])}, objNull];
if ((isNull _unit) || (_unit isEqualTo player)) exitWith {false};
private _cashAmount = parseNumber(ctrlText 341002);
if (_cashAmount <= 0) exitWith {["You didn't input any money to give", "basic"] spawn life_fnc_handleMessage;
    false};
if (_cashAmount > life_cash) exitWith {["You don't have that much to give!", "basic"] spawn life_fnc_handleMessage;
    false};
if (_cashAmount > 999999) exitWith {["You can't give more than $999,999 at a time.", "basic"] spawn life_fnc_handleMessage;
    false};
if (!life_use_atm) exitWith {["You recently robbed a store! You can't give money away just yet.", "basic"] spawn life_fnc_handleMessage;
    false};
if ((lbData[361003, lbCurSel 361003]) in life_arrested_uid) exitWith {
    ["You have recently arrested this player; you cannot give them the money you made from their arrest!", "basic"] spawn life_fnc_handleMessage;
    false};
if (life_gfunds_active) exitWith {
    ["You can't give money while having an active gang bank withdrawal. Try again in a couple seconds.", "basic"] spawn life_fnc_handleMessage;
    false};
if (player distance2D _unit > 20) exitWith {["The selected player is too far away!", "basic"] spawn life_fnc_handleMessage;
    false};
[format["You gave $%1 to %2.", [_cashAmount] call life_fnc_numberText, name _unit], "basic"] spawn life_fnc_handleMessage; [
    [_unit, _cashAmount, player], "life_fnc_receiveMoney", _unit, false, false] spawn life_fnc_MP;
[] spawn life_fnc_money;
life_cash = life_cash - _cashAmount;
life_ucashCacheC = ((life_cash / 2) + 5);
[0] call life_fnc_ClUpdatePartial; [
    ["-CASHGIVE-", player, (profileName), format["gave $%1 cash to %2 (%3).", [_cashAmount] call life_fnc_numberText, (name _unit), (getPlayerUID _unit)]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
["cash_send", _cashAmount] call life_fnc_statArrUpdate;
if (playerSide isEqualTo civilian && {A_stats_civTime < 300 && _cashAmount >= 74999}) then {[
        ["-MONEYWARNING-", player, profileName, format["gave $%1 to %2 (%3). Civ time: %4 minutes | Bank: $%5 | Cash: $%6 | Position: %7 | Experience: %8.", [_cashAmount] call life_fnc_numberText, _unit getVariable["plb_name", name _unit], getPlayerUID _unit, A_stats_civTime, [life_atmCash] call life_fnc_numberText, [life_cash] call life_fnc_numberText, getPosATL player, [life_side_exp] call life_fnc_numberText]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
};