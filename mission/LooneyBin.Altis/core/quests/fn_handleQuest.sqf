params[["_mode", "", [""]], ["_item", "", ["", []]], ["_quantity", -1, [0]]];
_quantity = round _quantity;
if (_mode isEqualTo "" || _item isEqualTo "" || _quantity isEqualTo - 1 || !life_session_completed) exitWith {};
// owner 2026-07-11 (PAROLE PAPERS, Act 2 onboarding): forward every event to the parole arc while it's
// active -- this chokepoint already sees collect/sell/buy/action/etc from the whole codebase.
if (!isNil "PLB_paroleActive" && {_item isEqualType ""}) then { ["event", _mode, _item, _quantity] call life_fnc_parole; };
if (_mode isEqualTo "spawnLootChest") exitWith {private _lootData = profileNamespace getVariable["plb_questChestLootArray", []];
    if !(_lootData isEqualTo[]) then {_lootData params["_sessionID", "_plb_pos", "_virtualArray", "_PhysArray", "_questID", "_serverTime"];
        if !(_questID in life_completedLifetimeQuests) exitWith {profileNamespace setVariable["plb_questChestLootArray", []]};
        [_plb_pos, _virtualArray, _PhysArray, _questID, true] spawn life_fnc_createQuestLoot;};};
private _antiCheese = {params["_questID"];
    private _exit = false;
    private _cooldown = (["getQuestRowByID", _questID] call life_fnc_questsCfg) select 5;
    if (_cooldown isEqualTo 0) exitWith {_exit};
    private _index = life_questAntiCheese findIf {_questID isEqualTo(_x select 0)};
    if (_index isEqualTo - 1) then {life_questAntiCheese pushBack[_questID, (time + _cooldown)];} else {
        if ((life_questAntiCheese select _index) select 1 < time) then {life_questAntiCheese deleteAt _index;
            life_questAntiCheese pushBack[_questID, (time + _cooldown)];} else {
            ["Your previous action did not count towards quest completion due to being too recent to your last action towards the quest.", "basic"] spawn life_fnc_handleMessage;
            _exit = true;};};
    _exit};
private _updateLifetimeProgress = {params["_questID", "_quantity"];
    if ([_questID] call _antiCheese) exitWith {};
    if (life_LifetimeProgressQuests isEqualTo[]) then {life_LifetimeProgressQuests pushBack[_questID, _quantity];} else {
        private _index = life_LifetimeProgressQuests findIf {_questID isEqualTo(_x select 0)};
        if (_index isEqualTo - 1) then {life_LifetimeProgressQuests pushBack[_questID, _quantity];} else {
            (life_LifetimeProgressQuests select _index) set[1, ((life_LifetimeProgressQuests select _index) select 1) + _quantity];};};};
private _updateNonLifetimeProgress = {params["_mode", "_quantity"];
    if (life_questProgress isEqualTo[]) then {life_questProgress pushBack[_mode, _quantity];} else {
        private _index = life_questProgress findIf {_mode isEqualTo(_x select 0)};
        if (_index isEqualTo - 1) then {life_questProgress pushBack[_mode, _quantity];} else {
            (life_questProgress select _index) set[1, ((life_questProgress select _index) select 1) + _quantity];};};};
private _isQuestComplete = {params["_id"];
    if (_id in life_completedLifetimeQuests) exitWith {true};
    private _questType = (["getQuestRowByID", _id] call life_fnc_questsCfg) param[2, -1];
    private _isLifetime =
    if (_questType == 2) then {true} else {false};
    private _requirements = ["getRequirementsByID", _id] call life_fnc_questsCfg;
    private _allMet = true;
    if !(_isLifetime) then {{_x params["_reqType", "_reqItem", "_reqQty"];
            private _index = life_questProgress findIf {_reqType isEqualTo(_x select 0)};
            if (_index isEqualTo - 1) then {_allMet = false;} else {if ((life_questProgress select _index) select 1 < _reqQty) then {
                    _allMet = false;};};}
        forEach _requirements;} else {private _index = life_LifetimeProgressQuests findIf {_id isEqualTo(_x select 0)};
        private _curQty = (life_LifetimeProgressQuests select _index) select 1;
        private _reqQty = (_requirements select 0) select 2;
        if !(_index isEqualTo - 1) then {if (_curQty >= _reqQty) then {life_completedLifetimeQuests pushBackUnique _id;
                life_LifetimeProgressQuests deleteAt _index;} else {_allMet = false;};};};
    _allMet;};
private _handleQuestComplete = {params["_questID"];
    private _questData = ["getQuestRowByID", _questID] call life_fnc_questsCfg;
    private _questReward = _questData param[6, []];
    if !(_questReward isEqualTo[]) then {if !((_questReward select 0) == 0) then {
            // NEW DRACHMA: quest reward converted to ND at the legacy 6000:1 rate, server-credited (ndSync toasts the award).
            [[(_questReward select 0)] call PLB_fnc_ndFromLegacy, "quest"] call PLB_fnc_ndRequest;};
        if !((_questReward select 1) == 0) then {life_honor_exp = life_honor_exp + (_questReward select 1);
            [14] call life_fnc_ClupdatePartial;
            [format["You were awarded %1 Honor for your quest completion", [(_questReward select 1)] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
        };
        if !((_questReward select 2) == 0) then {life_atmcash = life_atmcash + (_questReward select 2);
            life_atmcashCacheB = ((life_atmcash / 4) + 11);
            [format["You were awarded $%1 for your quest completion", [(_questReward select 2)] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
        };};
    private _lootArray = _questData param[7, []];
    if !(_lootArray isEqualTo[]) then {
        [player, (_lootArray select 0), (_lootArray select 1), _questID, false] spawn life_fnc_createQuestLoot;};};
private _lifeTimeIDS = ["getLifetimeQuestIDsByRequirements", [_mode, _item]] call life_fnc_questsCfg;
if !(_lifeTimeIDS isEqualTo[]) then {private _syncProgress = false; {if !(_x in life_completedLifetimeQuests) then {
            private _questData = ["getQuestRowByID", _x] call life_fnc_questsCfg;
            private _questSide = _questData param[1];
            if (playerSide != _questSide) exitWith {};
            [_x, _quantity] call _updateLifetimeProgress;
            if ([_x] call _isQuestComplete) then {[_x] call _handleQuestComplete;
                playSound "questDoneSeasonal";
                ["seasquests_completed", 1] call life_fnc_statArrUpdate;
                life_side_exp = life_side_exp + 250;
                _syncProgress = true;
                private _questData = ["getQuestRowByID", _x] call life_fnc_questsCfg;
                _questName = _questData param[8, "No quest name found"];
                _questReq = _questData param[9, "No quest description found"];
                _rewardInfo = _questData param[10, "No quest rewards found"];
                [format["<t align='center' size='1.5' color='#c154c1'>Lifetime Quest Completed</t><br/><br/>Quest %1 has been completed!<br/><br/>You completed: %2<br/><br/>Rewards Earned: %3", _questName, _questReq, _rewardInfo], "event"] spawn life_fnc_handleMessage;
                [
                    ["-QUESTCOMPLETED-", player, profileName, format["Finished Lifetime Quest: (%1)(%2), playerside: %3, position: %4.", _x, _questName, playerSide, getPosATL player]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
                if !(PLB_SessionID isEqualTo(profileNamespace getVariable["plbv_lastSessionID", "0"])) then {
                    profileNamespace setVariable["plbv_lastSessionID", PLB_SessionID];};};};}
    forEach _lifeTimeIDS;
    if (_syncProgress) then {[20] call life_fnc_ClupdatePartial;};};
if (_item in life_questItems && !(life_activeQuest isEqualTo 0)) then {if ([life_activeQuest] call _antiCheese) exitWith {};
    [_mode, _quantity] call _updateNonLifetimeProgress;
    if ([life_activeQuest] call _isQuestComplete) then {[life_activeQuest] call _handleQuestComplete;
        playSound "questDoneNormal";
        ["normquests_completed", 1] call life_fnc_statArrUpdate;
        life_side_exp = life_side_exp + 75;
        private _questData = ["getQuestRowByID", life_activeQuest] call life_fnc_questsCfg;
        _questName = _questData param[8, "No quest name found"];
        _questReq = _questData param[9, "No quest description found"];
        _rewardInfo = _questData param[10, "No quest rewards found"]; [
            ["-QUESTCOMPLETED-", player, profileName, format["Finished Restart Cycle Quest: (%1)(%2), playerside: %3, position: %4.", life_activeQuest, _questName, playerSide, getPosATL player]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
        life_completedQuests pushBackUnique life_activeQuest;
        life_activeQuest = 0;
        life_questItems = [];
        life_questProgress = [];
        [1] call life_fnc_questSync;
        private _priorityType =
        if (life_tutorialActive) then {"shortwarning"} else {"event"};
        [format["<t align='center' size='1.5' color='#c154c1'>Quest Completed</t><br/><br/>Quest %1 has been completed! You can now select a new quest.<br/><br/>You completed: %2<br/><br/>Rewards Earned: %3", _questName, _questReq, _rewardInfo], _priorityType] spawn life_fnc_handleMessage;
        if !(PLB_SessionID isEqualTo(profileNamespace getVariable["plbv_lastSessionID", "0"])) then {
            profileNamespace setVariable["plbv_lastSessionID", PLB_SessionID];};};};
if !(isNull(findDisplay 8100)) then {[] spawn life_fnc_questMenu};