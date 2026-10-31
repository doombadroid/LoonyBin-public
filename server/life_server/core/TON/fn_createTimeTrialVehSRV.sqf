/*
    TON_fnc_createTimeTrialVehSRV  (LooneyBin -- implemented from stub 2026-06-09)
    Time trials race vehicle. Client (core/civilian/fn_timeTrial.sqf, civTimeTrials NPC) sends
    [player, _carCFG, _carPos, _carD] after setting its own plb_timeTrialActive=true.
    Spawns the race car, keys it to the racer, deletes it when the trial ends (plb_timeTrialActive
    false), the racer leaves/dies, or after 30 min.
*/
params [["_racer", objNull, [objNull]], ["_carCFG", "", [""]], ["_carPos", [0,0,0], [[]]], ["_carD", 0, [0]]];
if (isNull _racer || {_carCFG isEqualTo ""}) exitWith {};
// owner 2026-07-24 SECURITY (audit: timeTrialSRV was an unauthenticated money printer). The payout fn had
// no proof a trial ever happened, because the only "am I racing" flag (plb_timeTrialActive) is set by the
// CLIENT (see the header above) and is therefore forgeable. Record a SERVER-side, non-public start token
// here -- the one place a trial can legitimately begin -- which TON_fnc_timeTrialSRV requires and then
// consumes, making the payout single-use per spawned vehicle. Also require the caller to be the racer.
private _src = remoteExecutedOwner;   // 0 == server-internal = trusted
private _caller = if (_src isEqualTo 0) then { objNull } else { (allPlayers select { owner _x isEqualTo _src }) param [0, objNull] };
if (_src isNotEqualTo 0 && {isNull _caller || {_caller isNotEqualTo _racer}}) exitWith {
    ["-SEC-", _caller, format ["BLOCKED createTimeTrialVeh for someone else (racer=%1)", getPlayerUID _racer]] call PLB_fnc_logIt;};
missionNamespace setVariable [format ["PLB_ttRun_%1", getPlayerUID _racer], serverTime];   // server-only: never publicVariable'd
private _veh = _carCFG createVehicle _carPos;
_veh setPosATL _carPos;
_veh setDir _carD;
_veh lock 0;
_veh setVariable ["plb_timeTrialVeh", true, true];
_veh setVariable ["plb_vehOwners", [[getPlayerUID _racer, name _racer]], true];
_veh setVariable ["owner", getPlayerUID _racer, true];   // cleanup-sweep spare
_veh setFuel 1;
[_veh, _racer] spawn {params ["_veh", "_racer"];
    private _endAt = serverTime + 1800;
    waitUntil { uiSleep 5;
        isNull _veh || {!alive _veh} || {isNull _racer} || {!alive _racer} ||
        {!(_racer getVariable ["plb_timeTrialActive", false])} || {serverTime > _endAt} };
    if (!isNull _veh) then { deleteVehicle _veh; };};
diag_log format ["[LooneyBin][timeTrial] %1 spawned for %2", _carCFG, getPlayerUID _racer];
