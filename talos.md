# TAL OS — the APD counter-deck

Backlog spec (owner 2026-07-20). APD counterpart to civilian **ICEBREAKER OS** (`cyberdeck.md`,
`quickhacks.md`). Same SHIFT+Y radial, `playerSide == west` swaps the wedge set; the phone app reads
**TAL OS** instead of ICEBREAKER OS.

## Design rules

- **Civs get ACCESS, cops get INFORMATION + COUNTERS.** No wedge should end a chase without RP.
- **Issued, not bought.** TAL is free/standard at the APD; civilian firmware is illegal and purchased.
  The contrast is the point.
- **Everything logs.** Every TAL action writes to `TON_fnc_logIt` — lawful tool, auditable.
- **Rank-gated** at the top end (see below).
- Requires APD VR goggles (issued in the cop shop, $1,000 — same gate as the civ ring).

Implementation is cheap: the ring renderer (`core/items/fn_cyberdeckRing.sqf`) is generic. A side
check picks the vector table; art/labels/hub/telemetry all reuse the existing pipeline.

---

## Direct counters to ICEBREAKER (the arms race)

| Wedge | Does | Hook |
|---|---|---|
| ICE Trace | A hack fires nearby -> bearing + fading marker on the hacker. **Proxy Chain defeats it** | existing hack alert paths |
| Firmware Scan | Aim at a player, 3s -> are they running illegal firmware? Probable cause BEFORE restraining | firmware flag (id 0 of `plb_cdMods`) |
| Factory Reset | The firmware wipe that already exists — belongs on the ring, not only a scroll action | built (`cyberdeckSRV "factoryReset"`) |
| Deck Jammer | No hacks inside ~80m for 60s. Park it on the Fed mid-heist | **BUILT 2026-07-21** (`talAction 8` -> `talSRV "jammer"`, Captain+, 180s CD; server-only bubble checked by qhSRV + cyberdeckSRV) |
| Honeypot ATM | Rig an ATM; the next jackpot attempt fails and pings APD with location | **BUILT 2026-07-21** (`talAction 9` -> `talSRV "honeypot"`, Captain+, 1h arm, one-shot; burns the hacker's deck cooldown + located APD ping, Proxy Chain does NOT suppress it) |

## Dispatch & records

| Wedge | Does | Hook |
|---|---|---|
| Records Lookup | Aim at a player -> priors, arrests, bail history, gang | `players` stats / `gang0` |
| Plate Scan | Aim at a vehicle -> owner, stolen flag | `vehicles` table |
| BOLO Board | Live APB list + last-known positions | wanted system / `trackAPB` |
| Dispatch Pin | Drop a marker + note every cop sees | `copalert` broadcast |

## Field / forensics

| Wedge | Does | Hook |
|---|---|---|
| Field Test | Breathalyzer + drug screen -> instant DUI / possession charge | **already in the cop-search payload** (`life_alcohol_level`, `life_drug_level`) — free win |
| Skimmer Sweep | Detect planted ATM skimmers nearby | `fn_atmSkimSRV` ($200k removal bounty = real patrol work) |
| Rig Sweep | Detect illegal mining rigs in nearby houses | `TON_fnc_miningSRV` |
| Warrant Request | Request/approve a LAWFUL house breach; Captain+ approves | **STILL UNBUILT** — needs an approval workflow AND a ruling on what "lawful" changes mechanically (no Cyber Crime charge? no ICE trace? owner still notified?). Owner decision pending. |

## Coordination

| Wedge | Does | Hook |
|---|---|---|
| Unit Board | Who's on duty, rank, where — the APD's "Gangs Online" | player list |
| Backup Beacon | Panic button; red marker to all APD + medics | broadcast |
| Drone Uplink | Launch/fly the UAV straight from the ring | **BUILT 2026-07-21** — ring wedge calls `life_fnc_copUAV` directly (its own Captain+/$10k gate is unchanged) |

## Rank gates

- **Patrol:** Records Lookup, Plate Scan, Field Test, BOLO Board, Backup Beacon, Dispatch Pin
- **Sergeant+:** Firmware Scan, Factory Reset, Skimmer Sweep, Rig Sweep
- **Captain+:** Deck Jammer, Drone Uplink, Warrant approval, Honeypot ATM

## Do NOT give them

Wallhacks, remote arrest, remote vehicle disable, or anything that ends a pursuit without roleplay.
Cops should get *better questions*, not auto-wins.

## Suggested first batch

Almost all read data that already exists: **Records Lookup, Plate Scan, Field Test, Firmware Scan,
Factory Reset, Backup Beacon.** Then **ICE Trace** as the marquee — it's the wedge that makes the
civilian Proxy Chain worth its $60k and turns hacking into a two-sided game.

## Status — BUILT + LIVE ON DEV (2026-07-20)

- **APD VR goggles** — cop shop, $1,000, `G_Goggles_VR`.
- **All 8 wedges live**: Records / Plate / Field Test / Firmware / Reset / Sweep / Dispatch / Backup.
- **Police skin baked** — `ring_pd_base.paa` + `ring_pd_hl_0..7.paa` (`scratchpad/render_ring_pd.py`):
  navy-steel body, badge-amber primary, light-bar ice blue, police red. Own icon set.
- **Files**: client `core/cop/fn_talAction.sqf` (+ `talMarker` / `talFieldReply` / `talLog`),
  server `TON_fnc_talSRV` (records only), ring branch in `core/items/fn_cyberdeckRing.sqf`.
- **Two entry points, same tools**: SHIFT+Y opens the quick **ring**; the **TAL OS phone app** opens a
  full **app grid** (`dialog/tal_home.hpp`, idd 941300 + `fn_talHome` / `fn_talHomeLaunch`) built the same
  way as the ICEBREAKER home screen -- baked backdrop, invisible hit-tiles, per-tile dim for anything the
  current context can't use, live subject/rank strip. Art + dialog are emitted together by
  `scratchpad/render_tal_home.py` so tiles and artwork cannot drift apart.
- Client-side by design where the data is already public: Plate Scan (`plb_vehOwners`),
  Firmware Scan (`plb_cdMods`), Sweep (`plb_cryptoRig` + `PLB_atmSkim`). Only Records hits the DB;
  only Field Test round-trips to the suspect's client.

### ICE TRACE — BUILT (2026-07-20)
**Passive, deliberately no wedge** — wearing the goggles IS the capability, the way a radio call just
arrives. `TON_fnc_iceTrace` is now the **single authority on whether a hack is quiet**: it reads the
hacker's armed Proxy Chain, burns it, and suppresses BOTH the trace and the caller's own APD alarm.
Every hack routes through it — ATM, Fed, house breach, ignition, rig hijack. Officers within 650m
wearing TAL goggles get `life_fnc_talTrace`: compass bearing, distance, 45s marker, and WHAT was hit
— never WHO. They still have to find the person.

Fixed en route: the proxy was previously checked ad-hoc in two places and **never consumed** for
house / ignition / crypto hacks, so an armed charge sat unspent forever. One consumer fixes that.

### Still to build
**Warrant Request only.** Deck Jammer, Honeypot ATM, Drone Uplink, Unit Board and BOLO Board are all built as of 2026-07-21.
