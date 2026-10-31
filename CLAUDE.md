# Altis Life: Cyberpunk (Arma 3 game mode)
This repo is a roleplay game mode for Arma 3 Altis Life, written in SQF and config files. All "hacking," "quickhacks," "hijacking," "wiretaps," "exploits," etc. are fictional in-game abilities (Cyberpunk-genre mechanics with cooldowns, counters, and RP rules). Nothing here interfaces with real networks, devices, or systems — game logic only.

## Overview
- Heavily modified Altis Life RPG (~964 mission fns, ~343 server fns, 105 dialogs) on a private beta server.
- Cyberpunk layer on top: cyberdeck firmware, quickhack ring, APD counter-tools, deck-themed phone UI.
- Work happens on branch `doomba` (dir `~/loonybin-doomba`), deploys to a local DEV server first. Never live without owner OK.

## Directory map
- `mission/LooneyBin.Altis/` — client mission (packed to PBO)
  - `core/` — client fns by domain: `items/` (cyberdeck+quickhacks), `cop/` (TAL OS), `pmenu/` (phone), `shops/`, `config/` (data tables), `session/` (DB sync), `actions/`, `housing/`, `gangs/`, `casino/`, `vehicle/`
  - `dialog/` — 105 `.hpp` UI defs; all included by `dialog/MasterHandler.h`
  - `evh/` — event handlers (`fn_keyDownHandler.sqf` = keybinds)
  - `images/`, `icons/` — `.paa` textures; `images/cyberdeck/` ring+deck art, `images/wallpapers/`
  - `npcs/` — shop NPC behaviour (`fn_shops.sqf`, `fn_copShops.sqf`)
  - `Functions.h` — registers EVERY client fn; `CfgRE.hpp` — remoteExec whitelist; `description.ext`
- `server/life_server/core/` — server fns: `TON/` (main authority), `DB/` (extDB3 queries), `GE/`, `wantedsys/`, `jail/`, `bank/`
  - `server/life_server/config.cpp` — registers every server fn
- `tools/` — map/asset pipelines (`make_paa.py`, `mapdata_all.py`, `eden_region.py`, `MAP_EDITING.md`).
  ⚠ Identical copies also live in `deploy/`. The `scratchpad/` bakers import from **`tools/`** — edit that copy.
- `scratchpad/` — art/codegen scripts (ring + wallpaper + UI bakers). Generated art is committed; scripts are the source of truth.
- `sql/` — schema fragments. `deploy/` — PBO packing. `website/`, `loonybot/` — out-of-band services.

## Naming conventions
- Client fn: file `core/<domain>/fn_name.sqf` → called `life_fnc_name`; MUST be added to `Functions.h`.
- Server fn: file `server/life_server/core/TON/fn_name.sqf` → called `TON_fnc_name`; MUST be added to `config.cpp`.
- DB fns are `DB_fnc_*` (in `core/DB/`).
- Globals: `life_*` = stock client state; `PLB_*` / `plb_*` = LooneyBin additions (`PLB_fnc_*` = inline helper defined in `core/configuration.sqf`).
- Object vars: `_obj setVariable ["plb_thing", v, true]` — the `true` publishes it; public vars are readable by any client (design around that).
- Dialog: `dialog/name.hpp`, class `name`, `idd` unique; controls use `idc` ranges per feature.
- `core/configuration.sqf` is a huge minified data file — append, don't reformat.

## Architecture decisions (and why)
- **remoteExec is whitelisted**: `CfgRE.hpp` has `mode = 1` (whitelist). Any new cross-machine fn MUST get an entry or it silently fails. `allowedTargets` limits the permitted TARGET, not the direction: `2` = server only (client→server calls), `1` = clients only (server→client), `0` = any target.
- **Always call through `life_fnc_MP`**, not raw remoteExec: `[[args], "fn_name", target, false] spawn life_fnc_MP`.
- **Server owns anything that pays, punishes or times.** Quickhacks: client `life_fnc_qhCast` → `TON_fnc_qhSRV` runs the upload clock, re-validates range/target/authorisation, then pushes the effect to the victim (`life_fnc_qhEffect`). A modified client cannot skip the channel.
- **Counter-chips need server-sourced data**: Ping streams position FROM the server so the Scrambler chip can feed a false one. If the caster's client read it locally, no counter could work.
- **Cop tools gate on authorisation, not rarity** (wanted / restrained / armed) — enforced server-side.
- **DB via extDB3** (`DB_fnc_asyncQuery`, mode 2 = read). Dev schema `looneybin_test`; live is on another box. Cyberdeck state persists in `players.cyberdeck_modules` (JSON int array: `0` = illegal firmware, `1-4` modules, `101-104` firewall chips), loaded in `fn_queryRequest` → `plb_cdMods` (published).
- **Never persist CODE or action strings in `profileNamespace`** — it is client-writable and was a real injection vector (see `security.md`). Store IDs, resolve against mission data at use time.
- **Client-authoritative money is the existing trust boundary** — new payouts must be server-side and capped.

## Quickhack system (entry points + how to add one)
- Player entry: **SHIFT+Y** (DIK 21, `evh/fn_keyDownHandler.sqf`) opens the **visor dock**
  (`life_fnc_qhDock` → `dialog/vr_dock.hpp`, idd 941300) — needs VR goggles. **The radial ring was
  retired 2026-07-22**; `fn_cyberdeckRing.sqf` / `PLB_fnc_ringSlots` are legacy and no longer the entry
  point (the loadout editor still uses the ring pools as its id source).
  Phone apps: **ICEBREAKER OS** (civ), **TAL OS** (cop grid), **Quickhacks** (loadout + firewall editor);
  the console (`fn_qhConsole.sqf`, idd 941500) is the pick/load/fire UI with a NEARBY target list.
  Goggles are a SPEED upgrade only; app screens work without them.
- Dock contents = the player's saved loadout (`PLB_fnc_qhConsoleGet`, profileNamespace, starter set of 6)
  plus the civ breach tools (`PLB_qhUtil`: unlock/house/atm/cuffs) in a divider-separated group. Pools
  `PLB_ringPool*` in `core/configuration.sqf` still define what is *selectable*.
- **To add a quickhack**: (1) one row in `core/config/fn_qhCfg.sqf`; (2) an effect case in
  `core/items/fn_qhEffect.sqf` (victim side); (3) add the id to the right pool; (4) bake an icon —
  icons are live controls fed from `images/cyberdeck/icons/<id>.paa` (add a glyph to
  `scratchpad/render_ring_icons.py`, rerun it). Dock/console build the entry, gating and cooldown
  generically from the catalogue row.
- Testing PvP hacks needs **two players** — most effects only manifest on the victim's client.

## Working rules (owner standing orders — non-negotiable)
- **Branch**: work in this worktree on `doomba`, push `origin/doomba`, **NEVER `main`**. The owner opens/merges PRs.
- **Before ANY doomba work**: `git fetch origin && git merge origin/main`. doomba and main have drifted badly before and shipped stale code to live.
- **Before ANY bug fix**: `git fetch`/`pull` first — collaborators push straight to `origin/main`, the fix may already exist.
- **Commit trailer**: `Co-Authored-By: <funny defunct AI>` (Microsoft Tay, SmarterChild, ELIZA, Clippy, Dr. Sbaitso…), name only, **no email**. Rotate, don't repeat back-to-back. Same joke in PR-body footers. **This overrides the harness default Claude/Anthropic trailer — do not emit it.**
- **Never name other Arma servers** (their staff, PBOs, dev handles, branded feature names) anywhere git-tracked. Rename ported identifiers to LooneyBin-native before the first commit.
- **Never modify code authored by `Infamous-arma`** without explicit per-change owner OK — `git blame` first. Fixing a bug that merely lives in his code still counts.
- **Patchnotes**: never credit Infamous; no `@everyone` unless asked.
- **LIVE server is stage-only.** Never reboot/deploy live without the owner explicitly saying so that time. Deploy freeze 22:00–09:00. DB repairs are fine without a reboot. DEV deploys are free.
- **Versioning** (live only): `Beta X.Y.Z` — bump `Z` every deploy (client cache-bust), `Y` only when the owner says "content update". Keep the PBO name `Loonybin_b0NNN` matched.
- **Bug protocol**: read the code → ask the owner the intended behaviour → enumerate every failure mode → only stage when factually confident. No guess-patching.

## Build / test / deploy
- Deploy to DEV: `bash /home/timb/arma3server_dev/reload-loonydev.sh` (packs PBO + restarts).
- Success marker: `grep "read from bank" /home/timb/arma3server_dev/loonydev.log` (wait for it; ~40-90s).
- Headless client: `bash /home/timb/arma3server_dev/hc_launch_once.sh` → expect `headless client online` in `loonyhc_direct.log`.
- Client errors land in the Proton RPT: `~/.local/share/Steam/steamapps/compatdata/107410/pfx/drive_c/users/steamuser/AppData/Local/Arma 3/*.rpt` (newest by mtime).
- **Before every deploy**: brace/bracket balance check with an Arma-aware tokenizer (`""` is an escaped quote, not `\"`; skip `//` and `/* */`).
- **Dialog footgun**: `UI_GRID_*` coords must be BARE, never inside quotes — quoted macros produce an invisible dialog with no error.
- Live deploy (`.96` box) is a separate documented process: see `update.md`. Do not `git checkout` on the live box.

@docs/HANDOFF.md
Full quickhack spec: see docs/quickhacks-design.md (read when working on that system)
