params[["_target", player], ["_caller", player], ["_actionID", 0], ["_useExplosive", false]];
private _safe = cursorTarget;
if !(playerSide isEqualTo civilian) exitWith {};
if (!(life_fed_robbed select 0) && ((life_fed_robbed param[1, -1800]) > (serverTime - (60 * 60)))) exitWith {   // owner 2026-06-19: POST-robbery lockout only. Alarm arms life_fed_robbed[1] at robbery START; without the !active gate this blocked cracking the inner safe mid-heist. See fn_openVault.
    [2, format["Security is high due to a recent robbery and you cannot open this safe. Try again in %1 minute(s).", ceil(((life_fed_robbed param[1, -1800]) - (serverTime - (60 * 60))) / 60)]] call life_fnc_broadcast
};
if (_useExplosive && !(43 in life_side_talents)) exitWith {[2, "You are not talented enough to use explosives."] call life_fnc_broadcast};
if ((life_inv_demoCharge <= 0) && _useExplosive) exitWith {[2, "You need a demolition charge to do this."] call life_fnc_broadcast};
if !((vehicle player) isEqualTo player) exitWith {[2, "You cannot do this from within a vehicle."] call life_fnc_broadcast};
if (["fed"] call life_fnc_activeFederalEvent) exitWith {
    ["There is already another Federal Event happening.", "basic"] spawn life_fnc_handleMessage;};
if (!(life_fed_robbed select 0) && !([0, true] call life_fnc_policeRequired)) exitWith {};   // owner 2026-06-19: fed cop req 6->0 for beta (safe). Restore to 6 at public launch.
if (SRV_lastRobbery > (serverTime - (60 * 15))) exitWith {
    [2, format["Security is high due to a recent robbery and you cannot open this safe. Try again in %1 minute(s).", ceil((SRV_lastRobbery - (serverTime - (60 * 15))) / 60)]] call life_fnc_broadcast
};
private _nearbySafes = (nearestObjects[player, ["Land_Research_house_V1_F", "Land_Research_HQ_F"], 30]);
private _safe =
if ((count _nearbySafes) >= 1) then {_nearbySafes select 0} else {objNull};
if (isNull _safe || !((typeOf _safe) in ["Land_Research_house_V1_F", "Land_Research_HQ_F"])) exitWith {
    [2, "There is no safe nearby."] call life_fnc_broadcast};
if ((_safe getVariable["plb_vaultlocked", 1]) isEqualTo 0) exitWith {[2, "The safe is already unlocked."] call life_fnc_broadcast};
private _nearbyVaults = (nearestObjects[player, ["Land_Dome_Big_F", "Land_Dome_Small_F"], 30]);
private _vault =
if ((count _nearbyVaults) >= 1) then {_nearbyVaults select 0} else {objNull};
if (isNull _vault) exitWith {[2, "There is no vault nearby."] call life_fnc_broadcast};
if ((_vault getVariable["plb_vaultlocked", 1]) isEqualTo 1) exitWith {
    [2, "The vault needs to be unlocked before breaching the safe."] call life_fnc_broadcast};
private _selectionNames = (selectionNames _safe) select {(_x find "door") >= 0};
private _closestSafeDoor = _selectionNames select 0; {private _distance = player distance(_safe modelToWorld(_safe selectionPosition _x));
    if ((_distance) < (player distance(_safe modelToWorld(_safe selectionPosition _closestSafeDoor)))) then {_closestSafeDoor = _x};}
forEach _selectionNames;
private _closestSafeDoorPos = (_safe modelToWorld(_safe selectionPosition _closestSafeDoor));
if ((_useExplosive) && (life_inv_demoCharge <= 0)) exitWith {[2, "You need a demolition charge to do this."] call life_fnc_broadcast};
if ((player distance _closestSafeDoorPos) >= 3) exitWith {[2, "You are not close enough to the safe door."] call life_fnc_broadcast};
if (life_action_in_use) exitWith {};
life_action_in_use = true;
private _isSuccess = false;
if (!_useExplosive) then {
    // owner 2026-07-18: safe crack = Cyberdeck SEQUENCE BREACH (the "car hacking menu"), 6-slot buffer (diff 2)
    private _r = [6] call life_fnc_cyberdeckSeq;
    _isSuccess = (_r isEqualTo 1);
    if (_r isEqualTo 0) then { [2, "You failed to crack the safe security locks."] call life_fnc_broadcast; };
    life_action_in_use = false;};
if (_useExplosive) then {disableSerialization;
5 cutRsc["life_progress", "PLAIN"];
private _display = uiNameSpace getVariable["life_progress", displayNull];
private _progressBar = _display displayCtrl 38201;
private _progressText = _display displayCtrl 38202;
life_action_in_use = true;
private _increment = 1;
private _totalTime =
if !(_useExplosive) then {25   // LooneyBin fed rework v2: inner-building drill = 25s. Demo = 10s plant + grenade boom.
} else {10};
private _currentPoint = 0;
private _loopDelay = _totalTime / floor(100 / _increment);
private _text =
if !(_useExplosive) then {"Cracking safe security locks"} else {"Planting a demolition charge"};
private _startCount = 0;
_progressBar progressSetPosition _startCount;
_progressText ctrlSetText format["%1 (%2%3)", _text, _startCount, "%"];
private _duration =
if (_useExplosive) then {5.882} else {20};
private _animation =
if (_useExplosive) then {"AinvPknlMstpSnonWnonDnon_medic_1"} else {"AinvPknlMstpSnonWnonDnon_medic_1"};
[_animation, _duration] spawn life_fnc_handleAnim;
_isSuccess =
for "_i"
from 0 to 1 step 0 do {uiSleep _loopDelay;
    if (isNull _progressBar) exitWith {[2, "You have failed to hack the safe."] call life_fnc_broadcast;
        false};
    _currentPoint = (progressPosition _progressBar) + (_increment / 100);
    _progressBar progressSetPosition _currentPoint;
    _progressText ctrlSetText format["%1 (%2%3)", _text, round(_currentPoint * 100), "%"];
    if (_currentPoint >= 1) exitWith {true};
    if ((speed player) >= 2) exitWith {[2, "You have failed to hack the safe."] call life_fnc_broadcast;
        false};
    if !((vehicle player) isEqualTo player) exitWith {[2, "You have failed to hack the safe."] call life_fnc_broadcast;
        false};
    if ((!life_action_in_use) || (!alive player) || ((player distance _closestSafeDoorPos) >= 3)) exitWith {
        [2, "You have failed to hack the safe."] call life_fnc_broadcast;
        false};
    if (player getVariable["plb_downed", false] || player getVariable["plb_restrained", false]) exitWith {
        [2, "You have failed to hack the safe."] call life_fnc_broadcast;
        false};
    if (["fed"] call life_fnc_activeFederalEvent) exitWith {
        ["There is already another Federal Event happening.", "basic"] spawn life_fnc_handleMessage;
        false};
    false;}; life_action_in_use = false;
[] spawn life_fnc_handleAnim;
5 cutText["", "PLAIN"];};
if (_isSuccess) then {if (_useExplosive) then {[false, "demoCharge", 1] call life_fnc_handleInv;
        private _toSend = (allPlayers - [allDeadMen]) select {(_x distance player) <= 30};
        [2, "Blasting charge activated, move away from the door."] call life_fnc_broadcast; [
            [player, "bombarm"], "life_fnc_playSound", _toSend, false, false] spawn life_fnc_MP;
        uiSleep 2.5;
        private _demoChargeClass = "GrenadeHand";
        private _maxTime = serverTime + 6;
        private _demoCharge = _demoChargeClass createVehicle _closestSafeDoorPos;
        private _plb_pos = _closestSafeDoorPos;
        while {(!isNull _demoCharge) && (serverTime < _maxTime)}
        do {_demoCharge setPos _plb_pos;
            uiSleep 0.01}; { _safe animate[_x, 0.2]}
        forEach((animationNames _safe) select {(_x find _closestSafeDoor) >= 0});};
    private _doorCount = getNumber(configFile >> "CfgVehicles" >> (typeOf _safe) >> "numberOfDoors");
    for "_i"
    from 1 to _doorCount do {_safe setVariable[format["bis_disabled_door_%1", _i], 0, true]
    }; _safe setVariable["plb_vaultlocked", 0, true];
    life_side_exp = life_side_exp + 25;
    [2, "The safe doors have been breached, and are now unlocked."] call life_fnc_broadcast;
    ["fedsafeopened", 1] call life_fnc_statArrUpdate;
    if !(life_fed_robbed select 0) then {[[player], "TON_fnc_fedRobbery", 2] spawn life_fnc_MP;};};