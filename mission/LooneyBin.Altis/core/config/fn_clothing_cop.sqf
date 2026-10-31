params[["_filter", 0, [0]]];
private _ret = [];
if ((call life_copLevel) isEqualTo 0) then {_ret = "You are not a Police Officer";};
private _isSRT = false;
private _titleName =
if (_isSRT) then {format["%1 SRT Armory", PLB_worldName]} else {format["%1 Police Department Shop", PLB_worldName]};
ctrlSetText[3103, _titleName];
private _uniform =
switch (call life_copLevel) do {case 1: {"images\police_uniform_cadet.jpg"};
    case 2: {"images\police_uniform_constable.jpg"};
    case 3: {"images\police_uniform_corporal.jpg"};
    case 4: {"images\police_uniform_sergeant.jpg"};
    case 5: {"images\police_uniform_lt.jpg"};
    case 6: {"images\police_uniform_captain.jpg"};
    case 7: {"images\police_uniform_captain.jpg"};
    default {""};}; private _rangeMaster =
switch (call life_copLevel) do {case 1: {"images\police_rangemaster_cadet.jpg"};
    case 2: {"images\police_rangemaster_constable.jpg"};
    case 3: {"images\police_rangemaster_corporal.jpg"};
    case 4: {"images\police_rangemaster_sergeant.jpg"};
    case 5: {"images\police_rangemaster_lieutenant.jpg"};
    case 6: {"images\police_rangemaster_captain.jpg"};
    case 7: {"images\police_rangemaster_captain.jpg"};
    default {""};}; private _BDU =
switch (call life_copLevel) do {case 4: {"images\police_combatu_sgt.jpg"};
    case 5: {"images\police_combatu_lt.jpg"};
    case 6: {"images\police_combatu_captain.jpg"};
    case 7: {"images\police_combatu_captain.jpg"};}; switch (_filter) do {case 0: {if (_isSRT) exitWith {
                _ret pushBack["U_B_CombatUniform_mcam_worn", "SRT Uniform", 0, "images\skins\srt_combatu.jpg"];
                if ((call life_copLevel) >= 2) then {
                    _ret pushBack["U_O_PilotCoveralls", "Pilot Coveralls (Police)", 5000, "images\c_coveralls_police.jpg"];};};
            // LoonyBin (owner 2026-06-13): rank DEFAULT uniforms (c_poloshirtpants_1_co retextures),
            // cumulative rank gate, listed FIRST with your own rank's uniform leading. Also the post-death
            // spawn uniform (fn_copLoadout); "SGT Grumpy" = alt SGT skin + the cop-NPC uniform.
            private _plbRankU = [[1, "APD Cadet Uniform",             "images\skins\apd\cadet.jpg"],
                [2, "APD Patrol Officer Uniform",    "images\skins\apd\po.jpg"],
                [3, "APD Corporal Uniform",          "images\skins\apd\cpl.jpg"],
                [4, "APD Sergeant Uniform",          "images\skins\apd\sgt.jpg"],
                [4, "APD Sergeant Uniform (Grumpy)", "images\skins\apd\sgt_grumpy.jpg"],
                [5, "APD Lieutenant Uniform",        "images\skins\apd\lt.jpg"],
                [6, "APD Captain Uniform",           "images\skins\apd\capt.jpg"],
                [7, "APD Chief Uniform",             "images\skins\apd\chief.jpg"]];
            private _plbMyLvl = (call life_copLevel) min 7;   // owner 2026-06-26: Chief (7) now gets its own skin (was capped to Captain)
            { _x params ["_lvl", "_uName", "_uTex"]; if (_lvl isEqualTo _plbMyLvl) then { _ret pushBack ["U_Rangemaster", _uName, 25, _uTex]; }; } forEach _plbRankU;
            { _x params ["_lvl", "_uName", "_uTex"]; if (_lvl < _plbMyLvl) then { _ret pushBack ["U_Rangemaster", _uName, 25, _uTex]; }; } forEach _plbRankU;
            if ((call life_copLevel) >= 1) then {
                // owner 2026-06-15 (#220): de-branded -- the custom cop_gendarmerie_blue.jpg has the upstream logo
                // baked in. "" = no texture override -> the vanilla U_B_GEN_Soldier_F (stock AAF Gendarmerie) skin.
                _ret pushBack["U_B_GEN_Soldier_F", "Police Gendarmerie (Blue)", 250, ""];};
            if ((call life_copLevel) >= 2) then {_ret pushBack["U_BG_Guerrilla_6_1", "Police Uniform", 100, _uniform];
                _ret pushBack["U_B_Wetsuit", nil, 250];};
            if ((call life_copLevel) >= 3) then {
                _ret pushBack["U_B_Protagonist_VR", "VR Suit (Police)", 2000, "#(argb,8,8,3)color(1,1,1,0.05)"];};
            if ((call life_copLevel) >= 2) then {
                _ret pushBack["U_O_PilotCoveralls", "Pilot Coveralls (Police)", 5000, "images\c_coveralls_police.jpg"];
                if (life_coprole in ["detective", "all"]) then {
                    _ret pushBack["U_O_PilotCoveralls", "Pilot Coveralls (Undercover)", 5000, "a3\Characters_f\Common\Data\pilot_suit_iran_co.paa"];
                    
                        _ret pushBack["U_O_PilotCoveralls", "Pilot Coveralls (Dark Camo)", 5000, "images\lc5_coveralls.jpg"];
                    
                        _ret pushBack["U_O_PilotCoveralls", "Pilot Coveralls (Pink Camo)", 5000, "images\covs_pink_camo.jpg"];
                    
                        _ret pushBack["U_O_PilotCoveralls", "Pilot Coveralls (Purple Camo)", 5000, "images\covs_purple_camo.jpg"];
                    
                        _ret pushBack["U_O_PilotCoveralls", "Pilot Coveralls (Red Camo)", 5000, "images\covs_red_camo.jpg"];
                    
                        _ret pushBack["U_O_PilotCoveralls", "Pilot Coveralls (Orange Camo)", 5000, "images\covs_orange_camo.jpg"];
                    
                        _ret pushBack["U_O_PilotCoveralls", "Pilot Coveralls (Green Camo)", 5000, "images\covs_green_camo.jpg"];
                    
                        _ret pushBack["U_O_PilotCoveralls", "Pilot Coveralls (Blue Camo)", 5000, "images\covs_blue_camo.jpg"];
                    
                        _ret pushBack["U_O_PilotCoveralls", "Pilot Coveralls (Toxic)", 5000, "images\craterewards\retribution\toxiccsats.jpg"];
};};
            if ((call life_copLevel) >= 3 && life_coprole in ["detective", "all"]) then {};
            if ((call life_copLevel) >= 3) then {
                _ret pushBack["U_C_CBRN_Suit_01_Blue_F", "Police Radiation Suit", 300, "a3\characters_f_enoch\uniforms\data\cbrn_suit_01_co.paa"];
            };
            if ((call life_copLevel) >= 4) then {_ret pushBack["U_O_Wetsuit", nil, 250];};
            if ((call life_copLevel) >= 5) then {
                _ret pushBack["U_B_CombatUniform_mcam_worn", "SWAT Uniform", 250, "images\c_combat_police_co.jpg"];
                _ret pushBack["U_I_Wetsuit", nil, 250];};
            
                _ret pushBack["U_B_Wetsuit", "Dark Water Wetsuit", 250, "images\lc4_dark_1.jpg"];
            
                _ret pushBack["U_I_E_ParadeUniform_01_LDF_F", "Police Parade Uniform", 250];
                _ret pushBack["U_I_E_ParadeUniform_01_LDF_decorated_F", "Police Parade Uniform Decorated", 250];};
    case 1: {if (_isSRT) exitWith {_ret pushBack["H_CrewHelmetHeli_B", nil, 0];};
            if ((call life_copLevel) >= 1) then {_ret pushBack["H_Cap_police", nil, 25];
                _ret pushBack["H_MilCap_gen_F", nil, 25];};
            
                _ret pushBack["H_Beret_blk", "Stylish Beret", 50];
            
                _ret pushBack["H_Beret_EAF_01_F", "Fancy Beret", 50];
            
                _ret pushBack["H_Beret_02", "Executive Beret", 50];
                _ret pushBack["H_Beret_Csat_01_F", "Red Beret", 50];
            
                _ret pushBack["H_HelmetB_light_wdl", nil, 1500];
            
                _ret pushBack["H_Beret_Colonel", "Master Beret", 50];
            
                _ret pushBack["H_Beret_gen_F", "Exclusive Beret", 50];
            if ((call life_copLevel) >= 2) then {
                // owner 2026-06-13: H_HelmetB_light_black renders olive/green when worn -> use the GA Spec
                // black helmet (reliably black, SWAT-style) instead.
                _ret pushBack["H_HelmetSpecB_blk", "Black SWAT Helmet", 1000];};};
    case 2: {if (_isSRT) exitWith {_ret pushBack["G_Balaclava_blk", nil, 0];};
            if ((call life_copLevel) >= 1) then {_ret = [["G_Aviator", nil, 10], ["G_Tactical_Black", "Tactical Shades", 10],
                    ["G_Tactical_Clear", "Tactical Glasses", 10], ["G_Combat", nil, 10], ["G_Combat_Goggles_tna_F", nil, 10],
                    ["G_Lowprofile", nil, 10], ["G_Shades_Black", nil, 10], ["G_Shades_Blue", nil, 10], ["G_Spectacles", nil, 10],
                    ["G_Spectacles_Tinted", nil, 10], ["G_Sport_Blackred", nil, 10], ["G_Sport_Checkered", nil, 10],
                    ["G_Sport_Blackyellow", nil, 10], ["G_Sport_BlackWhite", nil, 10], ["G_Sport_Greenblack", nil, 10],
                    ["G_Sport_Red", nil, 10], ["G_Squares", nil, 10], ["G_Squares_Tinted", nil, 10], ["G_Lady_Blue", nil, 10],
                    ["G_Lady_Red", nil, 10], ["G_Lady_Mirror", nil, 10], ["G_Lady_Dark", nil, 10]];};
            
                _ret pushBack["G_EyeProtectors_F", "Safety Goggles", 10];
                _ret pushBack["G_EyeProtectors_Earpiece_F", "Safety Goggles (Nerd)", 10];
            
                _ret pushBack["G_Goggles_VR", nil, 10];};
    case 3: {if (_isSRT) exitWith {_ret pushBack["V_TacVest_blk_POLICE", nil, 0];
                _ret pushBack["V_PlateCarrier1_blk", nil, 0];};
            if ((call life_copLevel) >= 1) then {_ret pushBack["V_Rangemaster_belt", nil, 150];
                _ret pushBack["V_BandollierB_khk", nil, 250];
                _ret pushBack["V_BandollierB_cbr", nil, 250];
                _ret pushBack["V_BandollierB_rgr", nil, 250];
                _ret pushBack["V_BandollierB_blk", nil, 250];
                _ret pushBack["V_BandollierB_oli", nil, 250];
                _ret pushBack["V_SmershVest_01_F", nil, 350];
                _ret pushBack["V_SmershVest_01_radio_F", nil, 350];};
            if ((call life_copLevel) >= 2) then {_ret pushBack["V_RebreatherB", nil, 500];};
            if ((call life_copLevel) >= 2) then {_ret pushBack["V_RebreatherIR", nil, 500];};
            
                _ret pushBack["V_LegStrapBag_black_F", nil, 350];
            if (((call life_copLevel)) >= 1 && (83 in life_side_talents)) then {_ret pushBack["V_TacVest_blk_POLICE", nil, 500];};
            if (((call life_copLevel)) >= 1 && (83 in life_side_talents)) then {_ret pushBack["V_TacVest_gen_F", nil, 500];};
            if (((call life_copLevel)) >= 2 && (83 in life_side_talents)) then {_ret pushBack["V_Safety_yellow_F", nil, 250];
                _ret pushBack["V_Safety_blue_F", nil, 250];};
            // owner 2026-06-21 (#466): Sgt+ (rank 4) gets the Carrier Light by RANK alone. Beta god-stats is off,
            // so the old `>=4 && 42 in life_cop_talents` gate left un-prestiged Sergeants with no body armor in the
            // shop ("no vests for Sgt+"). Rank-based now -- still <5 for the Level IV/V plates below.
            if ((call life_copLevel) >= 4) then {_ret pushBack["V_PlateCarrier1_blk", nil, 1000];};
            // LooneyBin (owner, 2026-06-10): Level IV + V armor for the APD
            if ((call life_copLevel) >= 5) then {_ret pushBack["V_PlateCarrier2_blk", "GA Carrier Rig Black (Level IV)", 2000];
                _ret pushBack["V_PlateCarrier2_rgr", "GA Carrier Rig (Level IV)", 2000];};
            if ((call life_copLevel) >= 6) then {_ret pushBack["V_PlateCarrierSpec_blk", "GA Special Rig Black (Level V)", 4000];
                _ret pushBack["V_PlateCarrierGL_blk", "GA Heavy GL Rig Black (Level V)", 4000];};};
    case 4: {if (_isSRT) exitWith {_ret pushBack["B_AssaultPack_blk", "SRT Backpack", 0, "images\skins\srt_assaultpack.jpg"];};
            // owner 2026-06-20 (Payton): Darter (AR-2 / B_UAV_01_backpack_F) REMOVED from the PD backpack shop.
            // (Was Sergeant+ with cop talent 76.) Re-add the drone here to restore it.
            // owner 2026-06-13 (#155): standard VISIBLE APD backpacks, scaled by rank. Cops had NO bags below
            // SGT and only the invisible ones at SGT+ -> "Sgt doesn't get any bags". Classes mirror the
            // invisible set (known-valid). Black where available to match APD kit.
            if ((call life_copLevel) >= 1) then {_ret pushBack["B_AssaultPack_blk", "APD Assault Pack", 150];
                _ret pushBack["B_FieldPack_blk",   "APD Field Pack",   200];};
            if ((call life_copLevel) >= 3) then {_ret pushBack["B_Kitbag_cbr",       "APD Kitbag",        300];
                _ret pushBack["B_TacticalPack_oli", "APD Tactical Pack", 300];};
            if ((call life_copLevel) >= 4) then {_ret pushBack["B_Carryall_blk", "APD Carryall", 500];
                _ret pushBack["B_Bergen_blk",   "APD Bergen",   500];};
            // owner 2026-06-13: invisible backpacks (1 per kind) -- SGT+ (copLevel 4), 2x the civ price.
            // The transparent procedural texture is applied to the pack via fn_changeClothes setObjectTexture.
            if ((call life_copLevel) >= 4) then {_ret pushBack["B_AssaultPack_blk",   "Invisible Assault Pack", 500, "PLB_INVIS_BAG"];
                _ret pushBack["B_FieldPack_blk",     "Invisible Field Pack",   500, "PLB_INVIS_BAG"];
                _ret pushBack["B_Kitbag_cbr",        "Invisible Kitbag",       500, "PLB_INVIS_BAG"];
                _ret pushBack["B_TacticalPack_oli",  "Invisible Tactical Pack",500, "PLB_INVIS_BAG"];
                _ret pushBack["B_Bergen_blk",        "Invisible Bergen",       500, "PLB_INVIS_BAG"];
                _ret pushBack["B_Carryall_blk",      "Invisible Carryall",     700, "PLB_INVIS_BAG"];
                _ret pushBack["B_Messenger_Black_F", "Invisible Messenger",    400, "PLB_INVIS_BAG"];};};
    case 5: {_ret = [];
            for "_i"
            from 0 to 4 do {_ret append([_i] call life_fnc_clothing_cop);};};
}; if (life_coprole in ["detective", "all"] && (_filter isNotEqualTo 5) && !_isSRT) then {{_ret append([_filter] call _x);}
    forEach[life_fnc_clothing_civ, life_fnc_clothing_reb, life_fnc_clothing_kart, life_fnc_clothing_dive];};
_ret;