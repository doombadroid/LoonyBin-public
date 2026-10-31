#include "..\..\macro.h"
private _groupName = ctrlText 2531;
private _length = count(toArray _groupName);
if (life_passiveModeJIP) exitWith {
    ["You cannot create a group while in passive mode! You can disable it on your phone (Y).", "basic"] spawn life_fnc_handleMessage;};
// LooneyBin: parity with lock/unlock/setPass -- no cooldown meant a group-entry flood was one
// macro'd click away (every create publicVariables the whole list to everyone)
if (scriptAvailable(30)) exitWith {["Please wait a bit before creating another group!", "basic"] spawn life_fnc_handleMessage;};
if (_groupName isEqualTo "") exitWith {["You must choose a name.", "basic"] spawn life_fnc_handleMessage;};
if (_length < 3) exitWith {["The minimum character limit for a group name is 3.", "basic"] spawn life_fnc_handleMessage;};
if (_length > 25) exitWith {["The maximum character limit for a group name is 25.", "basic"] spawn life_fnc_handleMessage;};
if !([_groupName] call life_fnc_isAlphanumeric) exitWith {
    ["Invalid character in name, characters allowed are A-z,0-9, and _", "basic"] spawn life_fnc_handleMessage;};
private _groupPassword = ctrlText 2532;
if (_groupPassword isEqualTo "") exitWith {["You must choose a password for the group.", "basic"] spawn life_fnc_handleMessage};
// LooneyBin: this check reused _length (the group NAME length) -- any 17-25 char group name was
// rejected with a bogus "password is too long" error. Measure the password itself.
if ((count (toArray _groupPassword)) > 16) exitWith {
    ["The maximum character limit for a password is 16.", "basic"] spawn life_fnc_handleMessage;};
if !([_groupPassword] call life_fnc_isAlphanumeric) exitWith {
    ["Invalid character in password, characters allowed are A-z,0-9, and _", "basic"] spawn life_fnc_handleMessage;};
if (isNil {randomized_life_group_list}) exitWith {
    ["Server failed to initiate groups and gangs list.", "basic"] spawn life_fnc_handleMessage;};
if !(randomized_life_group_list findIf {_groupName in _x}
isEqualTo - 1) exitWith {["That group name is already taken!", "basic"] spawn life_fnc_handleMessage;};
private _group = createGroup civilian;
private _left = _groupName select[0, 1];
private _mid = _groupName select[floor((count _groupName) / 2), 1];
private _right = _groupName select[((count _groupName) - 1), 1];
private _grpTag = format["%1%2%3", _left, _mid, _right];
private _countGroupTags = {(((_x select 1) getVariable["plb_grpTag", ""]) find _grpTag) >= 0}
count randomized_life_group_list;
private _grpTag =
if (_countGroupTags >= 1) then {format["[%1 (%2)] ", _grpTag, (_countGroupTags + 1)]} else {format["[%1] ", _grpTag]};
_group setVariable["plb_grpTag", _grpTag, true];
_group setGroupIdGlobal [_groupName];   // owner 2026-06-25 (Northhhhh): clean callsign (squad name) so side-chat shows the squad name, not the engine's auto group ID 
// goodchance this runs into issues down the road also doesnt address gang groups will just setup side chat correctly
randomized_life_group_list pushBack[_groupName, _group, true, getPlayerUID player, _groupPassword];
publicVariable "randomized_life_group_list";
[player] joinSilent _group;
player setRank "COLONEL";
life_my_gang = _group;
if !(isNull life_my_gang) then {["groupMenuMain"] spawn life_fnc_createDialog;
    publicVariable "randomized_life_group_list";};