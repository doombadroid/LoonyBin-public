params[["_pain", 0, [0]]];
life_pain = _pain;
if (_pain > 0) then {player setVariable["plb_pain", _pain, true];
    systemChat "You are in pain";
    profileNamespace setVariable["plb_pain", _pain];
    _pain spawn {private _pain = _this;
        while {true}
        do {if !(_pain isEqualTo life_pain) exitWith {};
            resetCamShake;
            addCamShake[1, 2, _pain * 10];
            uiSleep 3.5;};};} else {if (player getVariable["plb_pain", -1] > 0) then {player setVariable["plb_pain", nil, true];
        profileNamespace setVariable["plb_pain", _pain];};};