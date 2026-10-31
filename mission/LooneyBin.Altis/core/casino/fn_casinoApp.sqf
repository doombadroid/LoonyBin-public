/*
    File: fn_casinoApp.sqf  (LooneyBin -- Casino phone app entry)
    What the "Casino" phone button calls. Thin launcher: restriction-gates the player then opens the
    casino GAME-SELECT LANDING (life_fnc_casino "landing"), from which the player picks Blackjack /
    Coin Flip / Wheel / Slots / Roulette / Hi-Lo. This fn NEVER decides outcomes or credits money --
    all of that lives server-side in the per-game TON_fnc engines and the owner-2-gated receivers.
*/
if (!alive player) exitWith { ["You're in no state to gamble.","basic"] spawn life_fnc_handleMessage };
if !(playerSide in [civilian, west, independent]) exitWith { ["You can't visit the casino right now.","basic"] spawn life_fnc_handleMessage };
if (player getVariable ["plb_restrained", false]) exitWith { ["Your hands are restrained.","basic"] spawn life_fnc_handleMessage };
if (player getVariable ["plb_casinoBanned", false]) exitWith { ["You have self-excluded from the casino. An admin must lift it.","basic"] spawn life_fnc_handleMessage };

["landing", []] call life_fnc_casino;
