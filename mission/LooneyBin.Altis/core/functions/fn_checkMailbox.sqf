if (life_lastCompCheck >= time) exitWith {
    ["You can only check your mailbox every 10 minutes. Try again later.", "basic"] spawn life_fnc_handleMessage;};
private _restartTime =
if (isNil "serverStartTime") then {round((14400 - serverTime) / 60)} else {round((serverCycleLength - (serverTime - serverStartTime)) / 60)
};
if (_restartTime <= 5) exitWith {
    ["You cannot check your mailbox within 5 minutes of a restart. Try again after restart.", "basic"] spawn life_fnc_handleMessage;}; [
    [player, getPlayerUID player], "TON_fnc_processMailbox", 2] spawn life_fnc_MP;
life_lastCompCheck = time + 600;