/*
    life_fnc_loveBombHeal -- LooneyBin (owner 2026-06-11): runs on each player within 1km of an Ultimate
    Healing Sunshine Love Bomb (remoteExec'd by TON_fnc_loveBombSRV). Heal to full + revive if downed, and
    go briefly invincible so the (cosmetic) blast can't hurt you.
*/
if (!alive player) exitWith {};   // fully dead -> respawns on its own
player allowDamage false;
player setDamage 0;

// revive if incapacitated/downed
if (life_isDowned || {player getVariable ["plb_revivable", false]} || {player getVariable ["plb_reviving", false]}) then {
    life_isDowned = false;
    life_isDead = false;
    if !(isNull (findDisplay 7300)) then { (findDisplay 7300) closeDisplay 0; };
    closeDialog 0;
    { player setVariable [_x, nil, true]; } forEach ["plb_revivable", "plb_reviving", "plb_executing"];
    player setUnconscious false;
    player setDamage 0;
    player switchMove "amovppnemstpsnonwnondnon";
    [] call life_fnc_hudUpdate;};

player setDamage 0;
["<t color='#ff66cc' size='1.3'>You feel the Sunshine Love!</t><br/>The Ultimate Healing Sunshine Love Bomb healed you to full health.", "basic"] spawn life_fnc_handleMessage;
// stay invincible long enough to ride out the blast + the building collapse/debris before re-enabling damage
[] spawn { uiSleep 15; if (alive player) then { player allowDamage true; }; };
