 
private["_query","_result","_ret"];

// Economy 2026-06-16 (neglect-premium): rows are [className, prem, sales] -- quantity column now holds the
// PREMIUM (>=1, float) and the sales column the cumulative sale count toward the next crash. PLB_fnc_marketTick
// seeds any missing good, so an empty itemstock just starts everything at the max-price floor (prem 1).
_query = "SELECT `className`,`quantity`,`sales` FROM `itemstock`";

life_price_index = [_query,2,true] call DB_fnc_asyncQuery;
if (!(life_price_index isEqualType [])) then { life_price_index = []; };
