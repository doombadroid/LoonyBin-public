#include "..\macro.h"
waitUntil {!(isNull(findDisplay 46))};
// owner 2026-06-27: the volunteer 99 is injected in fn_requestReceived (case independent) BEFORE
// life_medicLevel is __SETCONST__'d, so an un-whitelisted medic-slot picker arrives here already as 99
// and passes the whitelist gate below as an "EMT Volunteer". (Suda's old `if (_medLevel isEqualTo 0) then
// {_medLevel = 99}` here was doubly dead: _medLevel was an undefined local AND life_medicLevel is a
// compile-final const that can't be reassigned client-side -- so it errored and changed nothing.)
if ((call life_medicLevel) < 1 && {(call life_medicLevel) != 99}) exitWith {["NotWhitelisted", false, true] call BIS_fnc_endMission;
    uiSleep 35;};
["waitForPlay"] call life_fnc_welcomeUI;
player setVariable["plb_medLevel", (call life_medicLevel), true];
life_medPartners = [];
[] call life_fnc_spawnMenu;
waitUntil {!isNull(findDisplay 38500)};
waitUntil {isNull(findDisplay 38500)};
life_maxWeight = 90;
life_maxTalents = 16;
[uniform player, "setUniform", ""] call life_fnc_clothingTextures;
// owner 2026-06-16 (#263): re-paint the saved BACKPACK skin on spawn too (was uniform-only -> custom/invisible
// medic backpacks reverted to default after a restart).
if !(backpack player isEqualTo "") then { [backpack player, "setBackpack", ""] call life_fnc_clothingTextures; };
[] spawn life_fnc_medicMarkers;
[] spawn life_fnc_medicHexs;

// owner 2026-07-12: everyone carries a GPS -- the map's G-search / route HUD is gated on it
if !("ItemGPS" in assignedItems player) then { player linkItem "ItemGPS"; };
