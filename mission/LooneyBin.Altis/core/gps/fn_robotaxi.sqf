/*
    life_fnc_robotaxi  (client) -- hail a driverless autopilot cab to your set GPS destination.
    Spawns a cab beside you on the road (server), drops you at the wheel, and auto-drives you there on the NORMAL
    autopilot. You can't override it -- manual input is gated out for robotaxis (fn_gpsAutopilot) -- so it's a true
    self-driving ride. Fare = $500 + $100/km. On-foot only, 60s cooldown. The tech-dystopia dream.
*/
if (!(isNull objectParent player)) exitWith { ["Robotaxi: get out of your vehicle first.", "basic"] spawn life_fnc_handleMessage; };
private _dest = missionNamespace getVariable ["PLB_gpsDest", []];
if (_dest isEqualTo []) exitWith { ["Robotaxi: set a GPS destination first, then hail a cab.", "basic"] spawn life_fnc_handleMessage; };
if ((missionNamespace getVariable ["life_robotaxiCD", 0]) > time) exitWith { ["Robotaxi: no cabs free right now -- try again in a moment.", "basic"] spawn life_fnc_handleMessage; };
private _fare = 500 + round (((player distance2D _dest) / 1000) * 100);
if (life_atmcash < _fare) exitWith { [format ["Robotaxi: the fare is $%1 -- your bank can't cover it.", _fare], "basic"] spawn life_fnc_handleMessage; };

life_robotaxiCD = time + 60;
life_atmcash = life_atmcash - _fare;
[1] call life_fnc_ClupdatePartial;
closeDialog 0;
[format ["<t color='#e7c757'>ROBOTAXI</t> dispatched -- fare $%1. Your cab is pulling up; hop in.", _fare], "basic"] spawn life_fnc_handleMessage;
[getPosATL player, _dest] remoteExec ["TON_fnc_robotaxiSRV", 2];

// once the server seats us, engage the autopilot to the destination -- hands-off the rest of the way
[_dest] spawn {params ["_dest"];
    private _giveUp = time + 15;
    waitUntil { uiSleep 0.4; (!(isNull objectParent player) && {local (vehicle player)}) || (time > _giveUp) };
    if (isNull objectParent player) exitWith {};                        // never got seated (server declined)
    uiSleep 1;
    ["set", _dest] call life_fnc_gps;                                   // plot from where the cab spawned
    uiSleep 0.4;
    ["start", "normal"] call life_fnc_gpsAutopilot;                     // autopilot drives; manual input is gated out for robotaxis
};
