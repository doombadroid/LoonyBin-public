/*
    TON_fnc_timeTrialSRV  (LooneyBin -- implemented 2026-06-09; the passthrough fed
    [player, raceId, carCFG, timer] into the 2017 group-race system (life_racers) -> time-trial
    finishes paid nothing.)  Client (core/civilian/fn_timeTrial.sqf) sends [player, _id, _carCFG, _timer]
    on a completed run. Payout scales gently with course id; the trial vehicle cleans itself up via
    TON_fnc_createTimeTrialVehSRV's watchdog when plb_timeTrialActive drops.
*/
params [["_racer", objNull, [objNull]], ["_id", 0, [0]], ["_carCFG", "", [""]], ["_timer", 0, [0]]];
if (isNull _racer) exitWith {};
// owner 2026-07-24 SECURITY (audit: unauthenticated money printer). This is CfgRE-whitelisted
// allowedTargets=2 and used to validate NOTHING but isNull _racer -- no proof a trial was ever run, no
// cooldown, no caller check -- so any client could remoteExec it in a loop for $20,000-$45,000 a call and
// could bill the payout to any player object it passed. Gating on plb_timeTrialActive would NOT fix it:
// that flag is set by the CLIENT (see fn_createTimeTrialVehSRV's header) and is forgeable.
// Fix: (1) the caller must BE the racer; (2) a server-side start token, written only by
// TON_fnc_createTimeTrialVehSRV when it actually spawns the trial vehicle, must exist; (3) the token is
// CONSUMED here, so a spawn pays exactly once. server-internal (_src == 0) still passes.
private _src = remoteExecutedOwner;   // 0 == server-internal = trusted
private _caller = if (_src isEqualTo 0) then { objNull } else { (allPlayers select { owner _x isEqualTo _src }) param [0, objNull] };
if (_src isNotEqualTo 0 && {isNull _caller || {_caller isNotEqualTo _racer}}) exitWith {
    ["-SEC-", _caller, format ["BLOCKED timeTrial payout billed to someone else (racer=%1)", getPlayerUID _racer]] call PLB_fnc_logIt;};
private _ttKey = format ["PLB_ttRun_%1", getPlayerUID _racer];
if ((missionNamespace getVariable [_ttKey, -1]) < 0) exitWith {
    ["-SEC-", _racer, format ["BLOCKED timeTrial payout with no server-recorded run (id %1)", _id]] call PLB_fnc_logIt;};
missionNamespace setVariable [_ttKey, nil];   // consume: one payout per spawned trial vehicle
_racer setVariable ["plb_timeTrialActive", false, true];
private _payout = 20000 + ((_id max 0) min 10) * 2500;
[["cash", "add", _payout], "life_fnc_uC", _racer, false, false] spawn life_fnc_MP;
[[format ["Time trial complete in %1s -- you earned $%2!", _timer, [_payout] call life_fnc_numberText], "basic"], "life_fnc_handleMessage", _racer, false, false] spawn life_fnc_MP;
["-RACE-", _racer, format ["finished time trial %1 (%2) in %3s, paid $%4", _id, _carCFG, _timer, _payout]] call PLB_fnc_logIt;
