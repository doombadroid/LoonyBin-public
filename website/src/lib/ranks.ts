// Rank / stat semantics — pinned from the live game SQF (fn_getRankString.sqf,
// fn_requestReceived.sqf, fn_titleCfg.sqf). Keep in sync if the game changes them.

// players_global.coplevel 1..7
export const COP_RANKS: Record<number, string> = {
  1: "APD Cadet",
  2: "APD Patrol Officer",
  3: "APD Corporal",
  4: "APD Sergeant",
  5: "APD Lieutenant",
  6: "APD Captain",
  7: "APD Chief of Police",
};

// players_global.mediclevel — National Guard (rebranded from AFD/Medic). 1..7,
// plus 99 = the EMT Volunteer tier (a sentinel, not a ladder step).
export const MEDIC_RANKS: Record<number, string> = {
  99: "NG EMT Volunteer",
  1: "NG Private",
  2: "NG Corporal",
  3: "NG Sergeant",
  4: "NG Warrant Officer",
  5: "NG Lieutenant",
  6: "NG Commander",
  7: "NG Marshal",
};

// gang rank is INVERTED: 1 = leader .. 5 = recruit
export const GANG_RANKS: Record<number, string> = {
  1: "Leader",
  2: "Officer",
  3: "Member",
  4: "Associate",
  5: "Recruit",
};

// players_global.adminlevel — server staff ranks (pinned from fn_welcomeUI.sqf;
// level 1 is untagged in-game, labelled "Trial Mod" here).
export const ADMIN_LEVELS: Record<number, string> = {
  1: "Trial Mod",
  2: "Moderator",
  3: "Admin",
  4: "Senior Admin",
  5: "Owner",
};

export function copRank(level: number): string | null {
  return level > 0 ? COP_RANKS[level] ?? `APD L${level}` : null;
}
export function medicRank(level: number): string | null {
  return level > 0 ? MEDIC_RANKS[level] ?? `NG L${level}` : null;
}
export function gangRank(rank: number): string {
  return GANG_RANKS[rank] ?? `R${rank}`;
}

// --- players_global.stats  (A_stats, 17 ints) index map (fn_requestReceived.sqf) ---
export const STAT = {
  CIV_TIME: 11, // civ playtime, minutes
  COP_TIME: 14, // cop playtime, minutes
  MED_TIME: 15, // medic playtime, minutes
} as const;
