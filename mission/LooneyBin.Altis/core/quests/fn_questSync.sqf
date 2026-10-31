params[["_mode", -1, [0]], "_questData"];
switch (_mode) do {case (0): {life_activeQuest = _questData param[0, 0];
            life_questProgress = +(_questData param[1, []]);
            life_completedQuests = +(_questData param[2, []]);
            [1] call life_fnc_questSync;
            life_lastSynced_restartQuest = +[life_activeQuest, life_questProgress, life_completedQuests];
            if ((playerSide isEqualTo civilian) && (life_activeQuest >= 800)) then {life_tutorialQuestsActive = true};
            life_questItems =
            if (life_activeQuest isEqualTo 0) then {[]} else {["getReqItems", life_activeQuest] call life_fnc_questsCfg};};
    case (1): {if (isNil "life_lastSynced_restartQuest") then {life_lastSynced_restartQuest = [0, [], []]};
            if (life_lastSynced_restartQuest isEqualTo[life_activeQuest, life_questProgress, life_completedQuests]) exitWith {};
            life_lastSynced_restartQuest = +[life_activeQuest, life_questProgress, life_completedQuests];
            player setVariable["plb_restartQuestData", [life_activeQuest, life_questProgress, life_completedQuests], 2];};};