/*
    TON_fnc_updateHousePrice  (LooneyBin -- implemented 2026-06-09; the passthrough fed
    [building, id, player, price] into 2017 updateHouse [oid, locked, worldspace] -> market listing
    prices never persisted (lost every restart; init's for-sale loader reads houses.sale).)
    Client (core/housing/fn_marketSellHouse.sqf) sends [building, dbID, player, listPrice]
    (-1 = de-list).
*/
params [["_building", objNull, [objNull]], ["_id", -1, [0, ""]], ["_unit", objNull, [objNull]], ["_price", -1, [0]]];
// owner 2026-07-24 SECURITY (audit): CfgRE allowedTargets=2 with no authorisation at all -- the house OID
// and the price came straight from the client and _unit was used only for the log line, so any client
// could list ANY house (or, via the injectable _id below, every house) for sale at any price, defeating
// the anti-theft hardening in TON_fnc_transferHouse. Worse, `params` explicitly permits _id to be a
// STRING, and it was concatenated unescaped into the UPDATE -- a crafted id terminates the literal and
// rewrites arbitrary rows.
// Fix: require the NON-SPOOFABLE caller to OWN the building, and take the OID from the building object
// server-side (the same authoritative source fn_bldgUpdateKeys uses) instead of trusting the client's _id.
// A remote caller must therefore supply a real house object it owns. server-internal (_src == 0) passes.
private _src = remoteExecutedOwner;   // 0 == server-internal = trusted
private _caller = if (_src isEqualTo 0) then { objNull } else { (allPlayers select { owner _x isEqualTo _src }) param [0, objNull] };
private _blocked = false;
if (_src isNotEqualTo 0) then {
    if (isNull _caller || {isNull _building} || {(_building getVariable ["plb_homeOwner", ""]) isNotEqualTo (getPlayerUID _caller)}) then {
        ["-SEC-", _caller, format ["BLOCKED updateHousePrice (caller %1 is not the owner; id arg '%2', price %3)",
            getPlayerUID _caller, _id, _price]] call PLB_fnc_logIt;
        _blocked = true;   // signal; a nested exitWith would only leave this then-block
    } else {_id = _building getVariable ["plb_houseID", -1];   // authoritative oid -- never the client's value
    };};
if (_blocked) exitWith {};
if (format ["%1", _id] in ["-1", ""]) exitWith {};
// SQL-escape regardless of origin (security.md 2.3) -- _id is String-typed by params
_id = (format ["%1", _id] splitString "\'""") joinString "";
if (_id isEqualTo "") exitWith {};
// owner 2026-06-19 (HOUSES BROKEN -- Jeff Stall): _id is the house OID (plb_houseID, a position-hash like
// 1462020928), NOT the auto-increment PK `id` (305/306/...). `WHERE id='<oid>'` matched ZERO rows, so a listing
// NEVER wrote houses.sale -> it stayed 0 -> TON_fnc_transferHouse (reads sale WHERE oid) saw sale=0 and BLOCKED
// every buyer as "not a legit listed resale" = nobody could buy any listed house. Same id/oid bug class as #374.
// Match on oid (the same key transferHouse/srvSellHouse use).
[format ["UPDATE houses SET sale='%2' WHERE oid='%1'", _id, _price max 0]] call DB_fnc_asyncQuery;
if (!isNull _building) then { _building setVariable ["salePrice", _price max 0, true]; };
["-HOUSELIST-", _unit, format ["house %1 listed at $%2", _id, _price]] call PLB_fnc_logIt;
