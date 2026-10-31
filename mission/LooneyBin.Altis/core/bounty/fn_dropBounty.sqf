disableSerialization;
private _dropBountySeconds =
if (470 in life_completedLifetimeQuests) then {240} else {300};
if (serverTime < (profileNamespace getVariable["plb_lastbh_dropped", [0, 0]] select 1)) exitWith {
    [format["You can only drop a bounty every %2 minutes! %1 minutes remaining.", ceil(((profileNamespace getVariable["plb_lastbh_dropped", [0, 0, ""]] select 1) - serverTime) / 60), (_dropBountySeconds / 60)], "basic"] spawn life_fnc_handleMessage;
};
private _display = findDisplay 2400;
if (isNull _display) exitWith {};
private _wantedList = _display displayCtrl 2402;
if (lbCurSel _wantedList isEqualTo - 1) exitWith {};
private _data = parseSimpleArray(_wantedList lbData(lbCurSel _wantedList));
_data params["_name", "_unitUID", "_charges", "_bounty"];
private _bountyArrayIndex = life_bounty_list findIf {_unitUID in _x};
if (_bountyArrayIndex isEqualTo - 1) exitWith {};
profileNameSpace setVariable["plb_lastbh_dropped", [PLB_instance_id, serverTime + _dropBountySeconds]];
life_dropped_bounties pushBackUnique _unitUID;
_unitUID spawn {uiSleep(60 * 45);
    private _index = life_dropped_bounties findIf {_x isEqualTo _this};
    life_dropped_bounties deleteAt _index;};
private _uidIdx = life_bounty_uid findIf {_unitUID isEqualTo _x};
life_bounty_uid deleteAt _uidIdx;
[_unitUID, true] call life_fnc_removeBounty;
["action", "dropbounty", 1] spawn life_fnc_handleQuest;