#include "..\..\macro.h"
if (player getVariable["plb_restrained", false] && (call life_adminLevel) <= 1) exitWith {
    ["You cannot open your cell phone when you're restrained!", "basic"] spawn life_fnc_handleMessage;};
// Silence Cell quickhack: outgoing comms jammed -- calls too, not just texts
if (diag_tickTime < (missionNamespace getVariable ["plb_qhSilencedUntil", 0])) exitWith {
    [format ["<t color='#ff3b1e'>SIGNAL JAMMED</t> -- your comms are muted for another %1s.",
        ceil ((missionNamespace getVariable ["plb_qhSilencedUntil", 0]) - diag_tickTime)], "basic"] spawn life_fnc_handleMessage;};
disableSerialization;
private _newLoad =
if (isNull(findDisplay 9500)) then {createDialog "Life_phone_app";
    waitUntil {!isNull(findDisplay 9500)};
    [findDisplay 9500] spawn life_fnc_p_updateMenu;
    true} else {false};
private _display = findDisplay 9500;
private _playerList = _display displayCtrl 9501;
private _callText = _display displayCtrl 9502;
private _hangupText = _display displayCtrl 9503;
private _titleText = _display displayCtrl 9504;
lbClear _playerList;
private _phoneStatus =
switch (life_phoneCallStatus) do {case (0): {"Idle"};
    case (1): {"Ringing"};
    case (2): {"Active Call"};
    case (3): {"Call Declined"};
    default {""}}; _titleText ctrlSetStructuredText parseText(format["<t size='0.90' align='center'>Phone Status: %1</t>", _phoneStatus]);
if (_newLoad) then {{if (_forEachIndex isEqualTo 0) then {
            _x ctrlAddEventHandler["ButtonClick", format["['startPhoneCall', [_this select 0]] spawn life_fnc_phoneCallClient", _forEachIndex]];
        } else {
            _x ctrlAddEventHandler["ButtonClick", format["['endPhoneCall', [_this select 0]] spawn life_fnc_phoneCallClient", _forEachIndex]];
        };}
    forEach[_callText, _hangupText];};
if !(isNull(life_remoteExplosive param[0, objNull])) then {private _index = _playerList lbAdd format["@Remote Bomb Detonator"];
    _playerList lbSetData[_index, "remotebomb"];};
if !(isNull(life_engineKillSwitch param[0, objNull])) then {
    private _index = _playerList lbAdd format["@Remote Engine Kill Switch Detonator"];
    _playerList lbSetData[_index, "enginekillswitch"];};
// exclude the headless client (HC1) -- it's a playable HeadlessClient_F so it shows up in allPlayers otherwise
private _allPlayers = (allPlayers - [player]) select { (typeOf _x) isNotEqualTo "HeadlessClient_F" }; {_x params[["_unit", objNull]];
    if (!isNull _unit && alive _unit) then {private _index = _playerList lbAdd format["%1", name _x];
        _playerList lbSetData[_index, getPlayerUID _x];};}
forEach _allPlayers;
switch (life_phoneCallStatus) do {case (0): {_callText ctrlEnable true;
            _hangupText ctrlEnable false;};
    case (1): {_callText ctrlEnable false;
            _hangupText ctrlEnable false;};
    case (2): {_callText ctrlEnable false;
            _hangupText ctrlEnable true;};
    case (3): {_callText ctrlEnable false;
            _hangupText ctrlEnable false;};}; lbSort _playerList;
if ((lbSize _playerList) >= 1) then {_playerList lbSetCurSel 0} else {
    _titleText ctrlSetStructuredText(parseText "<t size='0.90' align='center'>Nobody is alive to call.</t>"); {_x ctrlEnable false}
    forEach[_playerList, _callText, _hangupText];};