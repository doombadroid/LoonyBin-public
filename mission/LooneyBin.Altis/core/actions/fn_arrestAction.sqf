params[["_unit", objNull, [objNull]]];
if (isNull _unit || isNil "_unit" || !(_unit isKindOf "CAManBase") || !(isPlayer _unit)) exitWith {};
if (side _unit isEqualTo west || !(_unit getVariable["plb_restrained", false])) exitWith {};
if (playerSide isEqualTo civilian && !(_unit getVariable["plb_civRestrained", false])) exitWith {
    ["You cannot send players restrained by a cop to jail.", "basic"] spawn life_fnc_handleMessage};
if (isNil "life_bounty_list") then { life_bounty_list = [] };   // owner 2026-06-25: nil-guard so the findIf below can't throw -- a BH arrest silently died if the list was nil
if (life_bounty_list isEqualTo[] && playerSide isEqualTo civilian) exitWith {
    ["You do not have an active bounty hunting task.", "basic"] spawn life_fnc_handleMessage};
private _idx = life_bounty_list findIf {getPlayerUID _unit in _x};
if (playerSide isEqualTo civilian && _idx isEqualTo - 1) exitWith {
    ["You cannot arrest this person as you are not tasked to their bounty.", "basic"] spawn life_fnc_handleMessage};
private _action = [format["Are you sure you want to send %1 to prison?", name _unit], "Send To Prison", "Yes", "No"] call BIS_fnc_guiMessage;
if !(_action) exitWith {};
private _bounty = _unit getVariable["plb_wantedAmt", 0];
if (_bounty isEqualTo 0) exitWith {["This player is currently not wanted.", "basic"] spawn life_fnc_handleMessage};
if !(isNil {_unit getVariable "plb_arrest"}) exitWith {};
private _nearbyPlayers = ((getPos player) nearEntities["CAManBase", 10]) select {isPlayer _x};
if (count _nearbyPlayers > 2) then {uiSleep random 2;
    _unit setVariable["plb_arrest", player, true];
    uiSleep random 2;} else {_unit setVariable["plb_arrest", player, true];};
if !(_unit getVariable["plb_arrest", objNull] isEqualTo player) exitWith {};
if (player distance getMarkerPos "respawn_west" < 750) exitWith {_unit setVariable["plb_arrest", nil, true]};
private _isInterrogate = ({player distance2D getMarkerPos _x < 15}
count["marker_606", "marker_609", "marker_610"] > 0 && 22 in life_honor_talents && 8 in life_side_talents);
private _isSkiptracer = ({player distance2D getMarkerPos _x < 15}
count["marker_607", "marker_608", "marker_611", "marker_612"] > 0 && 11 in life_honor_talents && 8 in life_side_talents);
private _success = true;
if (_isInterrogate || _isSkiptracer || playerSide isEqualTo civilian) then {(switch (true) do {case _isInterrogate: {
                ["Interrogating", 100, 30]};
        case _isSkiptracer: {["Arresting", 100, 30]};
        case (playerSide isEqualTo civilian): {["Arresting", 10, 5]};}) params["_actionText", "_arrestArea", "_arresteeDistance"];
    disableSerialization;
    5 cutRsc["life_progress", "PLAIN"];
    private _ui = uiNamespace getVariable "life_progress";
    private _progress = _ui displayCtrl 38201;
    private _pgText = _ui displayCtrl 38202;
    private _text = format["%1 %2...", _actionText, name _unit];
    _pgText ctrlSetText format["%2 (1%1)...", "%", _text];
    _progress progressSetPosition 0.01;
    private _cP = 0.01;
    private _delay =
    if (472 in life_completedLifetimeQuests) then {0.18} else {0.20};
    life_arrestingBounty = true;
    _success = false;
    private _startPos = getPos player;
    [format["You must stay within %1 meters while arresting %2. Press 8 to cancel the arrest.", _arrestArea, name _unit], "basic"] spawn life_fnc_handleMessage;
    for "_i"
    from 0 to 1 step 0 do {uiSleep _delay;
        _cP = _cP + 0.01;
        _progress progressSetPosition _cP;
        _pgText ctrlSetText format["%3 (%1%2)...", round(_cP * 100), "%", _text];
        if !(alive player) exitWith {};
        if !(life_arrestingBounty) exitWith {};
        if !(isNull objectParent player) exitWith {titletext["The arresting process has failed!", "PLAIN"]};
        if !(_unit getVariable["plb_arrest", objNull] isEqualTo player) exitWith {titletext["The arresting process has failed!", "PLAIN"]};
        if (_cp >= 1) exitWith {_success = true;};
        if (player distance _startPos > _arrestArea || isNull _unit || !alive _unit || !(_unit getVariable["plb_restrained", false]) || player getVariable["plb_restrained", false] || _unit distance _startPos > _arresteeDistance || life_isDowned) exitWith {
            titletext["The arresting process has failed!", "PLAIN"]};}; 5 cutText["", "PLAIN"];};
life_arrestingBounty = false;
if !(_success) exitWith {_unit setVariable["plb_arrest", nil, true]};
private _confirm = false;
if (playerSide isEqualTo civilian) then {["fugitivearrested", 1] call life_fnc_statArrUpdate;
    private _friends = ((units group player) - [player]) select {player distance _x <= 100};
    if !(_friends isEqualTo[]) then {
        _confirm = ["We see you have a friend with you. Would you like to share the reward from this bounty with your friends?", "Share Bounty Reward", "Share It", "No, I'm Greedy!"] call BIS_fnc_guiMessage;
    };};
_unit setVariable["plb_arrest", nil, true]; [[_unit, player, false, _confirm], "TON_fnc_wantedBounty", 2] spawn life_fnc_MP;
life_side_exp = life_side_exp + 170;
if (life_allPointsBulletin param[1, "hehe"] isEqualTo(getPlayerUID _unit)) then {life_allPointsBulletin = [];
    publicVariable "life_allPointsBulletin";
    ["action", "arrestapb", 1] call life_fnc_handleQuest;};
if (_bounty >= 150000) then {["action", "arresthvt", 1] call life_fnc_handleQuest;};
["action", "arrest", 1] call life_fnc_handleQuest;
detach _unit; [[player, _unit, [false, _isSkiptracer, _isInterrogate]], "TON_fnc_handleJail", 2] spawn life_fnc_MP; [
    [getPlayerUID _unit], "TON_fnc_setJail", 2] spawn life_fnc_MP; [
    [0, format["%1 was arrested by %2", _unit getVariable["plb_name", name _unit], profileName], false], "life_fnc_broadcast", -2] spawn life_fnc_MP;