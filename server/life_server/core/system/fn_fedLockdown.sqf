/*
    PLB_fnc_fedLockdown  (LooneyBin -- re-lock the Federal Reserve to a clean, robbable state)
    owner 2026-06-16 (#312 "won't let us open domes"): a stuck / half-finished fed robbery left domes in a
    DEADLOCK -- plb_vaultlocked=0 (so fn_openVault refuses with "already unlocked") while the doors stayed
    disabled+shut (so they won't open). Re-running the lockdown puts every dome/safe back to
    plb_vaultlocked=1 + doors disabled+shut (breakable fresh) and re-arms the gold spawn.
    Mirrors the boot lockdown core in life_server\init.sqf (kept inline there on purpose -- live-safety; if
    you change the lock rules, change BOTH). Idempotent. Called by PLB_fnc_resetFed.
*/
private _fed = getMarkerPos "fed_reserve";
if (_fed isEqualTo [0,0,0]) exitWith { diag_log "[LooneyBin][fed] fedLockdown: fed_reserve marker missing -- skipped"; false };

private _domes = nearestObjects [_fed, ["Land_Dome_Big_F", "Land_Dome_Small_F"], 400]; {private _d = _x;
    private _n = getNumber (configFile >> "CfgVehicles" >> (typeOf _d) >> "numberOfDoors");
    for "_i" from 1 to _n do { _d setVariable [format ["bis_disabled_door_%1", _i], 1, true]; };
    { _d animate [_x, 0, true]; } forEach (animationNames _d);
    _d setVariable ["plb_vaultlocked", 1, true];
    _d setVariable ["plb_goldSpawned", false, true];   // re-arm fedGoldSpawn for the next breach
} forEach _domes;
missionNamespace setVariable ["PLB_fedComponentSpawned", false, true];   // re-arm the mining-component drop

private _safes = nearestObjects [_fed, ["Land_Research_house_V1_F", "Land_Research_HQ_F"], 400]; {private _s = _x;
    private _n = getNumber (configFile >> "CfgVehicles" >> (typeOf _s) >> "numberOfDoors");
    for "_i" from 1 to _n do { _s setVariable [format ["bis_disabled_door_%1", _i], 1, true]; };
    { _s animate [_x, 0, true]; } forEach (animationNames _s);
    _s setVariable ["plb_vaultlocked", 1, true];} forEach _safes;

private _gates = nearestObjects [_fed, ["Land_BarGate_F"], 400]; {_x setVariable ["gate_max", 0, true];
    _x setVariable ["bis_disabled_Door_1", 1, true];
    _x animateSource ["door_1_sound_source", 0];} forEach _gates;

// keep fn_fedAlarm's legacy relock targets current
life_bank_gates  = _gates;
life_bank_vaults = _domes;
life_bank_safes  = _safes;

diag_log format ["[LooneyBin][fed] fedLockdown: re-locked %1 dome(s), %2 safe(s), %3 gate(s)", count _domes, count _safes, count _gates];
true
