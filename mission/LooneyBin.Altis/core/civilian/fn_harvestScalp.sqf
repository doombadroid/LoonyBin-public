params[["_unit", objNull, [objNull]]];
if (isNull _unit || !(playerSide isEqualTo civilian) || !(_unit isKindOf "CAManBase") || alive _unit) exitWith {};
if (player distance _unit > 2.5) exitWith {};
if (((player distance(getMarkerPos "city") < 1000) || (player distance(getMarkerPos "civ_spawn_3") < 500) || (player distance(getMarkerPos "civ_spawn_4") < 500) || (player distance(getMarkerPos "civ_spawn_2") < 500)) && !((player distance(getMarkerPos "execute_exempt_01") < 4) || (player distance(getMarkerPos "execute_exempt_02") < 5) || (player distance(getMarkerPos "execute_exempt_03") < 4) || (player distance(getMarkerPos "execute_exempt_04") < 3) || (player distance(getMarkerPos "bankMarker") < 250))) exitWith {
    ["You cannot execute someone so close to a populated area.", "basic"] spawn life_fnc_handleMessage;};
if !(life_inv_skinningknife >= 1) exitWith {["You need a skinning knife to harvest someones scalp.", "basic"] spawn life_fnc_handleMessage;
};
if (_unit getVariable["plb_executing", player] != player) exitWith {
    ["Someone else is already executing this person!", "basic"] spawn life_fnc_handleMessage;};
if (time < (profileNamespace getVariable["plb_recent_scalp", [0, 0]] select 1)) exitWith {
    [format["You can only someones scalp every 15 minutes! %1 minutes remaining.", ceil(((profileNamespace getVariable["plb_recent_scalp", [0, 0, ""]] select 1) - time) / 60)], "basic"] spawn life_fnc_handleMessage;
};
if !((profileNamespace getVariable["plb_recent_scalp", [0, 0, ""]] select 2) isEqualTo "") exitWith {
    ["You must sell the scalp you already have!", "basic"] spawn life_fnc_handleMessage;};
private _checkDebugPlayer = allPlayers param[allPlayers findIf {(_unit getVariable["plb_steamid", ""]) isEqualTo(getPlayerUID _x)
}, objNull];
if (!(_checkDebugPlayer distance(getMarkerPos "respawn_west") < 1000) || (isNull _checkDebugPlayer)) exitWith {};
private _targetName = _unit getVariable["plb_name", "Unknown"];
_unit setVariable["plb_executing", player, true];
disableSerialization;
5 cutRsc["life_progress", "PLAIN"];
private _text = format["Scalping %1's Head", _targetName];
private _ui = uiNamespace getVariable "life_progress";
private _progress = _ui displayCtrl 38201;
private _pgText = _ui displayCtrl 38202;
_pgText ctrlSetText format["%2 (1%1)...", "%", _text];
_progress progressSetPosition 0.01;
private _cP = 0.01;
private _success = false;
life_action_in_use = true;
player playMoveNow "AinvPknlMstpSnonWnonDnon_medic1";
systemChat _text;
for "_i"
from 0 to 1 step 0 do {uiSleep 0.038;
    _cP = _cP + 0.01;
    _progress progressSetPosition _cP;
    _pgText ctrlSetText format["%3 (%1%2)...", round(_cP * 100), "%", _text];
    if (isNull _unit) exitWith {};
    if (alive _unit) exitWith {};
    if (player getVariable["plb_downed", false] || player getVariable["plb_restrained", false]) exitWith {};
    if !(isNull(_unit getVariable["plb_reviving", objNull])) exitWith {};
    if (isWeaponDeployed player) exitWith {};
    if (player distance _unit > 3) exitWith {};
    if (!life_action_in_use) exitWith {};
    if (isNull(_unit getVariable["plb_executing", objNull])) exitWith {
        ["This person can no longer be executed", "basic"] spawn life_fnc_handleMessage;};
    if (_unit getVariable["plb_executing", objNull] != player) exitWith {
        ["Someone else is already executing this person.", "basic"] spawn life_fnc_handleMessage;};
    if (_cP >= 1) exitWith {_success = true;};}; 5 cutText["", "PLAIN"];
life_action_in_use = false;
player switchMove "";
_unit setVariable["plb_executing", nil, true];
if (isNull _unit || !(_success)) exitWith {};
if !([true, "humanscalp", 1] call life_fnc_handleInv) exitWith {["You had no room for the scalp.", "basic"] spawn life_fnc_handleMessage;};
[format["You harvested %1's scalp", _targetName], "basic"] spawn life_fnc_handleMessage;
profileNameSpace setVariable["plb_recent_scalp", [PLB_instance_id, time + 900, _targetName]]; [
    ["-EXECUTE-", player, profileName, format["harvested the scalp of %1 (%2), POS: %3", _targetName, _unit getVariable["plb_steamid", ""], getPosATL _unit]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
[[], "life_fnc_doRespawn", _unit] spawn life_fnc_MP;
player playMove "AinvPknlMstpSlayWrflDnon";
titleText[format["You picked up %1's Scalp! Turn it in at a drug dealer to reap your reward.", _targetName], "PLAIN"];