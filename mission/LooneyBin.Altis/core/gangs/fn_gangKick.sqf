#include "..\..\macro.h"
disableSerialization;
if ((lbCurSel 9621) isEqualTo - 1) exitWith {["You need to select a person to kick!", "basic"] spawn life_fnc_handleMessage};
private _unit = parseSimpleArray(lbData[9621, lbCurSel 9621]);
if ((_unit select 0) isEqualTo getPlayerUID player) exitWith {
    ["You cannot kick yourself from the gang... Sorry. Try using the leave button instead!", "basic"] spawn life_fnc_handleMessage;};
if ((_unit select 2) <= (life_gang_data select 2)) exitWith {["Insufficient permissions.", "shortwarning"] spawn life_fnc_handleMessage;};
if ((life_gang_data select 2) isEqualTo 3 && (_unit select 2) != 5) exitWith {
    ["Insufficient permissions.", "shortwarning"] spawn life_fnc_handleMessage;};
if ((_unit select 0) isEqualTo "") exitWith {};
private _member = playableUnits param[playableUnits findIf {getPlayerUID _x isEqualTo(_unit select 0)}, objNull];
if (isNull _member) then {[
        [player, 1, life_gang_data select 0, life_gang_data select 1, _unit select 0, -1], "TON_fnc_updateGangMem", 2] spawn life_fnc_MP;
} else {[[player, 2, life_gang_data select 0, life_gang_data select 1, _member, -1], "TON_fnc_updateGangMem", 2] spawn life_fnc_MP;};
["Kicking player from gang and updating the database...", "basic"] spawn life_fnc_handleMessage;
[] spawn life_fnc_gangMenu;