#include "..\..\macro.h"
if (scriptAvailable(3)) exitWith {["Wait a bit before attempting to revive again!", "basic"] spawn life_fnc_handleMessage;};
private _target = cursorObject;
if (isNull _target || !(_target isKindOf "CAManBase") || life_action_in_use) exitWith {};
private _revivable = _target getVariable["plb_revivable", false] || ((_target getVariable["plb_group", grpNull] isEqualTo group player) && !(isNull(_target getVariable["plb_group", grpNull])));
if !(_revivable) exitWith {};
if (_target getVariable["plb_reviving", player] != player) exitWith {
    ["Someone else is already reviving this person", "basic"] spawn life_fnc_handleMessage;};
if (player distance _target > 5 || !(isNull objectParent player)) exitWith {};
if (isWeaponDeployed player) then {player playMove "";};
if (time < (player getVariable["plb_next_revive", -1000])) exitWith {
    [format["You cannot revive someone so soon after being revived yourself. You must wait %1 seconds.", round((player getVariable["plb_next_revive", -1000]) - time)], "basic"] spawn life_fnc_handleMessage;
};
if (playerSide isEqualTo civilian && (time < (profileNamespace getVariable["plb_recent_revive", [0, 0]] select 1))) exitWith {
    [format["You have recently revived someone! Your defibrillators need time to recharge! They should be ready in %1 seconds.", (profileNamespace getVariable["plb_recent_revive", [0, 0]] select 1) - time], "basic"] spawn life_fnc_handleMessage;
};
if (time < (_target getVariable["plb_next_revive", -1000]) && !(call life_medicLevel >= 5 || (call life_copLevel >= 6 && life_coprole in ["all", "medic"] && 22 in life_cop_talents))) exitWith {
    [format["The victim was recently revived and cannot be revived again for %1 seconds.", (_target getVariable["plb_next_revive", -1000]) - time], "basic"] spawn life_fnc_handleMessage;
};
private _targetName = _target getVariable["plb_name", "Unknown"];
private _text = format["Reviving %1", _targetName];
life_action_in_use = true;
_target setVariable["plb_reviving", player, true];
disableSerialization;
5 cutRsc["life_progress", "PLAIN"];
private _ui = uiNamespace getVariable "life_progress";
private _progress = _ui displayCtrl 38201;
private _pgText = _ui displayCtrl 38202;
_pgText ctrlSetText format["%2 (1%1)...", "%", _text];
_progress progressSetPosition 0.01;
private _cP = 0.01;
private _success = false;
private _sleep =
switch (true) do {case (120 in life_side_talents && call(life_medicLevel) >= 4): {0.1};
    case (playerSide isEqualTo independent): {0.15};
    case (life_coprole in ["all", "medic"] && {18 in life_cop_talents}): {0.15};
    case (life_coprole in ["all", "detective"] && {33 in life_cop_talents}): {0.15};
    default {0.2};}; if (playerSide isEqualTo civilian && 458 in life_completedLifetimeQuests) then {_sleep = _sleep * 0.85;};
if (14 in life_infamy_talents && license_civ_rebel) then {_sleep = _sleep * 0.85;};
["AinvPknlMstpSnonWnonDr_medic0", 9] spawn life_fnc_handleAnim;
for "_i"
from 0 to 1 step 0 do {uiSleep _sleep;
    _cP = _cP + 0.01;
    _progress progressSetPosition _cP;
    _pgText ctrlSetText format["%3 (%1%2)...", round(_cP * 100), "%", _text];
    _revivable = _target getVariable["plb_revivable", false] || ((_target getVariable["plb_group", grpNull] isEqualTo group player) && !(isNull(_target getVariable["plb_group", grpNull])));
    if (life_isDowned || !(alive player) || !(life_action_in_use) || isWeaponDeployed player) exitWith {};
    if (player getVariable["plb_restrained", false]) exitWith {};
    if (player distance _target > 4 || isNull _target) exitWith {};
    if !(_revivable) exitWith {};
    if (isNull(_target getVariable["plb_reviving", objNull])) exitWith {
        ["This person can no longer be saved", "basic"] spawn life_fnc_handleMessage;};
    if (_target getVariable["plb_reviving", objNull] != player) exitWith {
        ["Someone else is already reviving this person.", "basic"] spawn life_fnc_handleMessage;};
    if (_cP >= 1) exitWith {_success = true;};}; 5 cutText["", "PLAIN"];
life_action_in_use = false;
_target setVariable["plb_reviving", nil, true];
if !(_success) exitWith {private _anim =
    switch (true) do {case (currentWeapon player isEqualTo ""): {"amovpknlmstpsnonwnondnon"};
        case (currentWeapon player isKindOf["Rifle", configFile >> "CfgWeapons"]): {"amovpknlmstpsraswrfldnon"};
        default {"amovpknlmstpsraswpstdnon"};}; player switchMove _anim;
    player setVariable["plb_inAnim", false];};
[] spawn life_fnc_handleAnim;
private _nextRevive =
if (121 in life_side_talents) then {time + 60} else {time + 240};
private _defibChargeTime =
switch (true) do {case (playerSide isEqualTo independent): {300};
    case (life_coprole in ["all", "medic"] && {19 in life_cop_talents}): {240};
    case (15 in life_infamy_talents && license_civ_rebel): {240};
    default {360};}; profileNameSpace setVariable["plb_recent_revive", [PLB_instance_id, time + _defibChargeTime]];
if (isNull(life_medicAcceptedCorpse param[1, objNull])) then {private _reviveReward =
    if ((_target getVariable["plb_faction", civilian] isEqualTo independent) && playerSide isEqualTo independent) then {
        (call life_revive_fee)} else {(call life_revive_fee) + 1000};
    if (playerSide isEqualTo west) then {_reviveReward = (call life_revive_fee);};
    if (playerSide isNotEqualTo independent) then {life_atmcash = life_atmcash + _reviveReward;
        life_atmcashCacheB = ((life_atmcash / 4) + 11);
        titleText[format["You have revived %1 and received $%2 for rendering aid.", _targetName, [_reviveReward] call life_fnc_numberText], "PLAIN"];
    } else {private _partners = [];
        if !(life_medPartners isEqualTo[]) then {_partners = [7, objNull] call life_fnc_medicPartners;};
        if (_partners isEqualTo[]) then {life_atmcash = life_atmcash + _reviveReward;
            life_atmcashCacheB = ((life_atmcash / 4) + 11);
            titleText[format["You have revived %1 and received $%2 for rendering aid.", _targetName, [_reviveReward] call life_fnc_numberText], "PLAIN"];
        } else {_reviveReward = round(_reviveReward / ((count _partners) + 1));
            life_atmcash = life_atmcash + _reviveReward;
            life_atmcashCacheB = ((life_atmcash / 4) + 11);
            titleText[format["You have revived %1 and received $%2 for rendering aid.", _targetName, [_reviveReward] call life_fnc_numberText], "PLAIN"];
            [[_partners, _reviveReward], "TON_fnc_medicSplit", 2] spawn life_fnc_MP; [
                [format["You have received %1 for a revive performed by %2.", [_reviveReward] call life_fnc_numberText, profileName]], "life_fnc_handleMessage", _partners] call life_fnc_MP;
        };};
    private _xpReward =
    if (playerSide isEqualTo independent) then {50} else {30};
    life_side_exp = life_side_exp + _xpReward;
    [1] call life_fnc_ClupdatePartial;
    // LooneyBin: NG prestige points — medics earn them per revive (spend in the AEMT prestige menu)
    if (playerSide isEqualTo independent) then {
        250 call life_fnc_medicEarn;   // owner 2026-06-13 (#158): route through medicEarn so it notifies (was a silent +250)
    };}; [[player, false, false, false, _nextRevive], "life_fnc_revived", _target] spawn life_fnc_MP;
if (_target getVariable["plb_lowtime", false]) then {life_newPlyrRev = life_newPlyrRev + 1;};
uiSleep 0.6;
player reveal _target;
_target setVariable["plb_requestAcceptor", [objNull, ""], true];
if (playerSide isEqualTo west && life_coprole in ["all", "medic", "detective"]) then {[500] spawn life_fnc_earnPrestige};
["defibs", 1] call life_fnc_statArrUpdate;
switch (playerSide) do {case civilian: {A_stats_civRevives = A_stats_civRevives + 1};
    case independent: {A_stats_medRevives = A_stats_medRevives + 1;};
    default {};};
["revived", "player", 1 ] spawn life_fnc_handleQuest;
if (side _target == west) then {["revived", "cop", 1] spawn life_fnc_handleQuest;};
if (side _target == civilian) then {["revived", "civilian", 1] spawn life_fnc_handleQuest;};
