#include "..\..\macro.h"
if (scriptAvailable(5)) exitWith {
    ["Wait a few seconds before depositing more money in to gang bank account or try the deposit all feature instead.", "basic"] spawn life_fnc_handleMessage;
    ctrlEnable[3303, true];};
if (life_gang_funds isEqualTo - 1) exitWith {closeDialog 0;};
life_gang_data params[["_gangID", -1, [0]], ["_gangName", "", [""]], ["_rank", 5, [0]]];
if (_gangID isEqualTo - 1) exitWith {closeDialog 0;};
params[["_depositAll", false, [false]]];
private _value = 0;
_value =
if (_depositAll) then {life_cash} else {parseNumber(ctrlText 3305)};
if !(_value isEqualType 0) exitWith {ctrlEnable[3303, true];};
if (!_depositAll && (_value > 9999999)) exitWith {["You can't deposit more than $9,999,999", "basic"] spawn life_fnc_handleMessage;
    ctrlEnable[3303, true];};
if (!_depositAll && !([str(_value)] call life_fnc_isNumber)) exitWith {
    ["You can't deposit an expontential value due to the A3 Engine limitations... Try an amount below $9,999,999.", "basic"] spawn life_fnc_handleMessage;
    ctrlEnable[3303, true];};
if (_value <= 0) exitWith {["You did not enter an amount to deposit!", "basic"] spawn life_fnc_handleMessage;
    ctrlEnable[3303, true];};
if (_value > life_cash) exitWith {["You do not have that much cash on you.", "basic"] spawn life_fnc_handleMessage;
    ctrlEnable[3303, true];};
ctrlEnable[3302, false];
ctrlEnable[3303, false];
ctrlEnable[3304, false];
life_gfunds_active = true;
[format["Attempting to deposit $%1 in your gang account...", [_value] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage; [
    ["-GANGDEPOSIT-", player, (profileName), format["attempted to deposit $%1 from their GANG bank account. GANG ACCOUNT BAL: $%2 - Player Cash: $%3", [_value] call life_fnc_numberText, [life_gang_funds] call life_fnc_numberText, [life_cash] call life_fnc_numberText]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
[[1, _gangID, player, _value, life_cash, life_cashCacheB], "TON_fnc_gangBank", false, false] spawn life_fnc_MP;
life_cash = life_cash - _value;
life_cashCacheB = ((life_cash / 4) + 9);
[6] call life_fnc_ClupdatePartial;
life_gangfund_ready = false;
life_gang_funds = -1;
disableSerialization;
private _display = findDisplay 3300;
private _text = _display displayCtrl 3301;
_text ctrlSetStructuredText parseText format["<img size='1.7' image='icons\bank.paa'/> %1<br/><img size='1.6' image='icons\money.paa'/> $%2", "Processing Txn...", [life_cash] call life_fnc_numberText];
[] spawn {waitUntil {!life_gfunds_active};
    if (isNull(findDisplay 3300)) exitWith {}; [[0, life_gang_data select 0, player], "TON_fnc_gangBank", 2] spawn life_fnc_MP;
    waitUntil {uiSleep 0.3;
        life_gangfund_ready};
    uiSleep 0.5;
    [6] call life_fnc_ClupdatePartial;
    disableSerialization;
    private _display = findDisplay 3300;
    private _text = _display displayCtrl 3301;
    _text ctrlSetStructuredText parseText format["<img size='1.7' image='icons\bank.paa'/> $%1<br/><img size='1.6' image='icons\money.paa'/> $%2", [life_gang_funds] call life_fnc_numberText, [life_cash] call life_fnc_numberText];
    if ((life_gang_funds >= 1) && ((life_gang_data select 2) <= 2)) then {ctrlEnable[3302, true];};
    ctrlEnable[3303, true];
    ctrlEnable[3304, true];};