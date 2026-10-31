// life_fnc_gangMembersReceive (LooneyBin): server pushes THIS gang's member rows here so the
// gang menu / gang-ATM menu's `waitUntil life_gangMembersList_ready` completes.
// _this = [[playerid, name, gangrank], ...] from DB_fnc_queryGangMembers.
private _members = _this;
if (isNil "_members" || {!(_members isEqualType [])}) then { _members = []; };
life_gangMembersList = _members;
life_gangMembersList_ready = true;
