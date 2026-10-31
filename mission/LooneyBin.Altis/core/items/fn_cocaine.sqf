params[["_isForced", false, [false]]];
if ((_isForced) || ([false, "cocainep", 1] call life_fnc_handleInv)) then {if (life_cocaine_effect select 0) then {
        life_cocaine_effect = [true, time];} else {life_cocaine_effect = [true, time];
        [] spawn {waitUntil {uiSleep 1;
                (!alive player || ((time - (life_cocaine_effect select 1)) > (6 * 60)));};
            // owner 2026-06-20: do NOT re-enable stamina on expiry (stamina is removed server-wide). Just clear the
            // effect flag + revert the speed buff to base.
            life_cocaine_effect = [false, time];
            life_fatigueEnabled = true;
            player setAnimSpeedCoef 1;};};
    [] call life_fnc_hudUpdate;
    life_fatigueEnabled = false;
    player setFatigue 0;
    player enableFatigue false;
    titleText["You feel unstoppable!", "PLAIN"];
    player setAnimSpeedCoef 1.15;   // owner 2026-06-21: cocaine = +15% sprint speed (was +30%, originally +10%). setAnimSpeedCoef is absolute -> overwrites/overwritten by other speed buffs (meth/crank/redgull), reverts to 1.0 on expiry.
    ["cocainep"] call life_fnc_drugUsed;
    life_drug_level = selectMin[1, life_drug_level + 0.15];} else {["You have no cocaine to use.", "basic"] spawn life_fnc_handleMessage;};