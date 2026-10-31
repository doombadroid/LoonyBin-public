 
private["_civ","_cop","_id","_half","_share","_friends","_amount"]; 
_civ = [_this,0,Objnull,[Objnull]] call BIS_fnc_param;
_cop = [_this,1,Objnull,[Objnull]] call BIS_fnc_param;
_half = [_this,2,false,[false]] call BIS_fnc_param;
_share = [_this,3,false,[false]] call BIS_fnc_param;
// owner 2026-06-23 SECURITY (security.md §2.2): caller = fn_arrestAction (the ARRESTER -- a cop OR a tasked
// bounty-hunter civ -- collecting the bounty on _civ). Ungated, anyone could remoteExec [victim, self] to pay
// themselves a bounty with no arrest. Require the paid arrester (_cop) to BE the real caller (remoteExecutedOwner,
// non-spoofable) so you can only ever pay YOURSELF; server-internal passes.
// NEEDS OWNER REVIEW: this proves WHO is paid but not that a legitimate arrest happened (no server-side restrained/
// distance/task check) -- a scripter can still self-pay for any wanted player. To fully close, validate server-side
// that _civ is restrained by _cop (or is _cop's active bounty task) before paying.
private _src = remoteExecutedOwner;
private _caller = if (_src isEqualTo 0) then { objNull } else { (allPlayers select { owner _x isEqualTo _src }) param [0, objNull] };
if (_src isNotEqualTo 0 && {!(_cop isEqualTo _caller)}) exitWith { ["-SEC-", _caller, format ["BLOCKED wantedBounty by %1 (cop arg %2)", getPlayerUID _caller, getPlayerUID _cop]] call PLB_fnc_logIt; };
if(isNull _civ OR isNull _cop) exitWith {};
 
_id = [(getPlayerUID _civ),life_wanted_list] call life_fnc_index; 
 
if(_id != -1) then {
// owner 2026-06-24 (#517 double-jail exploit -- player089: "send to jail then hit it again" = repeat money + honor):
// SINGLE-FIRE. fn_arrestAction cleared its plb_arrest guard BEFORE this fired and handleJail is async, so a 2nd
// "Send to Jail" re-called this with the SAME _civ and PAID AGAIN. Capture the entry, then CLEAR the offender's
// wanted exactly like TON_fnc_wantedPardon (drop the cop-list entry + zero their client crimes via wantedListAdd
// 999 + wipe the DB row) BEFORE paying. -> a re-call finds _id == -1 (no second pay); the offender's plb_wantedAmt
// goes to 0 so re-clicks bail at fn_arrestAction's "not wanted" guard (no repeat honor); and the arrest finally
// clears the bounty (it used to leave them wanted after jail).
private _entry = life_wanted_list select _id;
private _ouid  = getPlayerUID _civ;
private _sanW  = { (format ["%1", _this]) splitString "\'""" joinString "" };
life_wanted_list deleteAt _id;
// owner 2026-06-24 (JAIL instant-release regression introduced by the #517 fix above): the #517 patch wiped the
// offender's CLIENT A_stats_crimes here (wantedListAdd 999). But the arrest path
// (fn_arrestAction -> TON_fnc_handleJail -> life_fnc_jailMe) derives the SENTENCE LENGTH *and* jailMe's
// release-loop guard ("A_stats_crimes select 0 == 0", index 0 = the wanted $) from that SAME client array --
// and life_fnc_wantedPerson is a stub, so there is NO server-side sentence fallback. wantedBounty and handleJail
// are spawned in PARALLEL by fn_arrestAction, so this wipe RACED jailMe's read -> _jailTime computed as 0 +
// line-128 early-out -> the prisoner was released the instant they reached the cell = "every arrest = instant
// release". So DO NOT wipe the crimes here. jailMe already wipes them on RELEASE (its own wantedListAdd 999).
// #517's money-dupe protection is preserved by the deleteAt + DB DELETE (a re-click finds _id == -1 -> no 2nd
// pay). To still block the repeat-HONOR re-click, just zero the offender's cop-facing wanted amount --
// fn_arrestAction's "not wanted" guard (line 19) reads plb_wantedAmt -- WITHOUT touching the sentence-bearing
// A_stats_crimes.
_civ setVariable ["plb_wantedAmt", 0, true];
[format ["DELETE FROM `%1` WHERE `playerid`='%2'", srv_table_wanted, (_ouid call _sanW)]] call DB_fnc_asyncQuery;
if(_half) then {[[(_entry select 3) / 2,(_entry select 3)],"life_fnc_bountyReceive",_cop,false] spawn life_fnc_MP;}
else {_friends = [units group _cop, {_cop distance _x < 100 && _x != _cop}] call BIS_fnc_conditionalSelect;
_amount = _entry select 3;
if (count life_allpoints > 0) then {if (life_allpoints select 1 == _ouid) then {_amount = _amount * 1.5;
life_allpoints = []; 
publicVariable "life_allpoints";};};
_original = _amount; 
if (_share && count _friends > 0) then {_amount = round (_amount / ((count _friends) + 1)); {
[[_amount,_amount,_cop,_original],"life_fnc_bountyReceive",_x,false] spawn life_fnc_MP;} forEach _friends;};
[[_amount,_amount,_cop,_original],"life_fnc_bountyReceive",_cop,false] spawn life_fnc_MP;};};