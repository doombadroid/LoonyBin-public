if !(isNull objectParent player) exitWith {};
if (isNil "life_action_gathering") then {life_action_gathering = false;};
if (life_action_gathering) exitWith {};
private _resourceZones = ["apple_1", "apple_2", "apple_4", "apple_5", "peaches_2", "peaches_3", "peaches_4", "weed_1", "illegal_marker_1_0", "illegal_marker_2_0", "illegal_marker_3_0", "illegal_marker_8_0", "rock_1", "rock_2", "rock_3", "oil_1", "oil_2", "oil_3", "mine_1", "mine_2", "mine_3", "mine_4", "mine_5", "mine_6", "salt_1", "prison_metal_1", "prison_metal_2", "prison_metal_3", "oysters_1", "oysters_2", "oysters_3", "oysters_4"];
private _nearbyZones = _resourceZones select {player distance2D(getMarkerPos _x) <= 150};
private _zone = _nearbyZones param[(_nearbyZones apply {player distance2D(getMarkerPos _x)}) findIf {
    _x isEqualTo(selectMin(_nearbyZones apply {player distance2D(getMarkerPos _x)}))}, ""];
if (_zone isEqualTo "") exitWith {};
if (((life_is_arrested param [0,0]) isEqualTo 0) && (_zone find "prison_metal" != -1)) exitWith {}; (switch (true) do {
    case (_zone isEqualTo "illegal_marker_1_0"): {["heroinu", 150];};
    case (_zone isEqualTo "illegal_marker_2_0"): {["cocaine", 150];};
    case (_zone isEqualTo "illegal_marker_3_0"): {["ephedrau", 150];};
    case (_zone isEqualTo "illegal_marker_8_0"): {["henbane", 150];};
    case (_zone isEqualTo "weed_1"): {["cannabis", 150];};
    case (_zone find "oysters_" != -1): {["oysteru", 100];};
    case (_zone find "mine" != -1): {[["diamondf", "diamond", "ironore", "copperore", "sand"], 70];};
    case (_zone find "rock" != -1): {["phos", 150];};
    case (_zone find "oil" != -1 && life_inv_pickaxe >= 1 && !((player nearEntities["Car", 15] select {
        typeOf _x in ["B_Truck_01_fuel_F", "C_Truck_02_fuel_F", "C_Van_01_fuel_F"]}) isEqualTo[])): {["oilu", 150];};
    case (_zone find "oil" != -1): {["hydro", 150];};
    case (_zone find "salt" != -1): {["salt", 150];};
    case (_zone find "apple" != -1): {["apple", 50];};
    case (_zone find "peaches" != -1): {["peach", 50];};
    case (_zone find "prison_metal" != -1): {["plateMetal", 2.5];};
    default {""};}) params["_item", "_distance"];
if (player distance2D(getMarkerPos _zone) > _distance) exitWith {};
if ("mine" in _zone) exitWith {[_zone, _distance] call life_fnc_mine;};
titleText["Gathering...", "PLAIN"];
life_action_gathering = true;
life_action_in_use = true;
private _startPos = getPos player;
private _nBuilding = nearestBuilding player;
private _rodoDrugs = ["cocaine", "heroinu"];
private _gangDrugs = ["cocaine", "heroinu", "cannabis"];
private _giveExtraGangTalent8 = (_item in _gangDrugs && 8 in life_gang_talents);
private _giveExtraGangTalent9 = (_item in ["ephedrau", "henbane"] && 9 in life_gang_talents);
private _totalGathered = 0;
private _exit = false;
private _delay = 4;
if (_item isEqualTo "cannabis" && {19 in life_infamy_talents && license_civ_rebel}) then {_delay = _delay - 0.4;};
if (_item isEqualTo "heroinu" && {20 in life_infamy_talents && license_civ_rebel}) then {_delay = _delay - 0.4;};
if (_item isEqualTo "cocaine" && {21 in life_infamy_talents && license_civ_rebel}) then {_delay = _delay - 0.4;};
if (_item in ["ephedrau", "henbane"] && {22 in life_infamy_talents && license_civ_rebel}) then {_delay = _delay - 0.04;};
for "_i"
from 0 to 1 step 0 do {
    if (_exit || (player distance2D _startPos) > 2 || (player distance2D(getMarkerPos _zone) > _distance) || !(isNull objectParent player)) exitWith {};
    if (player distance2D _nBuilding <= 10 && !(_item isEqualTo "plateMetal")) exitWith {
        ["You can't gather items so close to a building.", "basic"] spawn life_fnc_handleMessage;};
    if !(life_action_in_use) exitWith {};
    uiSleep _delay;
    private _count =
    switch (true) do {
        case (_item in _rodoDrugs && (life_gang_data param[0, -1337] isEqualTo(rodo_flag getVariable["plb_turf_data", []] select 0))): {
                selectRandom[1, 2]};
        default {1};}; private _amount =
    if (random 4 < 1 && (_giveExtraGangTalent8 || _giveExtraGangTalent9)) then {_count + 1} else {_count};
    // BUMPER CROP (222): +1 unit on every field harvest.
    if (222 in life_side_talents) then { _amount = _amount + 1; };
    switch (true) do {case ((_item isEqualTo "oysteru") && (random 2000 < 1) && ((life_maxWeight - life_carryWeight) > 3)): {
                [true, "treasuremap", 1] call life_fnc_handleInv;
                ["You have just found a rare treasure map in the oyster field!", "basic"] spawn life_fnc_handleMessage;};
        case ((_item isEqualTo "oysteru") && (random 15 < 1) && ((life_maxWeight - life_carryWeight) > 3)): {
                [true, "pearl", 1] call life_fnc_handleInv;
                ["You have just found a pearl in the oyster field!", "basic"] spawn life_fnc_handleMessage;};
    }; if ([true, _item, _amount] call life_fnc_handleInv) then {
        titleText[format["Gathered %1 %2. %3/%4", _amount, ["getName", _item] call life_fnc_virtItemCfg, life_carryWeight, life_maxWeight], "PLAIN"];
        life_side_exp = life_side_exp + 1;
        _totalGathered = _totalGathered + _amount;
        [_item, _amount] call life_fnc_statArrUpdate;
        ["collect", _item, _amount] call life_fnc_handleQuest;   // owner 2026-07-11: generic gather event (Parole Papers + future collect quests)
    } else {_exit = true;};}; if (_exit) then {
    titleText[format["Gathering done. You can't hold more %1.", ["getName", _item] call life_fnc_virtItemCfg], "PLAIN", 0.3];
    playSound "ziptie";
    playSound "ziptie";
    playSound "ziptie";} else {titleText["Gathering cancelled.", "PLAIN"];};
life_action_gathering = false;
life_action_in_use = false; [
    ["-GATHER-", player, profileName, format["gathered %1 %2 at position %3.", _totalGathered, ["getName", _item] call life_fnc_virtItemCfg, getPosATL player]], "TON_fnc_logIt", 2] spawn life_fnc_MP;