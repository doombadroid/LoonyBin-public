#include "..\..\macro.h"
if (scriptAvailable(120)) exitWith {["You cannot rapidly set passwords!", "basic"] spawn life_fnc_handleMessage;};
disableSerialization;
private _groupPassword = ctrlText 2551;
private _allowed = toArray("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_ ");
private _length = count(toArray _groupPassword);
private _chrByte = toArray _groupPassword;
if (_length > 16) exitWith {["The maximum character limit for a password is 16.", "basic"] spawn life_fnc_handleMessage;};
if (_groupPassword isEqualTo "") exitWith {["You did not enter a password to use!", "basic"] spawn life_fnc_handleMessage;};
private _badChar = false; {if !(_x in _allowed) exitWith {_badChar = true;};}
forEach _chrByte;
if (_badChar) exitWith {["Invalid character in password, characters allowed are A-z,0-9, and _", "basic"] spawn life_fnc_handleMessage;};
private _index = [life_my_gang, randomized_life_group_list] call life_fnc_index;
if (_index isEqualTo - 1) exitWith {};
if !(player isEqualTo(leader(group player))) exitWith {["You don't have the ability to do that.", "basic"] spawn life_fnc_handleMessage;};
(randomized_life_group_list select _index) params["_name", "_group", "_locked", "_ownerID", "_password"];
if (_password == _groupPassword) exitWith {["This is already the current group password!", "basic"] spawn life_fnc_handleMessage;};
randomized_life_group_list set[_index, [_name, _group, true, _ownerID, _groupPassword]];
publicVariable "randomized_life_group_list";
[format["You have set the group password to: %1", _groupPassword], "basic"] spawn life_fnc_handleMessage;
closeDialog 0;
[] spawn life_fnc_groupMenu;