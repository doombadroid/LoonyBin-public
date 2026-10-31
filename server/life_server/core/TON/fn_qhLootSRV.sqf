// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only
/*
    File: fn_qhLootSRV.sqf  (TON_fnc_qhLootSRV)
    LooneyBin 2026-07-21: QUICKHACK LOOT rolls (owner spec: consumables + rare installable hack chips).
    Tiered by source; the server rolls and grants so a client can't mint its own drops.

      [_source, _player]   _source: "fed" | "cartel"   (the rogue van seeds its own crate cart instead)

    Throttled per-UID per-source so re-running the same heist beat can't farm rolls.
*/
params [["_source", "", [""]], ["_player", objNull, [objNull]]];
if (isNull _player || {!(_source in ["fed", "cartel"])}) exitWith {};

private _uid = getPlayerUID _player;
private _tkey = format ["plb_qhLootCd_%1_%2", _source, _uid];
if (serverTime < (missionNamespace getVariable [_tkey, 0])) exitWith {};
missionNamespace setVariable [_tkey, serverTime + 300];

// [class, qty, chance] -- fed pays best (hardest content), cartel moderate. Every hack chip is a PERMANENT
// unlock (owner 2026-07-22), so one lucky roll is a forever upgrade and duplicates are tradeable.
// FED (owner 2026-07-22): consumable chance rolls PLUS one GUARANTEED hack chip, weighted across every
// tier -- T1 common, T3 the meat, T4 rare, Chauffeur/Puppet under 1% each. The ICE Firewall (the counter)
// still rides the chance table so the defence spreads slightly ahead of the offence.
private _table = if (_source isEqualTo "fed") then {
    [["proxychain", 2, 1], ["breachkit", 1, 0.6], ["icefirewall", 1, 0.14], ["deadmanchip", 1, 0.12]]} else {
    [["proxychain", 1, 0.5], ["breachkit", 1, 0.3], ["ghostplatechip", 1, 0.1],
     ["icefirewall", 1, 0.06], ["flatlinecharge", 1, 0.04], ["blackoutdaemon", 1, 0.02], ["memoryholechip", 1, 0.02], ["chauffeurchip", 1, 0.008], ["puppetchip", 1, 0.005], ["deadmanchip", 1, 0.05]]
};

private _won = []; {_x params ["_cls", "_qty", "_chance"];
    if (random 1 < _chance) then { _won pushBack [_cls, _qty]; };} forEach _table;

// fed only: the guaranteed weighted chip. Weights sum to 100; a completed fed ALWAYS pays exactly one chip.
if (_source isEqualTo "fed") then {
    // owner 2026-07-23: T1 cut 48 -> 30, freed weight pushed into T3 (the tier money can't buy) 40.5 -> 58.5.
    // T1 chips are cheaply shop-bought, so showering them devalued the whole system; T3 is the loot-only meat.
    private _chips = [["pingchip", 7.5], ["distractchip", 7.5], ["staticchip", 7.5], ["whiteoutchip", 7.5],      // T1  30
        ["stickychip", 6.5], ["jamchip", 6.5], ["wiretapchip", 6.5], ["crybabychip", 6.5],         // T3  58.5
        ["synapsechip", 6.5], ["leechchip", 6.5], ["shortchip", 6.5], ["eyespychip", 6.5], ["valetchip", 6.5],
        ["ghostplatechip", 3], ["blackoutdaemon", 2.5], ["flatlinecharge", 2.5], ["memoryholechip", 2],  // T4  10
        ["chauffeurchip", 0.75], ["puppetchip", 0.75]                                              // apex <1% each
    ];
    private _roll = random 100;
    private _acc = 0;
    private _pick = "";
    { _acc = _acc + (_x select 1); if (_roll < _acc && {_pick isEqualTo ""}) then { _pick = _x select 0; }; } forEach _chips;
    if (_pick isEqualTo "") then { _pick = "pingchip"; };   // float-edge fallback: roll == 100 exactly
    _won pushBack [_pick, 1];};
if (_won isEqualTo []) exitWith {};
 {_x params ["_cls", "_qty"];
    [[true, _cls, _qty], "life_fnc_handleInv", _player, false] spawn life_fnc_MP;} forEach _won;
private _dn = createHashMapFromArray [["proxychain", "Proxy Chain"], ["breachkit", "Breach Kit"], ["ghostplatechip", "Ghost Plate Chip"],
    ["icefirewall", "ICE Firewall Chip"], ["flatlinecharge", "Flatline Chip"], ["blackoutdaemon", "Blackout Daemon"], ["memoryholechip", "Memory Hole Chip"], ["puppetchip", "Puppet Strings Chip"], ["deadmanchip", "Dead Man's Clutch Chip"], ["chauffeurchip", "Chauffeur Override Chip"],
    ["pingchip", "Ping.exe Chip"], ["distractchip", "Distract.exe Chip"], ["staticchip", "Static Burst Chip"], ["whiteoutchip", "Whiteout Chip"], ["stickychip", "Sticky Fingers Chip"], ["jamchip", "Jam.exe Chip"], ["wiretapchip", "Wiretap Chip"], ["crybabychip", "Crybaby Chip"], ["synapsechip", "Synapse Drag Chip"], ["leechchip", "Leech Chip"], ["shortchip", "Short Circuit Chip"], ["eyespychip", "Eye Spy Chip"], ["valetchip", "Valet Protocol Chip"]];
private _names = _won apply { format ["%2x %1", _dn getOrDefault [_x select 0, _x select 0], _x select 1] };
[[format ["<t color='#c9e21a'>DECK LOOT</t> -- recovered from the intrusion: %1.", _names joinString ", "], "cyberjackpot"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
["-QHLOOT-", _player, name _player, format ["%1 loot -> %2", _source, str _won]] call TON_fnc_logIt;
