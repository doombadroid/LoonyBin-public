#include "..\..\macro.h"
/*
    life_fnc_babyOilStrip  (LooneyBin, owner 2026-06-25) -- runs on the RESTRAINED target's OWN client (remoteExec'd
    by life_fnc_babyOil via life_fnc_MP; CfgRE allowedTargets=1). Strips them to their underwear (weapons + worn
    clothing/containers + linked items all removed -> the gear is GONE, not dropped) and tells them they got oiled.
*/
if (isNull player) exitWith {};
removeAllWeapons player;
removeGoggles player;
removeHeadgear player;
{ player unlinkItem _x } forEach (assignedItems player);   // map/compass/GPS/watch/NVG/binos etc.
removeVest player;
removeBackpackGlobal player;
removeUniform player;                                      // -> down to underwear
["You're covered in baby oil", "basic"] spawn life_fnc_handleMessage;
