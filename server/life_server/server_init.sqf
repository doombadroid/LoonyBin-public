
// LooneyBin: PLB_UsingHeadless was NEVER defined anywhere, so the diag_log + `if (PLB_UsingHeadless)`
// below threw "Undefined variable" and HALTED server_init.sqf before the HandleDisconnect EH (and
// eventhandlers.sqf) were ever added -> disconnect cleanup never ran (corpse left at feet, no final
// flush). No headless client in this deployment -> false.
if (isNil "PLB_UsingHeadless") then { PLB_UsingHeadless = false; };
life_radio_dispatch = radioChannelCreate [[0, 0, 1, 1], "APD Dispatch", "%UNIT_NAME", []];
life_radio_RF = [radioChannelCreate [[0.8,0,0.6,0.9], "Radio Chan 1", "%UNIT_NAME", []],
radioChannelCreate [[0.8,0,0.6,0.9], "Radio Chan 2", "%UNIT_NAME", []],
radioChannelCreate [[0.8,0,0.6,0.9], "Radio Chan 3", "%UNIT_NAME", []]];
// owner 2026-06-13: phone-call line pool. handlePhoneCallSRV seeds PLB_phoneCalls from these (valid/non-zero
// channels only) -> this is the max CONCURRENT calls. Bumped 5 -> 10 for headroom; any that exceed Arma's
// channel cap come back 0 and are skipped by the handler, so over-allocating here is harmless.
life_phone_groups = [[radioChannelCreate [[0.8,0,0.6,0.9], "Cell Phone", "%UNIT_NAME", []], []],
[radioChannelCreate [[0.8,0,0.6,0.9], "Cell Phone", "%UNIT_NAME", []], []],
[radioChannelCreate [[0.8,0,0.6,0.9], "Cell Phone", "%UNIT_NAME", []], []],
[radioChannelCreate [[0.8,0,0.6,0.9], "Cell Phone", "%UNIT_NAME", []], []],
[radioChannelCreate [[0.8,0,0.6,0.9], "Cell Phone", "%UNIT_NAME", []], []],
[radioChannelCreate [[0.8,0,0.6,0.9], "Cell Phone", "%UNIT_NAME", []], []],
[radioChannelCreate [[0.8,0,0.6,0.9], "Cell Phone", "%UNIT_NAME", []], []],
[radioChannelCreate [[0.8,0,0.6,0.9], "Cell Phone", "%UNIT_NAME", []], []],
[radioChannelCreate [[0.8,0,0.6,0.9], "Cell Phone", "%UNIT_NAME", []], []],
[radioChannelCreate [[0.8,0,0.6,0.9], "Cell Phone", "%UNIT_NAME", []], []]];

diag_log format["PLB_UsingHeadless = %1", PLB_UsingHeadless];
if (PLB_UsingHeadless) then {publicVariable "life_radio_dispatch";
publicVariable "life_radio_RF";
publicVariable "life_phone_groups";};

addMissionEventHandler ["HandleDisconnect", {if (!isServer) exitWith {};
// owner 2026-07-16 INCIDENT FIX: the Loonazon autopilot HC (HC1) is NOT mission-critical. The old code ended
// the mission (BIS_fnc_endMission) whenever HC1 dropped -> every autopilot-HC reconnect booted the whole
// server. Now an HC disconnect just clears PLB_hcOwner (Loonazon then refuses new orders -> "on strike"
// message client-side) and NEVER ends the mission. Player disconnects always run on the server.
if (!isNil "HC1" && {!isNull HC1} && {(_this select 0) isEqualTo HC1}) exitWith { PLB_hcOwner = 0; publicVariable "PLB_hcOwner"; diag_log "[LooneyBin][HC] autopilot HC disconnected -> Loonazon closed until it returns (mission kept alive)"; };
[_this select 3,_this select 2, _this select 0] spawn PLB_fnc_playerDisconnected;}];

[] execVM "\life_server\eventhandlers.sqf";

// singleevh.md: day/night setTimeMultiplier migrated onto the single-wheel scheduler (id "dayNightTime", 200s).
// Cross-iteration de-dupe local _lastMultiplyer -> per-job state _st["last"]. Flag OFF => original loop runs
// byte-for-byte (else branch) = ZERO behavior change.
["dayNightTime", {params ["_st"];
    private _multiplier = 12;
    if (sunOrMoon < 1) then { _multiplier = _multiplier * 4.5; };
    if ((_st getOrDefault ["last", -1]) != _multiplier) then { setTimeMultiplier _multiplier; _st set ["last", _multiplier]; };
}, 200, false, true] call PLB_fnc_schedule;

// owner 2026-07-10: AUTOMATIC WEATHER CYCLE (sibling of dayNightTime; weather was admin-only -> stayed clear
// forever). Every ~40 min pick weighted-random weather [rain,fog,overcast] and broadcast: SRV_wcweather drives
// every client + JIP via the initPlayerLocal publicVariable handler, and the server applies it too with a
// smooth 120s transition. RESPECTS an admin-forced toggle (PLB_wx_rain / PLB_wx_snow from TON_fnc_changeWeather)
// -- won't auto-override admin weather until they clear it. Flag OFF => the equivalent legacy loop.
PLB_fnc_wxRoll = {private _r = random 1;
    switch (true) do {                                                     // [rain, fog, overcast]
        case (_r < 0.55): { [0, 0, random 0.2] };                          // clear-ish
        case (_r < 0.80): { [0, random 0.05, 0.4 + random 0.3] };          // cloudy
        case (_r < 0.92): { [0.4 + random 0.4, 0.05, 0.85 + random 0.15] };// rain
        default          { [0, 0.2 + random 0.25, 0.2 + random 0.2] };     // fog
    }}; ["weatherCycle", {params ["_st"];
    if ((missionNamespace getVariable ["PLB_wx_rain", false]) || {missionNamespace getVariable ["PLB_wx_snow", false]}) exitWith {};
    private _wx = call PLB_fnc_wxRoll;
    SRV_wcweather = _wx; publicVariable "SRV_wcweather";
    120 setOvercast (_wx select 2); 120 setRain (_wx select 0); 120 setFog (_wx select 1);
    diag_log format ["[LooneyBin][weather] auto-cycle -> rain %1 / fog %2 / overcast %3", _wx select 0, _wx select 1, _wx select 2];
}, 2400, false, true] call PLB_fnc_schedule;

// owner 2026-06-14 (#205): DISABLED the legacy auto-soft-restart. This spawned PLB_fnc_rebootMonitor (a
// 30-min "Server Maintenance" countdown -> doRestart/endMission = mission soft-reload) after life_restart_delay.
// It was never removed when the 4h ALWAYS-HARD scheduler (init.sqf ~line 227) became the sole restart
// authority, so BOTH ran -- the rebootMonitor reload landed right on top of the 4h scheduler's "1 Hour until
// RESTART" warning (RPT 13:50:01 warning -> 13:50:31 mission reload), which players saw as "it gave the 1
// hour msg then immediately restarted" (#195/#205). The 4h hard cycle handles restarts now; rebootMonitor is
// kept only for a MANUAL admin-triggered reboot. Re-enable this block only if the 4h scheduler is removed.
// [] spawn
// {
// waitUntil {!isNil "life_restart_delay"};
// sleep life_restart_delay;
// [] spawn PLB_fnc_rebootMonitor;
// };