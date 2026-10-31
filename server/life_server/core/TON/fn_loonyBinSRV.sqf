/*
    TON_fnc_loonyBinSRV  (LooneyBin -- implemented 2026-06-09, reworked to owner spec 2026-06-18)
    THE NAMESAKE HEIST: Mental-Hospital / Loony Bin federal event. Client = core/actions/fn_loonyBin.sqf
    + setupActions; this is the server half / state machine.

    SRV_loonyBinData = [lastBreach(serverTime), breached(bool), 0, keycode(str), tombLocked(bool),
                        remainsObj, copsRequired(=2)]

    DOORS / BARRIERS (owner 2026-06-18, all reset on event end):
      - life_mentalGate1  = back breach wall   -> moved underground (deleted) on breach, restored on reset
      - life_mentalGate2  = box on front door  -> moved underground on thermite blow, restored on reset
      - life_mentalGate3  = front gate         -> bis_disabled_Door locked until the demo charge blows
      - hospital front door (~[24112,15570.5]) -> bis_disabled_Door locked until thermite blows
      - church tomb door  (~[24096.3,15532.6]) -> bis_disabled_Door locked until the keycode is entered
    Cached refs/positions live in PLB_mentalDoorChurch / PLB_mentalDoorsThermite / PLB_mentalGate1Pos /
    PLB_mentalGate2Pos. Loot objects live in PLB_mentalLootObjs; the getaway truck in PLB_mentalTempest.

    FLOW: 2 cops -> demo a wall (event starts, map marker; back wall deleted, front gate unlocked) ->
    thermite the front door (all civ <=500m charged "Loony Bin Robbery" id 74 $15k; blows after 5 min ->
    hospital door unlocks, door-box removed) -> hack the 5 mainframe laptops (~10 min) -> tomb keypad
    spawns ON the church door + loot spawns inside the locked church + code broadcast -> enter the code
    at the keypad -> church door unlocks + an iridescent Tempest (Device) getaway spawns with keys for
    every non-cop within 200m -> load the loot and escape -> the caretaker buries the remains 10 min
    after the tomb spawned -> event ends, everything re-seals. Cop counter = re-enable the firewall at
    the back-door laptop. 45-min hard cap; 45-min re-breach cooldown.
*/
params [["_caseType", "", [""]], ["_data", [], [[]]]];

switch (_caseType) do {

    // ── SEALED / RESET STATE ── locks every door, restores the wall+box, clears loot/keypad/abandoned truck.
    // Called at boot (initServer, after a delay so the mapData church exists) and at every event end.
    case "loonyBinReset": {
        // Returns [building, [doorIdx,...]] -- the nearest door-building to _pos, then EVERY door index on it
        // within _radius of _pos (so a double-leaf entrance locks BOTH leaves). Church uses a big radius =
        // seal all its doors (tomb vault); the hotel uses a small one = just the front door(s).
        private _fnc_findDoor = {params ["_pos", ["_radius", 6]];
            private _bld = objNull; private _bestD = 9999; {private _b = _x;
                private _nd = getNumber (configFile >> "CfgVehicles" >> (typeOf _b) >> "NumberOfDoors");
                for "_i" from 1 to _nd do {private _dp = _b modelToWorld (_b selectionPosition format ["Door_%1_trigger", _i]);
                    if ((_dp distance _pos) < _bestD) then { _bestD = _dp distance _pos; _bld = _b; };};
            } forEach (nearestObjects [_pos, [], 35]);
            private _idx = [];
            if (!isNull _bld) then {private _nd = getNumber (configFile >> "CfgVehicles" >> (typeOf _bld) >> "NumberOfDoors");
                for "_i" from 1 to _nd do {private _dp = _bld modelToWorld (_bld selectionPosition format ["Door_%1_trigger", _i]);
                    if ((_dp distance _pos) < _radius) then { _idx pushBack _i; };};};
            [_bld, _idx]};
        // CHURCH (tomb vault) = seal ALL its doors, code-gated. COMPOUND/HOTEL = seal ALL doors of every
        // building the listed coords resolve to (radius 50 => the whole building, so a multi-door hotel locks
        // fully in one shot), thermite-gated. Add a coord to _thermiteCoords to seal another compound building.
        if (isNil "PLB_mentalDoorChurch") then { PLB_mentalDoorChurch = [[24096.3, 15532.6, 1.22], 50] call _fnc_findDoor; };
        if (isNil "PLB_mentalDoorsThermite") then {private _churchB = PLB_mentalDoorChurch select 0;
            private _thermiteCoords = [[24112, 15570.5, 1.26], [24104.8, 15589.4, 0.96]];
            PLB_mentalDoorsThermite = (_thermiteCoords apply { [_x, 50] call _fnc_findDoor }) select { !isNull (_x select 0) && {!((_x select 0) isEqualTo _churchB)} };
        };
        if (isNil "PLB_mentalGate1Pos" && {!isNull life_mentalGate1}) then { PLB_mentalGate1Pos = getPosATL life_mentalGate1; };
        if (isNil "PLB_mentalGate2Pos" && {!isNull life_mentalGate2}) then { PLB_mentalGate2Pos = getPosATL life_mentalGate2; };
        diag_log format ["[LooneyBin][heist] doors resolved -> church=%1 doors%2 | thermite=%3 | gate3=%4",
            typeOf (PLB_mentalDoorChurch select 0), PLB_mentalDoorChurch select 1,
            PLB_mentalDoorsThermite apply { [typeOf (_x select 0), _x select 1] }, typeOf life_mentalGate3];

        // LOCK every church + compound-building door, and the front gate
        {_x params [["_b", objNull], ["_idx", []]];
            if (!isNull _b) then { { _b setVariable [format ["bis_disabled_Door_%1", _x], 1, true]; } forEach _idx; };
        } forEach ([PLB_mentalDoorChurch] + PLB_mentalDoorsThermite);
        if (!isNull life_mentalGate3) then { life_mentalGate3 setVariable ["bis_disabled_Door_1", 1, true]; };
        // also swing every door SHUT -- a lock alone leaves a player-opened door standing open (= passable).
        // animateDoor (global) + the animateSource trio cover both door-animation schemes BI buildings use.
        private _fnc_shut = {params ["_b", "_i"];
            _b animateDoor [format ["Door_%1", _i], 0];
            { _b animateSource [format [_x, _i], 0]; } forEach ["Door_%1_source", "Door_%1_sound_source", "Door_%1_noSound_source"];}; {
            _x params [["_b", objNull], ["_idx", []]];
            if (!isNull _b) then { { [_b, _x] call _fnc_shut; } forEach _idx; };
        } forEach ([PLB_mentalDoorChurch] + PLB_mentalDoorsThermite);
        if (!isNull life_mentalGate3) then { [life_mentalGate3, 1] call _fnc_shut; };

        // RESTORE the back breach wall + the front-door box
        if (!isNull life_mentalGate1 && {!isNil "PLB_mentalGate1Pos"}) then {life_mentalGate1 hideObjectGlobal false;
            life_mentalGate1 setPosATL PLB_mentalGate1Pos;};
        if (!isNull life_mentalGate2 && {!isNil "PLB_mentalGate2Pos"}) then {life_mentalGate2 hideObjectGlobal false;
            life_mentalGate2 setPosATL PLB_mentalGate2Pos;};

        // CLEAR leftover keypad/loot + the markers. NOT the getaway Tempest.
        { if (!isNull _x) then { deleteVehicle _x; }; } forEach (missionNamespace getVariable ["PLB_mentalLootObjs", []]);
        PLB_mentalLootObjs = [];
        // owner 2026-06-20: the getaway Tempest now STAYS where it is until the next server restart -- the
        // event-end reset no longer despawns it. (Previously deleted here if still parked empty near the spawn.)
        // plb_eventVeh exempts it from fn_cleanup, so it survives even if driven off + abandoned. Just release
        // our ref; a fresh breach spawns a new one (the old one is orphaned but harmless, reaped only at restart).
        PLB_mentalTempest = objNull;
        { deleteMarker _x; } forEach ["life_mentalEventMarker", "life_mentalHospitalPatient"];

        SRV_loonyBinData set [1, false];
        SRV_loonyBinData set [4, true];
        SRV_loonyBinData set [5, objNull];
        publicVariable "SRV_loonyBinData";
        diag_log "[LooneyBin][heist] sealed/reset";};

    case "loonyBinBreached": {_data params [["_robber", objNull, [objNull]]];
        if (SRV_loonyBinData param [1, false]) exitWith {};
        if ((SRV_loonyBinData param [0, -2700]) > serverTime - 2700) exitWith {};
        if (["loonybin"] call PLB_fnc_fedEventActive) exitWith {
            [[2, "Another major crime is already in progress -- the Loony Bin breach won't trigger."], "life_fnc_broadcast", _robber, false, false] spawn life_fnc_MP;
        };
        // owner 2026-07-24 SECURITY (audit): every other heist's server half re-checks the police
        // requirement (fn_fedAlarm:20, fn_bankDrillVault:30, fn_jewelryEmporiumSRV:29) -- this one did not,
        // so the cop gate existed ONLY in the client (fn_loonyBin.sqf "breachGateBomb" ->
        // life_fnc_policeRequired). Being CfgRE allowedTargets=2, a client could remoteExec
        // ["loonyBinBreached"] and blow the Loony Bin with zero police online, skipping the demo charge and
        // the 25s placement too. Mirror the client requirement server-side with the standard
        // tenuredCops + PLB_betaZeroCops idiom; index 6 of SRV_loonyBinData is the required count the
        // client itself reads.
        // NB: index 6 defaults to 0 in init.sqf:327, and 0 legitimately means "no police requirement"
        // (life_fnc_policeRequired treats it that way client-side). Do NOT floor this at 1 -- that would
        // impose a requirement the config says does not exist and block breaches that should be allowed.
        private _lbReq = SRV_loonyBinData param [6, 0];
        if (_lbReq > 0 && {([] call PLB_fnc_tenuredCops) < _lbReq} && {!(missionNamespace getVariable ["PLB_betaZeroCops", false])}) exitWith {
            [[2, format ["The Loony Bin cannot be breached with fewer than %1 police officer(s) online.", _lbReq]], "life_fnc_broadcast", _robber, false, false] spawn life_fnc_MP;
            ["-SEC-", _robber, format ["BLOCKED loonyBin breach (needs %1 tenured cops)", _lbReq]] call PLB_fnc_logIt;};
        // make sure the seal/cache is in place before we start unlocking things
        if (isNil "PLB_mentalDoorChurch") then { ["loonyBinReset", []] call TON_fnc_loonyBinSRV; };

        private _frontPos = getPosATL life_mentalTrolleyFront;
        private _boom = "ModuleExplosive_DemoCharge_F" createVehicle _frontPos;
        [_boom] spawn { params ["_b"]; uiSleep 0.4; _b setDamage 1; }; {_x hideObjectGlobal true;
            _x enableSimulationGlobal false;} forEach [life_mentalTrolleyFront, life_mentalTrolleyBack];

        // owner 2026-06-18: breach deletes the back wall (gate1) + unlocks the front gate (gate3)
        if (!isNull life_mentalGate1 && {!isNil "PLB_mentalGate1Pos"}) then {life_mentalGate1 hideObjectGlobal true;
            life_mentalGate1 setPosATL [PLB_mentalGate1Pos select 0, PLB_mentalGate1Pos select 1, -500];};
        if (!isNull life_mentalGate3) then { life_mentalGate3 setVariable ["bis_disabled_Door_1", 0, true]; };

        // reset the scene's progress vars for a fresh run
        { _x setVariable ["plb_mentalLaptopHacked", false, true]; } forEach [life_mentalLaptop1, life_mentalLaptop2, life_mentalLaptop3, life_mentalLaptop4, life_mentalLaptop5];
        life_mentalLaptopFrontDoor setVariable ["plb_mentalThermiteStarted", false, true];
        life_mentalLaptopFrontDoor setVariable ["plb_mentalThermiteEnded", false, true];
        life_mentalLaptopCop setVariable ["plb_mentalFirewallActive", false, true];
        PLB_mentalLootObjs = [];

        SRV_loonyBinData set [0, serverTime];
        SRV_loonyBinData set [1, true];
        SRV_loonyBinData set [3, ""];
        SRV_loonyBinData set [4, true];
        SRV_loonyBinData set [5, objNull];
        publicVariable "SRV_loonyBinData";

        // active-breach map marker (global)
        if ((getMarkerPos "life_mentalEventMarker") isEqualTo [0,0,0]) then {
            private _mk = createMarker ["life_mentalEventMarker", getMarkerPos "life_mentalHospital"];
            _mk setMarkerType "loc_Hospital";
            _mk setMarkerColor "ColorRed";
            _mk setMarkerText "Loony Bin Breach";} else {"life_mentalEventMarker" setMarkerPos (getMarkerPos "life_mentalHospital");};

        [[0, "The Loony Bin is being BREACHED! The APD must respond!"], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
        [["The Loony Bin mental hospital is being breached! Respond immediately!", "copalert"], "life_fnc_handleMessage", west, false, false] spawn life_fnc_MP;
        diag_log format ["[LooneyBin][heist] breach started by %1", name _robber];
        ["-LOONYBIN-", _robber, "breached the Loony Bin gates"] call PLB_fnc_logIt;

        [] spawn {private _endAt = serverTime + 2700;   // 45-min event cap (hard backstop)
            private _fw = { life_mentalLaptopCop getVariable ["plb_mentalFirewallActive", false] };
            private _endEvent = {
                // restore the bomb-trolleys STATIC (sim false = their mission.sqm state); enabling sim made the
                // props topple/slide ("bombs moved to the left" on reset).
                { _x hideObjectGlobal false; _x enableSimulationGlobal false; } forEach [life_mentalTrolleyFront, life_mentalTrolleyBack];
                life_mentalLaptopFrontDoor setVariable ["plb_mentalThermiteStarted", false, true];
                life_mentalLaptopFrontDoor setVariable ["plb_mentalThermiteEnded", false, true];
                ["loonyBinReset", []] call TON_fnc_loonyBinSRV;   // re-lock doors, restore wall+box, clear loot/keypad/truck, reset SRV data + markers
                diag_log "[LooneyBin][heist] event ended";
                ["-LOONYBIN-", objNull, "heist event ended"] call PLB_fnc_logIt;};

            // PHASE 1: wait for the thermite to be primed on the front door
            waitUntil { uiSleep 2;
                (life_mentalLaptopFrontDoor getVariable ["plb_mentalThermiteStarted", false]) || (call _fw) || (serverTime > _endAt) };
            if ((call _fw) || (serverTime > _endAt)) exitWith {
                if (call _fw) then { [[0, "The APD locked the Loony Bin back down before the robbers got inside!"], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP; };
                call _endEvent;};

            // thermite primed -> charge EVERY civilian within 500 m with "Loony Bin Robbery" (id 74, $15,000)
            {if ((side _x isEqualTo civilian) && (alive _x) && ((_x distance (getMarkerPos "life_mentalHospital")) < 500)) then {
                    [74, _x] call TON_fnc_wantedAdd;};} forEach allPlayers;
            [[0, "The thermite is burning! Everyone near the Loony Bin is now wanted for Loony Bin Robbery!"], "life_fnc_broadcast", civilian, false, false] spawn life_fnc_MP;

            // 5-minute thermite countdown (holdout), abortable by the firewall. Broadcast the time left every
            // minute so the crew has a clock (players reported "no timers on the steps" -- #379/#380).
            private _tEnd = serverTime + 300;
            [_tEnd] spawn {params ["_tEnd"];
                while { (serverTime < _tEnd - 5) && {SRV_loonyBinData param [1, false]} && {!(life_mentalLaptopCop getVariable ["plb_mentalFirewallActive", false])} } do {
                    uiSleep 60;
                    private _min = ceil ((_tEnd - serverTime) / 60);
                    if (_min > 0 && {serverTime < _tEnd} && {SRV_loonyBinData param [1, false]}) then {
                        [[0, format ["Loony Bin: hold the front door -- the thermite blows in ~%1 minute(s)!", _min]], "life_fnc_broadcast", civilian, false, false] spawn life_fnc_MP;
                    };};};
            waitUntil { uiSleep 2; (serverTime > _tEnd) || (call _fw) };
            if (call _fw) exitWith {
                [[0, "The APD reactivated the Loony Bin firewall and stopped the breach!"], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
                ["resolve", "loonybin", "no"] call TON_fnc_sportsbookResolve;   // LoonyBets: APD held the Bin
                call _endEvent;};
            life_mentalLaptopFrontDoor setVariable ["plb_mentalThermiteEnded", true, true];

            // owner 2026-06-18: thermite blowing unlocks the hospital front door + removes the box blocking it
            {_x params [["_b", objNull], ["_idx", []]];
                if (!isNull _b) then { { _b setVariable [format ["bis_disabled_Door_%1", _x], 0, true]; } forEach _idx; };
            } forEach (missionNamespace getVariable ["PLB_mentalDoorsThermite", []]);
            if (!isNull life_mentalGate2 && {!isNil "PLB_mentalGate2Pos"}) then {life_mentalGate2 hideObjectGlobal true;
                life_mentalGate2 setPosATL [PLB_mentalGate2Pos select 0, PLB_mentalGate2Pos select 1, -500];};
            [[0, "The Loony Bin front door has been blown open! Hack the 5 mainframe computers!"], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;

            // PHASE 2: all 5 mainframe laptops hacked (~10 min of hacking total)
            private _laptops = [life_mentalLaptop1, life_mentalLaptop2, life_mentalLaptop3, life_mentalLaptop4, life_mentalLaptop5];
            waitUntil { uiSleep 2;
                (({ _x getVariable ["plb_mentalLaptopHacked", false] } count _laptops) isEqualTo 5) || (call _fw) || (serverTime > _endAt) };
            if ((call _fw) || (serverTime > _endAt)) exitWith {
                if (call _fw) then { [[0, "The APD reactivated the Loony Bin firewall and stopped the breach!"], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP; };
                call _endEvent;};

            // PHASE 3: keypad ON the church tomb door + loot spawns INSIDE the (still-locked) church + code broadcast
            private _churchDoorPos = [24096.3, 15532.6, 1.22];
            private _tombInside = [24094.2, 15546.7, 0.71];
            private _keypad = "Land_Tablet_01_F" createVehicle _churchDoorPos;
            _keypad setPosATL _churchDoorPos;
            _keypad setVariable ["plb_mentalUnlockedTomb", false, true];
            _keypad allowDamage false;
            // owner 2026-06-19 (2nd-attempt "no Enter Keycode scroll option" bug): fn_cleanup.sqf:77 INSTANT-reaps
            // ownerless objects (idleTime==0 path, and Land_Tablet_01_F isn't in PLBObjectWhitelist). The keypad was
            // the ONE phase-3 object missing an `owner` tag (gold/remains/crate all have one) -> it vanished on the
            // next cleanup pass. The keypad ACTION condition needs `!isNull nearestObject[...,"Land_Tablet_01_F"]`, so
            // once reaped the scroll option disappears = can't enter the code = tomb never opens. RACE: attempt 1
            // beat the cleanup pass, attempt 2 didn't (intermittent). Tag an owner so cleanup spares it; loonyBinReset
            // clears PLB_mentalLootObjs at event end.
            _keypad setVariable ["owner", "loonybin_keypad", true];
            PLB_mentalLootObjs pushBack _keypad;

            // exactly 20 gold bars -- 5 suitcases of 4 each (fed-reserve mechanic: plb_droppedItems + locked pickup menu)
            for "_i" from 0 to 4 do {
                private _gp = [(_tombInside select 0) - 1.5 + (random 3), (_tombInside select 1) - 1.5 + (random 3), _tombInside select 2];
                private _case = "Land_Suitcase_F" createVehicle _gp;
                _case setPosATL _gp;
                _case setVariable ["owner", "loonybin_gold", true];
                // owner 2026-07-18: 1 crypto MINING COMPONENT rides inside ONE gold case (looted via the same
                // locked pickup menu) instead of a standalone crate at the event. (MINE_COMPONENTS is #defined
                // in fn_miningSRV, not visible here -> inline the 8-item list.)
                private _lbLoot = [["goldbar", 4]];
                if (_i isEqualTo 0) then { _lbLoot pushBack [selectRandom ["cryptoCPU","cryptoGPU","cryptoPSU","cryptoStorage","cryptoMotherboard","cryptoRam","cryptoCooler","cryptoCase"], 1]; };
                _case setVariable ["plb_droppedItems", _lbLoot, true];
                PLB_mentalLootObjs pushBack _case;};

            // patient remains = 3x patientbag in a suitcase (was Land_Bodybag_01_black_F -- the flat bag was
            // un-targetable + collides with the combat-logger system; suitcase is the proven loot container, same
            // as the gold). Looted through the locked pickup menu (dupe-safe).
            private _remains = "Land_Suitcase_F" createVehicle _tombInside;
            _remains setPosATL [(_tombInside select 0) + 1.5, _tombInside select 1, _tombInside select 2];
            _remains setVariable ["owner", "loonybin_remains", true];
            _remains setVariable ["plb_droppedItems", [["patientbag", 3]], true];
            _remains allowDamage false;
            PLB_mentalLootObjs pushBack _remains;
            SRV_loonyBinData set [5, _remains];

            // weaponry crate -- SPMG, GM6 Lynx, MAR-10 + mags
            private _crate = "Box_NATO_Wps_F" createVehicle _tombInside;
            _crate setPosATL [(_tombInside select 0) - 1.5, _tombInside select 1, _tombInside select 2];
            clearWeaponCargoGlobal _crate; clearMagazineCargoGlobal _crate; clearItemCargoGlobal _crate; clearBackpackCargoGlobal _crate;
            _crate addWeaponCargoGlobal ["MMG_02_camo_F", 2];
            _crate addWeaponCargoGlobal ["srifle_GM6_F", 2];
            _crate addWeaponCargoGlobal ["srifle_DMR_02_F", 2];
            // owner 2026-06-19: .338 BELTS (the SPMG's feed) instead of the .338 10-round box mags; dropped the
            // 9.3 Navid belts (150Rnd_93x64) -- no Navid in the crate so they were dead weight.
            _crate addMagazineCargoGlobal ["5Rnd_127x108_Mag", 8];
            _crate addMagazineCargoGlobal ["130Rnd_338_Mag", 8];
            // owner 2026-07-18: + MAR-10 (srifle_DMR_02_F) box mags -- the crate had 2 MAR-10s but no ammo for them.
            _crate addMagazineCargoGlobal ["10Rnd_338_Mag", 8];
            _crate allowDamage false;
            // owner 2026-06-19: tag an owner so fn_cleanup spares it. Ownerless objects get reaped almost
            // immediately (fn_cleanup.sqf:77) -- that's why "the crate just vanished" mid-loot. It now lives until
            // the fed RESETS (loonyBinReset clears PLB_mentalLootObjs on event-end / re-seal), like the gold cases.
            _crate setVariable ["owner", "loonybin_weapons", true];
            PLB_mentalLootObjs pushBack _crate;

            // tomb map marker at the church door -- "the tomb will then be located on the map"
            if ((getMarkerPos "life_mentalHospitalPatient") isEqualTo [0,0,0]) then {
                private _mk = createMarker ["life_mentalHospitalPatient", _churchDoorPos];
                _mk setMarkerType "loc_Church";
                _mk setMarkerText "Patient Tomb";
                _mk setMarkerColor "ColorRed";} else {"life_mentalHospitalPatient" setMarkerPos _churchDoorPos;};

            private _code = format ["%1%2%3%4", floor random 10, floor random 10, floor random 10, floor random 10];
            SRV_loonyBinData set [3, _code];
            SRV_loonyBinData set [4, true];   // church tomb door stays locked until the code is entered
            publicVariable "SRV_loonyBinData";
            [[0, format ["The patient transfer code is %1 -- drive to the tomb on your map and enter it at the church door!", _code]], "life_fnc_broadcast", civilian, false, false] spawn life_fnc_MP;
            [["The robbers cracked the Loony Bin network! Defend the patient tomb at the map marker!", "copalert"], "life_fnc_handleMessage", west, false, false] spawn life_fnc_MP;

            // PHASE 4: code unlock -> open the church door + spawn the iridescent Tempest getaway with keys.
            //          The caretaker buries the remains 10 min after the tomb appeared.
            private _buryAt = serverTime + 600;
            private _unlocked = false;
            private _done = false;
            // owner 2026-06-20: the heist won't CLOSE while robbers still hold the scene. A civ "holds" the
            // event open if they're an alive player within 500 m of the hospital and NOT cop-restrained
            // (plb_restrained, set by fn_restrainAction). Robbers are civs, so the crew on-site keeps the
            // caretaker away until they all leave or get cuffed. 500 m mirrors the robbery-charge radius above.
            private _hospPos = getMarkerPos "life_mentalHospital";
            private _fnc_civsHolding = {
                ({ (side _x isEqualTo civilian) && {alive _x} && {isPlayer _x} && {!(_x getVariable ["plb_restrained", false])} && {(_x distance _hospPos) < 500} } count allPlayers) > 0
            };
            private _nextHoldMsg = 0;
            while { !_done } do {uiSleep 2;

                if (!_unlocked && {_keypad getVariable ["plb_mentalUnlockedTomb", false]}) then {_unlocked = true;
                    SRV_loonyBinData set [4, false];
                    publicVariable "SRV_loonyBinData";

                    // unlock the church tomb door
                    (missionNamespace getVariable ["PLB_mentalDoorChurch", [objNull, []]]) params [["_cb", objNull], ["_cidx", []]];
                    if (!isNull _cb) then { { _cb setVariable [format ["bis_disabled_Door_%1", _x], 0, true]; } forEach _cidx; };

                    // iridescent Tempest (Device) getaway, facing east, keys to every non-cop within 200 m
                    private _tPos = [24097.7, 15517.4, 0];
                    private _tempest = "O_Truck_03_device_F" createVehicle _tPos;
                    _tempest setPosATL _tPos;
                    _tempest setDir 90;
                    _tempest lock 0;
                    _tempest setFuel 1;
                    _tempest setVariable ["plb_eventVeh", true, true];
                    _tempest setVariable ["plb_vcap", 999999, true];   // owner 2026-06-19: UNLIMITED Y (virtual) inventory on the getaway Tempest (fn_openInventory reads plb_vcap; default 100) -- haul out all the loot.
                    {_tempest setObjectTextureGlobal [_x, "#(rgb,8,8,3)color(0.1,0.1,0.1,0.08,no)"];
                        _tempest setObjectMaterialGlobal [_x, "\a3\characters_f_kart\civil\data\c_RacingHelmet_VisorEffectMetalic.rvmat"];
                    } forEach [0, 1];
                    private _keys = []; {if ((side _x isEqualTo civilian) && {alive _x} && {(_x distance _tPos) < 200}) then {
                            _keys pushBack [getPlayerUID _x, name _x];
                            [[_tempest], "life_fnc_addVehicle2Chain", _x, false, false] spawn life_fnc_MP;};} forEach allPlayers;
                    _tempest setVariable ["plb_vehOwners", _keys, true];
                    _tempest setVariable ["owner", "loonybin_tempest", true];
                    PLB_mentalTempest = _tempest;
                    [[0, "The tomb is open! A getaway Tempest has been delivered nearby -- load the loot into it and escape!"], "life_fnc_broadcast", civilian, false, false] spawn life_fnc_MP;
                };

                // caretaker buries the remains 10 min after the tomb spawned -> event ends, everything re-seals.
                // owner 2026-06-20: ONLY once the area is clear. While any un-restrained civ player is within 500 m
                // the caretaker can't reach the tomb, so the event stays OPEN (loot + Tempest remain looted-able).
                // The 45-min hard cap (_endAt, below) is the backstop so a lone AFK civ can't hang it forever, and
                // the firewall re-enable (cop win, below) still ends it instantly.
                if ((serverTime > _buryAt) && {!(call _fnc_civsHolding)}) exitWith {
                    [[0, "The caretaker arrived and buried the patient remains -- the Loony Bin robbery is over!"], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
                    _done = true;};
                if ((serverTime > _buryAt) && {serverTime > _nextHoldMsg}) then {_nextHoldMsg = serverTime + 60;
                    [[0, "The caretaker is waiting -- he won't bury the patient while robbers still hold the Loony Bin. APD: clear or restrain everyone near the tomb to end it!"], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
                };
                if (call _fw) exitWith {
                    [[0, "The APD reactivated the Loony Bin firewall and stopped the breach!"], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
                ["resolve", "loonybin", "no"] call TON_fnc_sportsbookResolve;   // LoonyBets: APD held the Bin
                    _done = true;};
                if (serverTime > _endAt) exitWith { _done = true; };};
            call _endEvent;};};
    default { diag_log format ["[LooneyBin][heist] unhandled case: %1", _this]; };};
