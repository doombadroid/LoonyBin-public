/*
    life_fnc_lzEject  (LooneyBin, owner 2026-07-16) -- server orders this client OUT of a Loonazon van.
    moveOut is an argument-local command and CfgRE Commands mode=0 blocks command remoteExec entirely, so the
    eject rides a whitelisted FUNCTION: runs on the rider's own client where their unit is local.
    Handler gate: only the SERVER may fire this (remoteExecutedOwner 2).
*/
if (!hasInterface) exitWith {};
if (isRemoteExecuted && {remoteExecutedOwner isNotEqualTo 2}) exitWith {};
if (isNull objectParent player) exitWith {};
if !((objectParent player) getVariable ["plb_loonazonVan", false]) exitWith {};
moveOut player;
["The Loonazon van's security system ejects you. The seats are for packages.", "basic"] spawn life_fnc_handleMessage;
