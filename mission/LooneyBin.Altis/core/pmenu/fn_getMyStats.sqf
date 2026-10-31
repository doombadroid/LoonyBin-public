#include "..\..\macro.h"
params[["_isTitleApp", false, [false]]];
// owner 2026-07-17: re-enabled the My Stats chat command (was hard-gated off). Both paths share the stat-fetch
// below; _isTitleApp=false -> life_fnc_statsMenu (dialog myloonybinstats/877000), true -> life_fnc_titleMenu.
if (scriptAvailable(300)) exitWith {if (_isTitleApp) then {[] call life_fnc_titleMenu} else {[] spawn life_fnc_statsMenu};};
if (_isTitleApp) then {["Attempting to fetch your stats to unlock your titles...", "basic"] spawn life_fnc_handleMessage;} else {
    ["Attempting to fetch your stats to display My Stats...", "basic"] spawn life_fnc_handleMessage;};
if (PLB_useStatBuffer) then {
    // singleevh.md Phase 3a.2: build the 148-slot display array from the live stat map -> no DB round-trip.
    plbv_statTotals = []; for "_i" from 0 to 147 do { plbv_statTotals pushBack (PLB_stats_live getOrDefault [_i, 0]); };} else {
    [[getPlayerUID player], "TON_fnc_getStatsArr", 2] call life_fnc_MP;};
private _timer = time;
waitUntil {uiSleep 0.1;
    (count plbv_statTotals) > 0 || (time - _timer) > 15};
if (time - _timer > 15) exitWith {["Server did not respond.", "basic"] spawn life_fnc_handleMessage;};
if ((count plbv_statTotals) isEqualTo 0) exitWith {
    ["We could not find any stats for supplied playerid.", "basic"] spawn life_fnc_handleMessage;};
if (_isTitleApp) then {[] call life_fnc_titleMenu} else {[] spawn life_fnc_statsMenu};