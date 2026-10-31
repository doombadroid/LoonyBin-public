params[["_target", objNull, [objNull]]];
if !(playerSide isEqualTo west) exitWith {};
if !(SRV_prisonData select 1) exitWith {["There is no prison break to stop!", "basic"] spawn life_fnc_handleMessage;};
if !(isNull objectParent player) exitWith {};
if ((player distance _target) > 12) exitWith {
    ["You need to stay near the laptop to finish restoring the security system!", "basic"] spawn life_fnc_handleMessage;};
if (player getVariable["plb_restrained", false] || player getVariable["plb_downed", false]) exitWith {};
disableSerialization;
5 cutRsc["life_progress", "PLAIN"];
private _ui = uiNameSpace getVariable "life_progress";
private _success = false;
private _progress = _ui displayCtrl 38201;
private _pgText = _ui displayCtrl 38202;
_pgText ctrlSetText "Restoring Security System";
_progress progressSetPosition 0.01;
private _cP = 0.01;
for "_i"
from 0 to 1 step 0 do {uiSleep 0.3;
    _cP = _cP + 0.01;
    _progress progressSetPosition _cP;
    _pgText ctrlSetText format["Restoring Security System... (%1%2)", round(_cP * 100), "%"];
    if (_cp >= 1) exitWith {_success = true};
    if (!alive player || player getVariable["plb_restrained", false] || player getVariable["plb_downed", false]) exitWith {};
    if ((player distance _target) > 12) exitWith {
        ["You need to stay near the laptop to finish restoring the security system!", "basic"] spawn life_fnc_handleMessage;};
    if !(SRV_prisonData select 1) exitWith {["There is no prison break to stop!", "basic"] spawn life_fnc_handleMessage;};
}; 5 cutText["", "PLAIN"];
if !(_success) exitWith {};
if !(SRV_prisonData select 1) exitwith {["There is no prison break to stop!", "basic"] spawn life_fnc_handleMessage;};
["You have restored the security system to the Prison!", "basic"] spawn life_fnc_handleMessage; [
    [2, player, getPlayerUID player], "TON_fnc_handlePrisonBreak", 2] spawn life_fnc_MP;
["action", "stopprison", 1] spawn life_fnc_handleQuest;