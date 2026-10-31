if !(params[["_questID", -1, [0]]]) exitWith {};
private _selectedQuest = (["getQuestRowByID", _questID] call life_fnc_questsCfg);
private _questName = _selectedQuest param[8, "Error: No quest found"];
private _action = [format["Do you want to activate quest: %1?", _questName], "Quest System", "Confirm", "Cancel"] call BIS_fnc_guiMessage;
if !(_action) exitWith {};
closeDialog 0;
life_questItems = [];
life_activeQuest = 0;
life_questProgress = [];
life_activeQuest = _questID;
life_questItems = ["getQuestRequirementItemsByID", _questID] call life_fnc_questsCfg;
[1] call life_fnc_questSync;
private _selectedQuest = (["getQuestRowByID", _questID] call life_fnc_questsCfg);
private _questName = _selectedQuest param[8, "No Quest Name"];
private _details = _selectedQuest param[9, "No Quest Details"];
private _reward = _selectedQuest param[10, "No Quest Details"];
private _priorityType =
if (life_tutorialActive) then {"shortwarning"} else {"event"};
[format["<t align='center' size='1.5' color='#c154c1'>Quest Accepted</t><br/><br/>You've accepted the %1 quest. The quest will autocomplete when all requirements have been met.<br/><br/>%2<br/><br/>Completion of this quest will reward you with: %3", _questName, _details, _reward], _priorityType] spawn life_fnc_handleMessage;
playSound "questStart";
if (_questID == 250) then {if (SRV_civilianRestartQuests isEqualTo(SRV_civilianRestartQuests select {_X in life_completedQuests})) then {
        ["action", "completeallcivilianrestartquests", 1] spawn life_fnc_handleQuest;};};