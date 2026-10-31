params[["_aliveUnit", objNull], ["_deadUnit", objNull]];
life_corpse = _deadUnit;
// LooneyBin: mission.sqm only defines respawn_civilian. With respawn=BASE the engine respawns west
// (cops) + independent (medics) at [0,0,0] = debug island on death, where they get stuck and often
// can't be revived (after a long wait the engine auto-deletes the corpse, so fn_revived has nowhere
// to teleport them back to). Runtime respawn_west/guerrila markers (initServer createMarker) aren't
// honored by the engine's BASE-respawn marker cache (read once at mission load). Hard-correct here,
// which always runs client-side AFTER the engine respawn: any respawn landing on debug island is
// moved to the side's first real spawn point (cop/medic HQ), falling back to the civilian respawn.
if (((getPosATL _aliveUnit) distance2D [0,0,0]) < 100) then {private _pos = getMarkerPos "respawn_civilian";
    private _spawns = [playerSide] call life_fnc_spawnPointCfg;
    if (count _spawns > 0) then {private _first = (_spawns select 0) select 0;
        private _cand = if (_first isEqualType "") then { getMarkerPos _first } else { _first };
        if !(_cand isEqualTo [0,0,0]) then { _pos = _cand; };};
    _aliveUnit setPosATL _pos;};
if (_aliveUnit getVariable["plb_restrained", false]) then {_aliveUnit setVariable["plb_restrained", false, true]};
// owner 2026-06-19: died in the Dark Fungi Den -> respawned on the surface. Clear the den flag so they can't
// drive back to the surface rocks and dig (must re-take the elevator). See fn_mineFungi / fn_fungiActions.
_aliveUnit setVariable["plb_inFungiDen", false, true];
if (_aliveUnit getVariable["plb_escorting", false]) then {_aliveUnit setVariable["plb_escorting", false, true]};
if (_aliveUnit getVariable["plb_transporting", false]) then {_aliveUnit setVariable["plb_transporting", false, true]};
if (_aliveUnit getVariable["plb_surrendered", false]) then {_aliveUnit setVariable["plb_surrendered", false, true]};
if !(_aliveUnit getVariable["plb_steamid", ""] isEqualTo(getPlayerUID player)) then {
    _aliveUnit setVariable["plb_steamid", getPlayerUID player, true]};
if !(_aliveUnit getVariable["plb_name", ""] isEqualTo profileName) then {_aliveUnit setVariable["plb_name", profileName, true]};
// owner 2026-06-15 (#249): re-apply the COP identity vars on the respawned unit. They're only set in
// fn_initCop at the INITIAL spawn, so a respawn (= new unit object) lost them -> plb_copLevel defaulted to 0
// in fn_playerTags -> no rank/police icon over the cop = "cadets get undercover when they come back to life".
// Restore from the persistent client vars (life_copLevel/life_coprole); detectives + 'all' stay undercover.
if (side _aliveUnit isEqualTo west) then {_aliveUnit setVariable["plb_copLevel", call life_copLevel, true];
    _aliveUnit setVariable["plb_copRetiredLevel", call life_copRetiredLevel, true];
    _aliveUnit setVariable["plb_copRole", life_coprole, true];
    _aliveUnit setVariable["plb_showrank", !(life_coprole in ["detective", "all"]), true];};
 {_x setVariable["plb_aggressive", nil];}
forEach allPlayers;
if (time < (_aliveUnit getVariable["plb_next_revive", -1000])) then {_aliveUnit setVariable["plb_next_revive", -1000, true];};
player playMoveNow "amovppnemstpsraswrfldnon";
[life_sidechat, _aliveUnit] call life_fnc_manageSidechat;
// owner 2026-06-20: stamina REMOVED -- kill it on the freshly respawned unit immediately (a new unit defaults to
// stamina ON; the survival loop also re-asserts it each tick, this just closes the spawn-instant window).
player enableStamina false;