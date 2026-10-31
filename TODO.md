# LooneyBin — Stub Repair TODO

Working checklist for the stub/missing-feature grind. Full inventory: `STUBS.md`. Anti-cheat (WAC): `CLANKR.md`.
Status: `[ ]` todo · `[x]` done · `[~]` verified-OK (no change) · `[-]` deferred (needs design/schema).

## Done
- [x] **gangBank** — router (modes 0/1/2/4) + client receive, balance-gated, atomic (2026-06-06)
- [x] **handleWireTransfer** — credit the receiver (was a money-loss bug; sender debited, receiver never paid) (2026-06-07)
- [x] **wacClient** — clean gear scan + record tamper report (see CLANKR) (2026-06-07)
- [x] **vehicleRepairSRV** — garage repair now zeroes stored damage in DB (was a no-op) (2026-06-07)
- [x] **cartelSRV** — killed the loop-accumulation + double-capture bug; restored the cartel TAX payout to the controlling gang's bank (2026-06-07)
- [x] **duelArenaSystemSRV** — implemented match start (teleport both into the arena); scoring + payout + refunds already client-wired. ⚠️ NEEDS in-game test (2026-06-07)
- [x] **medicSplit** — assisting medics now get their revive-reward share (server-authoritative bank credit) (2026-06-07)
- [x] **adminDelVeh** — admin despawn vehicle, non-destructive (owned → returns to garage via active=0) (2026-06-07)
- [x] **enableCoPilot** — heli pilot dies → a living passenger is promoted to the controls (2026-06-07)
- [x] **transferGangOwnerSRV** — gang ownership transfer (swap gangrank0: new→1, old→2, persisted) (2026-06-07)
- [x] **setGangTagSRV** — gang tag now sets network-wide so everyone sees it (session-live; DB persist needs a column) (2026-06-07)

## Tier 1 — money/persistence passthroughs
- [~] **statTableUpdate** (→update) — REDUNDANT: stats persist via `ClupdatePartial[9]` (stats blob). Broken passthrough loses nothing live.
- [~] **bulkAdd** (→addQueue) — REDUNDANT: crimes persist via `ClupdatePartial[8]` (crimes blob). Same.
- [-] **updateVehicleMods** (→updateVehicle) — vehicle mods never persist; needs a `mods` column (schema) → DEFER
- [-] **varPersist** (→update) — ga_banktrace/drugtrace/choptrace anti-exploit cooldowns; needs columns/blob → DEFER. Real (relog resets cooldowns) but low-pri.

## Tier 2 — ownership / admin / data (MED)
- [x] **adminDelVeh** — DONE (despawn + return-to-garage)
- [ ] **transferHouse** (→setOwnerID) — house buy-from-player; setOwnerID only sets a netvar (no DB)
- [x] **transferGangOwnerSRV** — DONE (gangrank0 swap, persisted)
- [ ] **getID** (→setOwnerID) — verify call site / intent
- [ ] **updateHousePrice** (→updateHouse)
- [x] **setGangTagSRV** — DONE (session-live network set; DB persist needs a column → deferred)
- [ ] **updateGangMem** (→gangMember) — gang member DB row
- [ ] **update1GangTalents** (→setGangTalents)
- [ ] **adminPlayerQuerySRV** (→getAdmin) — admin ESP/suspect query
- [ ] **checkPlayer** (→getGuid)
- [ ] **getStatsArr** (→query)
- [x] **cartelSRV** — DONE (see Done): loop bug fixed + cartel tax payout restored
- [ ] **exchangeSystemSRV** (→reduceMarket) — market price decay on sells
- [ ] **srvObjectMonitor** (→addObjectWhitelist) — crankSmoke object whitelist
- [ ] **spawnPhysicalItem** (→placeStorage)
- [ ] **eventParticipants** (→addToEvent)
- [ ] **timeTrialSRV** (→finishRace)

## Tier 3 — VERIFY passthroughs (args checked = aligned to targets; confirm in-game, rewrite only if they misbehave)
- [~] bankRobbery · fedRobbery · srvRobStore · huntingGrounds · handlePrisonBreak — args aligned
- [~] trialSystemSRV · handleDispatch · registerSwat · srvSpikeStrip · srvChopShopSell — args aligned
- [~] changeWeather · govSystemSRV · processMailbox · add2Lotto · changeServCycle — args aligned

## Tier 4 — DEAD features (implement; bigger, lower priority)
- [x] **duelArenaSystemSRV** DONE (needs in-game test) · [ ] still dead: eventBRSRV, eventGunGameSRV, eventPurgeSRV, eventGraveyardSRV
- [ ] Heists: loonyBinSRV (signature), jewelryEmporiumSRV, convoyRobbery + endConvoyRobbery
- [ ] Racing: createTimeTrialVehSRV
- [ ] Gang houses: addGangHouse, changeGangHouseSRV, removeGangHouseSRV, gangBHistory
- [x] **medicSplit** + **enableCoPilot** DONE · [ ] still dead: airDrop, airDropMedic, medSupplySpawn
- [ ] Cop: evidenceTruck, evidenceAppend, srvMobileHQ
- [ ] Econ/misc: loginBonusSRV, houseTaxSRV, wantedRemoveCharge, handleTimer, discordEmbed, doBuySkin (skins stripped)
- [ ] Seasonal: easterSeasonalEvent, xmasTreeAndPresentsSRV · bankLightHouseToggle

## `gang1` column bug (this DB only has gang0) — same class as the gang-bank root
- [x] **fn_queryGangs** — boot gang-cache loader counted `gang1` → query threw → cache empty → ALL gang ops broke (gang bank, cartel tax, etc.). Fixed → gang0 (2026-06-07)
- [ ] **fn_update.sqf:70** — full-player-save field map uses `gang%instance`/`gangrank%instance` (= gang1) → the whole buffered UPDATE errors → that save path is a silent no-op (ClupdatePartial covers persistence, so no data loss). Fixing RE-ENABLES a dormant save path → needs care/testing before flipping.
- [ ] **fn_receiveHouses.sqf:85** — `UPDATE players SET gang%instance WHERE gang%instance` (gang id remap) → dormant/failing. Same re-enable caution.

## Mission-side silent no-ops (38)
- [ ] Triage which are actually live-referenced vs dead legacy duplicates (court/dispatch/SWAT/wanted clusters). Most are harmless reverse-drift shims.
