/*
    TON_fnc_createItem  (LooneyBin: spawn / grow a dropped-item pile) -- runs on the SERVER.
    Callers: fn_dropItem (manual Y-menu drop), fn_dropItems (death drop), fn_loginBonusGive, fn_chopTree,
    fn_openChristmasTreePresentCL -- all pass [_items, _pos, _class]:
        _items = [[shortName, amount], ...]   ("money" shortName carries cash) -- the virtual items dropped
        _pos   = position ASL
        _class = holder class, normally "Land_Suitcase_F"
    Was a logging-only STUB, so every drop decremented/cleared the player's inventory but no pile ever
    spawned -- items "just disappeared". Create a global holder, stash the items on it under plb_droppedItems
    (the var life_fnc_menuPickupItems reads on pickup), and self-delete once the pile is emptied or after
    30 min so dropped cases don't accumulate forever.

    LooneyBin tweak (drop bug #8): every manual drop used to spawn its OWN suitcase, so a few drops left a
    heap of cases -- and as live-PhysX objects they spawned overlapping and violently ejected nearby
    vehicles/players. Now we (1) MERGE into a same-class pile already on the ground within 6 m (stacking
    like items) instead of making another case, and (2) disable simulation on any new case so it sits inert
    and can't punt things around. Net: one tidy, non-colliding pile per spot.
*/
params [["_items", [], [[]]], ["_pos", [0, 0, 0], [[]]], ["_class", "Land_Suitcase_F", [""]]];
if (_class isEqualTo "") then { _class = "Land_Suitcase_F"; };
if (_items isEqualTo []) exitWith {};
// owner 2026-06-23 SECURITY (security.md §2.1/§2.3 -- item/cash dupe): the client passes _items verbatim and
// fn_pickupItem credits them, incl. the "money" pseudo-item -> life_cash. Any client could remoteExec a
// [["money",1e9]] pile and loot it. We can't fully validate the dropper's CLIENT-side inventory here (legit
// DEATH drops in fn_dropItems pass [money, life_cash]), so this is a BOUNDED mitigation: structurally validate
// every entry (kills malformed/injection-ish), drop bad ones, hard-cap money + item amounts, and log oversized
// drops for CLANKR. FULL fix = server-authoritative cash/inventory (drop-system refactor) -- flagged §2.1.
private _src = remoteExecutedOwner;
if (_src != 0) then {private _rc = (allPlayers select { owner _x isEqualTo _src }) param [0, objNull];
    private _moneyCap = 10000000;   // generous vs legit cash-on-hand; bounds the per-call mint (was unbounded)
    private _itemCap  = 100000;
    private _clean = [];
    private _strippedTimber = 0; {
        if (_x isEqualType [] && {count _x >= 2} && {(_x select 0) isEqualType ""} && {(_x select 1) isEqualType 0} && {(_x select 1) > 0}) then {
            private _n = _x select 0;
            private _amt = _x select 1;
            if ((toLower _n) in ["timber","timberl","timberh"]) then {
                // owner 2026-06-24: STRIP client-spawned timber. The ONLY legit fresh-timber path is now
                // TON_fnc_chopTreeSRV (server validates a real tree); a CLIENT createItem of timber is the mint
                // exploit (player093 76561190000000038). Trade-off: a manual/death DROP of carried timber is also lost --
                // rare, accepted to close the mint. Logged below.
                _strippedTimber = _strippedTimber + _amt;} else {
                private _cap = if ((toLower _n) in ["money","newdrachma","bank_money"]) then { _moneyCap } else { _itemCap };
                if (_amt > _cap) then {
                    ["-SEC-", _rc, format ["createItem amount CAPPED %1 x%2 -> %3 (possible dupe attempt)", _n, _amt, _cap]] call PLB_fnc_logIt;
                    _amt = _cap;};
                _clean pushBack [_n, _amt];};};} forEach _items;
    if (_strippedTimber > 0) then {
        ["-SEC-", _rc, format ["createItem TIMBER stripped x%1 (mint attempt -- fresh timber only via a tree)", _strippedTimber]] call PLB_fnc_logIt;
    };
    _items = _clean;
    if (_items isEqualTo []) exitWith {};};

// find an existing pile (same holder class, still holding items, not currently being looted) near the drop
private _existing = objNull; {
    if ( !((_x getVariable ["plb_droppedItems", []]) isEqualTo []) && {isNull (_x getVariable ["plb_inUse", objNull])} ) exitWith { _existing = _x; };
} forEach (nearestObjects [ASLToAGL _pos, [_class], 6]);

// merge onto the existing pile -- stack matching shortNames, append the rest -- and stop (no new case)
if (!isNull _existing) exitWith {private _cur = +(_existing getVariable ["plb_droppedItems", []]); {private _entry = _x;
        private _i = -1;
        { if ((_x select 0) isEqualTo (_entry select 0)) exitWith { _i = _forEachIndex; }; } forEach _cur;
        if (_i >= 0) then {(_cur select _i) set [1, ((_cur select _i) select 1) + (_entry select 1)];} else {_cur pushBack +_entry;};
    } forEach _items;
    _existing setVariable ["plb_droppedItems", _cur, true];};

private _holder = createVehicle [_class, [0, 0, 0], [], 0, "CAN_COLLIDE"];
_holder setPosASL _pos;
// inert: no PhysX, no damage -- the case can't ragdoll itself or shove vehicles/players (drop bug #8)
_holder enableSimulationGlobal false;
_holder allowDamage false;
_holder setVariable ["plb_droppedItems", _items, true];
_holder setVariable ["plb_inUse", nil, true];

// housekeeping: delete the pile once it's been picked clean (and nobody is in it) or after 30 minutes.
[_holder] spawn {params ["_h"];
    private _start   = time;
    private _minLife = 1200;            // LooneyBin: dropped briefcases live >= 20 min even if picked clean
    private _end     = time + 1800;     // hard cap 30 min
    waitUntil {uiSleep 30;
        isNull _h || time > _end ||
        ((time - _start >= _minLife) && ((_h getVariable ["plb_droppedItems", []]) isEqualTo []) && isNull (_h getVariable ["plb_inUse", objNull]))
    };
    if (!isNull _h) then { deleteVehicle _h; };};
