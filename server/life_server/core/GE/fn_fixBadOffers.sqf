/*
    KBW_fnc_fixBadOffers  (LooneyBin REWRITTEN 2026-06-09 for the new Exchange backend)
    Boot maintenance: 2017 version deactivated+DELETED old offers outright (would also have nuked the
    new storage rows). Now: live listings (active=1) older than 168h (7 days) EXPIRE INTO the owner's Exchange
    Storage (active=2, BuyorSell=2) -- vehicles instead get de-listed back to the garage. Storage rows
    older than 14 days are purged. Dupe-guard: vehicles marked listed without a live listing row reset.
*/
// expire vehicle listings -> garage
private _ev = ["SELECT ID, COALESCE(VehicleID,-1) FROM exchange WHERE active='1' AND isVehicle='1' AND timer>=168", 2, true] call DB_fnc_asyncQuery;
if (_ev isEqualType []) then {{
        [format ["UPDATE vehicles SET listed='0' WHERE id='%1'", parseNumber format ["%1", _x param [1, -1]]]] call DB_fnc_asyncQuery;
        [format ["DELETE FROM exchange WHERE ID='%1'", parseNumber format ["%1", _x param [0, -1]]]] call DB_fnc_asyncQuery;} forEach _ev;
};
// expire item listings -> owner storage
["UPDATE exchange SET active='2', BuyorSell='2', bought_at=UNIX_TIMESTAMP() WHERE active='1' AND isVehicle='0' AND timer>=168"] call DB_fnc_asyncQuery;
// purge storage older than 14 days
["DELETE FROM exchange WHERE active='2' AND bought_at < (UNIX_TIMESTAMP() - 1209600)"] call DB_fnc_asyncQuery;
// orphan-listed vehicles (listed=1 but no live listing row) -> back to garage
["UPDATE vehicles v LEFT JOIN exchange e ON e.VehicleID=v.id AND e.active='1' AND e.isVehicle='1' SET v.listed='0' WHERE v.listed='1' AND e.ID IS NULL"] call DB_fnc_asyncQuery;
diag_log "[LooneyBin][exchange] boot maintenance done (expiry -> storage, 14-day purge, orphan delist)";
