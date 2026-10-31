/*
    TON_fnc_srvSellVehicle  (LooneyBin -- ADAPTED from 2017 deleteVehicle)
    client args: [playerUID, plate, _clientPrice(IGNORED)]
    Sell a garaged vehicle: delete the row AND credit the seller's bank with a SERVER-AUTHORITATIVE
    sell-back. SECURITY: the client-sent price is NOT trusted -- the server reads the vehicle's real
    classname + side from the DB and recomputes the sell-back from the vehicle config (life_fnc_vehicleConfig
    "getVehicleRow", idx 8, indexed by the DB side). A modded client can no longer claim an arbitrary
    payout (money dupe), nor inject SQL via the UID.
*/
params [["_uid","",[""]],["_plate",-1,[0]],["_clientPrice",0,[0]]];
if (_uid == "" || _plate < 0) exitWith {};
// SECURITY: _uid is client-supplied and goes into SQL string-formatting -> a modded client could inject.
// A real Steam UID is digits only; reject anything else (closes SQL injection on pid). _plate is Number-typed.
if !(((toArray _uid) findIf {!(_x >= 48 && {_x <= 57})}) isEqualTo -1) exitWith {};

private _FALLBACK_CAP = 500000;     // unknown/custom class: tight cap on the (untrusted) client figure
private _SANITY_CAP   = 10000000;   // final sanity bound (above any legit sell-back; guards a config typo)

// idempotent sell lock -- a concurrent/rapid repeat (double click, laggy resend, injected spam) is rejected
if (isNil "srv_vehSellLocks") then { srv_vehSellLocks = []; };
if ([_uid,_plate] in srv_vehSellLocks) exitWith {};
srv_vehSellLocks pushBack [_uid,_plate];

// authoritative lookup: existence + real class + side in one query (also the row-exists guard)
private _rows = [format ["SELECT QUOTE(classname), QUOTE(side) FROM vehicles WHERE pid='%1' AND plate='%2'", _uid, _plate], 2, true] call DB_fnc_asyncQuery;
if (isNil "_rows" || {!(_rows isEqualType [])}) then { _rows = []; };
if (count _rows == 0) exitWith {        // already sold / not owned -> never credit, release the lock
    srv_vehSellLocks = srv_vehSellLocks - [[_uid,_plate]];};
(_rows select 0) params [["_class","",[""]], ["_sideStr","",[""]]];

// server-computed sell-back from the vehicle config (idx 8), indexed by the DB-recorded side
private _sideIdx = switch (toLower _sideStr) do { case "cop": {1}; case "med": {2}; default {0} };
private _price = -1;
// "getVehicleRow" returns the RAW config entry (no side-unpacking) -> index sell-back (idx 8) by the
// DB-recorded side ourselves. (getVehicleRowParsed unpacks by `playerSide`, which is unreliable on a
// dedicated server and would misprice cop/med vehicles at the civ tier.)
private _row = ["getVehicleRow", "", _class] call life_fnc_vehicleConfig;
// NEW DRACHMA: a vehicle sold in the ND (nd_car) shop MUST sell back in ND, never cash -- otherwise
// buy-cheap-in-ND then sell-for-cash is a money printer (60 ND Ifrit HMG -> 150k cash). Shop keys are
// config row idx 3.
// owner 2026-07-24: also accept the "nd_priced" currency-only sentinel. Pulling a vehicle from the ND shop
// empties its shop-key list, which used to ALSO erase its ND-ness here and reopen the ND-buy/cash-sell
// printer. "nd_priced" marks currency without listing the vehicle in any shop.
private _isND = (_row isEqualType [] && {count _row > 3} && {(_row select 3) isEqualType []} && {("nd_car" in (_row select 3)) || {"nd_priced" in (_row select 3)}});
if (_row isEqualType [] && {count _row > 8}) then {private _raw = _row select 8;
    private _sb = if (_raw isEqualType []) then { _raw param [_sideIdx, (_raw param [0, 0])] } else { _raw };
    // owner sell-back override (priceOv "veh" p1 = idx3) takes precedence if set, matching the client
    private _ov = ["veh", _class] call life_fnc_priceOv;
    if (_ov isNotEqualTo [] && {(_ov param [3, -1]) >= 0}) then { _sb = _ov select 3; };
    if (_sb isEqualType 0) then { _price = round _sb; };};
// unknown/custom class the config doesn't list -> cap the client figure rather than pay it blind
if (_price < 0) then { _price = (round _clientPrice) min _FALLBACK_CAP; };
_price = (_price max 0) min _SANITY_CAP;

[format ["DELETE FROM vehicles WHERE pid='%1' AND plate='%2'", _uid, _plate]] call DB_fnc_asyncQuery;
if (_price > 0) then {private _p = objNull;
    { if (getPlayerUID _x isEqualTo _uid) exitWith { _p = _x; }; } forEach allPlayers;
    if (_isND) then {
        // ND vehicle -> pay the sell-back into the New Drachma wallet at 6000:1 of the config cash sell value
        // (~40% of the ND buy price, matching the cash sell-back convention). No cash ever changes hands.
        private _ndStr = (_price / 6000) toFixed 4;
        if (!isNull _p) then {[_p, _ndStr, "vehsell"] call TON_fnc_ndCreditSrv;   // credits + pushes ndSync
        } else {
            [format ["UPDATE players SET new_drachma = new_drachma + %1 WHERE playerid='%2'", _ndStr, _uid]] call DB_fnc_asyncQuery;   // offline fallback
        };} else {[format ["UPDATE players SET bankacc = bankacc + %1 WHERE playerid='%2'", _price, _uid]] call DB_fnc_asyncQuery;
        if (!isNull _p) then { [["atm", "add", _price], "life_fnc_uC", _p] call life_fnc_MP; };   // client bank sync
    };};

[[_uid,_plate]] spawn { uiSleep 5; srv_vehSellLocks = srv_vehSellLocks - _this; };   // hold the lock 5s past the sell
