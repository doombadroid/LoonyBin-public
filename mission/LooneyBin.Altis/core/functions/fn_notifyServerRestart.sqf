if (playerSide isEqualTo civilian) then {
    ["If you want a vehicle to persist through restart that you own or a lockpicked police vehicle please exit the vehicle now and stay within 150m of the vehicle(s) as the server restarts.", "basic"] spawn life_fnc_handleMessage;
};
if (playerSide isEqualTo west) then {
    ["You can now send players to jail from any location on the map due to a nearing server restart. Use this option in accordance to APD policy and guidelines.", "basic"] spawn life_fnc_handleMessage;
};
waitUntil {uiSleep 1;
    (serverCycleLength - (serverTime - serverStartTime)) <= 55};
uiSleep random(25);
[] call life_fnc_ClupdateRequest;