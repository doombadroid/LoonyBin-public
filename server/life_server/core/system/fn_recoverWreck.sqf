// LooneyBin owner 2026-07-04: Wreckage Recovery Kit -- return a WRECK to its OWNER's garage (active=0), then
// remove the wreck. Server-authoritative: the owner UID + plate come from the wreck's plb_dbInfo (set by the
// garage-pull path), never from the caller. DELETE-then-INSERT on (pid, plate) so exactly ONE garage row
// exists whether the wreck's row was already deleted (uninsured -> fn_vehicleDead removed it) or still sits
// active=1 (insured), and a double-recover race collapses to a single row.
params [["_wreck", objNull, [objNull]]];
// owner 2026-07-05: DB-visible entry trace (the RPT is block-buffered / unreadable live). Records whether the
// server was even reached + the exact state it gates on (null / alive / dbInfo), so we can pin where recovery
// dies without an in-game repro. Reads on objNull are safe (return the default).
["-WRECKKIT-SRV", objNull, format ["recv: class=%1 isNull=%2 alive=%3 dbInfoP=%4 dbInfoL=%5", (if (isNull _wreck) then {"none"} else {typeOf _wreck}), isNull _wreck, (!isNull _wreck && {alive _wreck}), (_wreck getVariable ["plb_dbInfo", []]), (_wreck getVariable ["dbInfo", []])]] spawn TON_fnc_logIt;
if (isNull _wreck) exitWith {};
if (alive _wreck) exitWith {};   // only actual wrecks

private _dbInfo = _wreck getVariable ["plb_dbInfo", []];
if (count _dbInfo == 0) then { _dbInfo = _wreck getVariable ["dbInfo", []]; };
if (count _dbInfo < 2) exitWith {
    diag_log format ["[LooneyBin][recoverWreck] wreck %1 has no dbInfo -> can't map it to a garage; clearing it anyway", typeOf _wreck];
    ["-WRECKKIT-SRV", objNull, format ["EXIT no-dbInfo (count<2) on %1 -- wreck cleared, NO db write", typeOf _wreck]] spawn TON_fnc_logIt;
    { deleteVehicle _x } forEach (attachedObjects _wreck);
    deleteVehicle _wreck;};

private _uid   = format ["%1", _dbInfo select 0];
private _plate = format ["%1", _dbInfo select 1];
// SECURITY (owner 2026-07-04): plb_dbInfo is written CLIENT-side with public=true at garage-pull, so a script
// executor can broadcast an arbitrary [uid,plate] onto any wreck. These go into raw SQL below, so validate that
// both are plain DIGIT strings (Steam64 UIDs, gang UIDs, and plates are all integers) -> a spoofed value with a
// quote/paren/space can never break out of the quoted literal (no SQLi / no table-wipe). Mirror of the
// fn_loginBonusSRV hardening. _class comes from typeOf (the real object, not spoofable), so it needs no scrub.
private _isNum = { params ["_s"]; (count _s > 0) && {(toArray _s) findIf { !(_x >= 48 && {_x <= 57}) } < 0} };
if !((_uid call _isNum) && {_plate call _isNum}) exitWith {
    diag_log format ["[LooneyBin][recoverWreck] REJECTED non-numeric dbInfo (uid=%1 plate=%2) on %3 -- possible spoof; wreck cleared, NO db write", _uid, _plate, typeOf _wreck];
    ["-WRECKKIT-SRV", objNull, format ["EXIT non-numeric dbInfo uid=%1 plate=%2 on %3 -- wreck cleared, NO db write", _uid, _plate, typeOf _wreck]] spawn TON_fnc_logIt;
    { deleteVehicle _x } forEach (attachedObjects _wreck);
    deleteVehicle _wreck;};
// owner 2026-07-24 SECURITY (audit): the 2026-07-04 hardening above scrubs uid/plate against SQL injection
// but NOT against authorisation -- plb_dbInfo is written client-side with public=true, so a script executor
// can stamp its OWN uid onto somebody else's wreck and have it recovered into its own garage. There is also
// no caller check at all, so it can be fired from anywhere.
// Two additions, both chosen so they cannot reject a legitimate recovery:
//   1. If the `vehicles` table still knows this plate, take the owner from the DB (authoritative) rather
//      than the broadcast value. An UNINSURED wreck's row is already deleted by fn_vehicleDead, so no row
//      means we keep the existing behaviour and trust dbInfo -- unchanged from today.
//   2. A client caller must be near the wreck. The kit is used by walking up to it; the kit-possession
//      check itself stays client-side (server cannot see virtual inventory here).
private _srcRW = remoteExecutedOwner;   // 0 == server-internal = trusted
if (_srcRW isNotEqualTo 0) then {private _rwCaller = (allPlayers select { owner _x isEqualTo _srcRW }) param [0, objNull];
    if (isNull _rwCaller || {(_rwCaller distance _wreck) > 30}) then {
        ["-WRECKKIT-SRV", _rwCaller, format ["BLOCKED recoverWreck (range %1) on %2",
            if (isNull _rwCaller) then {-1} else {round (_rwCaller distance _wreck)}, typeOf _wreck]] spawn TON_fnc_logIt;
        _uid = "";   // signal; the guard below exits before any DB write
    };};
if (_uid isNotEqualTo "") then {
    private _dbOwner = [format ["SELECT pid FROM %1 WHERE plate='%2'", srv_table_vehicles, _plate], 2] call DB_fnc_asyncQuery;
    if (_dbOwner isEqualType [] && {count _dbOwner > 0}) then {private _trueUid = format ["%1", _dbOwner select 0];
        if ((_trueUid call _isNum) && {_trueUid isNotEqualTo _uid}) then {
            ["-WRECKKIT-SRV", objNull, format ["dbInfo uid %1 != DB owner %2 for plate %3 -- using the DB owner", _uid, _trueUid, _plate]] spawn TON_fnc_logIt;
            _uid = _trueUid;};};};
if (_uid isEqualTo "") exitWith {};
private _class = typeOf _wreck;
private _type  = switch (true) do {case (_class isKindOf "Air"):  { "Air" };
    case (_class isKindOf "Ship"): { "Ship" };
    default { "Car" };};

// owner 2026-07-08 (Pawnee/Blackfish never returned to garage): recreate the row -- the wreck's DB row was DELETED
// on death (no insurance on this server, so fn_vehicleDead:41 always removes it). TWO fixes vs the old code, which
// copy-pasted the civ-only login-bonus INSERT and baked in two false assumptions:
//   (1) SIDE was hardcoded 'civ'. A cop/med-owned vehicle written 'civ' is invisible to that player's garage tab
//       forever (fn_getVehicles filters side=cop/civ/med by playerSide). Use the REAL side from plb_side, which
//       fn_prepareVehicle (pull) and fn_restoreVehicles (restart) both stamp on the vehicle (values cop/civ/med)
//       and which survives on the wreck object. -> fixes cop/NG Blackfish.
//   (2) GANG vehicles were written to the personal `vehicles` table (pid=gang_id) -> matched neither garage ->
//       orphaned. Route them to gang_vehicles. Gang vs personal is told SERVER-side by id LENGTH (a gang_id is a
//       short int; a Steam64 owner uid is 17 digits) -- non-spoofable, and correct for pulled AND restored vehicles.
//       -> fixes gang-pooled Pawnee.
private _isGang = (count _uid) < 15;   // gang_id (short) vs Steam64 (17)

if (_isGang) then {
    // GANG -> gang_vehicles (keyed by gang_id; no side/alive/listed columns). Mirrors fn_gangGarageStore.sqf:86.
    [format ["DELETE FROM gang_vehicles WHERE gang_id='%1' AND plate='%2'", _uid, _plate]] call DB_fnc_asyncQuery;
    [format ["INSERT INTO gang_vehicles (pid, classname, type, gang_id, inventory, active, plate, color, fuel, damage) VALUES ('%1','%2','%3','%1','[]','0','%4','0','100','0')", _uid, _class, _type, _plate]] call DB_fnc_asyncQuery;
    diag_log format ["[LooneyBin][recoverWreck] %1 (plate %2) recovered to GANG garage %3", _class, _plate, _uid];
    ["-WRECKKIT-SRV", objNull, format ["WROTE gang_vehicles row: class=%1 type=%2 gang=%3 plate=%4 (active=0)", _class, _type, _uid, _plate]] spawn TON_fnc_logIt;
} else {
    // PERSONAL -> vehicles (keyed by pid) with the CORRECT stored side. active=0 -> garage; alive=1; repaired; empty.
    private _side = _wreck getVariable ["plb_side", "civ"];
    if !(_side in ["cop", "civ", "med"]) then { _side = "civ"; };   // allowlist -- plb_side is client-broadcast
    [format ["DELETE FROM %1 WHERE pid='%2' AND plate='%3'", srv_table_vehicles, _uid, _plate]] call DB_fnc_asyncQuery;
    [format ["INSERT INTO %1 (side, classname, type, pid, alive, active, inventory, color, plate, fuel, damage, alarm) VALUES ('%2', '%3', '%4', '%5', '1', '0', '[]', '0', '%6', '100', '0', '0')", srv_table_vehicles, _side, _class, _type, _uid, _plate]] call DB_fnc_asyncQuery;
    diag_log format ["[LooneyBin][recoverWreck] %1 (plate %2) recovered to garage of %3 (side %4)", _class, _plate, _uid, _side];
    ["-WRECKKIT-SRV", objNull, format ["WROTE garage row: class=%1 type=%2 side=%3 uid=%4 plate=%5 (active=0, alive=1)", _class, _type, _side, _uid, _plate]] spawn TON_fnc_logIt;
};

{ deleteVehicle _x } forEach (attachedObjects _wreck);
deleteVehicle _wreck;
