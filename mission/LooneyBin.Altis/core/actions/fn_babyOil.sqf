#include "..\..\macro.h"
/*
    life_fnc_babyOil  (LooneyBin, owner 2026-06-25) -- use a Baby Oil (virtual Y item) on a RESTRAINED player to
    strip them down to their underwear. Runs on the USER's client (the "Cover in Baby Oil" scroll action). Validates
    the target is restrained + close, consumes 1 Baby Oil, then asks the TARGET's own client to do the strip + show
    the message (life_fnc_babyOilStrip, CfgRE allowedTargets=1 -- a remote unit's own client owns its gear).
*/
params [["_unit", objNull, [objNull]]];
if (isNull _unit || {player isEqualTo _unit} || {!(_unit isKindOf "CAManBase")} || {!(isPlayer _unit)}) exitWith {};
if !(_unit getVariable ["plb_restrained", false]) exitWith {["They need to be restrained first.", "basic"] spawn life_fnc_handleMessage;};
if (player distance _unit > 5) exitWith {};
if (life_inv_babyoil < 1) exitWith {["You don't have any Baby Oil.", "basic"] spawn life_fnc_handleMessage;};
if !([false, "babyoil", 1] call life_fnc_handleInv) exitWith {};   // consume 1 (false = remove)
[[], "life_fnc_babyOilStrip", _unit] spawn life_fnc_MP;            // strip + message the target on their own client
["You slathered them in baby oil — they're stripped down to their underwear.", "basic"] spawn life_fnc_handleMessage;
[["-BABYOIL-", player, profileName, format ["baby-oiled %1 (%2) -> stripped to underwear at %3", name _unit, getPlayerUID _unit, getPosATL player]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
