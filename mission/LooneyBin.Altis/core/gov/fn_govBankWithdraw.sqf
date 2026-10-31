#include "..\..\macro.h"
if (scriptAvailable(5)) exitWith {
    ["Wait a few seconds before withdrawing more money from the governor bank account.", "basic"] spawn life_fnc_handleMessage;
    ctrlEnable[3302, true];};
if !(getPlayerUID player isEqualTo(SRV_governorData param[0, "GovUID"])) exitWith {closeDialog 0;};
private _value = parseNumber(ctrlText 251002);
private _preBalance = life_atmcash;
private _gangID = 50000;
if (_value < 500) exitWith {["You can't withdraw less than $500.", "basic"] spawn life_fnc_handleMessage;};
if (_value > 9999999) exitWith {["You can't withdraw more than $9,999,999", "basic"] spawn life_fnc_handleMessage;
    ctrlEnable[3302, true];};
if (_value <= 0) exitWith {["You did not enter an amount to withdraw!", "basic"] spawn life_fnc_handleMessage;
    ctrlEnable[3302, true];};
if !([str(_value)] call life_fnc_isNumber) exitWith {
    ["You can't deposit an expontential value due to the A3 Engine limitations... Try an amount below $9,999,999.", "basic"] spawn life_fnc_handleMessage;
    ctrlEnable[3302, true];};
if (_value > life_gang_funds) exitWith {["There is not enough governor bank funds in the account!", "basic"] spawn life_fnc_handleMessage;
    ctrlEnable[3302, true];};
ctrlEnable[251003, false];
life_gfunds_active = true;
[format["Attempting to withdraw $%1 from your governor bank account... This will take a few seconds as withdrawing has a delay to prevent exploits.", [_value] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
[
    ["-GOVBANKWITHDRAW-", player, (profileName), format["attempted to withdraw $%1 from their GOV bank account. GOV ACCOUNT BAL: $%2 - Player Cash: $%3", [_value] call life_fnc_numberText, [life_gang_funds] call life_fnc_numberText, [_preBalance] call life_fnc_numberText]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
[[1, _gangID, player, -(_value), life_cash, life_cashCacheB], "TON_fnc_gangBank", false, false] spawn life_fnc_MP;
life_gangfund_ready = false;
life_gang_funds = -1;
disableSerialization;
private _display = findDisplay 251000;
private _text = _display displayCtrl 251001;
_text ctrlSetStructuredText parseText format["<img size='1.7' image='icons\bank.paa'/> %1<br/><img size='1.6' image='icons\money.paa'/> $%2", "Processing Txn...", [life_cash] call life_fnc_numberText];
[_gangID] spawn {params["_gangID"];
    waitUntil {!life_gfunds_active};
    if (isNull(findDisplay 251000)) exitWith {}; [[0, _gangID, player], "TON_fnc_gangBank", false, false] spawn life_fnc_MP;
    waitUntil {uiSleep 0.3;
        life_gangfund_ready};
    uiSleep 0.5;
    [6] call life_fnc_ClupdatePartial;
    disableSerialization;
    private _display = findDisplay 251000;
    private _text = _display displayCtrl 251001;
    _text ctrlSetStructuredText parseText format["<img size='1.7' image='icons\bank.paa'/> $%1<br/><img size='1.6' image='icons\money.paa'/> $%2", [life_gang_funds] call life_fnc_numberText, [life_cash] call life_fnc_numberText];
    ctrlEnable[251003, true];};