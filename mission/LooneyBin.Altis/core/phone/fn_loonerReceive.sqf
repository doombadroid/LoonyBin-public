/*
    life_fnc_loonerReceive  (client) -- server pushes the Looner feed here.
    Arg: [ [[name, message, "Mon DD HH:MM"], ...] ]  (already oldest -> newest).
    Stashes it + re-renders looner.home IF the browser is open on it.
*/
params [["_feed", [], [[]]]];
PLB_loonerFeed = _feed;

// if the browser is currently showing Looner, refresh the page in place
if (!isNull (findDisplay 936100) && {(missionNamespace getVariable ["life_browser_url", ""]) find "looner." == 0}) then {
    ["go", life_browser_url] call life_fnc_browser;};
