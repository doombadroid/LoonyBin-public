/*
    life_fnc_loonazonCfg  (LooneyBin, owner 2026-07-16) -- Loonazon catalog v2: the STANDALONE APP's shop.
    Three storefront categories, stock pulled from the real shops (gen store = the town market's virtual buy
    list + the general store's physical gear; rebel = the full rebel armory; seeds = the drug store's seeds
    only), all at a 1.2x CONVENIENCE MARKUP -- a robot van hauls it to a field for you. Compiled client AND
    server (mission CfgFunctions), so the server prices/validates from the same table the app renders.
    Built ONCE into a mission-namespace cache (the virtItemCfg pattern) -- config lookups are heavy.

    Item rows: [class, displayName, price, isPhys, weight, icon]
      isPhys: true = real-inventory gear (weapons/mags/items) -> box plb_pinv; false = virtual -> plb_vinv
      weight: virtual = virtItemCfg weight; physical = CfgWeights weight (the house-storage accounting)
      ["cats"]          -> [[key, label], ...]
      ["items", cat]    -> item rows for that category
      ["get", class]    -> row or [] (searched across all categories)
      ["fee"]           -> flat delivery fee
      ["vcap"] / ["pcap"] -> cart weight caps (virtual 3000 / physical 960)
      ["source", cat]   -> dispatch-store positions for a category
*/
params [["_mode", "list", [""]], ["_arg", "", [""]]];

private _cats = [["gen", "GEN STORE"], ["rebel", "ARMORY"], ["drip", "REBEL DRIP"], ["ritems", "REB SUPPLY"], ["seeds", "SEEDS"]];

// ---- build the catalog cache once ----
private _cache = missionNamespace getVariable ["PLB_lzCatalog", createHashMap];
if (count _cache isEqualTo 0) then {private _mk = 1.2;   // convenience markup over shop price
    private _fnVirt = {   // virtual item -> row (name/weight/icon/price from virtItemCfg)
        params ["_cls"];
        private _pr = ["getMaxPrice", _cls] call life_fnc_virtItemCfg;
        if (!(_pr isEqualType 0) || {_pr <= 0}) exitWith { [] };
        [_cls, ["getName", _cls] call life_fnc_virtItemCfg, round (_pr * 1.2), false,
         ["getItemWeight", _cls] call life_fnc_virtItemCfg, ["getIcon", _cls] call life_fnc_virtItemCfg]};
    private _fnPhys = {   // physical item -> row (name/icon from configFile, weight from CfgWeights)
        params ["_cls", "_shopPrice"];
        // LooneyBin Economy: honor the owner weap price-override (the same life_fnc_priceOv source the real
        // shops use) so Loonazon tracks the LIVE rebel price BEFORE the 1.2x convenience markup -- otherwise it
        // sold from its static base and ignored admin overrides (Zafir override $150,000 was selling at
        // $50,000x1.2=$60,000). Now $150,000x1.2 = $180,000. (Cache rebuilds each restart, so overrides set
        // mid-session sync on the next reboot; server-side order validation always uses the server's live row.)
        private _ov = ["weap", _cls] call life_fnc_priceOv;
        if (_ov isNotEqualTo [] && {(_ov select 2) >= 0}) then { _shopPrice = _ov select 2; };
        private _cfg = configFile >> "CfgWeapons" >> _cls;
        if (!isClass _cfg) then { _cfg = configFile >> "CfgMagazines" >> _cls; };
        if (!isClass _cfg) then { _cfg = configFile >> "CfgGlasses" >> _cls; };
        if (!isClass _cfg) then { _cfg = configFile >> "CfgVehicles" >> _cls; };   // backpacks
        if (!isClass _cfg) exitWith { [] };
        [_cls, getText (_cfg >> "displayName"), round (_shopPrice * 1.2), true,
         (getNumber (missionConfigFile >> "CfgWeights" >> _cls >> "weight")) max 1, getText (_cfg >> "picture")]};

    // GEN STORE: town market virtual buy list + the general store's physical gear (weaponShopCfg "genstore")
    private _gen = [];
    { private _r = [_x] call _fnVirt; if (_r isNotEqualTo []) then { _gen pushBack _r; }; }
        forEach ((["market"] call life_fnc_virt_shops) param [1, []]); {_x params ["_cls", "_pr"];
        private _r = [_cls, _pr] call _fnPhys;
        if (_r isNotEqualTo []) then { _gen pushBack _r; };} forEach [
        ["ToolKit", 50], ["FirstAidKit", 75], ["ItemGPS", 10], ["ItemMap", 10], ["ItemCompass", 10],
        ["ItemWatch", 10], ["Binocular", 100], ["Integrated_NVG_F", 300], ["NVGoggles", 300]];

    // REBEL ARMORY: the rebel weapon shop's full stock (extracted from fn_weaponShopCfg "rebelwep")
    private _reb = [];
    private _fnMagPrice = { params ["_mag"];
        // Rebel armory (fn_weaponAddons rebelwep) magazine pricing: the dynamic mag block (L502-536) sells
        // EVERY gun magazine at a flat $100, with two explicit overrides pushed before it -- the RPG7_F rocket
        // ("PG7VM HEAT Grenade") at $140,000 and the Zafir 150Rnd_762x54_Box at $10,000. Loonazon applies the
        // ×1.2 markup below, so these land at exactly 20% over rebel: RPG $168,000, Zafir belt $12,000, every
        // other mag $120. (owner 2026-07-17 price audit -- the old 4-bucket 200/500 guess overcharged most mags
        // and 20x-UNDERcharged the Zafir belt at $600.)
        if (_mag find "RPG" > -1) exitWith { 140000 };
        if (_mag isEqualTo "150Rnd_762x54_Box") exitWith { 10000 };
        100}; {_x params ["_cls", "_pr"];
        private _r = [_cls, _pr] call _fnPhys;
        if (_r isNotEqualTo []) then {_reb pushBack _r;
            // its magazine, indented right under the gun (fixed per-mag pricing so every listing agrees)
            if (isClass (configFile >> "CfgWeapons" >> _cls)) then {
                private _mag = (getArray (configFile >> "CfgWeapons" >> _cls >> "magazines")) param [0, ""];
                if (_mag isNotEqualTo "" && {isClass (configFile >> "CfgMagazines" >> _mag)}) then {
                    private _mr = [_mag, [_mag] call _fnMagPrice] call _fnPhys;
                    if (_mr isNotEqualTo []) then {_mr set [1, format ["    +  %1", _mr select 1]];
                        _mr set [2, round (([_mag] call _fnMagPrice) * 1.2)];
                        _reb pushBack _mr;};};};};} forEach [
        ["hgun_Pistol_Signal_F", 500], ["hgun_Pistol_01_F", 1250], ["hgun_Rook40_F", 1500], ["hgun_ACPC2_F", 2500],
        ["hgun_Pistol_heavy_02_F", 2500], ["SMG_05_F", 3500], ["hgun_PDW2000_F", 3500], ["SMG_01_F", 4000],
        ["sgun_HunterShotgun_01_sawedoff_F", 5000], ["sgun_HunterShotgun_01_F", 6000],
        ["SMG_03C_TR_khaki", 6000], ["SMG_03C_TR_camo", 6000], ["SMG_03C_TR_hex", 6000], ["SMG_03C_TR_black", 6000],
        ["SMG_03_TR_khaki", 7000], ["SMG_03_TR_camo", 7000], ["SMG_03_TR_hex", 7000], ["SMG_03_TR_black", 7000],
        ["arifle_sdar_F", 3500], ["arifle_Mk20_plain_F", 3500], ["arifle_Mk20C_plain_F", 3500],
        ["arifle_ARX_hex_F", 6000], ["arifle_MSBS65_F", 5000], ["arifle_MSBS65_Mark_F", 6000],
        ["arifle_AK12_F", 5000], ["arifle_AK12_lush_F", 5000], ["arifle_AK12_arid_F", 5000], ["arifle_AK12U_lush_f", 6500],
        ["arifle_AKS_F", 3500], ["arifle_AKM_F", 6000],
        ["arifle_CTAR_blk_F", 4500], ["arifle_CTAR_hex_F", 4500], ["arifle_CTAR_ghex_F", 4500],
        ["arifle_CTAR_GL_blk_F", 5500], ["arifle_CTAR_GL_hex_F", 5500], ["arifle_CTAR_GL_ghex_F", 5500],
        ["arifle_Katiba_F", 5000], ["arifle_Katiba_C_F", 5000], ["arifle_Katiba_GL_F", 6000],
        ["arifle_TRG21_F", 4000], ["arifle_SPAR_01_khk_F", 5000], ["arifle_SPAR_01_snd_F", 5000],
        ["arifle_SPAR_03_khk_F", 7000], ["arifle_SPAR_03_snd_F", 7000],
        ["srifle_DMR_01_F", 5000], ["srifle_DMR_03_F", 9000], ["srifle_DMR_03_khaki_F", 9000],
        ["srifle_DMR_03_multicam_F", 9000], ["srifle_DMR_03_tan_F", 9000], ["srifle_DMR_03_woodland_F", 9000],
        ["srifle_DMR_06_olive_F", 6500], ["srifle_DMR_06_camo_F", 6500], ["srifle_DMR_06_hunter_F", 5000], ["srifle_EBR_F", 8000],
        ["LMG_Mk200_F", 9000], ["LMG_Mk200_black_F", 9000], ["LMG_03_F", 30000], ["LMG_Zafir_F", 50000],
        ["arifle_RPK12_lush_F", 20000], ["arifle_RPK12_arid_F", 20000], ["launch_RPG7_F", 30000], ["HandGrenade", 5000],
        ["SmokeShell", 100], ["SmokeShellRed", 100], ["SmokeShellGreen", 100], ["SmokeShellYellow", 100],
        ["SmokeShellPurple", 100], ["SmokeShellBlue", 100], ["SmokeShellOrange", 100],
        ["1Rnd_Smoke_Grenade_shell", 250], ["1Rnd_SmokeRed_Grenade_shell", 250], ["1Rnd_SmokeGreen_Grenade_shell", 250],
        ["1Rnd_SmokeYellow_Grenade_shell", 250], ["1Rnd_SmokePurple_Grenade_shell", 250], ["1Rnd_SmokeBlue_Grenade_shell", 250],
        ["1Rnd_SmokeOrange_Grenade_shell", 250],
        ["Rangefinder", 1000], ["NVGoggles_INDEP", 300], ["O_NVGoggles_grn_F", 300], ["O_NVGoggles_urb_F", 300],
        ["O_NVGoggles_ghex_F", 300], ["O_NVGoggles_hex_F", 300], ["NVGoggles_tna_F", 300],
        ["Chemlight_green", 50], ["Chemlight_red", 50], ["Chemlight_yellow", 50], ["Chemlight_blue", 50]];

    // SEED BANK: the drug store's SEEDS only
    private _seeds = [];
    { private _r = [_x] call _fnVirt; if (_r isNotEqualTo []) then { _seeds pushBack _r; }; }
        forEach ["cannas_0", "cannai_0"];

    // REBEL DRIP: the rebel clothing shop's full rack (extracted from fn_clothing_reb -- that fn is
    // client-UI-bound, so the rows live here). Uniforms/hats/glasses/vests/backpacks, all physical.
    private _drip = []; {_x params ["_cls", "_pr"];
        private _r = [_cls, _pr] call _fnPhys;
        if (_r isNotEqualTo []) then { _drip pushBack _r; };} forEach [["U_IG_Guerilla1_1", 300], ["U_IG_leader", 300],
        ["U_I_G_resistanceLeader_F", 300], ["U_I_G_Story_Protagonist_F", 300], ["U_I_CombatUniform", 300],
        ["U_I_CombatUniform_tshirt", 300], ["U_I_OfficerUniform", 300], ["U_O_CombatUniform_oucamo", 6000], ["U_OG_Guerrilla_6_1", 300],
        ["U_B_survival_uniform", 1000], ["U_MillerBody", 300], ["U_KerryBody", 300], ["U_B_CombatUniform_mcam", 300],
        ["U_B_CombatUniform_mcam_tshirt", 300], ["U_B_CombatUniform_mcam_vest", 300], ["U_B_CTRG_Soldier_F", 300],
        ["U_B_CTRG_Soldier_3_F", 300], ["U_B_CTRG_Soldier_2_F", 300], ["U_B_CTRG_Soldier_urb_1_F", 300], ["U_B_CTRG_Soldier_urb_2_F", 300],
        ["U_B_CTRG_Soldier_urb_3_F", 300], ["U_I_C_Soldier_Para_1_F", 300], ["U_I_C_Soldier_Para_2_F", 300],
        ["U_I_C_Soldier_Para_3_F", 300], ["U_I_C_Soldier_Para_4_F", 300], ["U_I_C_Soldier_Para_5_F", 300], ["U_B_CTRG_1", 1000],
        ["U_B_CTRG_2", 1000], ["U_B_CTRG_3", 1000], ["U_C_CBRN_Suit_01_Blue_F", 300], ["U_C_CBRN_Suit_01_White_F", 300],
        ["U_I_E_Uniform_01_shortsleeve_F", 300], ["U_I_E_Uniform_01_sweater_F", 300], ["U_I_E_Uniform_01_tanktop_F", 300],
        ["U_B_CombatUniform_mcam_wdl_f", 300], ["U_B_CombatUniform_tshirt_mcam_wdL_f", 300], ["U_Tank_green_F", 300],
        ["U_I_L_Uniform_01_camo_F", 300], ["U_I_L_Uniform_01_deserter_F", 300], ["U_B_CombatUniform_vest_mcam_wdl_f", 300],
        ["U_B_Wetsuit", 250], ["U_I_GhillieSuit", 1500], ["U_B_FullGhillie_sard", 1500], ["U_B_FullGhillie_ard", 1500],
        ["U_B_FullGhillie_lsh", 1500], ["U_B_T_FullGhillie_tna_F", 1500], ["U_O_R_Gorka_01_brown_F", 6000],
        ["U_O_CombatUniform_ocamo", 6000], ["U_O_PilotCoveralls", 5000], ["U_B_T_Soldier_F", 2000], ["U_C_ArtTShirt_01_v6_F", 50],
        ["U_C_ArtTShirt_01_v1_F", 50], ["U_C_ArtTShirt_01_v3_F", 50], ["U_C_ArtTShirt_01_v5_F", 50], ["U_C_ArtTShirt_01_v2_F", 50],
        ["U_C_ArtTShirt_01_v4_F", 50], ["U_C_Uniform_Scientist_02_formal_F", 50], ["U_I_E_ParadeUniform_01_LDF_F", 300],
        ["U_I_E_ParadeUniform_01_LDF_decorated_F", 300], ["U_I_E_Uniform_01_officer_F", 300], ["U_I_E_Uniform_01_coveralls_F", 300],
        ["U_O_ParadeUniform_01_CSAT_F", 300], ["U_O_ParadeUniform_01_CSAT_decorated_F", 300], ["U_C_FormalSuit_01_blue_F", 300],
        ["U_B_CBRN_Suit_01_Wdl_F", 300], ["U_B_CBRN_Suit_01_MTP_F", 300], ["U_B_CBRN_Suit_01_Tropic_F", 300], ["U_O_Wetsuit", 250],
        ["U_C_Journalist", 50], ["U_B_ParadeUniform_01_US_F", 300], ["U_B_ParadeUniform_01_US_decorated_F", 300],
        ["U_C_FormalSuit_01_khaki_F", 300], ["U_O_R_Gorka_01_camo_F", 6000], ["U_I_Wetsuit", 250], ["U_C_Uniform_Scientist_01_F", 50],
        ["U_I_ParadeUniform_01_AAF_F", 300], ["U_I_ParadeUniform_01_AAF_decorated_F", 300], ["U_C_FormalSuit_01_gray_F", 300],
        ["U_C_FormalSuit_01_tshirt_gray_F", 300], ["U_B_Protagonist_VR", 200], ["U_O_Protagonist_VR", 200], ["U_I_Protagonist_VR", 200],
        ["U_C_FormalSuit_01_black_F", 300], ["U_C_FormalSuit_01_tshirt_black_F", 300], ["U_O_R_Gorka_01_black_F", 6000],
        ["U_C_E_LooterJacket_01_F", 50], ["U_C_Uniform_Scientist_02_F", 50], ["H_ShemagOpen_tan", 25], ["H_Shemag_tan", 25],
        ["H_Shemag_olive", 25], ["H_Shemag_olive_hs", 25], ["H_ShemagOpen_khk", 25], ["H_Cap_grn_BI", 25], ["H_Cap_blk_ION", 25],
        ["H_Cap_blk_CMMG", 25], ["H_Cap_brn_SPECOPS", 25], ["H_Cap_tan_specops_US", 25], ["H_Cap_khaki_specops_UK", 25],
        ["H_Cap_blk_Raven", 25], ["H_Cap_oli_hs", 25], ["H_MilCap_ocamo", 25], ["H_MilCap_mcamo", 25], ["H_MilCap_oucamo", 25],
        ["H_MilCap_dgtl", 25], ["H_MilCap_gry", 25], ["H_MilCap_blue", 25], ["H_MilCap_tna_F", 25], ["H_MilCap_ghex_F", 25],
        ["H_Hat_camo", 25], ["H_Cap_headphones", 25], ["H_Booniehat_tna_F", 25], ["H_Booniehat_oli", 25], ["H_Booniehat_mcamo", 25],
        ["H_Booniehat_grn", 25], ["H_Booniehat_tan", 25], ["H_Booniehat_dgtl", 25], ["H_Booniehat_khk_hs", 25], ["H_Bandanna_camo", 25],
        ["H_Bandanna_khk_hs", 25], ["H_Bandanna_mcamo", 25], ["H_Watchcap_blk", 25], ["H_Watchcap_sgg", 25], ["H_Watchcap_khk", 25],
        ["H_Watchcap_camo", 25], ["H_Watchcap_cbr", 25], ["H_Cap_Black_IDAP_F", 25], ["H_Cap_White_IDAP_F", 25], ["H_Helmet_Skate", 1500],
        ["H_HelmetSpecB_blk", 8000], ["H_HelmetSpecB", 8000], ["H_HelmetSpecB_snakeskin", 8000], ["H_HelmetCrew_B", 15000],
        ["H_HelmetCrew_O", 15000], ["H_HelmetCrew_O_ghex_F", 15000], ["H_HelmetCrew_I", 15000], ["H_Tank_black_F", 1500],
        ["H_HelmetB_light", 1500], ["H_HelmetB_light_snakeskin", 1500], ["H_Beret_blk", 50], ["H_Beret_EAF_01_F", 50], ["H_Beret_02", 50],
        ["H_Beret_Csat_01_F", 50], ["H_Construction_basic_yellow_F", 1500], ["H_HelmetB_light_wdl", 1500], ["H_Hat_Safari_olive_F", 50],
        ["H_Hat_Safari_sand_F", 50], ["H_Construction_basic_orange_F", 1500], ["H_Beret_Colonel", 50], ["H_Construction_basic_red_F", 1500],
        ["H_Construction_basic_white_F", 1500], ["H_Beret_gen_F", 50], ["H_HeadBandage_clean_F", 50],
        ["H_Construction_basic_black_F", 1500], ["H_HeadBandage_stained_F", 50], ["H_Construction_earprot_black_F", 1500],
        ["H_HeadBandage_bloody_F", 50], ["G_Balaclava_blk", 200], ["G_Balaclava_combat", 200], ["G_Balaclava_lowprofile", 200],
        ["G_Balaclava_TI_blk_F", 200], ["G_Balaclava_TI_G_blk_F", 200], ["G_Balaclava_TI_tna_F", 200], ["G_Balaclava_TI_G_tna_F", 200],
        ["G_Balaclava_oli", 150], ["G_blindfold_01_black_F", 200], ["G_blindfold_01_white_F", 200],
        ["G_AirPurifyingRespirator_02_sand_F", 200], ["G_Bandanna_aviator", 150], ["G_Bandanna_beast", 150], ["G_Bandanna_blk", 150],
        ["G_Bandanna_khk", 150], ["G_Bandanna_oli", 150], ["G_Bandanna_shades", 150], ["G_Bandanna_sport", 150], ["G_Bandanna_tan", 150],
        ["G_Aviator", 10], ["G_Tactical_Black", 10], ["G_Tactical_Clear", 10], ["G_Combat", 10], ["G_Combat_Goggles_tna_F", 10],
        ["G_Lowprofile", 10], ["G_Shades_Black", 10], ["G_Shades_Blue", 10], ["G_Spectacles", 10], ["G_Spectacles_Tinted", 10],
        ["G_Sport_Blackred", 10], ["G_Sport_Checkered", 10], ["G_Sport_Blackyellow", 10], ["G_Sport_BlackWhite", 10],
        ["G_Sport_Greenblack", 10], ["G_Sport_Red", 10], ["G_Squares", 10], ["G_Squares_Tinted", 10], ["G_Lady_Blue", 10],
        ["G_Lady_Red", 10], ["G_Lady_Mirror", 10], ["G_Lady_Dark", 10], ["G_Respirator_blue_F", 10], ["G_Respirator_white_F", 10],
        ["G_Respirator_yellow_F", 10], ["G_AirPurifyingRespirator_02_olive_F", 200], ["G_AirPurifyingRespirator_02_black_F", 200],
        ["G_AirPurifyingRespirator_01_F", 200], ["G_RegulatorMask_F", 200], ["G_EyeProtectors_F", 10], ["G_EyeProtectors_Earpiece_F", 10],
        ["G_Goggles_VR", 10], ["V_PlateCarrier1_blk", 5000], ["V_PlateCarrier1_rgr_noflag_F", 5000], ["V_PlateCarrier1_tna_F", 5000],
        ["V_PlateCarrier1_wdl", 5000], ["V_PlateCarrierL_CTRG", 5000], ["V_CarrierRigKBT_01_EAF_F", 5000],
        ["V_CarrierRigKBT_01_Olive_F", 5000], ["V_CarrierRigKBT_01_light_Olive_F", 5000], ["V_PlateCarrier2_rgr", 12000],
        ["V_PlateCarrier2_blk", 12000], ["V_PlateCarrier2_rgr_noflag_F", 12000], ["V_PlateCarrierIA2_dgtl", 12000],
        ["V_PlateCarrierSpec_rgr", 25000], ["V_PlateCarrierSpec_blk", 25000], ["V_PlateCarrierSpec_mtp", 25000],
        ["V_PlateCarrierGL_rgr", 25000], ["V_TacVest_blk", 3000], ["V_TacVest_brn", 3000], ["V_TacVest_camo", 3000],
        ["V_TacVest_khk", 3000], ["V_TacVest_oli", 3000], ["V_I_G_resistanceLeader_F", 3000], ["V_TacVestIR_blk", 3000],
        ["V_LegStrapBag_olive_F", 350], ["V_Chestrig_rgr", 200], ["V_Chestrig_khk", 200], ["V_HarnessOSpec_brn", 200],
        ["V_HarnessOSpec_gry", 200], ["V_Chestrig_blk", 200], ["V_Chestrig_oli", 200], ["V_HarnessO_gry", 200],
        ["V_HarnessOGL_brn", 235000], ["V_LegStrapBag_coyote_F", 350], ["V_LegStrapBag_black_F", 350], ["B_AssaultPack_dgtl", 250],
        ["B_AssaultPack_ocamo", 250], ["B_AssaultPack_blk", 250], ["B_AssaultPack_cbr", 250], ["B_AssaultPack_mcamo", 250],
        ["B_AssaultPack_rgr", 250], ["B_AssaultPack_khk", 250], ["B_AssaultPack_sgg", 250], ["B_AssaultPack_tna_F", 250],
        ["B_AssaultPack_eaf_F", 250], ["B_AssaultPack_wdl_F", 250], ["B_AssaultPack_Kerry", 250], ["B_FieldPack_ocamo", 250],
        ["B_FieldPack_khk", 250], ["B_FieldPack_oucamo", 250], ["B_FieldPack_cbr", 250], ["B_FieldPack_blk", 250],
        ["B_FieldPack_ghex_F", 250], ["B_Kitbag_rgr", 250], ["B_Kitbag_cbr", 250], ["B_Kitbag_mcamo", 250], ["B_Kitbag_sgg", 250],
        ["B_TacticalPack_ocamo", 250], ["B_TacticalPack_oli", 250], ["B_Bergen_sgg", 250], ["B_Bergen_mcamo", 250], ["B_Bergen_rgr", 250],
        ["B_Bergen_blk", 250], ["B_Carryall_oli", 350], ["B_Carryall_ocamo", 350], ["B_Carryall_oucamo", 350], ["B_Carryall_mcamo", 350],
        ["B_Carryall_cbr", 350], ["B_Carryall_ghex_F", 350], ["B_Carryall_khk", 350], ["B_Carryall_taiga_F", 350],
        ["B_Carryall_eaf_F", 350], ["B_Carryall_green_F", 350], ["B_Carryall_wdl_F", 350], ["B_Carryall_blk", 350],
        ["B_ViperHarness_blk_F", 350], ["B_ViperHarness_ghex_F", 350], ["B_ViperHarness_hex_F", 350], ["B_ViperHarness_khk_F", 350],
        ["B_ViperHarness_oli_F", 350], ["B_ViperLightHarness_blk_F", 300], ["B_ViperLightHarness_ghex_F", 300],
        ["B_ViperLightHarness_hex_F", 300], ["B_ViperLightHarness_khk_F", 300], ["B_ViperLightHarness_oli_F", 300],
        ["B_RadioBag_01_oucamo_F", 250], ["B_RadioBag_01_digi_F", 250], ["B_RadioBag_01_mtp_F", 250], ["B_Messenger_Black_F", 200],
        ["B_Messenger_Coyote_F", 200], ["B_Messenger_Gray_F", 200], ["B_Messenger_Olive_F", 200],
        ["B_CivilianBackpack_01_Everyday_IDAP_F", 150], ["B_CivilianBackpack_01_Sport_Red_F", 150], ["B_RadioBag_01_hex_F", 250],
        ["B_CivilianBackpack_01_Everyday_Astra_F", 150], ["B_CivilianBackpack_01_Sport_Blue_F", 150], ["B_RadioBag_01_tropic_F", 250],
        ["B_RadioBag_01_eaf_F", 250], ["B_RadioBag_01_ghex_F", 250], ["B_CivilianBackpack_01_Everyday_Vrana_F", 150],
        ["B_CivilianBackpack_01_Sport_Green_F", 150], ["B_RadioBag_01_wdl_F", 250], ["B_CivilianBackpack_01_Everyday_Black_F", 150],
        ["B_RadioBag_01_black_F", 250], ["B_LegStrapBag_coyote_F", 350], ["B_LegStrapBag_black_F", 350], ["B_LegStrapBag_olive_F", 350]];

    // REB SUPPLY: the rebel market's virtual buy list (lockpicks, zipties, charges, tools...)
    private _rit = [];
    { private _r = [_x] call _fnVirt; if (_r isNotEqualTo []) then { _rit pushBack _r; }; }
        forEach ((["rebel"] call life_fnc_virt_shops) param [1, []]);

    _cache = createHashMapFromArray [["gen", _gen], ["rebel", _reb], ["drip", _drip], ["ritems", _rit], ["seeds", _seeds]];
    missionNamespace setVariable ["PLB_lzCatalog", _cache];};

switch (toLower _mode) do {case "cats":  { _cats };
    case "items": { _cache getOrDefault [_arg, []] };
    case "get": {private _hit = []; {private _rows = _cache getOrDefault [_x select 0, []];
            private _i = _rows findIf { (_x select 0) isEqualTo _arg };
            if (_i > -1) exitWith { _hit = _rows select _i; };} forEach _cats;
        _hit};
    case "fee":  { 350 };
    case "vcap": { 3000 };
    case "pcap": { 960 };
    case "source": {switch (_arg) do {case "rebel";
            case "drip";
            case "ritems": {private _pts = [];
                { private _p = getMarkerPos _x; if (!(_p isEqualTo [0,0,0])) then { _pts pushBack _p; }; }
                    forEach ["Rebelop_1", "Rebelop_2", "Rebelop_3", "Rebelop_4", "Rebelop_5", "Rebelop_6"];
                if (_pts isEqualTo []) then { [[3600, 13100, 0]] } else { _pts }};
            default {
                // town general/drug-store areas: Kavala / Athira / Pyrgos / Sofia (tune freely)
                [[3600, 13100, 0], [14050, 18750, 0], [16800, 12800, 0], [25700, 21350, 0]]};};};
    default { [] };};