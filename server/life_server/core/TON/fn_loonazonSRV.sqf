/*
    TON_fnc_loonazonSRV  (LooneyBin, owner 2026-07-15) -- Loonazon drone delivery.
      ["order",   item, qty]        client already debited bank (accept-risk pattern) + validated locally.
                                    Server re-validates against life_fnc_loonazonCfg (compiled server-side too)
                                    and REFUNDS on every reject. Spawns a Greyhawk that flies to the buyer and
                                    parachute-drops a package crate keyed to their UID.
      ["collect", player, crate]    claim gate: owner-only, once; items granted via life_fnc_handleInv adds
                                    (client checked carry space before calling).
    Drop mechanics reuse the cartel-airdrop lessons (fn_airDrop): enableRopeAttach false (no sling-away),
    chute deleted on landing (Air-class litter trips garage occupancy checks), crate despawns after 15 min.
*/
if (!isServer) exitWith {};
params [["_mode", "", [""]], ["_a1", objNull], ["_a2", 0], ["_a3", [], [[]]]];

switch (toLower _mode) do {case "order": {
        // CART order from the standalone app: _a1 = [[class, qty], ...], _a2 = the total the client debited.
        // Server re-validates every line against the catalog + recomputes weights/cost; ANY reject refunds the
        // full client-debited amount.
        private _cartIn = if (_a1 isEqualType []) then { _a1 } else { [] };
        private _paid = round (parseNumber (format ["%1", _a2]));
        private _unit = (allPlayers select { owner _x isEqualTo remoteExecutedOwner }) param [0, objNull];
        if (isNull _unit) exitWith {};
        private _uid = getPlayerUID _unit;
        if (_uid isEqualTo "") exitWith {};
        private _fee = ["fee"] call life_fnc_loonazonCfg;
        private _fnRefund = { if (_paid > 0) then { [[_paid], "life_fnc_casinoReceive", _unit, false] spawn life_fnc_MP; }; };
        // HC REQUIRED: no headless-client driver online -> no deliveries. Refund + the strike message (defense in
        // depth; the client blocks this first). owner 2026-07-16.
        if ((missionNamespace getVariable ["PLB_hcOwner", 0]) <= 0) exitWith {call _fnRefund;
            [["Workers are on strike, they're demanding more piss bottles. Not gonna happen. Try again later after we replace them all with minorities", "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
        };
        if (_cartIn isEqualTo []) exitWith { call _fnRefund; [["Loonazon: empty order.", "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP; };
        private _cart = []; private _sum = 0; private _vw = 0; private _pw = 0; private _bad = false; private _hasRebel = false;
        // anything from a rebel-side category (armory / drip / supply) makes the run dispatch from a rebel outpost
        private _rebSet = [];
        { { _rebSet pushBack (_x select 0); } forEach (["items", _x] call life_fnc_loonazonCfg); } forEach ["rebel", "drip", "ritems"]; {
            _x params [["_cls", "", [""]], ["_q", 0, [0]]];
            _q = round _q;
            private _row = ["get", _cls] call life_fnc_loonazonCfg;
            if (_row isEqualTo [] || {_q < 1} || {_q > 2000}) exitWith { _bad = true; };
            _row params ["_c", "_name", "_price", "_isPhys", "_wgt"];
            _cart pushBack [_c, _q];
            _sum = _sum + _price * _q;
            if (_isPhys) then { _pw = _pw + _wgt * _q; } else { _vw = _vw + _wgt * _q; };
            if (_c in _rebSet) then { _hasRebel = true; };} forEach _cartIn;
        if (_bad) exitWith { call _fnRefund; [["Loonazon: an item in your cart is out of stock. Order refunded.", "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP; };
        if (_vw > (["vcap"] call life_fnc_loonazonCfg) || {_pw > (["pcap"] call life_fnc_loonazonCfg)}) exitWith { call _fnRefund; [["Loonazon: order over the weight caps. Refunded.", "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP; };
        private _cost = _sum + _fee;
        if (_paid < _cost) exitWith { call _fnRefund; [["Loonazon: payment mismatch. Order refunded.", "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP; };
        private _srcCat = if (_hasRebel) then { "rebel" } else { "gen" };
        // ONE DELIVERY AT A TIME: block a new order while the player still has a van en route OR an un-emptied
        // box. PLB_loonazonActive holds the live delivery object (the van, then the crate). It auto-clears: when
        // the crate is emptied/despawned or the van wrecks, the stored object becomes null, so isNull => free again.
        if (isNil "PLB_loonazonActive") then { PLB_loonazonActive = createHashMap; };
        if (!(isNull (PLB_loonazonActive getOrDefault [_uid, objNull]))) exitWith {call _fnRefund;
            [["Loonazon: you've already got a delivery in progress or an unopened box waiting. Empty it first -- one at a time.", "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
        };
        ["-LOONAZON-", _unit, name _unit, format ["ordered cart %1 ($%2)", _cart, _cost]] call TON_fnc_logIt;

        // the van dispatches FROM THE STORE that sells the item (rebel outpost for weapons, town market for
        // groceries -- loonazonCfg "source") and DRIVES the whole way to the buyer: a real, interceptable haul.
        // HC connected -> it owns the van and physics-drives it (life_fnc_hcDrive, any range); no HC -> AI driver.
        private _p = getPosATL _unit;
        private _sources = ["source", _srcCat] call life_fnc_loonazonCfg;
        private _src = _sources param [0, _p];
        { if ((_x distance2D _p) < (_src distance2D _p)) then { _src = _x; }; } forEach _sources;   // nearest source to the buyer
        private _spawnRoad = objNull; private _bestD = 1e9;
        { private _rd = _x distance2D _src; if (_rd < _bestD) then { _bestD = _rd; _spawnRoad = _x; }; } forEach (_src nearRoads 600);
        private _sp = if (isNull _spawnRoad) then { [_src select 0, _src select 1, 0] } else { getPosATL _spawnRoad };
        private _van = createVehicle ["C_Van_02_vehicle_F", _sp, [], 0, "NONE"];
        _van setPosATL _sp;
        _van setVectorUp (surfaceNormal (getPosATL _van));
        _van setFuel 1;
        // SKIN REMOVED (owner 2026-07-19) -- abandoned for now: logos map wrong on the C_Van_02_vehicle_F UV. Van stays default. Restore when the skin is re-aligned to van_body_CO:
        // _van setObjectTextureGlobal [0, "images\loonazon_van.paa"];
        _van setVariable ["owner", "loonazon", true];              // cleanup-sweep spare (ownerless = instant reap)
        // HARDENING: locked doors (nobody rides or drives it off), no slingload heist, lockpick-exempt
        // (fn_lockpick checks plb_loonazonVan), and identifiable client-side for the robbery-event actions.
        _van lock 2;
        _van setVariable ["hc_ap_lock", true, true];               // hcDrive re-asserts the lock where the van is LOCAL (lock is an AL command; the setOwner handoff drops server-side locks)
        _van enableRopeAttach false;
        _van setVariable ["plb_loonazonVan", true, true];
        _van setVariable ["plb_lzOwner", _uid, true];
        _van setVariable ["plb_lzState", 0, true];                  // 0 en-route | 1 robbery holdout | 2 lootable/claimable
        PLB_loonazonActive set [_uid, _van];                        // outstanding delivery = the van (handed to the crate on drop)
        // owner 2026-07-17: Loonazon only delivers to ROADS ("our drivers don't offroad"). Snap the drop to the
        // nearest road; if the buyer stood well off any road (>45m), the van drops at that road point and we notify
        // + map-mark it on delivery (below). On/near a road -> deliver right up to them as before.
        private _roadDest = _p;
        private _offroad = false;
        private _nrRoads = _p nearRoads 400;
        if (_nrRoads isEqualTo []) then { _nrRoads = _p nearRoads 2000; };
        if !(_nrRoads isEqualTo []) then {private _nr = _nrRoads select 0;
            { if ((_p distance2D _x) < (_p distance2D _nr)) then { _nr = _x; }; } forEach _nrRoads;
            private _rp = getPosATL _nr;
            if ((_p distance2D _rp) > 45) then { _offroad = true; _roadDest = _rp; };};
        private _dest = if (_offroad) then { _roadDest } else { _p };
        _van limitSpeed 90;

        private _useHC = (!isNil "PLB_hcOwner") && {PLB_hcOwner > 0};   // HC-online signal (PLB_UsingHeadless retired -- it triggered the legacy endMission bug)
        private _drv = objNull; private _grp = grpNull;
        if (_useHC) then {
            // hand the driverless van to the HC: tag the destination, then transfer ownership. The HC's driver
            // pump (init.sqf) sees a local tagged van and runs life_fnc_hcDrive on it.
            _van setVariable ["hc_ap_mode", "normal", true];
            _van setVariable ["hc_ap_dest", _dest, true];
            _van setVariable ["hc_ap_arrive", 4, true];            // pull RIGHT up to the player, not 14m short
            _van setVariable ["hc_ap_done", "", true];
            _van setVariable ["hc_ap_want", true, true];
            _van setOwner PLB_hcOwner;} else {_grp = createGroup [civilian, true];
            _drv = _grp createUnit ["C_man_1", _sp, [], 0, "NONE"];
            _drv moveInDriver _van;
            _drv setCaptive true; _drv allowDamage false;
            _grp setBehaviour "CARELESS"; _grp setSpeedMode "FULL"; _grp setCombatMode "BLUE";
            (driver _van) doMove _dest;};
        [[format ["<t color='#e88b2d'>LOONAZON</t> -- order confirmed. A delivery van is en route. Track it on your map."], "info"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
        [["<t color='#e88b2d'>LOONAZON</t> is coming. Stand clear unless you want a box to the head -- the driver does not care. He's got piss bottles to empty.", "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;

        // PRIVATE DELIVERY TRACKER: push the van's live position to the BUYER's client only. Their client drops a
        // LOCAL map marker (createMarkerLocal -> nobody else can see it) so they watch it come. Cleared when the
        // van arrives (loonazon_arrived flag, set below) or dies/despawns. The van is HC-owned and can be far
        // away, so the client can't read its position itself -- the server pushes it.
        [_van, _unit] spawn {params ["_van", "_unit"];
            while { !isNull _van && {alive _van} && {!isNull _unit} && {!(_van getVariable ["loonazon_arrived", false])} } do {
                [["update", getPosATL _van], "life_fnc_loonazonTrack", _unit, false, false] spawn life_fnc_MP;
                uiSleep 2;};
            if (!isNull _unit) then { [["clear"], "life_fnc_loonazonTrack", _unit, false, false] spawn life_fnc_MP; };};

        // PORCH PIRATES: every 30s broadcast the van's position to ALL clients; only players with the Porch
        // Pirate talent (260) render it (client filters locally -- the server never needs their talent list).
        if (isNil "PLB_lzSeq") then { PLB_lzSeq = 0; };
        PLB_lzSeq = PLB_lzSeq + 1;
        private _lzId = PLB_lzSeq;
        [_van, _lzId, _uid] spawn {params ["_van", "_lzId", "_ownerUID"];
            while { !isNull _van && {alive _van} && {!(_van getVariable ["loonazon_arrived", false])} } do {
                [["update", _lzId, getPosATL _van, _ownerUID], "life_fnc_loonazonPirate", -2, false, false] spawn life_fnc_MP;
                uiSleep 30;};
            [["clear", _lzId, [0,0,0], _ownerUID], "life_fnc_loonazonPirate", -2, false, false] spawn life_fnc_MP;};

        // order data on the van (server-local -- the robbery-event cases below read them)
        _van setVariable ["plb_lzCart", _cart];
        _van setVariable ["plb_lzCost", _cost];

        [_van, _drv, _grp, _unit, _cart, _uid, _dest, _useHC, _cost, _offroad] spawn {
            params ["_van", "_drv", "_grp", "_unit", "_cart", "_uid", "_orderPos", "_useHC", "_cost", "_offroad"];
            private _dest = _orderPos;
            private _outcome = "";
            private _hardEnd = time + 7200;                        // owner 2026-07-17: absolute backstop 1h -> 2h so very-far hauls have room (van never despawns until drop-off; this only stops a truly-undeliverable van leaking forever)

            while { _outcome isEqualTo "" && {time < _hardEnd} } do {
                // ---- DRIVE LEG (runs again after a re-attempt) ----
                if (_useHC) then {_van setVariable ["hc_ap_dest", _dest, true];
                    _van setVariable ["hc_ap_done", "", true];
                    _van setVariable ["hc_ap_want", true, true];
                    // HC-fallback watchdog: setOwner is occasionally a silent no-op -- retry, then AI-fallback
                    private _giveUp = time + 15;
                    waitUntil {uiSleep 1;
                        if (!isNull _van && {alive _van} && {local _van} && {!(_van getVariable ["hc_ap_driving", false])} && {(_van getVariable ["hc_ap_done", ""]) isEqualTo ""}) then {
                            _van setVariable ["hc_ap_want", true, true];
                            _van setOwner PLB_hcOwner;};
                        (isNull _van) || {!alive _van} || {_van getVariable ["hc_ap_driving", false]} || {(_van getVariable ["hc_ap_done", ""]) isNotEqualTo ""} || {time > _giveUp}
                    };
                    if (!isNull _van && {alive _van} && {!(_van getVariable ["hc_ap_driving", false])} && {(_van getVariable ["hc_ap_done", ""]) isEqualTo ""}) then {
                        _van setVariable ["hc_ap_want", false, true];
                        _van setOwner 2;                            // reclaim to server (dedicated = id 2)
                        uiSleep 1;
                        if (isNull _drv) then {_grp = createGroup [civilian, true];
                            _drv = _grp createUnit ["C_man_1", getPosATL _van, [], 0, "NONE"];
                            _drv moveInDriver _van;
                            _drv setCaptive true; _drv allowDamage false;
                            _grp setBehaviour "CARELESS"; _grp setSpeedMode "FULL"; _grp setCombatMode "BLUE";};
                        if (!isNull (driver _van)) then { (driver _van) doMove _dest; };
                        _useHC = false;};} else {if (!isNull _van && {!isNull (driver _van)}) then { (driver _van) doMove _dest; };};
                private _legEnd = time + 1800;                     // owner 2026-07-17: one drive leg 15m -> 30m (far hauls from rebel outposts). A stuck van exits early via hc_ap_done + re-attempts; this is just the ceiling for a slow-but-moving van.
                private _engineDead = false;
                waitUntil {uiSleep 2;
                    if (!_useHC && {!isNull _van} && {alive _van} && {(_van distance2D _dest) > 12} && {!isNull (driver _van)}) then { (driver _van) doMove _dest; };
                    // EJECT BELT: nobody rides the Loonazon van. Lock 2 covers most of it, but locality quirks can
                    // let someone slip in -- moveOut is argument-local, so run it where the PLAYER is local.
                    if (!isNull _van) then { { if (isPlayer _x) then { [[], "life_fnc_lzEject", _x, false, false] spawn life_fnc_MP; }; } forEach crew _van; };
                    _engineDead = !isNull _van && {alive _van} && {(_van getHitPointDamage "HitEngine") >= 0.9};
                    (isNull _van) || {!alive _van}
                        || {(_van distance2D _dest) < 14}
                        || {(_van getVariable ["hc_ap_done", ""]) isNotEqualTo ""}
                        || {_engineDead}
                        || {time > _legEnd}};
                if (isNull _van || {!alive _van}) exitWith { _outcome = "destroyed"; };

                // A robbery only starts if a NON-OWNER did it: the buyer can't disable their own van to spawn a
                // redzone (or self-rob). If the engine dies with no other player near, it's owner/environmental ->
                // falls through to the delivery/gaveup branch, which refunds. (PLB_fnc_realPlayers drops the HC.)
                private _robberNear = _engineDead && {((call PLB_fnc_realPlayers) findIf {
                        alive _x && {(getPlayerUID _x) isNotEqualTo _uid} && {(_x distance _van) < 150}}) > -1};
                if (_engineDead && {!_robberNear}) then {
                    ["-LOONAZON-", objNull, "SERVER", format ["van of %1 disabled with no robber nearby -> refund, no redzone", _uid]] call TON_fnc_logIt;
                };

                if (_engineDead && _robberNear) then {
                    // ---- LOONAZON ROBBERY: van disabled by a NON-OWNER -> 10-min holdout + redzone ----
                    _van setVariable ["hc_ap_want", false, true];
                    _van setVariable ["hc_ap_abort", true, true];   // hard-stop any drive loop still running on the HC
                    _van setVariable ["plb_lzState", 1, true];
                    private _vp = getPosATL _van;
                    private _mkE = format ["lz_rob_e_%1", floor serverTime];
                    private _mkD = format ["lz_rob_d_%1", floor serverTime];
                    createMarker [_mkE, _vp]; _mkE setMarkerShape "ELLIPSE"; _mkE setMarkerBrush "Border"; _mkE setMarkerSize [200, 200]; _mkE setMarkerColor "ColorRed";
                    createMarker [_mkD, _vp]; _mkD setMarkerType "mil_warning"; _mkD setMarkerColor "ColorRed"; _mkD setMarkerText "LOONAZON ROBBERY";
                    [[1, "A LOONAZON delivery van has been ambushed! The drop site is a REDZONE for the next 10 minutes."], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
                    if (!isNull _unit) then { [["<t color='#ff3030'>LOONAZON ALERT</t> -- your delivery van is under attack! It's marked on the map. The robbers can crack the package in 10 minutes -- defend it, or claim a refund / re-delivery at the van if you hold them off.", "warning"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP; };
                    ["-LOONAZON-", objNull, "SERVER", format ["ROBBERY started on %1's van at %2", _uid, _vp]] call TON_fnc_logIt;
                    private _evEnd = time + 600;
                    waitUntil {uiSleep 5;
                        if (!isNull _van) then { { if (isPlayer _x) then { [[], "life_fnc_lzEject", _x, false, false] spawn life_fnc_MP; }; } forEach crew _van; };
                        (isNull _van) || {!alive _van} || {time > _evEnd}};
                    if (isNull _van || {!alive _van}) exitWith { deleteMarker _mkE; deleteMarker _mkD; _outcome = "destroyed"; };
                    // holdout over: package claimable -- first action wins (robbers break it open, or the owner
                    // refunds / re-attempts at the van)
                    _van setVariable ["plb_lzState", 2, true];
                    [[1, "The LOONAZON van's lock timer expired -- the package can now be broken open."], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
                    if (!isNull _unit) then { [["<t color='#ff3030'>LOONAZON</t> -- the package lock has expired. If the coast is clear, scroll on the van: refund or re-attempt delivery. If not... it's finders keepers now.", "warning"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP; };
                    private _grace = time + 600;
                    waitUntil {uiSleep 2;
                        if (!isNull _van) then { { if (isPlayer _x) then { [[], "life_fnc_lzEject", _x, false, false] spawn life_fnc_MP; }; } forEach crew _van; };
                        (isNull _van) || {!alive _van} || {(_van getVariable ["plb_lzResolution", ""]) isNotEqualTo ""} || {time > _grace}
                    };
                    deleteMarker _mkE; deleteMarker _mkD;
                    if (isNull _van || {!alive _van}) exitWith { _outcome = "destroyed"; };
                    private _res = _van getVariable ["plb_lzResolution", ""];
                    _van setVariable ["plb_lzResolution", nil];
                    switch (_res) do {case "robbed":    { _outcome = "robbed"; };
                        case "refund":    { _outcome = "refunded"; };
                        case "redeliver": {_dest = _van getVariable ["plb_lzRedeliverPos", _orderPos];
                            _van setVariable ["plb_lzState", 0, true];
                            // loop runs the drive leg again from here
                        };
                        default           { _outcome = "abandoned"; };   // nobody acted in the grace window
                    };} else {private _done = _van getVariable ["hc_ap_done", ""];
                    if ((_van distance2D _dest) < 25 || {_done isEqualTo "arrived"}) then {_outcome = "delivered";} else {
                        // owner 2026-07-17: NEVER give up mid-transit on a DRIVABLE van. A far / slow / momentarily
                        // stuck van (leg timeout, or the HC reporting blocked/stuck/no-route) re-attempts the drive
                        // -- clear the done flag and let the outer loop re-issue hc_ap_want. The van despawns ONLY
                        // after the package drops (delivered), it's wrecked/sank, or the 2h _hardEnd backstop.
                        // Genuinely undeliverable states (engine destroyed with no robber, or sank) still refund now.
                        if (_engineDead || {_done in ["wrecked", "sank"]}) then {
                            _outcome = "gaveup";                    // can't drive -> refund + despawn (not a "too far" case)
                        } else {_van setVariable ["hc_ap_done", "", true];
                            uiSleep 3;                              // small backoff so a walled van doesn't spin the retry
                        };};};};
            if (_outcome isEqualTo "") then { _outcome = "gaveup"; };

            // owner 2026-07-17: AP CRASH LOG -- one `log`-table line (tag -LZAPCRASH-) whenever a Loonazon van driving
            // under HEADLESS AUTOPILOT fails to deliver (wrecked / engine-dead / sank / undeliverable). Lets us tune the
            // HC autopilot from real crashes. Robberies resolve as "robbed"/"delivered" so they're naturally excluded;
            // this only fires while the van was still HC-driven (_useHC), not after an AI-driver fallback.
            if (_useHC && {_outcome in ["destroyed", "gaveup"]}) then {private _gone  = (isNull _van) || {!alive _van};
                private _cp    = if (_gone) then { _dest } else { getPosATL _van };
                private _done  = if (isNull _van) then { "destroyed" } else { _van getVariable ["hc_ap_done", ""] };
                private _eng   = if (_gone) then { 1 } else { _van getHitPointDamage "HitEngine" };
                private _dmg   = if (_gone) then { 1 } else { damage _van };
                private _dleft = if (_gone) then { -1 } else { round (_van distance2D _dest) };
                ["-LZAPCRASH-", objNull, "SERVER", format ["Loonazon AP van (buyer %1) crashed: outcome=%2 hcVerdict=%3 pos=%4 dmg=%5 engine=%6 distLeft=%7m dest=%8 cart=%9", _uid, _outcome, (if (_done isEqualTo "") then {"none"} else {_done}), _cp, (round (_dmg*100))/100, (round (_eng*100))/100, _dleft, _dest, _cart]] call TON_fnc_logIt;
            };

            if (!isNull _van) then { _van setVariable ["loonazon_arrived", true, true]; };   // stops tracker + pirate pings
            private _fnRefund = {if (_cost > 0 && {!isNull _unit}) then {
                    [[_cost], "life_fnc_casinoReceive", _unit, false] spawn life_fnc_MP;
                    [["<t color='#e88b2d'>LOONAZON</t> -- your order didn't make it. Full refund issued.", "info"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
                };};
            private _fnCleanVan = {if (!isNull _drv) then { deleteVehicle _drv; };
                if (!isNull _grp) then { deleteGroup _grp; };
                if (!isNull _van) then { deleteVehicle _van; };
                if (!isNil "PLB_loonazonActive") then { PLB_loonazonActive set [_uid, objNull]; };};
            ["-LOONAZON-", objNull, "SERVER", format ["order for %1 resolved: %2", _uid, _outcome]] call TON_fnc_logIt;

            switch (_outcome) do {case "delivered": {if (false) then {   // (vehicle deliveries retired with the cart catalog)
                        private _plate = round (random [100000, 550000, 999999]);
                        [format ["INSERT INTO %1 (side, classname, type, pid, alive, active, inventory, color, plate, fuel, damage, alarm) VALUES ('civ', 'B_Quadbike_01_F', 'Car', '%2', '1', '0', '[]', '0', '%3', '100', '0', '0')", srv_table_vehicles, _uid, _plate]] call DB_fnc_asyncQuery;
                        if (!isNull _unit) then { [["<t color='#e88b2d'>LOONAZON</t> -- your Quad Bike is registered. Pull it from any garage point.", "info"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP; };
                        if (!isNil "PLB_loonazonActive") then { PLB_loonazonActive set [_uid, objNull]; };
                        ["-LOONAZON-", objNull, "SERVER", format ["quad -> garage %1 (plate %2)", _uid, _plate]] call TON_fnc_logIt;
                    } else {
                        // box drops AT THE VAN (it pulled up to the buyer) -- the goods physically travelled
                        private _bp = if (isNull _van) then { _orderPos } else { getPosATL _van };
                        private _crate = [_bp, _uid, _cart] call TON_fnc_loonazonBox;
                        if (!isNull _unit) then {if (_offroad) then {
                                // owner 2026-07-17: couldn't reach an off-road buyer -> dropped at the nearest road.
                                // Owner-authored notice + a persistent map marker at the drop so they can find it.
                                [["Our drivers dont get paid enough to offroad. We only deliver to houses on roads.", "basic"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
                                [["drop", _bp], "life_fnc_loonazonTrack", _unit, false, false] spawn life_fnc_MP;} else {
                                [["<t color='#e88b2d'>LOONAZON</t> -- delivery here. Scroll 'Open Loonazon Box' to take your goods.", "info"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
                            };};
                        if (!isNil "PLB_loonazonActive") then { PLB_loonazonActive set [_uid, _crate]; };   // lock follows the box
                        ["-LOONAZON-", objNull, "SERVER", format ["package for %1 (%2) delivered at %3", _uid, _cart, _bp]] call TON_fnc_logIt;
                    };
                    // dwell, then depart + despawn (HC: reverse -> 3-point turn -> drive off; AI: doMove away)
                    if (_useHC) then {uiSleep 3;
                        if (!isNull _van) then {_van setVariable ["hc_ap_departing", false, true];
                            _van setVariable ["hc_ap_departWant", true, true];};
                        uiSleep 50;} else {uiSleep 3;
                        if (!isNull _van && {!isNull (driver _van)}) then {private _away = _orderPos getPos [700, random 360];
                            private _awayRoad = (_away nearRoads 300) param [0, objNull];
                            (driver _van) doMove (if (isNull _awayRoad) then { _away } else { getPosATL _awayRoad });};
                        uiSleep 45;};
                    if (!isNull _drv) then { deleteVehicle _drv; };
                    if (!isNull _van) then { deleteVehicle _van; };
                    if (!isNull _grp) then { deleteGroup _grp; };};
                case "robbed": {
                    // break-open case already spawned the robbed box (owned by the robber) -- just clear out
                    uiSleep 5;
                    call _fnCleanVan;};
                case "refunded": {
                    // money already sent by the refund case
                    call _fnCleanVan;};
                case "destroyed": {call _fnRefund;
                    if (!isNull _van) then { [_van] spawn { params ["_v"]; uiSleep 25; if (!isNull _v) then { deleteVehicle _v; }; }; };
                    if (!isNull _drv) then { deleteVehicle _drv; };
                    if (!isNull _grp) then { deleteGroup _grp; };
                    if (!isNil "PLB_loonazonActive") then { PLB_loonazonActive set [_uid, objNull]; };};
                default {   // "gaveup" / "abandoned" -- driver never made it / nobody claimed after the holdout
                    call _fnRefund;
                    call _fnCleanVan;};};};};

    case "breakopen": {
        // ROBBERY PAYOFF: after the 10-min holdout (state 2) ANYONE can break the package out of the van. The
        // robber becomes the box's owner, so the normal owner-gated open/carry actions work for them.
        private _player = _a1; private _van = _a2;
        if (isNull _player || {isNull _van}) exitWith {};
        if (!(_van getVariable ["plb_loonazonVan", false])) exitWith {};
        if ((_van getVariable ["plb_lzState", 0]) isNotEqualTo 2) exitWith {};
        if ((_player distance _van) > 7) exitWith {};
        // the buyer can't rob their own shipment -- they paid for it. Owner uses refund / re-attempt instead.
        if ((_van getVariable ["plb_lzOwner", ""]) isEqualTo (getPlayerUID _player)) exitWith {
            [["<t color='#e88b2d'>LOONAZON</t> -- that's your own order. Use Refund or Re-attempt Delivery, not a crowbar.", "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
        };
        if ((_van getVariable ["plb_lzResolution", ""]) isNotEqualTo "") exitWith {};   // someone already resolved it
        _van setVariable ["plb_lzResolution", "robbed"];
        private _rUid = getPlayerUID _player;
        private _crate = [(getPosATL _van), _rUid, _van getVariable ["plb_lzCart", []]] call TON_fnc_loonazonBox;
        [["<t color='#e88b2d'>LOONAZON</t> -- package cracked. It's yours now. Scroll 'Open Loonazon Box' to take the goods.", "info"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
        ["-LOONAZON-", _player, name _player, format ["ROBBED package (%1) from van of %2", _van getVariable ["plb_lzCart", []], _van getVariable ["plb_lzOwner", ""]]] call TON_fnc_logIt;
    };

    case "lzrefund": {
        // owner-only, after the holdout: take the money back instead of the goods
        private _player = _a1; private _van = _a2;
        if (isNull _player || {isNull _van}) exitWith {};
        if (!(_van getVariable ["plb_loonazonVan", false])) exitWith {};
        if ((_van getVariable ["plb_lzState", 0]) isNotEqualTo 2) exitWith {};
        if ((_van getVariable ["plb_lzOwner", ""]) isNotEqualTo (getPlayerUID _player)) exitWith {};
        if ((_player distance _van) > 7) exitWith {};
        if ((_van getVariable ["plb_lzResolution", ""]) isNotEqualTo "") exitWith {};
        _van setVariable ["plb_lzResolution", "refund"];
        private _refund = _van getVariable ["plb_lzCost", 0];
        if (_refund > 0) then { [[_refund], "life_fnc_casinoReceive", _player, false] spawn life_fnc_MP; };
        [["<t color='#e88b2d'>LOONAZON</t> -- order refunded in full. Sorry about the ambush. The driver is not sorry.", "info"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
        ["-LOONAZON-", _player, name _player, format ["claimed refund ($%1) after robbery holdout", _refund]] call TON_fnc_logIt;};

    case "lzredeliver": {
        // owner-only, after the holdout: kick the driver awake -- van repaired + resumes to the owner's CURRENT spot
        private _player = _a1; private _van = _a2;
        if (isNull _player || {isNull _van}) exitWith {};
        if (!(_van getVariable ["plb_loonazonVan", false])) exitWith {};
        if ((_van getVariable ["plb_lzState", 0]) isNotEqualTo 2) exitWith {};
        if ((_van getVariable ["plb_lzOwner", ""]) isNotEqualTo (getPlayerUID _player)) exitWith {};
        if ((_player distance _van) > 7) exitWith {};
        if ((_van getVariable ["plb_lzResolution", ""]) isNotEqualTo "") exitWith {};
        _van setDamage 0;
        _van setVariable ["plb_lzRedeliverPos", getPosATL _player];
        _van setVariable ["plb_lzResolution", "redeliver"];
        [["<t color='#e88b2d'>LOONAZON</t> -- driver revived (he was hiding under the seat). Delivery resuming to your position.", "info"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
        ["-LOONAZON-", _player, name _player, "chose re-delivery after robbery holdout"] call TON_fnc_logIt;};

    // ("collect" case removed 2026-07-16 -- the box is house-storage now: take/store runs through the trunk menu
    //  (life_fnc_loonazonOpen) directly against plb_vinv/plb_pinv, so no server-clamped grant path is needed.)

    case "carry": {
        // pick up / drop the box to reposition it. The box is server-local, so the attach/detach runs here; the
        // hidden cargo crate is attached to the box and follows. Owner-gated.
        private _player = _a1;
        private _crate = _a2;
        if (isNull _player || {isNull _crate}) exitWith {};
        if ((_crate getVariable ["plb_packageOwner", ""]) isNotEqualTo (getPlayerUID _player)) exitWith {};
        if (_crate getVariable ["plb_carrying", false]) then {detach _crate;
            // place at the player's FEET height in ASL (getPosATL z=0 is terrain level -> sinks through a house
            // floor). getPosASL feet = the actual floor they're standing on, 1.1m out in front. Kill momentum so
            // it settles without launching.
            private _dir = getDir _player;
            private _feet = getPosASL _player;
            _crate setPosASL [(_feet select 0) + (sin _dir) * 1.1, (_feet select 1) + (cos _dir) * 1.1, (_feet select 2) + 0.05];
            _crate setVectorUp [0, 0, 1];
            _crate setVelocity [0, 0, 0];
            _crate setVariable ["plb_carrying", false, true];
            _player setVariable ["plb_loonazonCarry", objNull, true];   // clears the cursor-free "Set Down" action
            [["Box set down.", "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;} else {
            if ((_player distance _crate) > 6) exitWith {};
            if (!isNull (_player getVariable ["plb_loonazonCarry", objNull])) exitWith {};   // already carrying one
            _crate attachTo [_player, [0, 1, 0.05]];   // held out in front
            _crate setVariable ["plb_carrying", true, true];
            _player setVariable ["plb_loonazonCarry", _crate, true];    // enables the cursor-free "Set Down" action
            [["Carrying the box -- use 'Set Down Loonazon Box' (scroll) to drop it where you want.", "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
        };};};
