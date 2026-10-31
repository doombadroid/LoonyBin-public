/*
    TON_fnc_medicFireSRV  (LooneyBin) -- house-fire controller. Runs on the SERVER.
    2020 client args: ["initArson", [_houseObj]]   (fn_commitArsonClient)

    Was a no-op stub, so the arsonist kit charged/consumed but no fire ever started -> "arson kit isn't
    working". A house fire = `plb_houseOnFire` true on the building (drives the flame loops + blocks AFD
    repair) + the building in the public `SRV_houseOnFire` list (so the fire effect plays for everyone,
    incl. JIP via initPlayerLocal) + life_fnc_medicFireClient broadcast to start the visuals/dispatch.
    If no firefighter puts it out, the house burns down (setDamage 1 -> ruins, repairable via the AFD
    repair system).
*/
params [["_caseType", "", [""]], ["_fireData", [], [[]]]];

switch (_caseType) do {case "initArson": {_fireData params [["_house", objNull, [objNull]]];
        if (isNull _house) exitWith {};
        if (isNil "SRV_houseOnFire") then { SRV_houseOnFire = []; };
        if (_house in SRV_houseOnFire || {_house getVariable ["plb_houseOnFire", false]}) exitWith {};
        if (count SRV_houseOnFire >= 5) exitWith {};

        _house setVariable ["plb_houseOnFire", true, true];
        SRV_houseOnFire pushBackUnique _house;
        publicVariable "SRV_houseOnFire";
        // start the fire visuals/sounds + AFD dispatch on all current clients (JIP joiners get it from initPlayerLocal)
        ["clientFireEffects", [_house, typeOf _house]] remoteExec ["life_fnc_medicFireClient", 0];
        [["-ARSON-", _house, "", format ["house set on fire: %1 at %2", typeOf _house, getPosATL _house]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;

        // owner 2026-07-13: EXTINGUISH PATH (was MISSING -- this controller only had the burn-out timer, so a
        // 100% hose never put the fire out and every burning house collapsed at the 8-min mark regardless).
        // The client hose loop (life_fnc_medicFireClient "toggleFirehose") stamps plb_hoseComplete=true on the
        // firefighter (setVariable target 2 = synced to the server) when their hose reaches 100%. This watcher
        // polls for any completed firefighter within 60m of THIS house (hose ops are anchored within ~50m of it):
        // fire out -> clear plb_houseOnFire (public: stops flames/marker/dispatch loops + releases the gear-swap
        // waitUntil on every responder) + pay each completer via the client "fireFighterPayment" case (which also
        // applies the Hazard Pay talent (243) +25% client-side). Their plb_hoseComplete resets so the next fire
        // starts clean. No completer within 8 min -> the original burn-down below runs unchanged.
        [_house] spawn {params ["_h"];
            private _end = time + 480;
            private _crew = [];
            waitUntil {uiSleep 5;
                if (isNull _h || {!(_h getVariable ["plb_houseOnFire", false])}) exitWith { true };
                _crew = allPlayers select { alive _x && {_x getVariable ["plb_hoseComplete", false]} && {_x distance2D _h < 60} };
                (_crew isNotEqualTo []) || {time > _end}};
            if (isNull _h) exitWith {   // house object vanished mid-fire -> purge the stale list entry
                SRV_houseOnFire = SRV_houseOnFire select { !isNull _x };
                publicVariable "SRV_houseOnFire";};
            if (_crew isNotEqualTo [] && {_h getVariable ["plb_houseOnFire", false]}) exitWith {
                _h setVariable ["plb_houseOnFire", false, true];
                SRV_houseOnFire = SRV_houseOnFire - [_h];
                publicVariable "SRV_houseOnFire";
                private _fee = 25000;   // per-firefighter payout (tunable; Hazard Pay adds +25% on the client)
                private _ownerUID = format ["%1", _h getVariable ["plb_homeOwner", ""]]; {_x setVariable ["plb_hoseComplete", false, true];
                    ["fireFighterPayment", [_fee, _ownerUID, typeOf _h, _h]] remoteExec ["life_fnc_medicFireClient", _x];} forEach _crew;
                diag_log format ["[LooneyBin][medicFireSRV] fire EXTINGUISHED: %1 at %2 by %3 firefighter(s)", typeOf _h, getPosATL _h, count _crew];
            };
            if (!isNull _h && {_h getVariable ["plb_houseOnFire", false]} && {time > _end}) then {
                _h setVariable ["plb_houseOnFire", false, true];
                SRV_houseOnFire = SRV_houseOnFire - [_h];
                publicVariable "SRV_houseOnFire";
                // owner 2026-07-11 (Malden Makeover): a maldened SHELL is a dynamic spawn -- setDamage 1 kills
                // it with NO ruin and leaves malden=1 (the house would resurrect pristine next restart). Route
                // through the makeover destroy path instead: original restored + properly ruined + flag cleared.
                if ((_h getVariable ["plb_malden", false]) && {!isNil "PLB_fnc_maldenDestroy"}) then {
                    [format ["%1", _h getVariable ["plb_houseID", ""]]] call PLB_fnc_maldenDestroy;} else {
                    _h setDamage 1;   // burned to ruins (AFD can repair it later)
                };};};};
    default { diag_log format ["[LooneyBin][medicFireSRV] unhandled case: %1", _caseType]; };};
