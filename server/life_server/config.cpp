class BIS_AddonInfo
{
author="76561190000000039";
timepacked="1472138527";
};

class DefaultEventhandlers;
class CfgPatches 
{
class life_server
{
units[] = {"C_man_1"};
weapons[] = {};
requiredAddons[] = {"A3_Data_F","A3_Soft_F","A3_Soft_F_Offroad_01","A3_Characters_F"};
fileName = "life_server.pbo";
author[]= {"Loonybin"}; 
};
};

class CfgFunctions
{
class STS_DB
{
tag = "DB";
class MySQL
{
file = "\life_server\core\DB";
class insert{};
class query{};
class update{};
class numberSafe {};
class mresArray {};
class mresToArray {};
class flushPlayer {};
class flushAllPlayers {};
class asyncQuery {};
class processQueue {};
class insertVehicle {};
class queryStock {};
class queryVehicle {};
class queryConfig {};
class insertHouse {};
class updateHouse {};
class deleteHouse {};
class deleteVehicle {};
class queryHouses {};
class queryStorage {};
class insertStorage {};
class updateStorage {};
class insertGang {};
class queryGangs {};
class updateGang {};
class deleteGang {};
class queryGangMembers {};
class gangMember {};
class queryCaptures {};
class updateCaptures {};
class updateTurf {};
class uC {};
class updateConfig {};
class updateVehicle {};
class saveVehicles {};
class restoreVehicles {};
class insertWanted {};
class deleteWanted {};
class setDeadState {};
class bool{};
class insertRequest{};
class queryRequest{};
class updateRequest{};
class updatePartial{};
};
};

class Life_System
{
tag = "life";
class Wanted_Sys
{
file = "\life_server\core\wantedsys";
class wantedFetch {};
class wantedPerson {};
class wantedBounty {};
class wantedPardon {};
class createDispatch {};
class swatDispatch {};
class setRestrained {};
};

class Jail_Sys
{
file = "\life_server\core\jail";
class jailSys {};
class startPrisonBreak {};
class trialRequest {};
class trialBegin {};
class juryVote {};
};
};

class STS_System
{
tag = "PLB";
class System
{
file = "\life_server\core\system";
class doRestart {};
class scheduler {};   // singleevh.md Phase 1: single-wheel server task scheduler (PLB_fnc_schedule/unschedule/schedulerStart/schedulerDump)
class resetFed {};   // owner 2026-06-16: admin live Federal Reserve / bank lockout reset (debug `call PLB_fnc_resetFed` or `!srv resetfed`)
class fedLockdown {};   // owner 2026-06-16 (#312): re-lock the fed domes/safes/gates to a clean robbable state (called by resetFed)
class fedEventActive {};   // owner 2026-06-16 (#302): server-authoritative federal-event mutual-exclusion check
class playerDisconnected {};
class setOwnerID {};
class query {};
class queryHouses {};
class houseContainerPos {};
class initEvent {};
class addToEvent {};
class add {};
class update {};
class manageRadio {};
class managePhone {};
class cleanup {};
class cleanupHouses {};
class cleanupStorage {};
class huntingZone {};
class spawnCaptures {};
class swatRegistered {};
class setWaypoint {};
class reduceMarket {};
class marketTick {};
class spawnVehicle {};
class addVehicle2Chain {};
class removeStorage {};
class experienceReq {};
class getVehicles {};
class vehicleStore {};
class vehicleCreate {};
class vehicleDelete {};
class vehicleDead {};
class recoverWreck {};
class joinRace {};
class getHouses {};
class addToLottery {};
class spikeStrip {};
class logIt {};
class govMaint {};
class rebootMonitor {};
class patchServer {};
class hardRestart {};
class weatherSync {};
class laserQueue {};
class laserTag {};
class laserEliminated {};
class getGuid {};
class getIpAddress {};
class placeStorage {};
class addStorage {};
class receiveHouses {};
class checkHacks {};
class chopShopSell {};
class igiInit {};
class robStore {};
class spawnGoldBars {};
class isUIDActive {};
class queryGangs {};
class updateGang {};
class receiveGangs {};
class gangMember {};
class monitorCaptures {};
class updateGangBank {};
class uC {};
class flipVehicle {};
class addObjectWhitelist {};
class insured {};
class updateWar {};
class visible {};
class getAdmin {};
class createP3DObjects {};
};

class Bank_Sys
{
file = "\life_server\core\bank";
class fedAlarm {};
class bankDrillVault {};
};

};
class GEServer
{
tag = "KBW";
class GE
{
file = "\life_server\core\GE";
class updateMailbox {};
class fixBadOffers {};
};
};
	class TONServer
	{
		tag = "TON";
		// LooneyBin: EXISTS aliases -- same 2017 files exposed under TON_fnc_* for the 2020 client.
		class System_TON
		{
			file = "\life_server\core\system";
			class flipVehicle {};
			class getVehicles {};
			class igiInit {};
			class laserEliminated {};
			class laserQueue {};
			class logIt {};
			class updateWar {};
			class vehicleCreate {};
			class vehicleDead {};
			class recoverWreck {};
			class vehicleDelete {};
			class vehicleStore {};
			class visible {};
		};
		class MySQL_TON
		{
			file = "\life_server\core\DB";
			class insertGang {};
		};
		class Jail_TON
		{
			file = "\life_server\core\jail";
			class jailSys {};
		};
		class Wanted_TON
		{
			file = "\life_server\core\wantedsys";
			class wantedBounty {};
			class wantedFetch {};
			class wantedPardon {};
			class claimBodybagSRV {};   // LooneyBin: claim a combat-log fugitive bodybag (jail offline + pay)
		};
		class Renamed_TON
		{
			file = "\life_server\core\TON";
			// LooneyBin: 59 renamed-layer wrappers -> 2017 fns. See docs/TON_RENAMED_REVIEW.md.
			class add2Lotto {};
			class addHouse {};
			class adminDelVeh {};
			class adminPlayerQuerySRV {};
			class bankRobbery {};
			class blackJackSRV {};   // LooneyBin: Casino phone app -- blackjack server engine (fn_blackJackSRV.sqf)
			class casinoSRV {};      // LooneyBin: Casino -- Coin Flip/Wheel/Slots/Roulette/Hi-Lo engine (fn_casinoSRV.sqf)
			class bulkAdd {};
			class cartelSRV {};
			class changeServCycle {};
			class changeWeather {};
			class checkPlayer {};
			class createAdminVeh {};
			class eventParticipants {};
			class exchangeSystemSRV {};
			class fedRobbery {};
			class gangBank {};
			class gangFortressSRV {};
			class houseFurnitureSRV {};
			class loveBombSRV {};
			class adminKickBan {};
			class economySRV {};
			class garageCount {};
			class getGangInfo {};
			class getID {};
			class getStatsArr {};
			class govSystemSRV {};
			class greenhouseSRV {};
			class barrelSRV {};
			class stimmySRV {};
			class fedOverrideSRV {};
			class handleDispatch {};
			class handleJail {};
			class handlePhoneCallSRV {};
			class handlePhoneMsg {};
			class handlePrisonBreak {};
			class handleWireTransfer {};
			class huntingGrounds {};
			class initHouseInventory {};
			class processMailbox {};
			class registerSwat {};
			class removeGang {};
			class setCleanTime {};
			class setGangTagSRV {};
			class setJail {};
			class spawnPhysicalItem {};
			class srvChopShopSell {};
			class srvObjectMonitor {};
			class srvRobStore {};
			class srvSellHouse {};
			class srvSellVehicle {};
			class srvSpikeStrip {};
			class statTableUpdate {};
			class timeTrialSRV {};
			class transferGangOwnerSRV {};
			class transferHouse {};
			class trialSystemSRV {};
			class updateGangTalents {};
			class updateGangMem {};
			class updateHousePrice {};
			class updateHouseTrunk {};
			class updateProperty {};
			class updateVehicleMods {};
			class varPersist {};
			class vehOwnerSwap {};
			class vehicleRepairSRV {};
			class vehicleSetActive {};
			class dongClient {};
			class adminMsg {};
			class wantedAdd {};
			class wantedSyncList {};
			class wantedRemove {};
		};
		class New_TON
		{
			file = "\life_server\core\TON";
			// LooneyBin: NEW 2020 server fns (no 2017 source). Stubs -> upgrade to full impl.
			class addGangHouse {};
			class airDrop {};
			class airDropMedic {};
			class bankLightHouseToggle {};
			class bldgUpdateKeys {};
			class chopTreeSRV {};
			class copUAVSRV {};
			class registerForeskin {};
			class loonerSRV {};      // LooneyBin: Looner microblog (feed/post)
			class newsPush {};       // LooneyBin: DataBattle living newspaper -- event -> headline + Bones loon
			class robotaxiSRV {};    // LooneyBin: Robotaxi -- spawn/seat/despawn the autopilot cab
			class loonazonSRV {};    // Loonazon drone delivery
			class loonazonBox {};    // Loonazon box spawner (shared: delivery + robbery break-open)
			class atmSkimSRV {};    // ATM skimmer backend (apply/remove/credit/load)
			class talentPointsSRV {};    // buyable talent points (load/buy, talent_points table)
			class airdropEventSRV {}; // public rebel weapon airdrops
			class eventRoutes {};    // shared hand-drawn route geometry (supply bomber A/B + smuggler loop)
			class apStress {};       // DEV-ONLY: HC-autopilot map-wide stress/coverage harness (strip before live)
			class eventRogueVanSRV {};   // world event: rogue Loonazon van (shoot engine -> jackpot)
			class eventIceCreamSRV {};   // world event: ice cream truck of doom (loot stops + random detonation)
			class eventSupplyBomberSRV {}; // world event: supply bomber carpet loot-drop
			class eventCropDusterSRV {}; // world event: crop duster gas cloud (buff/debuff zone)
			class eventBlackoutSRV {}; // world event: city blackout
			class loonstreetsSRV {};  // loonstreets.com data feed
			class miningSRV {};       // LoonyCoin mining rigs
			class cyberdeckSRV {};
			class talSRV {};          // TAL OS (APD) backend -- records lookup
			class iceTrace {};        // ICE TRACE -- single authority on whether a hack is quiet
			class qhSRV {};           // quickhack authority (server-timed upload channel)    // Cyberdeck hacks -- house-door relock + owner-notify (fed/bank later)
			class ndSRV {};           // New Drachma authority (server-side wallet, DECIMAL ledger)
			class ndCreditSrv {};     // New Drachma server-internal trusted credit (NOT in CfgRE by design)
			class qhLootSRV {};       // quickhack loot rolls (fed/cartel) -- consumables + rare hack chips
			class qhDeadmanSRV {};    // Dead Man's Clutch: server-side sever + consume when a hijack lands
			class bonesDM {};         // Ben Bones DM router
			class bonesDeliver {};    // Ben Bones reply delivery poll
			class sportsbookSRV {};  // LooneyBin: LoonyBets -- place a parimutuel bet (client->server)
			class sportsbookResolve {}; // LooneyBin: LoonyBets engine -- boot/publish/resolve (server-only)
			class toggleNewbieRoles {};
			class ownerSpangle {};
			class radioSRV {};
			class wantedChargesConfig {};
			class changeGangHouseSRV {};
			class convoyRobbery {};
			class copSplit {};
			class createItem {};
			class createTimeTrialVehSRV {};
			class discordEmbed {};
			class doBuySkin {};
			class duelArenaSystemSRV {};
			class easterSeasonalEvent {};
			class enableCoPilot {};
			class endConvoyRobbery {};
			class eventBRSRV {};
			class eventGraveyardSRV {};
			class eventGunGameSRV {};
			class funGunSRV {};      // LooneyBin: owner admin-menu FUN GUNS (Lynx rampage / submarine cannon)
			class eventPurgeSRV {};
			class eventChemtrailSRV {};   // world event: chemtrail flyover
			class eventBugInvasionSRV {}; // world event: bug invasion horde
			class eventLizardPoliceSRV {};// world event: lizard police
			class eventSmugglerBoatSRV {};// world event: smuggler speedboat contraband run
			class eventSmirnoffJumpSRV {};
			class evidenceAppend {};
			class evidenceTruck {};
			class fetchLoadouts {};
			class gangBHistory {};
			class gangGarageAddSRV {};
			class gangGarageCount {};
			class gangGarageGetVehicles {};
			class gangGarageSetActive {};
			class gangGarageStore {};
			class handleLoadouts {};
			class handleTimer {};
			class houseTaxSRV {};
			// owner 2026-07-14: RE-REGISTER the 7/11 malden-migration house fns dropped from config.cpp
			// (git<->on-box divergence) -- fn_*.sqf exist but were uncompiled => malden makeover / storage
			// vault / house rename / shed helipad / intake all silently dead server-side.
			class maldenSRV {};       // Malden Makeover apply (base<->Argo variant)
			class tagHousesSRV {};    // house ownership tagging + malden-skin boot restore
			class storageVaultSRV {}; // house storage vault
			class renameHouseSRV {};  // house rename
			class shedHelipadSRV {};  // shed helipad upgrade
			class intakeSRV {};       // new-player intake
			class ignitionBombSRV {};
			class jewelryEmporiumSRV {};
			class keyManagement {};
			class lagCheck {};
			class loginBonusSRV {};
			class medSupplyPay {};
			class medSupplySpawn {};
			class medicFireSRV {};
			class medicSplit {};
			class seizeLock {};
			class loonyBinSRV {};
			class droneCharges {};
			class fedGoldSpawn {};
			class removeGangHouseSRV {};
			class repairBuildingSRV {};
			class sendKeyHouses {};
			class srvMobileHQ {};
			class srvPersistentBounties {};
			class vehAddAlarm {};
			class wantedRemoveCharge {};
			class xmasTreeAndPresentsSRV {};
		};
	};
};

class CfgVehicles
{
class Car_F;
class Plane_Base_F;
class CAManBase;
class Civilian;

class Civilian_F : Civilian
{
class EventHandlers;
class CfgMovesFatigue
{
staminaCooldown = 7;
staminaDuration = 90;
staminaRestoration = 20;
};
};

class C_man_1 : Civilian_F
{
class EventHandlers;
class CfgMovesFatigue
{
staminaCooldown = 7;
staminaDuration = 90;
staminaRestoration = 20;
};
};
};