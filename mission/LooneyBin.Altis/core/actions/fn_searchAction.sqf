params[["_unit", objNull, [objNull]]];
if (isNull _unit || !(_unit isKindOf "CAManBase")) exitWith {};
["Searching...", "basic"] spawn life_fnc_handleMessage;
uiSleep 2;
if (player distance _unit > 5 || !alive player || !alive _unit) exitWith {
    ["Cannot search that person.", "basic"] spawn life_fnc_handleMessage;}; [
    ["-SEARCH-", player, (profileName), format["searched %1 (%2) at POS: %3", name _unit, getPlayerUID _unit, getPosATL player]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
[[player], "life_fnc_searchClient", _unit, false, false] spawn life_fnc_MP;
if ([
    ["weed_1", "illegal_marker_1_0", "illegal_marker_2_0", "illegal_marker_3_0", "illegal_marker_5_0"], 300, player] call life_fnc_inZone) then {
    ["action", "searchdrugfield", 1] call life_fnc_handleQuest;};