// Super Male Vitality (DataBattle supplement -- owner 2026-07-15). The supplement they BANNED.
// Temp SPRINT buff (+12%) AND ~30% DAMAGE RESIST for 90s. The sprint coef is ABSOLUTE (shares the
// overwrite behaviour with redgull/cocaine/meth/crank -- last drink wins, all revert to 1 on expiry).
// The damage resist is read in fn_handleDamage while (life_supermale_effect select 0) is true. Frogs hate it.
if (life_revive_fatigue > 0) exitWith {["This item has no effect due to revive fatigue.", "basic"] spawn life_fnc_handleMessage;};
if (life_inv_goldbar > 0) exitWith {["This item has no effect when carrying a goldbar.", "basic"] spawn life_fnc_handleMessage;};
private _dur = 90;   // seconds
if ([false, "supermale", 1] call life_fnc_handleInv) then {if (life_supermale_effect select 0) then {
        life_supermale_effect = [true, time];                   // already active -> refresh the timer
    } else {life_supermale_effect = [true, time];                   // [active?, startTime]
        [_dur] spawn {params ["_dur"];
            waitUntil {uiSleep 1;
                (!alive player || ((time - (life_supermale_effect select 1)) > _dur));};
            life_supermale_effect = [false, time];
            player setAnimSpeedCoef 1;                           // revert sprint on expiry (resist lapses with the flag)
        };};
    player setAnimSpeedCoef 1.12;                               // +12% sprint (absolute coef)
    titleText ["SUPER MALE VITALITY coursing through you. You are UNSTOPPABLE (for a bit).", "PLAIN DOWN", -1, true, true];
    ["use", "supermale", 1] call life_fnc_handleQuest;} else {
    ["You have no Super Male Vitality. The globalists got to your supply.", "basic"] spawn life_fnc_handleMessage;};
