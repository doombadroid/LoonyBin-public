private _index = randomized_life_group_list findIf {life_my_gang in _x};
if (_index isEqualTo - 1) exitWith {life_my_gang = objNull;};
(randomized_life_group_list select _index) params["_name", "_group", "_locked", "_ownerID", "_password"];
openMap false;
life_lastGroup = group player;
if (_ownerID isEqualTo(getPlayerUID player)) then {private _units = units group player;
    private _newOwner = _units param[_units findIf {!(_x isEqualTo player)}, objNull];
    if !(isNull _newOwner) then {randomized_life_group_list set[_index, [_name, _group, _locked, getPlayerUID _newOwner, _password]];
        publicVariable "randomized_life_group_list"; [[_newOwner, _group], "life_fnc_clientGroupLeader", _newOwner] spawn life_fnc_MP;
    } else {randomized_life_group_list deleteAt _index;
        publicVariable "randomized_life_group_list";};};
life_my_gang = objNull;
if (rank player != "PRIVATE") then {player setRank "PRIVATE";};
[player] joinSilent(createGroup civilian);
if (isNil {(group player) getVariable "gang_id"} && !(life_gang_data isEqualTo[])) then {life_action_in_use = true;
    [] spawn life_fnc_initGang;
    ["You have left your group. Rejoining your gangs default group.", "basic"] spawn life_fnc_handleMessage;} else {
    ["You have left your group.", "basic"] spawn life_fnc_handleMessage;};
[] spawn life_fnc_groupMenu;