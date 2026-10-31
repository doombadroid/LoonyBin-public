private _bookmarkQuest = {params[["_control", controlNull], ["_selectedIndex", -1]];
    if (_selectedIndex isEqualTo - 1) exitWith {};
    if (isNull _control) exitWith {};
    private _display = findDisplay 8100;
    if (isNull _display) exitWith {};
    private _list = _display displayCtrl 8101;
    private _infoText = _display displayCtrl 8102;
    private _questName = _display displayCtrl 8103;
    private _acceptButton = _display displayCtrl 8104;
    private _filter = _display displayCtrl 8105;
    private _filterType = _filter lbData(lbCurSel _filter);
    private _isLifetimeFilter = (_filterType isEqualTo "Lifetime Quests");
    private _bookMarkedQuest =
    if (_isLifetimeFilter) then {profileNamespace getVariable["plb_questDoubleClickedIndexSeas", -1]} else {
        profileNamespace getVariable["plb_questDoubleClickedIndex", -1]};
    if ((lbCurSel _list) isEqualTo - 1) exitWith {};
    
    private _index = _list lbValue _selectedIndex;
    if (_isLifetimeFilter) then {if (_selectedIndex isEqualTo _bookMarkedQuest) then {
            profileNamespace setVariable["plb_questDoubleClickedIndexSeas", -1];} else {
            profileNamespace setVariable["plb_questDoubleClickedIndexSeas", _selectedIndex]};} else {
        if (_selectedIndex isEqualTo _bookMarkedQuest) then {profileNamespace setVariable["plb_questDoubleClickedIndex", -1];} else {
            profileNamespace setVariable["plb_questDoubleClickedIndex", _selectedIndex]};};};
private _populateList = {params[["_controlData", [], [[]]]];
    if (_selectedType isEqualTo "" || _controlData isEqualTo[]) exitWith {};
    _controlData params["_control", "_selectedIndex"];
    private _display = findDisplay 8100;
    if (isNull _display) exitWith {};
    private _list = _display displayCtrl 8101;
    private _infoText = _display displayCtrl 8102;
    private _questName = _display displayCtrl 8103;
    private _acceptButton = _display displayCtrl 8104;
    private _filter = _display displayCtrl 8105;
    private _filterType = _control lbData _selectedIndex;
    lbClear _list;
    private _isRestartFilter = (_filterType isEqualTo "Restart Cycle Quests");
    private _isLifetimeFilter = (_filterType isEqualTo "Lifetime Quests");
    private _isTutorialFilter = (_filterType isEqualTo "Tutorial Quests");
    private _questCfg = ["getQuestArray"] call life_fnc_questsCfg;
    private _questCfg =
    switch (true) do {case (_isTutorialFilter): {_questCfg select {(_x param[2, -1] == 0)}};
        case (_isRestartFilter): {_questCfg select {(_x param[2, -1] == 1)}};
        case (_isLifetimeFilter): {_questCfg select {(_x param[2, -1] == 2)}};
        default {[]};}; if (_isRestartFilter) then {if (playerSide == civilian) then {_questCfg = _questCfg select {
                (_x param[0, -1] in SRV_civilianRestartQuests) || _x param[0, -1] == 250};};};
    private _questCfg =
    switch (true) do {
        
        default {_questCfg select {!(_x param[4, -1])}};}; private _activeIndex = 0; {
        _x params["_id", "_faction", "_questType", "_multiStage", "_qreserved", "", "", "", "_nameText", "_requirementText", "_awardText"];
        if (_id < 1000) then {private _color =
            switch (true) do {case (_id in life_completedLifetimeQuests): {[0, 1, 0, 1]};
                case (_id in life_completedQuests): {[0, 1, 0, 1]};
                case (_id isEqualTo life_activeQuest): {[1, 0, 0, 1]};
                case (_questType == 2): {[0, 0.71, 0.84, 1]};
                default {[]};}; if (playerSide isEqualTo _faction) then {private _index = _list lbAdd format["%1", _nameText];
                _list lbSetValue[_index, _id];
                if (_color isNotEqualTo[]) then {_list lbSetColor[_index, _color];
                    _list lbSetSelectColor[_index, _color];};
                if (_id isEqualTo life_activeQuest) then {_activeIndex = _index;};};};}
    forEach _questCfg;
    private _bookMarkedQuest =
    if (_isLifetimeFilter) then {profileNamespace getVariable["plb_questDoubleClickedIndexSeas", -1]} else {
        profileNamespace getVariable["plb_questDoubleClickedIndex", -1]};
    private _bookMarkedQuest =
    _bookMarkedQuest;
    if (_isLifetimeFilter) then {if (_bookMarkedQuest isNotEqualTo - 1) then {_list lbSetCurSel _bookMarkedQuest;} else {
            _list lbSetCurSel 0;};} else {switch (true) do {case (_bookMarkedQuest isNotEqualTo - 1): {_list lbSetCurSel _bookMarkedQuest};
            case (!(life_tutorialActive) && (life_activeQuest isEqualTo 0)): {_list lbSetCurSel 0};
            case ((life_tutorialActive) && (life_activeQuest isNotEqualTo 0)): {_list lbSetCurSel _activeIndex};
            case (life_activeQuest isNotEqualTo 0): {_list lbSetCurSel _activeIndex};
            case (life_tutorialActive): {_list lbSetCurSel(lbSize _list)};
            default {_list lbSetCurSel 0};};};};
disableSerialization;
createDialog "life_quest_menu";
waitUntil {!isNull(findDisplay 8100)};
private _display = findDisplay 8100;
[_display] spawn life_fnc_p_updateMenu;
private _list = _display displayCtrl 8101;
private _infoText = _display displayCtrl 8102;
private _questName = _display displayCtrl 8103;
private _acceptButton = _display displayCtrl 8104;
private _filter = _display displayCtrl 8105;
private _questCfg = ["getQuestArray"] call life_fnc_questsCfg;
_list ctrlAddEventHandler["LBSelChanged", "_this spawn life_fnc_questSel"];
_list ctrlAddEventHandler["LBDblClick", format["_this call %1", _bookmarkQuest]];
_filter ctrlAddEventHandler["LBSelChanged", format["[_this] call %1;", _populateList]];
if (life_activeQuest isEqualTo 0) then {_acceptButton ctrlSetText "Accept Quest";
    _acceptButton ctrlAddEventHandler["ButtonClick", "[lbValue [8101, lbCurSel 8101]] spawn life_fnc_questAccept; (_this select 0) ctrlEnable false"];
} else {_acceptButton ctrlSetText "Cancel Active Quest";};
_acceptButton ctrlEnable false;
lbClear _list;
private _filtersToShow = ["Restart Cycle Quests", "Lifetime Quests"];
if (false) then {_filtersToShow pushBack "Tutorial Quests"}; {private _title = _x;
    private _index = _filter lbAdd _title;
    _filter lbSetData[_index, _x];}
forEach _filtersToShow;
_filter lbSetCurSel 0;