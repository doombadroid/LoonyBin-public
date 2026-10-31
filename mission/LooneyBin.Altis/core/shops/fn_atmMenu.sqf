#include "..\..\macro.h"
params[["_target", objNull, [objNull]], ["_caller", objNull, [objNull]], ["_actionId", -1, [-1]], ["_arguments", "", [""]], ["_bankMode", 0, [0]]];
if !(life_use_atm) exitWith {["Because you robbed a store you can't use the ATM for 5 minutes.", "basic"] spawn life_fnc_handleMessage;};
// ASSET FREEZE (owner 2026-07-21): a wanted suspect an officer froze (TAL Asset Freeze -> plb_assetFrozen, a
// server-set + published expiry) can't touch an ATM until it lifts. Consistent with the existing client-money
// trust model -- the freeze var is server-authoritative, the enforcement point is the client like every other
// money op. Server-side ATM Jackpot honours the same freeze independently.
if ((player getVariable ["plb_assetFrozen", 0]) > serverTime) exitWith {
    [format ["<t color='#4aa3ff'>ACCOUNTS FROZEN</t> -- an officer locked your assets. %1s left.", ceil ((player getVariable ["plb_assetFrozen", 0]) - serverTime)], "basic"] spawn life_fnc_handleMessage;
};
if !(dialog) then {["atmV2Menu"] call life_fnc_createDialog;};
if (player getVariable["plb_restrained", false]) exitWith {};
if (player getVariable["plb_surrendered", false]) exitWith {};
// ATM SKIMMER: remember which physical ATM this session is on, so withdraw/deposit can read its skimmer owner.
// The open action already gates cursorObject to an ATM within 3m, so it IS the machine here.
if (!isNull cursorObject && {((typeOf cursorObject) in ["Land_Atm_01_F","Land_Atm_02_F","Land_Mattaust_ATM","Land_atm"]) || {[str cursorObject, "atm_0"] call KRON_StrInStr}}) then {
    life_skimATM = cursorObject;};
disableSerialization;
private _display = findDisplay 2700;
private _text = _display displayCtrl 2701;
private _units = _display displayCtrl 2703;
private _withButton = _display displayCtrl 2706;
private _depButton = _display displayCtrl 2707;
private _depAllButton = _display displayCtrl 2708;
if (life_inv_debitcard > 0) then {ctrlEnable[2710, false];};
if !(life_gfunds_active) then {_withButton ctrlEnable true;
    _depButton ctrlEnable true;
    _depAllButton ctrlEnable true;} else {
    ["You currently are performing another banking action, please reopen the menu when done.", "basic"] spawn life_fnc_handleMessage;};
_text ctrlSetStructuredText parseText format["<img size='1.7' image='icons\bank.paa'/> $%1<br/><img size='1.6' image='icons\money.paa'/> $%2", [life_atmcash] call life_fnc_numberText, [life_cash] call life_fnc_numberText];
lbClear _units; {if ((alive _x) && !(_x distance2D(getMarkerPos "respawn_west") <= 1000)) then {private _type =
        switch (side _x) do {case civilian: {"Civ"};
            case west: {"Cop"};
            case independent: {
                    "EMS"};}; private _playerData = [_x getVariable["plb_name", name _x], _x getVariable["plb_playerid", getPlayerUID _x]];
        private _idx = _units lbAdd format["%1 (%2)", _playerData param[0, "Error Name"], _type];
        _units lbSetData[_idx, _playerData param[1, "Error UID"]];};}
forEach((playableUnits - [player]) select { (typeOf _x) isNotEqualTo "HeadlessClient_F" });   // never list the headless client as a transfer target
lbSort _units;
lbSetCurSel[2703, 0];
if (((A_stats_crimes param[0, 0]) > 1000) && ((time - life_last_wanted) > 240)) then {life_last_wanted = time;
    private _toSend = allPlayers - [allDeadMen] select {((side _x isEqualTo civilian && !(((_x getVariable["plb_myBounties", []]) findIf {
            getPlayerUID player in _x}) isEqualTo - 1)) || side _x isEqualTo west)};
    if !(_toSend isEqualTo[]) then {[
            [9, profileName, str(A_stats_crimes select 0), player], "life_fnc_clientMessage", _toSend] spawn life_fnc_MP;};};