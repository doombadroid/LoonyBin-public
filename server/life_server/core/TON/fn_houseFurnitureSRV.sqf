/*
    TON_fnc_houseFurnitureSRV  (LooneyBin -- built 2026-06-10, presence-spawn added 2026-06-12)
    House furniture persistence. Furniture = placeable items (PLB_furnitureItems) placed via the standard
    hold/place pipeline, gated client-side to 20m of an OWNED house, sim+damage OFF.

    DB: houses.furniture = mresArray of [class, posATL(XYZ), dir, placerUID] per house.

    KEYING (owner 2026-07-10 -- THE "furniture never persists" root cause): every houseID passed in from the
    clients is plb_houseID = the houses.oid VARCHAR position-hash, NOT the auto-increment int id. This file
    originally queried `WHERE id='<oid>'`, which matched NOTHING -> the add-SELECT returned 0 rows -> exitWith
    -> NO furniture row was EVER written (and presenceStart/show found nothing to load). Furniture only lived
    as session objects and vanished on every restart. All queries now key on `oid` (the fn_transferHouse
    lesson), the cache is keyed on oid, and oid/owners are QUOTE()'d on read (bare varchars get call-compiled
    into mangled numbers -- the fn_getVehicles/classname footgun).

    PRESENCE SPAWN (owner request): furniture is only SPAWNED while the home is "occupied" -- the homeowner is
    online, OR (gang house) any member of the owning gang is online. When nobody's home it despawns (DB row
    kept) and respawns when they return. Server-side cache (PLB_furnCache) avoids re-querying the DB each tick.
      cache key = houseID(str) -> [ ownerUID(str), buildingObj, entries[[class,pos,dir,uid],...], spawnedObjs ]

    Modes:
      ["add", houseID, class, posATL, dir, obj, placer, itemKey]   client placed a piece (cap 20)
      ["remove", posATL]                                           client picked a piece up
      ["presenceStart"]                                            boot: build cache + run the presence loop
*/
// owner 2026-07-12: LIGHT-EMITTING FURNITURE. Map class -> [[r,g,b], brightness, zOffset]; spawned
// pieces in this map get a #lightpoint attached (server-side object = glows for everyone). Campfires
// keep simulation ON and are inflamed instead (fire needs sim; one object, negligible cost).
if (isNil "PLB_furnLights") then {PLB_furnLights = createHashMap; {PLB_furnLights set [_x select 0, _x select 1];} forEach [
        ["Land_Camping_Light_F",                  [[1.00, 0.75, 0.45], 0.45, 0.10]],
        ["Land_LampShabby_F",                     [[1.00, 0.80, 0.55], 0.70, 3.20]],
        ["Land_LampDecor_F",                      [[1.00, 0.85, 0.60], 0.60, 2.60]],
        ["Land_LampHarbour_F",                    [[1.00, 0.90, 0.70], 0.70, 3.00]],
        ["Land_LampSolar_F",                      [[0.85, 0.95, 1.00], 0.55, 2.80]],
        ["Land_LampStreet_small_F",               [[1.00, 0.85, 0.60], 0.70, 3.40]],
        ["Land_PortableLight_single_F",           [[0.95, 0.95, 1.00], 0.80, 1.30]],
        ["Land_PortableLight_double_F",           [[0.95, 0.95, 1.00], 1.00, 1.30]],
        ["Land_FloodLight_F",                     [[0.95, 0.95, 1.00], 1.20, 3.60]],
        ["Land_Flush_Light_green_F",              [[0.20, 1.00, 0.30], 0.45, 0.10]],
        ["Land_Flush_Light_red_F",                [[1.00, 0.15, 0.15], 0.45, 0.10]],
        ["Land_Flush_Light_yellow_F",             [[1.00, 0.85, 0.20], 0.45, 0.10]],
        ["Land_PortableHelipadLight_01_F",        [[1.00, 1.00, 1.00], 0.45, 0.15]]];
PLB_fnc_furnLight = {params ["_o", "_class"];
    if (_class isEqualTo "Land_Campfire_F") exitWith {_o enableSimulationGlobal true;   // fire needs sim
        _o inflame true;};
    private _cfg = PLB_furnLights getOrDefault [_class, []];
    if (_cfg isEqualTo []) exitWith {};
    _cfg params ["_rgb", "_bright", "_zOff"];
    private _l = createVehicle ["#lightpoint", getPosATL _o, [], 0, "CAN_COLLIDE"];
    _l setLightColor _rgb;
    _l setLightAmbient (_rgb vectorMultiply 0.12);
    _l setLightBrightness _bright;
    _l setLightUseFlare false;
    _l lightAttachObject [_o, [0, 0, _zOff]];
    _o setVariable ["plb_furnLight", _l];   // deleted alongside the piece by the hide/remove paths
};};

params [["_mode", "", [""]]];

private _decode = {params ["_raw"];
    if (isNil "_raw" || {_raw isEqualTo ""} || {_raw isEqualTo "[]"}) exitWith { [] };
    private _s = [_raw] call DB_fnc_mresToArray;
    if (_s isEqualType "") then { _s = parseSimpleArray (format ["%1", _s]); };
    if (isNil "_s" || {!(_s isEqualType [])}) exitWith { [] };
    _s};

// spawn one cached piece (sim/damage off, pickup vars restored) -> returns the object (objNull on bad class)
private _spawnPiece = {params ["_e"];
    _e params [["_class", "", [""]], ["_pos", [0,0,0], [[]]], ["_dir", 0, [0]], ["_uid", "", [""]]];
    if (_class isEqualTo "") exitWith { objNull };

    // owner 2026-07-10: CAN_COLLIDE = spawn at the EXACT stored position. The simple `_class createVehicle _pos`
    // syntax uses engine "safe" placement, which shoved big pieces (ladders/towers against a shed wall) to a
    // collision-free spot -> furniture "didn't go back exactly the way it was" after show/hide.
    private _o = createVehicle [_class, [0, 0, -100], [], 0, "CAN_COLLIDE"];
    _o setDir _dir;
    _o setPosATL _pos;
    _o enableSimulationGlobal false;
    _o allowDamage false;
    _o setVariable ["plb_placedItem", true, true];
    _o setVariable ["plb_ownerID", _uid, true];
    _o setVariable ["plb_furniture", true, true];   // exempt from the server cleanup sweep (fn_cleanup)
    [_o, _class] call PLB_fnc_furnLight;
    _o};

// resolve the house building for a houseID near a position (match plb_houseID)
// owner 2026-07-10: ["House"] not ["House_F"] -- the buyable industrial shed (Land_i_Shed_Ind_F) is not
// reliably isKindOf House_F (the receiveHouses/gang-tagger #208 lesson), so shed furniture never resolved
// its building. "House" covers sheds + every normal home.
private _findBldg = {params ["_hid", "_pos"];
    private _b = objNull;
    { if ((format ["%1", _x getVariable ["plb_houseID", -1]]) isEqualTo (format ["%1", _hid])) exitWith { _b = _x; }; } forEach (nearestObjects [_pos, ["House"], 45]);
    _b};

if (isNil "PLB_furnCache") then { PLB_furnCache = createHashMap; };

switch (toLower _mode) do {case "add": {
        params ["", ["_houseID", "", ["", 0]], ["_class", "", [""]], ["_pos", [0,0,0], [[]]], ["_dir", 0, [0]], ["_obj", objNull, [objNull]], ["_placer", objNull, [objNull]], ["_itemKey", "", [""]]];
        if (((str _houseID) in ["-1", ""]) || {_class isEqualTo ""}) exitWith {};
        private _rows = [format ["SELECT furniture FROM houses WHERE oid='%1'", _houseID], 2, true] call DB_fnc_asyncQuery;
        if !(_rows isEqualType [] && {count _rows > 0}) exitWith {
            diag_log format ["[LooneyBin][furniture] add: no houses row for oid=%1 -- piece NOT persisted", _houseID];
            // owner 2026-07-10: the client deleted its preview + consumed the item on send (server-spawn
            // handoff) -- on ANY reject the item must be refunded or it just vanishes.
            if (!isNull _placer) then {[[true, _itemKey, 1], "life_fnc_handleInv", _placer, false, false] spawn life_fnc_MP;
                [["That building isn't registered for furniture storage.", "basic"], "life_fnc_handleMessage", _placer, false, false] spawn life_fnc_MP;
            };};
        private _furn = [(_rows select 0) param [0, ""]] call _decode;
        if (count _furn >= 20) exitWith {
            if (!isNull _obj) then { deleteVehicle (_obj getVariable ["plb_furnLight", objNull]); deleteVehicle _obj; };
            if (!isNull _placer) then {[[true, _itemKey, 1], "life_fnc_handleInv", _placer, false, false] spawn life_fnc_MP;
                [["This house already has the maximum of 20 furniture pieces.", "basic"], "life_fnc_handleMessage", _placer, false, false] spawn life_fnc_MP;
            };};
        private _entry = [_class, _pos, _dir, if (isNull _placer) then {""} else {getPlayerUID _placer}];
        _furn pushBack _entry;
        [format ["UPDATE houses SET furniture='%1' WHERE oid='%2'", [_furn] call DB_fnc_mresArray, _houseID]] call DB_fnc_asyncQuery;
        // owner 2026-07-10 (SERVER-SPAWN HANDOFF): the SERVER spawns the live piece and tracks it from birth.
        // The client's preview is already deleted client-side; a legacy/late _obj ref (old clients mid-restart)
        // gets deleted here so it can't linger untracked -- untracked client copies were the show/hide dupe.
        if (!isNull _obj) then { deleteVehicle (_obj getVariable ["plb_furnLight", objNull]); deleteVehicle _obj; };
        private _new = [_entry] call _spawnPiece;
        private _hk = format ["%1", _houseID];
        if (_hk in PLB_furnCache) then {private _c = PLB_furnCache get _hk;
            (_c select 2) pushBack _entry;
            if (!isNull _new) then { (_c select 3) pushBack _new; };} else {private _bldg = [_houseID, _pos] call _findBldg;
            private _own = if (!isNull _bldg) then { format ["%1", _bldg getVariable ["plb_homeOwner", ""]] } else { "" };
            PLB_furnCache set [_hk, [_own, _bldg, [_entry], (if (isNull _new) then {[]} else {[_new]})]];};
        diag_log format ["[LooneyBin][furniture] +%1 @ house %2 (%3 pieces)", _class, _houseID, count _furn];};
    case "remove": {params ["", ["_pos", [0,0,0], [[]]]];
        private _rows = ["SELECT QUOTE(oid), furniture FROM houses WHERE furniture IS NOT NULL AND furniture != ''", 2, true] call DB_fnc_asyncQuery;
        if !(_rows isEqualType []) exitWith {}; {private _hid = format ["%1", _x param [0, ""]];
            private _furn = [_x param [1, ""]] call _decode;
            private _i = _furn findIf { ((_x param [1, [0,0,0]]) distance _pos) < 1.5 };
            if (_i isNotEqualTo -1) exitWith {_furn deleteAt _i;
                [format ["UPDATE houses SET furniture='%1' WHERE oid='%2'", [_furn] call DB_fnc_mresArray, _hid]] call DB_fnc_asyncQuery;
                // cache: drop the matching entry + its spawned object (the client already deleteVehicle'd it)
                private _hk = format ["%1", _hid];
                if (_hk in PLB_furnCache) then {private _c = PLB_furnCache get _hk;
                    private _ei = (_c select 2) findIf { ((_x param [1, [0,0,0]]) distance _pos) < 1.5 };
                    if (_ei != -1) then { (_c select 2) deleteAt _ei; };
                    private _si = (_c select 3) findIf { !isNull _x && {(getPosATL _x) distance _pos < 1.5} };
                    if (_si != -1) then { private _fo = (_c select 3) select _si; deleteVehicle (_fo getVariable ["plb_furnLight", objNull]); deleteVehicle _fo; (_c select 3) deleteAt _si; };
                };
                diag_log format ["[LooneyBin][furniture] -1 piece @ house %1 (%2 left)", _hid, count _furn];};} forEach _rows;};
    case "presencestart": {
        // build the cache from the DB (entries only; nothing spawned yet)
        private _rows = ["SELECT QUOTE(oid), QUOTE(owners), furniture FROM houses WHERE furniture IS NOT NULL AND furniture != ''", 2, true] call DB_fnc_asyncQuery;
        if (_rows isEqualType []) then {{_x params [["_hid", -1], ["_own", ""], ["_fraw", ""]];
                private _entries = [_fraw] call _decode;
                if (count _entries > 0) then {private _p = (_entries select 0) param [1, [0,0,0]];
                    private _bldg = [_hid, _p] call _findBldg;
                    PLB_furnCache set [format ["%1", _hid], [format ["%1", _own], _bldg, _entries, []]];};} forEach _rows;};
        diag_log format ["[LooneyBin][furniture] presence cache built: %1 house(s) with furniture", count PLB_furnCache];
        // OWNER-TRIGGERED design (owner 2026-06-12): furniture NO LONGER auto-spawns on presence.
        // The house owner uses the "Show Furniture" scroll action -> case "show" spawns it; this loop
        // ONLY despawns each house's set once its owner logs out (auto-disable on logout).
        // (Old loop was also broken: `_y params ... forEach (values PLB_furnCache)` -- _y only exists
        // when forEach'ing the HashMap itself, so it errored every tick and never spawned anything.)
        // singleevh.md: furniture presence despawn-manager migrated onto the single-wheel scheduler (id
        // "houseFurniture", 30s). Self-contained body (recomputes _onlineUIDs each tick; mutates only
        // PLB_furnCache rows). Flag OFF => original loop runs byte-for-byte (else branch) = ZERO behavior change.
        ["houseFurniture", {params ["_st"];
            private _onlineUIDs = (call PLB_fnc_realPlayers) apply { getPlayerUID _x }; {private _c = _y;
                _c params ["_ownerUID", "_bldg", "_entries", "_spawned"];
                private _isUp = ((_spawned findIf { !isNull _x }) != -1);
                if (_isUp && !(_ownerUID in _onlineUIDs)) then {
                    { if (!isNull _x) then { deleteVehicle (_x getVariable ["plb_furnLight", objNull]); deleteVehicle _x; }; } forEach _spawned;
                    _c set [3, []];
                    diag_log format ["[LooneyBin][furniture] owner %1 offline -> despawned house furniture", _ownerUID];};
            } forEach PLB_furnCache;}, 30, false, true] call PLB_fnc_schedule;};
    case "show": {params ["", ["_houseID", -1, [0, ""]], ["_requester", objNull, [objNull]]];
        private _hk = format ["%1", _houseID];
        private _uid = if (isNull _requester) then { "" } else { getPlayerUID _requester };
        // lazy-load the cache row if this house wasn't cached at boot (e.g. furniture added this session)
        if !(_hk in PLB_furnCache) then {
            private _rows = [format ["SELECT QUOTE(owners), furniture FROM houses WHERE oid='%1'", _houseID], 2, true] call DB_fnc_asyncQuery;
            if (_rows isEqualType [] && {count _rows > 0}) then {(_rows select 0) params [["_own", ""], ["_fraw", ""]];
                private _entries = [_fraw] call _decode;
                if (count _entries > 0) then {private _p = (_entries select 0) param [1, [0,0,0]];
                    PLB_furnCache set [_hk, [format ["%1", _own], [_houseID, _p] call _findBldg, _entries, []]];};};};
        if !(_hk in PLB_furnCache) exitWith {
            if (!isNull _requester) then { [["This house has no saved furniture.", "basic"], "life_fnc_handleMessage", _requester, false, false] spawn life_fnc_MP; };
        };
        private _c = PLB_furnCache get _hk;
        _c params ["_ownerUID", "_bldg", "_entries", "_spawned"];
        if (_uid isNotEqualTo _ownerUID) exitWith {};   // owner only
        // owner 2026-07-10: "Show" is now PURGE-THEN-RESPAWN instead of an "already out" refusal -- it deletes
        // whatever of this house's set is currently spawned and rebuilds from the SAVED entries. Idempotent:
        // spamming it can never accumulate copies (the ladder dupe), and it doubles as a "reset my furniture
        // to its saved layout" button if anything drifted or glitched.
        { if (!isNull _x) then { deleteVehicle (_x getVariable ["plb_furnLight", objNull]); deleteVehicle _x; }; } forEach _spawned;
        _c set [3, []];
        private _objs = []; {_x params [["_class", "", [""]], ["_pos", [0,0,0], [[]]], ["_dir", 0, [0]], ["_puid", "", [""]]];
            if (_class isNotEqualTo "") then {private _o = _class createVehicle _pos;
                _o setDir _dir;
                _o setPosATL _pos;
                _o enableSimulationGlobal false;
                _o allowDamage false;
                _o setVariable ["plb_placedItem", true, true];
                _o setVariable ["plb_ownerID", _puid, true];
                _o setVariable ["plb_furniture", true, true];
                [_o, _class] call PLB_fnc_furnLight;
                _objs pushBack _o;};} forEach _entries;
        _c set [3, _objs];
        diag_log format ["[LooneyBin][furniture] SHOW house %1: spawned %2 piece(s) for %3", _houseID, count _objs, _uid];
        if (!isNull _requester) then { [[format ["Furniture set out (%1 piece(s)). It packs away when you log off.", count _objs], "basic"], "life_fnc_handleMessage", _requester, false, false] spawn life_fnc_MP; };
    };
    case "hide": {params ["", ["_houseID", -1, [0, ""]], ["_requester", objNull, [objNull]]];
        private _hk = format ["%1", _houseID];
        if !(_hk in PLB_furnCache) exitWith {};
        private _c = PLB_furnCache get _hk;
        _c params ["_ownerUID", "_bldg", "_entries", "_spawned"];
        private _uid = if (isNull _requester) then { "" } else { getPlayerUID _requester };
        if (_uid isNotEqualTo _ownerUID) exitWith {};
        { if (!isNull _x) then { deleteVehicle (_x getVariable ["plb_furnLight", objNull]); deleteVehicle _x; }; } forEach _spawned;
        _c set [3, []];
        if (!isNull _requester) then { [["Furniture packed away.", "basic"], "life_fnc_handleMessage", _requester, false, false] spawn life_fnc_MP; };
    };};
