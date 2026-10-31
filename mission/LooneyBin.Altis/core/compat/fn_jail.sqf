// life_fnc_jail -- combat-log re-jail on reconnect (owner 2026-07-17: was a no-op stub = arrest-evasion hole).
// fn_setJail records an arrested player's uid in life_restrained_players; fn_query (server) remoteExecs THIS to
// the reconnecting client, which re-imprisons them via the real jail fn (life_fnc_jailPlayer) with _onLogin=true
// -- bypasses the already-arrested guard, teleports to jail, and restarts the jail timer (TON_fnc_jailSys).
// Runs client-side on the reconnecting player.
if (!hasInterface) exitWith {};
[objNull, false, false, false, true] call life_fnc_jailPlayer;
