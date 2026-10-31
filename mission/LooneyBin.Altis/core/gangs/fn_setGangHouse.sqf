params[["_building", objNull, [objNull]]];
life_gang_data params[["_myGangID", -1, [0]], ["_myGangName", "", [""]], ["_myGangRank", -1, [0]]];
if !(_myGangRank isEqualTo 1) exitWith {
    ["You are not the gang leader and can not perform this action!", "basic"] spawn life_fnc_handleMessage;};
if !((_building getVariable["plb_homeOwner", ""]) isEqualTo(getPlayerUID player)) exitWith {
    ["You are not the owner of this building and can not set it to be a gang house!", "basic"] spawn life_fnc_handleMessage;};
if !((life_gang_data select 3) isEqualTo[0, 0, 0]) exitWith {["You already have a gang house!", "basic"] spawn life_fnc_handleMessage;};
if !((life_gangBuilding select 1) isEqualTo[]) exitWith {["You already have a gang house!", "basic"] spawn life_fnc_handleMessage;};
if ((_building getVariable["plb_houseID", -1]) isEqualTo - 1) exitWith {};
life_action_in_use = true;
private _action = ["Are you sure you want to make this your gang building? Gang members will be able to spawn here and access certain building functions if you set this as your gang building.", "Convert to Gang Building?", "Convert", "Cancel"] call BIS_fnc_guiMessage;
life_action_in_use = false;
if !(_action) exitWith {
    ["You have chosen not to make this building a gang building at this time...", "basic"] spawn life_fnc_handleMessage;};
["Establishing this house to a gang building...", "basic"] spawn life_fnc_handleMessage;
life_gangBuilding = [_building, getPosATL _building];
life_gang_data set[3, getPosATL _building];
// owner 2026-06-17 (#324): mark the gang HQ green for the LEADER too. setGangHouseForMembers (below) only
// runs for the OTHER online members (- [player]); nothing marked the leader, so the leader saw only their
// blue owned-house marker ("normal house"). Same marker name the relog path (fn_initGang) uses so a later
// relog replaces it cleanly.
deleteMarkerLocal life_gangBldgMark;
deleteMarkerLocal (format ["phouse_gang_%1", _myGangID]);
life_gangBldgMark = createMarkerLocal [format ["phouse_gang_%1", _myGangID], getPosATL _building];
life_gangBldgMark setMarkerTextLocal "Gang Building";
life_gangBldgMark setMarkerColorLocal "ColorGreen";
life_gangBldgMark setMarkerTypeLocal "mil_end"; [[player, _building, _myGangID], "TON_fnc_addGangHouse", 2] call life_fnc_MP;
private _onlineMembers = ([_myGangID] call life_fnc_getOnlineMembers) - [player]; [
    [_building, _myGangID], "life_fnc_setGangHouseForMembers", _onlineMembers] spawn life_fnc_MP;