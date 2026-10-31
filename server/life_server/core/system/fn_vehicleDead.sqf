 
private["_vehicle","_plate","_uid","_query","_sql","_dbInfo"]; 
_vehicle = [_this,0,ObjNull,[ObjNull]] call BIS_fnc_param; 
if(isNull _vehicle) exitWith {};  
 
// owner 2026-06-19 (#406): read plb_dbInfo (the 2020 client / garage-pull var) first, falling back to legacy
// dbInfo. This ONLY read "dbInfo", which garage-pulled vehicles (fn_vehicleGaragePull/gangGaragePull set only
// plb_dbInfo) never have -> count 0 -> exited BEFORE deleteVehicle. So a cop SEIZE paid out (copSplit) but the
// vehicle was never removed ("seize completes + pays but doesn't seize the ifrit"). Restored-after-restart
// vehicles set dbInfo and worked; freshly-pulled ones didn't. deleteVehicle now ALWAYS runs.
_dbInfo = _vehicle getVariable["plb_dbInfo",[]];
if (count _dbInfo == 0) then { _dbInfo = _vehicle getVariable["dbInfo",[]]; };
if (count _dbInfo >= 2) then {_uid = _dbInfo select 0;
_plate = _dbInfo select 1;
// owner 2026-06-21 (Ebola vehicle-loss report): if this vehicle was RESTORED by the restart and died within 60s of
// that respawn, it almost certainly clipped a building/terrain on restore (the restore re-spawns at the EXACT parked
// position with NO building-overlap check -> embeds -> dies the moment the 20s damage shield lifts). Do NOT delete
// the owner's vehicle for OUR restore bug -- GARAGE it (active=0) + repair (damage=0) so they keep it and re-pull it.
// Normal deaths (not restored, >60s old, or insured) fall through to the unchanged delete path below.
private _restoredAt = _vehicle getVariable ["plb_restoredAt", -99999];
// owner 2026-06-21 (#453 sub-path): widened 60 -> 300s. A restored vehicle embedded in a building takes damage
// only after the 20s shield lifts and can tip/cook off slowly, dying PAST 60s -> it fell through to DELETE = the
// "orcas keep disappearing" tail. 5 min comfortably covers slow restore-collision deaths; an uninsured vehicle
// dying within 5 min of a restart is almost always our restore bug, not legit gameplay -> GARAGE it, don't delete.
if (((_restoredAt > -99999) && {(serverTime - _restoredAt) < 300}) && {!(_vehicle getVariable ["insured", false])}) then {
[format ["UPDATE vehicles SET active='0', damage='0' WHERE pid='%1' AND plate='%2'", _uid, _plate]] call DB_fnc_asyncQuery;
diag_log format ["[LooneyBin][veh] restore-collision death (<60s) -> GARAGED+repaired, not deleted: plate=%1 uid=%2", _plate, _uid];}
else {if (!(_vehicle getVariable ["insured", false])) then {[_plate,_uid] call DB_fnc_deleteVehicle;};};};

// owner 2026-07-04: leave the wreck on the map for 40min (players can SEE + recover it with a Wreckage
// Recovery Kit) instead of vanishing the instant it's destroyed. Only EXPLICIT removals -- cop seize/impound,
// which pass reason "seize" -- delete right away. Natural deaths (the Killed EH passes no reason string) get
// stamped as a lingering wreck; the idle-cleanup loop (fn_cleanup dead-branch) removes it once 40min elapse.
// (Killed EH _this select 1 is the killer OBJECT -> fails the [""] typecheck -> reason "" -> lingers. Good.)
private _reason = [_this,1,"",[""]] call BIS_fnc_param;
if (_reason isEqualTo "seize") then {deleteVehicle _vehicle;} else {_vehicle setVariable ["plb_wreckDeadAt", serverTime, true];
    _vehicle setVariable ["plb_isWreck", true, true];};