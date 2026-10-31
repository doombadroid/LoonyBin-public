/*
    PLB_fnc_marketTick — server NEGLECT-PREMIUM market engine (LooneyBin, reworked owner spec 2026-06-16)

    MODEL: every farmable/tradeable good FLOORS at its MAX sell price (premium = 1). A good that ISN'T being
    sold drifts its premium UP indefinitely (prem *= 1+RISE each idle tick) -> a neglected good keeps getting
    more lucrative until players farm it. Once a good accumulates CRASH (2500) cumulative SALES (counted in the
    life_stock_update PVEH), its premium CRASHES back to 1 (= max price) and the sales counter resets.

    life_price_index = [[class, prem, sales], ...]   prem >= 1 (sanity-capped), sales >= 0.
    Persisted via `itemstock` (quantity = prem, sales = sales) so premiums + counters survive restarts.
    Client sell price = maxPrice * prem  (life_fnc_marketFactor returns prem; virtItemCfg getLowestPrice
    floors tracked goods at idx 6 = max). Buys of untracked goods are unaffected (factor = 1 for them).
*/
if (!isServer) exitWith {};

private _TICK     = missionNamespace getVariable ["PLB_marketTickSecs", 90];
// owner 2026-06-17 (#338): HYBRID supply/demand model. Price = maxPrice * prem, prem in [FLOOR, CEIL]. SELLING
// pushes prem DOWN toward the FLOOR (oversupply discount); an IDLE tick recovers/climbs prem UP toward the CEIL
// (scarcity premium). So prices move BOTH ways now -- dump a good and it drops; leave it alone and it recovers
// then rises. (Was one-sided: floored at max, only rose when neglected, never dropped on a dump.)
PLB_marketRise    = missionNamespace getVariable ["PLB_marketRise",   0.006];   // prem recovery/climb per IDLE tick (toward CEIL)
PLB_marketFloor   = missionNamespace getVariable ["PLB_marketFloor",  0.6];     // FLOOR: an oversupplied good bottoms at 60% of its max
PLB_marketCrash   = missionNamespace getVariable ["PLB_marketCrash",  1500];    // DEPTH: SALES to drop a good from neutral (1.0) to the FLOOR (lower = more volatile/visible)
PLB_marketMaxPrem = missionNamespace getVariable ["PLB_marketMaxPrem", 1.3];    // CEIL: a scarce/neglected good tops at 130% of its max
publicVariable "PLB_marketFloor";
publicVariable "PLB_marketMaxPrem";   // client marketFactor reads it (the CEIL) -> publish so live tuning propagates
// per-item overrides [class, dropDepth, ceiling]. House-weed WAX (canna_dab): dropDepth 400 (a 400-unit dump
// drops it to the 60% floor = $240 = anti-hoard) + ceiling 1.0 (best case = its $400 base = ~$120k/maxed-house/
// 3h, no scarcity premium above that). Goods not listed use the globals. Read in the sell hook (eventhandlers),
// the client clamp (life_fnc_marketFactor), and the climb loop below. publicVariable'd so clients clamp the same.
PLB_marketItemOv = missionNamespace getVariable ["PLB_marketItemOv", [["canna_dab", 400, 1.0]]];
publicVariable "PLB_marketItemOv";
// owner 2026-07-08 (DRUG BUST event -- casino wheel "BUST" prize): while PLB_drugBustUntil is in the future, every
// illegal drug in PLB_drugBustGoods sells +12% server-wide (life_fnc_marketFactor stacks it above the ceiling for the
// window). Auto-expires off serverTime (no timer). List + until published so clients apply the same boost.
PLB_drugBustGoods = missionNamespace getVariable ["PLB_drugBustGoods", [
    "cocainep","cokebrick","cocainepure","meth","bluemeth","marijuana","marijuanam","canna_dab","hydro",
    "heroin","heroinp","heroinu","lsd_0","lsd_1","phos","crankp","ephedra"]];
if (isNil "PLB_drugBustUntil") then { PLB_drugBustUntil = 0; };
publicVariable "PLB_drugBustGoods";
publicVariable "PLB_drugBustUntil";

PLB_marketGoods = ["cocainep","cokebrick","cocainepure","diamond","diamondc","diamondf","diamondr",
    "goldbar","goldnugget","pearl","ruby","uraniump","turtle",
    "meth","bluemeth","marijuana","marijuanam","canna_dab","hydro","heroin","heroinp","heroinu",
    "oysterp","oysterfry","lsd_0","lsd_1","phos","crankp","ephedra","scotch_2","scotch_3","rum_3","moonshine","moonshinep","gingerale_0",
    "dog","dogp","goatp","sheep","sheepp","manfleshp","humanscalp",
    "salt_r","iron_r","copper_r","timber","timberh","timberl","plank","oilp","rubber"
    // NEW DRACHMA (owner 2026-07-23): loonycoin REMOVED from the floating market -- coins are no longer a
    // tradable good. Rigs deposit ND straight to the wallet, held coins auto-convert at login, and any
    // straggler sells at the Blackmarket for a FIXED 1 coin = 1 ND (fn_virtualShopManage). No drift.
];
if (isNil "life_price_index" || {!(life_price_index isEqualType [])}) then { life_price_index = []; };
// seed/migrate: every good gets a 3-element row [class, prem, sales]; upgrade any legacy 2-element rows
// (old signed-demand model) by treating them as a fresh floor (prem 1, sales 0).
{private _c = _x;
    private _i = life_price_index findIf {(_x isEqualType []) && {(_x param [0,""]) isEqualTo _c}};
    if (_i < 0) then {life_price_index pushBack [_c, 1, 0];} else {private _r = life_price_index select _i;
        private _prem  = _r param [1, 1]; if (!(_prem isEqualType 0)  || {_prem < PLB_marketFloor}) then { _prem = 1 };   // keep a valid loaded prem (may be <1 from a drop); reset only if invalid/below floor
        private _sales = _r param [2, 0]; if (!(_sales isEqualType 0) || {_sales < 0}) then { _sales = 0 };
        life_price_index set [_i, [_c, _prem, _sales]];};} forEach PLB_marketGoods;
PLB_marketEvents = [];   // legacy client-board var kept empty (no SURGE/GLUT in the premium model)
publicVariable "PLB_marketGoods";
publicVariable "PLB_marketEvents";
publicVariable "life_price_index";

// class-keyed snapshot of last tick's sales, so "sold since last tick?" is order-independent
private _lastSales = life_price_index apply { [_x param [0,""], _x param [2,0]] };
private _tickN = 0;
// singleevh.md: market recompute/publish migrated onto the single-wheel scheduler (id "marketTick", _TICK~90s).
// Cross-iteration state (_lastSales snapshot, _tickN counter) -> per-job state _st; the one-shot boot setup above
// (config read + life_price_index seed + publicVariables) still runs once when this fn is spawned. Runs in the
// wheel's transient spawn (may suspend). Flag OFF => original loop runs byte-for-byte (else branch).
["marketTick", {params ["_st"];
    private _lastSales = _st getOrDefault ["lastSales", life_price_index apply { [_x param [0,""], _x param [2,0]] }];
    private _tickN = (_st getOrDefault ["tickN", 0]) + 1;
    _st set ["tickN", _tickN]; {if (_x isEqualType [] && {count _x >= 3}) then {_x params ["_c", "_prem", "_sales"];
        if (!(_prem isEqualType 0)  || {_prem < PLB_marketFloor}) then { _prem = 1 };
        if (!(_sales isEqualType 0) || {_sales < 0}) then { _sales = 0 };
        private _psi  = _lastSales findIf {(_x select 0) isEqualTo _c};
        private _prev = if (_psi >= 0) then { (_lastSales select _psi) select 1 } else { _sales };
        // idle (no NEW sales since last tick) -> premium climbs; actively-sold -> hold (the crash is
        // handled the moment sales >= PLB_marketCrash in the life_stock_update hook).
        if (_sales <= _prev) then {
            // findIf (NOT forEach) -- a nested forEach here would clobber the outer _forEachIndex used by the
            // `life_price_index set [_forEachIndex,...]` below and write the wrong row.
            private _ovi  = PLB_marketItemOv findIf { (_x select 0) isEqualTo _c };
            private _maxP = if (_ovi >= 0) then { (PLB_marketItemOv select _ovi) param [2, PLB_marketMaxPrem] } else { PLB_marketMaxPrem };
            _prem = (_prem * (1 + PLB_marketRise)) min _maxP;};
        _prem = _prem max PLB_marketFloor;
        life_price_index set [_forEachIndex, [_c, _prem, _sales]];};} forEach life_price_index;
publicVariable "life_price_index";
_lastSales = life_price_index apply { [_x param [0,""], _x param [2,0]] };
    _st set ["lastSales", _lastSales];

if ((_tickN % 10) isEqualTo 0) then {private _smp = (life_price_index param [0, ["?",1,0]]);
    diag_log format ["[PLB_marketTick] alive tick=%1 sample %2", _tickN, _smp];};}, _TICK, false, true] call PLB_fnc_schedule;
