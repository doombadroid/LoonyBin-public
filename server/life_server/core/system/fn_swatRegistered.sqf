 
_unit = [_this,0,objNull,[objNull]] call BIS_fnc_param;
// owner 2026-06-23 SECURITY (security.md §2.2): cop-only, self-only. Reached from the client via
// TON_fnc_registerSwat (fn_swatDispatched's "Join SWAT" action, west-gated client-side) -> a plain `call` here,
// so remoteExecutedOwner is preserved. Ungated, any civ could remoteExec [anyObj] to inject themselves/others
// into the SWAT deployment roster. Require the real caller (remoteExecutedOwner, non-spoofable) to be a west cop
// registering THEMSELVES; server-internal passes.
private _src = remoteExecutedOwner;
private _caller = if (_src isEqualTo 0) then { objNull } else { (allPlayers select { owner _x isEqualTo _src }) param [0, objNull] };
if (_src isNotEqualTo 0 && {!((side _caller isEqualTo west) && {_unit isEqualTo _caller})}) exitWith { ["-SEC-", _caller, format ["BLOCKED swatRegistered by %1", getPlayerUID _caller]] call PLB_fnc_logIt; };
if (isNull _unit) exitWith {};
life_swat_active pushBack _unit;