params[["_killer", objNull, [objNull]], ["_deadPlayer", objNull, [objNull]], ["_deadPlayerSide", sideUnknown, [sideUnknown]], ["_deadPlayerGangData", [],
    [[]]], ["_killerGangData", [], [[]]
], ["_isWarKill", false, [false]], ["_hasMyBounty", false, [false]], ["_deadPlayerCopLevel", -1, [0]], ["_isSwat", false, [false]], ["_isHeadshot", false, [false]], ["_killerPos", [],
    [[]]
], ["_killDistance", -1, [0]], ["_killerVehicle", "", [""]], ["_deadPlayerVehicle", "", [""]], ["_killerUniform", "", [""]], ["_deadPlayerUniform", "", [""]]];
if (_deadPlayerCopLevel > 0 || _deadPlayerSide isEqualTo west) then {["kill", "cop", 1] spawn life_fnc_handleQuest;
    if (_deadPlayerCopLevel >= 4) then {["kill", "sgtpluskill", 1] spawn life_fnc_handleQuest;};
    if (_deadPlayerCopLevel isEqualTo 6) then {["kill", "captainkill", 1] spawn life_fnc_handleQuest;};
    if (_isSwat) then {["kill", "swatkill", 1] spawn life_fnc_handleQuest;};
    if (_isHeadshot) then {["kill", "copheadshot", 1] spawn life_fnc_handleQuest;};
    if ((_killerPos distance(getMarkerPos "fed_robbery_marker") <= 350) && !((nearestObjects[_killerPos, ["Land_Cargo_Patrol_V1_F"], 12]) isEqualTo[])) then {
        ["kill", "copdeerstand", 1] spawn life_fnc_handleQuest;};
    if (_killerPos distance(getMarkerPos "life_bank") <= 450) then {["kill", "copbankkill", 1] spawn life_fnc_handleQuest;};
    if (_deadPlayerVehicle in ["O_MRAP_02_F", "B_MRAP_01_F", "I_MRAP_03_F"]) then {["kill", "coparmorkill", 1] spawn life_fnc_handleQuest;
    };};
if (_deadPlayerVehicle in ["O_MRAP_02_F"]) then {["kill", "civifritkill", 1] spawn life_fnc_handleQuest;};
if (_killerVehicle in ["B_G_Offroad_01_armed_F", "I_C_Offroad_02_LMG_F", "O_LSV_02_armed_F"]) then {
    ["kill", "armedvehicle", 1] spawn life_fnc_handleQuest;};
if (_killerUniform in ["U_I_GhillieSuit", "U_B_FullGhillie_sard", "U_B_FullGhillie_ard", "U_B_FullGhillie_lsh", "U_B_T_FullGhillie_tna_F"]) then {
    ["kill", "ghillekill", 1] spawn life_fnc_handleQuest;};
if (_isWarKill) then {["kill", "warredgang", 1] spawn life_fnc_handleQuest;};
if (_hasMyBounty) then {["kill", "hasmybounty", 1] spawn life_fnc_handleQuest;};
if (_deadPlayer getVariable["plb_isBountyHunter", false]) then {["kill", "bhkill", 1] spawn life_fnc_handleQuest;};