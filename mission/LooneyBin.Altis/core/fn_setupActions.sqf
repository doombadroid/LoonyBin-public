#include"..\macro.h"
private _plb_obj=player;

life_actions= [];

// LooneyBin owner 2026-07-04: Wreckage Recovery Kit -- universal (all sides) scroll-wheel action shown on any
// WRECK when the player is holding a kit in their Y-inventory. Returns the wreck to its owner's garage.
life_actions pushBack(_plb_obj addAction ["<t color='#90EE90'>Recover Wreckage</t>", {[cursorObject]
        spawn life_fnc_recoverWreck},nil,200,false,false,"",'!isNil "life_inv_wreckkit" && {life_inv_wreckkit > 0} && !(alive cursorObject) && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship") && (cursorObject distance player < (12 + 0.5 * (sizeOf (typeOf cursorObject)))) && (count (cursorObject getVariable ["plb_dbInfo", []]) >= 2 || count (cursorObject getVariable ["dbInfo", []]) >= 2)',12]);

// open the Loonazon box with the house-storage trunk menu (virtual + physical tabs; per-item take/store)
life_actions pushBack(_plb_obj addAction ["<t color='#e88b2d'>Open Loonazon Box</t>", {[cursorObject]
        spawn life_fnc_loonazonOpen},nil,201,false,false,"",'!isNull cursorObject && {(cursorObject getVariable ["plb_packageOwner", "x"]) isEqualTo (getPlayerUID player)} && {!(cursorObject getVariable ["plb_carrying", false])} && {player distance cursorObject < 5}',5]);

// pick up the box to reposition it (server does the attach). Not while already carrying one.
life_actions pushBack(_plb_obj addAction ["<t color='#e88b2d'>Pick Up Loonazon Box</t>", { [["carry", player, cursorObject], "TON_fnc_loonazonSRV", 2] spawn life_fnc_MP; },nil,199,false,false,"",'!isNull cursorObject && {(cursorObject getVariable ["plb_packageOwner", "x"]) isEqualTo (getPlayerUID player)} && {isNull (player getVariable ["plb_loonazonCarry", objNull])} && {player distance cursorObject < 5}',5]);

// set the carried box down -- CURSOR-FREE (you can't look at a box attached to your own hands), shows whenever carrying
life_actions pushBack(_plb_obj addAction ["<t color='#e88b2d'>Set Down Loonazon Box</t>", { [["carry", player, (player getVariable ["plb_loonazonCarry", objNull])], "TON_fnc_loonazonSRV", 2] spawn life_fnc_MP; },nil,199,false,false,"",'!isNull (player getVariable ["plb_loonazonCarry", objNull])',0]);

// LOONAZON ROBBERY: after the 10-min holdout (van plb_lzState 2) ANYONE can crack the package out of the van
life_actions pushBack(_plb_obj addAction ["<t color='#ff3030'>Break Open Loonazon Package</t>", { [["breakopen", player, cursorObject], "TON_fnc_loonazonSRV", 2] spawn life_fnc_MP; },nil,202,false,false,"",'!isNull cursorObject && {cursorObject getVariable ["plb_loonazonVan", false]} && {(cursorObject getVariable ["plb_lzState", 0]) isEqualTo 2} && {(cursorObject getVariable ["plb_lzOwner", "x"]) isNotEqualTo (getPlayerUID player)} && {player distance cursorObject < 6}',6]);

// ...or the ORDERER (if they held the robbers off) takes a refund or sends the van on its way again
life_actions pushBack(_plb_obj addAction ["<t color='#e88b2d'>Loonazon: Refund Order</t>", { [["lzrefund", player, cursorObject], "TON_fnc_loonazonSRV", 2] spawn life_fnc_MP; },nil,201,false,false,"",'!isNull cursorObject && {cursorObject getVariable ["plb_loonazonVan", false]} && {(cursorObject getVariable ["plb_lzState", 0]) isEqualTo 2} && {(cursorObject getVariable ["plb_lzOwner", "x"]) isEqualTo (getPlayerUID player)} && {player distance cursorObject < 6}',6]);

life_actions pushBack(_plb_obj addAction ["<t color='#e88b2d'>Loonazon: Re-attempt Delivery</t>", { [["lzredeliver", player, cursorObject], "TON_fnc_loonazonSRV", 2] spawn life_fnc_MP; },nil,200,false,false,"",'!isNull cursorObject && {cursorObject getVariable ["plb_loonazonVan", false]} && {(cursorObject getVariable ["plb_lzState", 0]) isEqualTo 2} && {(cursorObject getVariable ["plb_lzOwner", "x"]) isEqualTo (getPlayerUID player)} && {player distance cursorObject < 6}',6]);

life_actions pushBack(_plb_obj addAction ["<t color='#f2c14e'>Grab Component</t>", { [cursorObject] spawn life_fnc_grabComponent },nil,201,false,false,"",'!isNull cursorObject && {(cursorObject getVariable ["plb_componentCrate", ""]) isNotEqualTo ""} && {!(cursorObject getVariable ["plb_grabbed", false])} && {player distance cursorObject < 5}',5]);

life_actions pushBack(_plb_obj addAction ["<t color='#f2c14e'>Assemble Mining Rig</t>", { [] spawn life_fnc_miningAssemble },nil,202,false,false,"",'(missionNamespace getVariable ["life_inv_cryptoCPU",0] > 0) && {missionNamespace getVariable ["life_inv_cryptoGPU",0] > 0} && {missionNamespace getVariable ["life_inv_cryptoPSU",0] > 0} && {missionNamespace getVariable ["life_inv_cryptoStorage",0] > 0} && {missionNamespace getVariable ["life_inv_cryptoMotherboard",0] > 0} && {missionNamespace getVariable ["life_inv_cryptoRam",0] > 0} && {missionNamespace getVariable ["life_inv_cryptoCooler",0] > 0} && {missionNamespace getVariable ["life_inv_cryptoCase",0] > 0}',5]);

// LooneyBin 2026-07-18: the mining rig is now a PLACED PHYSICAL object (installed via Use item -> placement).
// These scroll on the placed rig (any composition piece is tagged plb_cryptoRig + plb_rigOwner).
life_actions pushBack(_plb_obj addAction ["<t color='#f2c14e'>Collect New Drachma</t>", { ["collect", cursorObject] spawn life_fnc_miningRig },nil,201,false,false,"",'!isNull cursorObject && {(cursorObject getVariable ["plb_cryptoRig", false])} && {(cursorObject getVariable ["plb_rigOwner", ""]) isEqualTo (getPlayerUID player)} && {player distance cursorObject < 6}',5]);

life_actions pushBack(_plb_obj addAction ["<t color='#fdd835'>Move Mining Rig</t>", { ["move", cursorObject] spawn life_fnc_miningRig }
    // multi-rig 2026-07-22: Move/Delete key on the HOUSE owner (plb_rigHomeOwner), matching the server
    // delete-gate -- a hijack flips plb_rigOwner, and the victim must still be able to reclaim hardware.
    ,nil,201,false,false,"",'!isNull cursorObject && {(cursorObject getVariable ["plb_cryptoRig", false])} && {(cursorObject getVariable ["plb_rigHomeOwner", ""]) isEqualTo (getPlayerUID player)} && {player distance cursorObject < 6} && {isNull objectParent player} && {isNull life_placing}',5]);

life_actions pushBack(_plb_obj addAction ["<t color='#ff5252'>Delete Mining Rig</t>", { ["delete", cursorObject] spawn life_fnc_miningRig },nil,201,false,false,"",'!isNull cursorObject && {(cursorObject getVariable ["plb_cryptoRig", false])} && {(cursorObject getVariable ["plb_rigHomeOwner", ""]) isEqualTo (getPlayerUID player)} && {player distance cursorObject < 6} && {isNull objectParent player}',5]);

// LooneyBin 2026-07-18: NON-owner -> hack the rig (Terminal Breach -> full takeover + Cyber Crime charge)
life_actions pushBack(_plb_obj addAction ["<t color='#00e5ff'>Hack Mining Rig</t>", { [cursorObject] spawn life_fnc_cyberdeck },nil,201,false,false,"",'!isNull cursorObject && {(cursorObject getVariable ["plb_cryptoRig", false])} && {(cursorObject getVariable ["plb_rigOwner", ""]) isNotEqualTo (getPlayerUID player)} && {playerSide isEqualTo civilian} && {(call PLB_fnc_hasDeck)} && {player distance cursorObject < 6} && {!(((nearestObjects [cursorObject, ["House"], 20]) param [0, objNull]) getVariable ["plb_locked", true])}',5]);

if((getPlayerUID player) in []) then {life_actions pushBack(_plb_obj addAction ["<t color='#00FF00'>Deactivate Spangle</t>", {player setVariable ["plb_supertaze",false,true];},"",1.5,false,false,"",'(player getVariable [ "plb_superTaze",false ] )',6]);

    life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Activate Spangle</t>", {player setVariable ["plb_supertaze",true,true];},"",1.5,false,false,"",'!(player getVariable [ "plb_superTaze",false ] )',6]);};

if!(life_scrollDisabled) then {if((call life_adminLevel)>=2) then {life_actions pushBack(_plb_obj addAction ["<t color='#00FF00'>House Registration</t>", {if(cursorObject getVariable ["plb_homeOwner",""]
                isEqualTo"") exitWith {[format ["<t color='#FF0000' align='center'><t size='1.5' align='center'>House ID:"+"</t></t><br/>%1",cursorObject getVariable ["plb_houseID",-1]],"basic"]
                    spawn life_fnc_handleMessage;};
 [format ["<t color='#FF0000' align='center'><t size='1.5' align='center'>House Owner/ID:"+"</t></t><br/>%1 / %2",cursorObject getVariable ["plb_homeOwner","Not found"],cursorObject getVariable ["plb_houseID",-1]],"basic"]
                spawn life_fnc_handleMessage;},cursorObject,-1,false,false,"",'!(cursorObject getVariable [ "plb_restricted_house", false ] ) && !isNull cursorObject && (player distance cursorObject) < 20 && typeOf cursorObject in life_houseTypes',6]);

        life_actions pushBack(_plb_obj addAction ["Check Registration", {[cursorObject]
                call life_fnc_searchVehAction},"",0,false,false,"",' !isNull cursorObject && (player distance cursorObject) < 5 && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship")',6]);

        life_actions pushBack(_plb_obj addAction ["<t color='#00FF00'>Rebel Loadouts</t>", {[player,player,-1,"rebel"]
                spawn life_fnc_loadoutMenu},"",1.5,false,false,"",'(call life_adminLevel) >= 3 && !isNull cursorObject && (typeOf cursorObject in life_houseTypes) && (player distance cursorObject < 15) && ((cursorObject getVariable [ "plb_homeOwner", "" ] ) isNotEqualTo "")',6]);};

    if(isNull life_sittingChair) then {life_actions pushBack(_plb_obj addAction ["<t color='#2eeece'>Sit Down</t>", {[cursorObject]
                spawn life_fnc_handleChair},nil,1.5,true,true,"""",'player distance cursorObject < 3 && { ( [ str cursorObject, "bench" ] call KRON_StrInStr || [ str cursorObject, "chair" ] call KRON_StrInStr) }',-1]);};

    life_actions pushBack(_plb_obj addAction ["<t color='#ADFF2F'>ATM</t>", {[]
            call life_fnc_atmMenu},nil,1.5,true,true,"""",'((player distance cursorObject < 3 && { typeOf cursorObject in [ "Land_Mattaust_ATM","Land_atm" ] || [ str cursorObject,"atm_0" ] call KRON_StrInStr } ))',6]);

    life_actions pushBack(_plb_obj addAction ["<t color='#FFFF2F'>Gang Account</t>", {[]
            call life_fnc_gangAtmMenu},nil,1.5,true,true,"""",'(count life_gang_data > 0) && playerSide isEqualTo civilian && (player distance cursorObject < 3 && { typeOf cursorObject in [ "Land_Mattaust_ATM","Land_atm" ] || [ str cursorObject,"atm_0" ] call KRON_StrInStr } )',6]);

    life_actions pushBack(_plb_obj addAction ["<t color='#FF7400'>Check Mailbox</t>", {[]
            call life_fnc_checkMailbox},nil,1.5,true,true,"""",'player distance cursorObject < 3 && ( { typeOf cursorObject in [ "Land_Mattaust_ATM","Land_atm" ] || [ str cursorObject,"atm_0" ] call KRON_StrInStr } )',6]);

    // ATM SKIMMER (LooneyBin 2026-07-16): civ plants a $50k rebel skimmer on the physical ATM; cop pulls it for $200k.
    life_actions pushBack(_plb_obj addAction ["<t color='#e88b2d'>Plant ATM Skimmer</t>", { [] spawn life_fnc_applyAtmSkimmer; },nil,1.4,true,true,"",'playerSide isEqualTo civilian && {life_inv_atmskimmer > 0} && {player distance cursorObject < 3} && {((typeOf cursorObject) in ["Land_Atm_01_F","Land_Atm_02_F","Land_Mattaust_ATM","Land_atm"]) || {[str cursorObject, "atm_0"] call KRON_StrInStr}}',6]);
    life_actions pushBack(_plb_obj addAction ["<t color='#3aa0ff'>Remove ATM Skimmer ($200,000)</t>", { [["remove", getPosATL cursorObject, 0, player], "TON_fnc_atmSkimSRV", 2] spawn life_fnc_MP; },nil,1.4,true,true,"",'playerSide isEqualTo west && {(cursorObject call life_fnc_atmSkimOwner) isNotEqualTo ""} && {player distance cursorObject < 3} && {((typeOf cursorObject) in ["Land_Atm_01_F","Land_Atm_02_F","Land_Mattaust_ATM","Land_atm"]) || {[str cursorObject, "atm_0"] call KRON_StrInStr}}',6]);

    if(vehicle player isKindOf"Air"&&driver vehicle player isEqualTo player) then {life_actions pushBack(_plb_obj addAction ["Eject", {_veh=vehicle player;

                if(_veh!=player) then {_engineOn=isEngineOn _veh;

                    player action ["GetOut",_veh];

                    uiSleep 1;};},"",6,false,false,"",'vehicle player isKindOf "Air" && driver vehicle player == player ;',6]);};

    if(((vehicle player) getVariable ["plb_nitro",0])>0) then {life_actions pushBack(_plb_obj addAction ["<t color='#00FF00'>Activate Nitro</t>", {[vehicle player]
                call life_fnc_activateNitro},nil,2,false,false,"",'(vehicle player != player) && (driver vehicle player == player) && (((vehicle player) getVariable [ "plb_nitro", 0 ] ) > 0)',-1]);};

    life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Repair Vehicle</t>", {[cursorObject]
            call life_fnc_repairTruck},nil,0,false,false,"",' (isNull objectParent player) && !isNull cursorObject && alive cursorObject && ((cursorObject isKindOf "Car") || (cursorObject isKindOf "Air") || (cursorObject isKindOf "Ship")) && (player distance cursorObject < 5) ',6]);

    life_actions pushBack(_plb_obj addAction ["Unflip Vehicle", {[cursorObject]
            call life_fnc_flip},"",-1,false,false,"",'!(cursorObject getVariable [ "plb_mobileHeadQuartersTruckLocked", false ] ) && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air") && (vehicle player == player) && (player distance cursorObject < 8) && (local cursorObject || cursorObject in life_vehicles || vectorUp cursorObject select 2 < 0.6 || vectorUp cursorObject select 1 > 0.2 || vectorUp cursorObject select 1 < -0.2) && (speed cursorObject < 1)',6]);

    life_actions pushBack(_plb_obj addAction ["Push Vehicle", {[]
            call life_fnc_pushVehicle},nil,0.6,false,true,"",'!isNull cursorObject && (cursorObject isKindOf "Air" || cursorObject isKindOf "Ship") && (cursorObject in life_vehicles) && (player distance cursorObject) < 5 && (speed cursorObject) < 5 && (isNull objectParent player) && !life_action_in_use',6]);

    life_actions pushBack(_plb_obj addAction ["Pick Up Item(s)", {[cursorObject]
            call life_fnc_menuPickupItems},nil,1.5,false,false,"",'!isNull cursorObject && count (cursorObject getVariable [ "plb_droppedItems", [ ] ] ) > 0 && player distance cursorObject < 5',6]);

    life_actions pushBack(_plb_obj addAction ["<t color='#00FF00'>Fix Firing Pin</t>", {[]
            call life_fnc_fixFiringPin},nil,1.5,false,false,"",'(player getVariable [ "plb_gunBroken",false ] ) && !(player getVariable [ "plb_restrained",false ] ) && (isNull objectParent player)',6]);

    life_actions pushBack(_plb_obj addAction ["<t color='#1E90FF'>Deploy APD UAV</t>", {[]
            spawn life_fnc_copUAV},nil,1.5,false,false,"",'(call life_copLevel) >= 6 && life_inv_uav05 > 0 && (isNull objectParent player)',6]);

    if (isNil "life_droneMonitor") then {["init"]
        spawn life_fnc_reviveDrone};

    life_actions pushBack(_plb_obj addAction ["<t color='#26ff7a'>Healing Bullets</t>", {player setVariable ["plb_medicGunMode","heal",true]; ["Medic gun set to HEALING BULLETS - each shot heals the target +10 hp.","info"]
            spawn life_fnc_handleMessage;},nil,1.5,false,false,"",'17 in life_medic_talents && (currentWeapon player isEqualTo "hgun_P07_khk_F") && ((player getVariable [ "plb_medicGunMode","taser" ] ) isEqualTo "taser")',6]);

    life_actions pushBack(_plb_obj addAction ["<t color='#ff4040'>Taser Mode</t>", {player setVariable ["plb_medicGunMode","taser",true]; ["Medic gun set to TASER - each shot downs the target.","info"]
            spawn life_fnc_handleMessage;},nil,1.5,false,false,"",'17 in life_medic_talents && (currentWeapon player isEqualTo "hgun_P07_khk_F") && ((player getVariable [ "plb_medicGunMode","taser" ] ) isEqualTo "heal")',6]);

    life_actions pushBack(_plb_obj addAction ["<t color='#26ff7a'>Treat via Drone</t>", {["treat"]
            spawn life_fnc_reviveDrone},nil,2,false,false,"",'(call life_medicLevel) >= 3 && ((typeOf (getConnectedUAV player)) in [ "C_IDAP_UAV_06_medical_F","I_UAV_06_medical_F" ] ) && { (allPlayers findIf { (_x distance (getConnectedUAV player)) < 7 && ((_x getVariable [ "plb_revivable",false ] ) || (alive _x && damage _x > 0.3)) } ) > -1 }',6]);

    life_actions pushBack(_plb_obj addAction ["<t color='#7ad1ff'>Medical Supplies (Drone)</t>", {[cursorObject,"","","hospital"]
            call life_fnc_virtualShopMenu},nil,1.5,false,false,"",'!isNull cursorObject && ((typeOf cursorObject) in [ "I_UAV_06_medical_F","C_IDAP_UAV_06_medical_F" ] ) && (cursorObject getVariable [ "plb_medSupply", false ] ) && (player distance cursorObject < 8)',6]);

    life_actions pushBack(_plb_obj addAction ["Push Back",life_fnc_pushObject,"",0,false,false,"",'!isNull cursorTarget && player distance cursorTarget < 6 && (cursorTarget isKindOf "Ship" || cursorTarget isKindOf "Plane")',6]);

    life_actions pushBack(_plb_obj addAction ["Pick Up Object",life_fnc_pickupObject,cursorObject,0,false,false,"",'!isNull cursorObject && (typeOf cursorObject isNotEqualTo "Land_BatteryPack_01_closed_black_F") && cursorObject getVariable [ "plb_placedItem", false ] && ((player isEqualTo ((cursorObject getVariable [ "plb_owner", objNull ] ))) || ((getPlayerUID player) isEqualTo (cursorObject getVariable [ "plb_ownerID", "" ] ))) && ((player distance cursorObject) < 5)',6]);

    life_actions pushBack(_plb_obj addAction ["<t color='#a8d8ff'>Lay Down</t>", {["lay",cursorObject]
            call life_fnc_furnitureAction},nil,1.5,false,true,"",'!isNull cursorObject && (typeOf cursorObject isEqualTo "Land_WoodenBed_01_F") && (cursorObject getVariable [ "plb_placedItem",false ] ) && !(player getVariable [ "plb_layingBed",false ] ) && (player distance cursorObject < 3) && (isNull objectParent player)',6]);

    life_actions pushBack(_plb_obj addAction ["<t color='#a8d8ff'>Get Up</t>", {["getup",objNull]
            call life_fnc_furnitureAction},nil,1.5,false,true,"",'player getVariable [ "plb_layingBed",false ]',6]);

    life_actions pushBack(_plb_obj addAction ["<t color='#fdd835'>Move Furniture</t>", {["move",cursorObject]
            call life_fnc_furnitureAction},nil,1.5,false,false,"",'!isNull cursorObject && (cursorObject getVariable [ "plb_placedItem",false ] ) && (typeOf cursorObject in PLB_furnitureClasses) && ((getPlayerUID player) isEqualTo (cursorObject getVariable [ "plb_ownerID","" ] )) && (player distance cursorObject < 4) && (isNull objectParent player)',6]);

    life_actions pushBack(_plb_obj addAction ["<t color='#ff5252'>Delete Furniture</t>", {["delete",cursorObject]
            spawn life_fnc_furnitureAction},nil,1.5,false,false,"",'!isNull cursorObject && (cursorObject getVariable [ "plb_placedItem",false ] ) && (typeOf cursorObject in PLB_furnitureClasses) && ((getPlayerUID player) isEqualTo (cursorObject getVariable [ "plb_ownerID","" ] )) && (player distance cursorObject < 4) && (isNull objectParent player)',6]);

    life_actions pushBack(_plb_obj addAction ["Eject All Physical Items", {private _confirm= ["Do you want to drop all the physical items from your loot chest? This will allow other players to see/take them off the ground.","Seasonal Chest Loot","Yes","No"]
            call BIS_fnc_guiMessage;

            if!(_confirm) exitWith {};
 ["ejectItems",0,cursorObject]
            call life_fnc_dropPhysicalItem},"",0,false,false,"",'!isNull cursorObject && (typeOf cursorObject isEqualTo "Box_Syndicate_WpsLaunch_F") && cursorObject getVariable [ "plb_questloot", false ] && ((player distance cursorObject) < 5)',6]);

    if!(isNull life_placing) then {life_actions pushBack(_plb_obj addAction ["Place Object",life_fnc_placeObject,nil,0,false,false,"",'!isNull life_placing',6]);

        life_actions pushBack(_plb_obj addAction ["<t color='#a8d8ff'>Raise Object (+Z)</t>", {life_placeZ=life_placeZ+0.1;

                if(!isNull life_placing)then {life_placing attachTo [player, [0,life_placeFwd,life_placeZ]];

                    life_placing setDir life_placeDir;};},nil,1.5,false,false,"",'!isNull life_placing',6]);

        life_actions pushBack(_plb_obj addAction ["<t color='#a8d8ff'>Lower Object (-Z)</t>", {life_placeZ=life_placeZ-0.1;

                if(!isNull life_placing)then {life_placing attachTo [player, [0,life_placeFwd,life_placeZ]];

                    life_placing setDir life_placeDir;};},nil,1.5,false,false,"",'!isNull life_placing',6]);

        // owner 2026-07-10: FAST vertical steps (the 0.1m ones need 30 clicks for a platform height).
        life_actions pushBack(_plb_obj addAction ["<t color='#a8d8ff'>Raise Object (+1m)</t>", {life_placeZ = life_placeZ + 1;
                if (!isNull life_placing) then {life_placing attachTo [player, [0, life_placeFwd, life_placeZ]];
                    life_placing setDir life_placeDir;};},nil,1.5,false,false,"",'!isNull life_placing',6]);

        life_actions pushBack(_plb_obj addAction ["<t color='#a8d8ff'>Lower Object (-1m)</t>", {life_placeZ = life_placeZ - 1;
                if (!isNull life_placing) then {life_placing attachTo [player, [0, life_placeFwd, life_placeZ]];
                    life_placing setDir life_placeDir;};},nil,1.5,false,false,"",'!isNull life_placing',6]);

        life_actions pushBack(_plb_obj addAction ["<t color='#a8d8ff'>Rotate Object (10 deg)</t>", {life_placeDir=(life_placeDir+10) mod 360;

                if(!isNull life_placing)then {life_placing setDir life_placeDir;};},nil,1.5,false,false,"",'!isNull life_placing',6]);

        life_actions pushBack(_plb_obj addAction ["Stop Placing Object", {deleteVehicle life_placing;

                life_placing=objNull;},nil,0,false,false,"",'!isNull life_placing',6]);};

    life_actions pushBack(_plb_obj addAction ["<t color='#fb9924'>Place Boom Box</t>", {["boombox"]
            spawn life_fnc_holdObject},nil,2,false,false,"",'(isNull objectParent player) && (life_inv_boombox > 0) && (isNull life_boomBox) && (isNull life_placing) && (player nearObjects [ "Land_BatteryPack_01_closed_black_F", 20 ] isEqualTo [ ] )',-1]);

    life_actions pushBack(_plb_obj addAction ["<t color='#e760ff'>Start Dancing</t>", {["startDance", []]
            spawn life_fnc_boomBox},nil,2,false,false,"",'(isNull objectParent player) && !(life_isDancing) && (player nearObjects [ "Land_BatteryPack_01_closed_black_F", 13 ] isNotEqualTo [ ] )',-1]);

    life_actions pushBack(_plb_obj addAction ["<t color='#e760ff'>Stop Dancing</t>", {["stopDance", []]
            spawn life_fnc_boomBox},nil,2,false,false,"",'(isNull objectParent player) && (life_isDancing)',-1]);

    if((cursorObject isEqualTo life_boomBox)&&(((cursorObject getVariable ["plb_boomBoxData", []]) param [1,""]) isEqualTo(getPlayerUID player))) then {life_actions pushBack(_plb_obj addAction ["<t color='#f01f07'>Stop Music</t>", {["stopMusic", [cursorObject]]
                spawn life_fnc_boomBox},nil,2,false,false,"",'(isNull objectParent player) && !(isNull cursorObject) && (alive cursorObject) && (((cursorObject getVariable [ "plb_boomBoxData", [ ] ] ) param [ 3, "" ] ) isNotEqualTo "")',-1]);

        life_actions pushBack(_plb_obj addAction ["<t color='#fb9924'>Start Music</t>", {["startMusic", [cursorObject]]
                spawn life_fnc_boomBox},nil,2,false,false,"",'(isNull objectParent player) && !(isNull cursorObject) && (alive cursorObject) && (((cursorObject getVariable [ "plb_boomBoxData", [ ] ] ) param [ 3, "" ] ) isEqualTo "")',-1]);

        life_actions pushBack(_plb_obj addAction ["<t color='#f01f07'>Delete Boom Box</t>", {["deleteBoomBox", [cursorObject]]
                spawn life_fnc_boomBox},nil,2,false,false,"",' (isNull objectParent player) && !(isNull cursorObject) && (alive cursorObject) ',-1]);};

    if!(playerSide isEqualTo independent) then {life_actions pushBack(_plb_obj addAction ["Remove Blindfold", {[2,cursorObject]
                spawn life_fnc_blindfoldAction},cursorObject,-1,false,true,"",'((cursorObject getVariable [ "plb_blinded",false ] ) && (cursorObject isKindOf "CAManBase") && (isPlayer cursorObject) && (alive cursorObject) && ((cursorObject distance player) < 5) && ((speed cursorObject) < 1))',6]);

        life_actions pushBack(_plb_obj addAction ["NG Item Shop", {[cursorObject,"","","hospital"]
                call life_fnc_virtualShopMenu},nil,1.5,false,false,"",'(playerSide isEqualTo civilian || playerSide isEqualTo west) && (typeOf cursorObject) isEqualTo "C_IDAP_supplyCrate_F" && cursorObject getVariable [ "plb_medSupply", false ]',5]);};

    if(life_inv_adrenalineShot>0) then {life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Give Adrenaline Shot</t>",life_fnc_adrenalineShot,objNull,-1,false,true,"",'(!isNull cursorObject) && ((player distance cursorObject) <= 5) && (isPlayer cursorObject) && (alive cursorObject) && (cursorObject getVariable [ "plb_downed",false ] ) && (life_inv_adrenalineShot > 0)',6]);};

    if(life_inv_bloodbag>0) then {life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Blood Transfusion Self</t>",life_fnc_bloodbag,player,-1,false,false,"",'((playerSide in [ independent, civilian ] && damage player > 0) || ((94 in life_side_talents) && damage player > 0.2) || ((95 in life_side_talents) && damage player > 0.1) || ((96 in life_side_talents) && damage player > 0)) && (life_inv_bloodbag > 0)',6]);

        life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Give Blood Transfusion</t>",life_fnc_bloodbag,cursorObject,-1,false,false,"",'isPlayer cursorObject && isNull objectParent player && ((playerSide in [ independent, civilian ] && damage cursorObject > 0) || ((94 in life_side_talents) && damage player > 0.2) || ((95 in life_side_talents) && damage player > 0.1) || ((96 in life_side_talents) && damage cursorObject > 0)) && (life_inv_bloodbag > 0)',6]);};

    if(life_inv_firstAidKit>0) then {life_actions pushBack(_plb_obj addAction ["<img image='\A3\Weapons_F\Items\data\UI\gear_FirstAidKit_CA' /> <t color='#65ff57'>Treat Yourself</t>",life_fnc_medKit,player,-1,false,false,"",'isNull objectParent player && ((damage player > 0.25) || (player getHit "legs" >= 0.5)) && (life_inv_firstAidKit > 0)',6]);

        life_actions pushBack(_plb_obj addAction ["<img image='\A3\Weapons_F\Items\data\UI\gear_FirstAidKit_CA' /> <t color='#65ff57'>Treat Player</t>",life_fnc_medKit,cursorObject,-1,false,false,"",'isPlayer cursorObject && isNull objectParent player && (player distance cursorObject <= 2) && (damage cursorObject > 0.25) && (life_inv_firstAidKit > 0)',6]);};

    if((life_inv_canna_papers>0)||(life_inv_canna_bong>0)||(life_inv_canna_rig>0)||(life_inv_canna_vape>0)||(life_inv_canna_joint>0)||(life_inv_canna_prejoint>0)) then {life_actions pushBack(_plb_obj addAction ["<img image='mpmissions\__cur_mp.altis\icons\canna_rawpapers.paa' /> <t color='#8b2b13'>Roll Joints with Raw Papers</t>", {["canna_papers"]
                spawn life_fnc_cannabisItems},"",0,false,false,"",'(life_inv_canna_papers > 0) && ((life_inv_cannas_3 > 0) || (life_inv_cannai_3 > 0) || (life_inv_marijuana > 0) || (life_inv_marijuanam > 0)) && !(player getVariable [ "plb_cannabisUsing", false ] )',6]);

        life_actions pushBack(_plb_obj addAction ["<img image='mpmissions\__cur_mp.altis\icons\canna_bong.paa' /> <t color='#8bfdee'>Take Bong Rip</t>", {["canna_bong"]
                spawn life_fnc_cannabisItems},"",0,false,false,"",'(life_inv_canna_bong > 0) && ((life_inv_cannas_3 > 0) || (life_inv_cannai_3 > 0) || (life_inv_marijuana > 0) || (life_inv_marijuanam > 0)) && !(player getVariable [ "plb_cannabisUsing", false ] )',6]);

        life_actions pushBack(_plb_obj addAction ["<img image='mpmissions\__cur_mp.altis\icons\canna_rig.paa' /> <t color='#ffda3f'>Take Dab With Glass Rig</t>", {["canna_rig"]
                spawn life_fnc_cannabisItems},"",0,false,false,"",'(life_inv_canna_rig > 0) && (life_inv_canna_dab > 0) && !(player getVariable [ "plb_cannabisUsing", false ] )',6]);

        life_actions pushBack(_plb_obj addAction ["<img image='mpmissions\__cur_mp.altis\icons\canna_vape.paa' /> <t color='#ff547f'>Rip Wax Pen</t>", {["smokeWeedJointOrVape", [true]]
                spawn life_fnc_cannabisItems},"",0,false,false,"",'(life_inv_canna_vape > 0) && !(player getVariable [ "plb_cannabisUsing", false ] )',6]);

        life_actions pushBack(_plb_obj addAction ["<img image='mpmissions\__cur_mp.altis\icons\canna_joint.paa' /> <t color='#ca73fb'>Smoke Rolled Joint</t>", {["smokeWeedJointOrVape", [false,"canna_joint"]]
                spawn life_fnc_cannabisItems},"",0,false,false,"",'(life_inv_canna_joint > 0) && !(player getVariable [ "plb_cannabisUsing", false ] )',6]);

        life_actions pushBack(_plb_obj addAction ["<img image='mpmissions\__cur_mp.altis\icons\canna_preroll.paa' /> <t color='#ca73fb'>Smoke Pre-Roll</t>", {["smokeWeedJointOrVape", [false,"canna_prejoint"]]
                spawn life_fnc_cannabisItems},"",0,false,false,"",'(life_inv_canna_prejoint > 0) && !(player getVariable [ "plb_cannabisUsing", false ] )',6]);};

    life_actions pushBack(_plb_obj addAction ["Pull Out Unconscious", {private _vehicle=cursorObject;

            private _vehicleCrew=crew _vehicle- [driver _vehicle];

            private _locked=locked _vehicle;

            _vehicle lock 0;

            player moveInDriver _vehicle;

            moveOut player;

            player MoveInTurret [_vehicle, [0]];
 {moveOut player;

                player moveInCargo [_vehicle,_vehicle getCargoIndex _x];}
            forEach _vehicleCrew;
 [_vehicle,_locked]
            spawn {params ["_vehicle","_locked"];

                uiSleep 1.5;

                player action ["Eject",vehicle player];

                moveOut player;

                if(_locked isEqualTo 2) then {_vehicle lock 2};};},cursorTarget,0,false,false,"",'!isNull cursorTarget && (isNull objectParent player) && alive cursorTarget && (player distance cursorTarget) < 4 && (count crew cursorTarget) > 0 && { !alive _x } count crew cursorTarget > 0 && (cursorTarget isKindOF "Car" || cursorTarget isKindOf "Ship" || cursorTarget isKindOf "Air")',6]);

    life_actions pushBack(_plb_obj addAction ["Destroy Medical Supplies", {[cursorObject]
            spawn life_fnc_medSupplyDestroy},nil,1.5,false,false,"",'(typeOf cursorObject) isEqualTo "C_IDAP_supplyCrate_F" && cursorObject getVariable [ "plb_medSupply", false ]',3]);

    life_actions pushBack(_plb_obj addAction ["Clean Up Campfire", {if((typeOf cursorObject isEqualTo"Land_Campfire_F")||(typeOf cursorObject isEqualTo"MetalBarrel_burning_F")) then {deleteVehicle cursorObject}},nil,-1,false,false,"",'!isNull cursorObject && (player distance cursorObject) <= 4 && ((typeOf cursorObject) isEqualTo "Land_Campfire_F" || (typeOf cursorObject) isEqualTo "MetalBarrel_burning_F") && cursorObject getVariable [ "plb_CampfireDeletable", true ]',4]);};

if!(life_scrollDisabled) then {switch(playerSide) do {case civilian: {if(!isNil"SRV_cartelEvent") then {life_actions pushBack(_plb_obj addAction ["<t color='#F53E4D'>Capture Event Point</t>", {[SRV_cartelEvent param [1,objNull]]
                        spawn life_fnc_cartelEventCapture},nil,2,false,false,"",'private _flag = SRV_cartelEvent param [ 1, objNull ] ; !isNull _flag && { (_flag distance2D player < 2.5) && !(isObjectHidden _flag) && !(life_gang_data isEqualTo [ ] ) && isNull objectParent player }',6]);};

            if(SRV_gangBoatFortressData select 0) then {life_actions pushBack(_plb_obj addAction ["<t color='#F53E4D'>Capture Gang Boat Flag</t>", {[cursorObject]
                        spawn life_fnc_captureGangBoatFlag},nil,2,false,false,"",'private _flags = SRV_gangBoatFortressData param [ 1, [ ] ] ; cursorTarget in _flags && { (cursorTarget distance2D player < 2.5) && !(life_gang_data isEqualTo [ ] ) && isNull objectParent player }',6]);};

            life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Stop time trial</t>", {["stop"]
                    call life_fnc_timeTrial},nil,-1,false,true,"",'player getVariable [ "plb_timeTrialActive", false ]',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#ff33cc'>Pickup easter bunny</t>", {["pickupBunny", [cursorObject]]
                    call life_fnc_easterSeasonalEventCL},nil,-1,false,true,"",'cursorObject getVariable [ "easterRabbitActive", false ] && (player distance cursorObject) < 2',2]);

            life_actions pushBack(_plb_obj addAction ["<t color='#E40010'>Open</t> <t color='#1FD537'>present</t>", {["openPresent"]
                    call life_fnc_openChristmasTreePresentCL},nil,-1,false,true,"",'cursorObject getVariable [ "plb_christmasPresent", false ] && (typeOf cursorObject) in [ "Land_PaperBox_01_small_closed_brown_F", "Box_EAF_Uniforms_F" ] && (player distance cursorObject) < 3',2]);

            life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Use Defibrillator</t>",life_fnc_revivePlayer,cursorObject,-1,false,true,"",'!isNull cursorObject && cursorObject isKindOf "CAManBase" && !(alive cursorObject) && (cursorObject getVariable [ "plb_revivable",false ] || ((cursorObject getVariable [ "plb_group",grpNull ] isEqualTo group player) && !(isNull (cursorObject getVariable [ "plb_group",grpNull ] )))) && life_inv_defib > 0 && (player distance cursorObject) < 3.5 && (isNull objectParent player) && (isNull objectParent cursorObject)',6]);

            life_actions pushBack(_plb_obj addAction ["Rob Person", {[cursorObject]
                    call life_fnc_robAction},nil,0,false,false,"",'!isNull cursorObject && !(currentWeapon player in [ "", "Binocular", "Rangefinder", "hgun_Pistol_Signal_F" ] ) && ((cursorObject getVariable [ "plb_surrendered",false ] ) || (cursorObject getVariable [ "plb_restrained",false ] && 16 in life_honor_talents && 8 in life_side_talents && cursorObject getVariable [ "plb_civRestrained",false ] )) && cursorObject isKindOf "CAManBase" && (isPlayer cursorObject) && alive cursorObject && cursorObject distance player < 5 && !(cursorObject getVariable [ "plb_escorting",false ] ) && speed cursorObject < 1',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#FF69B4'>Cover in Baby Oil</t>", {[cursorObject]
                    call life_fnc_babyOil},nil,0,false,false,"",'life_inv_babyoil>0 && !isNull cursorObject && (cursorObject getVariable [ "plb_restrained",false ] ) && cursorObject isKindOf "CAManBase" && (isPlayer cursorObject) && alive cursorObject && cursorObject distance player < 5 && speed cursorObject < 1 && (isNull objectParent player)',6]);

            if(life_inv_ziptie>0) then {life_actions pushBack(_plb_obj addAction ["Restrain", {[cursorObject]
                        call life_fnc_restrain},nil,-1,false,true,"",'(cursorObject getVariable [ "plb_surrendered",false ] || cursorObject getVariable [ "plb_downed",false ] ) && cursorObject isKindOf "CAManBase" && (isPlayer cursorObject) && alive cursorObject && cursorObject distance player < 5 && !(cursorObject getVariable [ "plb_escorting",false ] ) && !(cursorObject getVariable [ "plb_restrained",false ] ) && speed cursorObject < 1 && life_inv_ziptie > 0 && (isNull objectParent player) && (isNull objectParent cursorObject)',6]);};

            if((call PLB_fnc_hasDeck)) then {life_actions pushBack(_plb_obj addAction ["Lockpick Handcuffs", {[cursorObject,false,true]
                        spawn life_fnc_lockpick},nil,-1,false,true,"",'(call PLB_fnc_hasDeck) && !isNull cursorObject && cursorObject isKindOf "CAManBase" && (isPlayer cursorObject) && player distance cursorObject < 3.5 && (cursorObject getVariable [ "plb_restrained",false ] ) && !(cursorObject getVariable [ "plb_civRestrained",false ] ) && !(cursorObject getVariable [ "plb_escorting",false ] ) && !(cursorObject getVariable [ "plb_downed",false ] ) && (isNull objectParent player) && (isNull objectParent cursorObject)',6]);};

            if(life_inv_boltCutter>=1) then {life_actions pushBack(_plb_obj addAction ["Boltcut Handcuffs", {[cursorObject,true]
                        spawn life_fnc_lockpick},nil,-1,false,true,"",'life_inv_boltCutter >= 1 && !isNull cursorObject && cursorObject isKindOf "CAManBase" && (isPlayer cursorObject) && player distance cursorObject < 3.5 && (cursorObject getVariable [ "plb_restrained",false ] ) && !(cursorObject getVariable [ "plb_civRestrained",false ] ) && !(cursorObject getVariable [ "plb_escorting",false ] ) && !(cursorObject getVariable [ "plb_downed",false ] ) && (isNull objectParent player) && (isNull objectParent cursorObject)',6]);};

            if(life_inv_blindfold>=1) then {life_actions pushBack(_plb_obj addAction ["Apply Blindfold", {[1,cursorObject]
                        spawn life_fnc_blindfoldAction},cursorObject,-1,false,true,"",'((cursorObject getVariable [ "plb_restrained",false ] ) && !(cursorObject getVariable [ "plb_blinded",false ] ) && (life_inv_blindfold >= 1) && (cursorObject isKindOf "CAManBase") && (isPlayer cursorObject) && (alive cursorObject) && ((cursorObject distance player) < 5) && ((speed cursorObject) < 1)) && (isNull objectParent player)',6]);};

            if((call PLB_fnc_hasDeck)) then {life_actions pushBack(_plb_obj addAction ["Pick Vehicle Lock", {[cursorObject,false,true]
                        spawn life_fnc_lockpick},nil,-1,false,true,"",'!isNull cursorObject && alive cursorObject && (player distance cursorObject) < 4 && (call PLB_fnc_hasDeck) && (locked cursorObject != 0) && speed cursorObject < 2 && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship" || cursorObject isKindOf "Tank") && !(cursorObject in life_vehicles) && (isNull objectParent player)',6]);};

            if(life_inv_ignitionbomb>0) then {life_actions pushBack(_plb_obj addAction ["<img image='mpmissions\__cur_mp.altis\icons\ignitionbomb.paa' /> <t color='#e99755'>Attach Ignition Bomb</t>", {[vehicle player]
                        call life_fnc_ignitionBomb},nil,-1,false,true,"",'life_inv_ignitionbomb > 0 && !(isNull objectParent player) && (driver (vehicle player) isEqualTo player)',6]);};

            if(!(isNull objectParent player) && (vehicle player isKindOf "B_T_VTOL_01_infantry_F")) then {life_actions pushBack(_plb_obj addAction ["<t color='#e99755'>Toggle Ramp</t>", {private _v = vehicle player;
                        _v animateDoor ["Door_1_source", 1 - (_v animationSourcePhase "Door_1_source")]},nil,-1,false,true,"",'!(isNull objectParent player) && (vehicle player isKindOf "B_T_VTOL_01_infantry_F") && (driver (vehicle player) isEqualTo player)',6]);};

            if(life_inv_remotekillswitch>0) then {life_actions pushBack(_plb_obj addAction ["<img image='mpmissions\__cur_mp.altis\icons\phonebomb.paa' /><t color='#FF0000'>Insert Remote Engine Disabler</t>", {["attach",cursorObject]
                        spawn life_fnc_remoteEngineKillSwitch},nil,-1,false,true,"",'life_inv_remotekillswitch > 0 && (isNull objectParent player) && !isNull cursorObject && !life_action_in_use && !(cursorObject getVariable [ "plb_remoteEngineKillSwitchActive", false ] ) && alive cursorObject && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship" || cursorObject isKindOf "Tank") && player distance cursorObject < 5',6]);};

            if(life_inv_phonebomb>0) then {life_actions pushBack(_plb_obj addAction ["<img image='mpmissions\__cur_mp.altis\icons\phonebomb.paa' /><t color='#FF0000'>Insert Remote Bomb</t>", {["attachBomb",cursorObject]
                        spawn life_fnc_remoteExplosive},nil,-1,false,true,"",'life_inv_phonebomb > 0 && (isNull objectParent player) && !isNull cursorObject && !life_action_in_use && !(cursorObject getVariable [ "plb_phoneBombActive", false ] ) && alive cursorObject && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship" || cursorObject isKindOf "Tank") && player distance cursorObject < 5',6]);};

            if(life_inv_arsonistkit>0) then {life_actions pushBack(_plb_obj addAction ["<img image='mpmissions\__cur_mp.altis\icons\arsonistkit.paa' /> Set house on fire", {[cursorObject]
                        spawn life_fnc_commitArsonClient},nil,-1,false,true,"",'life_inv_arsonistkit > 0 && { (player distance cursorObject) < 10 } && (isNull objectParent player) && !isNull cursorObject && !life_action_in_use && typeOf cursorObject in life_houseTypes',6]);};

            if(isNull objectParent player) then {life_actions pushBack(_plb_obj addAction ["Unrestrain", {[cursorObject,true]
                        spawn life_fnc_unrestrain},nil,-1,false,true,"",'!isNull cursorObject && cursorObject isKindOf "CAManBase" && (isPlayer cursorObject) && player distance cursorObject < 3.5 && (cursorObject getVariable [ "plb_restrained",false ] ) && (cursorObject getVariable [ "plb_civRestrained",false ] ) && !(cursorObject getVariable [ "plb_escorting",false ] ) && !(cursorObject getVariable [ "plb_downed",false ] ) && !(currentWeapon player in [ "","Binocular","Rangefinder","hgun_Pistol_Signal_F" ] ) && (isNull objectParent player) && (isNull objectParent cursorObject)',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#FFF000'>Pull out of vehicle</t>", {[cursorObject]
                        call life_fnc_pulloutAction},nil,-1,false,true,"",'!isNull cursorObject && (player distance cursorObject) < 4 && !(currentWeapon player in [ "", "Binocular", "Rangefinder", "hgun_Pistol_Signal_F" ] ) && (side player isEqualTo civilian) && (locked cursorObject isEqualTo 0) && (count crew cursorObject) > 0 && speed cursorObject < 2 && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship") && { alive _x } count crew cursorObject > 0 && (isNull objectParent player)',6]);

                life_actions pushBack(_plb_obj addAction ["Remove Blindfold", {[2,cursorObject]
                        spawn life_fnc_blindfoldAction},cursorObject,-1,false,true,"",'((cursorObject getVariable [ "plb_blinded",false ] ) && (cursorObject isKindOf "CAManBase") && (isPlayer cursorObject) && (alive cursorObject) && ((cursorObject distance player) < 5) && ((speed cursorObject) < 1)) && (isNull objectParent player)',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Execute!</t>", {[cursorObject]
                        call life_fnc_execute},nil,-1,false,true,"",'!isNull cursorObject && !(alive cursorObject) && cursorObject isKindOf "CAManBase" && !(typeOf cursorObject in [ "Goat_random_F", "Cock_random_F", "Hen_random_F", "Sheep_random_F","Alsatian_Random_F" ] ) && !(currentWeapon player in [ "", "Binocular", "Rangefinder", "hgun_Pistol_Signal_F" ] ) && player distance cursorObject < 2 && (isNull objectParent player) && isNull (objectParent cursorObject)',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Harvest Organs</t>", {[cursorObject,true]
                        call life_fnc_execute},nil,-1,false,true,"",'!isNull cursorObject && !(alive cursorObject) && cursorObject isKindOf "CAManBase" && player distance cursorObject < 2 && (isNull objectParent player) && life_inv_skinningknife >= 1 && (isNull objectParent cursorObject) && !((cursorObject getVariable [ "plb_wasCop", false ] ) || (side cursorObject isEqualTo west))',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Circumcise</t>", {[cursorObject,true]
                        call life_fnc_execute},nil,-1,false,true,"",'!isNull cursorObject && !(alive cursorObject) && cursorObject isKindOf "CAManBase" && player distance cursorObject < 2 && (isNull objectParent player) && life_inv_skinningknife >= 1 && (isNull objectParent cursorObject) && ((cursorObject getVariable [ "plb_wasCop", false ] ) || (side cursorObject isEqualTo west))',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#ff27c0'>Executioner Move</t>", {["killerPlayer", [cursorObject]]
                        spawn life_fnc_executionerMove},nil,-1,false,true,"",'!isNull cursorObject && cursorObject isKindOf "CAManBase" && (isPlayer cursorObject) && player distance cursorObject < 3.5 && (cursorObject getVariable [ "plb_restrained",false ] ) && (cursorObject getVariable [ "plb_civRestrained",false ] ) && !(cursorObject getVariable [ "plb_escorting",false ] ) && !(cursorObject getVariable [ "plb_downed",false ] ) && !(currentWeapon player in [ "", "Binocular", "Rangefinder", "hgun_Pistol_Signal_F", "hgun_P07_F", "hgun_P07_khk_F", "hgun_P07_blk_F" ] ) && ((( [ currentWeapon player ] call BIS_fnc_itemType) param [ 1, "" ] ) isEqualTo "Handgun") && (isNull objectParent player) && (isNull objectParent cursorObject)',6]);};

            if(457 in life_completedLifetimeQuests) then {life_actions pushBack(_plb_obj addAction ["<t color='#330000'>Skin Scalp</t>", {[cursorObject]
                        spawn life_fnc_harvestScalp},nil,-1,false,true,"",'!isNull cursorObject && !(alive cursorObject) && cursorObject isKindOf "CAManBase" && player distance cursorObject < 2 && (isNull objectParent player) && life_inv_skinningknife >= 1 && (isNull objectParent cursorObject) && (playerSide isEqualTo civilian)',6]);};

            if(life_inv_snake>0||life_inv_rabbit>0||life_inv_chicken>0||life_inv_dog>0||life_inv_sheep>0||life_inv_goat>0||life_inv_manflesh>0) then {life_actions pushBack(_plb_obj addAction ["Cook Raw Meat",life_fnc_cookMeat,"",-1,false,false,"",'!isNull cursorObject && ((typeOf cursorObject) isEqualTo "Land_Campfire_F" || (typeOf cursorObject) isEqualTo "MetalBarrel_burning_F") && inflamed cursorObject && (life_inv_snake > 0 || life_inv_rabbit > 0 || life_inv_chicken > 0 || life_inv_dog > 0 || life_inv_sheep > 0 || life_inv_goat > 0 || life_inv_manflesh > 0)',4]);};

            life_actions pushBack(_plb_obj addAction ["Cook Oysters",life_fnc_processAction,"oyster",1.5,false,false,"",'!isNull cursorObject && ((typeOf cursorObject) isEqualTo "Land_Campfire_F" || (typeOf cursorObject) isEqualTo "MetalBarrel_burning_F") && inflamed cursorObject && life_inv_oysteru > 0 && !life_is_processing',5]);

            life_actions pushBack(_plb_obj addAction ["Fry Oysters",life_fnc_processAction,"oysterfry",1.5,false,false,"",'!isNull cursorObject && ((typeOf cursorObject) isEqualTo "Land_Campfire_F" || (typeOf cursorObject) isEqualTo "MetalBarrel_burning_F") && inflamed cursorObject && life_inv_oysterp > 0 && !life_is_processing',5]);

            life_actions pushBack(_plb_obj addAction ["Escort", {[cursorObject]
                    call life_fnc_escortAction},"",-1,false,true,"",'!isNull cursorObject && cursorObject isKindOf "CAManBase" && (isPlayer cursorObject) && !(currentWeapon player in [ "", "Binocular", "Rangefinder", "hgun_Pistol_Signal_F" ] ) && alive cursorObject && cursorObject distance player < 3.5 && (cursorObject getVariable [ "plb_restrained",false ] ) && !(cursorObject getVariable [ "plb_escorting",false ] ) && (isNull objectParent player) && (isNull objectParent cursorObject)',6]);

            life_actions pushBack(_plb_obj addAction ["Stop Escorting",life_fnc_stopEscorting,"",-1,false,true,"",'!isNull (player getVariable [ "plb_escortObj",objNull ] ) && ((player getVariable [ "plb_escortObj",objNull ] ) getVariable [ "plb_escorting",false ] ) && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#FFF000'>Put in Vehicle</t>", {[cursorObject]
                    call life_fnc_putInVeh},nil,-1,false,false,"",'!isNull cursorObject && (player distance cursorObject) < 6 && speed cursorObject < 2 && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship") && !isNull (player getVariable [ "plb_escortObj",objNull ] ) && isPlayer (player getVariable [ "plb_escortObj",objNull ] ) && alive (player getVariable [ "plb_escortObj",objNull ] ) && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["Virtual Item Storage", {[cursorObject]
                    spawn life_fnc_openInventory},nil,0,false,true,"",'!isNull cursorObject && (player distance cursorObject) < 6 && ((typeOf cursorObject) in [ "Land_TentA_F","Land_TentDome_F","B_CargoNet_01_ammo_F","C_IDAP_CargoNet_01_supplies_F", "B_CargoNet_01_ammo_F","O_Truck_03_covered_F", "Box_FIA_Ammo_F", "VirtualReammoBox_F", "I_E_CargoNet_01_ammo_F" ] )',5]);

            if((life_is_arrested param [0,0]) isEqualTo 1&&life_inv_shank>0) then {life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Shank!</t>", {[cursorObject]
                        call life_fnc_useShank},3,-1,false,false,"",' !isNull cursorTarget && cursorTarget isKindOf "CAManBase" && isPlayer cursorTarget && alive cursorTarget && life_inv_shank > 0  && isNull objectParent player && player distance cursorTarget < 2 ',2]);};

            if(life_delivery_type>0) then {life_actions pushBack(_plb_obj addAction ["Attach sling to cargo", {private _r=ropeCreate [vehicle player,"slingload0",life_delivery_object, [0,0,0],7];},"",2,true,true,"",' vehicle player != player && driver (vehicle player) == player && (vehicle player) isKindOf "AIR" && !(life_delivery_object in (ropeAttachedObjects (vehicle player))) && ((getPos (vehicle player)) distance (getPos life_delivery_object)) < 14 && (getPos (vehicle player)) select 2 < 12 ',-1]);

                life_actions pushBack(_plb_obj addAction ["Detach all cargo", {{ropeDestroy _x}
                        forEach(ropes(vehicle player));},"",2,true,true,"",' vehicle player != player && (vehicle player) isKindOf "AIR" && life_delivery_object in (ropeAttachedObjects (vehicle player)) ',-1]);};

            if((getPlayerUID player isEqualTo(SRV_governorData param [0,"GovUID"]))&& {player distance2D(getMarkerPos"gov")<=15}) then {life_actions pushBack(_plb_obj addAction ["<t color='#2ef5ef'>Governor Laws</t>", {[]
                        spawn life_fnc_govLawMenu},nil,0,false,false,"",'(playerSide isEqualTo civilian) && (typeOf cursorObject isEqualTo "Land_Laptop_Intel_01_F") && !(isNull cursorObject) && (player distance cursorObject < 5)',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#2ef5ef'>Governor Bank</t>", {[]
                        call life_fnc_govBank},nil,0,false,false,"",'(playerSide isEqualTo civilian) && !(isNull cursorObject) && (typeOf cursorObject isEqualTo "Land_Laptop_Intel_01_F") && (player distance cursorObject < 5)',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#2ef5ef'>ATM</t>", {[]
                        call life_fnc_atmMenu},nil,1.5,true,true,"""",'(playerSide isEqualTo civilian) && !(isNull cursorObject) && (typeOf cursorObject isEqualTo "Land_Laptop_Intel_01_F") && (player distance cursorObject < 5)',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#2ef5ef'>Toggle Governor Building Locks</t>", {["toggleGovBuildingLocks",cursorObject]
                        spawn life_fnc_govSystem},nil,0,false,false,"",'(playerSide isEqualTo civilian) && !(isNull cursorObject) && (typeOf cursorObject isEqualTo "Land_Hotel_02_F") && (player distance cursorObject < 15)',6]);};

            life_actions pushBack(_plb_obj addAction ["<t color='#0099FF'>Pick Barley</t>", {["barley",1,"neriumo2d"]
                    call life_fnc_gatherObject},nil,1,true,true,"""",'player distance cursorObject < 3 && { [ str cursorObject,"neriumo2d" ] call KRON_StrInStr } && (!((cursorObject isKindOf "Car") || (cursorObject isKindOf "Air") || (cursorObject isKindOf "Ship"))) && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#0099FF'>Pick Berries</t>", {["berry",3,"neriumo"]
                    call life_fnc_gatherObject},nil,1,true,true,"""",'player distance cursorObject < 3 && { [ str cursorObject,"neriumo" ] call KRON_StrInStr } && (!((cursorObject isKindOf "Car") || (cursorObject isKindOf "Air") || (cursorObject isKindOf "Ship"))) && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#0099FF'>Pick Berries</t>", {["berry",3,"colored"]
                    call life_fnc_gatherObject},nil,1,true,true,"""",'player distance cursorObject < 3 && { [ str cursorObject,"b_colored" ] call KRON_StrInStr } && (!((cursorObject isKindOf "Car") || (cursorObject isKindOf "Air") || (cursorObject isKindOf "Ship"))) && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#0099FF'>Pick Rye</t>", {["rye",1,"arundod2s"]
                    call life_fnc_gatherObject},nil,1,true,true,"""",'player distance cursorObject < 7 && { [ str cursorObject,"arundod2s" ] call KRON_StrInStr } && (!((cursorObject isKindOf "Car") || (cursorObject isKindOf "Air") || (cursorObject isKindOf "Ship")))',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#0099FF'>Pick Corn</t>", {["corn",1,"ficusc1s"]
                    call life_fnc_gatherObject},nil,1,true,true,"""",'player distance cursorObject < 7 && { [ str cursorObject,"ficusc1s" ] call KRON_StrInStr } && (!((cursorObject isKindOf "Car") || (cursorObject isKindOf "Air") || (cursorObject isKindOf "Ship")))',6]);

            if(player distance(getMarkerPos"illegal_marker_8_0")<175) then {life_actions pushBack(_plb_obj addAction ["Gather Henbane",life_fnc_gather,"",0,false,false,"",'!life_action_in_use && (player distance (getMarkerPos "illegal_marker_8_0") < 150) && (isNull objectParent player)',6]);};

            if(player distance(getMarkerPos"illegal_marker_3_0")<175) then {life_actions pushBack(_plb_obj addAction ["Gather Ephedra",life_fnc_gather,"",0,false,false,"",'!life_action_in_use && (player distance (getMarkerPos "illegal_marker_3_0") < 150) && (isNull objectParent player)',6]);};

            if(player distance(getMarkerPos"illegal_marker_2_0")<170) then {life_actions pushBack(_plb_obj addAction ["Gather Cocaine",life_fnc_gather,"",0,false,false,"",'!life_action_in_use && (player distance (getMarkerPos "illegal_marker_2_0") < 150) && (isNull objectParent player) ',6]);};

            if(player distance(getMarkerPos"illegal_marker_1_0")<175) then {life_actions pushBack(_plb_obj addAction ["Gather Opium",life_fnc_gather,"",3,false,true,"",'!life_action_in_use && (player distance (getMarkerPos "illegal_marker_1_0") < 150) && (isNull objectParent player) ',6]);};

            if(player distance(getMarkerPos"illegal_marker_4_0")<150) then {life_actions pushBack(_plb_obj addAction ["Mine Uranium",life_fnc_mineUranium,"",0,false,false,"",'!life_action_in_use && (player distance (getMarkerPos "illegal_marker_4_0") < 150) && (isNull objectParent player) && ((str(cursorObject) find "factory_tunnel_f") >= 0) && ((player distance cursorObject) <= 15) && (life_inv_pickaxe > 0)',6]);};

            if({player distance getMarkerPos format ["apple_%1",_x]
                <75}
            count [1,2,3,4,5]
            >0) then {life_actions pushBack(_plb_obj addAction ["Pick Apples",life_fnc_gather,"",0,false,false,"",'!life_action_in_use && { player distance getMarkerPos format [ "apple_%1",_x ] < 50 } count [ 1,2,3,4,5 ] > 0 && (isNull objectParent player)',6]);};

            if({player distance getMarkerPos format ["peaches_%1",_x]
                <75}
            count [1,2,3,4]
            >0) then {life_actions pushBack(_plb_obj addAction ["Pick Peaches",life_fnc_gather,"",0,false,false,"",'!life_action_in_use && { player distance getMarkerPos format [ "peaches_%1",_x ] < 50 } count [ 1,2,3,4 ] > 0 && (isNull objectParent player)',6]);};

            if({player distance getMarkerPos format ["weed_%1",_x]
                <170}
            count [1,2]
            >0) then {life_actions pushBack(_plb_obj addAction ["Gather Cannabis",life_fnc_gather,"",3,false,true,"",'!life_action_in_use && ((player distance (getMarkerPos "weed_1") < 150) || (player distance (getMarkerPos "weed_2") < 150)) && (isNull objectParent player) ',6]);};

            if({player distance getMarkerPos format ["mine_%1",_x]
                <90}
            count [1,2,3,4,5,6,7]
            >0) then {life_actions pushBack(_plb_obj addAction ["Mine Quarry",life_fnc_gather,"",0,false,false,"",'!life_action_in_use && ( { player distance getMarkerPos format [ "mine_%1",_x ] < 100 } count [ 1,2,3,4,5,6,7 ] > 0) && (isNull objectParent player) && (life_inv_pickaxe > 0)',6]);};

            if({player distance getMarkerPos format ["mine_%1",_x]
                <90}
            count [1,2,3,4,5,6,7]
            >0) then {life_actions pushBack(_plb_obj addAction ["<t color='#0BEE0F'>Start Metal Detector</t>",life_fnc_metalDetector,"",0,false,false,"",'!life_action_in_use && ( { player distance getMarkerPos format [ "mine_%1",_x ] < 100 } count [ 1,2,3,4,5,6,7 ] > 0) && (isNull objectParent player) && (life_inv_metaldetector > 0)',6]);};

            if(({player distance getMarkerPos format ["salt_%1",_x]
                <175}
            count [1,2,3,4]
            >0)|| {surfaceType position player=="#GdtDead"}) then {life_actions pushBack(_plb_obj addAction ["Gather Salt",life_fnc_gather,"",0,false,false,"",'!life_action_in_use && ((player distance (getMarkerPos "salt_1") < 150) || (player distance (getMarkerPos "salt_2") < 150) || (player distance (getMarkerPos "salt_3") < 150) || (player distance (getMarkerPos "salt_4") < 150) || (surfaceType position player == "#GdtDead")) && (isNull objectParent player) ',6]);};

            if({player distance getMarkerPos format ["rock_%1",_x]
                <175}
            count [1,2,3,4]
            >0) then {life_actions pushBack(_plb_obj addAction ["Gather Phosphorus",life_fnc_gather,"",0,false,false,"",'!life_action_in_use && ((player distance (getMarkerPos "rock_1") < 150) || (player distance (getMarkerPos "rock_2") < 150) || (player distance (getMarkerPos "rock_3") < 150) || (player distance (getMarkerPos "rock_4") < 150)) && (isNull objectParent player) ',6]);};

            if({player distance getMarkerPos format ["oil_%1",_x]
                <200}
            count [1,2,3,4]
            >0) then {if(life_inv_pickaxe>=1&&!((player nearEntities ["Car",15]
                select {typeOf _x in ["B_Truck_01_fuel_F","C_Truck_02_fuel_F","C_Van_01_fuel_F"]}) isEqualTo [])) then {life_actions pushBack(_plb_obj addAction ["Gather Oil",life_fnc_gather,"",0,false,false,"",'!life_action_in_use && ((player distance (getMarkerPos "oil_1") < 150) || (player distance (getMarkerPos "oil_2") < 150) || (player distance (getMarkerPos "oil_3") < 150) || (player distance (getMarkerPos "oil_4") < 150)) && isNull objectParent player && (life_inv_pickaxe > 0)',6]);}
                else {life_actions pushBack(_plb_obj addAction ["Gather Hydrogen Sulfate",life_fnc_gather,"",0,false,false,"",'!life_action_in_use && ((player distance (getMarkerPos "oil_1") < 150) || (player distance (getMarkerPos "oil_2") < 150) || (player distance (getMarkerPos "oil_3") < 150) || (player distance (getMarkerPos "oil_4") < 150)) && (isNull objectParent player) ',6]);};};

            if(life_inv_woodaxe>0) then {life_actions pushBack(_plb_obj addAction ["Chop Tree", {[cursorObject]
                        call life_fnc_chopTree},"",0,false,false,"",'((player distance2D cursorObject) < 4) && (((str(cursorObject) find " t_") >= 0) || ((str(cursorObject) find " palm_") >= 0)) && (isNull objectParent player)',6]);};

            if({player inArea format ["turtle_%1",_x]}
            count [1,2]
            >0) then {life_actions pushBack(_plb_obj addAction ["Grab Turtle",life_fnc_catchTurtle,"",1.5,false,false,"",'(player inArea "turtle_1" || player inArea "turtle_2") && { count (nearestObjects [ player, [ "Turtle_F" ] ,4 ] ) > 0 } && (isNull objectParent player)',6]);};

            if({player inArea format ["turtle_%1",_x]}
            count [1,2]
            >0) then {life_actions pushBack(_plb_obj addAction ["<t color='#7FFFD4'>Find Oysters</t>",life_fnc_gather,"",0,false,false,"",'(player inArea "turtle_1" || player inArea "turtle_2") && { (isNull objectParent player) && !life_action_in_use && { count (nearestObjects [ player, [ "Land_Wreck_Traw_F", "Land_Wreck_Traw2_F" ] ,20 ] ) > 0 } }',6]);};

            if(surfaceIsWater(getPosATL(vehicle player))) then {life_actions pushBack(_plb_obj addAction ["Drop Fishing Net",life_fnc_dropFishingNet,"",5,false,true,"",'(surfaceIsWater (getPosATL vehicle player)) && ((vehicle player isKindOf "Ship") || (typeOf (vehicle player) isEqualTo "I_MRAP_03_F")) && life_carryWeight < life_maxWeight && speed (vehicle player) < 2 && speed (vehicle player) > -1 && !life_net_dropped ',6]);

                life_actions pushBack(_plb_obj addAction ["Catch Fish",life_fnc_catchFish,"",1.5,false,false,"",'(surfaceIsWater (getPosATL player)) && count(nearestObjects [ player, [ "Fish_Base_F" ] , 3 ] ) > 0 && (isNull objectParent player)',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#0099FF'>Collect Water</t>",life_fnc_gatherWater,nil,1,false,true,"""",'surfaceIsWater position player && vehicle player == player && (getPosASL player) select 2 < 1 && (isNull objectParent player)',6]);

                if(life_inv_excavator>0) then {life_actions pushBack(_plb_obj addAction ["Search Wreck",life_fnc_searchWreck,"",5,false,true,"",'(surfaceIsWater (getPosATL vehicle player)) && ((str(cursorObject) find "wreck_") >= 0) && ((player distance cursorObject) <= 20) && (life_inv_excavator > 0) && (isNull objectParent player)',6]);};};

            life_actions pushBack(_plb_obj addAction ["Setup Oil Pump", {[cursorObject]
                    call life_fnc_oilPump},nil,0,false,false,"",'((typeOf cursorObject in [ "B_Truck_01_fuel_F","C_Truck_02_fuel_F","C_Van_01_fuel_F" ] ) && !(toLower("mpmissions\__cur_mp.altis\images\Van_01_adds_crank.jpg") in (getObjectTextures cursorObject)) && !isNull cursorObject && (player distance cursorObject) < 5 && !(cursorObject getVariable [ "plb_oilPump",false ] )) && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["Break Down Oil Pump", {[cursorObject]
                    call life_fnc_oilPump},nil,0,false,false,"",'((typeOf cursorObject in [ "B_Truck_01_fuel_F","C_Truck_02_fuel_F","C_Van_01_fuel_F" ] ) && !isNull cursorObject && (player distance cursorObject) < 5 && (cursorObject getVariable [ "plb_oilPump",false ] )) && (isNull objectParent player)',6]);

            if((typeOf cursorObject in ["B_Truck_01_fuel_F","C_Truck_02_fuel_F","C_Van_01_fuel_F"])&&!isNull cursorObject&&(player distance cursorObject)<5&&(cursorObject getVariable ["plb_oilPump",false])) then {life_actions pushBack(_plb_obj addAction ["Drill for Oil!", {[cursorObject]
                        call life_fnc_drillOil},nil,0,false,false,"",'!life_is_processing && (isNull objectParent player)',6]);};

            if(life_inv_skinningknife>=1) then {life_actions pushBack(_plb_obj addAction ["Skin Animal", {[cursorObject]
                        call life_fnc_skinAnimal},"",0,false,false,"",'typeOf cursorObject in [ "Cock_random_F", "Hen_random_F", "Fin_random_F", "Alsatian_Random_F", "Goat_random_F", "Sheep_random_F", "Rabbit_F", "Snake_random_F" ] && !(alive cursorObject) && !life_action_in_use && life_inv_skinningknife >= 1 && (isNull objectParent player)',6]);};

            if("O_Truck_03_device_F"in(life_vehicles apply {typeOf _x})) then {life_actions pushBack(_plb_obj addAction ["Gather with device", {[cursorObject]
                        call life_fnc_deviceMine},nil,0,false,false,"",'(typeOf cursorObject isEqualTo "O_Truck_03_device_F") && (objNull isEqualTo (cursorObject getVariable [ "plb_mining", objNull ] )) && { cursorObject in life_vehicles } && (isNull objectParent player)',6]);};

            life_actions pushBack(_plb_obj addAction ["Get the lab ready", {[cursorObject]
                    call life_fnc_crankLab},nil,0,false,false,"",'((typeOf cursorObject == "C_Van_01_box_F") && (toLower("mpmissions\__cur_mp.altis\images\Van_01_adds_crank.jpg") in (getObjectTextures cursorObject)) && !isNull cursorObject && (player distance cursorObject) < 5 && !(cursorObject getVariable [ "plb_labMode",false ] )) && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["Break down the lab", {[cursorObject]
                    call life_fnc_crankLab},nil,0,false,false,"",'((typeOf cursorObject == "C_Van_01_box_F") && (toLower("mpmissions\__cur_mp.altis\images\Van_01_adds_crank.jpg") in (getObjectTextures cursorObject)) && !isNull cursorObject && (player distance cursorObject) < 5 && (cursorObject getVariable [ "plb_labMode",false ] )) && (isNull objectParent player)',6]);

            if((typeOf cursorObject isEqualTo"C_Van_01_box_F")&&(toLower("mpmissions\__cur_mp.altis\images\Van_01_adds_crank.jpg") in(getObjectTextures cursorObject))&&!isNull cursorObject&&(player distance cursorObject)<5&&cursorObject getVariable ["plb_labMode",false]) then {life_actions pushBack(_plb_obj addAction ["Mix Crank cocktail",life_fnc_processAction,"crank",0,false,false,"",' life_inv_ephedrau > 0 && life_inv_phos > 0 && life_inv_hydro > 0 && !life_is_processing && (isNull objectParent player)',6]);};

            if((typeOf cursorObject isEqualTo"C_Van_01_box_F")&&(toLower("mpmissions\__cur_mp.altis\images\Van_01_adds_crank.jpg") in(getObjectTextures cursorObject))&&!isNull cursorObject&&(player distance cursorObject)<5&&cursorObject getVariable ["plb_labMode",false]) then {life_actions pushBack(_plb_obj addAction ["Cook Crank",life_fnc_processAction,"crankp",0,false,false,"",' life_inv_crank > 0 && !life_is_processing && (isNull objectParent player)',6]);};

            if("C_Van_01_fuel_F"in(life_vehicles apply {typeOf _x})) then {life_actions pushBack(_plb_obj addAction ["<t color='#FF9999'>Get the distillery ready</t>", {[cursorObject]
                        call life_fnc_moonshineLab},nil,0,false,false,"",'((typeOf cursorObject == "C_Van_01_fuel_F") && (toLower("mpmissions\__cur_mp.altis\images\moonshineback.jpg") in (getObjectTextures cursorObject)) && !isNull cursorObject && (player distance cursorObject) < 5 && !(cursorObject getVariable [ "plb_labMode",false ] )) && (isNull objectParent player)',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#FF9999'>Break down the distillery</t>", {[cursorObject]
                        call life_fnc_moonshineLab},nil,0,false,false,"",'((typeOf cursorObject == "C_Van_01_fuel_F") && (toLower("mpmissions\__cur_mp.altis\images\moonshineback.jpg") in (getObjectTextures cursorObject)) && !isNull cursorObject && (player distance cursorObject) < 5 && (cursorObject getVariable [ "plb_labMode",false ] )) && (isNull objectParent player)',6]);

                if((typeOf cursorObject isEqualTo"C_Van_01_fuel_F")&&(toLower("mpmissions\__cur_mp.altis\images\moonshineback.jpg") in(getObjectTextures cursorObject))&&!isNull cursorObject&&(player distance cursorObject)<5&&cursorObject getVariable ["plb_labMode",false]) then {life_actions pushBack(_plb_obj addAction ["<t color='#FF9999'>Make Supplies into Corn Hash</t>",life_fnc_processAction,"moonshinehash",0,false,false,"",' life_inv_corn > 0 && life_inv_yeast > 0 && life_inv_water > 0 && !life_is_processing && (isNull objectParent player)',6]);};

                if((typeOf cursorObject isEqualTo"C_Van_01_fuel_F")&&(toLower("mpmissions\__cur_mp.altis\images\moonshineback.jpg") in(getObjectTextures cursorObject))&&!isNull cursorObject&&(player distance cursorObject)<5&&cursorObject getVariable ["plb_labMode",false]) then {life_actions pushBack(_plb_obj addAction ["<t color='#FF9999'>Distill Hash into Homebrew Moonshine</t>",life_fnc_processAction,"moonshine",0,false,false,"",' life_inv_moonshinehash > 0 && !life_is_processing && (isNull objectParent player)',6]);};};

            if!(isNull life_holding_barrel) then {life_actions pushBack(_plb_obj addAction ["Drop Barrel",life_fnc_dropOil,cursorTarget,-1,false,true,"",' !isNull life_holding_barrel && speed player < 2 ',6]);

                life_actions pushBack(_plb_obj addAction ["Place Barrel in Boat",life_fnc_placeOil,cursorTarget,-1,false,true,"",'!isNull cursorTarget && !isNull life_holding_barrel && (typeOf cursorTarget) in IL_Supported_Vehicles_BOAT && cursorTarget distance player < 5 && speed cursorTarget < 4',6]);};

            if(vest player=="V_HarnessOGL_brn") then {life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Activate Suicide Vest</t>", {["self"]
                        call life_fnc_suicideVest},"",0,false,false,"",'vest player == "V_HarnessOGL_brn" && alive player && playerSide isEqualTo civilian && !life_istazed && !(player getVariable [ "plb_restrained",false ] ) && !(player getVariable [ "plb_escorting",false ] ) && !(player getVariable [ "plb_transporting",false ] )',6]);};

            life_actions pushBack(_plb_obj addAction ["<t color='#00FF00'>House Menu</t>", {[cursorObject]
                    call life_fnc_houseMenu},nil,-1,false,false,"",'(cursorObject getVariable [ "plb_restricted_house", false ] != true) && (cursorObject isKindOf "House_F") && { !(isNull cursorObject) } && { (player distance cursorObject) < 10 } && { count ( [ typeOf cursorObject ] call life_fnc_houseConfig) > 0 } && { (( [ typeOf cursorObject ] call life_fnc_houseConfig) select 0) > -1 }',6]);

            // SHED HELIPAD deck reach: up on the pad cursorObject is deck concrete, never the shed,
            // so resolve the upgraded shed directly BELOW the player instead. Vertical extension only --
            // horizontal stays the same 10m as the ground action (distance2D), and the cursorObject
            // guard stops a duplicate entry when the shed itself is aimable through the rails.
            life_actions pushBack(_plb_obj addAction ["<t color='#00FF00'>House Menu</t>", {private _shed = ((nearestObjects [player, ["Land_i_Shed_Ind_F"], 12]) select {!isObjectHidden _x && {_x getVariable ["plb_helipad", false]}}) param [0, objNull];
                    if (!isNull _shed) then {[_shed] call life_fnc_houseMenu;};},nil,-1,false,false,"",'isNull objectParent player && {((getPosATL player) select 2) > 2.5} && {(typeOf cursorObject) isNotEqualTo "Land_i_Shed_Ind_F"} && { private _s = ((nearestObjects [player, ["Land_i_Shed_Ind_F"], 12]) select { !isObjectHidden _x && {_x getVariable ["plb_helipad", false]} && {!(_x getVariable ["plb_restricted_house", false])} } ) param [0, objNull]; !isNull _s && { (player distance2D _s) < 10 } }',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#33CC33'>Plant Sativa Seeds</t>", {["plant", [cursorObject,"s"]]
                    spawn life_fnc_greenhouse},nil,1.5,false,false,"",'((cursorObject getVariable [ "plb_homeOwner","" ] isEqualTo (getPlayerUID player)) || { ((cursorObject getVariable [ "plb_house_keys", [ ] ] ) findIf { (_x param [ 0,"" ] ) isEqualTo (getPlayerUID player) } ) != -1 } ) && (cursorObject getVariable [ "plb_greenhouse_unaged",false ] ) && !isNull cursorObject && (player distance cursorObject < 12) && (life_inv_cannas_0 > 0)',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#33CC33'>Plant Indica Seeds</t>", {["plant", [cursorObject,"i"]]
                    spawn life_fnc_greenhouse},nil,1.5,false,false,"",'((cursorObject getVariable [ "plb_homeOwner","" ] isEqualTo (getPlayerUID player)) || { ((cursorObject getVariable [ "plb_house_keys", [ ] ] ) findIf { (_x param [ 0,"" ] ) isEqualTo (getPlayerUID player) } ) != -1 } ) && (cursorObject getVariable [ "plb_greenhouse_unaged",false ] ) && !isNull cursorObject && (player distance cursorObject < 12) && (life_inv_cannai_0 > 0)',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#CB1EEC'>Harvest Greenhouse</t>", {["harvest", [cursorObject]]
                    spawn life_fnc_greenhouse},nil,1.5,false,false,"",'((cursorObject getVariable [ "plb_homeOwner","" ] isEqualTo (getPlayerUID player)) || { ((cursorObject getVariable [ "plb_house_keys", [ ] ] ) findIf { (_x param [ 0,"" ] ) isEqualTo (getPlayerUID player) } ) != -1 } ) && (cursorObject getVariable [ "plb_greenhouse_unaged",false ] ) && !isNull cursorObject && (player distance cursorObject < 12) && (cursorObject getVariable [ "plb_gh_crop", [ ] ] isNotEqualTo [ ] )',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#FFD700'>Check Greenhouse</t>", {["status", [cursorObject]]
                    spawn life_fnc_greenhouse},nil,1.5,false,false,"",'((cursorObject getVariable [ "plb_homeOwner","" ] isEqualTo (getPlayerUID player)) || { ((cursorObject getVariable [ "plb_house_keys", [ ] ] ) findIf { (_x param [ 0,"" ] ) isEqualTo (getPlayerUID player) } ) != -1 } ) && (cursorObject getVariable [ "plb_greenhouse_unaged",false ] ) && !isNull cursorObject && (player distance cursorObject < 12)',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#D2A679'>Lay Down Spirits to Age</t>", {["laydown", [cursorObject]]
                    spawn life_fnc_barrel},nil,1.5,false,false,"",'((cursorObject getVariable [ "plb_homeOwner","" ] isEqualTo (getPlayerUID player)) || { ((cursorObject getVariable [ "plb_house_keys", [ ] ] ) findIf { (_x param [ 0,"" ] ) isEqualTo (getPlayerUID player) } ) != -1 } ) && (cursorObject getVariable [ "plb_barrel_unaged",false ] ) && !isNull cursorObject && (player distance cursorObject < 12) && (life_inv_scotch_0 + life_inv_whiskeyc_0 + life_inv_whiskeyr_0 + life_inv_rum_0 > 0)',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#CB1EEC'>Collect Aging Barrel</t>", {["collect", [cursorObject]]
                    spawn life_fnc_barrel},nil,1.5,false,false,"",'((cursorObject getVariable [ "plb_homeOwner","" ] isEqualTo (getPlayerUID player)) || { ((cursorObject getVariable [ "plb_house_keys", [ ] ] ) findIf { (_x param [ 0,"" ] ) isEqualTo (getPlayerUID player) } ) != -1 } ) && (cursorObject getVariable [ "plb_barrel_unaged",false ] ) && !isNull cursorObject && (player distance cursorObject < 12) && (cursorObject getVariable [ "plb_barrel_crop", [ ] ] isNotEqualTo [ ] )',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#FFD700'>Check Aging Barrel</t>", {["status", [cursorObject]]
                    spawn life_fnc_barrel},nil,1.5,false,false,"",'((cursorObject getVariable [ "plb_homeOwner","" ] isEqualTo (getPlayerUID player)) || { ((cursorObject getVariable [ "plb_house_keys", [ ] ] ) findIf { (_x param [ 0,"" ] ) isEqualTo (getPlayerUID player) } ) != -1 } ) && (cursorObject getVariable [ "plb_barrel_unaged",false ] ) && !isNull cursorObject && (player distance cursorObject < 12)',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#FFD700'>Set My APD Title</t>", {[]
                    spawn {["<t align='center'>Enter your custom APD rank title.</t>","APD Rank Title","Set"]
                        call life_fnc_inputMenu;

                        private _title=life_input_response;

                        life_input_response="";

                        if(_title isEqualTo "") exitWith {};

                        player setVariable ["plb_ownerCopTitle",_title,true];

                        profileNamespace setVariable ["plb_ownerCopTitle",_title];

                        saveProfileNamespace;
 [format ["APD rank title set to: %1",_title],"basic"]
                        spawn life_fnc_handleMessage;}},"",1.5,false,false,"",'playerSide isEqualTo west && (getPlayerUID player) isEqualTo "76561190000000001"',6]);

            if!(life_houses isEqualTo []) then {life_actions pushBack(_plb_obj addAction ["<t color='#FFD700'>Show Furniture</t>", {[["show",cursorObject getVariable ["plb_houseID",-1],player],"TON_fnc_houseFurnitureSRV",2]
                        spawn life_fnc_MP},nil,-1,false,false,"",'!isNull cursorObject && (player distance cursorObject) < 15 && cursorObject isKindOf "House_F" && ((cursorObject getVariable [ "plb_homeOwner","" ] ) isEqualTo getPlayerUID player) && (isNull objectParent player)',6]);

                // owner 2026-07-11 (MENTOR PROGRAM, Act 3 onboarding): veterans adopt a [NEW BLOOD] --
                // the state pays $1,000,000 when the mentee finishes parole. UNCONDITIONAL registration
                // (self-gates via the condition string) -- the first placement sat inside the shank's
                // life_inv_shank>0 wrapper, so only shank-carrying vets ever saw it.
                life_actions pushBack(_plb_obj addAction ["<t color='#00FF00'>Offer to Mentor (New Blood)</t>", {["offer"] call life_fnc_mentor},3,-1,false,false,"",' !isNull cursorTarget && cursorTarget isKindOf "CAManBase" && isPlayer cursorTarget && alive cursorTarget && (cursorTarget getVariable ["plb_newBlood", false]) && ((cursorTarget getVariable ["plb_mentorUid", ""]) isEqualTo "") && !(player getVariable ["plb_newBlood", false]) && playerSide isEqualTo civilian && isNull objectParent player && player distance cursorTarget < 3 ',3]);

                // owner 2026-07-12: autopilot scroll actions REMOVED -- activation lives in the
                // TAB radial (driving-mode wedges), gated on the $300 garage module.

                life_actions pushBack(_plb_obj addAction ["<t color='#FFD700'>Pack Away Furniture</t>", {[["hide",cursorObject getVariable ["plb_houseID",-1],player],"TON_fnc_houseFurnitureSRV",2]
                        spawn life_fnc_MP},nil,-1,false,false,"",'!isNull cursorObject && (player distance cursorObject) < 15 && cursorObject isKindOf "House_F" && ((cursorObject getVariable [ "plb_homeOwner","" ] ) isEqualTo getPlayerUID player) && (isNull objectParent player)',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Toggle All House Locks</t>", {[cursorObject]
                        call life_fnc_lockHouse},nil,-1,false,false,"",'!isNull cursorObject && (player distance cursorObject) < 20 && cursorObject isKindOf "House" && (cursorObject in life_vehicles) && (isNull objectParent player)',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#FF7400'>Request NG House Repair</t>", {["requestRepair"]
                        spawn life_fnc_civRepairBuilding},nil,1.5,true,true,"""",'private _building = if (life_houses isNotEqualTo []) then {(nearestTerrainObjects [ player, [ "House" ] , 7, true, true ] ) param [ 0, objNull ] } else {objNull}; private _building = if (_building getVariable [ "plb_terrainObject_repaired", false ] ) then { (nearestObjects [ player, [ "House" ] , 7, true ] ) param [ 0, objNull ] } else { _building } ; ((_building isKindOf "House_F") && !(_building getVariable [ "plb_repairRequested", false ] ) && ((_building getVariable [ "plb_homeOwner", "" ] ) isEqualTo (getPlayerUID player)) && (damage _building >= 1))',6]);

                (_plb_obj addAction ["<t color='#33CC33'>Repair House (Kit)</t>", {["kitRepair"]
                        spawn life_fnc_civRepairBuilding},nil,1.5,true,true,"""",'private _building = if ((playerSide isEqualTo civilian) && (life_inv_houserepairkit > 0)) then { (nearestTerrainObjects [ player, [ "House" ] , 7, true, true ] ) param [ 0, objNull ] } else { objNull } ; private _building = if (_building getVariable [ "plb_terrainObject_repaired", false ] ) then { (nearestObjects [ player, [ "House" ] , 7, true ] ) param [ 0, objNull ] } else { _building } ; ((playerSide isEqualTo civilian) && (life_inv_houserepairkit > 0) && (_building isKindOf "House_F") && ((_building getVariable [ "plb_homeOwner", "" ] ) isEqualTo (getPlayerUID player)) && (damage _building isEqualTo 1))',6]);};

            if(cursorObject in life_gangBuilding||([cursorObject,getPlayerUID player,"accessInv"]
            call life_fnc_keyHolderStatus)||!(life_houses isEqualTo [])) then {if((cursorObject getVariable ["plb_house_tax", [false]]) select 0) exitWith {};

                life_actions pushBack(_plb_obj addAction ["Vehicle Garage", {["Car",cursorObject]
                        call life_fnc_handleVehicles},nil,0,false,true,"",'!isNull cursorObject && (player distance cursorObject) < 20 && cursorObject isKindOf "House" && (typeOf cursorObject in [ "Land_i_Garage_V1_F","Land_i_Garage_V2_F","Land_i_Garage_V1_dam_F","Land_i_Garage_V2_dam_F","Land_i_Shed_Ind_F","Land_House_Big_02_F","Land_House_Big_03_F" ] ) && (cursorObject in life_vehicles || cursorObject in life_gangBuilding || ( [ cursorObject, getPlayerUID player, "accessLock" ] call life_fnc_keyHolderStatus)) && (isNull objectParent player)',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#37e8f0'>Helipad Garage</t>", {["Air",cursorObject]
                        call life_fnc_handleVehicles},nil,0,false,true,"",'!isNull cursorObject && (player distance cursorObject) < 25 && (typeOf cursorObject isEqualTo "Land_i_Shed_Ind_F") && (cursorObject getVariable ["plb_helipad", false]) && (cursorObject in life_vehicles || cursorObject in life_gangBuilding || ( [ cursorObject, getPlayerUID player, "accessLock" ] call life_fnc_keyHolderStatus)) && (isNull objectParent player)',6]);

                life_actions pushBack(_plb_obj addAction ["Gang Garage", {["Car",cursorObject,true]
                        call life_fnc_handleVehicles},nil,0,false,true,"",'!isNull cursorObject && (player distance cursorObject) < 20 && cursorObject isKindOf "House" && (typeOf cursorObject in [ "Land_i_Garage_V1_F","Land_i_Garage_V2_F","Land_i_Garage_V1_dam_F","Land_i_Garage_V2_dam_F","Land_i_Shed_Ind_F","Land_House_Big_02_F","Land_House_Big_03_F" ] ) && (cursorObject in life_vehicles || cursorObject in life_gangBuilding || ( [ cursorObject, getPlayerUID player, "accessLock" ] call life_fnc_keyHolderStatus)) && (isNull objectParent player) && ((life_gang_data param [ 0, -1 ] ) isNotEqualTo -1) && ((life_gang_data param [ 2, 5 ] ) <= 3)',6]);

                life_actions pushBack(_plb_obj addAction ["Store Vehicle in Garage",life_fnc_storeVehicle,"""",0,false,true,"""",'!life_garage_store && !isNull cursorObject && (player distance cursorObject) < 20 && cursorObject isKindOf "House" && (typeOf cursorObject in [ "Land_i_Garage_V1_F","Land_i_Garage_V2_F","Land_i_Garage_V1_dam_F","Land_i_Garage_V2_dam_F","Land_i_Shed_Ind_F","Land_House_Big_02_F","Land_House_Big_03_F" ] ) && (cursorObject in life_vehicles || cursorObject in life_gangBuilding || ( [ cursorObject, getPlayerUID player, "accessLock" ] call life_fnc_keyHolderStatus)) && (isNull objectParent player)',6]);};

            if(player distance getMarkerPos"fed_reserve"<=400) then {life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Break Into Dome (Side Door)</t>",life_fnc_openVault,"",0,false,false,"",'((call PLB_fnc_hasDeck)) && ((typeOf cursorObject) in [ "Land_Dome_Big_F","Land_Dome_Small_F" ] ) && (( { (player distance (cursorObject modelToWorld (cursorObject selectionPosition _x))) <= 3 } count (selectionNames cursorObject)) >= 1) && ((cursorObject getVariable [ "plb_vaultlocked", 1 ] ) isEqualTo 1) && (!life_action_in_use) && (isNull objectParent player)',6]);

                life_actions pushBack(_plb_obj addAction ["Crack Safe",life_fnc_openSafe,false,0,false,false,"",'(( { (player distance (cursorObject modelToWorld (cursorObject selectionPosition _x))) <= 2.75 } count ((selectionNames cursorObject) select { (_x find "door") >= 0 } )) >= 1) && ((cursorObject getVariable [ "plb_vaultlocked", 1 ] ) isEqualTo 1) && ((typeOf cursorObject) in [ "Land_Research_house_V1_F","Land_Research_HQ_F" ] ) && ((call PLB_fnc_hasDeck)) && (!life_action_in_use) && (isNull objectParent player)',6]);

                life_actions pushBack(_plb_obj addAction ["Plant Demo Charge",life_fnc_openSafe,true,0,false,false,"",'(( { (player distance (cursorObject modelToWorld (cursorObject selectionPosition _x))) <= 2.75 } count ((selectionNames cursorObject) select { (_x find "door") >= 0 } )) >= 1) && ((cursorObject getVariable [ "plb_vaultlocked", 1 ] ) isEqualTo 1) && ((typeOf cursorObject) in [ "Land_Research_house_V1_F","Land_Research_HQ_F" ] ) && (life_inv_demoCharge >= 1) && (43 in life_side_talents) && (!life_action_in_use) && (isNull objectParent player)',6]);

                life_actions pushBack(_plb_obj addAction ["Bolt Cut Gate",life_fnc_openGate,"",0,false,false,"",'((typeOf cursorObject) isEqualTo "Land_BarGate_F") && !((cursorObject getVariable [ "gate_max", 0 ] ) isEqualTo 1) && ((player distance cursorObject) <= 5) && (life_inv_boltCutter >= 1) && (!life_action_in_use) && (isNull objectParent player)',6]);};

            if(player distance [20898.6,19221.7,0.00143909]
            <=400) then {life_actions pushBack(_plb_obj addAction ["Plant Demo Charge",life_fnc_evidenceSystems,2,5,false,false,"",'(( { (player distance (cursorObject modelToWorld (cursorObject selectionPosition _x))) <= 2.75 } count ((selectionNames cursorObject) select { (_x find "door") >= 0 } )) >= 1) && (!(SRV_evidence_status select 1) && (SRV_evidence_status select 0)) && typeOf cursorObject isEqualTo "Land_Dome_Big_F" && (life_inv_demoCharge >= 1) && !(life_action_in_use) && (isNull objectParent player)',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Breach Evidence Vault</t>",life_fnc_evidenceVaultOpen,nil,5,false,false,"",'(playerSide isEqualTo civilian) && (typeOf cursorObject isEqualTo "Land_Dome_Big_F") && (cursorObject getVariable [ "plb_evidenceOpen",false ] ) && !(cursorObject getVariable [ "plb_vaultBreached",false ] ) && (life_inv_demoCharge >= 1) && !life_action_in_use && (isNull objectParent player) && ((player distance cursorObject) < 12)',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#00BFFF'>Hack Defense Systems</t>",life_fnc_evidenceSystems,0,5,false,false,"",'(playerSide isEqualTo civilian) && !isNull cursorObject && (cursorObject isEqualTo (missionNamespace getVariable [ "evidenceLaptop", objNull ] )) && ((cursorObject getVariable [ "plb_laptopstatus",1 ] ) in [ 1,3 ] ) && ((player distance cursorObject) < 3) && !life_action_in_use && (isNull objectParent player)',6]);};

            if((life_adminEvent select 2 isEqualTo 4)&&(life_inEvent)) then {life_actions pushBack(_plb_obj addAction ["<t color='#1EC57E'>Unearth Remains</t>", {["digGrave",cursorObject]
                        spawn life_fnc_eventGraveyardClient},nil,0,false,false,"",'((typeOf cursorObject isEqualTo "Land_ShellCrater_01_F") && !isNull cursorObject && (player distance cursorObject) < 5 && (player inArea "graveyardshift1") && (isNull objectParent player))',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#CB1EEC'>Gather Skeletal Remains</t>", {["gatherBones",cursorObject]
                        spawn life_fnc_eventGraveyardClient},nil,0,false,false,"",'((typeOf cursorObject in [ "Land_HumanSkeleton_F" ] ) && !isNull cursorObject && (player distance cursorObject) < 5 && (player inArea "graveyardshift1") && (isNull objectParent player))',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Burn Skeletal Remains</t>", {["burnBones",cursorObject]
                        spawn life_fnc_eventGraveyardClient},nil,0,false,false,"",'((typeOf cursorObject isEqualTo "Land_Campfire_F") && !isNull cursorObject && inflamed cursorObject && (player distance cursorObject) < 5 && (player inArea "graveyardshift1") && (isNull objectParent player))',6]);};

            if(player distance getMarkerPos"life_mentalHospital"<=400) then {life_actions pushBack(_plb_obj addAction ["<t color='#1EC57E'>Breach Loony Bin Gate</t>", {["breachGateBomb", [cursorObject]]
                        spawn life_fnc_loonyBin},nil,0,false,false,"",'(playerSide isEqualTo civilian) && (cursorObject in [ life_mentalTrolleyBack, life_mentalTrolleyFront ] ) && !isNull cursorObject && (player distance cursorObject) < 5',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#CB1EEC'>Lay Thermite On Front Door</t>", {["startThermiteFrontDoor", [cursorObject]]
                        spawn life_fnc_loonyBin},nil,0,false,false,"",'(playerSide isEqualTo civilian) && (cursorObject isEqualTo life_mentalLaptopFrontDoor) && !isNull cursorObject && (player distance cursorObject) < 5',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Hack Loony Bin Laptop</t>", {["uploadLaptopVirusHack", [cursorObject]]
                        spawn life_fnc_loonyBin},nil,0,false,false,"",'(playerSide isEqualTo civilian) && (cursorObject in [ life_mentalLaptop1, life_mentalLaptop2, life_mentalLaptop3, life_mentalLaptop4, life_mentalLaptop5 ] ) && !isNull cursorObject && (player distance cursorObject) < 5',6]);};

            if(player distance getMarkerPos"life_mentalHospitalPatient"<=150) then {life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Enter Keycode for Tomb</t>", {["mental_input"]
                        call life_fnc_createDialog},nil,0,false,false,"",'(playerSide isEqualTo civilian) && !isNull (nearestObject [ getMarkerPos "life_mentalHospitalPatient", "Land_Tablet_01_F" ] ) && (player distance2D (getMarkerPos "life_mentalHospitalPatient") < 7)',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Loot Patient Remains</t>", {["lootPatientsRemains", [cursorObject]]
                        spawn life_fnc_loonyBin},nil,0,false,false,"",'(playerSide isEqualTo civilian) && (cursorObject isEqualTo (SRV_loonyBinData param [ 5, objNull ] )) && !isNull cursorObject && (player distance cursorObject) < 5',6]);};

            if((getPosATL player) inPolygon life_jewelryEmporiumPoly) then {if!(isNull((nearestObjects [player, ["Coffin_02_F"],3]) param [0,objNull])) then {life_actions pushBack(_plb_obj addAction ["<t color='#1EC57E'>Break Jewel Case</t>", {["breakGlassCase", [((nearestObjects [player, ["Coffin_02_F"],3]) param [0,objNull])]]
                            spawn life_fnc_jewelryEmporium},nil,0,false,false,"",'(playerSide isEqualTo civilian) && !life_action_in_use && {private _jewelCase = ((nearestObjects [ player, [ "Coffin_02_F" ] , 3 ] ) param [ 0, objNull ] ) ; (_jewelCase in [ life_jewerlyCase1, life_jewerlyCase2, life_jewerlyCase3, life_jewerlyCase4, life_jewerlyCase5, life_jewerlyCase6, life_jewerlyCase7, life_jewerlyCase8, life_jewerlyCase9, life_jewerlyCase10, life_jewerlyCase11, life_jewerlyCase12, life_jewerlyCase13, life_jewerlyCase14 ] ) && !isNull _jewelCase && (player distance _jewelCase) < 5 && !(isObjectHidden _jewelCase) && !(_jewelCase getVariable [ "plb_jewelCaseLooted", false ] )}',6]);};

                if(player distance2D [20708.1,16628.4,0]
                <=3) then {life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Start Drilling Door</t>", {["startDrill", [cursorObject]]
                            spawn life_fnc_jewelryEmporium},nil,0,false,false,"",'!(SRV_jewelryEmporiumSRV param [ 1, false ] ) && (playerSide isEqualTo civilian) && (cursorObject isEqualTo life_jewerlyEmporium) && !isNull cursorObject && (player distance cursorObject) < 15',6]);};

                life_actions pushBack(_plb_obj addAction ["<t color='#CB1EEC'>Take Jewelry Piece</t>", {["takeJewelryContents", [cursorObject]]
                        spawn life_fnc_jewelryEmporium},nil,0,false,false,"",'(playerSide isEqualTo civilian) && (typeOf cursorObject isEqualTo "Land_Trophy_01_gold_F") && !isNull cursorObject && (player distance cursorObject) < 8',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#CB1EEC'>Load Container</t>", {["loadOutsideContainer", [cursorObject]]
                        spawn life_fnc_jewelryEmporium},nil,0,false,false,"",'(playerSide isEqualTo civilian) && (cursorObject isEqualTo life_jewerlyContainer) && !isNull cursorObject && (player distance cursorObject) < 8',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#CB1EEC'>Take Safe Loot</t>", {["takeSafeContents", [cursorObject]]
                        spawn life_fnc_jewelryEmporium},nil,0,false,false,"",'(playerSide isEqualTo civilian) && (typeOf cursorObject isEqualTo "Fridge_01_open_F") && !(cursorObject getVariable [ "plb_safeLooted", false ] ) && !isNull cursorObject && (player distance cursorObject) < 5',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#CB1EEC'>Laser Cut Safe</t>", {["weldSafe", [cursorObject]]
                        spawn life_fnc_jewelryEmporium},nil,0,false,false,"",'(playerSide isEqualTo civilian) && (cursorObject isEqualTo life_jewerlySafe) && !isNull cursorObject && (player distance cursorObject) < 5 && !(SRV_jewelryEmporiumSRV param [ 3, false ] )',6]);};

            if({player distance getMarkerPos format ["life_exchangeMarker%1",_x]
                <55}
            count [1,2,3,4,5]
            >0) then {life_actions pushBack(_plb_obj addAction ["<t color='#4DF53E'>LoonyBin Exchange - List Vehicle</t>",life_fnc_exchangeCreateListing,"vehicleItem",0,false,false,"",'!isNull cursorObject && (alive cursorObject) && !(isPlayer cursorObject) && (cursorObject in life_vehicles) && (player distance cursorObject < 5) && ((cursorObject isKindOf "Car") || (cursorObject isKindOf "Air") || (cursorObject isKindOf "Ship"))',6]);};

            life_actions pushBack(_plb_obj addAction ["Hack Bank Vault", {if ((missionNamespace getVariable ["life_lastBankDrillClick", -999]) > serverTime - 15) exitWith {["Drill already starting, give it a moment.","basic"]
                        spawn life_fnc_handleMessage;};

                    life_lastBankDrillClick = serverTime;

                    if([]
                    call life_fnc_activeFederalEvent) exitWith {["There is already another Federal Event happening.","basic"]
                        spawn life_fnc_handleMessage;};

                    if!([4,true]
                    call life_fnc_policeRequired) exitWith {};

                    if(SRV_lastRobbery>(serverTime-(60*15))) exitWith {[2,format ["Security is high due to a recent robbery and you cannot rob the bank. Try again in %1 minute(s).",ceil((SRV_lastRobbery-(serverTime-(60*15)))/60)]]
                        call life_fnc_broadcast};

                    // LooneyBin 2026-07-18: Cyberdeck -- Terminal Breach (6 cmds) gates the bank job (was a drill)
                    private _bankRoot = [2] call life_fnc_cyberdeckTerm;
                    if !(_bankRoot isEqualTo 1) exitWith {}; [[player,cursorObject],"TON_fnc_bankRobbery",2]
                    spawn life_fnc_MP;
 ["bankdrill",1]
                    call life_fnc_statArrUpdate;},nil,4,true,true,"",'(player distance (getMarkerPos "life_bank_door") < 4) && (call PLB_fnc_hasDeck) && !(life_bank_robbed select 0) && (life_bank_robbed select 1) < serverTime - 1200 && (isNull objectParent player)',6]);

            if(license_civ_bounty) then {if({player distance getMarkerPos format ["bounty_%1",_x]
                    <(life_track_radius+100)}
                count [0,1,2,3]
                >0) then {life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Track Fugitive 1</t>", {[0]
                            call life_fnc_trackBounty},nil,0,false,true,"",' player distance (getMarkerPos "bounty_0") < life_track_radius ',6]);

                    life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Track Fugitive 2</t>", {[1]
                            call life_fnc_trackBounty},nil,0,false,true,"",' player distance (getMarkerPos "bounty_1") < life_track_radius ',6]);

                    life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Track Fugitive 3</t>", {[2]
                            call life_fnc_trackBounty},nil,0,false,true,"",' player distance (getMarkerPos "bounty_2") < life_track_radius ',6]);

                    life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Track Fugitive 4</t>", {[3]
                            call life_fnc_trackBounty},nil,0,false,true,"",' player distance (getMarkerPos "bounty_3") < life_track_radius ',6]);};

                if((471 in life_completedLifetimeQuests)&&(currentWeapon player in ["hgun_P07_F","hgun_P07_khk_F","hgun_P07_blk_F"])) then {private _toggleP07= {private _lethalState=player getVariable ["plb_lethalBH",false];

                        player setVariable ["plb_lethalBH",!(_lethalState),true];

                        private _text=if!(_lethalState) then {"lethal rounds"}
                        else {"downing rounds"};
 [format ["You switched to %1.",_text],"basic"]
                        spawn life_fnc_handleMessage;};

                    life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Load Lethal Rounds for P07</t>",_toggleP07,nil,1.5,false,false,"",'!(player getVariable [ "plb_lethalBH",false ] ) && (currentWeapon player in [ "hgun_P07_F", "hgun_P07_khk_F", "hgun_P07_blk_F" ] )',6]);

                    life_actions pushBack(_plb_obj addAction ["<t color='#00FF00'>Load Non-Lethal Rounds for P07</t>",_toggleP07,nil,1.5,false,false,"",'(player getVariable [ "plb_lethalBH",false ] ) && (currentWeapon player in [ "hgun_P07_F", "hgun_P07_khk_F", "hgun_P07_blk_F" ] )',6]);};

                life_actions pushBack(_plb_obj addAction ["Send to Jail", {[cursorObject]
                        call life_fnc_arrestAction},nil,0,false,false,"",'!isNull cursorObject && isPlayer cursorObject && license_civ_bounty && (side cursorObject isEqualTo civilian) && (cursorObject getVariable [ "plb_restrained",false ] ) && (cursorObject getVariable [ "plb_civRestrained",false ] ) && alive cursorObject && (player distance cursorObject < 3.5) && (( { player distance (getMarkerPos _x) < 19 } count [ "jail_release2" ] > 0) || { player distance getMarkerPos _x < 15 } count [ "marker_609","marker_606","marker_607","marker_608","marker_611","marker_610", "marker_612" ] > 0) && !(cursorObject getVariable [ "plb_escorting",false ] )',6]);

                life_actions pushBack(_plb_obj addAction ["Send Combat Logger to Jail", {[cursorObject]
                        spawn life_fnc_jailCL},"",0,false,false,"",'!isNull cursorObject && !(isPlayer cursorObject) && license_civ_bounty && (player distance cursorObject < 3.5) && ((typeOf cursorObject) isEqualTo "Land_Bodybag_01_black_F")',3]);

                life_actions pushBack(_plb_obj addAction ["Bounty Hunter Enter as Driver", {["driver"]
                        call life_fnc_forceVehicleEnter},nil,200,false,false,"",'(cursorObject in life_vehicles) && { !isNull cursorObject && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship") && (locked cursorObject) != 0 && cursorObject distance player < 5 }',4.5]);

                life_actions pushBack(_plb_obj addAction ["Bounty Hunter Enter as Passenger", {["passenger"]
                        call life_fnc_forceVehicleEnter},nil,100,false,false,"",'(cursorObject in life_vehicles) && { !isNull cursorObject && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship") && (locked cursorObject) != 0 && cursorObject distance player < 5 }',4.5]);

                if(player getVariable ["plb_activeBounty",false]
                ||!(life_bounty_list isEqualTo [])) then {life_actions pushBack(_plb_obj addAction ["<t color='#FF00FF'>Hide Badge</t>", {player setVariable ["plb_activeBounty",nil,true];},3,0,false,true,"",'player getVariable [ "plb_activeBounty", false ]',6]);

                    life_actions pushBack(_plb_obj addAction ["<t color='#FF00FF'>Show Badge</t>", {player setVariable ["plb_activeBounty",true,true];},3,0,false,true,"",'!(player getVariable [ "plb_activeBounty", false ] ) && !(life_bounty_list isEqualTo [ ] )',6]);};};

            life_actions pushBack(_plb_obj addAction ["Destroy Spike Strip",life_fnc_packupSpikes,"",0,false,false,"",'_spikes = nearestObjects [ player, [ "Land_Razorwire_F" ] ,8 ] select 0 ; !isNil "_spikes" && !isNil { (_spikes getVariable "plb_placed") }',6]);

            if(life_juryVoteEnabled) then {life_actions pushBack(_plb_obj addAction ["Vote <t color='#00FF00'>NOT GUILTY</t>", {["voteNotGuilty", [player]]
                        call life_fnc_trialSystem},false,6,false,true,"",' !(life_clientTrialData select 2)']);

                life_actions pushBack(_plb_obj addAction ["Vote <t color='#FF0000'>GUILTY</t>", {["voteGuilty", [player]]
                        call life_fnc_trialSystem},false,6,false,true,"",'!(life_clientTrialData select 2)']);};

            life_actions pushBack(_plb_obj addAction ["Enter DLC vehicle as Driver", {["dlcDriver"]
                    call life_fnc_forceVehicleEnter},nil,200,false,false,"",'(locked cursorObject) isEqualTo 0 && { !isNull cursorObject && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship") && cursorObject distance player < 5 && !(getAssetDLCInfo [ typeOf cursorObject ] select 1) }',4.5]);};

        case west: {life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Use Defibrillator</t>",life_fnc_revivePlayer,cursorObject,-1,false,false,"",'!isNull cursorObject && cursorObject isKindOf "CAManBase" && !(alive cursorObject) && cursorObject getVariable [ "plb_revivable",false ] && life_inv_defib > 0 && (98 in life_side_talents) && (player distance cursorObject) < 3.5 && (isNull objectParent player) && (isNull objectParent cursorObject)',5]);

            life_actions pushBack(_plb_obj addAction ["Restrain", {[cursorObject]
                    call life_fnc_restrain},nil,-1,false,false,"",'if (isPlayer cursorObject) then { ((side cursorObject != west) && alive cursorObject && cursorObject isKindOf "CAManBase" && cursorObject distance player < 5 && !(cursorObject getVariable [ "plb_restrained",false ] ) && speed cursorObject < 1) && (isNull objectParent player) && (isNull objectParent cursorObject) } ;',6]);

            life_actions pushBack(_plb_obj addAction ["Escort", {[cursorObject]
                    call life_fnc_escortAction},"",0,false,false,"",'!isNull cursorObject && cursorObject isKindOf "CAManBase" && (isPlayer cursorObject) && alive cursorObject && cursorObject distance player < 3.5 && (cursorObject getVariable [ "plb_restrained",false ] ) && attachedTo cursorObject != player && (isNull objectParent player) && (isNull objectParent cursorObject)',6]);

            life_actions pushBack(_plb_obj addAction ["Stop Escorting",life_fnc_stopEscorting,"",0,false,false,"",' !isNull life_escort',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Disarm</t>", {[cursorObject]
                    call life_fnc_disarmAction},nil,-1,false,false,"",'!isNull cursorObject && !(alive cursorObject) && !(cursorObject getVariable [ "plb_disarmed", false ] ) && cursorObject isKindOf "CAManBase" && player distance cursorObject < 2 && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#FF8000'>Remove Firing Pin</t>", {[cursorObject]
                    call life_fnc_removeFiringPin},nil,1.5,false,false,"",'(playerSide isEqualTo west) && !isNull cursorObject && (isPlayer cursorObject) && (side cursorObject isEqualTo civilian) && (cursorObject getVariable [ "plb_restrained",false ] ) && !(cursorObject getVariable [ "plb_civRestrained",false ] ) && !(cursorObject getVariable [ "plb_gunBroken",false ] ) && (player distance cursorObject < 4) && (isNull objectParent player)',6]);

            // owner 2026-06-28: the "Send Fugitive to Jail" claim action MOVED onto the bag itself (server-side,
            // fn_playerDisconnected -> global+JIP `addAction`). A small ground bag couldn't be cursorObject'd, and the
            // old gate required the BH to be actively tracking the fugitive -- too strict vs the server's any-cop/BH auth.

            life_actions pushBack(_plb_obj addAction ["Give Ticket",life_fnc_ticketAction,"",0,false,false,"",'if (!isNull cursorObject) then { if (isPlayer cursorObject) then { ((side cursorObject != west) && alive cursorObject && cursorObject distance player < 3.5 && !(cursorObject getVariable [ "plb_escorting",false ] ) && (cursorObject getVariable [ "plb_restrained",false ] )) && (isNull objectParent player) } ; } ;',6]);

            life_actions pushBack(_plb_obj addAction ["Cop Enter as Driver", {["driver"]
                    call life_fnc_forceVehicleEnter},nil,200,false,false,"",' !isNull cursorObject && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship") && (locked cursorObject) != 0 && cursorObject distance player < 5 && (isNull objectParent player)',7]);

            life_actions pushBack(_plb_obj addAction ["Cop Enter as Passenger", {["passenger"]
                    call life_fnc_forceVehicleEnter},nil,100,false,false,"",' !isNull cursorObject && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship") && (locked cursorObject) != 0 && cursorObject distance player < 5 && !(cursorObject isKindOf "B_Heli_Attack_01_F") && (isNull objectParent player)',7]);

            life_actions pushBack(_plb_obj addAction ["Cop Enter as Commander", {["commander"]
                    call life_fnc_forceVehicleEnter},nil,100,false,false,"",'!isNull cursorObject && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship") && (locked cursorObject) != 0 && cursorObject distance player < 5 && ((cursorObject isKindOf "B_Heli_Attack_01_F")||(cursorObject isKindOf "B_Heli_Transport_01_F")||(cursorObject isKindOf "B_MRAP_01_hmg_F") || cursorObject isKindOf "I_MRAP_03_F") && (isNull objectParent player)',7]);

            life_actions pushBack(_plb_obj addAction ["Cop Enter as Gunner", {["gunner"]
                    call life_fnc_forceVehicleEnter},nil,100,false,false,"",'!isNull cursorObject && ((cursorObject isKindOf "Car")||(cursorObject isKindOf "Air")||(cursorObject isKindOf "Ship")) && (locked cursorObject) != 0 && cursorObject distance player < 5 && (count (allTurrets [ cursorObject,true ] ) > 0) && !(cursorObject isKindOf "O_Heli_Light_02_unarmed_F") && (isNull objectParent player)',7]);

            life_actions pushBack(_plb_obj addAction ["Exit", {["exit"]
                    call life_fnc_forceVehicleEnter},nil,100,false,false,"",'(vehicle player != player) && (locked(vehicle player)==2)',8]);

            life_actions pushBack(_plb_obj addAction ["<t color='#FFF000'>Pull out of vehicle</t>", {[cursorObject]
                    call life_fnc_pulloutAction},nil,0,false,false,"",'!isNull cursorObject && (player distance cursorObject) < 4 && (count crew cursorObject) > 0 && (cursorObject isKindOF "Car" || cursorObject isKindOf "Ship" || cursorObject isKindOf "Air") && { alive _x } count crew cursorObject > 0 && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#FFF000'>Put in Vehicle</t>", {[cursorObject]
                    call life_fnc_putInVeh},nil,-1,false,false,"",'!isNull cursorObject && (player distance cursorObject) < 6 && speed cursorObject < 2 && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship") && !isNull (player getVariable [ "plb_escortObj",objNull ] ) && isPlayer (player getVariable [ "plb_escortObj",objNull ] ) && alive (player getVariable [ "plb_escortObj",objNull ] ) && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#FFFF00'>Emergency Lights (OFF)</t>", {vehicle player setVariable ["plb_lights",false,true];},nil,-1,false,false,"",'!(isNull objectParent player) && (objectParent player getVariable [ "plb_side","civ" ] == "cop") && objectParent player getVariable [ "plb_lights", false ] && (player isEqualTo (driver vehicle player)) && (!isNil { vehicle player getVariable "plb_lights" } )',6]);

            if("B_UavTerminal"in(assignedItems player)) then {life_actions pushBack(_plb_obj addAction ["<t color='#0000FF'>Connect to UAV</t>", {player connectTerminalToUAV cursorObject;
 [cursorObject,900]
                        call life_fnc_setVehicleIdle;},false,90,false,false,"",'!isNull cursorObject && alive cursorObject && (player distance cursorObject) < 6 && (typeOf cursorObject == "B_UAV_01_F") && (!isUAVConnected cursorObject) && (isNull objectParent player)',6]);

                life_actions pushBack(_plb_obj addAction ["Show UAV Feed", {showUAVFeed true},false,4,false,false,"",' !isNull (getConnectedUAV player) && !shownUAVFeed ',6]);

                life_actions pushBack(_plb_obj addAction ["Hide UAV Feed", {showUAVFeed false},false,4,false,false,"",' shownUAVFeed ',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#FF69B4'>Show Security Cameras</t>", {life_showCams=true},nil,1.5,false,false,"",'!life_showCams',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#FF69B4'>Hide Security Cameras</t>", {life_showCams=false},nil,1.5,false,false,"",'life_showCams',6]);

                if(life_showCams) then {life_actions pushBack(_plb_obj addAction ["<t color='#FF69B4'>Jewelry Desk</t>", {[0]
                            call life_fnc_trafficCams},nil,1.5,false,false,"",'life_showCams && isNil "life_trafficCam" && player distance2d [ 20714, 16625, 5 ] < 4500',6]);

                    life_actions pushBack(_plb_obj addAction ["<t color='#FF69B4'>Jewelry Front Gate</t>", {[1]
                            call life_fnc_trafficCams},nil,1.5,false,false,"",'life_showCams && isNil "life_trafficCam" && player distance2d [ 20714, 16625, 5 ] < 4500',6]);

                    life_actions pushBack(_plb_obj addAction ["<t color='#FF69B4'>Jewelry Back Gate</t>", {[2]
                            call life_fnc_trafficCams},nil,1.5,false,false,"",'life_showCams && isNil "life_trafficCam" && player distance2d [ 20714, 16625, 5 ] < 4500',6]);

                    life_actions pushBack(_plb_obj addAction ["<t color='#FF69B4'>Fed Reserve Gate (W)</t>", {[3]
                            call life_fnc_trafficCams},nil,1.5,false,false,"",'life_showCams && isNil "life_trafficCam" && player distance2d [ 16084, 17000, 5 ] < 3000',6]);

                    life_actions pushBack(_plb_obj addAction ["<t color='#FF69B4'>Fed Reserve Gate (E)</t>", {[4]
                            call life_fnc_trafficCams},nil,1.5,false,false,"",'life_showCams && isNil "life_trafficCam" && player distance2d [ 16084, 17000, 5 ] < 3000',6]);

                    life_actions pushBack(_plb_obj addAction ["<t color='#FF69B4'>Fed Reserve Gate (SE)</t>", {[5]
                            call life_fnc_trafficCams},nil,1.5,false,false,"",'life_showCams && isNil "life_trafficCam" && player distance2d [ 16084, 17000, 5 ] < 3000',6]);

                    life_actions pushBack(_plb_obj addAction ["<t color='#FF69B4'>Prison Laptop</t>", {[6]
                            call life_fnc_trafficCams},nil,1.5,false,false,"",'life_showCams && isNil "life_trafficCam" && player distance2d [ 16793, 13590, 5 ] < 2000',6]);

                    life_actions pushBack(_plb_obj addAction ["<t color='#FF69B4'>Bank Vault</t>", {[7]
                            call life_fnc_trafficCams},nil,1.5,false,false,"",'life_showCams && isNil "life_trafficCam" && player distance2d [ 14771, 10737, 5 ] < 4000',6]);

                    life_actions pushBack(_plb_obj addAction ["<t color='#FF69B4'>Bank Back Door</t>", {[8]
                            call life_fnc_trafficCams},nil,1.5,false,false,"",'life_showCams && isNil "life_trafficCam" && player distance2d [ 14771, 10737, 5 ] < 4000',6]);

                    life_actions pushBack(_plb_obj addAction ["<t color='#FF69B4'>Bank Front Door</t>", {[9]
                            call life_fnc_trafficCams},nil,1.5,false,false,"",'life_showCams && isNil "life_trafficCam" && player distance2d [ 14771, 10737, 5 ] < 4000',6]);

                    life_actions pushBack(_plb_obj addAction ["<t color='#FF69B4'>Athira Square</t>", {[10]
                            call life_fnc_trafficCams},nil,1.5,false,false,"",'life_showCams && isNil "life_trafficCam" && player distance2d [ 14038 , 18751, 5 ] < 1500',6]);

                    life_actions pushBack(_plb_obj addAction ["<t color='#FF69B4'>Kavala Square</t>", {[11]
                            call life_fnc_trafficCams},nil,1.5,false,false,"",'life_showCams && isNil "life_trafficCam" && player distance2d [ 3646, 13114, 5 ] < 2000',6]);

                    life_actions pushBack(_plb_obj addAction ["<t color='#FF69B4'>Sofia Square</t>", {[12]
                            call life_fnc_trafficCams},nil,1.5,false,false,"",'life_showCams && isNil "life_trafficCam" && player distance2d [ 25707, 21382, 5 ] < 3500',6]);

                    life_actions pushBack(_plb_obj addAction ["<t color='#FF69B4'>Pyrgos Square</t>", {[13]
                            call life_fnc_trafficCams},nil,1.5,false,false,"",'life_showCams && isNil "life_trafficCam" && player distance2d [ 16745, 12507, 5 ] < 1500',6]);};};

            life_actions pushBack(_plb_obj addAction ["Send to Jail", {[cursorObject]
                    call life_fnc_arrestAction},nil,0,false,false,"",'!isNull cursorObject && isPlayer cursorObject && !(side cursorObject isEqualTo west) && (cursorObject getVariable [ "plb_restrained",false ] ) && alive cursorObject && (player distance cursorObject < 3.5) && (( { (position player) inPolygon (life_police_hq_polys select _x) } count [ 0,1,2,3,4,5,6 ] > 0) || ((player distance getMarkerPos "jail_release2") < 30) || (((SRV_mobileHQ param [ 1, objNull ] ) != objNull) && ((SRV_mobileHQ param [ 1, objNull ] ) getVariable [ "plb_mobileHeadQuartersTruckLocked", false ] ) && (((SRV_mobileHQ param [ 1, objNull ] ) distance2D player) < 20))) && !(cursorObject getVariable [ "plb_escorting",false ] ) && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["Send Combat Logger to Jail", {[cursorObject]
                    call life_fnc_jailCL},"",0,false,false,"",'!isNull cursorObject && !(isPlayer cursorObject) && (player distance cursorObject < 3.5) && ((typeOf cursorObject) isEqualTo "Land_Bodybag_01_black_F") && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["Impound Vehicle", {[false,cursorObject]
                    call life_fnc_impoundAction},nil,3,false,false,"",'!isNull cursorObject && alive cursorObject && (player distance cursorObject) < 6 && speed cursorObject < 2 && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship") && ((cursorObject getVariable [ "plb_side", "civ" ] in [ "cop", "med" ] ) || !(typeOf cursorObject in [ "O_MRAP_02_F","I_MRAP_03_F","B_G_Offroad_01_armed_F","O_LSV_02_armed_F","I_C_Offroad_02_LMG_F" ] ))',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Seize Vehicle</t>", {[true,cursorObject]
                    call life_fnc_impoundAction},nil,0,false,false,"",'!isNull cursorObject && alive cursorObject && (player distance cursorObject) < 6 && speed cursorObject < 2 && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship") && (cursorObject getVariable [ "plb_side", "" ] isEqualTo "civ") && (typeOf cursorObject in [ "O_MRAP_02_F","I_MRAP_03_F","B_G_Offroad_01_armed_F","O_LSV_02_armed_F","I_C_Offroad_02_LMG_F", "B_MRAP_01_F" ] || (cursorObject getVariable [ "plb_canSeize",false ] ))',6]);

            life_actions pushBack(_plb_obj addAction ["Search", {[cursorObject]
                    call life_fnc_searchAction},nil,0,false,false,"",'!isNull cursorObject && cursorObject isKindOf "CAManBase" && (isPlayer cursorObject) && (cursorObject getVariable [ "plb_restrained",false ] || cursorObject getVariable [ "plb_civRestrained",false ] ) && (side cursorObject != west) && player distance cursorObject < 3.5 && !(cursorObject getVariable [ "plb_escorting",false ] ) && (isNull objectParent player)',6]);

            // owner 2026-07-20: APD wipes ILLEGAL CYBERDECK FIRMWARE off a restrained suspect's phone. Strips the
            // firmware (id 0 of plb_cdMods, broadcast so this condition can read it) -- their purchased hardware
            // modules (1-4) SURVIVE; they just have to re-flash at an electronics shop.
            life_actions pushBack(_plb_obj addAction ["<t color='#ff5a3c'>Factory Reset Cyberdeck</t>", {[["factoryReset", cursorObject, player], "TON_fnc_cyberdeckSRV", 2] spawn life_fnc_MP;},nil,0,false,false,"",'!isNull cursorObject && cursorObject isKindOf "CAManBase" && (isPlayer cursorObject) && (cursorObject getVariable [ "plb_restrained",false ] || cursorObject getVariable [ "plb_civRestrained",false ] ) && (side cursorObject != west) && player distance cursorObject < 3.5 && (0 in (cursorObject getVariable [ "plb_cdMods",[] ] )) && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["Search Trunk", {[cursorObject]
                    call life_fnc_vehicleInvSearch},nil,0,false,false,"",'!isNull cursorObject && (player distance cursorObject) < 6 && speed cursorObject < 2 && alive cursorObject && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship" || typeOf cursorObject in [ "Land_TentA_F","Land_TentDome_F","B_CargoNet_01_ammo_F" ] ) && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["Check Registration", {[cursorObject]
                    call life_fnc_searchVehAction},"",0,false,false,"",' ((call life_adminLevel) <= 1) && !isNull cursorObject && (player distance cursorObject) < 5 && speed cursorObject < 2 && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship")',6]);

            life_actions pushBack(_plb_obj addAction ["Search House Storage", {[cursorObject]
                    call life_fnc_houseInvSearch},nil,0,false,false,"",'(cursorObject getVariable [ "plb_restricted_house", false ] != true) && !isNull cursorObject && (player distance cursorObject) < 8 && (typeOf cursorObject in life_houseTypes) && (call life_copLevel >= 5) && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["Seize House Storage", {[cursorObject]
                    call life_fnc_houseInvSeize},nil,0,false,false,"",'(cursorObject getVariable [ "plb_restricted_house", false ] != true) && !isNull cursorObject && (player distance cursorObject) < 8 && (typeOf cursorObject in life_houseTypes) && (call life_copLevel >= 5) && (isNull objectParent player)',6]);

            if(player distance2D [9054.95,22465.4,0]
            <=60) then {life_actions pushBack(_plb_obj addAction ["Seize Tent Trunk", {[cursorObject]
                        spawn life_fnc_seizeIllegalTent},nil,0,false,false,"",'!isNull cursorObject && ((player distance cursorObject) < 6) && (typeOf cursorObject in [ "Land_TentA_F", "Land_TentDome_F" ] ) && (isNull objectParent player)',6]);}
            else {life_actions pushBack(_plb_obj addAction ["Seize Trunk", {[cursorObject]
                        spawn life_fnc_vehicleInvSeize},nil,0,false,false,"",'!isNull cursorObject && (player distance cursorObject) < 6 && speed cursorObject < 2 && alive cursorObject && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship" || typeOf cursorObject in [ "Land_TentA_F", "Land_TentDome_F", "B_CargoNet_01_ammo_F" ] ) && (isNull objectParent player)',6]);};

            life_actions pushBack(_plb_obj addAction ["Seize virtual Items into Evidence", {[cursorObject,"HQ","ITEM"]
                    call life_fnc_seizePlayerIllegal},"",0,false,false,"",'!isNull cursorObject && (player distance cursorObject) < 6 && speed cursorObject < 2 && ((cursorObject isKindOf "CAManBase" && (isPlayer cursorObject) && (side cursorObject != west) && (cursorObject getVariable [ "plb_restrained",false ] ))) && (call life_copLevel) >= 1 && (( { (position player) inPolygon (life_police_hq_polys select _x) } count [ 0,1,2,3,4,5,6 ] > 0) || (((SRV_mobileHQ param [ 1, objNull ] ) != objNull) && ((SRV_mobileHQ param [ 1, objNull ] ) getVariable [ "plb_mobileHeadQuartersTruckLocked", false ] ) && (((SRV_mobileHQ param [ 1, objNull ] ) distance2D player) < 20))) && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["Seize all Items into Evidence", {[cursorObject,"HQ","ALL"]
                    call life_fnc_seizePlayerIllegal},"",0,false,false,"",'!isNull cursorObject && (player distance cursorObject) < 6 && speed cursorObject < 2 && ((cursorObject isKindOf "CAManBase" && (isPlayer cursorObject) && (side cursorObject != west) && (cursorObject getVariable [ "plb_restrained",false ] ) || ((cursorObject isKindOf "Car" || cursorObject isKindOf "Air") && alive cursorObject))) && (call life_copLevel) >= 1 && (( { (position player) inPolygon (life_police_hq_polys select _x) } count [ 0,1,2,3,4,5,6 ] > 0) || (((SRV_mobileHQ param [ 1, objNull ] ) != objNull) && ((SRV_mobileHQ param [ 1, objNull ] ) getVariable [ "plb_mobileHeadQuartersTruckLocked", false ] ) && (((SRV_mobileHQ param [ 1, objNull ] ) distance2D player) < 20))) && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["Seize virtual Items into Vehicle", {[cursorObject,"Field","ITEM"]
                    call life_fnc_seizePlayerIllegal},"",0,false,false,"",'!isNull cursorObject && (player distance cursorObject) < 6 && speed cursorObject < 2 && cursorObject isKindOf "CAManBase" && (isPlayer cursorObject) && (side cursorObject != west) && (cursorObject getVariable [ "plb_restrained",false ] ) && (call life_copLevel) >= 2 && (count(nearestObjects [ player, [ "Car","Air" ] , 20 ] ) > 0) && ( { player distance2D getMarkerPos format [ "police_hq_%1",_x ] < 50 } count [ 1,2,3,4,5,6 ] isEqualTo 0) &&!(((SRV_mobileHQ param [ 1, objNull ] ) != objNull) && ((SRV_mobileHQ param [ 1, objNull ] ) getVariable [ "plb_mobileHeadQuartersTruckLocked", false ] ) && (((SRV_mobileHQ param [ 1, objNull ] ) distance2D player) < 20)) && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["Seize all Items into Vehicle", {[cursorObject,"Field","ALL"]
                    call life_fnc_seizePlayerIllegal},"",0,false,false,"",'!isNull cursorObject && (player distance cursorObject) < 6 && speed cursorObject < 2 && cursorObject isKindOf "CAManBase" && (isPlayer cursorObject) && (side cursorObject != west) && (cursorObject getVariable [ "plb_restrained",false ] ) && (call life_copLevel) >= 2 && (count(nearestObjects [ player, [ "Car","Air" ] , 20 ] ) > 0) && ( { player distance2D getMarkerPos format [ "police_hq_%1",_x ] < 50 } count [ 1,2,3,4,5,6 ] isEqualTo 0) &&!(((SRV_mobileHQ param [ 1, objNull ] ) != objNull) && ((SRV_mobileHQ param [ 1, objNull ] ) getVariable [ "plb_mobileHeadQuartersTruckLocked", false ] ) && (((SRV_mobileHQ param [ 1, objNull ] ) distance2D player) < 20)) && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["Seize Objects", {[cursorObject]
                    call life_fnc_seizeObjects},nil,0,false,false,"",'((cursorObject isKindOf "GroundWeaponHolder") || (cursorObject isKindOf "WeaponHolderSimulated") || (cursorObject isKindOf "WeaponHolder")) && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Track APB Target</t>", {[true]
                    call life_fnc_trackAPB},nil,0,false,true,"",' player distance (getMarkerPos "bounty_apb") < life_track_radius ',6]);

            life_actions pushBack(_plb_obj addAction ["Pack up Spike Strip",life_fnc_packupSpikes,"",0,false,false,"",'_spikes = nearestObjects [ player, [ "Land_Razorwire_F" ] ,8 ] select 0 ; !isNil "_spikes" && !isNil { (_spikes getVariable "plb_placed") }',6]);

            if((call life_copLevel)>=5) then {life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Toggle All House Locks</t>", {[cursorObject]
                        call life_fnc_lockHouse},nil,-1,false,false,"",'!isNull cursorObject && (player distance cursorObject) < 20 && (typeOf cursorObject in life_houseTypes) && ((call life_copLevel) >= 5) && (cursorObject getVariable [ "plb_homeOwner","" ] != "") && (isNull objectParent player)',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Toggle Governor Building Locks</t>", {["toggleGovBuildingLocks",cursorObject]
                        spawn life_fnc_govSystem},nil,0,false,false,"",'!(isNull cursorObject) && (typeOf cursorObject isEqualTo "Land_Hotel_02_F") && (player distance cursorObject < 15) && ((call life_copLevel) >= 5) && (isNull objectParent player)',6]);};

            life_actions pushBack(_plb_obj addAction ["<t color='#990000'>Charge with Crime</t>",life_fnc_crimeCharge,cursorObject,-1,false,false,"",'!isNull cursorObject && (player distance cursorObject) < 5 && cursorObject isKindOf "CAManBase" && (isPlayer cursorObject) && (side cursorObject != west) && (cursorObject getVariable [ "plb_restrained",false ] ) && (call life_copLevel) > 1 && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["Revoke Drivers License", {[cursorObject,"driver"]
                    call life_fnc_revokeLicense},nil,0,false,false,"",'(isPlayer cursorObject) && (side cursorObject isEqualTo civilian) && alive cursorObject && cursorObject distance player < 5 && (cursorObject getVariable [ "plb_restrained",false ] ) && speed cursorObject < 1 && ((call life_copLevel) >= 2) && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["Revoke Bounty Hunter License", {[cursorObject,"bounty"]
                    call life_fnc_revokeLicense},nil,0,false,false,"",'(isPlayer cursorObject) && (side cursorObject isEqualTo civilian) && alive cursorObject && cursorObject distance player < 5 && (cursorObject getVariable [ "plb_restrained",false ] ) && (cursorObject getVariable [ "plb_isBountyHunter", false ] ) && speed cursorObject < 1 && (call life_copLevel) >= 2 && (isNull objectParent player)',6]);

            if((call life_copLevel)>=3) then {life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Revoke BH License (Server Cycle)</t>", {[cursorObject,"bounty",true]
                        call life_fnc_revokeLicense},nil,0,false,false,"",'(isPlayer cursorObject) && (side cursorObject isEqualTo civilian) && alive cursorObject && cursorObject distance player < 5 && (cursorObject getVariable [ "plb_restrained",false ] ) && (cursorObject getVariable [ "plb_isBountyHunter", false ] ) && speed cursorObject < 1 && (call life_copLevel) >= 3 && (isNull objectParent player)',6]);};

            life_actions pushBack(_plb_obj addAction ["Unlock Reserve Gate",life_fnc_openGate,"",0,false,false,"",'((typeOf cursorObject) isEqualTo"Land_BarGate_F") && !((cursorObject getVariable [ "gate_max", 0 ] ) isEqualTo 1) && ((player distance cursorObject) <= 7) && (cursorObject in life_fed_gates) && (!life_action_in_use) && (isNull objectParent player)',6]);

            life_actions pushBack(_plb_obj addAction ["Open Police Gate", {private _gates=nearestObjects [player, ["Land_BarGate_F","Land_RoadBarrier_01_F"],15];

                    private _gate=_gates param [_gates findIf {!isNull _x},objNull];

                    if(!isNull _gate&& {!(_gate in life_fed_gates)}) then {_gate animate ["Door_1_rot",1]};},"",3,false,false,"",'private _gates = nearestObjects [ player, [ "Land_BarGate_F", "Land_RoadBarrier_01_F" ] , 15 ] ; private _gate = _gates param [ _gates findIf { !isNull _x } , objNull ] ; !isNull _gate && { !(_gate in life_fed_gates) && _gate animationPhase "Door_1_rot" isEqualTo 0 }',6]);

            life_actions pushBack(_plb_obj addAction ["Close Police Gate", {private _gates=nearestObjects [player, ["Land_BarGate_F","Land_RoadBarrier_01_F"],15];

                    private _gate=_gates param [_gates findIf {!isNull _x},objNull];

                    if(!isNull _gate&& {!(_gate in life_fed_gates)}) then {_gate animate ["Door_1_rot",0]};},"",3,false,false,"",'private _gates = nearestObjects [ player, [ "Land_BarGate_F", "Land_RoadBarrier_01_F" ] , 15 ] ; private _gate = _gates param [ _gates findIf { !isNull _x } , objNull ] ; !isNull _gate && { !(_gate in life_fed_gates) && _gate animationPhase "Door_1_rot" isEqualTo 1 }',6]);

            life_actions pushBack(_plb_obj addAction ["Remove Blindfold", {[2,cursorObject]
                    spawn life_fnc_blindfoldAction},cursorObject,-1,false,true,"",'((cursorObject getVariable [ "plb_blinded",false ] ) && (cursorObject isKindOf "CAManBase") && (isPlayer cursorObject) && (alive cursorObject) && ((cursorObject distance player) < 5) && ((speed cursorObject) < 1)) && (isNull objectParent player)',6]);

            if(life_coprole in ["detective","all"]) then {life_actions pushBack(_plb_obj addAction ["Show Rank Identity", {player setVariable ["plb_showrank",true,true];},nil,-2,false,false,"",'!(player getVariable [ "plb_showrank",true ] )',6]);

                life_actions pushBack(_plb_obj addAction ["Hide Rank Identity", {player setVariable ["plb_showrank",false,true];},nil,-2,false,false,"",'(player getVariable [ "plb_showrank",true ] )',6]);};

            if(life_coprole in ["warrant","all"]) then {life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Track Fugitive 1</t>", {[0]
                        call life_fnc_trackBounty},nil,0,false,true,"",' player distance (getMarkerPos "bounty_0") < life_track_radius ',6]);};

            if((call life_copLevel)>=2) then {life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Load Lethal Rounds</t>", {[]
                        call life_fnc_nonLethal},nil,1.5,false,false,"",'player getVariable [ "plb_nonlethal",false ]',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#00FF00'>Load Non-Lethal Rounds</t>", {[]
                        call life_fnc_nonLethal},nil,1.5,false,false,"",'!(player getVariable [ "plb_nonlethal",false ] )',6]);};

            life_actions pushBack(_plb_obj addAction ["Deactivate SWAT", {(_this select 1) setUnitLoadout life_swatLoadout;

                    life_swatLoadout=nil;

                    life_activeSWAT=false;

                    life_SWATActionAvail=false;},"",1.5,false,false,"","life_activeSWAT && life_SWATActionAvail"]);

            life_actions pushBack(_plb_obj addAction ["Disable Drill",life_fnc_stopBankRobbery,false,4,true,true,"",' (player distance (getMarkerPos "life_bank_door") < 4 || player distance (getMarkerPos "life_bank_door_2") < 4) && (life_bank_robbed select 0) && isNull objectParent player',6]);

            if(!isNil"serverStartTime"&&!isNil"serverCycleLength"&& {(serverCycleLength-(serverTime-serverStartTime))<=240}) then {life_actions pushBack(_plb_obj addAction ["Send to Jail (Anywhere)", {[cursorObject]
                        call life_fnc_arrestAction},nil,0,false,false,"",'!isNull cursorObject && isPlayer cursorObject && !(side cursorObject isEqualTo west) && (cursorObject getVariable [ "plb_restrained",false ] ) && alive cursorObject && (player distance cursorObject < 3.5) && !(cursorObject getVariable [ "plb_escorting",false ] ) && (isNull objectParent player)',6]);};

            if(player distance [20898.6,19221.7,0.00143909]
            <=400) then {life_actions pushBack(_plb_obj addAction ["Secure Dome",life_fnc_evidenceSystems,3,5,false,false,"",'life_evidence_dome isEqualTo cursorObject && (!(SRV_evidence_status select 1) && (SRV_evidence_status select 0)) && typeOf cursorObject isEqualTo "Land_Dome_Big_F" && !life_action_in_use && isNull objectParent player',6]);

                life_actions pushBack(_plb_obj addAction ["<t color='#00FF00'>Repair Defense Systems</t>",life_fnc_evidenceSystems,1,5,false,false,"",'(playerSide isEqualTo west) && !isNull cursorObject && (cursorObject isEqualTo (missionNamespace getVariable [ "evidenceLaptop", objNull ] )) && !((cursorObject getVariable [ "plb_laptopstatus",1 ] ) isEqualTo 1) && ((player distance cursorObject) < 3) && !life_action_in_use && (isNull objectParent player)',6]);};

            if(player distance getMarkerPos"life_mentalHospital"<=400) then {life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Disable Mainframe Virus</t>", {["stopRobberyCop", [cursorObject]]
                        spawn life_fnc_loonyBin},nil,0,false,false,"",'(playerSide isEqualTo west) && (cursorObject isEqualTo life_mentalLaptopCop) && !(cursorObject getVariable [ "plb_mentalFirewallActive", false ] ) && !isNull cursorObject && (player distance cursorObject) < 5',6]);};

            if((call life_copLevel)>=3||(call life_adminLevel)>=2) then {life_actions pushBack(_plb_obj addAction ["Force Open/Close Door", {[cursorObject,true]
                        spawn life_fnc_doorAnimate},nil,1,false,false,"",'(typeOf cursorObject isEqualTo "Land_Dome_Big_F" || typeOf cursorObject isEqualTo "Land_Dome_Small_F" || (player distance (getMarkerPos "life_bank_door") < 4 || player distance (getMarkerPos "life_bank_door_2") < 4)) && !life_action_in_use && isNull objectParent player',6]);};

            life_actions pushBack(_plb_obj addAction ["Unrestrain", {[cursorObject,true]
                    spawn life_fnc_unrestrain},nil,0,false,false,"",'if (!isNull cursorObject) then { if (isPlayer cursorObject) then { (cursorObject isKindOf "CAManBase" && player distance cursorObject < 3.5 && (cursorObject getVariable [ "plb_restrained",false ] ) && !(cursorObject getVariable [ "plb_escorting",false ] )) && (isNull objectParent player) && (isNull objectParent cursorObject) } ; } ;',6]);

            life_actions pushBack(_plb_obj addAction ["Service Chopper ($1,000)", {[]
                    spawn life_fnc_serviceChopper},nil,1.4,false,true,"",'(playerSide isEqualTo west) && (player distance [ 15186,17331,0 ] < 60) && !life_action_in_use && (isNull objectParent player)',6]);

            if((call life_copLevel)>=4) then {life_actions pushBack(_plb_obj addAction ["Setup Mobile HQ", {["setupMobileHQ", [],player,vehicle player]
                        spawn life_fnc_clientMobileHQ;},nil,0,false,false,"",'!(SRV_mobileHQ select 2) && (vehicle player) isKindOf "B_Truck_01_covered_F" && (driver (vehicle player)) isEqualTo player',6]);};};

        case independent: {life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Use Defibrillator</t>",life_fnc_revivePlayer,cursorObject,-1,false,true,"",'!isNull cursorObject && cursorObject isKindOf "CAManBase" && !(alive cursorObject) && cursorObject getVariable [ "plb_revivable",false ] && life_inv_defib > 0 && (player distance cursorObject) < 3.5 && (isNull objectParent player) && (isNull objectParent cursorObject)',6]);

            if((call life_medicLevel)>=4) then {life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Toggle All House Locks</t>", {[cursorObject]
                        call life_fnc_lockHouse},nil,-1,false,false,"",'!isNull cursorObject && (player distance cursorObject) < 20 && (typeOf cursorObject in life_houseTypes) && ((call life_medicLevel) >= 4) && (cursorObject getVariable [ "plb_homeOwner","" ] != "") && (isNull objectParent player)',6]);};

            life_actions pushBack(_plb_obj addAction ["Medic Enter as Driver", {["driver"]
                    call life_fnc_forceVehicleEnter},nil,200,false,false,"",'(cursorObject getVariable [ "plb_side", "" ] isEqualTo "med") && { !isNull cursorObject && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship") && (locked cursorObject) != 0 && cursorObject distance player < 5 }',7]);

            life_actions pushBack(_plb_obj addAction ["Medic Enter as Passenger", {["passenger"]
                    call life_fnc_forceVehicleEnter},nil,100,false,false,"",'(cursorObject getVariable [ "plb_side", "" ] isEqualTo "med") && { !isNull cursorObject && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship") && (locked cursorObject) != 0 && cursorObject distance player < 5 }',7]);

            life_actions pushBack(_plb_obj addAction ["Exit", {["exit"]
                    call life_fnc_forceVehicleEnter},nil,100,false,false,"",'!(isNull objectParent player) && (locked (vehicle player) isEqualTo 2) && (vehicle player getVariable [ "plb_side", "" ] isEqualTo "med")',8]);

            life_actions pushBack(_plb_obj addAction ["<t color='#FFFF00'>Emergency Lights (OFF)</t>", {vehicle player setVariable ["plb_lights",false,true];},nil,-1,false,false,"",'!(isNull objectParent player) && (objectParent player getVariable [ "plb_side","civ" ] == "med") && objectParent player getVariable [ "plb_lights", false ] && (player isEqualTo (driver vehicle player)) && (!isNil { vehicle player getVariable "plb_lights" } )',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#FFFF00'>Emergency Lights (ON)</t>", {[vehicle player]
                    call life_fnc_medicSirenLights;},nil,-1,false,false,"",'!(isNull objectParent player) && (objectParent player getVariable [ "plb_side","civ" ] == "med") && !(objectParent player getVariable [ "plb_lights", false ] ) && (player isEqualTo (driver vehicle player)) && (!isNil { vehicle player getVariable "plb_lights" } )',6]);

            life_actions pushBack(_plb_obj addAction ["Impound Vehicle", {[false,cursorObject]
                    call life_fnc_impoundAction},nil,3,false,false,"",'!isNull cursorObject && alive cursorObject && (player distance cursorObject) < 6 && speed cursorObject < 2 && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship" ) && !(typeOf cursorObject in [ "O_MRAP_02_F","B_G_Offroad_01_armed_F","O_LSV_02_armed_F","I_C_Offroad_02_LMG_F" ] ) && ((call life_medicLevel) >= 3)',6]);

            if(life_isActiveFirefighter&&(count SRV_houseOnFire!=0)) then {if!(isNull life_hoseObject) then {if((typeOf cursorObject isEqualTo"O_Truck_03_fuel_F")&&!isNull cursorObject&&(player distance cursorObject)<5) then {life_actions pushBack(_plb_obj addAction ["<t color='#2afffa'>Refill Hose</t>", {["fillHose"]
                                spawn life_fnc_medicFireClient},nil,0,false,false,"",'(isNull objectParent player) && (count SRV_houseOnFire != 0) && (typeOf cursorObject isEqualTo "O_Truck_03_fuel_F") && (player distance cursorObject) < 5',6]);};

                    life_actions pushBack(_plb_obj addAction ["<t color='#2afffa'>Toggle Fire Hose</t>", {["toggleFirehose", [(player getVariable ["plb_hoseOn",false]),cursorObject]]
                            spawn life_fnc_medicFireClient},nil,0,false,false,"",'private _nearHouseFire = false ; { if (player distance2D _x <= 25) exitWith { _nearHouseFire = true ; } ; } foreach SRV_houseOnFire ; (isNull objectParent player) && (count SRV_houseOnFire != 0) && _nearHouseFire',6]);};};

            life_actions pushBack(_plb_obj addAction ["NG Item Shop", {[cursorObject,"","","meditemshop"]
                    call life_fnc_virtualShopMenu},nil,1.5,false,false,"",'playerSide isEqualTo independent && (typeOf cursorObject) isEqualTo "C_IDAP_supplyCrate_F" && cursorObject getVariable [ "plb_medSupply", false ]',5]);

            life_actions pushBack(_plb_obj addAction ["Partner Up", {[1,cursorObject]
                    call life_fnc_medicPartners},nil,-1,false,true,"",'!isNull cursorObject && cursorObject isKindOf "CAManBase" && isPlayer cursorObject && alive cursorObject && isNull objectParent player && side cursorObject isEqualTo independent',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#FFFF00'>Check Partners</t>", {[4,objNull]
                    call life_fnc_medicPartners},nil,-1,false,true,"",'!(life_medPartners isEqualTo [ ] )',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#FF0000'>Wipe Partners</t>", {[5,objNull]
                    call life_fnc_medicPartners},nil,-1,false,true,"",'!(life_medPartners isEqualTo [ ] ) && isNull objectParent player',6]);

            life_actions pushBack(_plb_obj addAction ["<t color='#90EE90'>Clear Wreckage</t>", {[cursorObject]
                    spawn life_fnc_medicDeleteVeh},nil,200,false,false,"",'!(alive cursorObject) && (cursorObject isKindOf "Car" || cursorObject isKindOf "Air" || cursorObject isKindOf "Ship") && (cursorObject distance player < 12)',12]);

            life_actions pushBack(_plb_obj addAction ["<t color='#FF7400'>Repair Destroyed House</t>", {["actionRepair"]
                    spawn life_fnc_medicRepairBuilding},nil,1.5,true,true,"""",'private _building = (nearestTerrainObjects [ player, [ "House" ] , 7, true, true ] ) param [ 0, objNull ] ; private _building = if (_building getVariable [ "plb_terrainObject_repaired", false ] ) then { (nearestObjects [ player, [ "House" ] , 7, true ] ) param [ 0, objNull ] } else { _building } ; ((_building isKindOf "House_F") && (_building getVariable [ "plb_repairRequested", false ] ) && (damage _building >= 1))',6]);

            life_actions pushBack(_plb_obj addAction ["Open Gate", {private _gates=nearestObjects [player, ["Land_BarGate_F","Land_RoadBarrier_01_F"],15];

                    private _gate=_gates param [_gates findIf {!isNull _x},objNull];

                    private _copGate=false;

                    if(_gate in life_cop_gates) then {_copGate=true};

                    if(!isNull _gate&& {!(_gate in life_fed_gates)}
                    &&!_copGate) then {_gate animate ["Door_1_rot",1]};

                    if(_copGate) then {["Medics are unable to tamper with police gates.","basic"]
                        spawn life_fnc_handleMessage;};},"",3,false,false,"",'private _gates = nearestObjects [ player, [ "Land_BarGate_F", "Land_RoadBarrier_01_F" ] , 15 ] ; private _gate = _gates param [ _gates findIf { !isNull _x } , objNull ] ; !isNull _gate && { !(_gate in life_fed_gates) && _gate animationPhase "Door_1_rot" isEqualTo 0 }',6]);

            life_actions pushBack(_plb_obj addAction ["Close Gate", {private _gates=nearestObjects [player, ["Land_BarGate_F","Land_RoadBarrier_01_F"],15];

                    private _gate=_gates param [_gates findIf {!isNull _x},objNull];

                    private _copGate=false;

                    if(_gate in life_cop_gates) then {_copGate=true};

                    if(!isNull _gate&& {!(_gate in life_fed_gates)}
                    && {!_copGate}) then {_gate animate ["Door_1_rot",0]};

                    if(_copGate) then {["Medics are unable to tamper with police gates.","basic"]
                        spawn life_fnc_handleMessage;};},"",3,false,false,"",'private _gates = nearestObjects [ player, [ "Land_BarGate_F", "Land_RoadBarrier_01_F" ] , 15 ] ; private _gate = _gates param [ _gates findIf { !isNull _x } , objNull ] ; !isNull _gate && { !(_gate in life_fed_gates) && _gate animationPhase "Door_1_rot" isEqualTo 1 }',6]);};};};
