if ((life_gang_data select 2) > 3) exitWith {
    ["You are not of proper rank to invite people to the gang!", "basic"] spawn life_fnc_handleMessage;};
if (isNull(findDisplay 9550)) exitWith {};
disableSerialization;
private _playerToInvite = lbData[9555, lbCurSel 9555];
_playerToInvite = missionNamespace getVariable _playerToInvite;
if (isNil "_playerToInvite" || {isNull _playerToInvite}) exitWith {
    ["Could not find player to send invitation to. They may have disconnected.", "basic"] spawn life_fnc_handleMessage;
    closeDialog 0;};
if !((_playerToInvite getVariable["gang_data", []]) isEqualTo[]) exitWith {
    ["The player you selected is already in a gang!", "basic"] spawn life_fnc_handleMessage;
    closeDialog 0;};
[format["Sending gang invite to %1...", name _playerToInvite], "basic"] spawn life_fnc_handleMessage;
closeDialog 0; [
    [player, profileName, life_gang_data, [life_gang_talents, life_gang_exp], life_gangBuilding], "life_fnc_gangInvite", _playerToInvite] spawn life_fnc_MP;