waitUntil {position player distance(getMarkerPos "Respawn_west") > 1000}; [{
    if (!PLB_useStatBuffer) then { [9] call life_fnc_ClupdatePartial; };   // singleevh.md Phase 3b: flag-on -> A_stats flushed by the unified fn_flushStats (120s + events), not this 300s PFH
    if (life_newPlyrRev > 4) then {[
            [1, player, "Potential Revive Exploit", format["This player has done %1 revives in the last 5 minutes and could be exploiting revive fees.", life_newPlyrRev]], "TON_fnc_discordEmbed", 2] call life_fnc_MP;
    };
    life_newPlyrRev = 0;
    [1] call life_fnc_questSync;
    private _syncQuest = false;
    if (!(life_LifetimeProgressQuests isEqualTo[]) && !(life_lastSynced_LifetimeProgressQuests isEqualTo life_LifetimeProgressQuests)) then {
        _syncQuest = true};
    if !(life_lastSynced_completedLifetimeQuests isEqualTo life_completedLifetimeQuests) then {_syncQuest = true};
    if (_syncQuest) then {[20] call life_fnc_ClupdatePartial};}, [], 300] call life_fnc_addPerFrameHandler;
// singleevh.md Phase 3a: periodic durable flush of the stat buffer (flag-gated). Bounds crash loss to ~120s
// (the legacy path only flushed on respawn / sync / restart / quit, so a hard crash lost the session's deltas).
[{ if (PLB_useStatBuffer) then { call life_fnc_flushStats }; }, [], 120] call life_fnc_addPerFrameHandler; [{params[["_args", [0], [[]]
    ], ["_handle", -1, [0]]];
    _args params[["_civTime", 0, [0]]];
    
        switch (playerSide) do {case west: {A_stats_copTime = A_stats_copTime + 1;
                    life_houseTimer = life_houseTimer + 1;};
            case civilian: {A_stats_civTime = A_stats_civTime + 1;
                    if !(life_houses isEqualTo[]) then {life_houseTimer = life_houseTimer + 1;};};
            case independent: {A_stats_medTime = A_stats_medTime + 1;};
        }; if (PLB_useStatBuffer) then { PLB_astats_dirty = true; }; if (life_houseTimer >= 10) then {life_houseTimer = 0; [
                ["updateHouseTime", [player]], "TON_fnc_houseTaxSRV", 2] spawn life_fnc_MP;};;
    if (playerSide isEqualTo civilian && {!isNil "A_stats_civTime"}) then {if ((A_stats_civTime - _civTime) > 360) then {[
                [player, [71, _civTime, str A_stats_civTime]], "TON_fnc_dongClient", 2] call life_fnc_MP;};};
    life_mpCalls = [];}, [A_stats_civTime], 60] call life_fnc_addPerFrameHandler;