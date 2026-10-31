// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only
/*
    File: fn_qhTrace.sqf  (life_fnc_qhTrace)
    LooneyBin 2026-07-21: the victim's answer to being hacked. Inside the 10s trace window this pings
    the hacker's position back -- the risk half of every quickhack's risk/reward.
*/
if (diag_tickTime > (missionNamespace getVariable ["plb_qhTraceUntil", 0])) exitWith {
    ["The trace window has closed.", "basic"] spawn life_fnc_handleMessage;};
private _h = missionNamespace getVariable ["plb_qhLastHacker", objNull];
if (isNull _h) exitWith { ["Nothing to trace.", "basic"] spawn life_fnc_handleMessage; };
plb_qhTraceUntil = 0;
[["trace", _h, player], "TON_fnc_qhSRV", 2] spawn life_fnc_MP;
["<t color='#c9e21a'>TRACING</t> -- following the signal back...", "basic"] spawn life_fnc_handleMessage;
