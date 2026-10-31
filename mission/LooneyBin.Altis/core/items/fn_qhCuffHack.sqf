// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only.
/*
    File: fn_qhCuffHack.sqf  (life_fnc_qhCuffHack)
    LooneyBin 2026-07-22: CUFF CRACKER -- the deck quickhack that breaches your OWN restraints, "same as the
    car lockpick just for handcuffs". Free with the firmware flash. Runs the Sequence Breach minigame directly
    (fn_lockpick refuses to run while the caster is restrained, which is exactly when you need this), and on a
    clean breach frees you (the fn_jailMe unrestrain pattern). Reached with SHIFT+Y while cuffed -- no phone
    (blocked while restrained) and no goggles.
*/
if (!hasInterface) exitWith {};
if (!(call PLB_fnc_hasDeck)) exitWith { ["You don't have a Cyberdeck.", "basic"] spawn life_fnc_handleMessage; };
if (!(player getVariable ["plb_restrained", false]) && {!(player getVariable ["plb_civRestrained", false])}) exitWith {
    ["<t color='#c8f53a'>CUFF CRACKER</t> -- you're not restrained.", "basic"] spawn life_fnc_handleMessage;};
if (dialog) exitWith {};   // the Sequence Breach opens its own dialog

["<t color='#c8f53a'>CUFF CRACKER</t> -- jacking your restraints...", "basic"] spawn life_fnc_handleMessage;
private _r = [6] call life_fnc_cyberdeckSeq;   // 6-cell buffer -- roughly a car breach
if (_r isEqualTo 1) then {if (alive player) then {player switchMove "";
        player setVariable ["plb_escorting", false, true];
        player setVariable ["plb_transporting", false, true];
        player setVariable ["plb_restrained", false, true];
        player setVariable ["plb_civRestrained", false, true];
        detach player;};
    titleText ["Restraints cracked -- you're loose.", "PLAIN"];
    ["<t color='#c8f53a'>CUFFS CRACKED</t> -- you slipped the restraint.", "basic"] spawn life_fnc_handleMessage;} else {
    ["<t color='#ff5a3c'>TRACE FAILED</t> -- the cuffs held. Try again.", "basic"] spawn life_fnc_handleMessage;};
