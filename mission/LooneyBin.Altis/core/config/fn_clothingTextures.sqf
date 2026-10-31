params[["_classname", "", [""]], ["_mode", "", [""]], "_toFind"];
if (_classname isEqualTo "") exitWith {};
private _imgPath = "images\";private _copLevel=(call life_copLevel);private _medicLevel=(call life_medicLevel);private _adminLevel=(call life_adminLevel);private _desert6Uniform=if(32 in life_achievements) then{[]}else{[getPlayerUID player]};private _subscriber=[getPlayerUID player];private _textureArray=[[1,"
U_BG_Guerrilla_6_1 ",[civilian,west],0,0,0,0,-1,[],"
Police Uniform(Cadet)
",_imgPath+"
police_uniform_cadet.jpg "],[63,"
U_Rangemaster ",[civilian,west],0,0,0,0,-1,[],"
Police Uniform(Cadet)
",_imgPath+"
police_rangemaster_cadet.jpg "],[64,"
U_BG_Guerrilla_6_1 ",[west],2,0,0,0,-1,[],"
Police Uniform(Constable)
",_imgPath+"
police_uniform_constable.jpg "],[2,"
U_Rangemaster ",[west],2,0,0,0,-1,[],"
Police Uniform(Constable)
",_imgPath+"
police_rangemaster_constable.jpg "],[65,"
U_BG_Guerrilla_6_1 ",[west],3,0,0,0,-1,[],"
Police Uniform(Corporal)
",_imgPath+"
police_uniform_corporal.jpg "],[3,"
U_Rangemaster ",[west],3,0,0,0,-1,[],"
Police Uniform(Corporal)
",_imgPath+"
police_rangemaster_corporal.jpg "],[66,"
U_BG_Guerrilla_6_1 ",[west],4,0,0,0,-1,[],"
Police Uniform(Sergeant)
",_imgPath+"
police_uniform_sergeant.jpg "],[4,"
U_Rangemaster ",[west],4,0,0,0,-1,[],"
Police Uniform(Sergeant)
",_imgPath+"
police_rangemaster_sergeant.jpg "],[67,"
U_BG_Guerrilla_6_1 ",[west],5,0,0,0,-1,[],"
Police Uniform(Lieutenant)
",_imgPath+"
police_uniform_lt.jpg "],[5,"
U_Rangemaster ",[west],5,0,0,0,-1,[],"
Police Uniform(Lieutenant)
",_imgPath+"
police_rangemaster_lieutenant.jpg "],[68,"
U_BG_Guerrilla_6_1 ",[west],6,0,0,0,-1,[],"
Police Uniform(Captain)
",_imgPath+"
police_uniform_captain.jpg "],[6,"
U_Rangemaster ",[west],6,0,0,0,-1,[],"
Police Uniform(Captain)
",_imgPath+"
police_rangemaster_captain.jpg "],[7,"
U_B_CombatUniform_mcam_worn ",[west],4,0,0,0,-1,[],"
Police BDU(Sergeant)
",_imgPath+"
police_combatu_sgt.jpg "],[8,"
U_B_CombatUniform_mcam_worn ",[west],5,0,0,0,-1,[],"
Police BDU(Lieutenant)
",_imgPath+"
police_combatu_lt.jpg "],[9,"
U_B_CombatUniform_mcam_worn ",[west],6,0,0,0,-1,[],"
Police BDU(Captain)
",_imgPath+"
police_combatu_captain.jpg "],[10,"
U_B_CombatUniform_mcam_worn ",[west],0,0,0,0,-1,[],"
SWAT Uniform ",_imgPath+"
c_combat_police_co.jpg "],[11,"
U_O_PilotCoveralls ",[west],2,0,0,0,8,[],"
Pilot Coveralls(Police)
",_imgPath+"
c_coveralls_police.jpg "],[12,"
U_O_PilotCoveralls ",[west],2,0,0,0,9,[],"
Pilot Coveralls(Police)
",_imgPath+"
c_coveralls_police.jpg "],[13,"
U_B_Protagonist_VR ",[west],1,0,0,7,-1,[],"
VR Suit(Police)
","
#(argb, 8, 8, 3) color(1, 1, 1, 0.05)
"],[14,"
U_B_CombatUniform_mcam_worn ",[west],0,0,0,0,-1,[],"
SRT Uniform ",_imgPath+"
skins\srt_combatu.jpg "],[15,"
B_AssaultPack_blk ",[west],0,0,0,0,-1,[],"
SRT Assault Pack ",_imgPath+"
skins\srt_assaultpack.jpg "],[21,"
U_C_Poloshirt_salmon ",[civilian,west],0,0,0,1,-1,[],"
Hawaiian ",_imgPath+"
c_poloshirt_flowers.jpg "],[22,"
U_C_Poloshirt_blue ",[civilian,west],0,0,0,3,-1,[],"
Nice Job Man ",_imgPath+"
c_nice_job_man.jpg "],[23,"
U_C_Poloshirt_salmon ",[civilian,west],0,0,3,0,-1,[],"
ADMIN Shirt ",_imgPath+"
c_poloshirt_admin.jpg "],[24,"
U_I_Protagonist_VR ",[civilian,west],0,0,0,0,-1,[],"
White VR Suit ","
#(argb, 8, 8, 3) color(1, 1, 1, 1)
"],[25,"
U_C_Poloshirt_burgundy ",[civilian,west],0,0,0,0,-1,[],"
Poloshirt Twitch ",_imgPath+"
c_poloshirt_twitch.jpg "],[26,"
U_Marshal ",[civilian,west],0,0,0,0,-1,[],"
Yellow Plaid ",_imgPath+"
marshal_yellow_plaid.jpg "],[27,"
U_C_Poloshirt_redwhite ",[civilian,west],0,0,0,0,-1,[],"
LoonyBin Ent.Poloshirt ",_imgPath+"
c_poloshirt_loonybin_red.jpg "],[28,"
U_C_Scientist ",[civilian],0,0,0,0,-1,[],"
Prisoner Outfit ",_imgPath+"
prisoner_uniform.jpg "],[29,"
U_O_OfficerUniform_ocamo ",[civilian,west],0,0,0,0,-1,_desert6Uniform,"",_imgPath+"
o_officer_desert.jpg "],[31,"
B_Carryall_khk ",[civilian,west],0,0,0,0,5,[],"
Hiker 's Backpack",_imgPath+"b_carryall_hiker.jpg"],[32,"U_O_PilotCoveralls",[west],2,0,0,0,9,[],"Undercover no texture","a3\Characters_f\Common\Data\pilot_suit_iran_co.paa"],[33,"B_AssaultPack_blk",[civilian,west],0,0,0,0,31,[],"Blue Assault Pack",_imgPath+"b_assaultpack_blue.jpg"],[34,"B_AssaultPack_khk",[civilian,west],0,0,0,0,32,[],"Green Assault Pack",_imgPath+"b_assaultpack_green.jpg"],[35,"B_AssaultPack_sgg",[civilian,west],0,0,0,0,33,[],"Orange Assault Pack",_imgPath+"b_assaultpack_orange.jpg"],[36,"B_AssaultPack_wdl_F",[civilian,west],0,0,0,0,34,[],"Red Assault Pack",_imgPath+"b_assaultpack_red.jpg"],[37,"B_AssaultPack_rgr",[civilian,west],0,0,0,0,35,[],"Purple Assault Pack",_imgPath+"b_assaultpack_purple.jpg"],[40,"U_B_CombatUniform_mcam",[civilian,west],0,0,0,0,-1,[],"Asydidas Uniform",_imgPath+"u_b_combatUniform_mcam_loonydidas.jpg"],[42,"U_Marshal",[independent],0,0,0,0,-1,[],"NG Uniform",_imgPath+"med_polo1.jpg"],[43,"U_Marshal",[independent],0,2,0,0,-1,[],"NG Uniform",_imgPath+"med_polo2.jpg"],[44,"U_Marshal",[independent],0,3,0,0,-1,[],"NG Uniform",_imgPath+"med_polo3.jpg"],[45,"U_Marshal",[independent],0,4,0,0,-1,[],"NG Uniform",_imgPath+"med_polo4.jpg"],[46,"U_Marshal",[independent],0,5,0,0,-1,[],"NG Uniform",_imgPath+"med_polo5.jpg"],[47,"U_Marshal",[independent],0,6,0,0,-1,[],"NG Uniform",_imgPath+"med_polo6.jpg"],[48,"U_C_Paramedic_01_F",[independent],0,0,0,0,-1,[],"NG Uniform",_imgPath+"med_paramedic_uniform.jpg"],[48,"U_B_HeliPilotCoveralls",[independent],0,0,0,0,-1,[],"NG Uniform",_imgPath+"med_pilot_uniform.jpg"],[48,"U_B_Wetsuit",[independent],0,0,0,0,-1,[],"NG Uniform",_imgPath+"med_dive_uniform.jpg"],[48,"U_C_ConstructionCoverall_Red_F",[independent],0,0,0,0,-1,[],"NG Uniform",_imgPath+"med_coverall.jpg"],[48,"U_B_CombatUniform_mcam",[independent],0,0,0,0,-1,[],"NG Uniform",_imgPath+"med_combat_uniform.jpg"],[49,"U_O_PilotCoveralls",[west],2,0,0,0,49,[],"Pilot Coveralls (Police)",_imgPath+"c_coveralls_police.jpg"],[50,"U_O_PilotCoveralls",[west],2,0,0,0,49,[],"Undercover no texture","a3\Characters_f\Common\Data\pilot_suit_iran_co.paa"],[51,"U_O_PilotCoveralls",[civilian],0,0,0,0,49,[],"Lootcrate 5 Coveralls",_imgPath+"lc5_coveralls.jpg"],[52,"U_O_PilotCoveralls",[west],2,0,0,0,49,[],"Lootcrate 5 Coveralls",_imgPath+"lc5_coveralls.jpg"],[54,"U_B_GEN_Soldier_F",[west],1,0,0,0,-1,[],"Police Gendarmerie (Blue)","",""],[55,"U_B_GEN_Soldier_F",[west],1,0,0,3,-1,[],"Police Gendarmerie (Grey)","",""],[56,"U_B_GEN_Soldier_F",[west],1,0,0,3,-1,[],"Police Gendarmerie (Tan)","",""],[57,"U_O_PilotCoveralls",[civilian,west],0,0,0,0,82,[],"Pink Camo Coveralls",_imgPath+"covs_pink_camo.jpg"],[58,"U_O_PilotCoveralls",[civilian,west],0,0,0,0,83,[],"Purple Camo Coveralls",_imgPath+"covs_purple_camo.jpg"],[59,"U_O_PilotCoveralls",[civilian,west],0,0,0,0,84,[],"Red Camo Coveralls",_imgPath+"covs_red_camo.jpg"],[60,"U_O_PilotCoveralls",[civilian,west],0,0,0,0,92,[],"Orange Camo Coveralls",_imgPath+"covs_orange_camo.jpg"],[61,"U_O_PilotCoveralls",[civilian,west],0,0,0,0,93,[],"Green Camo Coveralls",_imgPath+"covs_green_camo.jpg"],[62,"U_O_PilotCoveralls",[civilian,west],0,0,0,0,94,[],"Blue Camo Coveralls",_imgPath+"covs_blue_camo.jpg"],[69,"U_O_PilotCoveralls",[civilian,west],0,0,0,0,120,[],"Pilot Coveralls (Worship)",_imgPath+"craterewards\retribution\worshipcsats.jpg"],[70,"U_O_PilotCoveralls",[civilian,west],0,0,0,0,121,[],"Pilot Coveralls (Toxic)",_imgPath+"craterewards\retribution\toxiccsats.jpg"],[72,"B_Messenger_Black_F",[civilian,west],0,0,0,0,120,[],"Messenger Bag (Worship)",_imgPath+"craterewards\retribution\worshipback.jpg"],[73,"B_Messenger_Black_F",[civilian,west],0,0,0,0,121,[],"Messenger Bag (Toxic)",_imgPath+"craterewards\retribution\toxicback.jpg"],[75,"U_O_R_Gorka_01_brown_F",[civilian,west],0,0,0,0,132,[],"Granit Asydidas (Tan/Black)",_imgPath+"craterewards\uniform1\granit_loonydidas_tan.jpg"],[76,"U_O_R_Gorka_01_brown_F",[civilian,west],0,0,0,0,133,[],"Granit Asydidas (Camo/Tan)",_imgPath+"craterewards\uniform1\granit_loonydidas_camo.jpg"],[77,"U_O_R_Gorka_01_brown_F",[civilian,west],0,0,0,0,134,[],"Granit Asydidas (White/Camo)",_imgPath+"craterewards\uniform1\granit_loonydidas_white.jpg"],[78,"U_O_R_Gorka_01_brown_F",[civilian,west],0,0,0,0,135,[],"Granit (Graffiti)",_imgPath+"craterewards\uniform1\granit_graffiti.jpg"],[79,"U_O_R_Gorka_01_brown_F",[civilian,west],0,0,0,0,136,[],"Granit Asydidas (Green/Black)",_imgPath+"craterewards\uniform1\granit_loonydidas_green.jpg"],[80,"U_O_R_Gorka_01_brown_F",[civilian,west],0,0,0,0,137,[],"Granit Asydidas (Orange/Black)",_imgPath+"craterewards\uniform1\granit_loonydidas_orange.jpg"],[81,"U_O_R_Gorka_01_brown_F",[civilian,west],0,0,0,0,138,[],"Granit (Electric)",_imgPath+"craterewards\uniform1\granit_electric.jpg"],[82,"U_O_R_Gorka_01_brown_F",[civilian,west],0,0,0,0,139,[],"Granit (Toxic)",_imgPath+"craterewards\uniform1\granit_toxic.jpg"],[83,"U_O_R_Gorka_01_brown_F",[civilian,west],0,0,0,0,140,[],"Granit (Off-White)",_imgPath+"craterewards\uniform1\granit_off-white.jpg"],[84,"U_C_man_sport_1_F",[civilian],0,0,0,0,-1,[],"Sports Clothes (Asydidas)",_imgPath+"sportsclothes_adidas.jpg"],[85,"U_O_PilotCoveralls",[civilian,west],0,0,0,0,-1,_subscriber,"Pilot Coveralls (Quarantine)",_imgPath+"asyplus\csat_quarantine.jpg"],[86,"U_O_PilotCoveralls",[civilian,west],0,0,0,0,-1,_subscriber,"Pilot Coveralls (Ode to Mitch)",_imgPath+"asyplus\farmer_mitch.jpg"]];
private"_return";private _trimCT={private _s=_this;if!(_s isEqualType"")exitWith{_s};private _ws=[" ",toString[9],toString[10],toString[13]];while{_s!=""&&{(_s select[0,1])in _ws}}do{_s=_s select[1]};while{_s!=""&&{(_s select[(count _s)-1,1])in _ws}}do{_s=_s select[0,(count _s)-1]};_s};_textureArray=_textureArray apply{private _r=+_x;_r set[1,(_r select 1)call _trimCT];if((_r select 9)isEqualType"")then{_r set[9,(_r select 9)call _trimCT]};if((_r select 10)isEqualType"")then{_r set[10,(_r select 10)call _trimCT]};if(((count _r)>11)&&{(_r select 11)isEqualType""})then{_r set[11,(_r select 11)call _trimCT]};_r};switch(_mode) do{case"getID":{_return=-1;{if((_x select 1)==_classname&&(toLower(_toFind)==toLower(_x select 10))) exitWith{_return=(_x select 0)};}forEach _textureArray;};case"getRowByID":{_return=_textureArray param[_textureArray findIf{(_x select 0) isEqualTo _toFind},[]];};case"setUniform":{private _itemType=getNumber(configFile>>"CfgWeapons">>uniform player>>"ItemInfo">>"type");if!(_itemType isEqualTo 801) exitWith{};if((life_uniformBackpack_skins select 0)!=-1&&{uniform player==(_textureArray select(_textureArray findIf{(_x select 0) isEqualTo(life_uniformBackpack_skins select 0)}) select 1)}) exitWith{[uniform player,"setIdx",life_uniformBackpack_skins select 0]call life_fnc_clothingTextures;_return=true};_return=true;};case"setBackpack":{if((life_uniformBackpack_skins select 1)!=-1&&{backpack player==(_textureArray select(_textureArray findIf{(_x select 0) isEqualTo(life_uniformBackpack_skins select 1)}) select 1)}) exitWith{[backpack player,"setIdx",life_uniformBackpack_skins select 1]call life_fnc_clothingTextures;_return=true};_return=true;};case"setIdx":{private _isPack=getNumber(configFile>>"CfgVehicles">>_classname>>"isBackpack");private _itemType=getNumber(configFile>>"CfgWeapons">>_classname>>"ItemInfo">>"type");private _skinID=if(isNil"_toFind") then{-1}else{_toFind};private _textureArray=_textureArray param[_textureArray findIf{(_x select 1)==_classname&&(_toFind isEqualTo(_x select 0))},[]];if(_textureArray isEqualTo[]) exitWith{_return=true};if(_itemType isEqualTo 801) then{player setObjectTextureGlobal[0,_textureArray select 10];if!(_textureArray param[11,""]isEqualTo"") then{player setObjectTextureGlobal[1,_textureArray select 11];};};if(_isPack isEqualTo 1) then{(unitBackpack player) setObjectTextureGlobal[0,_textureArray select 10];};_return=true;};};_return;