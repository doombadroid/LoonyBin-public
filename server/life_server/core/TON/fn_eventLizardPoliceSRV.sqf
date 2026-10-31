/*
    TON_fnc_eventLizardPoliceSRV  (LooneyBin world event -- Ben Bones canon). life_adminEvent type 10.
    For 8 minutes the badges are SHEDDING -- every cop is cold-blooded. Server flags PLB_lizardPolice; the
    client watcher (initPlayerLocal) gives cops a green reptile tint + a toast. Cosmetic + pure lore/chaos.
*/
params [["_locID", -1, [0]]];
if (life_adminEvent param [0, false]) exitWith {};
life_adminEvent = [true, false, 10, 0];
publicVariable "life_adminEvent";
PLB_lizardPolice = [true, serverTime + 480]; publicVariable "PLB_lizardPolice";

[[0, "BEN BONES EMERGENCY BROADCAST: the badges are SHEDDING. Every cop is COLD-BLOODED for 8 minutes. Trust NO ONE with a siren."], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
["LIZARD", "POLICE CONFIRMED REPTILIAN FOR THE NEXT 8 MIN -- 'ROUTINE', SAYS FORKED TONGUE", "the COPS are LIZARDS right now. i can SEE the scales. do NOT comply, patriot."] call TON_fnc_newsPush;

[] spawn {uiSleep 480;
    PLB_lizardPolice = [false, 0]; publicVariable "PLB_lizardPolice";
    if (life_adminEvent param [0, false] && {(life_adminEvent param [2, 0]) isEqualTo 10}) then {
        life_adminEvent = [false, false, 0, 0]; publicVariable "life_adminEvent";
        [[0, "The lizard police have shed back to human form. Allegedly."], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;};};
