class Life_Client_Core {tag = "life";
    class Master_Directory {file = "core";
        class initCiv {};
        class initCop {};
        class initMedic {};
        class setupActions {};
        class setupEVH {};
        class survival {};};
    class LoonyBin115C {file = "core\session";
        class ClupdatePartial {};
        class ClupdateRequest {};
        class dataQuery {};
        class insertPlayerInfo {};
        class requestReceived {};
        class syncData {};
        class ndSync {};        // New Drachma: server -> client authoritative balance push
        class ndResult {};      // New Drachma: server -> client debit result (token continuation)
        class ndCoinSwept {};   // New Drachma: server -> client login coin-sweep toast
    };
    class Radio {                 // LooneyBin car radio (driver-controlled, shared: occupants say2D / bystanders say3D)
        file = "core\radio";
        class autoRadio {};
        class radioHud {};
        class radioKeys {};
        class radioRadial {};
        class radioListen {};
        class hudToast {};    // life_fnc_hudToast  -- generalised radio-card notification (core\radio\fn_hudToast.sqf)
        class toastDemo {};   // life_fnc_toastDemo -- owner test trigger for the notification language
        class plbShopDemo {}; // life_fnc_plbShopDemo -- PROOF: custom-PAA "real way" shop (core\radio\fn_plbShopDemo.sqf)
        class plbInvDemo {};  // life_fnc_plbInvDemo  -- PROOF: custom-PAA STRONGBOX inventory (core\radio\fn_plbInvDemo.sqf)
    };
    // owner 2026-06-23: SpyGlass anti-cheat REMOVED entirely (legacy/unmaintained, caused more issues than it
    // solved -- menuCheck false-positives nuked the display hierarchy on spawn). The WAC tamper-report sink it
    // shared was renamed WAC -> DONG (TON_fnc_dongClient) and kept. The 64 inert checkIntegrity guards were stripped.
    class Admin {file = "core\admin";
        class adminAddMoney {};
        class adminTeleportFacing {};
        class adminInfo {};
        class adminMenu {};
        class adminMenuTabSwitch {};
        class adminQuery {};
        class adminTP {};
        class adminRevive {};
        class adminInvis {};
        class adminBulletCam {};
        class adminKick {};
        class adminBan {};
        class economyMenu {};
        class adminNewsBroadcast {};
        class adminMessage {};
        class adminJail {};
        class adminSetPos {};
        class adminGetPos {};
        class adminMode {};
        class adminGodmode {};
        class adminPlayerQuery {};
        class adminSpectate {};
        class srvCycAdjust {};
        class adminSpawnVehicle {};
        class adminRestrain {};
        class adminUnrestrain {};
        class unitRestrain {};
        class eventVehMarkers {};
        class adminCam {};
        class adminWeather {};
        class adminWeaponMenu {};   // ui branch: WEAPONS & GEAR tab -- spawn any weapon/mag/attachment (level >2, logged)
        class adminVehicleList {};  // ui branch: vehicle tab list -- curated sections + full-game search
        class adminClothingMenu {}; // ui branch: CLOTHING tab -- every uniform/vest/hat/goggles/backpack in the game
        class adminGearReceive {};  // target-side receiver for staff-menu gives (CfgRE-whitelisted; raw engine remoteExec is blocked)
        class adminSnowFX {};};
    class AdminSpectate {file = "core\adminSpectate";
        class spectateESP {};
        class spectateSettings {};};
    class SeasonalEvents {file = "core\seasonalEvents";
        class easterSeasonalEventCL {};
        class openChristmasTreePresentCL {};};
    class Bounty {file = "core\bounty";
        class dropBounty {};
        class removeBounty {};
        class requestBounty {};
        class trackBounty {};
        class setGroupMarker {};
        class trackAPB {};
        class bodybagMarker {};};
    class Medical_System {file = "core\medical";
        class acceptMedicalRequest {};
        class deathScreen {};
        class doRespawn {};
        class requestMedicalConfirmation {};
        class medicRespondDone {};
        class medicLights {};
        class medicLoadout {};
        class medicMarkers {};
        class sendRequestToMedic {};
        class medicSiren {};
        class medicSirenLights {};
        class medicHexs {};
        class medicDeleteVeh {};
        class deathScreenMedicalButtonClick {};
        class respawned {};
        class revived {};
        class revivePlayer {};
        class loveBomb {};
        class loveBombHeal {};
        class reviveDrone {};
        class medicEarn {};
        class medSupplyEarn {};
        class setPain {};
        class painkillers {};
        class medicPartners {};
        class rehab {};
        class medicRepairBuilding {};
        class medicRespondMenu {};
        class medicFireClient {};};
    class Actions {file = "core\actions";
        class activateNitro {};
        class alcoholRecipes {};
        class arrestAction {};
        class bankToggleLighthouse {};
        class blindfoldAction {};
        class blindfoldClient {};
        class buyLicense {};
        class catchFish {};
        class catchTurtle {};
        class ch7Broadcast {};
        class chopTree {};
        class crankLab {};
        class closeMap {};
        class commitArsonClient {};
        class drillOil {};
        class dropFishingNet {};
        class dropOil {};
        class escortAction {};
        class evidenceVaultOpen {};
        class flip {};
        class gather {};
        class gatherObject {};
        class gatherOil {};
        class gatherWater {};
        class getDPMission {};
        class finishDPMission {};
        class healHospital {};
        class holsterWeapon {};
        class lottoTix {};
        class medSupplyDestroy {};
        class mine {};
        class mineUranium {};
        class oilPump {};
        class openGate {};
        class openSafe {};
        class openVault {};
        class packupSpikes {};
        class pickupItem {};
        class pickupOil {};
        class placeOil {};
        class postBail {};
        class processAction {};
        class processVehicle {};
        class pulloutAction {};
        class pushVehicle {};
        class putInVeh {};
        class refillAmmo {};
        class repairTruck {};
        class restrainAction {};
        class robAction {};
        class babyOil {};
        class babyOilStrip {};
        class robStoreAction {};
        class searchAction {};
        class searchVehAction {};
        class searchWreck {};
        class serviceChopper {};
        class skinAnimal {};
        class stopBankRobbery {};
        class stopEscorting {};
        class storeVehicle {};
        class surrender {};
        class ticketAction {};
        class translateOil {};
        class treasureChestCreate {};
        class treasureMapOpen {};
        class turnedIn {};
        class unrestrain {};
        class useShank {};
        class evidenceSystems {};
        class startConvoyRobbery {};
        class finishConvoyRobbery {};
        class moonshineLab {};
        class metalDetector {};
        class fungiActions {};
        class mineFungi {};
        class loonyBin {};
        class putInVehAction {};
        class jewelryEmporium {};
        class enterActiveTurf {};
        class campFire {};};
    class Intake {file = "core\intake";
        class intake {};   // owner 2026-07-11: THE INTAKE Act 1 -- new-player onboarding (wake in the Bin)
        class parole {};   // owner 2026-07-11: PAROLE PAPERS Act 2 -- 6-contract starter arc
        class mentor {};   // owner 2026-07-11: MENTOR PROGRAM Act 3 -- veterans adopt New Bloods, paid on graduation
    };
    class GPS {   // owner 2026-07-12: road-graph GPS -- routing + map overlay (roadgraph_data.sqf generated by tools/roadgraph_build.py)
        file = "core\gps";
        class gpsInit {};     // lazy graph loader (nodes/edges/adjacency)
        class routeFind {};   // A* over the road graph -> route polyline
        class gps {};         // UI: ALT+MapClick set/clear, map Draw overlay, G-on-map search hook
        class gpsSearch {};   // destination search dialog (towns + named markers)
        class gpsHud {};      // turn-by-turn banner loop (reroute + arrival)
        class gpsAutopilot {};// TESLA MODE: scroll autopilot along the active route (driver-local)
        class robotaxi {};    // hail a driverless autopilot cab to the GPS destination
        class hcDrive {};     // HEADLESS AUTOPILOT: drive a driverless veh to a dest, player-less, runs on the HC (any range)
        class hcReverse {};   // physics reverse (negative model-space velocity), raycast-guarded behind
        class hcTurnAround {};// 3-point turn to a target heading (forward/reverse arcs) -- cars with no reverse gear
        class hcDepart {};    // clean departure: reverse off the spot -> 3-point turn -> hand back to hcDrive to leave
    };
    class Housing {class miningRig {};   // install/collect house mining rig
        file = "core\housing";
        class buyHouse {};
        class getBuildingPositions {};
        class handleHouse {};
        class houseMenu {};
        class renameHouse {};
        class buyHelipad {};   // owner 2026-07-10: shed helipad upgrade purchase (house menu)
        class maldenPicker {};      // owner 2026-07-11: Malden Makeover skin picker (client half; 6 colors + off)
        class maldenSync {};        // owner 2026-07-11: swap-time client registry fix (life_vehicles door-lock gate)
        class storageVault {};      // owner 2026-07-11: Storage Worker NPC -- vault dialog (pack/unpack)
        class storageVaultRecv {};  // owner 2026-07-11: server -> client vault panel push (CfgRE targets=1)
        class storageWorker {};     // owner 2026-07-11: Storage Worker NPC init hook (scroll action)
        class vaultClassLabel {};   // owner 2026-07-11: friendly house-class name for the vault UI
        class renameHouseDone {};
        class marketSellHouse {};
        class CLinitHouses {};
        class initKeyHouseMarkers {};
        class lightHouseAction {};
        class lightHouse {};
        class lockHouse {};
        class sellHouse {};
        class upgradeProperty {};
        class manageBldgKeys {};
        class listKeyHolders {};
        class keyHolderStatus {};
        class manageHouseTax {};};
    class Config {file = "core\config";
        class qhCfg {};           // quickhack catalogue (Tier 1)
        class eatFood {};
        class houseConfig {};
        class licenseCfg {};
        class mapData {};
        class maldenMap {};   // owner 2026-07-11: Malden Makeover class map (base <-> Argo variant; server reads it too)
        class prestigeCfg {};
        class talentCfg {};
        class timeTrialCfg {};
        class vehicleAnimate {};
        class vehicleTextures {};
        class questsCfg {};
        class tutorialCfg {};
        class vehicleConfig {};
        class ndPriceCfg {};      // New Drachma price override table (seeded 6000:1, hand-tunable)
        class virt_shops {};
        class virtItemCfg {};
        class weaponAddons {};
        class clothingTextures {};
        class weaponShopCfg {};
        class vehicleSkinShopCfg {};
        class clothing_civ {};
        class clothing_barber {};
        class clothing_faces {};
        class clothing_cop {};
        class clothing_dive {};
        class clothing_kart {};
        class clothing_reb {};
        class clothing_copdive {};
        class clothing_med {};
        class recipeDetail {};
        class titleCfg {};
        class eventCfg {};
        class loonazonCfg {};   // Loonazon drone-store catalog (client+server)
        class hornCfg {};
        class exchangeCfg {};
        class wantedChargesConfig {};
        class loginBonusCfg {};
        class sprayCanCfg {};
        class hexIconCfg {};
        class medicFireRelPositionsCfg {};
        class dynamicMapCfg {};
        class christmasTreePresentsCfg {};
        class welcomeUIConfig {};
        class vehicleModConfig;};
    class Player_Menu {file = "core\pmenu";
        class achievementSel {};
        class captureSel {};
        class capture {};
        class cellphone {};
        class cellphone_call {};
        class clientMessage {};
        class bonesText {};   // incoming Ben Bones AI text
        class dropCharge {};
        class dropItem {};
        class giveItem {};
        class giveMoney {};
        class inventory {};
        class keyDrop {};
        class keyGive {};
        class keyMenu {};
        class licenses {};
        class market {};
        class money {};
        class pardon {};
        class p_openMenu {};
        class p_updateMenu {};
        class favoriteApps {};
        class setFavApp {};
        class brightNight {};
        class sendText {};
        class settingsInit {};
        class settingsMenu {};
        class setWallpaper {};
        class wallpaperAnim {};
        class ringLoadout {};         // quick-hack loadout editor (ICEBREAKER / TAL)
        class ringLoadoutAssign {};
        class ringLoadoutDefaults {};
        class ringLoadoutMode {};     // ring-slots <-> firewall toggle  // animated wallpaper frame driver (Matrix rain)
        class showMsg {};
        class s_onSliderChange {};
        class updateMarkers {};
        class updateViewDistance {};
        class useItem {};
        class wallpaper {};
        class wantedMenu {};
        class wantedList {};
        class wantedInfo {};
        class gangListMenu {};    // owner 2026-06-13: press-9 gangs-online roster
        class gangListSelect {};
        class getMyStats {};
        class titleMenu {};
        class titleSel {};
        class s_onComboChange {};
        class p_openLightSwitchBox {};};
    class Phone {file = "core\phone";
        class browser {};         // phone web browser "LoonyNet" (open/go/url/nav/back)
        class browserSites {};    // url -> page content registry (add fake sites here)
        class loonerReceive {};   // Looner microblog: server pushes the feed to the client
        class loonazonTrack {};   // Loonazon: server pushes the delivery van pos -> buyer-only local map marker
        class loonazonPirate {};  // Porch Pirate talent: 30s van pings -> local marker (client filters by talent 260)
        class loonazonApp {};     // the standalone LOONAZON app (dialog 987600): categories + cart + weight caps
    };
    class Casino {file = "core\casino";
        class casinoApp {};       // phone-app entry -> game-select landing
        class casinoBanConfirm {}; // self-exclusion confirm + apply (Settings "Casino Ban")
        class blackJack {};       // blackjack client controller + server "render" callback
        class blackJackReceive {}; // owner-2-gated BANK credit (server-initiated only)
        class casino {};          // client controller for Coin Flip/Wheel/Slots/Roulette/Hi-Lo + landing + server "result" render
        class casinoReceive {};   // owner-2-gated BANK credit for the five simple games (server-initiated only)
    };
    class Functions {file = "core\functions";
        class lzEject {};   // server orders a rider out of a Loonazon van (moveOut where the unit is local)
        class accType {};
        class priceOv {};
        class marketFactor {};
        class achievementGrant {};
        class achievementScan {};
        class actionKeyHandler {};
        class actionUIHandler {};
        class adjustInventoryArray {};
        class autoRun {};
        class autoDrive {};
        class calWeight {};
        class calWeightDiff {};
        class clearVehicleAmmo {};
        class checkMailbox {};
        class clientWireTransfer {};
        class createLMarker {};
        class createVehicleLocal {};
        class dropItems {};
        class dynamicMapSystem {};
        class dynamicMapVehicleFix {};
        class getDiscount {};
        class earthquakeClient {};
        class animSync {};
        class pushFunction {};
        class evidenceDefense {};
        class gangBoatDefense {};
        class enableActions {};
        class slingAndMass {};
        class emote {};
        class fetchCfgDetails {};
        class compZones {};   // owner 2026-07-10: composition-zone loader (compositions\zones.sqf; proximity-streamed local props)
        class maldenBullets {};   // owner 2026-07-11: heavy-caliber hit reporter for Malden Makeover shells (client sensor)
        class inputMenu {};
        class fetchDeadGear {};
        class fetchVehInfo {};
        class fireMissile {};
        class fetchWeaponMagazines {};
        class fixUniform {};
        class filterChat {};
        class profanityFilter {};
        class forceDropItem {};
        class isUnitCopilot {};
        class getRankString {};
        class giveDiff {};
        class giveGift {};
        class handleAnim {};
        class handleInv {};
        class handleItem {};
        class hudSetup {};
        class hudUpdate {};
        class index {};
        class initStats {};
        class inventoryDifference {};
        class jump {};
        class zoneCreator {};
        class cleanName {};
        class isNumber {};
        class isUIDActive {};
        class KRON_Strings {};
        class listNBoxSort {};
        class loadDeadGear {};
        class loadGear {};
        class nearestDoor {};
        class numberText {};
        class playerTags {};
        class ownerMode {};
        class invisBag {};
        class policeRequired {};
        class pullOutVeh {};
        class pushObject {};
        class radiationZone {};
        class receiveItem {};
        class receiveMoney {};
        class saveGear {};
        class setAggressive {};
        class setVehicleIdle {};
        class setTitle {};
        class setUnconscious {};
        class sideString {};
        class showBroadcast {};
        class simDisable {};
        class slingParachute {};
        class statArrUpdate {};
        class flushStats {};   // singleevh.md Phase 3a: durable stat-buffer flush (life_fnc_flushStats)
        class stripDownPlayer {};
        class tacticalPing {};
        class tazeSound {};
        class trackMarkers {};
        class wantedListAdd {};
        class updateRemoteStat {};
        class uavCinematic {};
        class welcomeCredits {};
        class isAlphanumeric {};
        class directCall {};
        class notifyServerRestart {};
        class manageSidechat {};
        class calculateWarRating {};
        class handleChair {};
        class phoneCallClient {};
        class activeFederalEvent {};
        class inZone {};
        class dropPhysicalItem {};
        class getTitleColor {};
        class getDateUTC {};
        class formatContainer {};
        class applyRandomBillboardTexture {};
        class duelArenaSystem {};
        class clientMobileHQ {};};
    class gangfort {file = "core\gangfort";
        class initGangFortClient;
        class initGangBoatClient;
        class gangFortHud;
        class gangBoatHud;
        class captureGangFort;   // owner 2026-06-17: capture the fortress flag (king-of-the-hill scoring)
    };
    class quests {file = "core\quests";
        class questMenu {};
        class questSel {};
        class questAccept {};
        class handleQuest {};
        class createQuestLoot {};
        class questSync {};
        class questPlayerKilled {};};
    class Network {file = "core\functions\network";
        class botKick {};
        class broadcast {};
        class corpse {};
        class MP {};
        class netSetVar {};
        class setFuel {};
        class setTexture {};
        class soundDevice {};
        class playSound {};
};
    class Civilian {file = "core\civilian";
        class addInfamy {};
        class civLoadout {};
        class craftRecipe {};
        class doPrisonBreak {};
        class airplaneDrugRunner {};
        class execute {};
        class factory {};
        class jailPlayer {};
        class jailMe {};
        class policeRecruit {};
        class removeLicenses {};
        class robPerson {};
        class robReceive {};
        class skyDive {};
        class cookMeat {};
        class laserJoin {};
        class initLaser {};
        class civRepairBuilding {};
        class ufoCrash {};
        class trialSystem {};
        class harvestScalp {};
        class tutorialNewPlayer {};
        class loginBonusInit {};
        class loginBonusGive {};
        class executionerMove {};
        class timeTrial {};
        class passiveMode {};};
    class Vehicle {file = "core\vehicle";
        class addVehicle2Chain {};
        class colorVehicle {};
        class openVehDoors {};
        class deviceMine {};
        class handleVehicles {};
        class lockVehicle {};
        class removeVehKey {};
        class vehicleOwners {};
        class vehicleWeight {};
        class vInteractionMenu {};
        class horn {};
        class prepareVehicle {};
        class refuelVehicle {};
        class tractorMine {};
        class checkPlate {};
        class forceVehicleEnter {};};
    class Inventory {file = "core\inventory";
        class loonazonOpen {};   // Loonazon box -> house-storage trunk menu (lean fork of openInventory, no DB)
        class openInventory {};
        class refreshInventory {};
        class storeInventory {};
        class takeInventory {};
        class physicalInventoryWeight {};
        class moveItemInventory {};
        class refreshAdminInventory {};
        class dropTrunkInventory {};
        class dropPlayerInventory {};
        class vehSwapItem {};
        class houseToVehicleStore {};
        class vehicleToHouseStore {};};
    class Cop {file = "core\cop";
        class talAction {};      // TAL OS wedge dispatcher (APD visor ring) -- talos.md
        class talTrace {};       // ICE TRACE ping receiver (passive -- no wedge)
        class talHome {};        // TAL OS app grid (APD phone terminal)
        class talHomeLaunch {};  // TAL OS grid tile dispatcher
        class talMarker {};      // TAL dispatch pin / backup beacon (local marker)
        class talFieldReply {};  // runs on the SUSPECT: returns breathalyser/drug screen
        class talLog {};         // TAL audit trail -> TON_fnc_logIt
        class addPrestige {};
        class applyCharge {};
        class bountyReceive {};
        class copSplitReceive {};
        class copInteractionMenu {};
        class copLights {};
        class copLoadout {};
        class copSearch {};
        class copSiren {};
        class crimeCharge {};
        class selfCharge {};
        class copUAV {};
        class detectiveGear {};
        class swatEnroll {};
        class disarmed {};
        class disarmAction {};
        class removeFiringPin {};
        class breakGuns {};
        class fixFiringPin {};
        class earnPrestige {};
        class doorAnimate {};
        class impoundAction {};
        class jailCL {};
        class licenseCheck {};
        class licensesRead {};
        class nonLethal {};
        class radar {};
        class reGear {};
        class repairDoor {};
        class restrain {};
        class revokeLicense {};
        class revokeLicenseAction {};
        class searchClient {};
        class seizePlayerIllegal {};
        class seizePlayerIllegalAction {};
        class seizeToVehicle {};
        class seizeIllegalTent {};
        class seizeObjects {};
        class sirenLights {};
        class speedCamera {};
        class trafficCams {};
        class spikeStripEffect {};
        class stopPrisonBreak {};
        class ticketGive {};
        class ticketPaid {};
        class ticketPay {};
        class ticketPrompt {};
        class vehBaseSeize {};
        class houseInvSearch {};
        class houseInvSeize {};
        class vehicleInvSearch {};
        class vehicleInvSeize {};
        class giveMedkits {};
        class requestBackup {};
        class requestSuperior {};
        class dispatchClientMessage {};
        class toggleSwatLights {};};
    class Gangs {file = "core\gangs";
        class createGang {};
        class gangInviteMenu {};
        class cartelEventCapture {};
        class gangCreated {};
        class gangMenu {};
        class initGang {};
        class setGangGrpLdr {};
        class setGangHouse {};
        class populateGangInfo {};
        class invite2Gang {};
        class captureCartel {};
        class getCartelRubber {};
        class gangRanks {};
        class clientGangLeader {};
        class gangDisbanded {};
        class gangDisband {};
        class gangInvite {};
        class gangKick {};
        class gangLeave {};
        class gangNewLeader {};
        class getOnlineMembers {};
        class manageRank {};
        class removeGangHouse {};
        class captureTurf {};
        class acceptWar {};
        class gangWarsMenu {};
        class warStatus {};
        class gangWarsMenuLBChange {};
        class warChallenged {};
        class surrenderWar {};
        class challengeWar {};
        class changeGangHouse {};
        class setGangHouseForMembers {};
        class gangSetOwner {};
        class gangTransferOwner {};
        class setGangTag {};
        class gangGarageAdd {};
        class gangGarageLBChange {};
        class gangGarageMenu {};
        class gangGaragePull {};
        class gangGarageRepairRefuel {};
        class gangGarageDestroy {};
        class captureGangBoatFlag {};};
    class Gov {file = "core\gov";
        class getGovTax {};
        class govCandidateMenu {};
        class govLawMenu {};
        class govVotingMenu {};
        class govSystem {};
        class govPardon {};
        class govBank {};
        class govBankWithdraw {};};
    class PLB_Groups12 {file = "core\groups";
        class groupMenu {};
        class groupBrowser {};
        class createGroup {};
        class groupManagement {};
        class clientGroupKick {};
        class clientGroupLeader {};
        class joinGroup {};
        class kickGroup {};
        class leaveGroup {};
        class lockGroup {};
        class setGroupLeader {};
        class unlockGroup {};
        class setGroupPass {};
        class setGroupRestrainMarker {};};
    class Shops {file = "core\shops";
        class atmMenu {};
        class gangAtmMenu {};
        class buyClothes {};
        class changeClothes {};
        class changeVision {};
        class chopShopClaim {};
        class chopShopMenu {};
        class chopShopSelection {};
        class chopShopSell {};
        class clothingFilter {};
        class clothingMenu {};
        class simpleShopBuySell {};
        class simpleShopSelection {};
        class vehicleSkinShopMenu;
        class vehicleSkinShopBuy {};
        class vehicleSkinShopSelection {};
        class vehicleShopBuy {};
        class vehicleShopLBChange {};
        class vehicleShopMenu {};
        class virtualShopManage {};
        class sellVehicleInv {};
        class virtualShopMenu {};
        class virtualShopUpdate {};
        class virtualShopPopulate {};
        class ncShop {};        // life_fnc_ncShop -- NIGHT CITY weapon shop (ui branch; rebelwep routes here)
        class vehicleShopMods {};   // ui branch: fill the vehicle-shop buy-time configure grid
        class vehicleShopTotal {};  // ui branch: recompute the vehicle-shop TOTAL readout
        class weaponShopBuy {};
        class weaponShopFilter {};
        class weaponShopMenu {};
        class weaponShopSelection {};};
    class Loadout {file = "core\shops\loadouts";
        class chooseLoadoutCurrency {};
        class deleteLoadout {};
        class equipLoadout {};
        class getLoadoutItems {};
        class getLoadoutPrice {};
        class getVirtualInv {};
        class loadoutMenu {};
        class loadoutPreview {};
        class loadoutSelection {};
        class saveLoadout {};};
    class Talents {file = "core\talents";
        class buyTalentPoint {};   // purchase an extra talent point ($1m, +$500k each) past the free cap
        class talentPointsRecv {}; // server -> client: purchased-point count (login + after each buy)
        class addExperience {};
        class populatePrestigeTree {};
        class populateTalentTree {};
        class calGangTalents {};
        class calTalents {};
        class learnPrestige {};
        class learnTalent {};
        class prestigeInfo {};
        class prestigeMenu {};
        class respec {};
        class talentInfo {};
        class talentMenu {};
        class verifyTalents {};};
    class Tutorials {file = "core\tutorial";
        class tutorialSel {};
        class tutorialStart {};
        class handleTutorial {};};
    class Items {file = "core\items";
        class adrenalineShot {};
        class supermale {};
        class miningAssemble {};    // build a mining rig from components
        class grabComponent {};     // grab a crypto component from an event crate   // Super Male Vitality supplement (sprint + damage-resist buff)
        class adrenalineShotEffect {};
        class alarm {};
        class bloodbag {};
        class boltcutter {};
        class recoverWreck {};
        class debitCard {};
        class applyAtmSkimmer {};   // plant a $50k ATM skimmer on the physical ATM you're facing (fn_atmSkimSRV backend)
        class atmSkimOwner {};      // owner UID of the skimmer on an ATM (reads synced PLB_atmSkim by position)
        class jerryRefuel {};
        class lockpick {};
        class cyberdeck {};        // LooneyBin 2026-07-18: Cyberdeck launcher (replaces lockpick+drill)
        class cyberdeckSeq {};     // Sequence Breach minigame controller (blocking)
        class cyberdeckPick {};    // Sequence Breach grid-click handler
        class cyberdeckTerm {};    // Terminal Breach minigame controller (blocking)
        class cyberdeckSubmit {};  // Terminal Breach ENTER handler
        class cyberdeckIgnition {}; // Hack Ignition -- temp engine-fry on any vehicle (cdfeatures #3)
        class cyberdeckATM {};      // ATM jackpot hack (cdfeatures #2)
        class cyberdeckWardrive {}; // Wardrive scan -- ping nearby hackable targets (cdfeatures #8)
        class cyberdeckHome {};     // Cyberdeck HOME MENU (Custom 20 app-grid launcher)
        class cyberdeckLaunch {};   // Home-menu hack dispatcher
        class cyberdeckBuyModule {};
        class qhRecycle {};         // Chip Recycler: melt 3 hack chips -> 1 random Tier-3 chip (Kabuki scroll)
        class cyberdeckRing {};   // VR-goggle SHIFT+Y quick-hack radial // Tech-shop permanent module purchase (client deduct -> server grant)
        class cyberdeckBank {};     // Bank Vault hack (home-menu entry, mirrors the scroll action)
        class qhCast {};            // quickhack caster -- validate + hand off to TON_fnc_qhSRV
        class qhEffect {};          // quickhack victim-side effect + trace-window arm
        class qhTrace {};           // victim trace-back (scroll action inside the 10s window)
        class qhTraceResult {};     // trace outcome (server -> both parties)
        class qhPing {};            // server-streamed ping/pursuit map marker
        class qhEyeSpy {};          // Eye Spy CCTV feed viewer (server picks the camera -> client renders it)
        class qhEngineKill {};      // setHit an engine on the vehicle's OWNER (occupied cars are driver-local)
        class qhChauffeur {};       // Chauffeur Override victim-side drive + wrestle/kill-switch/bail controller
        class qhPuppet {};          // Puppet Strings hacker-side deck-dive: slump body + capture/publish input
        class qhConsole {};         // ICEBREAKER/TAL OS quickhack console -- populate + theme + nearby scan
        class qhConsolePick {};     // console: tap a NEARBY row -> lock PLB_cdTarget + paint scope readout
        class qhConsoleFire {};     // console: tap a loadout tile -> cast that slot via life_fnc_qhCast
        class qhConsoleLoad {};     // console: toggle a library chip in/out of the 6-slot loadout (persist, ids only)
        class qhCuffHack {};        // Cuff Cracker: sequence-breach your own restraints (SHIFT+Y while cuffed)
        class qhDock {};            // VISOR DOCK launcher (SHIFT+Y): gate + capture target + open vr_dock
        class qhDockFill {};        // VISOR DOCK populate (dialog onLoad): theme, HUD, lock, magnifying icons
        class openGift {};
        class nitro {};
        class redgull {};
        class spikeStrip {};
        class speedbomb {};
        class vehAmmo {};
        class pickupObject {};
        class tent {};
        class placeObject {};
        class holdObject {};
        class furnitureAction {};
        class tracker {};
        class protest {};
        class cocaine {};
        class medKit {};
        class ignitionBomb {};
        class boomBox {};
        class sprayPaint {};
        class remoteExplosive {};
        class remoteEngineKillSwitch {};};
    class exchange {file = "core\exchange";
        class exchangeMenu {};
        class exchangeMenuFilter {};
        class exchangeMenuManage {};
        class exchangeMenuSelection {};
        class exchangeStorageMenu {};
        class exchangeStorageMenuFilter {};
        class exchangeStorageMenuManage {};
        class exchangeStorageMenuSelection {};
        class exchangeCreateListing {};};
    class Dialog_Controls {file = "dialog\function";
        class adminEventMenuLB {};
        class animateDialog {};
        class bankDebit {};
        class bankDeposit {};
        class bankTransfer {};
        class bankWithdraw {};
        class gangBankHist {};
        class gangDeposit {};
        class gangWithdraw {};
        class createDialog {};
        class createMessage {};
        class deleteMessage {};
        class displayHandler {};
        class doubleClickItem {};
        class factoryLBChange {};
        class handleMessage {};
        class initMessageHUD {};
        class insertElement {};
        class pickupSelected {};
        class menuPickupItems {};
        class prisonBreakQuery {};
        class setMapPosition {};
        class spawnConfirm {};
        class statsMenu {};
        class statsFilter {};
        class spawnMenu {};
        class spawnPointCfg {};
        class spawnPointSelected {};
        class vehicleGarageLBChange {};
        class vehicleGarageMenu {};
        class vehicleGaragePull {};
        class vehicleGarageSell {};
        class deathCamera {};
        class redeployMenu {};
        class garageModMenu {};
        class garageBuyMods {};
        class vehicleGarageRepairRefuel {};
        class guiMessage {};
        class serverInfoMessages {};
        class sprayPaintMenu {};
        class coloredHexes {};
        class coloredHexesMenu {};
        class titleColorMenu {};
        class ctrlCreate {};
        class loadingScreen {};
        class welcomeUI {};
        class garageModComboChange {};};
    class LoonyBin_EVH {file = "evh";
        class getInMan {};
        class getOutMan {};
        class handleDamage {};
        class handleDowned {};
        class handleVehicleDamage {};
        class handleTagged {};
        class inventoryClosed {};
        class inventoryOpened {};
        class onFired {};
        class onPlayerKilled {};
        class suicideVest {};
        class handleFlashbang {};
        class mouseDownHandler {};
        class mouseUpHandler {};
        class onPlayerRespawn {};
        class onTakeItem {};
        class onPutItem {};
        class seatSwitchedMan {};
        class onGameInterrupt {};
        class keyDownHandler {};
        class keyUpHandler {};
        class handleChatMessage {};};
    class LoonyBin_OEF {file = "evh\eachFrame";
        class addPerFrameHandler {};
        class onEachFrame {};
        class removePerFrameHandler {};};
    class AdminEvents {file = "core\adminEvents";
        class adminEventMenu {};
        class eventGunGameClient {};
        class funGunClient {};   // owner admin-menu fun guns (server->client effect)
        class eventGunGameKill {};
        class eventBRClient {};
        class eventGraveyardClient {};
        class eventPurgeClient {};
        class eventSmirnoffJumpingClient {};
        class handleAdminEvent {};};
    class drugs {file = "core\drugs";
        class attachSmoke {};
        class crank {};
        class drugUsed {};
        class heroin {};
        class meth {};
        class overdose {};
        class pcp {};
        class drinkAlcohol {};
        class cannabisItems {};
        class greenhouse {};
        class barrel {};
        class lsd {};}};
class NPC_Core {tag = "NPC";
    class animation {file = "npcs\animation";
};
    class NPCs {file = "npcs";
        class applyCop {};
        class CH7 {};
        class chopshop {};
        class civDMV {};
        class civDrugRunner {};
        class civFactory {};
        class civHuntingWeapon {};
        class civProcessItem {};
        class civRebelVehicles {};
        class civRebelWeapon {};
        class civSkiptracer {};
        class civTurfShops {};
        class civTurfVehicles {};
        class civTurfDealer {};
        class civVehicles {};
        class civTimeTrials {};
        class clinics {};
        class copGetBounty {};
        class copShops {};
        class copVehicles {};
        class courthouse {};
        class duelArena {};
        class gasStations {};
        class governor {};
        class missionDP {};
        class medVehicles {};
        class prison {};
        class shops {};
        class tourism {};
        class civConvoy {};
        class civExchange {};
        class civFungi {};
        class civJewelry {};
        class civGangFortressVehicles {};
        class civGangFortressWeapons {};
        class civGangFortressDealer {};};};
class ChatcomFiles {tag = RWT;
    class chatcom {file = "core\chatcom\chatfuncs";
        class chatcomExec {};
        class chatcomProcess {};
        class chatcomVerify {};};};
	class LooneyBin_Compat {tag = "life";
		class Compat {file = "core\compat";
			// reverse-drift: mission callbacks the 2017 server calls (2020 renamed/removed)
			class GEMenu {};
			class addStatistic {};
			class addToGang {};
			class applyWeather {};
			class battlEyeReceive {};
			class calcPrice {};
			class candidate {};
			class candidates {};
			class capNotice {};
			class createDispatch {};
			class createVehicle {};
			class finishDispatch {};
			class forceJoinGroup {};
			class gangBank {};
			class gangMembersReceive {};
			class getBuildID {};
			class getQuantity {};
			class itemDemand {};
			class jackpot {};
			class jail {};
			class jailSys {};
			class joinRace {};
			class localChatMessage {};
			class newDispatch {};
			class newWaypoint {};
			class playKaraoke {};
			class prisonBreaker {};
			class raceWon {};
			class receiveOwner {};
			class reqsync {};
			class sessionReceive {};
			class setBounty {};
			class setRestrained {};
			class setReturnValue {};
			class startPrisonBreak {};
			class startRace {};
			class swatDeactivate {};
			class swatDispatch {};
			class swatDispatched {};
			class trialBegin {};
			class uC {};
			class vehicleColorCfg {};
			class vehicleExit {};
			class wantedPardon {};
			class wantedPerson {};};};
