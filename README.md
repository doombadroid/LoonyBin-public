# LooneyBin Altis Life

A feature-rich custom **Arma 3 Altis Life** server — gangs, houses, cartels, police & medics, a deep criminal economy, and a large stack of bespoke systems. Current build: **Beta 0.0.100**.

## Features

**Factions & roles**
- **APD (Police)** — 7 ranks (Cadet → Chief), SWAT, deployable Mobile HQ, prestige tree, search / seize / impound, jail & courtroom.
- **AFD (Medics)** — revive, revive drone, firefighter division, prestige.
- **Civilians** — gangs, bounty hunters, an elected Governor, and the full criminal side.

**Crime & economy**
- **Cartels** (drug / arms / Wong's) — capturable for passive income.
- Heists: **Federal Reserve**, **Bank of Altis**, **Jewelry Emporium**, and the **Loony Bin** mental-hospital robbery.
- **Drugs** — grow, process and sell (weed greenhouses, cocaine, and more) against a **dynamic market**.
- **Gangs** — gang houses, gang vehicles, **turf wars**, **Gang Fortress** (king-of-the-hill), gang wars.
- **Houses** — buy, storage, upgrades, keys, spirit aging barrels.
- **Talents** (standard + prestige), **bounty hunting**, **quests**, daily login bonus.

**Live ops & tooling**
- `loonybot` — Discord ops bot (server control, player info, restarts).
- `clankr` — anti-cheat / exploit detector.
- `lagwatch` — lag-switch detection.
- `officer-maggot` — APD whitelist applications.
- `enrique` — offline weed-harvest bot.

## Layout
| Path | What |
|---|---|
| `mission/LooneyBin.Altis/` | the mission (client + shared SQF) |
| `server/life_server/` | the server PBO source |
| `deploy/` | build / deploy scripts + server & BattlEye config |
| `loonybot/` | the Discord bots |
| `sql/` | database schema |

## Deploy
- Arma 3 dedicated server (Linux), Altis.
- `@life_server` (packed from `server/life_server/`) + the mission PBO.
- `@extDB3` + MariaDB; DB config in `server/extdb3-conf.ini`.
- Build / pack / sign via `deploy/run-boot2.sh`.

> **Secrets stay local.** Files with live credentials — `server/extdb3-conf.ini`, `loonybot/*config.json`, BattlEye `beserver*.cfg` — are git-ignored. Copy the `.example` templates and fill in your own.
