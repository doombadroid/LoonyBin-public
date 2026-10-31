if !(life_isSwat) exitWith {};
if !(SRV_SWATrequested) exitWith {["Sorry, SWAT officers are not needed at this time.", "basic"] spawn life_fnc_handleMessage;};
private _copCount = count(allPlayers select {side _x isEqualTo west});
if ((SRV_activeSWAT select 1) >= (SRV_activeSWAT select 0)) exitWith {
    ["Sorry, all the slots available for the swat deployment have been filled.", "basic"] spawn life_fnc_handleMessage;};
["action", "reportswat", 1] spawn life_fnc_handleQuest; [[player], "TON_fnc_registerSwat", 2] call life_fnc_MP;