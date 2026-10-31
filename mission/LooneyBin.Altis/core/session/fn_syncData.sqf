if (isNil "life_session_time") then {life_session_time = false};
if (life_session_time) exitWith {
    ["You have already used the sync option, you can only use this feature once every 5 minutes.", "basic"] spawn life_fnc_handleMessage};
[] call life_fnc_ClupdateRequest;
["Syncing player information to the server. Please wait up to 20 seconds before leaving.", "basic"] spawn life_fnc_handleMessage;
[] spawn {life_session_time = true;
    uiSleep(5 * 60);
    life_session_time = false;};