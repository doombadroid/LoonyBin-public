/*
    life_fnc_buyTalentPoint  (LooneyBin, owner 2026-07-16) -- BUY an extra talent point past the free cap.
    Price ladder: 1st = $1.0m, each additional +$500k (1.5m, 2.0m, ...). Capped once every talent in your
    side's tree is learnable (no point hoarding useless points). Bank-money purchase, deducted client-side
    (the learnTalent/respec precedent); the server records the count (talent_points table) and pushes the
    authoritative total back, which re-runs calTalents.
*/
if (!hasInterface) exitWith {};
private _bought = missionNamespace getVariable ["life_boughtTalents", 0];
private _price = 1000000 + (500000 * _bought);

// how big is my side's tree? once currentTalents covers it, more points are useless -- block the sale
// (getTalents self-filters by playerSide)
private _treeCount = count (["getTalents"] call life_fnc_talentCfg);
if (_treeCount > 0 && {life_currentTalents >= _treeCount}) exitWith {
    ["You already have enough points to learn every talent in your tree.", "basic"] spawn life_fnc_handleMessage;};

private _action = [format ["Buy 1 additional talent point for $%1? (Each one you buy raises the next one's price by $500,000.)", [_price] call life_fnc_numberText], "Buy Talent Point", "Buy", "Cancel"] call BIS_fnc_guiMessage;
if (!_action) exitWith {};
if (life_atmcash < _price) exitWith {
    [format ["You need $%1 in your BANK to buy this talent point.", [_price] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
};
life_atmcash = life_atmcash - _price;
life_atmcashCacheB = ((life_atmcash / 4) + 11);
life_boughtTalents = _bought + 1;
[] call life_fnc_calTalents;
[["buy"], "TON_fnc_talentPointsSRV", 2] spawn life_fnc_MP;
[format ["Talent point purchased for $%1. You now have %2 bought point(s). Spend it in the Talents app.", [_price] call life_fnc_numberText, life_boughtTalents], "basic"] spawn life_fnc_handleMessage;
[["-TALENTS-", player, (profileName), format ["bought talent point #%1 for $%2", life_boughtTalents, _price]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
// refresh the open talent menu header if it's up
if (!isNull (findDisplay 123000)) then { ["standard"] spawn life_fnc_talentMenu; };
