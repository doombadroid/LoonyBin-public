/*
    TON_fnc_addHouse  (LooneyBin: 2020 house purchase)
    2020 client args : [player, getPlayerUID player, _house, _buyPrice]   (fn_buyHouse)
    The 2017 file was a passthrough to DB_fnc_insertHouse (params [oid,uid,locked,worldspace]); the
    2020 args don't line up (oid=player object, locked=house object, worldspace=price) -> garbage row
    AND it never told the client -> plb_houseID stayed -1, house never registered ("can't buy houses").
    Now: compute the building id the SAME way the client's life_fnc_getBuildID does (getPosWorld x/y
    hash) so client+server agree -> INSERT the row -> stamp the id vars on the house (global) -> call
    life_fnc_handleHouse mode 1 on the buyer (sets plb_homeOwner, marker, life_houses, keychain).
    NB: life_fnc_handleHouse MUST be whitelisted in CfgRE.hpp (mode=1) or the engine blocks this call.
*/
if (life_server_training) exitWith {};
params [["_player", objNull, [objNull]], ["_uid", "", [""]], ["_house", objNull, [objNull]], ["_price", 0, [0]], ["_vcap", 0, [0]], ["_phys_cap", 0, [0]]];
if (isNull _player || isNull _house || _uid isEqualTo "") exitWith {};

// building id = getPosWorld x/y hash (matches life_fnc_getBuildID's fallback). Keep it a STRING, NOT
// parseNumber: the hash (e.g. 1403618708) exceeds Arma's float-exact range (2^24), so a numeric oid is
// lossy -> (a) formats into SQL as "1.40362e+09" (storage.houseid is INT, never matches) and (b)
// COLLIDES for houses a few metres apart (both round to the same float) -> selling/deleting one nukes
// the other. The string concat of the two rounded coords is exact and distinct.
private _p = getPosWorld _house;
private _oid = format ["%1%2", round (_p select 0), round (_p select 1)];
// CLinitHouses parseSimpleArray's worldspace on load; handleHouse keys life_houses by str(getPosATL)
private _ws = str (getPosATL _house);
diag_log format ["LB_HOUSE_BUY uid=%1 type=%2 oid=%3 ws=%4 price=%5", _uid, typeOf _house, _oid, _ws, _price];

// SECURITY (owner 2026-06-17, insider-reported house THEFT): the client buy gate (fn_buyHouse) only rejects
// an owned house when plb_homeOwner != "" -- but that var is EMPTY whenever the real owner is offline / the
// boot ownership-tag raced (the SAME #305/#307 timing). Empty -> the buy slips through and the write below
// OVERWRITES the real owner = you "buy" someone's house out from under them (for a nearby for-sale price).
// Re-check ownership SERVER-SIDE (authoritative) BEFORE writing: if this oid is already owned by a DIFFERENT
// player, refund the buyer (handleHouse mode 3 = "denied, already owned, money returned") and ABORT untouched.
private _own = [format ["SELECT QUOTE(COALESCE(owners,'')) FROM houses WHERE oid='%1'", _oid], 2] call DB_fnc_asyncQuery;
private _curOwner = if (_own isEqualType [] && {count _own > 0}) then { format ["%1", _own select 0] } else { "" };
if (_curOwner isNotEqualTo "" && {_curOwner isNotEqualTo "0"} && {_curOwner isNotEqualTo _uid}) exitWith {
    diag_log format ["[LooneyBin][addHouse] BLOCKED house THEFT: uid=%1 tried to BUY oid=%2 already owned by %3 -- refunded + aborted", _uid, _oid, _curOwner];
    ["-HOUSETHEFT-", _uid, format ["BLOCKED buy of already-owned house (oid=%1, real owner %2) -- refunded buyer", _oid, _curOwner]] call PLB_fnc_logIt;
    [3, _house, _uid, _price, -1] remoteExec ["life_fnc_handleHouse", owner _player];};

// INSERT ... ON DUPLICATE KEY UPDATE -- NOT REPLACE. extDB3 runs multi-threaded (Threads=0,
// maxSessions=-1) so async fire-and-forget queries on the SAME row execute OUT OF ORDER. REPLACE =
// DELETE+INSERT, so when a player bought/set up a house and then gave a key (or stored items / upgraded)
// seconds later, this buy write could land AFTER those UPDATEs and WIPE them -- the #307 root: house keys
// given shortly after the buy vanished (keyholders re-NULL'd), and same for vinv/pinv/greenhouse_crop/tax.
// (Confirmed: a key given 68s after buy was lost; one given 29min after the buy survived.) INSERT..ODKU
// never deletes the row; on an oid collision it only re-asserts the IDENTITY columns (owner/worldspace/
// instance, which don't change), so a late-landing buy can no longer clobber later per-column writes.
// Fresh buy (no row) still INSERTs the full row: base caps from houseConfig, keycap/upgrade flags 0,
// keyholders/vinv/pinv NULL (-> [] / [[],0] on load). Resale re-buys hit the INSERT path (sell DELETEs
// the row first), so the ODKU branch only ever fires for the same-owner buy/UPDATE race.
// owner 2026-06-17: the ODKU owners-update is CONDITIONAL -- only (re)assert ownership if the row is currently
// unowned or already this buyer's. Atomic backstop to the pre-check above: even if two buys race, the SQL can
// never overwrite a DIFFERENT player's ownership (house theft). Same-owner re-assert still works (#307 race).
// owner 2026-07-10: ALSO write classname at buy time (typeOf the bought building -- the intact shed for
// shed buys). It was left NULL here, and the tag pass only self-healed classname for rows it could RESOLVE;
// an industrial shed with no classname fell to the House_F fallback (sheds aren't House_F) and never
// resolved -> a freshly-bought shed stayed untagged after every restart (dev row 488 "Test"). Belt +
// suspenders with the tagger's new position-probe shed detection (fn_tagHousesSRV).
[format ["INSERT INTO houses (oid, owners, locked, worldspace, instance, vcap, phys_cap, keycap, barrel, greenhouse, leadcontainer, classname) VALUES ('%1','%2','1','%3','%4','%5','%6','0','0','0','0','%7') ON DUPLICATE KEY UPDATE owners=IF(owners='' OR owners IS NULL OR owners=VALUES(owners), VALUES(owners), owners), worldspace=VALUES(worldspace), instance=VALUES(instance), classname=VALUES(classname)", _oid, _uid, _ws, life_server_instance, _vcap, _phys_cap, typeOf _house]] call DB_fnc_asyncQuery;

// register server-side (cleanup/ownership scans read life_house_owners) + stamp id vars the client reads
if (isNil "life_house_owners") then { life_house_owners = []; };
// worldspace stored as the position ARRAY (not _ws string) to match receiveHouses' boot-load entries,
// so deleteHouse's `str (_x select 2)` position-match works when this house is later sold.
life_house_owners pushBack [_oid, _uid, getPosATL _house];
_house setVariable ["plb_houseID", _oid, true];
_house setVariable ["plb_buildID", _oid, true];
_house setVariable ["houseId", _oid, true];

// tell the buyer: mode 1 = bought (sets plb_homeOwner/locked/inv, marker, life_houses, keychain msg)
[1, _house, _uid, _price, -1] remoteExec ["life_fnc_handleHouse", owner _player];
