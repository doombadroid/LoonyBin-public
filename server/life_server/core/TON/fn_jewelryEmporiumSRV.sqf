/*
    TON_fnc_jewelryEmporiumSRV  (LooneyBin -- implemented from stub 2026-06-09)
    Jewelry Emporium heist server half. Client (core/actions/fn_jewelryEmporium.sqf) drives all the
    progress bars + loot; this owns the shared state:
      SRV_jewelryEmporiumSRV = [lastBreach, active, safeDrilled, safeWelded, casesLootable, 0, copsRequired]
    Client cases sent here:
      ["robberyStarted", [player]]            drill succeeded -> event live: alarm on (client PFH keys on
                                              [1]), cases breakable ([4]), safe drilled ([2]); cop alert
      ["weldSafe",       [safeObj, player]]   weld done -> [3] true (crowbar/loot gate)
      ["createCase",     [caseObj]]           a display case was smashed -> mark it looted (authoritative)
    Event auto-ends after 20 min: state reset, cases + safe restored for the next run (30-min cooldown
    is client-gated on slot 0).
*/
params [["_caseType", "", [""]], ["_data", [], [[]]]];

switch (_caseType) do {case "robberyStarted": {_data params [["_robber", objNull, [objNull]]];
        if (SRV_jewelryEmporiumSRV param [1, false]) exitWith {};
        // owner 2026-06-16 (#302): server-authoritative one-federal-event-at-a-time gate (client check has a window).
        if (["jewelry"] call PLB_fnc_fedEventActive) exitWith {
            [[2, "Another major crime is already in progress -- the Jewelry Emporium job is a no-go."], "life_fnc_broadcast", _robber, false, false] spawn life_fnc_MP;
        };
        // owner 2026-06-13: SERVER-AUTHORITATIVE cop gate (copsRequired = slot 6, default 6). Was client-only;
        // a JIP client whose PLB_betaZeroCops hadn't synced could trip it understaffed. exitWith here is the
        // case-block scope (mirrors the active-check above) -> stops the start before it activates.
        // owner 2026-06-22 (#496): TENURED cop count (continuously on-duty >= PLB_copTenureReq), anti soft-log.
        // owner 2026-07-03: floor the Jewelry Emporium cop requirement at 1 (beta data may hold 0).
        if ((([] call PLB_fnc_tenuredCops) < ((SRV_jewelryEmporiumSRV param [6, 6]) max 1)) && {!(missionNamespace getVariable ["PLB_betaZeroCops", false])}) exitWith {
            [[2, format ["The Jewelry Emporium cannot be robbed with fewer than %1 police officer(s) online.", (SRV_jewelryEmporiumSRV param [6, 6]) max 1]], "life_fnc_broadcast", _robber, false, false] spawn life_fnc_MP;
        };
        SRV_jewelryEmporiumSRV = [serverTime, true, true, false, true, 0, SRV_jewelryEmporiumSRV param [6, 6]];
        publicVariable "SRV_jewelryEmporiumSRV";
        SRV_jewelryComponentDropped = false;   // owner 2026-07-18: re-arm the mining-component drop for this event
        [[0, "The Jewelry Emporium is being ROBBED! The APD must respond!"], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
        [["The Jewelry Emporium alarm has been tripped -- respond now!", "copalert"], "life_fnc_handleMessage", west, false, false] spawn life_fnc_MP;
        // owner 2026-06-16 (#301): robbing the emporium never applied a wanted charge. Charge the driller and
        // any civilian within 90m with "Jewelry Emporium Robbery" (charge 76), mirroring the bank's 90m pass.
        {if ((side _x isEqualTo civilian) && {(_x distance2D [20720, 16620, 0]) < 90}) then { [76, _x] call TON_fnc_wantedAdd; };
        } forEach allPlayers;
        diag_log format ["[LooneyBin][jewelry] robbery started by %1", name _robber];
        [] spawn {private _endAt = serverTime + 1200;   // 20-min window
            waitUntil { uiSleep 5; serverTime > _endAt };
            if !(SRV_jewelryEmporiumSRV param [3, false]) then { ["resolve", "jewelry", "no"] call TON_fnc_sportsbookResolve; };   // LoonyBets: window closed, safe never welded
            SRV_jewelryEmporiumSRV set [1, false];
            SRV_jewelryEmporiumSRV set [2, false];
            SRV_jewelryEmporiumSRV set [3, false];
            SRV_jewelryEmporiumSRV set [4, false];
            publicVariable "SRV_jewelryEmporiumSRV";
            // restore the scene for the next run: display cases + safe lootable again
            {_x setVariable ["plb_jewelCaseLooted", false, true];
                _x setVariable ["plb_droppedItems", [], true];   // owner 2026-07-18: clear any un-grabbed mining component
            } forEach (nearestObjects [[20720, 16620, 0], ["Coffin_02_F"], 120]);
            if (!isNil "life_jewerlySafe") then { life_jewerlySafe setVariable ["plb_jewelSafeLooted", false, true]; };
            diag_log "[LooneyBin][jewelry] event window closed, scene reset";};};
    case "weldSafe": {_data params [["_safe", objNull, [objNull]], ["_robber", objNull, [objNull]]];
        if !(SRV_jewelryEmporiumSRV param [1, false]) exitWith {};
        // owner 2026-07-24 SECURITY (audit): the active-event check above was the ONLY guard, so during any
        // live robbery any client could remoteExec this and instantly flip safeWelded -- which resolves the
        // LoonyBets "jewelry" market YES on demand, letting a bettor settle their own wager. Require the
        // safe to have actually been DRILLED first (index 2, the real prerequisite for welding) and a
        // client caller to be standing at it.
        if !(SRV_jewelryEmporiumSRV param [2, false]) exitWith {
            ["-SEC-", _robber, "BLOCKED jewelry weldSafe (safe not drilled)"] call PLB_fnc_logIt;};
        private _srcWS = remoteExecutedOwner;   // 0 == server-internal = trusted
        if (_srcWS isNotEqualTo 0) then {private _wsCaller = (allPlayers select { owner _x isEqualTo _srcWS }) param [0, objNull];
            if (isNull _wsCaller || {isNull _safe} || {(_wsCaller distance _safe) > 30}) exitWith {
                ["-SEC-", _wsCaller, "BLOCKED jewelry weldSafe (caller not at the safe)"] call PLB_fnc_logIt;
                _data = [];   // signal for the guard below
            };};
        if (_data isEqualTo []) exitWith {};
        SRV_jewelryEmporiumSRV set [3, true];
        publicVariable "SRV_jewelryEmporiumSRV";
        ["resolve", "jewelry", "yes"] call TON_fnc_sportsbookResolve;   // LoonyBets: safe welded open
        diag_log format ["[LooneyBin][jewelry] safe welded by %1", name _robber];};
    case "createCase": {_data params [["_oldCase", objNull, [objNull]]];
        if (isNull _oldCase) exitWith {};
        // owner 2026-07-24 SECURITY (audit): this spawned a Land_Trophy_01_gold_F on EVERY call with the
        // only guard being isNull _oldCase. It SET plb_jewelCaseLooted without ever CHECKING it, and never
        // looked at the event state, so any client could remoteExec it repeatedly -- on the same display
        // case, with no robbery running -- for unlimited gold trophies. Gate on the state the robbery
        // already maintains: cases must be lootable (SRV_jewelryEmporiumSRV index 4, set true on
        // robberyStarted and cleared when the window closes), this case must not have been looted already,
        // and a client caller must be standing at it.
        if !(SRV_jewelryEmporiumSRV param [4, false]) exitWith {
            ["-SEC-", objNull, "BLOCKED jewelry createCase (cases not lootable / no robbery active)"] call PLB_fnc_logIt;};
        if (_oldCase getVariable ["plb_jewelCaseLooted", false]) exitWith {
            ["-SEC-", objNull, "BLOCKED jewelry createCase (case already looted)"] call PLB_fnc_logIt;};
        private _srcJC = remoteExecutedOwner;   // 0 == server-internal = trusted
        if (_srcJC isNotEqualTo 0) then {private _jcCaller = (allPlayers select { owner _x isEqualTo _srcJC }) param [0, objNull];
            if (isNull _jcCaller || {(_jcCaller distance _oldCase) > 30}) exitWith {
                ["-SEC-", _jcCaller, format ["BLOCKED jewelry createCase (range %1)",
                    if (isNull _jcCaller) then {-1} else {round (_jcCaller distance _oldCase)}]] call PLB_fnc_logIt;
                _data = [];   // signal: the isNull guard re-checked below exits the case
            };};
        if (_data isEqualTo []) exitWith {};
        _oldCase setVariable ["plb_jewelCaseLooted", true, true];
        // owner 2026-07-18: 1 crypto MINING COMPONENT rides on ONE smashed display case (the same container as a
        // trophy), looted via the "Pick Up Item(s)" menu. Once per event (SRV_jewelryComponentDropped, reset on
        // robberyStarted + cleared on window-close). Attached to the persistent Coffin, NOT the trophy (the
        // trophy is deleteVehicle'd the instant it's grabbed -> would lose the component to a grab race).
        if !(missionNamespace getVariable ["SRV_jewelryComponentDropped", false]) then {SRV_jewelryComponentDropped = true;
            _oldCase setVariable ["owner", "jewelry_component", true];
            _oldCase setVariable ["plb_droppedItems", [[selectRandom ["cryptoCPU","cryptoGPU","cryptoPSU","cryptoStorage","cryptoMotherboard","cryptoRam","cryptoCooler","cryptoCase"], 1]], true];
        };
        // #149: spawn the grabbable jewelry loot on the smashed case. The client (takeJewelryContents)
        // grabs a Land_Trophy_01_gold_F off the case -> jewelBag. Without this, broken cases gave no loot.
        private _pos = _oldCase modelToWorld [0, 0, 0.9];
        private _loot = createVehicle ["Land_Trophy_01_gold_F", _pos, [], 0, "CAN_COLLIDE"];
        _loot setPosATL _pos;
        _loot setDir (getDir _oldCase);
        _loot setVariable ["plb_furniture", true, true];   // #152: exempt from fn_cleanup's sweep (was deleting the loot)
        diag_log format ["[LooneyBin][jewelry] case smashed -> loot trophy spawned at %1", _pos];};
    default { diag_log format ["[LooneyBin][jewelry] unhandled case: %1", _this]; };};
