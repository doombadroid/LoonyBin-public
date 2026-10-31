// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only
/*
    File: fn_cyberdeckSRV.sqf  (TON_fnc_cyberdeckSRV)
    LooneyBin 2026-07-18: Cyberdeck server backend -- the bits that must survive the hacker disconnecting
    or need cross-player resolution: house break-in alerts + door relock, crypto rig takeover.
    The minigame + the immediate door unlock run client-side (parity with fn_boltcutter forced entry).
*/
params [["_mode", "", [""]]];

// DECK JAMMER (TAL, Captain+): an active 80m bubble kills civilian intrusions outright. Called with
// `call` so it can see this file's privates -- do NOT move these call sites inside a spawn block.
private _fnJammed = {params [["_jpos", [0,0,0], [[]]], ["_who", objNull, [objNull]]];
    private _jams = (missionNamespace getVariable ["PLB_deckJam", []]) select { (_x param [1, 0]) > serverTime };
    missionNamespace setVariable ["PLB_deckJam", _jams];
    private _hit = (_jams findIf { (_jpos distance2D (_x param [0, [0,0,0]])) < 80 }) > -1;
    if (_hit && {!isNull _who}) then {
        [["<t color='#ff3b1e'>SIGNAL JAMMED</t> -- APD counter-intrusion field. Your deck can't reach anything here.", "warning"], "life_fnc_handleMessage", _who, false, false] spawn life_fnc_MP;
    };
    _hit};

switch (_mode) do {

    // House break-in -- fires on EVERY attempt (success OR fail). Owner toast + APD alert always;
    // doors relock after 3 min on success (survives the hacker leaving).
    case "houseBreach": {params ["", ["_house", objNull], ["_hacker", objNull], ["_success", false]];
        if (isNull _house) exitWith {};
        if ([getPosATL _house, _hacker] call _fnJammed) exitWith {};
        private _loc = (nearestLocations [getPosATL _house, ["NameCityCapital", "NameCity", "NameVillage", "NameLocal"], 3000]) param [0, locationNull];
        private _town = if (isNull _loc) then { "an outlying area" } else { text _loc };

        // APD alert -- always
        if !([_hacker, "HOUSE BREACH", getPosATL _house] call TON_fnc_iceTrace) then {
            [[format ["Someone was spotted breaking into a house in %1.", _town], "copalert"], "life_fnc_handleMessage", west, false, false] spawn life_fnc_MP;
        };

        // owner toast -- always (resolved at notify-time so a relog still gets it)
        private _ownerUID = _house getVariable ["plb_homeOwner", ""];
        if !(_ownerUID isEqualTo "") then {
            private _owner = allPlayers param [allPlayers findIf { getPlayerUID _x isEqualTo _ownerUID }, objNull];
            if (!isNull _owner) then {private _msg = if (_success) then {
                    "<t color='#ff3030'>SECURITY BREACH</t> -- someone hacked your house locks and got IN. Your doors are open."} else {
                    "<t color='#ff3030'>SECURITY ALERT</t> -- someone tried to hack your house locks and failed."};
                [[_msg, "warning"], "life_fnc_handleMessage", _owner, false, false] spawn life_fnc_MP;};};

        // relock all doors after 3 minutes on success; clear the house furniture during the breach so it can't
        // be shoved against the doors to barricade them, then restore it when the house relocks.
        if (_success) then {private _furn = [];
            if (!isNil "PLB_furnCache") then {private _hk = format ["%1", _house getVariable ["plb_houseID", -1]];
                _furn = (PLB_furnCache getOrDefault [_hk, []]) param [3, []];
                { if (!isNull _x) then { _x hideObjectGlobal true; }; } forEach _furn;   // rig is NOT in furnCache, stays visible
            };
            [_house, _furn] spawn {params ["_house", "_furn"];
                uiSleep 180;
                { if (!isNull _x) then { _x hideObjectGlobal false; }; } forEach _furn;   // restore furniture
                if (isNull _house) exitWith {};
                private _nd = getNumber (configFile >> "CfgVehicles" >> typeOf _house >> "numberOfDoors");
                private _shop = (typeOf _house) in ["Land_i_Shop_01_V1_F", "Land_i_Shop_01_V2_F", "Land_i_Shop_01_V3_F"];
                for "_i" from 1 to _nd do {if !(_shop && {_i in [1, 3]}) then {
                        _house setVariable [format ["bis_disabled_Door_%1", _i], 1, true];
                        _house animate [format ["door_%1_rot", _i], 0];};};
                _house setVariable ["plb_locked", true, true];};};};

    // Crypto rig hijack -- reassign rig ownership to the hacker (all composition pieces + hashmap),
    // notify the previous owner. (Phase 5: refine collect exclusivity vs the house owner.)
    case "cryptoTakeover": {params ["", ["_rig", objNull], ["_newOwner", objNull]];
        if (isNull _rig || {isNull _newOwner}) exitWith {};
        if ([getPosATL _rig, _newOwner] call _fnJammed) exitWith {};
        // multi-rig (owner 2026-07-22): rigs are keyed by house_rigs.id -- a hack flips ONLY the targeted
        // rig. Other rigs in the same house each need their own hack (each with its own trace risk).
        private _rid = format ["%1", _rig getVariable ["plb_rigId", ""]];
        private _newUID = getPlayerUID _newOwner;
        private _oldUID = _rig getVariable ["plb_rigOwner", ""];
        private _rec = [];
        if (!isNil "PLB_cryptoRigs") then { _rec = PLB_cryptoRigs getOrDefault [_rid, []]; };
        // owner rule 2026-07-18: keyholders (and the house owner) CANNOT hack their own rig -- hacking is for
        // OUTSIDERS only. Reject server-side if the hacker holds keys to (or owns) the rig's house.
        private _rigHouse = _rec param [0, objNull];
        private _insider = !isNull _rigHouse && {(_rigHouse getVariable ["plb_homeOwner", ""]) isEqualTo _newUID
            || {((_rigHouse getVariable ["plb_house_keys", []]) findIf { (_x param [0, ""]) isEqualTo _newUID }) != -1}};
        if (_insider) exitWith {
            [["You hold keys to this house -- you can't hack its rig.", "basic"], "life_fnc_handleMessage", _newOwner, false, false] spawn life_fnc_MP;
        };
        private _objs = _rec param [2, []];
        if (_objs isEqualTo []) then { _objs = [_rig]; };
        { if (!isNull _x) then { _x setVariable ["plb_rigOwner", _newUID, true]; }; } forEach _objs;
        if (!isNil "PLB_cryptoRigs" && {_rec isNotEqualTo []}) then {
            PLB_cryptoRigs set [_rid, [_rec param [0, objNull], _newUID, _objs, _rec param [3, ""]]];};
        if (_rid isNotEqualTo "") then {
            // persist so the steal survives a restart (reload reads house_rigs.owner)
            [format ["UPDATE house_rigs SET owner='%1' WHERE id=%2", _newUID, _rid], 2, false] call DB_fnc_asyncQuery;};

        if !(_oldUID isEqualTo "") then {
            private _old = allPlayers param [allPlayers findIf { getPlayerUID _x isEqualTo _oldUID }, objNull];
            if (!isNull _old) then {
                [["<t color='#ff3030'>RIG HIJACKED</t> -- someone took over your crypto mining rig!", "warning"], "life_fnc_handleMessage", _old, false, false] spawn life_fnc_MP;
            };};
        // trace regardless of whether the previous owner happens to be online
        [_newOwner, "RIG HIJACK", getPosATL _rig] call TON_fnc_iceTrace;};

    // Hack Ignition (cdfeatures #3): temporarily fry any vehicle's engine (~22s), then auto-restore. Folds in the
    // old remote engine kill switch. setHit MUST run where the vehicle is local -- an occupied car is local to
    // its DRIVER, not the server, so we route it through life_fnc_qhEngineKill targeted at the vehicle (owner).
    case "ignition": {params ["", ["_veh", objNull], ["_hacker", objNull]];
        if (isNull _veh) exitWith {};
        if ([getPosATL _veh, _hacker] call _fnJammed) exitWith {};
        // ANALOG RETROFIT (mods slot 9 = 2): there is no onboard computer to fry. Server-authoritative -- a
        // modified client cannot skip this, and the hacker is told WHY so the counter is discoverable rather
        // than feeling like a broken hack.
        if (_veh getVariable ["plb_analog", false]) exitWith {if (!isNull _hacker) then {
                [["<t color='#ff3b1e'>NO ECU FOUND</t> -- this thing is an analog retrofit. Nothing to hack.", "warning"], "life_fnc_handleMessage", _hacker, false, false] spawn life_fnc_MP;
            };};
        if (_veh getVariable ["plb_ignHacked", false]) exitWith {};   // already down
        _veh setVariable ["plb_ignHacked", true, true];
        private _hp = getText (configFile >> "CfgVehicles" >> typeOf _veh >> "HitPoints" >> "HitEngine" >> "name");
        if (_hp isEqualTo "") then { _hp = "HitEngine"; };
        [[_veh, _hp, 1], "life_fnc_qhEngineKill", _veh] spawn life_fnc_MP;   // runs on the vehicle's OWNER
        { [["<t color='#ff3030'>SYSTEMS COMPROMISED</t> -- ignition fried, engine offline.", "warning"], "life_fnc_handleMessage", _x, false, false] spawn life_fnc_MP; } forEach (crew _veh);
        [_hacker, "IGNITION HACK", getPosATL _veh] call TON_fnc_iceTrace;
        if (!isNull _hacker) then { ["-CYBERDECK-", _hacker, name _hacker, format ["hacked the ignition of a %1", typeOf _veh]] call TON_fnc_logIt; };
        [_veh, _hp] spawn {params ["_v", "_hp"];
            uiSleep 22;
            if (isNull _v) exitWith {};
            [[_v, _hp, 0], "life_fnc_qhEngineKill", _v] spawn life_fnc_MP;   // restore the engine on its owner
            _v setVariable ["plb_ignHacked", nil, true];};};

    // GHOST KEY trace window (owner 2026-07-21): a deck breach on someone's vehicle is silent to the street but
    // NOT invisible to the owner. Every online keyholder except the thief gets the standard INTRUSION alert and
    // the 10s trace-back, routed through life_fnc_qhEffect so the trace plumbing stays in exactly one place.
    // Server-side so the thief's client cannot decide to skip telling anyone.
    case "ghostkey": {params ["", ["_veh", objNull, [objNull]], ["_hacker", objNull, [objNull]]];
        if (isNull _veh || {isNull _hacker}) exitWith {};
        private _owners = _veh getVariable ["plb_vehOwners", []];
        private _uids = _owners apply { _x param [0, ""] };
        private _hackerUid = getPlayerUID _hacker;
        private _notify = allPlayers select { isPlayer _x && {(getPlayerUID _x) in _uids} && {(getPlayerUID _x) isNotEqualTo _hackerUid} };
        { [["ghostkey", _hacker, "GHOST KEY"], "life_fnc_qhEffect", _x, false] spawn life_fnc_MP; } forEach _notify;
        if (_notify isNotEqualTo []) then {
            ["-CYBERDECK-", _hacker, name _hacker, format ["ghost key on %1 -- %2 keyholder(s) alerted", typeOf _veh, count _notify]] call TON_fnc_logIt;
        };};

    // ATM jackpot (cdfeatures #2): server rolls a weighted $100-50k payout, hands it over as CASH, pings APD.
    // Limits: each WORLD ATM (Land_Atm_01/02_F) is drainable ONCE per restart; the hacker then has a 15-min
    // deck cooldown (UID-keyed -> relog-proof until restart). All checks are server-authoritative.
    case "atmJackpot": {
        // NB: ATMs are createSimpleObject/createVehicleLocal (LOCAL, no network id) so the client's object arrives
        // null here -- the client passes the POSITION and we resolve OUR OWN local ATM copy at that spot.
        params ["", ["_pos", [], [[]]], ["_hacker", objNull]];
        if (_pos isEqualTo [] || {isNull _hacker}) exitWith {};
        // ASSET FREEZE (owner 2026-07-21): a frozen suspect can't jackpot an ATM either -- server-enforced here.
        if ((_hacker getVariable ["plb_assetFrozen", 0]) > serverTime) exitWith {
            [["<t color='#4aa3ff'>ACCOUNTS FROZEN</t> -- the machine won't talk to you while your assets are locked.", "basic"], "life_fnc_handleMessage", _hacker, false, false] spawn life_fnc_MP;
        };
        // World ATMs are client-only (createSimpleObject, mapData _xIsServer=false) -- the server has NO ATM object
        // to resolve. Validate the position against the mapData ATM coordinates instead (cached). Anti-spoof for a
        // hacked client sending a bogus position. Fallback: if the map list is somehow empty, don't hard-block --
        // the hacker-distance gate below still applies.
        private _atmPts = missionNamespace getVariable ["plb_atmPts", []];
        if (_atmPts isEqualTo []) then {private _mapEnts = missionNamespace getVariable ["allLocalMapEntities", []];
            _atmPts = (_mapEnts select { (_x select 0) in ["Land_Atm_01_F", "Land_Atm_02_F"] }) apply { _x select 1 };
            missionNamespace setVariable ["plb_atmPts", _atmPts];};
        if (count _atmPts > 0 && {(_atmPts findIf { (_pos distance2D _x) < 4 }) < 0}) exitWith {};
        if ((_hacker distance _pos) > 8) exitWith {};
        if ([_pos, _hacker] call _fnJammed) exitWith {};
        private _uid = getPlayerUID _hacker;
        private _akey = format ["%1_%2", round (_pos select 0), round (_pos select 1)];
        // HONEYPOT ATM (TAL, Captain+): the machine is bait. The hack "succeeds" into nothing, the deck
        // takes the full cooldown anyway, and the APD gets a LOCATED ping -- a Proxy Chain does not
        // suppress this one: the alert comes from the bank's own hardware, not from tracing the intruder.
        private _honey = missionNamespace getVariable ["PLB_atmHoney", createHashMap];
        if (serverTime < (_honey getOrDefault [_akey, 0])) exitWith {
            _honey deleteAt _akey;                                          // one-shot: the trap is spent
            missionNamespace setVariable ["PLB_atmHoney", _honey];
            private _cdSecsH = if (2 in (_hacker getVariable ["plb_cdMods", []])) then { 600 } else { 900 };
            missionNamespace setVariable ["plb_atmCd_" + _uid, diag_tickTime + _cdSecsH];
            [["<t color='#ff3b1e'>HONEYPOT</t> -- that machine was bait. Your payload dumped into a dead account and something just phoned home.", "warning"], "life_fnc_handleMessage", _hacker, false, false] spawn life_fnc_MP;
            private _hLoc = (nearestLocations [_pos, ["NameCityCapital", "NameCity", "NameVillage", "NameLocal"], 3000]) param [0, locationNull];
            private _hTown = if (isNull _hLoc) then { "an outlying area" } else { text _hLoc };
            [[format ["HONEYPOT TRIPPED -- a deck just hit the rigged ATM in %1.", _hTown], "copalert"], "life_fnc_handleMessage", west, false, false] spawn life_fnc_MP;
            [[getPosATL _hacker, "HONEYPOT HIT", "ColorRed", true], "life_fnc_talMarker", west, false] spawn life_fnc_MP;
            ["-CYBERDECK-", _hacker, name _hacker, format ["HONEYPOT tripped at ATM %1 (%2)", _akey, _hTown]] call TON_fnc_logIt;};
        // per-ATM: once per restart (position-key list, broadcast so clients can pre-gate)
        private _done = missionNamespace getVariable ["plb_atmDoneKeys", []];
        if (_akey in _done) exitWith {
            [["This ATM's already been drained this restart -- find another one.", "basic"], "life_fnc_handleMessage", _hacker, false, false] spawn life_fnc_MP;
        };
        // per-player: 15-min cooldown, keyed by UID so it survives a relog until restart
        private _cdKey = "plb_atmCd_" + _uid;
        private _cd = missionNamespace getVariable [_cdKey, 0];
        if (diag_tickTime < _cd) exitWith {
            [[format ["Your deck is still cooling down -- ~%1 min before the next ATM.", ceil ((_cd - diag_tickTime) / 60)], "basic"], "life_fnc_handleMessage", _hacker, false, false] spawn life_fnc_MP;
        };
        _done pushBack _akey; missionNamespace setVariable ["plb_atmDoneKeys", _done, true];   // drained until restart (public -> clients pre-gate)
        private _cdSecs = if (2 in (_hacker getVariable ["plb_cdMods", []])) then { 600 } else { 900 };   // Cooling Rig module: 15 -> 10 min
        missionNamespace setVariable [_cdKey, diag_tickTime + _cdSecs];   // player cooldown (server-side, authoritative)
        private _roll = random 1;
        private _amt = switch (true) do {case (_roll > 0.98): { 20000 + floor (random 30001) };   // ~2%  -> 20k-50k
            case (_roll > 0.85): { 5000  + floor (random 12001) };   // ~13% -> 5k-17k
            case (_roll > 0.55): { 1000  + floor (random 3001) };    // ~30% -> 1k-4k
            default              { 100   + floor (random 901) };     // ~55% -> 100-1000
        };
        _amt = (_amt min 50000) max 100;
        [["cash", "add", _amt], "life_fnc_uC", _hacker, false] spawn life_fnc_MP;   // PHYSICAL CASH -- server-authoritative amount, client persists it via the normal partial-save
        [[format ["You skimmed <t color='#c9e21a'>$%1</t> in cash from the ATM before the trace cut you off. Get it to a bank before a cop finds you.", [_amt] call life_fnc_numberText], "cyberjackpot"], "life_fnc_handleMessage", _hacker, false, false] spawn life_fnc_MP;
        private _loc = (nearestLocations [_pos, ["NameCityCapital", "NameCity", "NameVillage", "NameLocal"], 3000]) param [0, locationNull];
        private _town = if (isNull _loc) then { "an outlying area" } else { text _loc };
        // ICE TRACE is the single authority on whether a hack is quiet (burns an armed Proxy Chain).
        private _quiet = [_hacker, "ATM HACK", _pos] call TON_fnc_iceTrace;
        if (!_quiet) then {
            [[format ["ATM tamper alarm -- someone is hacking an ATM in %1.", _town], "copalert"], "life_fnc_handleMessage", west, false, false] spawn life_fnc_MP;
        };
        ["-CYBERDECK-", _hacker, name _hacker, format ["ATM jackpot hack -> $%1 CASH", _amt]] call TON_fnc_logIt;};

    // Cyberdeck permanent module purchase (owner 2026-07-20). Client already deducted the price (client-authoritative
    // money, same trust boundary as the virtual shop); server validates not-owned, grants, and PERSISTS to the column.
    case "buyModule": {params ["", ["_modId", -1], ["_buyer", objNull]];
        if (isNull _buyer || {_modId isNotEqualTo 0}) exitWith {};   // owner 2026-07-23: scroll-buy is firmware-flash ONLY now -- every other module installs via its shop chip ("installHack"). (Old whitelist also never included 105-112, so those scroll buys took money and installed nothing.)
        private _owned = _buyer getVariable ["plb_cdMods", []];
        if (_modId in _owned) exitWith {
            [["You already own that module.", "basic"], "life_fnc_handleMessage", _buyer, false, false] spawn life_fnc_MP;};
        _owned pushBack _modId;
        _buyer setVariable ["plb_cdMods", _owned, true];
        [format ["UPDATE players SET cyberdeck_modules='%1' WHERE playerid='%2'", str _owned, getPlayerUID _buyer]] spawn DB_fnc_asyncQuery;
        private _nm = switch (_modId) do {case 101: { "Scrambler Chip" }; case 102: { "Optic Filter" };
            case 103: { "Audio Limiter" }; case 104: { "Hardened Firmware" };
            default { ["Cyberdeck Firmware", "Overclock Module", "Cooling Rig", "Signal Amp"] select _modId };};
        private _msg = if (_modId isEqualTo 0) then {
            "<t color='#c9e21a'>FIRMWARE FLASHED</t> -- ICEBREAKER OS is live on your phone. Keep it off the APD's radar."} else {
            format ["<t color='#c9e21a'>MODULE INSTALLED</t> -- %1 is now active on your deck.", _nm]};
        [[_msg, "cyberjackpot"], "life_fnc_handleMessage", _buyer, false, false] spawn life_fnc_MP;
        ["-CYBERDECK-", _buyer, name _buyer, format ["bought cyberdeck id %1 (%2)", _modId, _nm]] call TON_fnc_logIt;};

    // Drop-only hack chip install (client consumed the item via handleInv; ids 200+ = loot-gated quickhacks)
    case "installHack": {params ["", ["_hackId", -1], ["_buyer", objNull]];
        // The whitelist is the security boundary: without it a crafted client could install ANY id, including
        // the firmware a Factory Reset just stripped. Chip-model (owner 2026-07-22): every civ hack has a chip,
        // so the hack-chip whitelist DERIVES from the catalogue's field 13 (single source of truth -- adding a
        // row to fn_qhCfg is the whole registration). Literal extras: 108/110 utility chips, plus the deck
        // modules + firewall permanents (owner 2026-07-23 -- Kabuki scroll-buys became shop chips; ids match
        // PLB_cdModules). Firmware (0) is deliberately NOT here -- it installs only via "buyModule" flash.
        private _extras = createHashMapFromArray [[108, "ICE Firewall"], [110, "Dead Man's Clutch"],
            [1, "Overclock"], [2, "Cooling Rig"], [3, "Signal Amp"], [101, "Scrambler"],
            [102, "Optic Filter"], [103, "Audio Limiter"], [104, "Hardened Firmware"], [105, "Deadbolt"],
            [106, "Freq-Hop Radio"], [107, "Encrypted SIM"], [109, "Surge Protector"], [111, "Co-Pilot Guardian"], [112, "Sealed Tank"]];
        private _hackRow = (["civ"] call life_fnc_qhCfg) select { (_x param [12, -1]) isEqualTo _hackId };
        if (isNull _buyer || {(_hackRow isEqualTo []) && {!(_hackId in keys _extras)}}) exitWith {};
        private _names = _extras;
        if (_hackRow isNotEqualTo []) then { _names set [_hackId, (_hackRow select 0) select 1]; };
        private _owned = _buyer getVariable ["plb_cdMods", []];
        if (_hackId in _owned) exitWith {};
        _owned pushBack _hackId;
        _buyer setVariable ["plb_cdMods", _owned, true];
        [format ["UPDATE players SET cyberdeck_modules='%1' WHERE playerid='%2'", str _owned, getPlayerUID _buyer]] spawn DB_fnc_asyncQuery;
        [[format ["<t color='#c9e21a'>CHIP INSTALLED</t> -- %1 is now on your deck.", _names getOrDefault [_hackId, "The chip"]], "cyberjackpot"], "life_fnc_handleMessage", _buyer, false, false] spawn life_fnc_MP;
        ["-CYBERDECK-", _buyer, name _buyer, format ["installed drop-only hack chip %1", _hackId]] call TON_fnc_logIt;};

    // CHIP RECYCLER (owner 2026-07-23): the client already pulled 3 hack chips; roll + grant ONE random Tier-3
    // chip back (server-authoritative so a modified client can't mint chips). The dupe sink that biases the
    // economy toward the loot-only middle tier. Grants an ITEM (still has to be USE-installed).
    case "recycleChips": {params ["", ["_buyer", objNull]];
        if (isNull _buyer) exitWith {};
        private _t3 = ["stickychip","jamchip","wiretapchip","crybabychip","synapsechip","leechchip","shortchip","eyespychip","valetchip"];
        private _pick = selectRandom _t3;
        [[true, _pick, 1], "life_fnc_handleInv", _buyer, false, false] spawn life_fnc_MP;
        private _dn = createHashMapFromArray [["stickychip","Sticky Fingers"],["jamchip","Jam.exe"],["wiretapchip","Wiretap"],["crybabychip","Crybaby"],["synapsechip","Synapse Drag"],["leechchip","Leech"],["shortchip","Short Circuit"],["eyespychip","Eye Spy"],["valetchip","Valet Protocol"]];
        [[format ["<t color='#c9e21a'>CHIP RECYCLER</t> -- three chips fused into a <t color='#c9e21a'>%1 Chip</t> (Tier 3). USE it to install.", _dn getOrDefault [_pick, _pick]], "cyberjackpot"], "life_fnc_handleMessage", _buyer, false, false] spawn life_fnc_MP;
        ["-CYBERDECK-", _buyer, name _buyer, format ["recycled 3 chips -> %1", _pick]] call TON_fnc_logIt;};

    // COP FACTORY RESET: wipes the ILLEGAL FIRMWARE (id 0) only -- purchased modules (1-4) survive, as the owner spec'd.
    case "factoryReset": {params ["", ["_target", objNull], ["_cop", objNull]];
        if (isNull _target || {isNull _cop}) exitWith {};
        if !((side _cop) isEqualTo west) exitWith {};
        if ((_cop distance _target) > 10) exitWith {};
        private _owned = _target getVariable ["plb_cdMods", []];
        if !(0 in _owned) exitWith {
            [["That phone is running clean stock firmware.", "basic"], "life_fnc_handleMessage", _cop, false, false] spawn life_fnc_MP;};
        _owned = _owned - [0];
        _target setVariable ["plb_cdMods", _owned, true];
        [format ["UPDATE players SET cyberdeck_modules='%1' WHERE playerid='%2'", str _owned, getPlayerUID _target]] spawn DB_fnc_asyncQuery;
        [["<t color='#ff5a3c'>FACTORY RESET</t> -- an officer wiped the illegal firmware. ICEBREAKER OS is gone; your installed modules survived. Re-flash at an electronics shop.", "cyberjackpot"], "life_fnc_handleMessage", _target, false, false] spawn life_fnc_MP;
        [["Cyberdeck factory reset -- illegal firmware wiped. Their hardware modules remain installed.", "copalert"], "life_fnc_handleMessage", _cop, false, false] spawn life_fnc_MP;
        ["-CYBERDECK-", _cop, name _cop, format ["FACTORY RESET on %1 -- firmware wiped, %2 module(s) kept", name _target, count _owned]] call TON_fnc_logIt;
    };};
