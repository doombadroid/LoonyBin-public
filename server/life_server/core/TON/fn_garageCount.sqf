/*
    TON_fnc_garageCount  (LooneyBin: 2020 garage-count adapter)
    2020 client args : [getPlayerUID player, playerSide, player]   (fn_vehicleShopMenu / fn_factory)
    Counts the player's owned vehicles (any type, alive) on that side and pushes the total to
    the client as life_garageCount — gates the life_maxGarageVeh purchase check. Without this the
    client sits at life_garageCount = -1 -> "Failed to fetch garage count from server."
    Replaces the old passthrough stub to PLB_fnc_getVehicles (arg-mismatched, set life_veh_count).
*/
params [["_uid","",[""]], ["_side",sideUnknown,[west]], ["_unit",objNull,[objNull]]];
// owner 2026-06-23 SECURITY (security.md §2.3 — cross-account read + SQLi): the client _uid was interpolated
// RAW into the SELECT (UNION-exfil / injection) and the count is the player's OWN garage. Force the actor to
// the NON-SPOOFABLE caller's OWN account (fn_vehicleShopMenu/fn_factory pass getPlayerUID player) and reply to
// the real caller. Server-internal (_src==0) keeps the passed _uid/_unit.
private _src = remoteExecutedOwner;
if (_src != 0) then {private _rc = (allPlayers select { owner _x isEqualTo _src }) param [0, objNull];
    _unit = _rc;
    _uid  = getPlayerUID _rc;};
if (_uid == "" || isNull _unit) exitWith {};
_uid = (format ["%1", _uid]) splitString "\'""" joinString "";

private _sideStr = switch (_side) do {case west: {"cop"};
    case civilian: {"civ"};
    case independent: {"med"};
    default {"civ"};};

// Count every alive vehicle the player owns on this side (active-out + stored) toward the cap.
private _q = format ["SELECT id FROM %1 WHERE pid='%2' AND side='%3' AND alive='1'", srv_table_vehicles, _uid, _sideStr];
private _rows = [_q, 2, true] call DB_fnc_asyncQuery;
private _n = if (isNil "_rows" || {!(_rows isEqualType [])}) then { 0 } else { count _rows };

life_garageCount = _n;
(owner _unit) publicVariableClient "life_garageCount";
