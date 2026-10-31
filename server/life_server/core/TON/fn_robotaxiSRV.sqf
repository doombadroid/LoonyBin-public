/*
    TON_fnc_robotaxiSRV  (server) -- spawn a driverless autopilot cab for the caller, then clean it up after the ride.
    Client (life_fnc_robotaxi) has already gated (on foot, dest set, fare paid) + engages the autopilot once seated.
    The rider takes the wheel, but the autopilot does the driving and their manual input is gated out (fn_gpsAutopilot),
    so it's hands-off -- no AI chauffeur needed; not being able to override IS the "can't drive it yourself" fix.
    Owner-tagged so the object reaper leaves it alone mid-ride.
*/
if (!isServer) exitWith {};
params [["_pos", [0,0,0], [[]]], ["_dest", [0,0,0], [[]]]];
private _src = remoteExecutedOwner;
private _unit = (allPlayers select { owner _x isEqualTo _src }) param [0, objNull];
if (isNull _unit) exitWith {};
if (!(isNull objectParent _unit)) exitWith {};                          // must be on foot (anti-abuse)

private _rds = _pos nearRoads 60;
private _sp = if (_rds isEqualTo []) then { _pos } else { getPosATL (_rds select 0) };
private _cab = "C_Hatchback_01_F" createVehicle _sp;
_cab setPosATL _sp;
_cab setVectorUp (surfaceNormal (getPosATL _cab));
_cab setFuel 1;
_cab setVariable ["plb_autopilot", true, true];                         // the autopilot module gate
_cab setVariable ["plb_robotaxi", true, true];
_cab setVariable ["owner", getPlayerUID _unit, true];                   // protect from fn_cleanup ownerless-reap
_cab lock 0;
_unit moveInDriver _cab;                                                // rider takes the wheel; autopilot drives, input gated out (fn_gpsAutopilot)
["-ROBOTAXI-", _unit, name _unit, format ["hailed a cab -> %1", mapGridPosition _dest]] call TON_fnc_logIt;

// end the ride: once it brakes to a full stop at the destination, despawn immediately so the cab can't be stolen
// (when the autopilot disengages the rider's input un-gates -- otherwise they could just drive it off).
[_cab, _dest] spawn {params ["_cab", "_dest"];
    uiSleep 12;                                                         // boarding grace
    private _cap = time + 900;
    private _moved = false;
    waitUntil {uiSleep 1;
        if ((speed _cab) > 10) then { _moved = true; };                // it actually got underway
        (isNull _cab) || {!alive _cab}
        || {_cab getVariable ["plb_taxi_arrived", false]}              // autopilot ended the ride (arrival/damage/fuel/blocked)
        || {({isPlayer _x} count crew _cab) isEqualTo 0}               // rider bailed early
        || {_moved && {(speed _cab) < 3} && {(_cab distance2D _dest) < 60}}  // fallback: was moving, now stopped near the dest
        || {time > _cap}};
    // let it brake to a full stop at the curb, then despawn. The cab is LOCAL TO THE RIDER'S CLIENT
    // (he was the driver), and a server-side deleteVehicle on a remote object is a silent no-op -- that
    // was the "coasts to a stop and sits there forever" bug. Pull locality home first.
    waitUntil { uiSleep 1; (isNull _cab) || {(speed _cab) < 2} || {time > _cap + 30} };
    uiSleep 1;
    if (!isNull _cab) then {_cab setOwner 2;                                               // locality back to the server
        uiSleep 1;
        deleteVehicle _cab;                                            // anyone inside pops out on foot -- no free cab
    };};
