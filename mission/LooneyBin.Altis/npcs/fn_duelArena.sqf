params["_obj_main", "_stance"];
if (_obj_main isKindOf "CAManBase") then {};
_obj_main addAction["Invite someone to duel", {["promptMenu"] spawn life_fnc_duelArenaSystem
}, nil, 1.5, false, false, "", 'playerSide isEqualTo civilian', 5];
_obj_main addAction["Accept a duel", {["acceptInvite"] spawn life_fnc_duelArenaSystem
}, nil, 1.5, false, false, "", 'playerSide isEqualTo civilian', 5];