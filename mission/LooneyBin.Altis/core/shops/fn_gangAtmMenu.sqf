#include "..\..\macro.h"
if (scriptAvailable(8)) exitWith {["You cannot access the gang bank again so soon.", "basic"] spawn life_fnc_handleMessage;
    closeDialog 0};
params[["_target", objNull, [objNull]], ["_caller", objNull, [objNull]], ["_actionId", -1, [-1]], ["_arguments", "", [""]]];
// owner 2026-06-15 (#252): gang bank stays its own scroll-wheel action, but only the TOP gang ranks may USE
// it -- rank 1 (leader), 2 (manage/withdraw) and 3 (invite). life_gang_data[2] = the player's gang rank
// (set in fn_gangRanks). param[2,-1] is safe for non-gang / short data -> rejected.
if !((life_gang_data param [2, -1]) in [1, 2, 3]) exitWith {
    ["Only your gang's top ranks can access the gang bank.", "basic"] spawn life_fnc_handleMessage;};
if !(life_use_atm) exitWith {["Because you robbed a store you can't use the ATM for 5 minutes.", "basic"] spawn life_fnc_handleMessage;};
if !(dialog) then {["atmV2MenuV2Gang"] call life_fnc_createDialog;};
if (player getVariable["plb_restrained", false]) exitWith {};
if (player getVariable["plb_surrendered", false]) exitWith {};
if (life_gfunds_active) exitWith {closeDialog 0;
    ["There is a transaction in progress. Please wait until it is complete.", "basic"] spawn life_fnc_handleMessage};
life_gangfund_ready = false;
life_gang_funds = -1;
life_gangMembersList_ready = false;
life_gangMembersList = []; [[0, life_gang_data select 0, player], "TON_fnc_gangBank", false, false] spawn life_fnc_MP; [
    [life_gang_data select 0, player], "TON_fnc_getGangInfo", 2] call life_fnc_MP;
disableSerialization;
private _display = findDisplay 3300;
private _text = _display displayCtrl 3301;
private _title = _display displayCtrl 3308;
_text ctrlSetStructuredText parseText format["<img size='1.7' image='icons\bank.paa'/> %1<br/><img size='1.6' image='icons\money.paa'/> $%2", "Loading...", [life_cash] call life_fnc_numberText];
_title ctrlSetText format["%1's Bank", life_gang_data select 1];
ctrlEnable[3302, false];
ctrlEnable[3303, false];
ctrlEnable[3304, false];
ctrlEnable[3307, false];
[] spawn {waitUntil {uiSleep 0.3;
        life_gangfund_ready && life_gangMembersList_ready};
    uiSleep 0.5;
    disableSerialization;
    private _display = findDisplay 3300;
    private _text = _display displayCtrl 3301;
    private _gangMembersList = _display displayCtrl 3306;
    _text ctrlSetStructuredText parseText format["<img size='1.7' image='icons\bank.paa'/> $%1<br/><img size='1.6' image='icons\money.paa'/> $%2", [life_gang_funds] call life_fnc_numberText, [life_cash] call life_fnc_numberText];
    if ((life_gang_funds >= 1) && ((life_gang_data select 2) <= 2)) then {ctrlEnable[3302, true];
        ctrlEnable[3307, true];};
    lbClear _gangMembersList; {_x params["_xGangName", "_xGangUID"];
        _gangMembersList lbAdd format["%1 (%2)", _xGangName, _xGangUID];
        _gangMembersList lbSetData[(lbSize _gangMembersList) - 1, str[_xGangName, _xGangUID]];}
    forEach life_gangMembersList;
    ctrlEnable[3303, true];
    ctrlEnable[3304, true];};