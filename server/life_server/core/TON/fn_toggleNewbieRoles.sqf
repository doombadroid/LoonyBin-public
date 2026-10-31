/*
    TON_fnc_toggleNewbieRoles  (LooneyBin TEST: Owner toggle for the new-player role grant)
    client args: [player]   -- fired by the Owner-only phone button (adminLevel >= 5).
    Flips SRV_grantNewbieRoles, persists it to the config table (REPLACE = atomic, safe under extDB3's
    multi-threaded fire-and-forget), broadcasts the new value to all clients, and tells the owner the
    new state. fn_queryRequest reads SRV_grantNewbieRoles when a NEW player loads and, if on, grants
    APD Chief (cop 7) + AFD Chief (medic 6) + Senior Admin (admin 4).
    Whitelisted in CfgRE.hpp (allowedTargets = 2, client -> server).
*/
params [["_player", objNull, [objNull]]];
if (isNull _player) exitWith {};
// owner 2026-06-23 SECURITY (security.md §2.2 — SERVER TAKEOVER): gate to the OWNER via the NON-SPOOFABLE
// caller. The passed _player object is attacker-controlled (any client can remoteExec this with any object),
// and the docstring's "owner-only phone button (adminLevel>=5)" gate is CLIENT-side only. remoteExecutedOwner
// is the engine-set real sender (0 = server-internal = trusted). Without this, any client flips the auto-grant
// ON, then a fresh alt joins as Senior Admin (4) + APD Chief (7) + AFD Chief (6).
private _src = remoteExecutedOwner;
private _realCaller = if (_src isEqualTo 0) then { objNull } else { (allPlayers select { owner _x isEqualTo _src }) param [0, objNull] };
if (_src != 0 && {getPlayerUID _realCaller != "76561190000000001"}) exitWith {
    ["-SEC-", _realCaller, format ["BLOCKED toggleNewbieRoles by non-owner %1", getPlayerUID _realCaller]] call PLB_fnc_logIt;};

SRV_grantNewbieRoles = !(missionNamespace getVariable ["SRV_grantNewbieRoles", true]);
publicVariable "SRV_grantNewbieRoles";

private _v = if (SRV_grantNewbieRoles) then { "1" } else { "0" };
[format ["REPLACE INTO config (`index`, value) VALUES (200, '%1')", _v]] call DB_fnc_asyncQuery;

private _msg = if (SRV_grantNewbieRoles) then {"Auto-grant ON: new players now spawn as APD Chief, AFD Chief, and Senior Admin."} else {
    "Auto-grant OFF: new players no longer receive roles on join."};
[[1, _msg], "life_fnc_broadcast", _player, false] spawn life_fnc_MP;
diag_log format ["LB_NEWBIE_ROLES toggled -> %1 by %2", SRV_grantNewbieRoles, getPlayerUID _player];
