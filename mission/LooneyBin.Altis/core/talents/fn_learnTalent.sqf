params[["_type", "", [""]]];
if (_type isEqualTo "") exitWith {};
[_type] spawn {params[["_type", "", [""]]];
    disableSerialization;
    private _talentID = parseNumber(lbData[123001, lbCurSel 123001]);
    private _exit = false;
    if (playerSide isEqualTo civilian) then {if (_type isEqualTo "gang" && !(life_gang_data isEqualTo[]) && {(life_gang_data select 2) > 2
        }) exitWith {["You're not high enough rank to edit gang talents!", "basic"] spawn life_fnc_handleMessage;
            _exit = true;};};
    if (_exit) exitWith {}; (switch (_type) do {case "standard": {[life_side_talents, ["getRowByID", _talentID] call life_fnc_talentCfg]
            }; case "gang": {[life_gang_talents, ["getRowByID", "gang", _talentID] call life_fnc_prestigeCfg]}
    }) params["_talents", "_talentRow"];
    _talentRow params["_talentID", "_side", "_req", "_depth", "_title", "_description"];
    if (_talentID in _talents) then {if (_type isEqualTo "standard") then {
            private _child = ["getChild", _talentID] call life_fnc_talentCfg;
            if !(_child isEqualTo[]) exitWith {
                [format["You can't unlearn this talent as it has a child talent, %1, which will need to be unlearned first.", _child select 4], "basic"] spawn life_fnc_handleMessage
            };
            private _action = true;
            _action = [format["If you proceed you will unlearn the talent %1 for a cost of $%2!", _title, [(call life_respec_fee)] call life_fnc_numberText], "Unlearn Talent", "Yes", "No"] call BIS_fnc_guiMessage;
            if !(_action) exitWith {};
            if (life_atmcash < (call life_respec_fee)) exitWith {
                ["You don't have enough money in your bank to unlearn this talent.", "basic"] spawn life_fnc_handleMessage;};
            life_side_talents deleteAt(life_side_talents findIf {_x isEqualTo _talentID});
            life_atmcash = life_atmcash - (call life_respec_fee);
            life_atmcashCacheB = ((life_atmcash / 4) + 11);
            [format["You have unlearned the talent %1.", _title], "basic"] spawn life_fnc_handleMessage;} else {
            private _child = ["getChild", "gang", _talentID] call life_fnc_prestigeCfg;
            if !(_child isEqualTo[]) exitWith {
                [format["You can't unlearn this talent as it has a child talent, %1, which will need to be unlearned first.", _child select 4], "basic"] spawn life_fnc_handleMessage
            };
            life_gang_talents deleteAt(life_gang_talents findIf {_x isEqualTo _talentID});
            [format["You have unlearned the gang talent %1.", _title], "basic"] spawn life_fnc_handleMessage;};} else {
        if (_type isEqualTo "standard") then {if (_talentID isEqualTo 8 && license_civ_rebel && _type isEqualTo "standard") exitWith {
                ["You must first get rid of your Rebel Training to become a Master Bounty Hunter.", "basic"] spawn life_fnc_handleMessage;
                _exit = true;};
            private _max = life_currentTalents;
            private _free = _max - count _talents;
            if (_free < 1) exitWith {["You don't have an available talent point to spend!", "basic"] spawn life_fnc_handleMessage;};
            if (_req > 0 && !(_req in _talents)) exitWith {
                ["This talent requires another talent that you don't have!", "basic"] spawn life_fnc_handleMessage;};
            _talents pushBack _talentID;
            [format["You have learned the talent %1.", _title], "basic"] spawn life_fnc_handleMessage;
            systemChat format["You have learned the talent %1.", _title];
            ["action", "learntalent", 1] call life_fnc_handleQuest;   // owner 2026-07-11: Parole Papers step 4 (+ future quests)
        } else {private _max = life_currentGangTalents;
            private _free = _max - count _talents;
            if (_free < 1) exitWith {["You don't have an available talent point to spend!", "basic"] spawn life_fnc_handleMessage;};
            if (_req > 0 && !(_req in _talents)) exitWith {
                ["This talent requires another talent that you don't have!", "basic"] spawn life_fnc_handleMessage;};
            _talents pushBack _talentID;
            [format["You have learned the talent %1.", _title], "basic"] spawn life_fnc_handleMessage;
            systemChat format["You have learned the talent %1.", _title];};};
    [_type] call life_fnc_populateTalentTree;};