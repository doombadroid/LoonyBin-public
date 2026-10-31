if !([false, "meth", 1] call life_fnc_handleInv) exitWith {};
life_drug_level = selectMin[life_drug_level + 0.2, 1];
if (life_meth_effect isEqualTo 0) then {life_meth_effect = time;
    [] spawn {life_fatigueEnabled = false;
        player setAnimSpeedCoef 1.15;
        player setFatigue 0;
        player enableFatigue false;
        waitUntil {uiSleep 0.75;
            !(alive player) || ((time - life_meth_effect) > (4.5 * 60))};
        player setAnimSpeedCoef 1;
        player enableFatigue true;
        life_meth_effect = 0;
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
        while {alive player && ((time - life_meth_effect) < (4 * 60))}
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
        life_meth_effect = 0;};} else {life_meth_effect = time;};
systemChat "You feel incredible!";
[] call life_fnc_hudUpdate;
["meth"] call life_fnc_drugUsed;