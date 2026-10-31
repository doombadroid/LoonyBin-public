/*
    life_fnc_adminGodmode  (LooneyBin) -- standalone admin GODMODE toggle.
    owner 2026-06-21: DECOUPLED from Admin Mode. Admin Mode used to bundle godmode + ESP; the "Godmode" menu
    button (idc 12904) was dead (no onButtonClick). Now this is the godmode half on its own, so an admin can run
    ESP without invincibility (and vice-versa).

    Damage/survival immunity only. life_adminGod = the local toggle state. plb_aMode = the BROADCAST godmode flag
    that fn_onPlayerKilled reads (a kill made while godded logs -ADMINACTION- "...with admin-mode activated"
    instead of a normal -KILLED-) and initPlayerLocal re-broadcasts on JIP. On disable we drop allowDamage
    immediately but keep plb_aMode up for a 2-min grace, then clear it IF still off -- the same anti-evasion the
    old bundled Admin Mode had (so an admin can't toggle off a split-second before a kill to dodge the audit log).
*/
if ((call life_adminLevel) <= 1) exitWith {};
if (isNil "life_adminGod") then { life_adminGod = false; };

if (life_adminGod) exitWith {life_adminGod = false;
    player allowDamage true;
    systemChat "Godmode: off";
    [["-ADMINACTION-", player, profileName, "disabled admin godmode."], "TON_fnc_logIt", 2] spawn life_fnc_MP;
    // keep the broadcast accountability flag up 2 more min, then clear only if still off (anti-evasion).
    [] spawn {uiSleep (60 * 2);
        if !(life_adminGod) then {player setVariable ["plb_aMode", false, true];
            [["-ADMINACTION-", player, profileName, "admin godmode shutoff."], "TON_fnc_logIt", 2] spawn life_fnc_MP;};};};

life_adminGod = true;
player allowDamage false;
player setVariable ["plb_aMode", true, true];
private _p = player;
_p setDamage 0;
plbv_hunger = 100;
plbv_thirst = 100;
systemChat "Godmode: on";
[["-ADMINACTION-", player, profileName, "enabled admin godmode."], "TON_fnc_logIt", 2] spawn life_fnc_MP;
