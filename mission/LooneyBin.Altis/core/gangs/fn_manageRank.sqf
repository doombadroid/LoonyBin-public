#include "..\..\macro.h"
params[["_mode", 0, [0]]];
disableSerialization;
private _gangID = life_gang_data select 0;
private _gangName = life_gang_data select 1;
if ((lbCurSel 9621) isEqualTo - 1) exitWith {["You must select a player first.", "basic"] spawn life_fnc_handleMessage;};
private _unit = parseSimpleArray(getSelData(9621));
if ((_unit select 0) isEqualTo(getPlayerUID player)) exitWith {["You cannot modify your own rank.", "basic"] spawn life_fnc_handleMessage;
};
if ((_unit select 0) isEqualTo "") exitWith {};
private _onlineMembers = [_gangID] call life_fnc_getOnlineMembers;
private _member = _onlineMembers param[_onlineMembers findIf {getPlayerUID _x isEqualTo(_unit select 0)}, objNull];
switch (_mode) do {case 1: {if (((_unit select 2) - 1) <= (life_gang_data select 2)) exitWith {
                ["Insufficient permissions.", "basic"] spawn life_fnc_handleMessage;};
            if (isNull _member) then {[
                    [player, 1, _gangID, _gangName, (_unit select 0), ((_unit select 2) - 1)], "TON_fnc_updateGangMem", false] spawn life_fnc_MP;
            } else {[[player, 2, _gangID, _gangName, _member, ((_unit select 2) - 1)], "TON_fnc_updateGangMem", false] spawn life_fnc_MP;};
            ["Promoting member and updating rank in database...", "basic"] spawn life_fnc_handleMessage;
            [] spawn life_fnc_gangMenu;};
    case 2: {if ((((_unit select 2)) <= (life_gang_data select 2)) || ((_unit select 2) + 1) < 0) exitWith {
                ["Insufficient permissions.", "basic"] spawn life_fnc_handleMessage;};
            if (isNull _member) then {[
                    [player, 1, _gangID, _gangName, (_unit select 0), ((_unit select 2) + 1)], "TON_fnc_updateGangMem", false] spawn life_fnc_MP;
            } else {[[player, 2, _gangID, _gangName, _member, ((_unit select 2) + 1)], "TON_fnc_updateGangMem", false] spawn life_fnc_MP;};
            ["Demoting member and updating rank in database...", "basic"] spawn life_fnc_handleMessage;
            [] spawn life_fnc_gangMenu;};};