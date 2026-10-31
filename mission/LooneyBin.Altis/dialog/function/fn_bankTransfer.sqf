#include "..\..\macro.h"
// ASSET FREEZE (owner 2026-07-21): frozen suspects can't move money out either.
if ((player getVariable ["plb_assetFrozen", 0]) > serverTime) exitWith {
    ["<t color='#4aa3ff'>ACCOUNTS FROZEN</t> -- an officer has locked your transfers.", "basic"] spawn life_fnc_handleMessage;
    ctrlEnable[2705, true];};
if (scriptAvailable(4)) exitWith {["Please wait a few seconds before trying to send money again!", "basic"] spawn life_fnc_handleMessage;
    uiSleep 4;
    ctrlEnable[2705, true];};
if ((lbCurSel 2703) isEqualTo - 1) exitWith {
    ["You need to select someone to transfer the money to.", "basic"] spawn life_fnc_handleMessage;
    ctrlEnable[2705, true];};
private _unit = allPlayers param[allPlayers findIf {(lbData[2703, lbCurSel 2703]) isEqualTo(_x getVariable["plb_steamid", getPlayerUID _x])
}, objNull];
if (isNull _unit) exitWith {ctrlEnable[2705, true];};
if (isNil "_unit") exitWith {["The player selected doesn't seem to exist?", "basic"] spawn life_fnc_handleMessage;
    ctrlEnable[2705, true];};
if ((_unit distance(getMarkerPos "Respawn_west") < 1000) || !(alive _unit)) exitWith {
    ["This player is dead. Try again soon.", "basic"] spawn life_fnc_handleMessage;};
private _val = parseNumber(ctrlText 2702);
if !([str _val] call life_fnc_isNumber) exitWith {["Invalid number.", "basic"] spawn life_fnc_handleMessage;};
if (_val > 9999999) exitWith {["You can't transfer more than $9,999,999 at a time.", "basic"] spawn life_fnc_handleMessage;
    ctrlEnable[2705, true];};
if (_val < 100) exitWith {["You cannot transfer less than $100."] spawn life_fnc_handleMessage;
    ctrlEnable[2705, true];};
if (_val > life_atmcash) exitWith {
    [format["You do not have enough money in your bank account, to transfer $%1.", _val], "basic"] spawn life_fnc_handleMessage;
    ctrlEnable[2705, true];};
private _action = [format["Are you sure you want to send $%1 to the player %2?", [_val] call life_fnc_numberText, name _unit], "Approve Funds Transfer", "Send Money", "Cancel"] call BIS_fnc_guiMessage;
if ((player distance(getMarkerPos "Respawn_west") < 1000) || !(alive player)) exitWith {
    ["You cannot conduct wiretransfers while dead. Please try again.", "basic"] spawn life_fnc_handleMessage;};
if (_action) then {private _preBalance = life_atmcash;
    life_atmcash = (round(life_atmcash - _val)) max 0;
    life_atmcashCacheB = ((life_atmcash / 4) + 11);
    [1] call life_fnc_ClupdatePartial;
    private _nearATMs = ((nearestObjects[player, [], 10]) + (nearestTerrainObjects[player, [], 10])) select {private _object = _x;
        private _alwaysATM = ((typeOf _object) in ["Land_Atm_01_F", "Land_Atm_02_F", "Land_ATM_01_malden_F", "Land_ATM_02_malden_F", "Land_Laptop_Intel_01_F"]) || (((str _object) find "atm_0") >= 0);
        private _hasAction = ((((actionIDs _object) findIf {"life_fnc_atmMenu" in ((_object actionParams _x) select 1);
        }) >= 0) && !(_object in allPlayers));
        _hasAction =
        if (!isNil "_hasAction") then {_hasAction} else {false};
        (_hasAction || _alwaysATM);}; [
        [_val, player, _unit, _preBalance, _nearATMs], "TON_fnc_handleWireTransfer", 2, false, false] spawn life_fnc_MP;
    [] call life_fnc_atmMenu; [
        ["-BANKTRANSFER-", player, profileName, format["wiretransfered $%1 to %2 (%3).", [_val] call life_fnc_numberText, name _unit, getPlayerUID _unit]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
    if (playerSide isEqualTo civilian && {A_stats_civTime < 1440 && _val >= 74999}) then {[
            ["-MONEYWARNING-", player, profileName, format["wiretransferred $%1 to %2 (%3). Civ time: %4 minutes | Bank: $%5 | Cash: $%6 | Position: %7 | Experience: %8.", [_val] call life_fnc_numberText, _unit getVariable["plb_name", name _unit], getPlayerUID _unit, A_stats_civTime, [life_atmCash] call life_fnc_numberText, [life_cash] call life_fnc_numberText, getPosATL player, [life_side_exp] call life_fnc_numberText]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
    };
    [format["You have transfered $%1 to %2.", [_val] call life_fnc_numberText, _unit getVariable["plb_name", name _unit]], "basic"] spawn life_fnc_handleMessage;
} else {["You have decided to cancel the funds transfer at this time...", "basic"] spawn life_fnc_handleMessage;};
ctrlEnable[2705, true];