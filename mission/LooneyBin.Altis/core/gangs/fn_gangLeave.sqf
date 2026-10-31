private _action = ["Are you sure you want to leave your gang?", "Leave Gang", "Leave", "Cancel"] call BIS_fnc_guiMessage;
if !(_action) exitWith {};
if ((life_gang_data select 2) isEqualTo 1) exitWith {
    ["You cannot leave the gang as acting leader! Please appoint a new leader or disband the gang instead.", "basic"] spawn life_fnc_handleMessage;
};
if !(isNil {(group player) getVariable "gang_id"}) then {[player] joinSilent(createGroup civilian);}; [
    [player, 2, life_gang_data select 0, life_gang_data select 1, player, -1], "TON_fnc_updateGangMem", 2] call life_fnc_MP;
deleteMarkerLocal life_gangBldgMark;
life_gang_data = [];
life_gangBuilding = [objNull, []];
life_gangBldgMark = "";
player setVariable["gang_data", nil, true];
["Leaving gang...", "basic"] spawn life_fnc_handleMessage;
closeDialog 0;