/*
    life_fnc_botKick  (LooneyBin) -- remote kick from the loonybot admin bridge.
    The server remoteExecs this onto the target's client (via the bot_commands poller in
    server init.sqf). Show the reason, then drop them to debriefing with "loser" -- the
    established kick ending used by init.sqf's fnc_serv_kick.
*/
params [["_reason", "Removed by an admin.", [""]]];
[format ["You have been removed from the server.\nReason: %1", _reason], "basic"] spawn life_fnc_handleMessage;
uiSleep 3;
endMission "loser";
