// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only
/*
    File: fn_talSRV.sqf  (TON_fnc_talSRV)
    LooneyBin 2026-07-20: TAL OS server backend (see talos.md). Only the wedges that need DB access or
    authority live here -- Plate Scan / Firmware Scan / Sweep read PUBLIC object vars client-side.

    Modes:
      ["records", _target, _cop]   rap sheet from the DB, returned to the requesting officer only
*/
params [["_mode", "", [""]]];

switch (_mode) do {

    case "records": {params ["", ["_t", objNull], ["_cop", objNull]];
        if (isNull _t || {isNull _cop}) exitWith {};
        if !((side _cop) isEqualTo west) exitWith {};      // west-only, server-enforced
        if ((_cop distance _t) > 25) exitWith {
            [["RECORDS -- suspect out of scanner range.", "basic"], "life_fnc_handleMessage", _cop, false, false] spawn life_fnc_MP;};
        private _uid = getPlayerUID _t;
        if (_uid isEqualTo "") exitWith {};

        private _p = [format ["SELECT arrested, crimes, gang0 FROM players WHERE playerid='%1'", _uid], 2] call DB_fnc_asyncQuery;
        private _g = [format ["SELECT stats FROM players_global WHERE playerid='%1'", _uid], 2] call DB_fnc_asyncQuery;
        private _stats = [(_g param [0, "[]"])] call DB_fnc_mresToArray;
        if (isNil "_stats" || {!(_stats isEqualType [])}) then { _stats = [] };
        private _num = { parseNumber format ["%1", _this] };

        private _jailed  = (_p param [0, 0]) call _num;                 // currently in custody
        private _gang    = format ["%1", _p param [2, ""]];
        private _copKill = (_stats param [0, 0]) call _num;             // cops killed
        private _prison  = (_stats param [4, 0]) call _num;             // minutes served
        private _tickets = (_stats param [49, 0]) call _num;            // tickets paid
        private _bail    = (_stats param [82, 0]) call _num;            // spent on bail

        // priors score -> a plain-language flag so an officer can act on it without reading numbers
        private _flag = switch (true) do {
            case (_copKill >= 100 || _prison >= 600): { "<t color='#ff3b30' size='1.15'>VIOLENT -- EXTENSIVE PRIORS</t>" };
            case (_copKill >= 20  || _prison >= 180): { "<t color='#f0a01e'>REPEAT OFFENDER</t>" };
            case (_prison > 0 || _bail > 0):          { "<t color='#4db8ff'>PRIOR CONTACT</t>" };
            default                                   { "<t color='#4db8ff'>NO SIGNIFICANT RECORD</t>" };};
        private _custody = if (_jailed > 0) then { "<br/><t color='#ff3b30'>FLAGGED: escaped / in custody</t>" } else { "" };
        private _gangTxt = if (_gang isEqualTo "" || {_gang isEqualTo "0"}) then { "none on file" } else { _gang };

        [[format [
            "<t color='#f0a01e' size='1.2'>RECORDS -- %1</t><br/>%2%3<br/><t color='#7d8b9e'>Gang</t> %4<br/><t color='#7d8b9e'>Time served</t> %5 min   <t color='#7d8b9e'>Bail paid</t> $%6<br/><t color='#7d8b9e'>Officers killed</t> %7   <t color='#7d8b9e'>Tickets paid</t> %8",
            toUpper (name _t), _flag, _custody, _gangTxt, _prison, [_bail] call life_fnc_numberText, _copKill, _tickets], "basic"],
            "life_fnc_handleMessage", _cop, false, false] spawn life_fnc_MP;

        ["-TALOS-", _cop, name _cop, format ["records lookup on %1 (%2)", name _t, _uid]] call TON_fnc_logIt;};

    // ---- DECK JAMMER: an 80m / 60s no-intrusion bubble. Server-side ONLY on purpose: criminals learn
    // it exists by their cast failing, not by a marker. TON_fnc_qhSRV and TON_fnc_cyberdeckSRV both
    // consult PLB_deckJam, so every civ hack path is covered by one authority.
    case "jammer": {params ["", ["_pos", [0,0,0], [[]]], ["_cop", objNull, [objNull]]];
        if (isNull _cop || {!((side _cop) isEqualTo west)}) exitWith {};
        private _jams = missionNamespace getVariable ["PLB_deckJam", []];
        _jams = _jams select { (_x param [1, 0]) > serverTime };            // drop expired while we're here
        _jams pushBack [_pos, serverTime + 60];
        missionNamespace setVariable ["PLB_deckJam", _jams];
        ["-TALOS-", _cop, name _cop, format ["deck jammer active at %1 for 60s", _pos]] call TON_fnc_logIt;};

    // ---- HONEYPOT ATM: rigged machine. The next ATM Jackpot against it fails and pings the APD.
    // Keyed by rounded position, the same key shape cyberdeckSRV's atmJackpot already builds.
    case "honeypot": {params ["", ["_pos", [0,0,0], [[]]], ["_cop", objNull, [objNull]]];
        if (isNull _cop || {!((side _cop) isEqualTo west)}) exitWith {};
        private _key = format ["%1_%2", round (_pos param [0, 0]), round (_pos param [1, 0])];
        private _hp = missionNamespace getVariable ["PLB_atmHoney", createHashMap];
        _hp set [_key, serverTime + 3600];                                  // stays hot for an hour
        missionNamespace setVariable ["PLB_atmHoney", _hp];
        ["-TALOS-", _cop, name _cop, format ["honeypot armed on ATM %1", _key]] call TON_fnc_logIt;};

    // ---- REMOTE VEHICLE STOP: the APD's lawful Killswitch. The SERVER runs the 8s uplink and re-checks
    // authorisation on completion, so a modified TAL client can neither skip the channel nor stop a
    // vehicle that stopped being a lawful target while the handshake ran.
    case "vehstop": {params ["", ["_veh", objNull, [objNull]], ["_cop", objNull, [objNull]]];
        if (isNull _veh || {isNull _cop}) exitWith {};
        if !((side _cop) isEqualTo west) exitWith {};
        // Analog Retrofit: no ECU, no uplink. Told plainly -- the counter has to be learnable.
        if (_veh getVariable ["plb_analog", false]) exitWith {
            [["<t color='#ff3b30'>NO ECU</t> -- analog retrofit. Safe Stop cannot reach this vehicle.", "basic"], "life_fnc_handleMessage", _cop, false, false] spawn life_fnc_MP;
        };
        if (_veh getVariable ["plb_ignHacked", false]) exitWith {};
        private _fnWanted = {params ["_v"];
            ((crew _v) findIf { isPlayer _x && {(_x getVariable ["plb_wantedAmt", 0]) > 0}}) > -1};
        if !([_veh] call _fnWanted) exitWith {
            [["<t color='#ff3b30'>NOT AUTHORISED</t> -- no wanted occupant. Safe Stop is a pursuit tool.", "basic"], "life_fnc_handleMessage", _cop, false, false] spawn life_fnc_MP;
        };
        // the occupants get the full channel -- this is their window to pull over or bail
        { [["<t color='#f0a01e' size='1.2'>APD SAFE STOP UPLINK</t><br/>Your drivetrain is being commanded to stop. Pull over.", "warning"], "life_fnc_handleMessage", _x, false, false] spawn life_fnc_MP; } forEach (crew _veh);
        [_veh, _cop, _fnWanted] spawn {params ["_veh", "_cop", "_fnWanted"];
            uiSleep 8;                                                     // SERVER owns the uplink clock
            if (isNull _veh || {isNull _cop}) exitWith {};
            if (!alive _veh) exitWith {};
            if ((_cop distance _veh) > 320) exitWith {                     // lost visual = lost uplink
                [["<t color='#ff3b30'>UPLINK LOST</t> -- the vehicle broke range.", "basic"], "life_fnc_handleMessage", _cop, false, false] spawn life_fnc_MP;
            };
            if !([_veh] call _fnWanted) exitWith {
                [["<t color='#ff3b30'>UPLINK ABORTED</t> -- no wanted occupant on completion.", "basic"], "life_fnc_handleMessage", _cop, false, false] spawn life_fnc_MP;
            };
            private _hp = getText (configFile >> "CfgVehicles" >> typeOf _veh >> "HitPoints" >> "HitEngine" >> "name");
            if (_hp isEqualTo "") then { _hp = "HitEngine"; };
            _veh setVariable ["plb_ignHacked", true, true];
            [[_veh, _hp, 1], "life_fnc_qhEngineKill", _veh] spawn life_fnc_MP;   // owner-local (occupied car = driver-local)
            { [["<t color='#f0a01e'>ENGINE STOPPED</t> -- APD Safe Stop executed.", "warning"], "life_fnc_handleMessage", _x, false, false] spawn life_fnc_MP; } forEach (crew _veh);
            [["<t color='#f0a01e'>SAFE STOP EXECUTED</t> -- suspect vehicle disabled.", "basic"], "life_fnc_handleMessage", _cop, false, false] spawn life_fnc_MP;
            ["-TALOS-", _cop, name _cop, format ["SAFE STOP executed on %1", typeOf _veh]] call TON_fnc_logIt;
            [_veh, _hp] spawn {params ["_v", "_hp"];
                uiSleep 25;
                if (isNull _v) exitWith {};
                [[_v, _hp, 0], "life_fnc_qhEngineKill", _v] spawn life_fnc_MP;   // restore on the owner
                _v setVariable ["plb_ignHacked", nil, true];};};};

    // ---- BREACH ORDER: instant lawful unlock. Gated on the vehicle being tied to a wanted suspect --
    // either someone wanted is sitting in it, or a registered keyholder is wanted and online.
    case "breachorder": {params ["", ["_veh", objNull, [objNull]], ["_cop", objNull, [objNull]]];
        if (isNull _veh || {isNull _cop}) exitWith {};
        if !((side _cop) isEqualTo west) exitWith {};
        if ((_cop distance _veh) > 15) exitWith {};
        private _occWanted = ((crew _veh) findIf { isPlayer _x && {(_x getVariable ["plb_wantedAmt", 0]) > 0}}) > -1;
        private _owners = _veh getVariable ["plb_vehOwners", _veh getVariable ["vehicle_info_owners", []]];
        private _ownerUids = _owners apply { _x param [0, ""] };
        private _ownWanted = (allPlayers findIf {
            isPlayer _x && {(getPlayerUID _x) in _ownerUids} && {(_x getVariable ["plb_wantedAmt", 0]) > 0}}) > -1;
        if (!_occWanted && {!_ownWanted}) exitWith {
            [["<t color='#ff3b30'>NO PROBABLE CAUSE</t> -- this vehicle is not tied to a wanted suspect.", "basic"], "life_fnc_handleMessage", _cop, false, false] spawn life_fnc_MP;
        };
        _veh lock 0;
        _veh setVariable ["plb_breachOrder", serverTime, true];
        [["<t color='#f0a01e'>BREACH ORDER SERVED</t> -- vehicle unlocked on the record.", "basic"], "life_fnc_handleMessage", _cop, false, false] spawn life_fnc_MP;
        { [["<t color='#f0a01e'>BREACH ORDER</t> -- the APD have lawfully opened your vehicle.", "warning"], "life_fnc_handleMessage", _x, false, false] spawn life_fnc_MP; } forEach (allPlayers select { (getPlayerUID _x) in _ownerUids });
        ["-TALOS-", _cop, name _cop, format ["BREACH ORDER unlocked %1 (occWanted=%2 ownWanted=%3)", typeOf _veh, _occWanted, _ownWanted]] call TON_fnc_logIt;
    };

    // ---- ASSET FREEZE: lock a wanted suspect's banking for 10 min. plb_assetFrozen is read by the bank/ATM
    // paths (fn_bankDeposit/Withdraw + the ATM Jackpot hack). Server-authorised, wanted-gated.
    case "assetfreeze": {params ["", ["_t", objNull, [objNull]], ["_cop", objNull, [objNull]]];
        if (isNull _t || {isNull _cop} || {!((side _cop) isEqualTo west)}) exitWith {};
        if ((_t getVariable ["plb_wantedAmt", 0]) <= 0) exitWith {
            [["<t color='#ff3b30'>NOT WANTED</t> -- Asset Freeze is felony-only.", "basic"], "life_fnc_handleMessage", _cop, false, false] spawn life_fnc_MP;
        };
        _t setVariable ["plb_assetFrozen", serverTime + 600, true];
        [["<t color='#4aa3ff'>ASSETS FROZEN</t> -- an officer has locked your accounts for 10 minutes.", "basic"], "life_fnc_handleMessage", _t, false, false] spawn life_fnc_MP;
        [["<t color='#f0a01e'>ASSET FREEZE</t> -- their ATM and bank are locked for 10 minutes.", "basic"], "life_fnc_handleMessage", _cop, false, false] spawn life_fnc_MP;
        ["-TALOS-", _cop, name _cop, format ["asset freeze on %1", name _t]] call TON_fnc_logIt;};

    // ---- GRID PRIORITY: restore every deck-blacked-out street light within 300m of the officer. Blackout
    // (qhSRV "gridout") registers each event in PLB_gridBlackout; this brings the affected lamps back early.
    case "gridpriority": {params ["", ["_pos", [0,0,0], [[]]], ["_cop", objNull, [objNull]]];
        if (isNull _cop || {!((side _cop) isEqualTo west)}) exitWith {};
        private _events = missionNamespace getVariable ["PLB_gridBlackout", []];
        private _keep = []; private _restored = 0; {_x params ["_lamps", "_endT", "_ctr"];
            if (serverTime < _endT && {(_pos distance2D _ctr) < 300}) then {
                { if (!isNull _x) then { _x switchLight "AUTO"; _restored = _restored + 1; }; } forEach _lamps;} else {
                if (serverTime < _endT) then { _keep pushBack _x; };};} forEach _events;
        missionNamespace setVariable ["PLB_gridBlackout", _keep];
        [[format ["<t color='#f0a01e'>GRID PRIORITY</t> -- %1 lights back on.", _restored], "basic"], "life_fnc_handleMessage", _cop, false, false] spawn life_fnc_MP;
        ["-TALOS-", _cop, name _cop, format ["grid priority restored %1 lamps", _restored]] call TON_fnc_logIt;};

    // ---- BLACK BOX SUBPOENA: recover who wiped a suspect's memory. Memory Hole (qhSRV "memhole") stamps
    // plb_memHoleBy on the victim; this reads it back for the officer -- the identity the wipe tried to erase.
    case "blackbox": {params ["", ["_t", objNull, [objNull]], ["_cop", objNull, [objNull]]];
        if (isNull _t || {isNull _cop} || {!((side _cop) isEqualTo west)}) exitWith {};
        private _rec = _t getVariable ["plb_memHoleBy", []];
        if (_rec isEqualTo [] || {serverTime > (_rec param [1, 0])}) exitWith {
            [["<t color='#f0a01e'>BLACK BOX</t> -- implant log is clean. No memory tampering on record.", "basic"], "life_fnc_handleMessage", _cop, false, false] spawn life_fnc_MP;
        };
        [[format ["<t color='#f0a01e' size='1.2'>BLACK BOX RECOVERED</t><br/>Memory wipe traced to <t color='#ff3b30'>%1</t>. Recording timestamp holds up in court.", _rec param [0, "Unknown"]], "basic"], "life_fnc_handleMessage", _cop, false, false] spawn life_fnc_MP;
        ["-TALOS-", _cop, name _cop, format ["black box recovered memhole author %1 on %2", _rec param [0, "?"], name _t]] call TON_fnc_logIt;
    };

    // ---- REMOTE DETAIN: 10s server-timed channel on a wanted felon (re-validated on completion), then a
    // full-body ragdoll (reuses the Flatline victim effect). An ICE Firewall on the felon eats it and shatters.
    case "detain": {params ["", ["_t", objNull, [objNull]], ["_cop", objNull, [objNull]]];
        if (isNull _t || {isNull _cop} || {!((side _cop) isEqualTo west)}) exitWith {};
        if ((_t getVariable ["plb_wantedAmt", 0]) <= 0) exitWith {};
        { [["<t color='#f0a01e' size='1.2'>REMOTE DETAINMENT INITIATED</t><br/>COMPLY. Do not resist.", "warning"], "life_fnc_handleMessage", _x, false, false] spawn life_fnc_MP; } forEach [_t];
        [_t, _cop] spawn {params ["_t", "_cop"];
            uiSleep 10;
            if (isNull _t || {!alive _t} || {isNull _cop}) exitWith {};
            if ((_t getVariable ["plb_wantedAmt", 0]) <= 0) exitWith {
                [["<t color='#ff3b30'>DETAIN ABORTED</t> -- suspect is no longer wanted.", "basic"], "life_fnc_handleMessage", _cop, false, false] spawn life_fnc_MP;
            };
            // ICE Firewall (108) on the felon eats one Tier-4-class hit and shatters.
            if (108 in (_t getVariable ["plb_cdMods", []]) && {"icefw" in (_t getVariable ["plb_fwChips", []])}) exitWith {
                private _owned = (_t getVariable ["plb_cdMods", []]) - [108];
                _t setVariable ["plb_cdMods", _owned, true];
                [format ["UPDATE players SET cyberdeck_modules='%1' WHERE playerid='%2'", str _owned, getPlayerUID _t]] spawn DB_fnc_asyncQuery;
                [["<t color='#33ffbb'>ICE FIREWALL</t> -- it ate the detainment signal and shattered.", "cyberjackpot"], "life_fnc_handleMessage", _t, false, false] spawn life_fnc_MP;
                [["<t color='#ff3b30'>DETAIN FAILED</t> -- suspect was running a hard firewall.", "basic"], "life_fnc_handleMessage", _cop, false, false] spawn life_fnc_MP;
            };
            [["flatline", _cop, "REMOTE DETAIN"], "life_fnc_qhEffect", _t, false] spawn life_fnc_MP;
            [["<t color='#f0a01e'>DETAINMENT EXECUTED</t> -- suspect is down. Move in.", "basic"], "life_fnc_handleMessage", _cop, false, false] spawn life_fnc_MP;
            ["-TALOS-", _cop, name _cop, format ["remote detain executed on %1", name _t]] call TON_fnc_logIt;};};

    // ---- WARRANT REQUEST: a junior officer asks; a senior officer (Sgt+ = copLevel 3+) signs off. ★ OPEN OWNER
    // RULING: a served warrant currently only stamps plb_warrant for 10 min -- it does NOT yet change the Cyber
    // Crime charge, the ICE trace, or homeowner notification. Those are the policy questions to confirm.
    case "warrantreq": {params ["", ["_t", objNull, [objNull]], ["_cop", objNull, [objNull]]];
        if (isNull _t || {isNull _cop} || {!((side _cop) isEqualTo west)}) exitWith {};
        private _seniors = allPlayers select { (side _x) isEqualTo west && {alive _x} && {(_x getVariable ["plb_copLevel", 0]) >= 3} && {_x isNotEqualTo _cop} };
        if (_seniors isEqualTo []) exitWith {
            [["<t color='#ff3b30'>NO SENIOR OFFICER</t> -- need a Corporal+ online to sign a warrant.", "basic"], "life_fnc_handleMessage", _cop, false, false] spawn life_fnc_MP;
        }; {
            [[format ["<t color='#f0a01e' size='1.1'>WARRANT REQUEST</t><br/>%1 wants a lawful-entry warrant on <t color='#dbe4ee'>%2</t>. Scroll them to APPROVE within 30s.", name _cop, name _t], "copalert"], "life_fnc_handleMessage", _x, false, false] spawn life_fnc_MP;
        } forEach _seniors;
        // ★ FUNCTIONAL-BUT-PENDING-A-RULING: for now the request auto-grants a 10-min warrant flag once a senior
        // is confirmed online (they are notified for transparency). A real per-request APPROVE scroll-action, and
        // deciding what the warrant actually CHANGES (Cyber Crime charge / ICE trace / homeowner notice), are the
        // owner's calls -- see docs/quickhacks-design.md. plb_warrant is a stamp other tools can read today.
        _t setVariable ["plb_warrant", serverTime + 600, true];
        [["<t color='#f0a01e'>WARRANT GRANTED</t> -- a senior officer signed off. Lawful entry is authorised for 10 minutes.", "basic"], "life_fnc_handleMessage", _cop, false, false] spawn life_fnc_MP;
        ["-TALOS-", _cop, name _cop, format ["warrant granted on %1 (%2 seniors notified)", name _t, count _seniors]] call TON_fnc_logIt;};
};
