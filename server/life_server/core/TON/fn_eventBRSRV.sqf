/*
    TON_fnc_eventBRSRV  (LooneyBin -- implemented from stub 2026-06-09)
    Admin event: BATTLE ROYALE. Start = [_locationID] from the eventCfg lambda. Clients join via the
    event key (mode 2 -> fn_eventBRClient) and register through TON_fnc_eventParticipants (server
    life_event_queue). Server closes joins after 3 min, then LAST PARTICIPANT ALIVE wins. 30-min cap.
*/
params [["_locID", -1, [0]]];
if (life_adminEvent param [0, false]) exitWith {};
if (isNil "life_event_queue") then { life_event_queue = []; };
life_event_queue = [];
life_adminEvent = [true, false, 2, _locID];
publicVariable "life_adminEvent";
private _locData = (["getLocationByID", _locID] call life_fnc_eventCfg);
private _locName = _locData param [1, "?"];
private _brPos = _locData param [2, [0,0,0]];
// owner 2026-06-24: SHRINKING-ZONE. Create the global play-zone marker NOW (start, full size) so it already exists
// when clients spawn their zone-watch threads at join-lock -- avoids a publicVariable-vs-marker race that left the
// marker missing (client read markerPos [0,0,0] -> exitWith -> no shrink, no out-of-zone bleed). Shrink begins at lock.
deleteMarker "AE_BattleRoyale_Zone";
createMarker ["AE_BattleRoyale_Zone", _brPos];
"AE_BattleRoyale_Zone" setMarkerShape "ELLIPSE";
"AE_BattleRoyale_Zone" setMarkerSize [400, 400];
"AE_BattleRoyale_Zone" setMarkerBrush "Border";
"AE_BattleRoyale_Zone" setMarkerColor "ColorBlue";
"AE_BattleRoyale_Zone" setMarkerText "Battle Royale Zone";
[[0, format ["ADMIN EVENT: BATTLE ROYALE at %1! Civilians -- press your event key to join!", _locName]], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
[] spawn {private _end = {life_adminEvent = [false, false, 0, 0]; publicVariable "life_adminEvent";
        life_event_queue = [];
        deleteMarker "AE_BattleRoyale_Zone";};
    uiSleep 180;
    if !(life_adminEvent param [0, false] && {(life_adminEvent param [2, 0]) isEqualTo 2}) exitWith {};
    life_adminEvent set [1, true]; publicVariable "life_adminEvent";
    [[0, format ["Battle Royale joins CLOSED -- %1 fighters. Last one standing wins! The zone is now shrinking -- stay inside the circle.", count life_event_queue]], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
    // owner 2026-06-24: shrink the play zone 400m -> 35m over ~18 min. Clients bleed-damage anyone outside it
    // (fn_eventBRClient zone threads keyed on this marker). Self-stops when the event clears life_adminEvent.
    [] spawn {private _r0 = 400; private _rMin = 35; private _shrinkSecs = 1080; private _t0 = serverTime;
        while { (life_adminEvent param [0, false]) && {(life_adminEvent param [2, 0]) isEqualTo 2} } do {
            private _r = _r0 - ((_r0 - _rMin) * (((serverTime - _t0) / _shrinkSecs) min 1));
            "AE_BattleRoyale_Zone" setMarkerSize [_r, _r];
            uiSleep 15;};};
    if (count life_event_queue < 2) exitWith {
        [[0, "Battle Royale cancelled -- not enough fighters."], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
        call _end;};
    private _endAt = serverTime + 1620;
    private _alive = life_event_queue;
    waitUntil {uiSleep 3;
        _alive = life_event_queue select { !isNull _x && {alive _x} };
        (count _alive <= 1) || (serverTime > _endAt) || !(life_adminEvent param [0, false])};
    if !(life_adminEvent param [0, false]) exitWith {};
    if (count _alive isEqualTo 1) then {private _winner = _alive select 0;
        [["atm", "add", 250000], "life_fnc_uC", _winner, false, false] spawn life_fnc_MP;
        [[0, format ["%1 has WON the Battle Royale! ($250,000 prize)", name _winner]], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
        diag_log format ["[LooneyBin][event] BR won by %1", getPlayerUID _winner];
        ["-EVENT-", _winner, "WON Battle Royale ($250k)"] call PLB_fnc_logIt;} else {
        [[0, "The Battle Royale has ended."], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;};
    call _end;};
