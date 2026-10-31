/*
    TON_fnc_eventParticipants  (LooneyBin rename layer)  ->  PLB_fnc_addToEvent [2017]
    2020 client args : [true, player]
    2017 fn params   : _unit(@0), _add(@1)
    ADAPT (known behaviour drift — passthrough is a stub)
*/
// LooneyBin 2026-06-09: 2020 client sends [add(BOOL), unit]; the 2017 fn wants [unit, add] -- the
// passthrough fed a BOOL into the unit slot so the event queue NEVER populated (Battle Royale's
// last-alive winner check reads that queue). Swap the args.
params [["_add", true, [true]], ["_unit", objNull, [objNull]]];
[_unit, _add] call PLB_fnc_addToEvent;
