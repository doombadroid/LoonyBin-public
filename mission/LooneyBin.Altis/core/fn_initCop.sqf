#include "..\macro.h"
waitUntil {!(isNull(findDisplay 46))};
if ((call(life_copLevel) isEqualTo 0) && (call(life_adminLevel) isEqualTo 0)) exitWith {
    ["NotWhitelisted", false, true] call BIS_fnc_endMission;
    uiSleep 15;};
if (((str player) in ["cop_warrant_1", "cop_warrant_2", "cop_warrant_3", "cop_warrant_4", "cop_warrant_5", "cop_medic_1", "cop_medic_2", "cop_medic_3", "cop_medic_4"]) && !((call life_copLevel) >= 3)) exitWith {
    ["NotWhitelisted", false, false] call BIS_fnc_endMission;
    uiSleep 15;};
// owner 2026-06-19: undercover (detective) slots are now a PURE WHITELIST (players.isdetective -> life_isDetective),
// NOT a rank gate. Anyone whitelisted via officer_maggot `!detective <pid> on` takes a cop_detective_* slot at ANY
// rank; non-whitelisted are bounced. (Was: copLevel >= 4 / Sgt+.) Warrant/medic slots stay rank-gated above. The
// detective ROLE/features downstream (coprole="detective" @ ~L60 -> plb_showrank false + loadout/clothing) are
// unchanged -- passing this gate is all it takes.
if (((str player) in ["cop_detective_1", "cop_detective_2", "cop_detective_3", "cop_detective_4"]) && !(life_isDetective)) exitWith {
    ["NotWhitelisted", false, false] call BIS_fnc_endMission;
    uiSleep 15;};
if (((str player) in ["cop_17"]) && (call(life_copLevel) <= 3)) exitWith {["SGTSlot", false, false] call BIS_fnc_endMission;
    uiSleep 15;};
if (isClass(configFile >> "CfgVehicles" >> "gm_ge_army_iltis_cargo")) exitWith {["BadDLC", false, false] call BIS_fnc_endMission;
    uiSleep 15;};
private _copCount = {side _x isEqualTo west}
count playableUnits;
private _civCount = {side _x in [civilian, independent]}
count playableUnits;
// owner 2026-06-14: cop population cap REMOVED. Cops were kicked ("TooManyCops") when the cop:civ ratio
// got too high (>5 cops & <=20 civs, etc.). Now any whitelisted player can take any open cop slot regardless
// of civ pop -- the number of cop_* slots in mission.sqm is the only limit. (_civCount kept for the log below.)
["waitForPlay"] call life_fnc_welcomeUI;
player setVariable["plb_copLevel", call life_copLevel, true];
player setVariable["plb_copRetiredLevel", call life_copRetiredLevel, true];
// owner 2026-06-20: OWNER cop rank -- re-apply the persisted custom rank title (profileNamespace) onto the fresh
// unit each cop spawn so it survives relog/respawn. Owner-only (locked UID); set via the "Set My APD Title" action.
if ((getPlayerUID player) isEqualTo "76561190000000001") then {private _oct = profileNamespace getVariable ["plb_ownerCopTitle", ""];
    if (_oct isNotEqualTo "") then { player setVariable ["plb_ownerCopTitle", _oct, true]; };};
// owner 2026-06-16: cops DEFAULT non-lethal (down/taze) -- that's intended. The real bug wasn't the default,
// it was that ANY single cop-weapon hit downed instantly (1-shot taze, armor ignored). Fix is in
// fn_handleDamage: stun hits now ACCUMULATE and the hits-to-down SCALE with the target's armour. Spec:
// bare body = 1 hit, basic plate carrier = 6, headshot = 1 (instant), helmeted head = 2; heavier rigs and
// armoured vehicles scale higher (PLB_stun* tunables in init.sqf).
player setVariable["plb_nonlethal", true, true];
life_coprole =
switch (true) do {case (call life_copLevel >= 6 || call life_adminLevel >= 3): {"all"};
    case ((str player) in ["cop_warrant_1", "cop_warrant_2", "cop_warrant_3", "cop_warrant_4", "cop_warrant_5"]): {"warrant"};
    case ((str player) in ["cop_medic_1", "cop_medic_2", "cop_medic_3", "cop_medic_4"]): {"medic"};
    case ((str player) in ["cop_detective_1", "cop_detective_2", "cop_detective_3", "cop_detective_4"]): {"detective"};
    default {
        // owner 2026-07-15: was "" -- and fn_addPrestige/fn_earnPrestige hard-exit on an empty coprole, so every
        // cop below rank 6 in a plain cop_N slot earned ZERO prestige forever (only rank 6+/admins got "all";
        // Jeff Stall: 976 cop_exp, 0 prestige). "patrol" satisfies the prestige gate and matches no perk check
        // (medic/detective/warrant gear+abilities all test explicit role lists).
        "patrol"};}; player setVariable["plb_copRole", life_coprole, true];
if (life_coprole in ["detective", "all"]) then {player setVariable["plb_showrank", false, true];} else {
    player setVariable["plb_showrank", true, true];};
[] call life_fnc_spawnMenu;
waitUntil {!isNull(findDisplay 38500)};
waitUntil {isNull(findDisplay 38500)};
life_maxWeight = 90;
life_maxTalents = 20;
if ((call life_copLevel) > 2) then {life_maxTalents = life_maxTalents + (2 * ((call life_copLevel) - 2));};
[] spawn life_fnc_trackMarkers;
[uniform player, "setUniform", ""] call life_fnc_clothingTextures;
// owner 2026-06-16 (#263): also re-paint the BACKPACK skin on spawn. fn_requestReceived restored the cop's
// saved skins (plb_clothingSkinsCop) on login but only the uniform was re-applied here, so an invisible/
// custom backpack reverted to default after a restart. (Pairs with the copLoadout preserve-idx fix.)
if !(backpack player isEqualTo "") then { [backpack player, "setBackpack", ""] call life_fnc_clothingTextures; };
life_track_radius =
switch (true) do {case (8 in life_cop_talents): {200};
    case (7 in life_cop_talents): {300};
    case (6 in life_cop_talents): {400};
    case (5 in life_cop_talents): {500};
    case (4 in life_cop_talents): {800};
    case (3 in life_cop_talents): {900};
    case (2 in life_cop_talents): {1000};
    default {1400};}; private _copAll = count(allPlayers select {(_x getVariable["plb_copRole", ""] isEqualTo "all")});
private _copDetective = count(allPlayers select {(_x getVariable["plb_copRole", ""] isEqualTo "detective")});
private _copMedic = count(allPlayers select {(_x getVariable["plb_copRole", ""] isEqualTo "medic")});
private _copWarrant = count(allPlayers select {(_x getVariable["plb_copRole", ""] isEqualTo "warrant")});
if (life_coprole in ["all", "warrant", "detective", "medic"]) then {
    if (_copAll > 0 || _copDetective > 0 || _copMedic > 0 || _copWarrant > 0) then {[
            ["-COPCOUNT-", player, profileName, format["logged on with %1 cops online. %2 detectives, %3 cop medics, %4 warrant officers and %5 cop role all online.", _copCount, _copDetective, _copMedic, _copWarrant, _copAll]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
    };};
// owner 2026-07-12: everyone carries a GPS -- the map's G-search / route HUD is gated on it
if !("ItemGPS" in assignedItems player) then { player linkItem "ItemGPS"; };
