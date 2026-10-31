/*
    TON_fnc_initHouseInventory  (LooneyBin: GATED house-storage hydration -- security.md §"free house keys")
    2020 client args : [_house, _houseID, _mode]   (_mode default "hydrate"; "dehydrate" used by cop search/seize)

    owner 2026-06-23 (option B): house storage (plb_vinv/plb_pinv) is NO LONGER broadcast at rest -- fn_receiveHouses
    now sets it SERVER-LOCAL, so a client can't read another player's stash off the object (the publicly-bragged
    "free house keys" exploit). This fn is the single hydration chokepoint:
      * HYDRATE  -> verify the NON-spoofable caller (remoteExecutedOwner) is the owner / a keyholder / a gangmate of
                    a gang house / a cop, then broadcast the real contents GLOBAL for the open session. A non-authorized
                    caller is denied (-SEC-) and gets nothing. Server-internal calls (_src==0) are trusted.
      * DEHYDRATE-> broadcast EMPTY to every client, then restore the server-LOCAL cache from the DB (so the
                    disconnect-path save in fn_updateHouseTrunk still reads true contents server-side). fn_updateHouseTrunk
                    dehydrates the owner/keyholder close path; cop search/seize call this mode when done.
    The take/store/refresh machinery + the anti-dupe trunk-lock timing are UNTOUCHED (they operate on the hydrated
    global var during the session exactly as before) -- B deliberately avoids that fragile, dupe-prone code.
*/
params [["_house", objNull, [objNull]], ["_houseID", "", ["", 0]], ["_mode", "hydrate", [""]]];
if (isNull _house) exitWith {};
// owner 2026-07-24 SECURITY (audit): the hydrate gate below authorises against the HOUSE OBJECT, but the
// DB read keyed on _oid, which came from the SEPARATE client argument _houseID and was never compared to
// the authorised house. So: own a cheap house H, call with _house = H (auth passes) and _houseID = the
// VICTIM's oid -> _loadInv reads the victim's vinv/pinv and lines 69-70 broadcast them onto H, where the
// attacker simply takes them. The close then persists to H's own oid, so the items are duplicated out
// while the victim's row looks untouched. _oid was also interpolated unescaped into the SELECT (SQLi), and
// the "dehydrate" branch exits BEFORE the auth block, so it took the same foreign oid with no check.
// Fix: derive the oid from the house OBJECT (the same authoritative source fn_updateHouseTrunk uses), so
// the authorised house and the queried row can no longer differ. The client's _houseID is now only a
// fallback for server-internal callers (_src == 0), and the value is quote-stripped either way.
private _srcOid = remoteExecutedOwner;   // 0 == server-internal = trusted
private _oid = format ["%1", _house getVariable ["plb_houseID", -1]];
if (_srcOid isEqualTo 0 && {_oid in ["-1", ""]}) then { _oid = format ["%1", _houseID]; };
_oid = (_oid splitString "\'""") joinString "";   // SQL-escape (security.md 2.3)

// load [vinv, pinv] from the houses row (the authoritative store; written on every trunk close).
private _loadInv = {private _v = [[], 0]; private _p = [[], 0];
    if (_oid != "" && {_oid != "-1"}) then {
        private _row = [format ["SELECT vinv,pinv FROM houses WHERE oid='%1'", _oid], 2] call DB_fnc_asyncQuery;
        if (!isNil "_row" && {!(_row isEqualTo [])}) then {private _dec = {params [["_s", "", [""]]];
                if (isNil "_s" || {_s isEqualTo ""} || {_s isEqualTo "NULL"}) exitWith {[]};
                private _a = [_s] call DB_fnc_mresToArray;
                if (typeName _a == "STRING") then { _a = parseSimpleArray (format ["%1", _a]); };
                if (isNil "_a") then { _a = []; };
                _a};
            private _vd = [_row select 0] call _dec; if !(_vd isEqualTo []) then { _v = _vd; };
            private _pd = [_row select 1] call _dec; if !(_pd isEqualTo []) then { _p = _pd; };};};
    [_v, _p]};

// DEHYDRATE: clear the broadcast (clients go empty), then re-assert the true contents SERVER-LOCAL only.
if (_mode isEqualTo "dehydrate") exitWith {
    _house setVariable ["plb_invHydrated", false, true];   // session over -> updateHouseTrunk's empty-write guard re-arms
    _house setVariable ["plb_vinv", [[], 0], true];
    _house setVariable ["plb_pinv", [[], 0], true];
    ([] call _loadInv) params ["_v", "_p"];
    _house setVariable ["plb_vinv", _v];   // server-LOCAL real (disconnect-path save reads this)
    _house setVariable ["plb_pinv", _p];};

// HYDRATE: authorize the caller unless this is a server-internal call (_src == 0 = trusted, e.g. ghrefresh).
private _src = remoteExecutedOwner;
if (_src isNotEqualTo 0) then {private _caller = (allPlayers select { owner _x isEqualTo _src }) param [0, objNull];
    if (isNull _caller) exitWith {};
    private _uid = getPlayerUID _caller;
    private _isOwner = ((_house getVariable ["plb_homeOwner", ""]) isEqualTo _uid);
    private _isKey   = ((_house getVariable ["plb_house_keys", []]) findIf { (format ["%1", _x param [0, ""]]) isEqualTo _uid }) != -1;
    private _hGang   = _house getVariable ["plb_house_gang", -1];
    private _isGang  = (_hGang isEqualType 0) && {_hGang > 0} && {_hGang isEqualTo ((_caller getVariable ["gang_data", []]) param [0, -1])};
    private _isCop   = (side _caller isEqualTo west);   // cop house Search/Seize (copLevel gate is on the client action)
    if !(_isOwner || _isKey || _isGang || _isCop) exitWith {
        ["-SEC-", _caller, format ["BLOCKED house-inv hydrate (not owner/keyholder/gang/cop) house %1 by %2", _house getVariable ["plb_houseID", -1], _uid]] call PLB_fnc_logIt;
    };};

([] call _loadInv) params ["_vinv", "_pinv"];
_house setVariable ["plb_vinv", _vinv, true];   // broadcast real contents for the open session
_house setVariable ["plb_pinv", _pinv, true];
// owner 2026-06-24: mark this house HYDRATED for the session. updateHouseTrunk refuses to persist an EMPTY client
// payload unless this flag is set -> a close that never actually loaded the contents (denied/failed hydrate, the
// display bug) can no longer wipe the stored row. Cleared on dehydrate (close/seize) so the guard re-arms each session.
_house setVariable ["plb_invHydrated", true, true];
// owner 2026-06-25 (#542 house wipe): bump a per-house SESSION token on every hydrate. A close carries the gen of
// the open it belongs to; if a NEWER open hydrated since (gen advanced), TON_fnc_updateHouseTrunk no-ops that stale
// close so its delayed dehydrate broadcast can't clobber the live session's contents to empty (= the wipe).
_house setVariable ["plb_invGen", (_house getVariable ["plb_invGen", 0]) + 1, true];
