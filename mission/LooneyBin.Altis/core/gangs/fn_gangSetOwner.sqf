if (life_gang_data param[2, -1] isEqualTo - 1) exitWith {};
life_gang_data set[2, 1];
["The gang leader has transferred gang ownership to you.", "basic"] spawn life_fnc_handleMessage;