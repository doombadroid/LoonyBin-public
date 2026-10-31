if !([false, "crankp", 1] call life_fnc_handleInv) exitWith {};
life_drug_level = selectMin[life_drug_level + 0.4, 1];
if (life_crank_effect isEqualTo 0) then {life_crank_effect = time;
    [] spawn {player setAnimSpeedCoef 1.15;
        player setFatigue 0;
        player enableFatigue false;
        life_fatigueEnabled = false;
        waitUntil {uiSleep 0.575;
            !(alive player) || ((time - life_crank_effect) > (4.5 * 60))};
        player setAnimSpeedCoef 1;
        player enableFatigue true;
        life_crank_effect = 0;
        life_fatigueEnabled = true;};
    [] spawn {
        "ColorInversion"
        ppEffectEnable true;
        "ColorInversion"
        ppEffectAdjust[life_drug_level / 5, 0, life_drug_level / 5];
        "ColorInversion"
        ppEffectCommit 1;
        "chromAberration"
        ppEffectEnable true;
        "chromAberration"
        ppEffectAdjust[life_drug_level / 10, life_drug_level / 10, true];
        "chromAberration"
        ppEffectCommit 1;
        uiSleep 2.25;
        while {alive player && ((time - life_crank_effect) < (4 * 60))}
        do {
            "ColorInversion"
            ppEffectEnable true;
            "ColorInversion"
            ppEffectAdjust[life_drug_level / 5, 0, life_drug_level / 5];
            "ColorInversion"
            ppEffectCommit 1;
            "chromAberration"
            ppEffectEnable true;
            "chromAberration"
            ppEffectAdjust[life_drug_level / 10, life_drug_level / 10, true];
            "chromAberration"
            ppEffectCommit 1;
            uiSleep 2;};
        "chromAberration" ppEffectEnable false;
        "ColorInversion"
        ppEffectEnable false;
        life_crank_effect = 0;};} else {life_crank_effect = time;};
systemChat "You feel incredible!";
[] call life_fnc_hudUpdate;
["crank"] call life_fnc_drugUsed;