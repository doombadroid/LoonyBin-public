params[["_enforcer", objNull, [objNull]], ["_target", objNull, [objNull]], ["_isTrial", false, [false]]];
if ((_enforcer isEqualTo _target) && !(_isTrial)) exitWith {};
if ((_target getVariable["plb_arrested", false]) && !(_isTrial)) exitWith {};
if (_target getVariable["plb_surrendered", false]) then {_target setVariable["plb_surrendered", nil, true];};
detach _target;
private _copEnforcer = (side _enforcer) isEqualTo west;
if (isNull _enforcer || isNull _target) exitWith {};
if (_copEnforcer && side _target isEqualTo west) exitWith {}; [
    ["action", "restrain", 1], "life_fnc_handleQuest", _enforcer] spawn life_fnc_MP;
_target setVariable["plb_restrained", true, true];
closeDialog 0;
private _enforcerString =
if (_isTrial) then {"the Judge"} else {_enforcer getVariable["plb_name", [name _enforcer] call life_fnc_cleanName]};
[format["You've been restrained by %1", _enforcerString], "basic"] spawn life_fnc_handleMessage;
if (side player isEqualTo west) then {[["civ_cops_restrained", 1], "life_fnc_statArrUpdate", _enforcer] spawn life_fnc_MP;};
if (_copEnforcer) then {life_old_group = group player;
    if !((units group player) isEqualTo[]) then {[player] join grpNull;
        if ("ItemGPS" in (assignedItems player)) then {[
                [false, player], "life_fnc_setGroupRestrainMarker", units life_old_group] spawn life_fnc_MP;};};} else {
    _target setVariable["plb_civRestrained", true, true]; ["Civilian restraints break after 10 minutes.", "civ_restraints", {
        player getVariable["plb_civRestrained", false];}] spawn life_fnc_handleMessage;};
if (_target getVariable["plb_downed", false] && !(_copEnforcer)) then {waitUntil {uiSleep 0.25;
        !(_target getVariable["plb_downed", false])}};
_target playMoveNow "AmovPercMstpSnonWnonDnon";
disableUserInput false;
private _startTime = time;
private _maxRestrainTime = 10 * 60;
private _timeUp = false;
private _continue = true;
while {_continue}
do {if (isNull objectParent player) then {_target playMove "AmovPercMstpSnonWnonDnon_Ease"};
    waitUntil {_noNearbyCops = ({side _x isEqualTo west && player distance _x < 500}
        count allPlayers isEqualTo 0);
        _timeUp = (!_copEnforcer || (isNull objectParent player && _copEnforcer && _noNearbyCops)) && time - _startTime > _maxRestrainTime && !(_target getVariable["plb_escorting", false]) && !(_target getVariable["plb_transporting", false]);
        if (_timeUp || !(_target getVariable["plb_restrained", false]) || !alive _target) then {_continue = false;};
        if !(isNull objectParent player) then {if (driver(vehicle player) isEqualTo player) then {player action["Eject", vehicle player];};
        };
        !_continue || animationState _target != "AmovPercMstpSnonWnonDnon_Ease";};}; _target playMoveNow "AmovPercMstpSnonWnonDnon";
if (_copEnforcer && life_old_group != group player) then {[player] joinSilent life_old_group;
    life_old_group = grpNull;};
_target allowDamage true;
_target setVariable["plb_restrained", nil, true];
_target setVariable["plb_civRestrained", nil, true];
if (life_isDowned) then {player setUnconscious true};