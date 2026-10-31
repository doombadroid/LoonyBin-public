dynamicMap_zoneLocations = [PLB_worldName] call life_fnc_dynamicMapCfg;
dynamicMap_static_status = "idle";
dynamicMap_static_objectList = [];
dynamicMap_static_activeObjects = []; {_x params["_zonePos", "_zoneRadius", "_zoneID"];
    missionNamespace setVariable[format["dynamicMap_%1_status", _zoneID], "idle"];
    missionNamespace setVariable[format["dynamicMap_%1_objectList", _zoneID], []];
    missionNamespace setVariable[format["dynamicMap_%1_activeObjects", _zoneID], []];}
forEach dynamicMap_zoneLocations;
private _shitObjects = ["I_Heli_light_03_unarmed_F", "I_Heli_Transport_02_F", "O_Heli_Light_02_unarmed_F", "Headgear_H_Bandanna_sand", "Headgear_H_Beret_blk", "Headgear_H_Booniehat_mcamo", "Headgear_H_Booniehat_oli", "Headgear_H_Cap_blk", "Headgear_H_Cap_blu", "Headgear_H_Cap_grn", "Headgear_H_Cap_marshal", "Headgear_H_Cap_police", "Headgear_H_Cap_red", "Headgear_H_Hat_blue", "Headgear_H_Hat_brown", "Headgear_H_Hat_checker", "Headgear_H_Hat_grey", "Headgear_H_Hat_tan", "Headgear_H_HelmetB_light_desert", "Headgear_H_HelmetCrew_I", "Headgear_H_HelmetLeaderO_oucamo", "Headgear_H_HelmetSpecB", "Headgear_H_HelmetSpecO_blk", "Headgear_H_MilCap_blue", "Headgear_H_MilCap_ocamo", "Headgear_H_RacingHelmet_1_blue_F", "Headgear_H_RacingHelmet_1_green_F", "Headgear_H_RacingHelmet_1_orange_F", "Headgear_H_RacingHelmet_1_red_F", "Headgear_H_RacingHelmet_1_white_F", "Headgear_H_RacingHelmet_3_F", "Headgear_H_RacingHelmet_4_F", "Headgear_H_ShemagOpen_khk", "Headgear_H_ShemagOpen_tan", "Headgear_H_Shemag_olive", "Headgear_H_StrawHat", "Headgear_H_Watchcap_cbr", "Vest_V_BandollierB_blk", "Vest_V_BandollierB_cbr", "Vest_V_PlateCarrier1_blk", "Vest_V_PlateCarrierIA2_dgtl", "Vest_V_PlateCarrierIAGL_oli", "Vest_V_RebreatherB", "Vest_V_TacVest_blk_POLICE", "Vest_V_TacVest_brn", "Vest_V_TacVest_camo", "Vest_V_TacVest_khk", "Vest_V_TacVest_oli", "Weapon_arifle_Katiba_F", "Weapon_arifle_MXM_F", "Weapon_arifle_MX_F", "Weapon_arifle_TRG20_F", "Weapon_arifle_TRG21_F", "Weapon_hgun_ACPC2_F", "Weapon_hgun_P07_F", "Weapon_hgun_P07_blk_F", "Weapon_hgun_PDW2000_F", "Weapon_hgun_Pistol_heavy_01_F", "Weapon_hgun_Pistol_heavy_02_F", "Weapon_hgun_Rook40_F", "Weapon_launch_Titan_short_F", "Weapon_LMG_Mk200_F", "Weapon_LMG_Mk200_black_F", "Weapon_SMG_01_F", "Weapon_SMG_02_F", "Weapon_srifle_DMR_01_F", "Weapon_srifle_DMR_02_F", "Weapon_srifle_DMR_03_F", "Weapon_srifle_EBR_F", "Weapon_srifle_GM6_F", "Box_Syndicate_Wps_F", "Box_IND_Wps_F", "Box_GEN_Equip_F", "Box_NATO_Uniforms_F", "Land_OfficeCabinet_01_F", "Land_MetalCase_01_small_F", "Box_AAF_Uniforms_F", "B_Heli_Transport_01_F", "B_MBT_01_mlrs_F", "Land_MetalCase_01_large_F", "C_Offroad_01_repair_F", "C_Heli_Light_01_civil_F"];
private _decorObjects = ["Headgear_H_Bandanna_sand", "Headgear_H_Beret_blk", "Headgear_H_Booniehat_mcamo", "Headgear_H_Booniehat_oli", "Headgear_H_Cap_blk", "Headgear_H_Cap_blu", "Headgear_H_Cap_grn", "Headgear_H_Cap_marshal", "Headgear_H_Cap_police", "Headgear_H_Cap_red", "Headgear_H_Hat_blue", "Headgear_H_Hat_brown", "Headgear_H_Hat_checker", "Headgear_H_Hat_grey", "Headgear_H_Hat_tan", "Headgear_H_HelmetB_light_desert", "Headgear_H_HelmetCrew_I", "Headgear_H_HelmetLeaderO_oucamo", "Headgear_H_HelmetSpecB", "Headgear_H_HelmetSpecO_blk", "Headgear_H_MilCap_blue", "Headgear_H_MilCap_ocamo", "Headgear_H_RacingHelmet_1_blue_F", "Headgear_H_RacingHelmet_1_green_F", "Headgear_H_RacingHelmet_1_orange_F", "Headgear_H_RacingHelmet_1_red_F", "Headgear_H_RacingHelmet_1_white_F", "Headgear_H_RacingHelmet_3_F", "Headgear_H_RacingHelmet_4_F", "Headgear_H_ShemagOpen_khk", "Headgear_H_ShemagOpen_tan", "Headgear_H_Shemag_olive", "Headgear_H_StrawHat", "Headgear_H_Watchcap_cbr", "Item_Binocular", "Item_FirstAidKit", "Item_ItemGPS", "Item_ItemRadio", "Item_MineDetector", "Item_NVGoggles", "Item_NVGoggles_INDEP", "Item_NVGoggles_OPFOR", "Item_optic_Arco", "Item_optic_MRCO", "Item_Rangefinder", "Item_ToolKit", "Item_U_BG_Guerilla1_1", "Item_U_BG_Guerilla2_1", "Item_U_BG_Guerilla2_2", "Item_U_BG_Guerrilla_6_1", "Item_U_BG_leader", "Item_U_B_CombatUniform_mcam", "Item_U_B_CTRG_3", "Item_U_B_FullGhillie_sard", "Item_U_B_survival_uniform", "Item_U_B_Wetsuit", "Item_U_C_Driver_1_blue", "Item_U_C_Driver_1_green", "Item_U_C_Driver_1_orange", "Item_U_C_Driver_1_red", "Item_U_C_Driver_1_white", "Item_U_C_Driver_2", "Item_U_C_Driver_3", "Item_U_C_HunterBody_grn", "Item_U_C_Journalist", "Item_U_C_Poloshirt_blue", "Item_U_C_Poloshirt_burgundy", "Item_U_C_Poloshirt_redwhite", "Item_U_C_Poloshirt_salmon", "Item_U_C_Poloshirt_stripped", "Item_U_C_Poloshirt_tricolour", "Item_U_C_Poor_1", "Item_U_C_Scientist", "Item_U_I_CombatUniform", "Item_U_I_FullGhillie_ard", "Item_U_I_FullGhillie_lsh", "Item_U_I_FullGhillie_sard", "Item_U_I_G_resistanceLeader_F", "Item_U_I_HeliPilotCoveralls", "Item_U_I_pilotCoveralls", "Item_U_I_Wetsuit", "Item_U_OrestesBody", "Item_U_O_GhillieSuit", "Item_U_O_OfficerUniform_ocamo", "Item_U_O_Protagonist_VR", "Item_U_O_Wetsuit", "Item_U_Rangemaster", "Land_AirHorn_01_F", "Land_Antibiotic_F", "Land_Axe_F", "Land_Axe_fire_F", "Land_BakedBeans_F", "Land_Bandage_F", "Land_Battery_F", "Land_BloodBag_F", "Land_BottlePlastic_V2_F", "Land_BucketNavy_F", "Land_Bucket_F", "Land_Bucket_painted_F", "Land_BulletTrap_01_F", "Land_ButaneCanister_F", "Land_ButaneTorch_F", "Land_Camera_01_F", "Land_CanisterFuel_F", "Land_CanisterOil_F", "Land_CanOpener_F", "Land_Canteen_F", "Land_Can_Rusty_F", "Land_Can_V1_F", "Land_Can_V2_F", "Land_Can_V3_F", "Land_CarBattery_01_F", "Land_CarBattery_02_F", "Land_CerealsBox_F", "Land_Defibrillator_F", "Land_DisinfectantSpray_F", "Land_DuctTape_F", "Land_FlatTV_01_F", "Land_FMradio_F", "Land_FoodContainer_01_F", "Land_GamingSet_01_camera_F", "Land_GamingSet_01_console_F", "Land_GamingSet_01_controller_F", "Land_GamingSet_01_powerSupply_F", "Land_GasCanister_F", "Land_GasCooker_F", "Land_Gloves_F", "Land_HDMICable_01_F", "Land_HeatPack_F", "Land_Ketchup_01_F", "Land_Laptop_device_F", "Land_Laptop_F", "Land_Laptop_unfolded_scripted_F", "Land_Magazine_rifle_F", "Land_Map_F", "Land_Matches_F", "Land_MetalWire_F", "Land_Meter3m_F", "Land_Microwave_01_F", "Land_MobilePhone_smart_F", "Land_MultiMeter_F", "Land_Mustard_01_F", "Land_PensAndPencils_F", "Land_PortableLongRangeRadio_F", "Land_PortableSpeakers_01_F", "Land_Printer_01_F", "Land_Projector_01_F", "Land_RiceBox_F", "Land_Rope_01_F", "Land_Saw_F", "Land_Screwdriver_V1_F", "Land_Screwdriver_V2_F", "Land_Shovel_F", "Land_Suitcase_F", "Land_SurvivalRadio_F", "Land_Tablet_01_F", "Land_Tableware_01_cup_F", "Land_TacticalBacon_F", "Land_VitaminBottle_F", "Land_WaterPurificationTablets_F", "Land_Wrench_F", "ShootingMat_01_folded_Olive_F", "Vest_V_BandollierB_blk", "Vest_V_BandollierB_cbr", "Vest_V_PlateCarrier1_blk", "Vest_V_PlateCarrierIA2_dgtl", "Vest_V_PlateCarrierIAGL_oli", "Vest_V_RebreatherB", "Vest_V_TacVest_blk_POLICE", "Vest_V_TacVest_brn", "Vest_V_TacVest_camo", "Vest_V_TacVest_khk", "Vest_V_TacVest_oli", "Weapon_arifle_Katiba_F", "Weapon_arifle_MXM_F", "Weapon_arifle_MX_F", "Weapon_arifle_TRG20_F", "Weapon_arifle_TRG21_F", "Weapon_hgun_ACPC2_F", "Weapon_hgun_P07_F", "Weapon_hgun_P07_blk_F", "Weapon_hgun_PDW2000_F", "Weapon_hgun_Pistol_heavy_01_F", "Weapon_hgun_Pistol_heavy_02_F", "Weapon_hgun_Rook40_F", "Weapon_launch_Titan_short_F", "Weapon_LMG_Mk200_F", "Weapon_LMG_Mk200_black_F", "Weapon_SMG_01_F", "Weapon_SMG_02_F", "Weapon_srifle_DMR_01_F", "Weapon_srifle_DMR_02_F", "Weapon_srifle_DMR_03_F", "Weapon_srifle_EBR_F", "Weapon_srifle_GM6_F", "Box_Syndicate_Wps_F", "Box_IND_Wps_F", "Box_GEN_Equip_F", "Box_NATO_Uniforms_F", "Land_OfficeCabinet_01_F", "Land_MetalCase_01_small_F", "I_Heli_light_03_unarmed_F", "I_Heli_Transport_02_F", "O_Heli_Light_02_unarmed_F", "Box_AAF_Uniforms_F", "B_Heli_Transport_01_F", "B_MBT_01_mlrs_F", "Land_MetalCase_01_large_F", "C_Offroad_01_repair_F", "C_Heli_Light_01_civil_F"]; {
    _x params["_xObjectStr", "_xPos", "_xVectorDirAndUp", "_xCode", "_xIsServer"];
    _zone = "static";
    if !(_xIsServer) then {if ((_xCode find "_isStatic = true") isEqualTo - 1) then {
            if (_xPos distance2D(getMarkerPos "jail_marker_loonybin") > 110) then {for "_i"
                from 0 to((count dynamicMap_zoneLocations) - 1) do {_zoneCheck = (dynamicMap_zoneLocations select _i);
                    if (((_zoneCheck select 0) distance2D _xPos) < (_zoneCheck select 1)) exitWith {_zone = _zoneCheck select 2;};};};};
        if (_xObjectStr in _decorObjects) then {if !(_xObjectStr in _shitObjects) then {if (round(random(99)) <= 20) then {
                    private _objectList = missionNamespace getVariable[format["dynamicMap_%1_objectList", _zone], []];
                    _objectList pushBack _x;
                    missionNamespace setVariable[format["dynamicMap_%1_objectList", _zone], _objectList];};};} else {
            private _objectList = missionNamespace getVariable[format["dynamicMap_%1_objectList", _zone], []];
            _objectList pushBack _x;
            missionNamespace setVariable[format["dynamicMap_%1_objectList", _zone], _objectList];};};}
forEach allLocalMapEntities;
dynamicMap_fnc_loadArea = {private _status = missionNamespace getVariable format["dynamicMap_%1_status", _this];
    if (_status in ["creating", "removing", "active"]) exitWith {};
    missionNamespace setVariable[format["dynamicMap_%1_status", _this], "creating"]; {private _object = objNull;
        _object = _x call life_fnc_createVehicleLocal;
        uiSleep 0.0005;
        if !(isNull _object) then {private _objects = missionNamespace getVariable[format["dynamicMap_%1_activeObjects", _this], []];
            _objects pushBack _object;
            missionNamespace setVariable[format["dynamicMap_%1_activeObjects", _this], _objects];};}
    forEach(missionNamespace getVariable format["dynamicMap_%1_objectList", _this]);
    missionNamespace setVariable[format["dynamicMap_%1_status", _this], "active"];};
dynamicMap_fnc_unloadArea = {private _status = missionNamespace getVariable format["dynamicMap_%1_status", _this];
    if (_status in ["creating", "idle", "removing"]) exitWith {};
    missionNamespace setVariable[format["dynamicMap_%1_status", _this], "removing"];
    private _objectsRemoved = 0; {deleteVehicle _x;
        _objectsRemoved = _objectsRemoved + 1;
        uiSleep 0.002;}
    forEach(missionNamespace getVariable format["dynamicMap_%1_activeObjects", _this]);
    missionNamespace setVariable[format["dynamicMap_%1_activeObjects", _this], []];
    missionNamespace setVariable[format["dynamicMap_%1_status", _this], "idle"];};
[] spawn {private["_playerPos", "_status"];
    "static"
    spawn dynamicMap_fnc_loadArea;
    while {true}
    do {uiSleep 2;
        if (life_inCombat && (diag_tickTime - life_inCombatTime >= 30)) then {life_inCombat = false};
        _playerPos =
        if ((playerSide isEqualTo civilian) && (player distance2D(getMarkerPos "Respawn_west") < 600)) then {
            if !(isNil "life_ses_last_pos") then {if !(life_ses_last_pos isEqualTo[]) then {life_ses_last_pos};} else {getPosWorld player};
        } else {getPosWorld player};
        _playerPos =
        switch (true) do {case !(isNil "suspectESP_suspectObj"): {if (!isNull suspectESP_suspectObj) then {
                        getPosWorld suspectESP_suspectObj;} else {getPosWorld player;};};
            case (isNil "_playerPos"): {getPosWorld player};
            default {_playerPos};};
        // LooneyBin: when civ near Respawn_west with empty life_ses_last_pos, the switch above can
        // leave _playerPos nil/malformed -> distance2D threw "1 element, 3 expected" every 2s.
        // Fall back to a real position and skip the tick if still invalid.
        if (isNil "_playerPos" || {!(_playerPos isEqualType []) || {(count _playerPos) < 2}}) then { _playerPos = getPosWorld player; };
        if (alive player && (count _playerPos >= 2) && ((_playerPos distance2D getMarkerPos("Respawn_west")) > 600)) then {{
                _x params["_zonePos", "_zoneRadius", "_zoneID"];
                _status = missionNamespace getVariable format["dynamicMap_%1_status", _zoneID];
                switch (_status) do {case "idle": {_radiusIncrease = 1000;
                            if (_zoneRadius <= 200) then {_radiusIncrease = 400;};
                            if ((_playerPos distance2d _zonePos) < (_zoneRadius + _radiusIncrease)) then {
                                _zoneID spawn dynamicMap_fnc_loadArea;};}; case "active": {_radiusIncrease = 1250;
                                if (_zoneRadius <= 200) then {_radiusIncrease = 550;};
                                if ((_playerPos distance2D _zonePos) > (_zoneRadius + _radiusIncrease)) then {
                                    if !(isNull life_dynamicMap_lastVehicle) then {
                                        if (((getPosATL life_dynamicMap_lastVehicle) distance2D _zonePos) > (_zoneRadius + _radiusIncrease)) then {
                                            _zoneID spawn dynamicMap_fnc_unloadArea;};} else {_zoneID spawn dynamicMap_fnc_unloadArea;};};
                            };};}
            forEach dynamicMap_zoneLocations;};};};