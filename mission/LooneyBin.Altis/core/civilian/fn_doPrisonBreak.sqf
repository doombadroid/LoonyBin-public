#include "..\..\macro.h"
if (scriptAvailable(5)) exitWith {["Please don't spam Prison Breaks!", "basic"] spawn life_fnc_handleMessage;};
params[["_target", objNull, [objNull]]];
if (life_action_in_use) exitWith {systemChat "You are already performing an action.";};
if !(playerSide isEqualTo civilian) exitWith {};
if ([] call life_fnc_activeFederalEvent) exitWith {
    ["There is already another Federal Event happening.", "basic"] spawn life_fnc_handleMessage;};
if !([(SRV_prisonData select 2)] call life_fnc_policeRequired) exitWith {};
if (player getVariable["plb_restrained", false] || player getVariable["plb_downed", false] || player getVariable["plb_arrested", false]) exitWith {};
private _prisonerCount = count(allPlayers select {side _x isEqualTo civilian && _x getVariable["plb_arrested", false]});
if (_prisonerCount isEqualTo 0) exitWith {["A prison break requires prisoners to be in the prison.", "basic"] spawn life_fnc_handleMessage;
};
if (serverTime - (SRV_prisonData select 0) < 1800) exitWith {
    ["This prison is on lockdown. Try again in a few minutes.", "basic"] spawn life_fnc_handleMessage;};
if ((currentWeapon player) in ["", "Binocular", "Rangefinder", "hgun_Pistol_Signal_F"]) exitWith {
    ["The prison guards will not be very intimidated by an unarmed civilian!", "basic"] spawn life_fnc_handleMessage;};
if (SRV_prisonData select 1) exitWith {["There is already a prison break in progress!", "basic"] spawn life_fnc_handleMessage;};
if ((player distance _target) > 10) exitWith {
    ["You need to stay near the laptop to complete the virus upload!", "basic"] spawn life_fnc_handleMessage;};
if !(isNull objectParent player) exitWith {};
if (SRV_lastRobbery > (serverTime - (60 * 15))) exitWith {
    [2, format["Security is high due to a recent robbery and you cannot start the prison break. Try again in %1 minute(s).", ceil((SRV_lastRobbery - (serverTime - (60 * 15))) / 60)]] call life_fnc_broadcast
};
life_action_in_use = true;
disableSerialization;
5 cutRsc["life_progress", "PLAIN"];
private _ui = uiNameSpace getVariable "life_progress";
private _success = false;
private _progress = _ui displayCtrl 38201;
private _pgText = _ui displayCtrl 38202;
_pgText ctrlSetText "Uploading Virus";
_progress progressSetPosition 0.01;
private _cP = 0.01;
for "_i"
from 0 to 1 step 0 do {if (random(100) >= 50) then {uiSleep 0.35;} else {uiSleep 0.25;};
    _cP = _cP + 0.01;
    _progress progressSetPosition _cP;
    _pgText ctrlSetText format["Uploading virus... (%1%2)", round(_cP * 100), "%"];
    if (_cp >= 1) exitWith {_success = true;};
    if (!alive player || player getVariable["plb_restrained", false] || player getVariable["plb_downed", false]) exitWith {};
    if ((player distance _target) > 10) exitWith {
        ["You need to stay near the laptop to complete the virus upload!", "basic"] spawn life_fnc_handleMessage;};
    if !(isNull objectParent player) exitWith {};
    if (SRV_prisonData select 1) exitWith {["There is already a prison break in progress!", "basic"] spawn life_fnc_handleMessage;};
}; 5 cutText["", "PLAIN"];
if !(_success) exitWith {life_action_in_use = false;};
if (SRV_prisonData select 1) exitWith {["There is already a prison break in progress!", "basic"] spawn life_fnc_handleMessage;
    life_action_in_use = false;};
if !([(SRV_prisonData select 2)] call life_fnc_policeRequired) exitWith {life_action_in_use = false;};
["The virus has been uploaded into the Prison security system and is infecting the network. The prisoners will be able to escape once the breach completes (~13 minutes). Keep the police away from the computer terminal!", "basic"] spawn life_fnc_handleMessage;
life_action_in_use = false;
if (SRV_prisonData select 1) exitWith {["There is already a prison break in progress!", "basic"] spawn life_fnc_handleMessage;};
[[14, player], "TON_fnc_wantedAdd", false, false] spawn life_fnc_MP;   // owner 2026-06-15 (#232): charge "Prison Break" (id 14) for STARTING the break -- was never applied
[[1, player, getPlayerUID player, group player], "TON_fnc_handlePrisonBreak", 2] spawn life_fnc_MP;
// owner 2026-06-23: STANDARD life_progress bar for the breach HOLD (was just a text message before). Same kind
// as repair/bulk processing (cutRsc "life_progress", ctrls 38201/38202, fixed-rate loop). Purely VISUAL -- it does
// NOT set life_action_in_use, so the breaker can still fight/reload; the server (TON_fnc_startPrisonBreak) stays
// authoritative for the actual breach. _holdTime MUST match that fn's _breakTimer (Altis 800 / Australia 600).
[_target] spawn {params ["_laptop"];
    private _holdTime = if (worldName == "Australia") then { 600 } else { 800 };
    disableSerialization;
    5 cutRsc ["life_progress", "PLAIN"];
    private _ui = uiNamespace getVariable "life_progress";
    private _progress = _ui displayCtrl 38201;
    private _pgText = _ui displayCtrl 38202;
    private _text = "Prison breach in progress";
    private _delay = _holdTime / 100;
    private _cP = 0;
    _progress progressSetPosition 0;
    _pgText ctrlSetText format ["%1 (0%2)...", _text, "%"];
    for "_i" from 0 to 1 step 0 do {uiSleep _delay;
        _cP = _cP + 0.01;
        _progress progressSetPosition _cP;
        _pgText ctrlSetText format ["%3 (%1%2)...", round (_cP * 100), "%", _text];
        if (_cP >= 1) exitWith {};
        if (!alive player || {player getVariable ["plb_restrained", false]} || {player getVariable ["plb_downed", false]}) exitWith {};
        if !(isNull objectParent player) exitWith {};                 // entered a vehicle
        if (!isNull _laptop && {(player distance2D _laptop) > 500}) exitWith {};   // walked >500m from the laptop (matches the server hold)
        if !(SRV_prisonData param [1, false]) exitWith {};            // breach completed, or a cop stopped it
    };
    5 cutText ["", "PLAIN"];};