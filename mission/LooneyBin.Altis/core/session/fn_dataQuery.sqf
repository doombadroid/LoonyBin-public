if (life_session_completed) exitWith {};
life_loadingScreenStatus = format["Sending Server Request For %1 (%2)", profileNameSteam, profileName]; [
    [player, playerSide], "DB_fnc_queryRequest", false, false] call life_fnc_MP;