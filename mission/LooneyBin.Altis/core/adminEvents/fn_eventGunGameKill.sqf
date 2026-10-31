params[["_target", objNull, [objNull]], ["_progress", false, [false]], ["_deadBody", objNull, [objNull]]];
if (isNull _target) exitWith {};
if !(playerSide isEqualTo civilian) exitWith {};
if !(life_inEvent) exitWith {};
if (_progress) then {life_gunGameKills = (life_gunGameKills + 1) min 15;} else {cutText["", "BLACK FADED"];
    0 cutFadeOut 7.5;
    life_isDead = false;
    life_corpse = _deadBody;
    if !(isNull life_corpse) then {private _containers = nearestObjects[life_corpse, ["WeaponHolderSimulated"], 5]; {deleteVehicle _x}
        forEach _containers;
        hideBody life_corpse;};
    if !(playerSide isEqualTo west) then {life_cash = 0;
        life_cashCacheB = ((life_cash / 4) + 9);}; {_x setVariable["plb_aggressive", nil];}
    forEach allPlayers;
    waitUntil {alive player};
    private _plb_pos = ((["getLocationByID", (life_adminEvent select 3)] call life_fnc_eventCfg) select 2);
    if (!isNil "_plb_pos") then {while {
            _plb_pos isEqualTo((["getLocationByID", (life_adminEvent select 3)] call life_fnc_eventCfg) select 2)}
        do {
            _plb_pos = [((["getLocationByID", (life_adminEvent select 3)] call life_fnc_eventCfg) select 2), 1, 250, 1, 0, 0, 0, [], ((["getLocationByID", (life_adminEvent select 3)] call life_fnc_eventCfg) select 2)] call BIS_fnc_findSafePos;
        }; uiSleep ((random 3) + 2);
        player setPos _plb_pos;};
    life_deathCamera cameraEffect["TERMINATE", "BACK"];
    camDestroy life_deathCamera;
    player switchMove "amovpercmstpsnonwnondnon";};
private _defaultGear = [[], [], [], ["U_B_Wetsuit", []], ["V_TacVest_oli", []], ["B_Carryall_cbr", []], "H_HelmetB_light", "", [],
    ["ItemMap", "", "", "ItemCompass", "ItemWatch", "Integrated_NVG_F"]];
private _nextGun =
switch (life_gunGameKills) do {case 0: {_defaultGear set[0, ["LMG_Zafir_F", "", "", "", ["150Rnd_762x54_Box", 150], [], ""]];
            _defaultGear set[5, ["B_AssaultPack_khk", [["150Rnd_762x54_Box", 2, 150]]]];
            _defaultGear;};
    case 1: {_defaultGear set[0, ["LMG_Mk200_F", "", "", "optic_Arco", ["200Rnd_65x39_cased_Box", 200], [], ""]];
            _defaultGear set[5, ["B_AssaultPack_khk", [["200Rnd_65x39_cased_Box", 2, 200]]]];
            _defaultGear;};
    case 2: {_defaultGear set[0, ["LMG_03_F", "", "", "optic_Arco", ["200Rnd_556x45_Box_F", 200], [], ""]];
            _defaultGear set[5, ["B_AssaultPack_khk", [["200Rnd_556x45_Box_F", 2, 200]]]];
            _defaultGear;};
    case 3: {_defaultGear set[0, ["srifle_EBR_F", "", "", "optic_Arco", ["20Rnd_762x51_Mag", 20], [], ""]];
            _defaultGear set[5, ["B_AssaultPack_khk", [["20Rnd_762x51_Mag", 10, 20]]]];
            _defaultGear;};
    case 4: {_defaultGear set[0, ["arifle_MXM_F", "", "", "optic_Arco", ["30Rnd_65x39_caseless_mag", 30], [], ""]];
            _defaultGear set[5, ["B_AssaultPack_khk", [["30Rnd_65x39_caseless_mag", 10, 30]]]];
            _defaultGear;};
    case 5: {_defaultGear set[0, ["arifle_MX_Black_F", "", "", "optic_Arco", ["30Rnd_65x39_caseless_mag", 30], [], ""]];
            _defaultGear set[5, ["B_AssaultPack_khk", [["30Rnd_65x39_caseless_mag", 10, 30]]]];
            _defaultGear;};
    case 6: {_defaultGear set[0, ["arifle_MXC_Black_F", "", "", "optic_Arco", ["30Rnd_65x39_caseless_mag", 30], [], ""]];
            _defaultGear set[5, ["B_AssaultPack_khk", [["30Rnd_65x39_caseless_mag", 10, 30]]]];
            _defaultGear;};
    case 7: {_defaultGear set[0, ["arifle_Katiba_F", "", "", "optic_Arco", ["30Rnd_65x39_caseless_green", 30], [], ""]];
            _defaultGear set[5, ["B_AssaultPack_khk", [["30Rnd_65x39_caseless_green", 10, 30]]]];
            _defaultGear;};
    case 8: {_defaultGear set[0, ["SMG_03C_TR_khaki", "", "", "", ["50Rnd_570x28_SMG_03", 50], [], ""]];
            _defaultGear set[5, ["B_AssaultPack_khk", [["50Rnd_570x28_SMG_03", 10, 50]]]];
            _defaultGear;};
    case 9: {_defaultGear set[0, ["srifle_DMR_06_hunter_F", "", "", "optic_Arco", ["10Rnd_Mk14_762x51_Mag", 10], [], ""]];
            _defaultGear set[5, ["B_AssaultPack_khk", [["10Rnd_Mk14_762x51_Mag", 10, 10]]]];
            _defaultGear;};
    case 10: {_defaultGear set[0, ["srifle_DMR_01_F", "", "", "optic_Arco", ["10Rnd_762x54_Mag", 10], [], ""]];
            _defaultGear set[5, ["B_AssaultPack_khk", [["10Rnd_762x54_Mag", 10, 10]]]];
            _defaultGear;};
    case 11: {_defaultGear set[0, ["hgun_PDW2000_F", "", "", "", ["30Rnd_9x21_Mag", 30], [], ""]];
            _defaultGear set[5, ["B_AssaultPack_khk", [["30Rnd_9x21_Mag", 10, 30]]]];
            _defaultGear;};
    case 12: {_defaultGear set[0, ["arifle_sdar_F", "", "", "", ["20Rnd_556x45_UW_mag", 20], [], ""]];
            _defaultGear set[5, ["B_AssaultPack_khk", [["20Rnd_556x45_UW_mag", 10, 20]]]];
            _defaultGear;};
    case 13: {_defaultGear set[2, ["hgun_Rook40_F", "", "", "", ["30Rnd_9x21_Mag", 20], [], ""]];
            _defaultGear set[5, ["B_AssaultPack_khk", [["30Rnd_9x21_Mag", 10, 20]]]];
            _defaultGear;};
    case 14: {_defaultGear set[2, ["hgun_Pistol_heavy_02_F", "", "", "", ["6Rnd_45ACP_Cylinder", 6], [], ""]];
            _defaultGear set[5, ["B_AssaultPack_khk", [["6Rnd_45ACP_Cylinder", 10, 6]]]];
            _defaultGear;};
    default {_defaultGear;};}; if (life_gunGameKills <= 14) then {if !(life_adminEvent select 0) exitWith {};
    player setUnitLoadout _nextGun;
    if (sunOrMoon < 0.5) then {player action["nvGoggles", player];};
    if (_progress) then {[["Player Killed", 0.25, 0.25], [format["Advanced to the next tier! %1/15", life_gunGameKills], 0.25, 0.25],
            [format["%1", getText(configFile >> "CfgWeapons" >> currentWeapon player >> "DisplayName")], 0.25, 0.25, 7]
        ] spawn BIS_fnc_EXP_camp_SITREP;} else {};} else {if !(life_adminEvent select 0) exitWith {}; [
        [2, player], "TON_fnc_eventGunGameSRV", 2] spawn life_fnc_MP;};