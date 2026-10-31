params["_obj_main", "_stance"];
if (_obj_main isKindOf "CAManBase") then {};
_obj_main addAction["Register for Jury Duty", {["registerForJury", [player]] spawn life_fnc_trialSystem
}, nil, 1.5, false, false, "", 'playerSide isEqualTo civilian && !(SRV_trialData isEqualTo [objNull, [], [], false, false, false, ""]) && (life_clientTrialData select 1)', 5];
_obj_main addAction["Turn Yourself In (Paid)", {[false] call life_fnc_turnedIn
}, nil, 1.5, false, false, "", '!(playerSide isEqualTo west) && ((A_stats_crimes) select 0) > 0', 5];
_obj_main addAction["Turn Yourself In (Prison)", {[true] call life_fnc_turnedIn
}, nil, 1.5, false, false, "", '!(playerSide isEqualTo west) && ((A_stats_crimes) select 0) > 0', 5];
_obj_main addAction["Accept a duel", {["acceptInvite"] spawn life_fnc_duelArenaSystem
}, nil, 1.5, false, false, "", 'playerSide isEqualTo civilian', 5];