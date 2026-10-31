class Functions {mode = 1;
    jip = 0;

    //class BIS_fnc_debugConsoleExec {allowedTargets = 2;};

    class life_fnc_colorVehicle {allowedTargets = 0;};
    class life_fnc_openVehDoors {allowedTargets = 0;};
    class life_fnc_breakGuns {allowedTargets = 0;};
    class life_fnc_corpse {allowedTargets = 0;};
    class life_fnc_lockVehicle {allowedTargets = 0;};
    class life_fnc_setTexture {allowedTargets = 0;};
    class life_fnc_simDisable {allowedTargets = 0;};
    class life_fnc_vehicleAnimate {allowedTargets = 0;};
    
    // LAUNCH (launch.md #3, 2026-06-13): BIS_fnc_debugConsoleExec REMOVED from the whitelist. mode=1 means
    // anything not listed cannot be remoteExec'd, so this closes the arbitrary-code RCE (a client could
    // remoteExec it at the server and run any code). Admins still use the debug console LOCALLY (no RE needed).
    class life_fnc_addVehicle2Chain {allowedTargets = 1;};
    class life_fnc_ndSync {          // New Drachma: server pushes authoritative balance
        allowedTargets = 1;};
    class life_fnc_ndResult {        // New Drachma: server pushes debit result
        allowedTargets = 1;};
    class life_fnc_ndCoinSwept {     // New Drachma: server pushes login coin-sweep toast
        allowedTargets = 1;};
    class life_fnc_giveGift {allowedTargets = 1;};
    class life_fnc_medicPartners {allowedTargets = 1;};
    class life_fnc_statArrUpdate {allowedTargets = 1;};
    class life_fnc_adminInfo {allowedTargets = 1;};
    class life_fnc_broadcast {allowedTargets = 1;};
    class life_fnc_trialSystem {allowedTargets = 1;};
    class life_fnc_copLights {allowedTargets = 1;};
    class life_fnc_copSearch {allowedTargets = 1;};
    class life_fnc_copSiren {allowedTargets = 1;};
    class life_fnc_giveDiff {allowedTargets = 1;};
    class life_fnc_licenseCheck {allowedTargets = 1;};
    class life_fnc_licensesRead {allowedTargets = 1;};
    class life_fnc_lightHouse {allowedTargets = 1;};
    class life_fnc_sendRequestToMedic {allowedTargets = 1;};
    class life_fnc_medicSiren {allowedTargets = 1;};
    class life_fnc_medicLights {allowedTargets = 1;};
    class life_fnc_netSetVar {allowedTargets = 1;};
    class life_fnc_pullOutVeh {allowedTargets = 1;};
    class life_fnc_receiveItem {allowedTargets = 1;};
    class life_fnc_receiveMoney {allowedTargets = 1;};
    class life_fnc_removeLicenses {allowedTargets = 1;};
    class life_fnc_revived {allowedTargets = 1;};
    class life_fnc_robPerson {allowedTargets = 1;};
    class life_fnc_robReceive {allowedTargets = 1;};
    class life_fnc_searchClient {allowedTargets = 1;};
    class life_fnc_setFuel {allowedTargets = 1;};
    class life_fnc_soundDevice {allowedTargets = 1;};
    class life_fnc_spikeStripEffect {allowedTargets = 1;};
    class life_fnc_tazeSound {allowedTargets = 1;};
    class life_fnc_ticketPaid {allowedTargets = 1;};
    class life_fnc_ticketPrompt {allowedTargets = 1;};
    class life_fnc_setGangGrpLdr {allowedTargets = 1;};
    class life_fnc_seizePlayerIllegalAction {allowedTargets = 1;};
    class life_fnc_seizeToVehicle {allowedTargets = 1;};
    class life_fnc_removeVehKey {allowedTargets = 1;};
    class life_fnc_handleMessage {allowedTargets = 1;};
    class life_fnc_renameHouseDone {   // owner 2026-07-10: server confirms a house rename -> refresh the client's marker
        allowedTargets = 1;};
    class life_fnc_playSound {allowedTargets = 1;};
    class life_fnc_setAggressive {allowedTargets = 1;};
    class life_fnc_adrenalineShotEffect {allowedTargets = 1;};
    class life_fnc_restrainAction {allowedTargets = 1;};
    class life_fnc_babyOilStrip {allowedTargets = 1;};
    class life_fnc_clientGroupLeader {allowedTargets = 1;};
    class life_fnc_clientGroupKick {allowedTargets = 1;};
    class life_fnc_revokeLicenseAction {allowedTargets = 1;};
    class life_fnc_tacticalPing {allowedTargets = 1;};
    class life_fnc_gangRanks {allowedTargets = 1;};
    class life_fnc_gangDisbanded {allowedTargets = 1;};
    class life_fnc_gangMembersReceive {allowedTargets = 1;};
    class life_fnc_gangInvite {allowedTargets = 1;};
    class life_fnc_clientGangLeader {allowedTargets = 1;};
    class life_fnc_gangCreated {allowedTargets = 1;};
    class life_fnc_doRespawn {allowedTargets = 1;};
    class life_fnc_disarmed {allowedTargets = 1;};
    class life_fnc_blindfoldClient {allowedTargets = 1;};
    class life_fnc_adminGearReceive {   // NC_PHONE: staff-menu weapon/clothing gives to the target client
        allowedTargets = 0;};
    class life_fnc_adminPlayerQuery {allowedTargets = 1;};
    class life_fnc_updateRemoteStat {allowedTargets = 1;};
    class life_fnc_horn {allowedTargets = 1;};
    class life_fnc_removeGangHouse {allowedTargets = 1;};
    class life_fnc_closeMap {allowedTargets = 1;};
    class life_fnc_unitRestrain {allowedTargets = 1;};
    class life_fnc_removeBounty {allowedTargets = 1;};
    class life_fnc_handleDowned {allowedTargets = 1;};
    class life_fnc_talMarker {allowedTargets = 0;};
    class life_fnc_talFieldReply {allowedTargets = 0;};
    class life_fnc_qhEffect {allowedTargets = 1;};
    class life_fnc_qhTraceResult {allowedTargets = 1;};
    class life_fnc_qhPing {allowedTargets = 1;};
    class life_fnc_qhEyeSpy {allowedTargets = 1;};
    class life_fnc_qhEngineKill {allowedTargets = 1;};
    class life_fnc_qhChauffeur {allowedTargets = 1;};
    class life_fnc_qhPuppet {allowedTargets = 1;};
    class life_fnc_talTrace {allowedTargets = 1;};
    class life_fnc_clientMessage {allowedTargets = 1;};
    class life_fnc_dispatchClientMessage {allowedTargets = 1;};
    class life_fnc_requestMedicalConfirmation {allowedTargets = 1;};
    class life_fnc_showBroadcast {allowedTargets = 1;};
    class life_fnc_medicRespondDone {allowedTargets = 1;};
    class life_fnc_setGroupMarker {allowedTargets = 1;};
    class life_fnc_setUnconscious {allowedTargets = 1;};
    class life_fnc_addExperience {allowedTargets = 1;};
    class life_fnc_earnPrestige {allowedTargets = 1;};
    class life_fnc_addPrestige {allowedTargets = 1;};
    class life_fnc_warStatus {allowedTargets = 1;};
    class life_fnc_warChallenged {allowedTargets = 1;};
    class life_fnc_eventGunGameClient {allowedTargets = 1;};
    class life_fnc_funGunClient {   // owner fun guns server->client effect
        allowedTargets = 1;};
    class life_fnc_eventGunGameKill {allowedTargets = 1;};
    class life_fnc_eventSmirnoffJumpingClient {allowedTargets = 1;};
    class life_fnc_evidenceSystems {allowedTargets = 1;};
    class life_fnc_attachSmoke {allowedTargets = 1;};
    class life_fnc_setGroupRestrainMarker {allowedTargets = 1;};
    class life_fnc_changeGangHouse {allowedTargets = 1;};
    class life_fnc_setGangHouseForMembers {allowedTargets = 1;};
    class life_fnc_bodybagMarker {allowedTargets = 1;};
    class life_fnc_handleQuest {allowedTargets = 1;};
    class life_fnc_gangSetOwner {allowedTargets = 1;};
    class life_fnc_medicRepairBuilding {allowedTargets = 1;};
    class life_fnc_civRepairBuilding {allowedTargets = 1;};
    class life_fnc_initKeyHouseMarkers {allowedTargets = 1;};
    class life_fnc_cannabisItems {allowedTargets = 1;};
    class life_fnc_handleAnim {allowedTargets = 1;};
    class life_fnc_boomBox {allowedTargets = 1;};
    class life_fnc_govSystem {allowedTargets = 1;};
    class life_fnc_govPardon {allowedTargets = 1;};
    class life_fnc_phoneCallClient {allowedTargets = 1;};
    class life_fnc_executionerMove {allowedTargets = 1;};
    class life_fnc_sprayPaint {allowedTargets = 1;};
    class life_fnc_questSync {allowedTargets = 1;};
    class life_fnc_medicFireClient {allowedTargets = 1;};
    class life_fnc_putInVehAction {allowedTargets = 1;};
    class life_fnc_questPlayerKilled {allowedTargets = 1;};
    class life_fnc_duelArenaSystem {allowedTargets = 1;};
    class life_fnc_storageVaultRecv {   // owner 2026-07-11: Storage Worker (server -> client: repaint panels)
        allowedTargets = 1;};
    class life_fnc_jail {   // 2026-07-23 (BUGS #556): combat-log re-jail. fn_query (server) remoteExecs this to a
        allowedTargets = 1; // reconnecting player whose uid is in life_restrained_players. mode=1 is a WHITELIST, so
    };                      // with no entry the call was silently dropped and arrest-evasion by relog worked.
    class TON_fnc_loonerSRV {allowedTargets = 2;};
    class TON_fnc_robotaxiSRV {allowedTargets = 2;};
    class TON_fnc_sportsbookSRV {allowedTargets = 2;};
    class TON_fnc_registerSwat {allowedTargets = 2;};
    class DB_fnc_insertRequest {allowedTargets = 2;};
    class TON_fnc_statTableUpdate {allowedTargets = 2;};
    class TON_fnc_fetchLoadouts {allowedTargets = 2;};
    class TON_fnc_handleLoadouts {allowedTargets = 2;};
    class DB_fnc_queryRequest {allowedTargets = 2;};
    class DB_fnc_updatePartial {allowedTargets = 2;};
    class DB_fnc_updateRequest {allowedTargets = 2;};
    class TON_fnc_jailSys {allowedTargets = 2;};
    class TON_fnc_bulkAdd {allowedTargets = 2;};
    class TON_fnc_wantedAdd {allowedTargets = 2;};
    class TON_fnc_wantedSyncList {allowedTargets = 2;};
    class TON_fnc_wantedFetch {allowedTargets = 2;};
    class TON_fnc_garageCount {allowedTargets = 2;};
    class TON_fnc_storageVaultSRV {   // owner 2026-07-11: Storage Worker (client -> server: list/pack/unpack)
        allowedTargets = 2;};
    class TON_fnc_maldenSRV {   // owner 2026-07-11: Malden Makeover apply/bullets (client -> server; owner re-verified)
        allowedTargets = 2;};
    class life_fnc_maldenSync {   // owner 2026-07-11: Malden swap client-registry fix (server -> clients)
        allowedTargets = 1;};
    class TON_fnc_intakeSRV {   // owner 2026-07-11: THE INTAKE Act 1 (client -> server: complete/skip/reset)
        allowedTargets = 2;};
    class life_fnc_intake {   // owner 2026-07-11: THE INTAKE stipend ack (server -> client; handler gates remoteExecutedOwner==2)
        allowedTargets = 1;};
    class life_fnc_parole {   // owner 2026-07-11: DIRECTOR nudge (server -> client; handler gates remoteExecutedOwner==2)
        allowedTargets = 1;};
    class life_fnc_mentor {   // owner 2026-07-11: mentor offer/link/payout messages (client<->client prompt is spoof-useless; money paths gate ==2)
        allowedTargets = 1;};
    class TON_fnc_wantedPardon {allowedTargets = 2;};
    class TON_fnc_wantedRemove {allowedTargets = 2;};
    // owner 2026-06-23: life_fnc_observe removed with SpyGlass (whitelist entry deleted so no undefined-fn remoteExec target remains).
    class TON_fnc_addHouse {allowedTargets = 2;};
    class TON_fnc_spawnPhysicalItem {allowedTargets = 2;};
    class TON_fnc_srvChopShopSell {allowedTargets = 2;};
    class TON_fnc_lagCheck {allowedTargets = 2;};
    class TON_fnc_vehicleSetActive {allowedTargets = 2;};
    class TON_fnc_getID {allowedTargets = 2;};
    class TON_fnc_getGangInfo {allowedTargets = 2;};
    class TON_fnc_changeServCycle {allowedTargets = 2;};
    class TON_fnc_getVehicles {allowedTargets = 2;};
    class TON_fnc_keyManagement {allowedTargets = 2;};
    class TON_fnc_checkPlayer {allowedTargets = 2;};
    class TON_fnc_chopTreeSRV {allowedTargets = 2;};
    class TON_fnc_copUAVSRV {allowedTargets = 2;};
    class TON_fnc_registerForeskin {allowedTargets = 2;};
    class TON_fnc_srvSellHouse {allowedTargets = 2;};
    class TON_fnc_renameHouseSRV {   // owner 2026-07-10: player house rename (owner-gated + re-sanitized server-side)
        allowedTargets = 2;};
    class TON_fnc_shedHelipadSRV {   // LooneyBin: shed helipad upgrade purchase (owner-gated server-side)
        allowedTargets = 2;};
    class TON_fnc_srvSpikeStrip {allowedTargets = 2;};
    class TON_fnc_wantedRemoveCharge {allowedTargets = 2;};
    class TON_fnc_updateHouseTrunk {allowedTargets = 2;};
    class TON_fnc_vehicleCreate {allowedTargets = 2;};
    class TON_fnc_vehicleDelete {allowedTargets = 2;};
    class TON_fnc_vehicleStore {allowedTargets = 2;};
    class TON_fnc_copSplit {allowedTargets = 2;};
    class TON_fnc_seizeLock {allowedTargets = 2;};
    class TON_fnc_vehicleDead {allowedTargets = 2;};
    class TON_fnc_recoverWreck {allowedTargets = 2;};
    class TON_fnc_logIt {allowedTargets = 2;};
    class TON_fnc_insertGang {allowedTargets = 2;};
    class TON_fnc_doBuySkin {allowedTargets = 2;};
    class TON_fnc_flipVehicle {allowedTargets = 2;};
    class TON_fnc_enableCoPilot {allowedTargets = 2;};
    class TON_fnc_fedRobbery {allowedTargets = 2;};
    class TON_fnc_fedGoldSpawn {allowedTargets = 2;};
    class TON_fnc_evidenceTruck {allowedTargets = 2;};
    class TON_fnc_adminMsg {                  // admin-menu "Message All" (client admin -> server relay)
        allowedTargets = 2;};
    class TON_fnc_discordEmbed {              // client exploit-flag reports -> server (stub logs them)
        allowedTargets = 2;};
    class life_fnc_animSync {                 // boltcutter/repair work-anim broadcast (client -> everyone)
        allowedTargets = 0;};
    class life_fnc_pushFunction {             // Push Vehicle -> runs where the vehicle is local (client -> client)
        allowedTargets = 0;};
    class TON_fnc_droneCharges {allowedTargets = 2;};
    class TON_fnc_bankRobbery {allowedTargets = 2;};
    class TON_fnc_bankLighthouseToggle {allowedTargets = 2;};
    class TON_fnc_createItem {allowedTargets = 2;};
    class TON_fnc_handlePrisonBreak {allowedTargets = 2;};
    class TON_fnc_srvRobStore {allowedTargets = 2;};
    class TON_fnc_updateProperty {allowedTargets = 2;};
    class TON_fnc_handlePhoneMsg {allowedTargets = 2;};
    class TON_fnc_handleDispatch {allowedTargets = 2;};
    class TON_fnc_updateGangMem {allowedTargets = 2;};
    class TON_fnc_removeGang {allowedTargets = 2;};
    class TON_fnc_vehAddAlarm {allowedTargets = 2;};
    class TON_fnc_srvSellVehicle {allowedTargets = 2;};
    class TON_fnc_gangBank {allowedTargets = 2;};
    class TON_fnc_gangBHistory {allowedTargets = 2;};
    class TON_fnc_setJail {allowedTargets = 2;};
    class TON_fnc_wantedBounty {allowedTargets = 2;};
    class TON_fnc_claimBodybagSRV {allowedTargets = 2;};
    class TON_fnc_addGangHouse {allowedTargets = 2;};
    class TON_fnc_visible {allowedTargets = 2;};
    class TON_fnc_setCleanTime {allowedTargets = 2;};
    class TON_fnc_updateGangTalents {allowedTargets = 2;};
    class TON_fnc_adminDelVeh {allowedTargets = 2;};
    class TON_fnc_vehOwnerSwap {allowedTargets = 2;};
    class TON_fnc_airDrop {allowedTargets = 2;};
    class TON_fnc_updateVehicleMods {allowedTargets = 2;};
    class TON_fnc_createAdminVeh {allowedTargets = 2;};
    class TON_fnc_changeWeather {allowedTargets = 2;};
    class TON_fnc_duelArenaSystemSRV {allowedTargets = 2;};
    class TON_fnc_createTimeTrialVehSRV {allowedTargets = 2;};
    class TON_fnc_timeTrialSRV {allowedTargets = 2;};
    class TON_fnc_easterSeasonalEvent {allowedTargets = 2;};
    class TON_fnc_updateHousePrice {allowedTargets = 2;};
    class TON_fnc_processMailbox {allowedTargets = 2;};
    class TON_fnc_transferHouse {allowedTargets = 2;};
    class TON_fnc_srvPersistentBounties {allowedTargets = 2;};
    class TON_fnc_varPersist {allowedTargets = 2;};
    class TON_fnc_evidenceAppend {allowedTargets = 2;};
    class TON_fnc_laserQueue {allowedTargets = 2;};
    class TON_fnc_laserEliminated {allowedTargets = 2;};
    class TON_fnc_medicSplit {allowedTargets = 2;};
    class TON_fnc_igiInit {allowedTargets = 2;};
    class TON_fnc_add2Lotto {allowedTargets = 2;};
    class TON_fnc_updateWar {allowedTargets = 2;};
    class TON_fnc_srvObjectMonitor {allowedTargets = 2;};
    class TON_fnc_getStatsArr {allowedTargets = 2;};
    class TON_fnc_bldgUpdateKeys {allowedTargets = 2;};
    class TON_fnc_toggleNewbieRoles {allowedTargets = 2;};
    class TON_fnc_ownerSpangle {allowedTargets = 2;};
    class TON_fnc_airDropMedic {allowedTargets = 2;};
    class TON_fnc_eventGunGameSRV {allowedTargets = 2;};
    class TON_fnc_eventChemtrailSRV {allowedTargets = 2;};
    // owner 2026-07-17: HC-driven admin dynamic events (admin client -> server). mode=1 whitelist:
    // without these the admin-menu remoteExec is silently denied and nothing spawns.
    class TON_fnc_eventRogueVanSRV {allowedTargets = 2;};
    class TON_fnc_eventIceCreamSRV {allowedTargets = 2;};
    class TON_fnc_eventSupplyBomberSRV {allowedTargets = 2;};
    class TON_fnc_eventCropDusterSRV {allowedTargets = 2;};
    class TON_fnc_eventSmugglerBoatSRV {allowedTargets = 2;};
    class TON_fnc_bonesDM {allowedTargets = 2;};
    class life_fnc_bonesText {allowedTargets = 1;};
    class TON_fnc_miningSRV {allowedTargets = 2;};
    class TON_fnc_cyberdeckSRV {allowedTargets = 2;};
    class TON_fnc_talSRV {allowedTargets = 2;};
    class TON_fnc_iceTrace {allowedTargets = 2;};
    class TON_fnc_ndSRV {allowedTargets = 2;};
    class TON_fnc_qhSRV {allowedTargets = 2;};
    class TON_fnc_qhLootSRV {allowedTargets = 2;};
    class TON_fnc_eventBlackoutSRV {allowedTargets = 2;};
    class TON_fnc_loonazonSRV {allowedTargets = 2;};
    class TON_fnc_eventBugInvasionSRV {allowedTargets = 2;};
    class TON_fnc_eventLizardPoliceSRV {allowedTargets = 2;};
    class TON_fnc_funGunSRV {   // owner fun guns: grant/revoke + player sub-spawn callback
        allowedTargets = 2;};
    class TON_fnc_eventBRSRV {allowedTargets = 2;};
    class TON_fnc_eventPurgeSRV {allowedTargets = 2;};
    class TON_fnc_eventSmirnoffJumpSRV {allowedTargets = 2;};
    class TON_fnc_eventParticipants {allowedTargets = 2;};
    class TON_fnc_handleTimer {allowedTargets = 2;};
    class TON_fnc_huntingGrounds {allowedTargets = 2;};
    class TON_fnc_changeGangHouseSRV {allowedTargets = 2;};
    class TON_fnc_removeGangHouseSRV {allowedTargets = 2;};
    class TON_fnc_medSupplySpawn {allowedTargets = 2;};
    class TON_fnc_medSupplyPay {allowedTargets = 2;};
    class TON_fnc_vehicleRepairSRV {allowedTargets = 2;};
    class TON_fnc_initHouseInventory {allowedTargets = 2;};
    class TON_fnc_eventGraveyardSRV {allowedTargets = 2;};
    class TON_fnc_convoyRobbery {allowedTargets = 2;};
    class TON_fnc_endConvoyRobbery {allowedTargets = 2;};
    class TON_fnc_transferGangOwnerSRV {allowedTargets = 2;};
    class TON_fnc_setGangTagSRV {allowedTargets = 2;};
    class TON_fnc_exchangeSystemSRV {allowedTargets = 2;};
    class TON_fnc_gangFortressSRV {allowedTargets = 2;};
    class TON_fnc_houseFurnitureSRV {allowedTargets = 2;};
    class TON_fnc_loveBombSRV {allowedTargets = 2;};
    class life_fnc_loveBombHeal {allowedTargets = 1;};
    class TON_fnc_adminKickBan {allowedTargets = 2;};
    class TON_fnc_economySRV {allowedTargets = 2;};
    class TON_fnc_trialSystemSRV {allowedTargets = 2;};
    class TON_fnc_repairBuildingSRV {allowedTargets = 2;};
    class TON_fnc_sendKeyHouses {allowedTargets = 2;};
    class TON_fnc_loginBonusSRV {allowedTargets = 2;};
    class TON_fnc_xmasTreeAndPresentsSRV {allowedTargets = 2;};
    class TON_fnc_ignitionBombSRV {allowedTargets = 2;};
    class TON_fnc_govSystemSRV {allowedTargets = 2;};
    class TON_fnc_greenhouseSRV {allowedTargets = 2;};
    class TON_fnc_barrelSRV {allowedTargets = 2;};
    class TON_fnc_loonyBinSRV {allowedTargets = 2;};
    class TON_fnc_handlePhoneCallSRV {allowedTargets = 2;};
    class TON_fnc_gangGarageGetVehicles {allowedTargets = 2;};
    class TON_fnc_gangGarageCount {allowedTargets = 2;};
    class TON_fnc_gangGarageAddSRV {allowedTargets = 2;};
    class TON_fnc_gangGarageStore {allowedTargets = 2;};
    class TON_fnc_gangGarageSetActive {allowedTargets = 2;};
    class TON_fnc_medicFireSRV {allowedTargets = 2;};
    class TON_fnc_jewelryEmporiumSRV {allowedTargets = 2;};
    class TON_fnc_adminPlayerQuerySRV {allowedTargets = 2;};
    class TON_fnc_srvMobileHQ {allowedTargets = 2;};
    class TON_fnc_cartelSRV {allowedTargets = 2;};
    class TON_fnc_handleWireTransfer {allowedTargets = 2;};
    class TON_fnc_houseTaxSRV {allowedTargets = 2;};
    // owner 2026-07-24: the two OWNER-ONLY control tools were registered in config.cpp and wired to admin-menu
    // buttons via life_fnc_MP, but had NO CfgRE entry -- under mode = 1 every call was silently dropped while
    // the UI reported success, so "Fed Control" and "Stimmy Checks" have never worked from in-game. (Fed
    // Override was still ACTIVE only because server_control.fedoverride=1 is restored at boot in
    // init.sqf:1013 -- but it could not be turned OFF.) Both re-verify the caller against the owner UID via
    // remoteExecutedOwner (hardened in the same commit; they previously trusted a client-passed object).
    class TON_fnc_fedOverrideSRV {allowedTargets = 2;};
    class TON_fnc_stimmySRV {allowedTargets = 2;};
    class TON_fnc_dongClient {allowedTargets = 2;};
    class TON_fnc_handleJail {allowedTargets = 2;};
    class TON_fnc_blackJackSRV {   // LooneyBin: Casino phone app -- blackjack (deal/hit/stand/double/split)
        allowedTargets = 2;};
    class TON_fnc_casinoSRV {   // LooneyBin: Casino -- Coin Flip/Wheel/Slots/Roulette/Hi-Lo engine (client->server intent)
        allowedTargets = 2;};
    class PLB_fnc_createP3DObjects {allowedTarget = 2;};
    // LooneyBin: server->client callbacks. Under mode=1 these MUST be whitelisted or the engine
    // silently blocks the server's remoteExec to the client. life_fnc_requestReceived is THE
    // player-load return (server queryRequest/insert -> client) — without it the client hangs at
    // waitUntil{life_session_completed} forever (no spawn/HUD/phone). Others: GE/exchange, money
    // (uC), gang garage, weapon grant — all server-initiated calls onto clients.
    class life_fnc_requestReceived {allowedTargets = 1;};
    class life_fnc_blackJack {   // LooneyBin: Casino -- server->client table render
        allowedTargets = 1;};
    class life_fnc_blackJackReceive {   // LooneyBin: Casino -- server->client bank payout credit
        allowedTargets = 1;};
    class life_fnc_casino {   // LooneyBin: Casino -- server->client result render (Coin Flip/Wheel/Slots/Roulette/Hi-Lo)
        allowedTargets = 1;};
    class life_fnc_casinoReceive {   // LooneyBin: Casino -- server->client bank payout credit (five simple games)
        allowedTargets = 1;};
    class life_fnc_loonerReceive {   // LooneyBin: Looner -- server->client feed push
        allowedTargets = 1;};
    class life_fnc_loonazonTrack {   // LooneyBin: Loonazon -- server->client van-position push (buyer-only local marker)
        allowedTargets = 1;};
    class life_fnc_loonazonPirate {   // LooneyBin: Porch Pirate -- server->all van pings (clients filter by talent)
        allowedTargets = 1;};
    class TON_fnc_talentPointsSRV {   // LooneyBin: buyable talent points (client -> server load/buy)
        allowedTargets = 2;};
    class life_fnc_talentPointsRecv { // LooneyBin: buyable talent points (server -> client count push)
        allowedTargets = 1;};
    class life_fnc_lzEject {          // LooneyBin: Loonazon van eject (server -> rider; handler gates owner==2)
        allowedTargets = 1;};
    class TON_fnc_atmSkimSRV {        // LooneyBin: ATM skimmer (client -> server apply/remove/credit)
        allowedTargets = 2;};
    class life_fnc_botKick {allowedTargets = 2;};
    class life_fnc_uC {allowedTargets = 1;};
    class life_fnc_GEMenu {allowedTargets = 1;};
    class KBW_fnc_GEMenu {allowedTargets = 1;};
    class life_fnc_gangGarageMenu {allowedTargets = 1;};
    class life_fnc_vehicleGarageMenu {allowedTargets = 1;};
    class life_fnc_handleHouse {allowedTargets = 1;};
    class KBW_fnc_addWeapon {allowedTargets = 1;};
    // LooneyBin: arrest/ticket cop pay. Both are server->client callbacks (wantedBounty -> bountyReceive
    // on the cop; copSplit -> copSplitReceive on each active cop). Without whitelisting, mode=1 silently
    // blocks them and cops are never paid for arrests OR tickets.
    class life_fnc_bountyReceive {allowedTargets = 1;};
    class life_fnc_copSplitReceive {allowedTargets = 1;};};
class Commands {mode = 0;
    jip = 0;};