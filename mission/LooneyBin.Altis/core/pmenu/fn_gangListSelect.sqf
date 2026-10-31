/*
    life_fnc_gangListSelect  --  owner 2026-06-13, extended 2026-06-24
    onLBSelChanged for the roster list (dialog\gang_list.hpp). Fills the right-hand box with the selected GANG's or
    GROUP's online members. PLB_rosterData (built in life_fnc_gangListMenu) = [[kind, label, [memberNames]], ...];
    lbData on each row is that row's INDEX, so gangs and groups fill identically.
*/
disableSerialization;
private _display = findDisplay 2450;
if (isNull _display) exitWith {};
private _gangBox = _display displayCtrl 2451;
private _memBox  = _display displayCtrl 2452;
lbClear _memBox;
private _sel = lbCurSel _gangBox;
if (_sel < 0) exitWith {};
private _data = _gangBox lbData _sel;
if (_data isEqualTo "") exitWith {};   // "No gangs/groups" placeholder row has no data
private _i = parseNumber _data;
private _roster = uiNamespace getVariable ["PLB_rosterData", []];
if (_i < 0 || {_i >= count _roster}) exitWith {}; {_memBox lbAdd format ["  %1", _x];} forEach ((_roster select _i) select 2);
