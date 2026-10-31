params[["_side", "", [""]]];
disableSerialization;
if (_side isEqualTo "") exitWith {closeDialog 0};
if (_side isEqualTo "gang" && life_gang_data isEqualTo[]) exitWith {
    ["You are not currently a member of a gang. You must create one or receive an invitation.", "basic"] spawn life_fnc_handleMessage;
    closeDialog 0;};
createDialog "life_talent_menu";
waitUntil {!isNull(findDisplay 123000)};
private _plb_display = findDisplay 123000;
private _talentListDisplayCtrl = _plb_display displayCtrl 123001;
private _talentInfoText = _plb_display displayCtrl 123002;
private _talentPointsText = _plb_display displayCtrl 123006;
private _talentButton = _plb_display displayCtrl 123004;
private _talentTreeTitle = _plb_display displayCtrl 123005;
[_plb_display] spawn life_fnc_p_updateMenu;
_talentButton ctrlEnable false;
_talentButton ctrlSetText "SELECT TALENT";
private["_max", "_availTalents", "_talents", "_free"];
if (_side == "standard") then {_max = life_maxTalents;
    _availTalents = life_currentTalents;
    _talents = life_side_talents;
    _free = _availTalents - count _talents;} else {_max = 9;
    _availTalents = life_currentGangTalents;
    _talents = life_gang_talents;
    _free = _availTalents - count _talents;};
private _titleName =
switch (true) do {case (_side isEqualTo "gang"): {"Gang"};
    case (playerSide isEqualTo west): {"APD"};
    case (playerSide isEqualTo civilian && (_side isNotEqualTo "gang")): {"Civilian"};
    case (playerSide isEqualTo independent): {"NG"};
    default {
        "Your"};}; _talentTreeTitle ctrlSetStructuredText parseText format["<t size='0.90' align='center'>%1 Talent Tree</t>", _titleName];
_talentPointsText ctrlSetStructuredText parseText format["<t size='0.70' align='center'>Points: %1/%2 | Available: %3</t>", count _talents, _max, _free];
_talentInfoText ctrlSetStructuredText parseText format["<t size='0.60' align='center'>Select a talent from the tree for more information on its requirements and the benefits it brings. You must have a free talent point in order to learn a talent. Talent points are gained over time by all manors of gameplay.</t>", count _talents, _max, _free];
[_side] call life_fnc_populateTalentTree;
_talentListDisplayCtrl ctrlSetEventHandler["LBSelChanged", format["['%1'] call life_fnc_talentInfo", _side]];
_talentButton ctrlSetEventHandler["ButtonClick", format["['%1'] call life_fnc_learnTalent", _side]];
if (life_talentMenuSync) exitWith {};
if (_side isEqualTo "gang" && life_gang_data isEqualTo[]) exitWith {};
if (_side isEqualTo "gang" && {(life_gang_data select 2) > 2}) exitWith {};
[_side] spawn {params["_side"];
    if (_side isEqualTo "gang") then {life_talentMenuSync = true;
        private _talentCache = str life_gang_talents;
        private _gangID = life_gang_data select 0;
        waitUntil {isNull(findDisplay 123000)};
        if (str life_gang_talents isEqualTo _talentCache) exitWith {};
        private _onlineMembers = (allPlayers - [player]) select {!(_x getVariable["gang_data", []] isEqualTo[]) && {
                (_x getVariable "gang_data"
                select 0) isEqualTo _gangID}};
        if !(_onlineMembers isEqualTo[]) then {[
                ["life_gang_talents", life_gang_talents], "life_fnc_netSetVar", _onlineMembers] call life_fnc_MP;}; [[
                [life_gang_exp, life_gang_talents], life_gang_data select 0], "TON_fnc_updateGangTalents", 2] call life_fnc_MP;} else {
        life_talentMenuSync = true;
        private _talentCache = str life_side_talents;
        waitUntil {isNull(findDisplay 123000)};
        if (str life_side_talents isEqualTo _talentCache) exitWith {};
        [4] call life_fnc_ClupdatePartial;};
    if (isNull(findDisplay 123000)) then {life_talentMenuSync = false};};