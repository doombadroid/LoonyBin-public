/*
    TON_fnc_exchangeSystemSRV  (LooneyBin -- FULL IMPLEMENTATION 2026-06-09; was a passthrough into a
    2017 market-price fn -> the ENTIRE player Exchange was dead.)
    Row states (exchange table): active=1 live listing (pid=seller) · active=2 STORAGE row
      (pid=storage owner; BuyorSell 1=purchased [from_pid=seller], 2=retracted/expired).
    isWeapon doubles as the client's isPhysical flag. Money: creators/buyers deduct CLIENT-side
    (fees + purchase price); the server pays the SELLER (online uC / offline bank UPDATE).
    Client protocol (core/exchange/*):
      [1|3, [1, unit, uid, class, price, qty, fee]]       create virtual(1)/physical(3) listing
      [1|3, [2, exID, unit, class, price, wanted]]        buy from listing (partial ok)
      [2, [1, unit, uid, class, price, plate, veh, fee]]  list a garage vehicle
      [2, [2, exID, unit, class, price]]                  buy a vehicle listing
      [4, [exID, unit, uid, class]]                       retract own listing -> storage (veh -> garage)
      [5, [0, uid, unit]] / [5, [1, uid, unit, search]]   fetch all+owned+caps
      [6, [0, uid, unit]]                                 fetch storage (purchased + failed/retracted)
      [6, [1, uid, unit, storageID, [class, newQty]]]     withdraw (client already took the items)
      [7, [0|1, uid, unit]]                               fetch owned listings
    Replies via life_fnc_netSetVar (all exchange vars are on its approved list).
*/
params [["_mode", -1, [0]], ["_data", [], [[]]]];

private _san = { (format ["%1", _this]) splitString "\'""" joinString "" };
private _num = { parseNumber (format ["%1", _this]) };
private _hoursLeft = { params ["_t"]; private _h = (168 - _t) max 0; [floor (_h / 24), _h mod 24] };   // owner 2026-06-23: 7-day expiry (168h) to match the UI (was 120h/5d)
private _elapsed   = { params ["_t"]; private _e = _t max 0; [floor (_e / 24), _e mod 24] };   // owner 2026-06-23: created-ago [days,hours] for listing field 12 (was hardcoded [0,0] -> client showed no real "Created" time)

private _rowToListing = {params ["_r"];
    private _t = (_r select 10) call _num;   // timer (hours since listed)
    [(_r select 0) call _num, format ["%1", _r select 1], format ["%1", _r select 2], format ["%1", _r select 3],
     (_r select 4) call _num, (_r select 5) call _num, (_r select 6) call _num, (_r select 7) call _num,
     (_r select 8) call _num, (_r select 9) call _num, [_t] call _hoursLeft, [_t] call _elapsed]};
private _fetchListings = {params ["_uid", "_unit", ["_search", ""]];
    private _where = "active='1'";
    if (_search isNotEqualTo "") then { _where = _where + format [" AND (ClassName LIKE '%2%1%2' OR name LIKE '%2%1%2')", _search call _san, "%"]; };
    private _rows = [format ["SELECT ID, QUOTE(pid), QUOTE(name), QUOTE(ClassName), COALESCE(VehicleID,0), Price, Amount, isVirtual, isWeapon, isVehicle, timer FROM exchange WHERE %1 ORDER BY ID DESC LIMIT 100", _where], 2, true] call DB_fnc_asyncQuery;
    private _all = []; private _own = []; private _caps = [0, 0, 0];
    if (_rows isEqualType []) then {{private _l = [_x] call _rowToListing;
            _all pushBack _l;
            if ((_l select 1) isEqualTo _uid) then {_own pushBack _l;
                if ((_l select 7) isEqualTo 1) then { _caps set [0, (_caps select 0) + 1]; };
                if ((_l select 9) isEqualTo 1) then { _caps set [1, (_caps select 1) + 1]; };
                if ((_l select 8) isEqualTo 1) then { _caps set [2, (_caps select 2) + 1]; };};} forEach _rows;};
    if (_search isNotEqualTo "") then {
        // owner 2026-06-23 (bug C): a SEARCH (mode 5 sub 1) feeds life_exchangeSpecificedListing -- the "Searched"
        // tab reads THAT (fn_exchangeMenuFilter case == life_exchangeSelectedResource). It had ZERO server writers
        // before, so per-item search was always empty. Don't clobber the full All/Owned/caps lists on a search.
        [["life_exchangeSpecificedListing", _all], "life_fnc_netSetVar", _unit, false, false] spawn life_fnc_MP;} else {
        [["life_exchangeAllListings", _all], "life_fnc_netSetVar", _unit, false, false] spawn life_fnc_MP;
        [["life_exchangePlayerOwnedListings", _own], "life_fnc_netSetVar", _unit, false, false] spawn life_fnc_MP;
        [["life_exchangeMaxListings", _caps], "life_fnc_netSetVar", _unit, false, false] spawn life_fnc_MP;};
    [["life_exchangeRequested", true], "life_fnc_netSetVar", _unit, false, false] spawn life_fnc_MP;};
private _fetchStorage = {params ["_uid", "_unit"];
    private _rows = [format ["SELECT ID, QUOTE(pid), QUOTE(from_pid), QUOTE(ClassName), Amount, Price, isVirtual, isWeapon, BuyorSell, bought_at, UNIX_TIMESTAMP() FROM exchange WHERE active='2' AND pid='%1' ORDER BY ID DESC LIMIT 60", _uid], 2, true] call DB_fnc_asyncQuery;
    private _stor = []; private _failed = []; private _caps = [0, 0];
    if (_rows isEqualType []) then {{private _age = (((_x select 10) call _num) - ((_x select 9) call _num)) max 0;
            private _row = [(_x select 0) call _num, format ["%1", _x select 1], format ["%1", _x select 2], format ["%1", _x select 3],
                            (_x select 4) call _num, (_x select 5) call _num, (_x select 6) call _num, (_x select 7) call _num,
                            (1209600 - _age) max 0, _age];
            if (((_x select 8) call _num) isEqualTo 2) then { _failed pushBack _row; } else { _stor pushBack _row; };
            if ((_row select 6) isEqualTo 1) then { _caps set [0, (_caps select 0) + 1]; };
            if ((_row select 7) isEqualTo 1) then { _caps set [1, (_caps select 1) + 1]; };} forEach _rows;};
    [["life_exchangeStorage", _stor], "life_fnc_netSetVar", _unit, false, false] spawn life_fnc_MP;
    [["life_exchangeFailedListings", _failed], "life_fnc_netSetVar", _unit, false, false] spawn life_fnc_MP;
    [["life_exchangeStorageMaxListings", _caps], "life_fnc_netSetVar", _unit, false, false] spawn life_fnc_MP;
    [["life_exchangeStorageRequested", true], "life_fnc_netSetVar", _unit, false, false] spawn life_fnc_MP;};
private _paySeller = {params ["_sellerUID", "_amount", "_what"];
    if (_sellerUID isEqualTo "" || {_amount <= 0}) exitWith {};
    private _s = allPlayers param [allPlayers findIf { (getPlayerUID _x) isEqualTo _sellerUID }, objNull];
    if (!isNull _s) then {[["atm", "add", _amount], "life_fnc_uC", _s, false, false] spawn life_fnc_MP;
        [[format ["Exchange sale: %1 sold for $%2!", _what, [_amount] call life_fnc_numberText], "basic"], "life_fnc_handleMessage", _s, false, false] spawn life_fnc_MP;
    } else {[format ["UPDATE players SET bankacc = bankacc + %1 WHERE playerid='%2'", _amount, _sellerUID]] call DB_fnc_asyncQuery;};};

switch (_mode) do {
    // ---- create (1 virtual / 3 physical) OR buy ----
    case 1;
    case 3: {private _isPhys = _mode isEqualTo 3;
        if ((_data param [0, 0]) isEqualTo 1) then {            // CREATE
            _data params ["", ["_unit", objNull, [objNull]], ["_uid", "", [""]], ["_class", "", [""]], ["_price", 0, [0]], ["_qty", 0, [0]], ["_fee", 0, [0]]];
            if (isNull _unit || {_class isEqualTo ""} || {_price <= 0} || {_qty <= 0}) exitWith {};
            _uid = getPlayerUID _unit;   // owner 2026-06-23 SECURITY (security.md §2.3): derive UID server-side; the client _uid went RAW into SQL (`' OR '1'='1` injection). Listing owner = the acting player, so this is also the correct value.
            private _cnt = [format ["SELECT COUNT(*) FROM exchange WHERE active='1' AND pid='%1' AND isVirtual='%2' AND isWeapon='%3'", _uid, [1, 0] select _isPhys, [0, 1] select _isPhys], 2] call DB_fnc_asyncQuery;
            if ((format ["%1", _cnt param [0, 0]] call _num) >= 5) exitWith {
                [["atm", "add", _fee], "life_fnc_uC", _unit, false, false] spawn life_fnc_MP;   // refund the fee
                [["You already have 5 listings of that type -- fee refunded.", "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
            };
            [format ["INSERT INTO exchange (ClassName, Price, isVirtual, isWeapon, isVehicle, Amount, pid, BuyorSell, name, active, timer) VALUES ('%1','%2','%3','%4','0','%5','%6','0','%7','1','0')",
                _class call _san, _price, [1, 0] select _isPhys, [0, 1] select _isPhys, _qty, _uid, (name _unit) call _san]] call DB_fnc_asyncQuery;
            [[format ["Listing created: %1 x%2 at $%3.", _class, _qty, [_price] call life_fnc_numberText], "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
            ["-EXCHANGE-", _unit, format ["listed %1 x%2 @ $%3 (fee %4)", _class, _qty, _price, _fee]] call PLB_fnc_logIt;
            [_uid, _unit] call _fetchListings;
        } else {                                                 // BUY (buyer already paid client-side)
            _data params ["", ["_exID", -1, [0]], ["_unit", objNull, [objNull]], ["_class", "", [""]], ["_price", 0, [0]], ["_wanted", 0, [0]]];
            if (isNull _unit || {_exID < 0} || {_wanted <= 0}) exitWith {};
            private _buyerUID = getPlayerUID _unit;
            private _row = [format ["SELECT QUOTE(pid), Amount, Price, isVirtual, isWeapon FROM exchange WHERE ID='%1' AND active='1'", _exID], 2] call DB_fnc_asyncQuery;
            if (!(_row isEqualType []) || {count _row < 5}) exitWith {
                [["atm", "add", _price * _wanted], "life_fnc_uC", _unit, false, false] spawn life_fnc_MP;   // refund: listing vanished
                [["That listing no longer exists -- refunded.", "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
                [_buyerUID, _unit] call _fetchListings;};
            private _seller = format ["%1", _row select 0];
            private _have = (_row select 1) call _num;
            // owner 2026-06-23 SECURITY (security.md §2.1 CRIT): pay the seller from the SERVER-STORED listing
            // Price (_row select 2), NEVER the client-sent _price. The old `_price*_take` minted money to a
            // colluding/self seller (buyer debit is client-side, so a scripter pays nothing and the seller is
            // credited an arbitrary figure). The buyer-side REFUNDS below still use _price -- harmless, they only
            // return money to the caller (who, as a scripter, never paid it; a legit buyer gets their own change).
            private _srvPrice = (_row select 2) call _num;
            private _take = _wanted min _have;
            if (_take < _wanted) then {   // partial stock: refund the difference (buyer-side, client figure OK)
                [["atm", "add", _price * (_wanted - _take)], "life_fnc_uC", _unit, false, false] spawn life_fnc_MP;};
            if (_take >= _have) then {[format ["DELETE FROM exchange WHERE ID='%1'", _exID]] call DB_fnc_asyncQuery;} else {
                [format ["UPDATE exchange SET Amount=Amount-%2 WHERE ID='%1'", _exID, _take]] call DB_fnc_asyncQuery;};
            [format ["INSERT INTO exchange (ClassName, Price, isVirtual, isWeapon, isVehicle, Amount, pid, BuyorSell, name, active, timer, from_pid, bought_at) VALUES ('%1','%2','%3','%4','0','%5','%6','1','%7','2','0','%8',UNIX_TIMESTAMP())",
                _class call _san, _srvPrice, (_row select 3) call _num, (_row select 4) call _num, _take, _buyerUID, (name _unit) call _san, _seller]] call DB_fnc_asyncQuery;
            [_seller, _srvPrice * _take, format ["%1 x%2", _class, _take]] call _paySeller;
            [[format ["Purchased %1 x%2 -- collect it from your Exchange Storage!", _class, _take], "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
            ["-EXCHANGE-", _unit, format ["bought %1 x%2 @ $%3 from %4 (listing %5)", _class, _take, _price, _seller, _exID]] call PLB_fnc_logIt;
            [_buyerUID, _unit] call _fetchListings;
            [_buyerUID, _unit] call _fetchStorage;};};
    // ---- vehicles ----
    case 2: {if ((_data param [0, 0]) isEqualTo 1) then {            // LIST a garage vehicle
            _data params ["", ["_unit", objNull, [objNull]], ["_uid", "", [""]], ["_class", "", [""]], ["_price", 0, [0]], ["_plate", 0, [0]], ["_veh", objNull], ["_fee", 0, [0]]];
            if (isNull _unit || {_price <= 0}) exitWith {};
            _uid = getPlayerUID _unit;   // owner 2026-06-23 SECURITY (security.md §2.3): server-derive UID (no raw client UID in SQL) -- also enforces "you can only list YOUR OWN garage vehicle" (pid='_uid' match).
            private _vr = [format ["SELECT id FROM vehicles WHERE pid='%1' AND plate='%2' AND alive='1' LIMIT 1", _uid, _plate], 2] call DB_fnc_asyncQuery;
            if (!(_vr isEqualType []) || {_vr isEqualTo []}) exitWith {
                [["atm", "add", _fee], "life_fnc_uC", _unit, false, false] spawn life_fnc_MP;
                [["That vehicle couldn't be found in your garage -- fee refunded.", "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
            };
            private _vid = format ["%1", _vr param [0, -1]] call _num;
            [format ["UPDATE vehicles SET listed='1' WHERE id='%1'", _vid]] call DB_fnc_asyncQuery;
            [format ["INSERT INTO exchange (ClassName, Price, isVirtual, isWeapon, isVehicle, Amount, pid, BuyorSell, name, active, timer, VehicleID) VALUES ('%1','%2','0','0','1','1','%3','0','%4','1','0','%5')",
                _class call _san, _price, _uid, (name _unit) call _san, _vid]] call DB_fnc_asyncQuery;
            [[format ["Vehicle listed on the Exchange at $%1.", [_price] call life_fnc_numberText], "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
            ["-EXCHANGE-", _unit, format ["listed vehicle %1 (veh %2) @ $%3", _class, _vid, _price]] call PLB_fnc_logIt;
            [_uid, _unit] call _fetchListings;
        } else {                                                 // BUY a vehicle (buyer paid client-side; garage cap pre-checked)
            _data params ["", ["_exID", -1, [0]], ["_unit", objNull, [objNull]], ["_class", "", [""]], ["_price", 0, [0]]];
            if (isNull _unit || {_exID < 0}) exitWith {};
            private _buyerUID = getPlayerUID _unit;
            private _row = [format ["SELECT QUOTE(pid), COALESCE(VehicleID,-1), Price FROM exchange WHERE ID='%1' AND active='1' AND isVehicle='1'", _exID], 2] call DB_fnc_asyncQuery;
            if (!(_row isEqualType []) || {count _row < 3}) exitWith {
                [["atm", "add", _price], "life_fnc_uC", _unit, false, false] spawn life_fnc_MP;
                [["That vehicle listing no longer exists -- refunded.", "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
            };
            private _seller = format ["%1", _row select 0];
            private _vid = (_row select 1) call _num;
            [format ["UPDATE vehicles SET pid='%2', listed='0', active='0' WHERE id='%1'", _vid, _buyerUID]] call DB_fnc_asyncQuery;
            [format ["DELETE FROM exchange WHERE ID='%1'", _exID]] call DB_fnc_asyncQuery;
            [_seller, (_row select 2) call _num, format ["vehicle %1", _class]] call _paySeller;
            [[format ["Vehicle purchased! It's waiting in your garage."], "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
            ["-EXCHANGE-", _unit, format ["bought vehicle %1 (veh %2, listing %3) from %4", _class, _vid, _exID, _seller]] call PLB_fnc_logIt;
            [_buyerUID, _unit] call _fetchListings;};};
    // ---- retract own listing ----
    case 4: {_data params [["_exID", -1, [0]], ["_unit", objNull, [objNull]], ["_uid", "", [""]], ["_class", "", [""]]];
        if (isNull _unit || {_exID < 0}) exitWith {};
        _uid = getPlayerUID _unit;   // owner 2026-06-23 SECURITY (security.md §2.3): server-derive UID -> the "not yours" ownership check below now compares the listing's pid to the REAL caller (was a client-supplied string a scripter could match to retract anyone's listing) + no raw UID in SQL.
        private _row = [format ["SELECT QUOTE(pid), isVehicle, COALESCE(VehicleID,-1) FROM exchange WHERE ID='%1' AND active='1'", _exID], 2] call DB_fnc_asyncQuery;
        if (!(_row isEqualType []) || {count _row < 3}) exitWith {};
        if ((format ["%1", _row select 0]) isNotEqualTo _uid) exitWith {};   // not yours
        if (((_row select 1) call _num) isEqualTo 1) then {
            [format ["UPDATE vehicles SET listed='0' WHERE id='%1'", (_row select 2) call _num]] call DB_fnc_asyncQuery;
            [format ["DELETE FROM exchange WHERE ID='%1'", _exID]] call DB_fnc_asyncQuery;
            [["Vehicle listing retracted -- it's back in your garage.", "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
        } else {
            [format ["UPDATE exchange SET active='2', BuyorSell='2', bought_at=UNIX_TIMESTAMP() WHERE ID='%1'", _exID]] call DB_fnc_asyncQuery;
            [["Listing retracted -- collect the goods from your Exchange Storage.", "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
        };
        ["-EXCHANGE-", _unit, format ["retracted listing %1 (%2)", _exID, _class]] call PLB_fnc_logIt;
        [_uid, _unit] call _fetchListings;
        [_uid, _unit] call _fetchStorage;};
    // ---- fetches ----
    case 5: {_data params [["_sub", 0, [0]], ["_uid", "", [""]], ["_unit", objNull, [objNull]], ["_search", "", [""]]];
        if (isNull _unit) exitWith {};
        _uid = getPlayerUID _unit;   // owner 2026-06-23 SECURITY (security.md §2.3): server-derive UID -> "owned" listings are filtered against the REAL caller; client UID never reaches _fetchListings' SQL.
        [_uid, _unit, ["", _search] select (_sub min 1)] call _fetchListings;};
    case 6: {if ((_data param [0, 0]) isEqualTo 1) then {            // withdraw (client already took the items)
            _data params ["", ["_uid", "", [""]], ["_unit", objNull, [objNull]], ["_sid", -1, [0]], ["_upd", [], [[]]]];
            if (isNull _unit || {_sid < 0}) exitWith {};
            _uid = getPlayerUID _unit;   // owner 2026-06-23 SECURITY (security.md §2.3): server-derive UID -> the AND pid='%2' scope below now pins the row to the REAL caller (can't wipe/edit another player's storage row) + no raw UID in SQL.
            _upd params [["_class", "", [""]], ["_newQty", 0, [0]]];
            if (_newQty <= 0) then {
                [format ["DELETE FROM exchange WHERE ID='%1' AND active='2' AND pid='%2'", _sid, _uid]] call DB_fnc_asyncQuery;} else {
                [format ["UPDATE exchange SET Amount='%3' WHERE ID='%1' AND active='2' AND pid='%2'", _sid, _uid, _newQty]] call DB_fnc_asyncQuery;
            };
            ["-EXCHANGE-", _unit, format ["withdrew from storage %1 (%2 -> %3 left)", _sid, _class, _newQty]] call PLB_fnc_logIt;
            [_uid, _unit] call _fetchStorage;} else {_data params ["", ["_uid", "", [""]], ["_unit", objNull, [objNull]]];
            if (isNull _unit) exitWith {};
            _uid = getPlayerUID _unit;   // owner 2026-06-23 SECURITY (security.md §2.3): server-derive UID (fetch only YOUR storage; no raw client UID in _fetchStorage SQL).
            [_uid, _unit] call _fetchStorage;};};
    case 7: {_data params ["", ["_uid", "", [""]], ["_unit", objNull, [objNull]]];
        if (isNull _unit) exitWith {};
        _uid = getPlayerUID _unit;   // owner 2026-06-23 SECURITY (security.md §2.3): server-derive UID (fetch only YOUR listings; no raw client UID in SQL).
        [_uid, _unit] call _fetchListings;};
    default { diag_log format ["[LooneyBin][exchange] unhandled mode: %1", _this]; };};
