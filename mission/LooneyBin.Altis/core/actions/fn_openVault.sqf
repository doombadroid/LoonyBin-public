if !(playerSide isEqualTo civilian) exitWith {};
private _plb_trace = { [["-FEDTRACE-", player, _this select 0], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP; };   // via the rebuilt logIt: client remoteExec of raw COMMANDS (diag_log) is blocked under CfgRE mode=1

if (!(call PLB_fnc_hasDeck)) exitWith {["reject: no cyberdeck"] call _plb_trace;
    [2, "You need a Cyberdeck to breach the pylons."] call life_fnc_broadcast};
if (!isNil "plb_fedHackCooldown" && {plb_fedHackCooldown > serverTime}) exitWith {
    [2, format ["Your deck is still cooling down -- %1s left before you can hit this dome again.", ceil (plb_fedHackCooldown - serverTime)]] call life_fnc_broadcast
};
if (!(life_fed_robbed select 0) && ((life_fed_robbed param[1, -1800]) > (serverTime - (60 * 60)))) exitWith {   // owner 2026-06-19: only a POST-robbery lockout. The alarm sets life_fed_robbed=[true,serverTime] at robbery START, which armed this 60-min cooldown mid-heist and blocked drilling the OTHER domes. Gate on !active so an in-progress robbery isn't blocked; after the end-detector flips select 0 false, the lockout applies off the END timestamp.
    [2, format["Security is high due to a recent robbery and you cannot open this vault. Try again in %1 minute(s).", ceil(((life_fed_robbed param[1, -1800]) - (serverTime - (60 * 60))) / 60)]] call life_fnc_broadcast
};
if !((vehicle player) isEqualTo player) exitWith {[2, "You cannot do this from within a vehicle."] call life_fnc_broadcast};
if (["fed"] call life_fnc_activeFederalEvent) exitWith {["reject: another federal event active"] call _plb_trace;
    ["There is already another Federal Event happening.", "basic"] spawn life_fnc_handleMessage;};
if (!(life_fed_robbed select 0) && !([0, true] call life_fnc_policeRequired)) exitWith {   // owner 2026-06-19: fed cop req 6->0 for beta (dome). Restore to 6 at public launch.
    ["reject: policeRequired gate"] call _plb_trace;};
if (SRV_lastRobbery > (serverTime - (60 * 15))) exitWith {
    [2, format["Security is high due to a recent robbery and you cannot open this vault. Try again in %1 minute(s).", ceil((SRV_lastRobbery - (serverTime - (60 * 15))) / 60)]] call life_fnc_broadcast
};
private _nearbyVaults = (nearestObjects[player, ["Land_Dome_Big_F", "Land_Dome_Small_F"], 30]);
private _vault =
if ((count _nearbyVaults) >= 1) then {_nearbyVaults select 0} else {objNull};
if (isNull _vault) exitWith {[2, "There is no vault nearby."] call life_fnc_broadcast};
if ((_vault getVariable["plb_vaultlocked", 1]) isEqualTo 0) exitWith {[2, "The vault is already unlocked."] call life_fnc_broadcast};
private _selectionNames = selectionNames _vault;
private _closestVaultDoor = _selectionNames select 0; {
    private _distance = player distance(_vault modelToWorld(_vault selectionPosition _x));
    if ((_distance) < (player distance(_vault modelToWorld(_vault selectionPosition _closestVaultDoor)))) then {_closestVaultDoor = _x};}
forEach _selectionNames;
private _closestVaultDoorPos = (_vault modelToWorld(_vault selectionPosition _closestVaultDoor));
if !(_closestVaultDoor in ["door_1a", "door_1b", "door_2a", "door_2b"]) exitWith {
    [format ["reject: wrong panel (%1)", _closestVaultDoor]] call _plb_trace;
    [2, "You must hack the vault from the electrical panel near the side door."] call life_fnc_broadcast};
if ((player distance _closestVaultDoorPos) >= 4) exitWith {[2, "You are not close enough to the electrical panel."] call life_fnc_broadcast
};
if (life_action_in_use) exitWith { ["reject: action in use"] call _plb_trace; };
["fed hack STARTED (Cyberdeck)"] call _plb_trace;
life_action_in_use = true;

// STEP 1 -- Terminal Breach root uplink (9 commands, hard)
private _root = [3] call life_fnc_cyberdeckTerm;
if !(_root isEqualTo 1) exitWith {life_action_in_use = false;
    5 cutText["", "PLAIN"];
    if (_root isEqualTo 0) then {private _cd = 120;   // owner 2026-07-20: Cooldown Bypass talent (253) removed with the Hacker tree
        plb_fedHackCooldown = serverTime + _cd;
        [2, format ["The trace locked your deck out. Wait %1s before trying this dome again.", _cd]] call life_fnc_broadcast;
        ["fed hack FAIL: trace"] call _plb_trace;};};

// APD alerted the moment root lands -- unless a Proxy Chain is armed, which suppresses it and is consumed.
// (owner 2026-07-20: Ghost Protocol talent 254 removed with the Hacker tree; Proxy Chain is the replacement.)
// ICE TRACE decides server-side whether this is quiet (burns an armed Proxy Chain) and fires the
// robbery event itself when it isn't -- one authority for every hack instead of a client-side check.
[[player, "FED BREACH", getPosATL player, true], "TON_fnc_iceTrace", 2] spawn life_fnc_MP;

// STEP 2 -- PYLON DISARM: hold position at the panel until the bar fills
disableSerialization;
5 cutRsc["life_progress", "PLAIN"];
private _display = uiNameSpace getVariable["life_progress", displayNull];
private _progressBar = _display displayCtrl 38201;
private _progressText = _display displayCtrl 38202;
life_action_in_use = true;
private _increment = 1;
private _totalTime = if (1 in (player getVariable ["plb_cdMods", []])) then { 96 } else { 120 };   // 2-min pylon disarm hold; Overclock Module -20%
private _currentPoint = 0;
private _loopDelay = _totalTime / floor(100 / _increment);
private _text = "HACK UPLOADED -- PYLONS DISARMING, STAND BY";
private _startCount = 0;
_progressBar progressSetPosition _startCount;
_progressText ctrlSetText format["%1 (%2%3)", _text, _startCount, "%"];
private _duration = 20;
private _animation = "AinvPknlMstpSnonWnonDnon_medic_1";
[_animation, _duration] spawn life_fnc_handleAnim;
private _isSuccess =
for "_i"
from 0 to 1 step 0 do {uiSleep _loopDelay;
    if (isNull _progressBar) exitWith {[2, "You have failed to hack the vault."] call life_fnc_broadcast;
        false};
    _currentPoint = (progressPosition _progressBar) + (_increment / 100);
    _progressBar progressSetPosition _currentPoint;
    _progressText ctrlSetText format["%1 (%2%3)", _text, round(_currentPoint * 100), "%"];
    if (_currentPoint >= 1) exitWith {true};
    if ((speed player) >= 2) exitWith {["bar FAIL: moved (speed)"] call _plb_trace;
        [2, "You have failed to hack the vault."] call life_fnc_broadcast;
        false};
    if !((vehicle player) isEqualTo player) exitWith {["bar FAIL: entered vehicle"] call _plb_trace;
        [2, "You have failed to hack the vault."] call life_fnc_broadcast;
        false};
    if (player getVariable["plb_downed", false] || player getVariable["plb_restrained", false]) exitWith {
        ["bar FAIL: downed/restrained"] call _plb_trace;
        [2, "You have failed to hack the vault."] call life_fnc_broadcast;
        false};
    if ((!life_action_in_use) || (!alive player) || ((player distance _closestVaultDoorPos) >= 4)) exitWith {
        [format ["bar FAIL: actionInUse=%1 alive=%2 dist=%3", life_action_in_use, alive player, player distance _closestVaultDoorPos] ] call _plb_trace;
        [2, "You have failed to hack the vault."] call life_fnc_broadcast;
        false};
    if (["fed"] call life_fnc_activeFederalEvent) exitWith {["bar FAIL: another federal event went active mid-bar"] call _plb_trace;
        ["There is already another Federal Event happening.", "basic"] spawn life_fnc_handleMessage;
        false};
    false;}; life_action_in_use = false;
[] spawn life_fnc_handleAnim;
5 cutText["", "PLAIN"];
if (!_isSuccess) exitWith {private _cd = 120;   // owner 2026-07-20: Cooldown Bypass talent (253) removed with the Hacker tree
    plb_fedHackCooldown = serverTime + _cd;
    [2, "The uplink dropped -- pylons re-armed. Your deck is locked out for a bit."] call life_fnc_broadcast;
    ["fed pylon disarm FAILED (moved/left range/downed)"] call _plb_trace;};
if (_isSuccess) then {["break-in SUCCESS"] call _plb_trace;
    [["fed", player], "TON_fnc_qhLootSRV", 2] spawn life_fnc_MP;   // deck-loot roll (server-side, throttled)
    private _doorCount = getNumber(configFile >> "CfgVehicles" >> (typeOf _vault) >> "numberOfDoors");
    for "_i"
    from 1 to _doorCount do {_vault setVariable[format["bis_disabled_door_%1", _i], 0, true]
    }; _vault setVariable["plb_vaultlocked", 0, true];
    life_side_exp = life_side_exp + 50;
    [2, "You broke in through the side door. The vault doors (including the vehicle door) are now unlocked."] call life_fnc_broadcast;
    // LooneyBin fed rework: swing open ONLY the small side doors (door_1/door_2 anims). The big vehicle
    // door (door_3+) is UNLOCKED above -- "allowed to be opened" -- but stays shut until someone opens it.
    {_vault animate[_x, 1, false]}
    forEach((animationNames _vault) select {private _a = toLower _x;
        ((_a find "door_1") >= 0 || (_a find "door_2") >= 0) && {(_a find "locked") isEqualTo - 1}});
    [[_vault], "TON_fnc_fedGoldSpawn", 2] spawn life_fnc_MP;   // LooneyBin fed rework: 1-5 gold bars per briefcase in this dome's inner buildings
    [["-FED-", player, profileName, format ["broke into dome %1 at %2", typeOf _vault, getPosATL _vault]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
    // (alarm now fires at hack START -- see STEP 1, so cops get the full 2-minute disarm window to respond)
    // (old immediate conditional alarm removed -- replaced by the unconditional 10s-delayed alarm above)
};