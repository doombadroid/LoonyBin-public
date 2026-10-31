params[["_factoryType", "", [""]]];
if !(isNull(findDisplay 1800)) exitWith {};
["life_factory_menu"] call life_fnc_createDialog;
disableSerialization;
waitUntil {!isNull(findDisplay 1800)};
private _display = findDisplay 1800;
private _recipeList = _display displayCtrl 1850;
private _recipes =
switch (toLower _factoryType) do {case "vehicles": {
            ["C_Hatchback_01_F", "C_SUV_01_F", "C_Hatchback_01_sport_F", "C_Van_01_transport_F", "C_Van_01_box_F", "I_Truck_02_transport_F", "I_Truck_02_covered_F", "B_Truck_01_transport_F", "B_Truck_01_box_F", "C_Heli_Light_01_civil_F", "B_Heli_Light_01_F", "I_Heli_Transport_02_F", "I_Heli_light_03_unarmed_F", "O_Heli_Light_02_unarmed_F"]
        }; case "blackmarket": {
                ["B_G_Offroad_01_F", "B_G_Offroad_01_armed_F", "O_LSV_02_armed_F", "O_MRAP_02_F", "B_MRAP_01_F", "I_Heli_light_03_unarmed_F", "O_Heli_Light_02_unarmed_F", "I_C_Offroad_02_LMG_F", "arifle_CTAR_blk_F", "arifle_CTAR_hex_F", "arifle_CTAR_ghex_F", "arifle_Katiba_F", "arifle_Katiba_C_F", "srifle_DMR_01_F", "srifle_EBR_F", "srifle_DMR_03_khaki_F", "srifle_DMR_03_multicam_F", "srifle_DMR_03_tan_F", "srifle_DMR_03_woodland_F", "srifle_DMR_06_olive_F", "srifle_DMR_06_camo_F", "arifle_AKM_F", "arifle_AK12_F", "arifle_SPAR_03_khk_F", "arifle_SPAR_03_snd_F", "LMG_03_F", "LMG_Mk200_F", "30Rnd_580x42_Mag_F", "30Rnd_65x39_caseless_green", "10Rnd_762x54_Mag", "20Rnd_762x51_Mag", "30Rnd_762x39_Mag_F", "RPG7_F", "HandGrenade", "V_PlateCarrier1_blk", "V_PlateCarrier1_rgr_noflag_F", "V_PlateCarrier1_tna_F", "V_PlateCarrier1_wdl", "V_PlateCarrierGL_blk", "V_CarrierRigKBT_01_EAF_F", "V_CarrierRigKBT_01_Olive_F", "V_CarrierRigKBT_01_light_Olive_F", "V_TacVest_blk", "V_TacVest_brn", "V_TacVest_camo", "V_TacVest_khk", "V_TacVest_oli", "V_TacVestIR_blk", "V_HarnessOGL_brn", "hgun_Pistol_Signal_F", "hgun_Pistol_01_F", "hgun_Rook40_F", "hgun_Pistol_heavy_02_F", "SMG_05_F", "sgun_HunterShotgun_01_sawedoff_F", "sgun_HunterShotgun_01_F", "SMG_03C_TR_khaki", "SMG_03C_TR_camo", "SMG_03C_TR_hex", "SMG_03C_TR_black", "SMG_03_TR_khaki", "SMG_03_TR_camo", "SMG_03_TR_hex", "SMG_03_TR_black", "arifle_sdar_F", "arifle_Mk20_plain_F", "arifle_Mk20C_plain_F", "arifle_ARX_hex_F", "srifle_DMR_03_F", "arifle_MSBS65_F", "arifle_MSBS65_Mark_F", "arifle_AKS_F", "arifle_CTAR_GL_blk_F", "arifle_CTAR_GL_hex_F", "arifle_CTAR_GL_ghex_F", "arifle_Katiba_GL_F", "srifle_DMR_06_hunter_F", "arifle_AK12_lush_f", "arifle_AK12U_lush_f", "arifle_TRG21_F", "LMG_Mk200_black_F", "LMG_Zafir_F", "arifle_RPK12_lush_F", "arifle_RPK12_arid_F", "launch_RPG7_F", "V_PlateCarrierL_CTRG", "V_PlateCarrier2_rgr", "V_PlateCarrier2_blk", "V_PlateCarrier2_rgr_noflag_F", "V_PlateCarrierIA2_dgtl", "V_PlateCarrierSpec_rgr", "V_PlateCarrierSpec_blk", "V_PlateCarrierSpec_mtp", "V_PlateCarrierGL_rgr", "V_I_G_resistanceLeader_F", "V_LegStrapBag_olive_F", "V_Chestrig_rgr", "V_Chestrig_khk", "V_HarnessOSpec_brn", "V_HarnessOSpec_gry", "V_Chestrig_blk", "V_Chestrig_oli", "V_HarnessO_gry", "V_LegStrapBag_coyote_F", "V_LegStrapBag_black_F", "optic_Aco_smg", "optic_Holosight_smg", "optic_Holosight_smg_blk_F", "optic_Holosight_blk_F", "optic_ACO_grn_smg", "optic_ACO_grn", "optic_ACO_smg", "optic_Holosight_khk_F", "optic_Hamr_khk_F", "optic_Arco_blk_F", "optic_Arco_ghex_F", "optic_Arco_AK_blk_F", "optic_ERCO_khk_F", "optic_ERCO_snd_F", "optic_Yorris", "optic_MRD", "optic_MRD_black", "optic_DMS", "optic_AMS"]
            }; case "weapons": {
                    ["30Rnd_45ACP_Mag_SMG_01", "30Rnd_9x21_Mag", "9Rnd_45ACP_Mag", "hgun_ACPC2_F", "hgun_PDW2000_F", "SMG_02_F", "SMG_01_F", "optic_ACO", "optic_Holosight", "optic_Arco", "optic_ERCO_blk_F", "optic_MRCO", "optic_hamr"]
                };
                default {[]};}; if (_recipes isEqualTo[]) exitWith {};
lbClear _recipeList;
(arms_flag getVariable["plb_capData", [0, "Neutral", 0.5]]) params["_flagGangID", "_flagGangName", "_progress"];
life_garageCount = -1; [[getPlayerUID player, playerSide, player], "TON_fnc_garageCount", 2] spawn life_fnc_MP;
private _armsOwner = (life_gang_data param[0, -5]) isEqualTo _flagGangID;
private _armsVeh = ["B_G_Offroad_01_armed_F", "O_LSV_02_armed_F", "LMG_03_F", "RPG7_F", "V_HarnessOGL_brn"]; {private _show =
    if (_x in _armsVeh) then {_armsOwner} else {true};
    if (_show) then {(switch (true) do {case (isClass(configFile >> "CfgWeapons" >> _x)): {
                    ["CfgWeapons", getText(configFile >> "CfgWeapons" >> _x >> "displayName"), getText(configFile >> "CfgWeapons" >> _x >> "picture")]
                };
            case (isClass(configFile >> "CfgVehicles" >> _x)): {
                    ["CfgVehicles", getText(configFile >> "CfgVehicles" >> _x >> "displayName"), getText(configFile >> "CfgVehicles" >> _x >> "picture")]
                };
            case (isClass(configFile >> "CfgMagazines" >> _x)): {
                    ["CfgMagazines", getText(configFile >> "CfgMagazines" >> _x >> "displayName"), getText(configFile >> "CfgMagazines" >> _x >> "picture")]
                };
            default {[configNull, "", ""]};}) params["_cfgType", "_name", "_icon"];
        if (_x isEqualTo "V_HarnessOGL_brn") then {_name = "Suicide Vest";};
        private _index = _recipeList lbAdd _name;
        _recipeList lbSetData[_index, _x];
        _recipeList lbSetPicture[_index, _icon];};}
forEach _recipes;
private _name =
switch (toLower _factoryType) do {case "weapons": {"Firearm Production Factory"}; case "vehicles": {
                "Vehicle Production Factory"}; case "blackmarket": {"Black Market Production"}; default {"Factory Production"};};
( _display displayCtrl 1835) ctrlSetText _name;
lbSetCurSel[1850, 0];