if ((lbCurSel 9621) isEqualTo - 1) exitWith {["You must select a player first.", "basic"] spawn life_fnc_handleMessage;};
private _selectedData = parseSimpleArray(lbData[9621, lbCurSel 9621]);
if (_selectedData isEqualTo[]) exitWith {};
if !(life_gang_data param[2, -1] isEqualTo 1) exitWith {};
_selectedData params["_newOwnerPID", "_newOwnerName"];
private _action = [format["Are you sure you want to tranfer gang ownership to %1? Any current gang house will not transfer to the new gang owner.", _newOwnerName], "Tranfer Gang Ownership?", "Yes", "No"] call BIS_fnc_guiMessage;
closeDialog 0;
if !(_action) exitWith {};
private _onlineMembers = [life_gang_data select 0] call life_fnc_getOnlineMembers;
private _newOwner = allPlayers param[allPlayers findIf {_newOwnerPID isEqualTo(getPlayerUID _x)}, objNull]; [
    [getPlayerUID player, _newOwnerPID], "TON_fnc_transferGangOwnerSRV", 2] spawn life_fnc_MP;
if !(isNull(life_gangBuilding select 0)) then {[
        [life_gangBuilding select 0, life_gang_data select 0], "life_fnc_removeGangHouse", _onlineMembers] spawn life_fnc_MP; [
        [life_gangBuilding select 0, life_gang_data select 0], "TON_fnc_removeGangHouseSRV", 2] spawn life_fnc_MP;}; [
    [], "life_fnc_gangSetOwner", _newOwner] spawn life_fnc_MP;
life_gang_data set[2, 2];
[format["You have transferred gang ownership to %1.", _newOwnerName], "basic"] spawn life_fnc_handleMessage;