/*
    TON_fnc_sportsbookSRV  (client -> server, CfgRE allowedTargets=2). LoonyBets: place a bet.
      ["bet", marketKey, "yes"|"no", stake]
    Identity from remoteExecutedOwner (never trusted). The client has already debited its bank + client-side
    validated the market is open (from the PLB_sportsbook public var), same accept-risk pattern as the casino.
    Payout happens later in TON_fnc_sportsbookResolve. Bet rows live in sportsbook_bets.
*/
if (!isServer) exitWith {};
params [["_mode", "", [""]], ["_key", "", [""]], ["_sel", "", [""]], ["_stake", 0, [0]]];
if ((toLower _mode) isNotEqualTo "bet") exitWith {};
private _unit = (allPlayers select { owner _x isEqualTo remoteExecutedOwner }) param [0, objNull];
if (isNull _unit) exitWith {};
private _uid = getPlayerUID _unit;
if (_uid isEqualTo "") exitWith {};
_key = toLower _key; _sel = toLower _sel; _stake = round _stake;

// owner 2026-07-15: the client debits its bank BEFORE this call (casino accept-risk pattern), so every
// reject below must HAND THE STAKE BACK or the money just evaporates.
private _fnRefund = { if (_stake > 0) then { [[_stake], "life_fnc_casinoReceive", _unit, false] spawn life_fnc_MP; }; };
if !(_sel in ["yes", "no"]) exitWith { call _fnRefund; [["LoonyBets: pick YES or NO."], "life_fnc_handleMessage", _unit] spawn life_fnc_MP; };
if (_stake < 5000 || {_stake > 50000}) exitWith { call _fnRefund; [["LoonyBets: stake must be $5,000 - $50,000."], "life_fnc_handleMessage", _unit] spawn life_fnc_MP; };
if (isNil "PLB_sportsbookMarkets") exitWith { call _fnRefund; };
private _m = (PLB_sportsbookMarkets select { (_x select 0) isEqualTo _key }) param [0, []];
if (_m isEqualTo [] || {(_m select 3) isNotEqualTo "open"} || {serverTime > (_m select 2)}) exitWith {call _fnRefund;
    [["LoonyBets: that market is closed -- refresh loonybets.com."], "life_fnc_handleMessage", _unit] spawn life_fnc_MP;};
// ONE bet per player per market (owner 2026-07-15: double-tap placed two bets)
private _mine = [format ["SELECT COUNT(*) FROM sportsbook_bets WHERE uid='%1' AND market_key='%2' AND status='open'", _uid, _key], 2, true] call DB_fnc_asyncQuery;
if (parseNumber (format ["%1", (_mine param [0, [0]]) param [0, 0]]) > 0) exitWith {call _fnRefund;
    [["LoonyBets: you already have a bet on this market."], "life_fnc_handleMessage", _unit] spawn life_fnc_MP;};

private _nm = ((name _unit) splitString "\'""`") joinString "";
if ((count _nm) > 28) then { _nm = _nm select [0, 28]; };
[format ["INSERT INTO sportsbook_bets (uid, name, market_key, selection, stake, status) VALUES ('%1','%2','%3','%4',%5,'open')", _uid, _nm, _key, _sel, _stake]] call DB_fnc_asyncQuery;
["-SPORTSBET-", _unit, _nm, format ["$%1 on %2 = %3", _stake, _key, _sel]] call TON_fnc_logIt;
["publish"] call TON_fnc_sportsbookResolve;   // republish live pools
[[format ["LoonyBets: $%1 on %2 (%3) is IN. Good luck, degen.", _stake, _key, toUpper _sel]], "life_fnc_handleMessage", _unit] spawn life_fnc_MP;
