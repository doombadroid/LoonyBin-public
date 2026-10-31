if !([false, "heroinp", 1] call life_fnc_handleInv) exitWith {};
life_drug_level = selectMin[life_drug_level + 0.10, 1];
if (life_heroin_effect isEqualTo 0) then {[] spawn {
        "colorCorrections"
        ppEffectEnable true;
        "colorCorrections"
        ppEffectAdjust[1, 1.5, 0.5, [0, 0, 0, 0], [0.2, 0.2, 0.2, 0.5], [1, 0, 0, 0]];
        "colorCorrections"
        ppEffectCommit 1;
        "chromAberration"
        ppEffectEnable true;
        "chromAberration"
        ppEffectAdjust[life_drug_level / 10, life_drug_level / 10, true];
        "chromAberration"
        ppEffectCommit 1;
        life_heroin_effect = time;
        systemChat "You feel terrific!";
        waitUntil {uiSleep 0.75;
            !(alive player) || ((time - life_heroin_effect) > (4 * 60))};
        "chromAberration"
        ppEffectEnable false;
        "colorCorrections"
        ppEffectEnable false;
        life_heroin_effect = 0;};} else {life_heroin_effect = time;};
[] call life_fnc_hudUpdate;
["heroinp"] call life_fnc_drugUsed;