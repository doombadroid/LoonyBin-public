# NEEDSFIX

Deferred fixes that need a careful/vetted change (usually config-level = mission-load risk).

---

## Jet passive radar — true sensor removal (config patch)

**Status:** PARTIAL. Runtime mitigation is LIVE-staged; the real fix is deferred.

**What's done (runtime, safe):** `server/life_server/core/system/fn_spawnVehicle.sqf` — every spawned `isKindOf "Plane"` gets `setVehicleRadar 0` + `setVehicleReceiveRemoteTargets/ReportRemoteTargets/ReportOwnPosition false` on spawn. Kills the ACTIVE radar HUD + datalink targeting.

**What's still needed:** the **PASSIVE radar sensor** is a `CfgVehicles` component — no runtime command removes it, and a pilot can re-toggle the active radar with the radar key. To actually kill passive radar:
- Add a `CfgVehicles` patch in `mission/LooneyBin.Altis/config.cpp` (currently has NO CfgVehicles block) that, per buyable jet class, does `delete PassiveRadarSensorComponent` inside `Components >> SensorsManagerComponent >> Components` (or zeroes its ranges).
- Buyable jet classes: `B_Plane_CAS_01_dynamicLoadout_F` (Wipeout), `I_Plane_Fighter_03_CAS_F`, `I_Plane_Fighter_04_F` (Gryphon), `Plane_Fighter_03_F`.

**Why deferred / RISK:** a wrong parent-class chain or sensor class name = config fails to bind = mission won't load = **mass kick** (the 2026-06-16 deploy disaster). Must verify the exact base-class hierarchy + `SensorsManagerComponent` structure against the real Arma configs and test before deploying. Do it as its own isolated, vetted deploy — not bundled.

---

## #260 — suicide + alt+F4 → reconnect ALIVE with no gear

**Status:** DEFERRED (high impact — gear loss). Reporter: player006, 2026-06-15.

Player picks suicide on the death screen, alt+F4s during the death/respawn window, then reconnects **alive** (death never committed) but **stripped of all gear** (death already wiped it). Classic combat-log-during-death = inconsistent persisted state.

**Why deferred / RISK:** needs the full death→disconnect→DB→reconnect flow mapped (`fn_onPlayerKilled` → `fn_playerDisconnected` → flushPlayer/save → `fn_requestReceived` on rejoin). Wrong fix risks corrupting the alive/dead flag or the loadout column for EVERY disconnect. Right fix: on disconnect while dead/downed, COMMIT the death (so they rejoin fresh at spawn-select), OR on rejoin detect alive+no-gear and route to spawn-select. Vet against the disconnect-dupe house-save patch already in `fn_playerDisconnected`.

---

## #268 — spectating a player who disconnects → stuck on the dead body

**Status:** DEFERRED (admin-only). Reporter 2026-06-16.

Admin EG spectator (`core/admin/fn_adminSpectate.sqf`, `BIS_fnc_EGSpectator`). When the spectated unit disconnects, the BI spectator loses its focus unit, the camera sticks on the gone body, and F8/terminate doesn't fully restore input ("can't open anything, even phone").

**Why deferred / RISK:** it's a BI module — patching its null-target handling blind is risky and the feature is admin-only (low blast radius). Right fix: harden the F8 terminate path (always `["Terminate",[player]] call BIS_fnc_EGSpectator` + remove the KeyDown EH + restore camera) and add a guard that drops the admin out cleanly if the focused unit becomes null. Test with a real DC.

---

## #265 — Kavala drug dealer interaction tanks FPS

**Status:** NEEDINFO / investigate. Reporter 2026-06-16 (during a weed run).

FPS craters when interacting with the Kavala drug dealer (`life_fnc_virtualShopMenu` sell NPC). Could be the menu rebuild, a per-frame addAction condition, or the dynamic-market price recompute querying on open.

**Need from reporter:** is the drop while the **menu is open**, or just standing near the NPC? Which exact dealer/location? Then profile the open path (virtualShopMenu populate + market price calc).

---

## #254 — drug-cartel vehicle garage spawns Hatchback Sport into the pole

**Status:** DEFERRED (map work). Reporter 2026-06-15.

Pulling a Hatchback Sport at the drug-cartel garage spawns it too close to the pole → desync → kills nearby players (had to revive 1). Spawn point is too tight / no clearance check.

**Fix path:** move the drug-cartel garage spawn point clear of the pole (map-data / `fn_spawnVehicle` spot), or add an occupancy/clearance check + offset like the airDrop `findSafePos` pattern. Needs the exact spawn coords + a test pull.

---

## #275 — no actual oil cartel to cap

**Status:** DEFERRED (map work). Reporter 2026-06-16.

Oil cartel has no cappable flag/zone on the map. The cap system references `oil_flag` / `oil_cartel` (see `fn_airDrop`, `fn_captureCartel`) but the flag object / marker isn't placed.

**Fix path:** verify `oil_flag` object + `oil_cartel` marker + the `fn_spawnCaptures` setup for oil exist and are placed on Altis; add via the map-data / Eden pipeline if missing. Cross-check against arms/drug/wongs which DO work.

---

## #273 — player has a title they didn't earn

**Status:** NEEDINFO. Reporter player095, 2026-06-16 (screenshot attached).

Player shows a title (`plb_title`) they say they didn't unlock. Could be a title-grant/achievement-condition bug or a default seeded wrong.

**Need:** which exact title, and the screenshot detail. Then trace the title source (`life_fnc_titleCfg` / `getMyStats` / the achievement that grants it) to see if its unlock condition is too loose or seeded by default.
