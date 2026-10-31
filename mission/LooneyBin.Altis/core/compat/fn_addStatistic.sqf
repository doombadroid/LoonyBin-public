// life_fnc_addStatistic (LooneyBin, owner 2026-07-17: was a no-op stub -- session stat counters never ticked).
// Increment the player's stat-buffer slot _index by _value, client-side. Callers remoteExec [index,value] here
// (server/init.sqf login + gang, fn_monitorCaptures). Mirrors the increment in life_fnc_statArrUpdate:636 --
// respects the singleevh double-buffer (PLB_useStatBuffer) so buffered flushes + live reads both see it.
params [["_index", -1, [0]], ["_value", 0, [0]]];
if (!hasInterface || {_index < 0}) exitWith {};
if (!isNil "PLB_useStatBuffer" && {PLB_useStatBuffer}) then {
    PLB_stats_dirty set [_index, (PLB_stats_dirty getOrDefault [_index, 0]) + _value];   // delta -> flush buffer
    PLB_stats_live  set [_index, (PLB_stats_live  getOrDefault [_index, 0]) + _value];   // absolute -> live reads
} else {if (!isNil "plbv_tempStats" && {_index < count plbv_tempStats}) then {
        plbv_tempStats set [_index, (plbv_tempStats select _index) + _value];};};
