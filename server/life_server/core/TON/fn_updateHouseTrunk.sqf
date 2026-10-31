/*
    TON_fnc_updateHouseTrunk  (LooneyBin: persist house storage on trunk close)
    2020 client args : [player, _object]   (fn_openInventory, when a House_F trunk is closed)
    Was a stub passthrough to the 2017 DB_fnc_updateStorage (storage-table model). LooneyBin stores a
    house's storage as vinv/pinv columns on the houses row instead. fn_storeInventory sets plb_vinv/
    plb_pinv GLOBAL (true flag), so the server can read the just-updated values straight off the house
    object and write them, keyed by oid (= plb_houseID).
*/
params [["_player", objNull, [objNull]], ["_object", objNull, [objNull]], ["_vinvArg", [], [[]]], ["_pinvArg", [], [[]]], ["_genArg", -1, [0]]];
if (isNull _object) exitWith {};

// owner 2026-06-23 SECURITY (security.md §2.3 — item dupe): CfgRE-whitelisted -> a client could remoteExec
// arbitrary _vinv/_pinv arrays to write any items/qty into a house storage row; a re-open re-applies them =
// dupe / item creation. Defences: (1) derive the actor from the non-spoofable remoteExecutedOwner; (2) verify
// they OWN or hold a KEY to the house (the legit trunk-access gate, fn_keyHolderStatus); (3) VALIDATE every
// item entry -- real virtual-item classname + positive-integer qty under a per-stack cap -- and recompute the
// weight from the kept items, dropping anything bogus/inflated. The disconnect path ([objNull,_x] with no inv)
// is server-internal (_src==0) and falls through to the trusted object read.
private _src = remoteExecutedOwner;
private _caller = if (_src isEqualTo 0) then { objNull } else { (allPlayers select { owner _x isEqualTo _src }) param [0, objNull] };
if (_src isNotEqualTo 0) then { _player = _caller; };
// FLAT top-level owner/keyholder gate (a nested exitWith inside then{} would only leave the block and fall
// through into the trunk write). For a client call: caller must own the house OR hold a key (the legit
// trunk-access gate, fn_keyHolderStatus). server-internal (_src==0) passes.
// owner 2026-06-23/24: authorize the save. Legit savers = OWNER, a KEYHOLDER, a COP (Seize House Storage routes the
// post-seizure stash through here, side west), OR a GANGMATE of a gang house. The gangmate case was a FALSE POSITIVE
// (-SEC- spam): they can OPEN gang-house storage (fn_openInventory allows gang) but were BLOCKED from SAVING it here
// -> their changes silently reverted. Mirror the open-side gang check (caller's gang == house plb_house_gang).
// server-internal (_src==0) always passes.
private _cuid  = getPlayerUID _caller;
private _hGang = _object getVariable ["plb_house_gang", -1];
private _isAuth = (_src isEqualTo 0)
    || {(format ["%1", _object getVariable ["plb_homeOwner", ""]]) isEqualTo _cuid}
    || {((_object getVariable ["plb_house_keys", []]) findIf { (format ["%1", _x param [0, ""]]) isEqualTo _cuid }) != -1}
    || {side _caller isEqualTo west}
    || {(_hGang isEqualType 0) && {_hGang > 0} && {_hGang isEqualTo ((_caller getVariable ["gang_data", []]) param [0, -99])}};
if (!_isAuth) exitWith {
    ["-SEC-", _caller, format ["BLOCKED updateHouseTrunk (not owner/keyholder/cop/gang) by %1", _cuid]] call PLB_fnc_logIt;};

private _oid = _object getVariable ["plb_houseID", -1];
if (_oid isEqualTo -1) exitWith {};
if !(_oid isEqualType "") then { _oid = str _oid; };
_oid = (format ["%1", _oid]) splitString "\'""" joinString "";   // SQL-escape oid (security.md §2.3)

// owner 2026-06-25 (#542 house wipe -- rapid open/close TOCTOU): if a NEWER open hydrated this house since the
// open THIS close belongs to (plb_invGen advanced past _genArg), this close is STALE. Its delayed dehydrate would
// broadcast plb_vinv/pinv=[[],0] INTO the live newer session (clobbering it to empty), and its payload would
// persist stale data over the newer session. Make it a NO-OP -- the live session owns the data + persists on its
// own close. _genArg<0 = disconnect/legacy/internal path = always proceed. (Belt to the houses_no_wipe DB trigger.)
if (_src isNotEqualTo 0 && {_genArg >= 0} && {(_object getVariable ["plb_invGen", 0]) > _genArg}) exitWith {
    ["-HOUSEINV-", _player, format ["SKIPPED stale house close (open gen %1 < current %2) house %3 -- newer session owns it", _genArg, _object getVariable ["plb_invGen", 0], _oid]] call PLB_fnc_logIt;
};

// validate ONE storage payload [[items], weight]: keep only [realItem, 1..cap] entries, recompute weight
// server-side, return the sanitized [[items], weight]. _isPhys picks the legality oracle:
//   vinv (virtual items)  -> a real virtItemCfg entry (getName != "")              + virt item weight
//   pinv (physical gear)  -> a real missionConfigFile>>CfgWeights entry (weapons/  + physicalInventoryWeight
//                            mags/items the weight table knows)
// This is critical: pinv holds WEAPONS/magazines (NOT virtItems), so validating pinv against virtItemCfg
// would strip every legit gun. (no-op on the disconnect-path object read -- that path doesn't call this.)
// All oracle calls are guarded with !isNil (the codebase's fail-safe convention, e.g. fn_updateVehicle:45):
// life_fnc_* are normally compiled server-side, but if an oracle is momentarily unavailable we DON'T wipe a
// legit player's stash -- we degrade to STRUCTURAL-only validation ([nonEmptyString, posInt<=cap]) which still
// defeats the qty-inflation + garbage-injection dupe (the primary §2.3 vector), and keep the passed weight.
private _STACK_CAP = 100000;   // generous per-item ceiling; blocks the 9.9e8-qty inflation, allows any legit stash
private _fnc_sanitizeInv = {params [["_inv", [[], 0], [[]]], ["_isPhys", false, [false]]];
    private _items = _inv param [0, []];
    if (!(_items isEqualType [])) exitWith { [[], 0] };
    private _haveVirt = !isNil "life_fnc_virtItemCfg";
    private _kept = []; {if (_x isEqualType [] && {count _x >= 2}) then {private _cn  = format ["%1", _x param [0, ""]];
            private _qty = _x param [1, 0];
            if (_cn isNotEqualTo "" && {_qty isEqualType 0} && {_qty == floor _qty} && {_qty > 0}) then {
                private _valid = if (_isPhys) then {
                    // owner 2026-06-24 (DATA LOSS -- player099 + others, house gear vanishing): CfgWeights is the mission
                    // WEIGHT TABLE and is NOT a complete physical-item list (lv4/lv5 vests, many uniforms/backpacks/DLC
                    // items are absent) -> the old `isClass CfgWeights` STRIPPED legit gear on every house save = house
                    // inventory disappearing. Validate against the REAL Arma configs (which DO contain every physical
                    // class): weapons/uniforms/vests/headgear=CfgWeapons, mags=CfgMagazines, backpacks=CfgVehicles,
                    // glasses=CfgGlasses; keep CfgWeights as a fallback. Permissive by design -- the qty cap is the real
                    // dupe defense; this only drops genuinely-fake classnames.
                    isClass (configFile >> "CfgWeapons" >> _cn) || {isClass (configFile >> "CfgMagazines" >> _cn)} || {isClass (configFile >> "CfgVehicles" >> _cn)} || {isClass (configFile >> "CfgGlasses" >> _cn)} || {isClass (missionConfigFile >> "CfgWeights" >> _cn)}
                } else {
                    if (_haveVirt) then { (["getName", _cn] call life_fnc_virtItemCfg) isNotEqualTo "" } else { true }   // oracle nil -> structural-only (keep, don't wipe)
                };
                if (_valid) then { _kept pushBack [_cn, (_qty min _STACK_CAP)]; };};};} forEach _items;
    // recompute weight from the kept items (guarded); fall back to the passed weight if the oracle is absent.
    private _wt = -1;
    if (_isPhys) then {if (!isNil "life_fnc_physicalInventoryWeight") then { _wt = _kept call life_fnc_physicalInventoryWeight; };} else {
        if (_haveVirt) then { private _w = 0; { private _iw = ["getItemWeight", (_x select 0)] call life_fnc_virtItemCfg; if (_iw isEqualType 0) then { _w = _w + (_iw * (_x select 1)); }; } forEach _kept; _wt = _w; };
    };
    if (_wt < 0) then { _wt = (_inv param [1, 0]) max 0; };   // oracle unavailable -> keep the passed weight (non-negative)
    [_kept, _wt]};
// owner 2026-06-19 (HOUSE-STORAGE GUN DUPE -- Jeff Stall, recurrence): the close path now PASSES the closing
// client's AUTHORITATIVE post-take inventory. Reading plb_pinv straight off the object here raced the take's
// async `setVariable [...,true]` -- under load the broadcast hadn't reached the server yet, so we persisted the
// PRE-take inventory (the house KEPT the guns) while the player's gear kept them too = the dupe re-pulled next
// open. Trust the passed inv when present AND re-assert it onto the object (global) so the server's in-memory
// copy matches the DB -> a reopen can't surface the stale full stock. The disconnect path (fn_playerDisconnected
// -> [objNull,_x]) passes NO inv, so it falls back to the object read (correct there: the client is already gone).
private _vinv = _vinvArg;
private _pinv = _pinvArg;
private _vFromArg = (_vinv isNotEqualTo []);
private _pFromArg = (_pinv isNotEqualTo []);
if (!_vFromArg) then { _vinv = _object getVariable ["plb_vinv", [[], 0]]; };
if (!_pFromArg) then { _pinv = _object getVariable ["plb_pinv", [[], 0]]; };
// owner 2026-06-23 SECURITY (security.md §2.3): sanitize a CLIENT-supplied payload (drop fake classnames /
// inflated qty before it's stored + re-applied). The disconnect-path object read is already authoritative
// server state -> only scrub when the inv came from the client arg.
if (_vFromArg) then { _vinv = [_vinv, false] call _fnc_sanitizeInv; };   // virtual items
if (_pFromArg) then { _pinv = [_pinv, true]  call _fnc_sanitizeInv; };   // physical gear (CfgWeights)
// owner 2026-06-24 (DATA LOSS GUARD -- house wipe): a CLIENT that closed a house it never actually loaded (the b0093
// hydrate-display bug: 2nd+ open showed [[],0] because the dehydrate set the client var to [[],0], not nil) would pass
// an EMPTY payload here and OVERWRITE real stored gear. Refuse it: if the house was NOT hydrated this session
// (plb_invHydrated -- set only by a successful TON_fnc_initHouseInventory hydrate, cleared on dehydrate) and the client
// claims a column is empty, keep the authoritative SERVER-LOCAL value (the true pre-close contents) for that column.
// A LEGIT full-take always follows a successful hydrate (flag true), so real emptying still persists. server-internal
// (_src==0, disconnect path) never sets _v/_pFromArg, so it's unaffected.
if (_src isNotEqualTo 0 && {!(_object getVariable ["plb_invHydrated", false])}) then {
    if (_vFromArg && {(_vinv param [0, []]) isEqualTo []}) then {_vinv = _object getVariable ["plb_vinv", [[], 0]];
        ["-SEC-", _caller, format ["SKIPPED empty house vinv write (unhydrated session) house %1 by %2", _oid, _cuid]] call PLB_fnc_logIt;
    };
    if (_pFromArg && {(_pinv param [0, []]) isEqualTo []}) then {_pinv = _object getVariable ["plb_pinv", [[], 0]];
        ["-SEC-", _caller, format ["SKIPPED empty house pinv write (unhydrated session) house %1 by %2", _oid, _cuid]] call PLB_fnc_logIt;
    };};
// re-assert the (sanitized) inv onto the object so the server's in-memory copy matches the DB -> a reopen
// can't surface a stale/forged stock (closes the store->reopen dupe).
// owner 2026-06-23 (B): DEHYDRATE on close. Broadcast EMPTY so the just-closed stash stops being readable by every
// client (the old code re-asserted the real inv GLOBAL = the "free house keys" leak left wide open at rest), THEN
// re-assert the sanitized/persisted inv SERVER-LOCAL so the disconnect-path save + the next gated hydrate read the
// truth. The DB write below is the authoritative persist; the next open re-hydrates from it.
_object setVariable ["plb_invHydrated", false, true];   // close ends the session -> re-arm the empty-write guard
_object setVariable ["plb_vinv", [[], 0], true];
_object setVariable ["plb_pinv", [[], 0], true];
_object setVariable ["plb_vinv", _vinv];   // server-LOCAL real (not broadcast)
_object setVariable ["plb_pinv", _pinv];
// mres-encode + SQL-escape single quotes (defensive; item classnames have none, but keep it uniform)
private _vEnc = (([_vinv] call DB_fnc_mresArray) splitString "'") joinString "''";
private _pEnc = (([_pinv] call DB_fnc_mresArray) splitString "'") joinString "''";
[format ["UPDATE houses SET vinv='%1', pinv='%2' WHERE oid='%3'", _vEnc, _pEnc, _oid]] call DB_fnc_asyncQuery;
