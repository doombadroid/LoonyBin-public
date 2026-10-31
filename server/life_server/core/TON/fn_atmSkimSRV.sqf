/*
    TON_fnc_atmSkimSRV  (LooneyBin, owner 2026-07-16) -- ATM SKIMMER backend, POSITION-KEYED.
    A $50k rebel item ("atmskimmer") planted on a PHYSICAL ATM machine siphons 10% of every deposit/withdraw at
    that ATM to the planter. Persists across restart. A second skimmer on a rigged ATM takes it over (REPLACE).
    Cops scroll the ATM -> "Remove ATM Skimmer" for a $200k bounty. NPC bankers = no ATM = never skimmed.

    Altis ATMs are TERRAIN objects: an object ref does NOT survive remoteExec (arrives <NULL-object> on the
    server), so the whole system is keyed by the ATM's rounded world position. State = PLB_atmSkim HashMap
    (key -> ownerUID), server-authoritative, publicVariable'd to clients (they read it for the skim + the cop's
    remove action). DB atm_skimmers persists it.

    Modes (client -> server, remoteExec allowedTargets=2):
      ["apply",  pos, 0,   player]   plant/steal (client already consumed the item)
      ["remove", pos, 0,   player]   cop removes it -> $200k reward
      ["credit", pos, amt]           a victim transacted -> pay the ATM's owner (owner read SERVER-side)
      ["sync"]                       (re)broadcast PLB_atmSkim (called by clients at join for JIP)
      ["load"]                       boot: load PLB_atmSkim from the DB + broadcast
*/
if (!isServer) exitWith {};
params [["_mode", "", [""]], ["_pos", [0,0,0], [[]]], ["_amount", 0, [0]], ["_caller", objNull, [objNull]]];
if (isNil "PLB_atmSkim") then { PLB_atmSkim = createHashMap; };
private _san = { (format ["%1", _this]) splitString "\'""" joinString "" };   // strip \ ' " (SQL-safety, matches gangBank)
private _key = format ["%1_%2", round (_pos param [0, 0]), round (_pos param [1, 0])];

// credit a UID's bank: online -> live HUD/session bump + durable DB write; offline -> DB only (comp/mailbox lesson)
private _fnPay = {params ["_uid", "_amt"];
    if (_uid isEqualTo "" || {_amt <= 0}) exitWith {};
    private _su = _uid call _san;
    [format ["UPDATE players SET bankacc = bankacc + %1 WHERE playerid='%2'", _amt, _su]] spawn DB_fnc_asyncQuery;
    private _p = (allPlayers select { getPlayerUID _x isEqualTo _uid }) param [0, objNull];
    if (!isNull _p) then { [["atm", "add", _amt], "life_fnc_uC", _p, false] spawn life_fnc_MP; };};

switch (toLower _mode) do {

    case "apply": {private _unit = _caller;
        if (isNull _unit) then { _unit = (allPlayers select { owner _x isEqualTo remoteExecutedOwner }) param [0, objNull]; };
        if (isNull _unit) exitWith {};
        private _uid = getPlayerUID _unit;
        if (_uid isEqualTo "") exitWith {};
        private _prev = PLB_atmSkim getOrDefault [_key, ""];
        // REPLACE: a new skimmer on top cancels the old one out and takes over.
        PLB_atmSkim set [_key, _uid];
        publicVariable "PLB_atmSkim";
        // BANK ICE (owner 2026-07-21): stamp when this skimmer went live, so a skimmer left running too long
        // trips an escalating, PRECISE trace on the planter (see the "credit" case).
        private _ageMap = missionNamespace getVariable ["PLB_atmSkimAge", createHashMap];
        _ageMap set [_key, serverTime];
        missionNamespace setVariable ["PLB_atmSkimAge", _ageMap];
        [format ["REPLACE INTO atm_skimmers (atm_key, owner_uid) VALUES ('%1','%2')", _key call _san, _uid call _san]] spawn DB_fnc_asyncQuery;
        if (_prev isNotEqualTo "" && {_prev isNotEqualTo _uid}) then {
            private _pp = (allPlayers select { getPlayerUID _x isEqualTo _prev }) param [0, objNull];
            if (!isNull _pp) then { [["Someone found your ATM skimmer and replaced it with their own. You're cut off.", "basic"], "life_fnc_handleMessage", _pp, false, false] spawn life_fnc_MP; };
        };
        [["<t color='#e88b2d'>SKIMMER PLANTED</t> -- you now siphon 10%% of every transaction at this ATM. It survives restarts. Watch for cops.", "info"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
        ["-ATMSKIMMER-", _unit, name _unit, format ["planted skimmer at %1 (prev owner %2)", _key, _prev]] call TON_fnc_logIt;};

    case "remove": {private _unit = _caller;
        if (isNull _unit) then { _unit = (allPlayers select { owner _x isEqualTo remoteExecutedOwner }) param [0, objNull]; };
        if (isNull _unit) exitWith {};
        if (side _unit isNotEqualTo west) exitWith {};                       // cops only
        private _owner = PLB_atmSkim getOrDefault [_key, ""];
        if (_owner isEqualTo "") exitWith {};                                // nothing to remove (anti double-reward)
        PLB_atmSkim deleteAt _key;
        publicVariable "PLB_atmSkim";
        [format ["DELETE FROM atm_skimmers WHERE atm_key='%1'", _key call _san]] spawn DB_fnc_asyncQuery;
        [getPlayerUID _unit, 200000] call _fnPay;                            // cop bounty (owner just loses future skim)
        [["<t color='#3aa0ff'>SKIMMER REMOVED</t> -- you pulled a skimming device off this ATM. $200,000 reward wired to your account.", "info"], "life_fnc_handleMessage", _unit, false, false] spawn life_fnc_MP;
        ["-ATMSKIMMER-", _unit, name _unit, format ["cop removed skimmer at %1 (was %2) for $200000", _key, _owner]] call TON_fnc_logIt;};

    case "credit": {
        private _owner = PLB_atmSkim getOrDefault [_key, ""];               // owner derived SERVER-side (client can't redirect)
        if (_owner isEqualTo "") exitWith {};
        private _amt = round _amount;
        if (_amt <= 0) exitWith {};
        if (_amt > 999999) then { _amt = 999999; };                         // cap (matches the 9.99M txn ceiling)
        [_owner, _amt] call _fnPay;
        // BANK ICE (owner 2026-07-21, Skim Daemon counter): a skimmer left running past its payout window
        // (>20 min) starts throwing PRECISE traces -- the bank's ICE has locked onto it. Escalates the silent
        // 30% area-ping into a located fix on the planter, so greed past the safe window gets you caught.
        private _ageMap = missionNamespace getVariable ["PLB_atmSkimAge", createHashMap];
        private _placed = _ageMap getOrDefault [_key, serverTime];
        if ((serverTime - _placed) > 1200) then {private _icekey = "plb_skimIceCd_" + _key;
            if (serverTime >= (missionNamespace getVariable [_icekey, 0])) then {missionNamespace setVariable [_icekey, serverTime + 90];
                private _plr = allPlayers param [allPlayers findIf { getPlayerUID _x isEqualTo _owner }, objNull];
                private _fix = if (!isNull _plr) then { getPosATL _plr } else { _pos };   // planter if online, else the ATM
                { [[_fix, "SKIMMER TRACE", "ColorRed", true], "life_fnc_talMarker", _x, false] spawn life_fnc_MP; } forEach (allPlayers select { (side _x) isEqualTo west });
                [["<t size='1.15' color='#4aa3ff'>BANK ICE</t> -- a long-running skimmer has been traced to a location.", "copalert"], "life_fnc_handleMessage", west, false, false] spawn life_fnc_MP;
                if (!isNull _plr) then { [["<t color='#ff3b1e'>ICE ON YOU</t> -- your skimmer's been up too long. The bank just traced it to your position.", "warning"], "life_fnc_handleMessage", _plr, false, false] spawn life_fnc_MP; };
                ["-ATMSKIM-", objNull, "SERVER", format ["BANK ICE precise trace on planter %1 at ATM %2", _owner, _key]] call TON_fnc_logIt;
            };};
        // SILENT ALARM (owner 2026-07-21, Skim Daemon spec): 30% per skimmed transaction the machine
        // phones home. The VICTIM is told nothing -- that is what makes it silent; the APD gets a
        // located ping and the planter is warned their box is hot. Throttled per ATM so a busy machine
        // can't spam the net. Rolled here because only the server knows the true skim happened.
        if (random 1 < 0.30) then {private _akey = "plb_skimAlarmCd_" + _key;
            if (serverTime >= (missionNamespace getVariable [_akey, 0])) then {missionNamespace setVariable [_akey, serverTime + 120];
                private _loc = (nearestLocations [_pos, ["NameCityCapital", "NameCity", "NameVillage", "NameLocal"], 3000]) param [0, locationNull];
                private _town = if (isNull _loc) then { "an outlying area" } else { text _loc };
                [[format ["Bank fraud alert -- a tampered ATM reported a skimmed transaction in %1.", _town], "copalert"], "life_fnc_handleMessage", west, false, false] spawn life_fnc_MP;
                private _plr = allPlayers param [allPlayers findIf { getPlayerUID _x isEqualTo _owner }, objNull];
                if (!isNull _plr) then {
                    [["<t color='#ff3b1e'>SKIMMER EXPOSED</t> -- that machine tripped a fraud alert. The APD knows the area.", "warning"], "life_fnc_handleMessage", _plr, false, false] spawn life_fnc_MP;
                };
                ["-ATMSKIM-", objNull, "SERVER", format ["silent alarm tripped at ATM %1 (%2), planter %3", _key, _town, _owner]] call TON_fnc_logIt;
            };};};

    case "sync": { publicVariable "PLB_atmSkim"; };                          // JIP: a joiner asks for the current map

    case "load": {[] spawn {
            // QUOTE both cols: DB_fnc_asyncQuery mode 2 call-compiles the result, so a bare atm_key like
            // 14045_18756 parses as 14045 then _18756 (undefined) -> "Missing ]" -> the load aborts + skimmers
            // never restore across restart. (Same QUOTE-on-read rule as economySRV/foreskins/mres.)
            private _rows = ["SELECT QUOTE(atm_key), QUOTE(owner_uid) FROM atm_skimmers", 2, true] call DB_fnc_asyncQuery;
            if (isNil "_rows" || {!(_rows isEqualType [])}) exitWith {};
            private _n = 0; {_x params [["_k", ""], ["_u", ""]];
                if (_k isNotEqualTo "" && {_u isNotEqualTo ""}) then { PLB_atmSkim set [_k, _u]; _n = _n + 1; };} forEach _rows;
            publicVariable "PLB_atmSkim";
            diag_log format ["[LooneyBin][atmSkimmer] loaded %1 skimmer(s) from DB", _n];};};};
