#include "..\..\macro.h"
if (player getVariable["plb_restrained", false] && (call life_adminLevel) <= 1) exitWith {
    ["You cannot open your cell phone when you're restrained!", "basic"] spawn life_fnc_handleMessage;};
disableSerialization;
private _newLoad =
if (isNull(findDisplay 3000)) then {createDialog "life_cell_phone";
    waitUntil {!isNull(findDisplay 3000)};
    [findDisplay 3000] spawn life_fnc_p_updateMenu;
    true} else {false};
private _display = findDisplay 3000;
private _messageInput = _display displayCtrl 3001;
private _playerList = _display displayCtrl 3002;
private _basicText = _display displayCtrl 3003;
private _policeText = _display displayCtrl 3004;
private _medicText = _display displayCtrl 3005;
private _textAdmins = _display displayCtrl 3006;
private _taxiRequest = _display displayCtrl 3009;
private _allText = _display displayCtrl 3008;
private _adminText = _display displayCtrl 3007;
private _messageHistory = _display displayCtrl 3010;
_allText ctrlSetText "MSG ALL";
_adminText ctrlSetText "ADM SEND";
lbClear _playerList;
_messageInput ctrlSetText "";
if ((call life_adminLevel) >= 2) then {if (_newLoad) then {
        _allText ctrlAddEventHandler["ButtonClick", "[_this select 0, 5] call life_fnc_sendText"];
        _adminText ctrlAddEventHandler["ButtonClick", "[_this select 0, 6] call life_fnc_sendText"];};} else {{_x ctrlEnable false;
        _x ctrlShow false;}
    forEach[_adminText, _allText];
    if ((getPlayerUID player) isEqualTo(SRV_governorData param[0, "GovUID"])) then {_allText ctrlShow true;
        _allText ctrlSetText "GOV ALL";
        _allText ctrlEnable true;
        if (_newLoad) then {_allText ctrlAddEventHandler["ButtonClick", "[_this select 0, 7] call life_fnc_sendText"]};};
    if ((call life_eventCoordinatorLevel) > 0) then {_allText ctrlSetText "EVENT ALL";
        _allText ctrlAddEventHandler["ButtonClick", "[_this select 0, 8] call life_fnc_sendText"];
        _allText ctrlEnable true;
        _allText ctrlShow true;};};
if (_newLoad) then {{(_x select 0) ctrlAddEventHandler["ButtonClick", format["[_this select 0, %1] call life_fnc_sendText", _x select 1]]}
    forEach[[_basicText, 0], [_policeText, 1], [_medicText, 2], [_textAdmins, 3]];};
// exclude the headless client (HC1 is a playable HeadlessClient_F -> it lands in allPlayers; don't let anyone text/list it)
private _allPlayers = (allPlayers - [player]) select { (typeOf _x) isNotEqualTo "HeadlessClient_F" }; {_x params[["_unit", objNull]];
    if (!isNull _unit && alive _unit) then {private _index = _playerList lbAdd format["%1", name _x];
        _playerList lbSetData[_index, getPlayerUID _x];};}
forEach _allPlayers;
lbSort _playerList;
// owner 2026-07-15: pin the Ben Bones Official "contact" -- texting it routes to the AI daemon, not a player.
private _bb = _playerList lbAdd "Ben Bones Official";
_playerList lbSetData [_bb, "BENBONES"];
_playerList lbSetColor [_bb, [0.91, 0.70, 0.23, 1]];
if ((lbSize _playerList) >= 1) then {_playerList lbSetCurSel 0} else {_messageInput ctrlSetText "Nobody alive to text"; {
        _x ctrlEnable false}
    forEach[_messageInput, _playerList, _basicText, _policeText, _medicText, _textAdmins, _taxiRequest, _allText, _adminText];}; {
    _x ctrlShow false;}
forEach[_taxiRequest];
// ---- MESSAGE THREADS UI (owner 2026-07-20): threads list left, conversation view right. Selecting a
// thread SYNCS the recipient combo (3002) to that contact, so SEND (mode 0) replies into the thread.
if (_newLoad) then {(_display displayCtrl 3020) ctrlAddEventHandler ["LBSelChanged", {params ["_lb", "_sel"];
        private _who = _lb lbData _sel;
        private _combo = (findDisplay 3000) displayCtrl 3002;
        for "_i" from 0 to ((lbSize _combo) - 1) do {if ((_combo lbText _i) isEqualTo _who) exitWith { _combo lbSetCurSel _i; };};
        call PLB_fnc_msgRender;}];};
call PLB_fnc_msgFill;
