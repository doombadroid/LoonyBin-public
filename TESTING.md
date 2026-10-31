# TESTING — LooneyBin (deployed this session, not yet live-verified)

Check off as confirmed. `[SOLO]` you alone (owner/admin powers ok) · `[2P]`/`[3P]` need other players.
Repro is in-game actions (no console paste on this client). Watch for the noted expected result.

## 🔴 Highest priority — money / dupe (verify first)

- [ ] **Gang bank** `[SOLO, need a gang]` — interact with the gang ATM.
      Expect: balance LOADS (not stuck "Loading…"). Deposit $X → fund up, cash down. Withdraw $X →
      reverse. Withdraw MORE than the fund → rejected, no money created.
- [ ] **Wire transfer** `[2P]` — at an ATM, wire $X to another player.
      Expect: they receive $X, you lose $X. (Was broken: money vanished — receiver got nothing.)
- [ ] **Inventory dupe (store)** `[SOLO]` — put a stackable item in a vehicle trunk, wait ~3 s, relog.
      Expect: item is in the trunk ONLY, not also back in your inventory.
- [ ] **Buy/sell money dupe** `[SOLO]` — buy a virtual item, relog within ~2 s.
      Expect: you keep the item AND the cash stays spent (no cash-back-keep-item).
- [ ] **Vehicle sell** `[SOLO]` — sell a garaged vehicle.
      Expect: bank credited the sell price exactly once (no double-credit on a fast double-click).
- [ ] **Cartel tax** `[2P+, captured cartel]` — a gang controls a cartel (drug/oil/wongs/arms); a
      player NOT in that gang processes there.
      Expect: the controlling gang's bank rises by the tax cut. (Also: no server lag buildup near cartels.)
- [ ] **Medic split** `[3P]` — a medic revives a downed player with another AFD medic nearby.
      Expect: BOTH medics get a payout (reviver + partner each a share). "Medical assist payout" message.

## Connection / respawn

- [ ] **Reconnect-in-place** `[SOLO]` — log out in the field (away from a spawn), reconnect.
      Expect: you spawn where you logged out, not the spawn menu / town. Crash test (kill the client):
      reconnect → within walking distance of where you were.
- [ ] **Bleedout timer = 30 min** `[SOLO]` — die as civ.
      Expect: bleed timer counts from 30:00 (respawn button still unlocks ~36 s in). #41 corpse persistence
      already confirmed; just sanity-check the new duration.

## Gang

- [ ] **Gang ownership transfer** `[2P, gang]` — as gang owner (rank 1), transfer ownership to a member.
      Expect: they become owner, you demote. Reopen the gang menu → ranks correct. Persists on relog.
- [ ] **Gang tag** `[2P]` — set a gang tag in the gang menu.
      Expect: the tag shows network-wide (e.g. death messages read "[TAG] Name").
- [ ] **Gang menu** `[2P, gang]` — open gang management.
      Expect: members list populates; promote / kick / disband all work (earlier fix).

## Vehicle / heli

- [ ] **Vehicle repair** `[SOLO]` — damage a vehicle, store it, use the garage repair option, pull it.
      Expect: it comes out undamaged.
- [ ] **enableCoPilot** `[2P]` — fly a heli with a passenger aboard; die as the pilot.
      Expect: the passenger gets "you've got the controls" + can fly/land (not an automatic crash).
- [ ] **adminDelVeh** `[SOLO, admin ≥3]` — look at a vehicle, press the bound delete key (User Action 211).
      Expect: it despawns; if owned, the owner can re-pull it from the garage (not permanently destroyed).

## PvP

- [ ] **Duel arena** `[2P]` — courthouse duel NPC → invite a player + set a wager → they accept at the
      courthouse.
      Expect: both pay half the wager → teleport to the arena → first to 2 kills → winner gets 90% of the
      pot → both restored to pre-duel loadout/position. Refund if it fails.

## Passive (not interactive — check server logs)

- [ ] **wacClient** — if anyone equips restricted gear or trips the memhack report, the server RPT logs
      `912` (illegal equipment) / `913` (tamper report). Advisory only (no auto-kick).

---
Earlier this session's BUGS.md fixes (VON, side chat type-only, oil cartel, news broadcast, turf capture,
VDM karts, #40 group password, #44 chop claim, #23 restrain, #43 Orca rotor) — re-verify from BUGS.md if
not already confirmed.
