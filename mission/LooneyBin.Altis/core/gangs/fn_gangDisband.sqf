if !((life_gang_data select 2) isEqualTo 1) exitWith {["You are not the leader.", "shortwarning"] spawn life_fnc_handleMessage;};
private _action = ["You are about to disband your gang! It will remove all data from the database and the group will be destroyed. <br/><br/>Are you sure you want to disband the gang?", "Disband Gang", "Disband", "Cancel"] call BIS_fnc_guiMessage;
if (_action) then {private _gangID = life_gang_data select 0; [
        [player, life_gang_data select 1, _gangID], "TON_fnc_removeGang", 2] spawn life_fnc_MP;
    if !(isNull(life_gangBuilding select 0)) then {(life_gangBuilding select 0) setVariable["plb_house_gang", -1, true];};
    closeDialog 0;
    ["Disbanding the gang...", "shortwarning"] spawn life_fnc_handleMessage;} else {
    ["You have chosen to not disband the gang!", "basic"] spawn life_fnc_handleMessage;};