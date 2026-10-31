if !(playerSide in [civilian, west]) exitWith {};
if !((vehicle player) isEqualTo player) exitWith {titleText["You cannot do this from within a vehicle.", "PLAIN"]};
if (!(life_fed_robbed select 0) && ((life_fed_robbed param[1, -1800]) > (serverTime - (60 * 60)))) exitWith {   // owner 2026-06-19: POST-robbery lockout only. Alarm arms life_fed_robbed[1] at robbery START; without the !active gate this blocked re-cutting gates mid-heist. See fn_openVault.
    [2, format["Security is high due to a recent robbery and you cannot open this gate. Try again in %1 minute(s).", ceil(((life_fed_robbed param[1, -1800]) - (serverTime - (60 * 60))) / 60)]] call life_fnc_broadcast
};
if (!(life_fed_robbed select 0) && (playerSide isEqualTo west)) exitWith {
    [2, "You cannot unlock the gate when there is no robbery in progress."] call life_fnc_broadcast};
if ((life_inv_boltcutter <= 0) && (playerSide isEqualTo civilian)) exitWith {
    [2, "You need a boltcutter to do this."] call life_fnc_broadcast};
if (["fed"] call life_fnc_activeFederalEvent) exitWith {
    ["There is already another Federal Event happening.", "basic"] spawn life_fnc_handleMessage;};
if (!(life_fed_robbed select 0) && !([0, true] call life_fnc_policeRequired) && (playerSide isEqualTo civilian)) exitWith {};   // owner 2026-06-19: fed cop req 6->0 for beta (gate). Restore to 6 at public launch.
if (SRV_lastRobbery > (serverTime - (60 * 15))) exitWith {
    [2, format["Security is high due to a recent robbery and you cannot open this gate. Try again in %1 minute(s).", ceil((SRV_lastRobbery - (serverTime - (60 * 15))) / 60)]] call life_fnc_broadcast
};
private _nearbyGates = (nearestObjects[player, ["Land_BarGate_F"], 10]);
private _gate =
if ((count _nearbyGates) >= 1) then {_nearbyGates select 0} else {objNull};
if (isNull _gate) exitWith {titleText["There is no gate nearby.", "PLAIN"];};
if ((_gate getVariable["gate_max", 0]) isEqualTo 1) exitWith {[2, "The gate is already completely unlocked."] call life_fnc_broadcast};
if (life_action_in_use) exitWith {};
life_action_in_use = true;
disableSerialization;
5 cutRsc["life_progress", "PLAIN"];
private _display = uiNameSpace getVariable["life_progress", displayNull];
private _progressBar = _display displayCtrl 38201;
private _progressText = _display displayCtrl 38202;
life_action_in_use = true;
private _increment = 1;
private _totalTime =
if (playerSide isEqualTo west) then {   // LooneyBin fed rework 2026-06-09: flat 30s per gate for robbers (was 15s / 5s with talents); cops unlocking during a robbery stay quick
    10} else {30};
private _currentPoint = 0;
private _loopDelay = _totalTime / floor(100 / _increment);
private _text =
if (playerSide isEqualTo civilian) then {"Bolt cutting federal reserve gate"} else {"Unlocking federal reserve gate"};
private _startCount = 0;
_progressBar progressSetPosition _startCount;
_progressText ctrlSetText format["%1 (%2%3)", _text, _startCount, "%"];
private _duration = 5.882;
private _animation = "AinvPknlMstpSnonWnonDnon_medic_1";
[_animation, _duration] spawn life_fnc_handleAnim;
private _isSuccess =
for "_i"
from 0 to 1 step 0 do {uiSleep _loopDelay;
    if (isNull _progressBar) exitWith {[2, "You have failed to bolt cut the gate."] call life_fnc_broadcast;
        false};
    _currentPoint = (progressPosition _progressBar) + (_increment / 100);
    _progressBar progressSetPosition _currentPoint;
    _progressText ctrlSetText format["%1 (%2%3)", _text, round(_currentPoint * 100), "%"];
    if (_currentPoint >= 1) exitWith {true};
    if !((vehicle player) isEqualTo player) exitWith {[2, "You have failed to bolt cut the gate."] call life_fnc_broadcast;
        false};
    if (player getVariable["plb_downed", false] || player getVariable["plb_restrained", false]) exitWith {
        [2, "You have failed to bolt cut the gate."] call life_fnc_broadcast;
        false};
    if ((!life_action_in_use) || (!alive player) || ((player distance _gate) > 7)) exitWith {
        [2, "You have failed to bolt cut the gate."] call life_fnc_broadcast;
        false};
    if (["fed"] call life_fnc_activeFederalEvent) exitWith {
        ["There is already another Federal Event happening.", "basic"] spawn life_fnc_handleMessage;
        false};
    false;}; life_action_in_use = false;
[] spawn life_fnc_handleAnim;
5 cutText["", "PLAIN"];
if (_isSuccess) then {["boltcut", 1] call life_fnc_statArrUpdate;
    if (playerSide isEqualTo civilian) then { [false, "boltCutter", 1] call life_fnc_handleInv; };   // LooneyBin fed rework: bolt cutting USES UP the cutter
    private _max =
    if (40 in life_side_talents || playerSide isEqualTo west) then {1} else {0.25};
    _max =
    if ((_gate getVariable["gate_max", 0]) isEqualTo 0.25) then {1} else {_max};
    _gate setVariable["gate_max", _max, true];
    _gate setVariable["bis_disabled_Door_1", 0, true];   // LooneyBin fed v3: re-enable the engine open action (lockdown disables it)
    [2, "The gate is now unlocked."] call life_fnc_broadcast;
    _gate animateSource["door_1_sound_source", _gate getVariable["gate_max", 1]];
    if (!(life_fed_robbed select 0) && (playerSide isEqualTo civilian)) then {private _chance =
        if (43 in life_side_talents) then {3} else {1};
        if ((ceil(random _chance)) isEqualTo 1) then {[[player], "TON_fnc_fedRobbery", 2] spawn life_fnc_MP;};};};