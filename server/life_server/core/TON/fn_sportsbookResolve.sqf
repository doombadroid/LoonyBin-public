/*
    TON_fnc_sportsbookResolve  (SERVER-ONLY -- NOT in CfgRE, never client-callable). LoonyBets engine.
      ["boot"]                 start the deadline watcher (call once from server init); no standing markets
      ["publish"]              rebuild + publicVariable PLB_sportsbook (markets + live pools)
      ["open", key]            a HEIST STARTED (fedAlert edge-detector / event hooks): open that market
      ["resolve", key, result] settle a market ("yes"/"no"): parimutuel payout of the losing pool (10% rake)
                               to the winning stakes, mark bets done, close the market (it reopens only when
                               that heist next fires). Event hooks resolve outcomes; watcher deadlines -> "no".
    Markets live in PLB_sportsbookMarkets = [[key, question, deadline, state, result], ...]; bets in DB.
    Payout: online winners via life_fnc_casinoReceive (server->client bank credit); offline via a DB bank add.
*/
if (!isServer) exitWith {};
params [["_mode", "", [""]], ["_key", "", [""]], ["_result", "", [""]]];

private _fnPools = {params ["_k"];
    private _r = [format ["SELECT selection, SUM(stake) FROM sportsbook_bets WHERE market_key='%1' AND status='open' GROUP BY selection", _k], 2, true] call DB_fnc_asyncQuery;
    private _yes = 0; private _no = 0;
    if (!isNil "_r" && {_r isEqualType []}) then {
        { _x params ["_s", "_sum"]; if ((format ["%1", _s]) isEqualTo "yes") then { _yes = parseNumber (format ["%1", _sum]); } else { _no = parseNumber (format ["%1", _sum]); }; } forEach _r;
    };
    [_yes, _no]};
private _fnPublish = {if (isNil "PLB_sportsbookMarkets") exitWith {};
    PLB_sportsbook = PLB_sportsbookMarkets apply {_x params ["_k", "_q", "_dl", "_st", "_rs"];
        ([_k] call _fnPools) params ["_y", "_n"];
        [_k, _q, _y, _n, _dl, _st, _rs]};
    publicVariable "PLB_sportsbook";};

switch (toLower _mode) do {case "boot": {if (!isNil "PLB_sportsbookBooted") exitWith {};
        PLB_sportsbookBooted = true;
        PLB_sportsbookMarkets = [];   // heist markets open on the heist, not on a clock
        call _fnPublish;
        [] spawn {   // deadline watcher: a heist that never resolved by its window settles NO
            while {true} do {uiSleep 30;
                if (!isNil "PLB_sportsbookMarkets") then {
                    { _x params ["_k", "", "_dl2", "_st2"]; if (_st2 isEqualTo "open" && {serverTime > _dl2}) then { ["resolve", _k, "no"] call TON_fnc_sportsbookResolve; }; } forEach (+PLB_sportsbookMarkets);
                };};};};

    // a heist started -> open its market (called by the fedAlert edge-detector; no-op if already open)
    case "open": {if (isNil "PLB_sportsbookMarkets") then { PLB_sportsbookMarkets = []; };
        _key = toLower _key;
        private _reg = [
            // key        question                                                    window(s)
            ["bank",     "Bank of Altis: do the robbers crack the vault?",            1800],
            ["jewelry",  "Jewelry Emporium: do they weld the safe open?",             1500],
            ["fed",      "Federal Reserve: do the robbers get away with the gold?",   2100],
            ["evidence", "Evidence Lockup: does the dome get blown open?",            2100],
            ["shipping", "Altis Shipping convoy: does the cargo get fenced?",         3000],
            ["loonybin", "Loony Bin breach: do the patients crack the Tomb?",         2700]];
        private _def = (_reg select { (_x select 0) isEqualTo _key }) param [0, []];
        if (_def isEqualTo []) exitWith {};
        if ((PLB_sportsbookMarkets findIf { (_x select 0) isEqualTo _key }) >= 0) exitWith {};   // already open
        PLB_sportsbookMarkets pushBack [_key, _def select 1, serverTime + (_def select 2), "open", ""];
        call _fnPublish;
        [[0, format ["LoonyBets: THE BOOK IS OPEN -- %1 Get your bets in at loonybets.com.", _def select 1]], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
        [[format ["<t color='#ffcd3c'>LOONYBETS -- THE BOOK IS OPEN</t><br/>%1<br/>Bet now: phone &gt; Browser &gt; loonybets.com", _def select 1], "info"], "life_fnc_handleMessage", -2, false, false] spawn life_fnc_MP;   // toast for everyone
        ["-SPORTSBOOK-", objNull, "SERVER", format ["market OPEN: %1", _key]] call TON_fnc_logIt;
        if (_key isEqualTo "loonybin") then {
            // tomb-cracked detector: the church doors unlock (public vars) when the keycode is entered.
            [] spawn {private _end = time + 2700;
                private _hit = false;
                waitUntil {uiSleep 10;
                    private _gone = ((missionNamespace getVariable ["PLB_sportsbookMarkets", []]) findIf { (_x select 0) isEqualTo "loonybin" }) < 0;
                    (missionNamespace getVariable ["PLB_mentalDoorChurch", []]) params [["_b", objNull], ["_idx", []]];
                    _hit = !isNull _b && {(_idx findIf { (_b getVariable [format ["bis_disabled_Door_%1", _x], 1]) isEqualTo 0 }) >= 0};
                    _hit || _gone || {time > _end}};
                if (_hit) then { ["resolve", "loonybin", "yes"] call TON_fnc_sportsbookResolve; };};};};

    case "publish": { call _fnPublish; };

    case "resolve": {if (isNil "PLB_sportsbookMarkets") exitWith {};
        _key = toLower _key; _result = toLower _result;
        private _idx = PLB_sportsbookMarkets findIf { (_x select 0) isEqualTo _key };
        if (_idx < 0) exitWith {};
        private _m = PLB_sportsbookMarkets select _idx;
        if ((_m select 3) isNotEqualTo "open") exitWith {};   // already settled this window
        ([_key] call _fnPools) params ["_yes", "_no"];
        private _total = _yes + _no;
        private _winPool = if (_result isEqualTo "yes") then { _yes } else { _no };
        private _distributable = (_total - _winPool) - round ((_total - _winPool) * 0.1);   // losing pool minus 10% rake

        private _bets = [format ["SELECT id, uid, selection, stake FROM sportsbook_bets WHERE market_key='%1' AND status='open'", _key], 2, true] call DB_fnc_asyncQuery;
        if (!isNil "_bets" && {_bets isEqualType []}) then {{_x params ["", "_buid", "_bsel", "_bstake"];
                _buid = format ["%1", _buid]; _bsel = format ["%1", _bsel]; _bstake = parseNumber (format ["%1", _bstake]);
                private _bu = (allPlayers select { getPlayerUID _x isEqualTo _buid }) param [0, objNull];
                if (_bsel isEqualTo _result && {_winPool > 0}) then {
                    private _pay = _bstake + round ((_bstake / _winPool) * _distributable);
                    if (!isNull _bu) then {[[_pay], "life_fnc_casinoReceive", _bu, false] spawn life_fnc_MP;
                        // owner 2026-07-15: settle toasts -- every online bettor hears how it went
                        [[format ["<t color='#6ee787'>LOONYBETS -- YOU WON</t><br/>%1<br/>Settled %2. Your $%3 stake pays $%4.", _m select 1, toUpper _result, _bstake, _pay], "info"], "life_fnc_handleMessage", _bu, false, false] spawn life_fnc_MP;
                    } else {[format ["UPDATE players SET bankacc = bankacc + %1 WHERE playerid='%2'", _pay, _buid]] call DB_fnc_asyncQuery;
                    };} else {if (!isNull _bu) then {
                        [[format ["<t color='#ffb454'>LOONYBETS -- YOU LOST</t><br/>%1<br/>Settled %2. Your $%3 on %4 belongs to the winners now.", _m select 1, toUpper _result, _bstake, toUpper _bsel], "info"], "life_fnc_handleMessage", _bu, false, false] spawn life_fnc_MP;
                    };};} forEach _bets;};
        [format ["UPDATE sportsbook_bets SET status='done' WHERE market_key='%1' AND status='open'", _key]] call DB_fnc_asyncQuery;
        ["-SPORTSBOOK-", objNull, "SERVER", format ["%1 settled %2 (pool $%3, %4 winners share $%5)", _key, toUpper _result, _total, _result, _distributable]] call TON_fnc_logIt;

        // close the market -- it reopens only when that heist next starts
        PLB_sportsbookMarkets deleteAt _idx;
        call _fnPublish;

        // Ben Bones settles the book on Looner + DataBattle
        ["BOOK", format ["THE BOOK SETTLES: %1 -> %2 (pool $%3)", (_m select 1), toUpper _result, _total], format ["the book on '%1' closed %2. the house ALWAYS knows. i warned you, degens.", (_m select 1), toUpper _result]] call TON_fnc_newsPush;
    };};
