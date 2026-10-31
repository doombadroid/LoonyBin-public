// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only
/*
    File: fn_ringLoadoutDefaults.sqf  (life_fnc_ringLoadoutDefaults)
    Restore the stock 5-tool loadout for the player's side.
*/
PLB_ringLoadWork = +(if (playerSide isEqualTo west) then { PLB_ringDefaultCop } else { PLB_ringDefault });
[PLB_ringLoadWork] call PLB_fnc_ringSaveLoadout;
call life_fnc_ringLoadoutRefresh;
["Ring loadout restored to defaults.", "basic"] spawn life_fnc_handleMessage;
