/*
    TON_fnc_eventGraveyardSRV  (LooneyBin -- implemented from stub 2026-06-09)
    Admin event: GRAVEYARD (Halloween bone-gathering at location 50). Start = [1, objNull, _locID].
    Scoring/digging is fully client-side (fn_eventGraveyardClient + setupActions grave actions, keyed on
    life_adminEvent select 2 == 4 + life_inEvent). Server = open joins, 20-min round, close.
*/
params [["_mode", -1, [0]], ["_x1", objNull, [objNull]], ["_locID", 50, [0]]];
if !(_mode isEqualTo 1) exitWith {};
if (life_adminEvent param [0, false]) exitWith {};
if (isNil "life_event_queue") then { life_event_queue = []; };
life_event_queue = [];
life_adminEvent = [true, false, 4, _locID];
publicVariable "life_adminEvent";
[[0, "ADMIN EVENT: GRAVEYARD SHIFT! Civilians -- press your event key to join the dig!"], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
[] spawn {uiSleep 1200;   // 20-min round
    if (life_adminEvent param [0, false] && {(life_adminEvent param [2, 0]) isEqualTo 4}) then {
        life_adminEvent = [false, false, 0, 0]; publicVariable "life_adminEvent";
        life_event_queue = [];
        [[0, "The Graveyard Shift admin event has ended!"], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;};};
