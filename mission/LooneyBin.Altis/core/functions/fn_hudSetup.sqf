disableSerialization;
2 cutRsc["plb_playerHUD", "PLAIN"];
[] call life_fnc_hudUpdate;
[] spawn {private _damage = 0;
    private _wanted = 0;
    for "_i"
    from 0 to 1 step 0 do {_damage = damage player;
        _wanted = A_stats_crimes select 0;
        waitUntil {uiSleep 1;
            !(_wanted isEqualTo((A_stats_crimes) select 0)) || !(_damage isEqualTo(damage player))};
        [] call life_fnc_hudUpdate;};};