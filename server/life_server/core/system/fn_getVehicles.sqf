/*
    (ASY|TON)_fnc_getVehicles  (LooneyBin: 2020 garage-retrieve adapter)
    2020 client args : [player, _type]   (fn_handleVehicles -> "PLB_vehicleGarage" dialog)
    Queries the player's STORED vehicles (alive=1, active=0, not listed) of _type, reshapes each
    row into the index layout fn_vehicleGarageMenu / fn_vehicleGaragePull expect, and sends the
    list (wrapped once) to life_fnc_vehicleGarageMenu -> life_garageData.

    Client row indices consumed (fn_vehicleGarageMenu builds _temp from these, fn_vehicleGaragePull reads it):
      0 = id (lbValue)   2 = classname   4 = pid (ownership)
      7 = plate   8 = color   10 = mods   11 = vehWear[dmg,fuel,armour]   12 = customPlate
    THIS ADAPTER IS THE ONLY PRODUCER (fn_handleVehicles -> here). The client must read THIS reshaped
    layout, NOT the raw `vehicles` table schema -- b0162 mis-"fixed" the client to raw-table indices
    (mods@15/fuel@11/damage@12/customplate@16) and broke mods+fuel+damage because the client never sees
    the raw row. mods/customplate now come from real columns; vehWear built from the fuel/damage ints below.
    NOTE: rewritten from the 2017 5-arg signature — only caller was fn_garageCount, now self-contained.
    NOTE: DB_fnc_asyncQuery `call compile`s the whole extDB3 result, so raw varchar columns
    (classname/pid) MUST be QUOTE()'d in SQL or compile dies on the bare token (Undefined variable).
    Numeric columns come back already typed — do NOT parseNumber them.
*/
params [["_unit",objNull,[objNull]], ["_type","",[""]]];
if (isNull _unit || _type == "") exitWith {};

private _uid = getPlayerUID _unit;
if (_uid == "") exitWith {};
private _sideStr = switch (side _unit) do {case west: {"cop"};
    case civilian: {"civ"};
    case independent: {"med"};
    default {"civ"};};

// `mods` (TEXT) holds the full 9-slot upgrade array as an SQF literal e.g. "[1,50,2,0,1,0,0,3,1]"
// (written by TON_fnc_updateVehicleMods). COALESCE(...,'[]') keeps legacy NULL rows compile-safe, QUOTE()
// makes the value a single-quoted (SQF-valid) string token in the call-compiled result.
private _q = format [
    "SELECT id,QUOTE(classname),QUOTE(pid),plate,color,QUOTE(COALESCE(mods,'[]')),alarm,QUOTE(COALESCE(customplate,'')),fuel,damage FROM %1 WHERE pid='%2' AND side='%3' AND type='%4' AND alive='1' AND active='0' AND listed='0' ORDER BY classname, color",
    srv_table_vehicles, _uid, _sideStr, _type];
private _rows = [_q, 2, true] call DB_fnc_asyncQuery;
if (isNil "_rows" || {!(_rows isEqualType [])}) then { _rows = []; };

// Columns arrive pre-typed: id/plate/color/alarm/fuel/damage = Number, classname/pid/mods/customplate = String (QUOTE'd).
// SELECT order: 0 id,1 classname,2 pid,3 plate,4 color,5 mods,6 alarm,7 customplate,8 fuel,9 damage.
private _out = _rows apply {
    private _modsArr = parseSimpleArray (_x select 5);   // "[...]" -> array, "[]"/malformed -> [] (data-only parse; never compiles the DB mods blob -- Lystic RCE class)
    if (!(_modsArr isEqualType []) || {count _modsArr < 9}) then {
        _modsArr = [_x select 6,0,0,0,0,0,0,0,0];    // legacy / un-modded row: fall back to the alarm column
    };
    // DB stores fuel/damage as 0-100 ints (fn_updateVehicle writes (fuel)*100 / (damage)*100); the client wants
    // vehWear = [damage, fuelPercent, armour] in 0-1. (Was hardcoded [0,0.5] -> garage always showed 0 dmg / 50% fuel.)
    private _fuel01 = ((_x select 8) max 0) / 100;
    private _dmg01  = ((_x select 9) max 0) / 100; [_x select 0,                    // 0  id
        "",                             // 1  (unused)
        _x select 1,                    // 2  classname
        "",                             // 3  (unused)
        _x select 2,                    // 4  pid (ownership check)
        "",                             // 5  (unused)
        "",                             // 6  (unused)
        _x select 3,                    // 7  plate
        _x select 4,                    // 8  color
        "",                             // 9  (unused / "")
        _modsArr,                       // 10 mods (full 9-slot upgrade array)
        [_dmg01, _fuel01, 0],           // 11 vehWear [damage, fuelPercent, armour] (0-1) from DB fuel(#8)/damage(#9)
        _x select 7                     // 12 customPlate (owner 2026-06-16 #284: loaded from the customplate column)
    ]};

// Wrap once: fn_vehicleGarageMenu does params[["_garageArr",[],[[]]]] -> reads _this#0 as the list.
[[_out], "life_fnc_vehicleGarageMenu", _unit, false] spawn life_fnc_MP;
