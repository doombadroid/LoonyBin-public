closeDialog 0;
life_respawned = true;
// owner 2026-06-16 (#291/#292): the engine corpse-immunity window was raised to ~31min so a body can't be
// yanked out from under a player mid-bleedout (the old 360s setting force-respawned them at ~5-6min). But that
// would also make a RESPAWNED player's abandoned body linger ~31min -> corpse buildup. `player` is still the
// dead body here (the engine respawn hasn't fired yet), so flag it -> fn_cleanup reaps a respawned-orphan on
// its next pass instead of waiting the full window. A body left bleeding for a revive is NOT flagged (this
// only runs when the player CHOSE to respawn) -> it stays protected for the full 30min.
player setVariable ["plb_respawnedOrphan", true, true];
life_inCombat = false; {_x setVariable["plb_aggressive", nil];}
forEach allPlayers;
private _toSend = (allPlayers - [allDeadMen] - [player]) select {
    (side _x isEqualTo west && _x getVariable["plb_copRole", ""] in ["medic", "all"]) || side _x isEqualTo independent};
if !(_toSend isEqualTo[]) then {[[player, player], "life_fnc_medicRespondDone", _toSend] spawn life_fnc_MP;};
[] spawn life_fnc_spawnMenu;