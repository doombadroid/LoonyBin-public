/*
    TON_fnc_transferHouse  (LooneyBin -- implemented 2026-06-09; the passthrough fed
    [player, uid, house, price] into 2017 setOwnerID -> buying a MARKET-LISTED house never transferred
    ownership.)  Client (core/housing/fn_buyHouse.sqf market branch, buyer already paid client-side)
    sends [player, buyerUID, houseObj, buyPrice]. Transfer the row, pay the seller, retag the building.
*/
params [["_buyer", objNull, [objNull]], ["_uid", "", [""]], ["_house", objNull, [objNull]], ["_price", 0, [0]]];
if (isNull _buyer || {_uid isEqualTo ""} || {isNull _house}) exitWith {};
private _id = _house getVariable ["plb_houseID", -1];
if (format ["%1", _id] isEqualTo "-1") exitWith {
    [["The realtor couldn't process the sale (house not registered). Contact staff.", "basic"], "life_fnc_handleMessage", _buyer, false, false] spawn life_fnc_MP;
};
private _seller = _house getVariable ["plb_homeOwner", ""];
private _gangid = _house getVariable ["plb_house_gang", -1];   // case-4 marker handling (gang house vs normal)

// SECURITY (owner 2026-06-17, house-theft hardening — sibling of the fn_addHouse fix): verify SERVER-SIDE that
// this is a real listed resale before overwriting ownership. The DB `sale` column = the listing price (>0 =
// for sale). Block + refund if the row has no real seller, the buyer IS the seller, or it isn't actually
// listed -- so a stale plb_homeOwner / forged call can't transfer an unlisted (or unowned) house = theft.
private _chk = [format ["SELECT QUOTE(COALESCE(owners,'')), QUOTE(COALESCE(sale,'0')) FROM houses WHERE oid='%1'", _id], 2] call DB_fnc_asyncQuery;
private _dbOwner = ""; private _dbSale = 0;
if (_chk isEqualType [] && {count _chk > 1}) then {_dbOwner = format ["%1", _chk select 0];
    _dbSale  = parseNumber format ["%1", _chk select 1];};
if (_dbOwner isEqualTo "" || {_dbOwner isEqualTo "0"} || {_dbOwner isEqualTo _uid} || {_dbSale <= 0}) exitWith {
    diag_log format ["[LooneyBin][transferHouse] BLOCKED illegit transfer: oid=%1 dbOwner=%2 sale=%3 buyer=%4 -- refunded", _id, _dbOwner, _dbSale, _uid];
    ["-HOUSETHEFT-", _uid, format ["BLOCKED transfer of house oid=%1 (owner %2, sale %3) -- not a legit listed resale; refunded", _id, _dbOwner, _dbSale]] call PLB_fnc_logIt;
    [3, _house, _uid, _price, -1] remoteExec ["life_fnc_handleHouse", owner _buyer];};

// PERSIST FIX (owner 2026-06-13): the houses row key is `oid` (varchar position-hash = plb_houseID), NOT the
// auto-increment int `id`. The old `WHERE id='<oid-hash>'` never matched -> the ownership transfer NEVER
// persisted (the shed reverted to the seller on reboot). Match on oid.
// owner 2026-07-10: a resale to a NEW owner drops the previous owner's custom name (custom_name=NULL).
// owner 2026-07-11 (Malden Makeover): a resale also ends the makeover -- malden=0 + restore the original look.
// revert DELETES the shell _house points at and returns the restored original; the retag below must run on THAT.
if (_house getVariable ["plb_malden", false]) then {private _restored = ["revert", _house] call TON_fnc_maldenSRV;
    if (!isNull _restored) then { _house = _restored; };};
[format ["UPDATE houses SET owners='%2', sale='0', keyholders=NULL, custom_name=NULL, malden=0 WHERE oid='%1'", _id, _uid]] call DB_fnc_asyncQuery;

// keep the server-side ownership cache in sync (cleanup + later sell/delete + ownership scans read it)
if (!isNil "life_house_owners") then {
    private _oi = life_house_owners findIf { (format ["%1", _x select 0]) isEqualTo (format ["%1", _id]) };
    if (_oi > -1) then { (life_house_owners select _oi) set [1, _uid]; };};

// retag the building globally BEFORE the client finalizes read it
_house setVariable ["plb_homeOwner", _uid, true];
_house setVariable ["plb_houseName", "", true];   // owner 2026-07-10: new owner starts with the type name, not the seller's custom name
_house setVariable ["salePrice", 0, true];
// owner 2026-06-13: CLEAR the market listing on purchase. fn_buyHouse gates a "for sale" buy on
// plb_house_price > 0 -- transferHouse cleared salePrice/DB sale but NOT plb_house_price, so the house
// stayed buyable at the listed price to everyone else after it sold. Reset it + drop it from the phone-market
// list so the listing dies the instant it's bought (no manual unlist needed).
_house setVariable ["plb_house_price", -1, true];
if (!isNil "life_forSaleHouses") then { life_forSaleHouses = life_forSaleHouses - [_house]; publicVariable "life_forSaleHouses"; };

// SELLER finalize: handleHouse mode 4 removes the house from THEIR client life_houses/life_vehicles + deletes
// their marker AND credits them (_marketPrice). Offline -> credit the DB directly. Pay ONCE: the old code
// double-paid (uC AND the DB UPDATE). mode-4 was never even called before this fix -> seller kept phantom ownership.
if (_seller isNotEqualTo "" && {_price > 0}) then {
    private _sellerObj = allPlayers param [allPlayers findIf { (getPlayerUID _x) isEqualTo _seller }, objNull];
    if (!isNull _sellerObj) then {[4, _house, _seller, _price, _gangid] remoteExec ["life_fnc_handleHouse", owner _sellerObj];} else {
        [format ["UPDATE players SET bankacc = bankacc + %1 WHERE playerid='%2'", _price, _seller]] call DB_fnc_asyncQuery;};};

// BUYER finalize: handleHouse mode 5 registers the house in the buyer's life_houses + life_vehicles, draws the
// owned-property marker, adds the keychain, and (at its top) clears life_houseTxn/life_action_in_use. WITHOUT
// this the buyer could open the menu (plb_homeOwner is global) but had NO life_houses entry -> couldn't place
// objects / open the vehicle garage / see it as owned, and the buy lock stayed stuck. This was the reported bug.
[5, _house, _uid, _price, -1] remoteExec ["life_fnc_handleHouse", owner _buyer];

["-HOUSEBUY-", _buyer, format ["bought house %1 for $%2 from %3", _id, _price, _seller]] call PLB_fnc_logIt;
