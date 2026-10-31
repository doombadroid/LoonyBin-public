disableSerialization;
private _data = lbData[2621, lbCurSel 2621];
_data = missionNamespace getVariable _data;
if (_data isEqualTo player) exitWith {["You can't kick yourself", "basic"] spawn life_fnc_handleMessage};
private _index = randomized_life_group_list findIf {life_my_gang in _x};
if (_index isEqualTo - 1) exitWith {};
(randomized_life_group_list select _index) params["_name", "_group", "_locked", "_ownerID", "_password"];
if ((getPlayerUID _data) isEqualTo _ownerID) then {
    randomized_life_group_list set[_index, [_name, _group, _locked, getPlayerUID player, _password]];
    publicVariable "randomized_life_group_list";}; [[_data, _group], "life_fnc_clientGroupKick", _data] spawn life_fnc_MP;
[] spawn life_fnc_groupManagement;