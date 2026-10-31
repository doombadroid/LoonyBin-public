params["_isLoad", "_index"];
disableSerialization;
waitUntil {!isNull findDisplay 88888};
private _display = findDisplay 88888;
private _cMessageList = _display displayCtrl 88882;
private _cMessageShow = _display displayCtrl 88887;
private _cMessageHeader = _display displayCtrl 88890;
(_display displayCtrl 88886) ctrlSetText "From:                 								Message:";
if (_isLoad) exitWith {{private _msg = _x select 1;
        _cMessageList lnbAddRow[_x select 0, format["%1 ...", _msg]];
        _cMessageList lnbSetData[[((lnbSize _cMessageList) select 0) - 1, 0], str _x];}
    forEach life_messages;};
private _data = parseSimpleArray(_cMessageList lnbData[_index, 0]);
private _status = "[OFFLINE]";
if !(allPlayers findIf {name _x isEqualTo(_data select 0)}
isEqualTo - 1) then {_status = "[ONLINE]"};
private _messageTime = _data select 2;
private _timeText = "";
if (!isNil "_messageTime") then {private _convert = (time - (_data select 2)) / 60 / 60;
    private _hours = floor _convert;
    private _minutes = round((_convert - _hours) * 60);
    _timeText =
    if (_hours > 0) then {format["%1 hour(s) ago", _hours]} else {format["%1 minutes(s) ago", _minutes]};};
_cMessageHeader ctrlSetStructuredText parseText format["%1 %2 wrote: <t align='right'>%3</t>", _data select 0, _status, _timeText];
_cMessageShow ctrlSetStructuredText parseText format["<t size='0.85' valign='top' align='left'>%1</t>", _data select 1];