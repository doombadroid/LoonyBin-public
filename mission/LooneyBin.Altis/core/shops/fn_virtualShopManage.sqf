#include "..\..\macro.h"
if (scriptAvailable(0.275)) exitWith {};
params[["_shopType", ""], ["_control", controlNull], ["_manageType", ""]];
if (isNull _control) exitWith {};
if (_shopType isEqualTo "") exitWith {};
if !(ctrlEnabled _control) exitWith {};
private _plb_display = findDisplay 39500;
if (isNull _plb_display) exitWith {};
private _topTitle = _plb_display displayCtrl 39501;
private _subTitle = _plb_display displayCtrl 39502;
private _mainListGroup = _plb_display displayCtrl 39503;
private _mainItemList = _mainListGroup controlsGroupCtrl 1000;
private _mainItemListEdit = _mainListGroup controlsGroupCtrl 1004;
private _mainItemListBackground = _mainListGroup controlsGroupCtrl 1003;
private _mainItemListBuyButton = _mainListGroup controlsGroupCtrl 1005;
private _mainItemListSellButton = _mainListGroup controlsGroupCtrl 1006;
private _mainItemListSelect = lbCurSel _mainItemList;
if ((_control isEqualTo _mainItemListBuyButton) && (_mainItemListSelect isEqualTo - 1)) exitWith {
    ["You need to select an item to buy", "basic"] spawn life_fnc_handleMessage;};
if ((_control isEqualTo _mainItemListSellButton) && (_mainItemListSelect isEqualTo - 1)) exitWith {
    ["You need to select an item to sell", "basic"] spawn life_fnc_handleMessage;};
private _selectedData = [_mainItemList lnbData[_mainItemListSelect, 0], _mainItemList lnbValue[_mainItemListSelect, 1], _mainItemList lnbValue[_mainItemListSelect, 2]];
_selectedData params["_item", "_price"];
private _shopInfo = [_shopType] call life_fnc_virt_shops;
_shopInfo params[["_shopTitle", ""], ["_buyItems", []], ["_sellItems", []]];
switch (_manageType) do {case ("buyItem"): {
            // owner 2026-07-07: the gang-fortress drug dealer is SELL-ONLY. Buying then selling back there was a
            // money pump (the fort's drug SELL bonus made sell > buy -> round-trip profit). Block BUYING at the drug
            // dealer (heroin shop) while inside the fort zone; selling still works so the fort's drug perk stays.
            if ((_shopType isEqualTo "heroin") && {[["gang_fortress_marker"], 400, player] call life_fnc_inZone}) exitWith {
                ["The gang fortress dealer only BUYS drugs -- he won't sell to you.", "basic"] spawn life_fnc_handleMessage;};
            if !(_item in _buyItems) exitWith {["You can't buy this item!", "basic"] spawn life_fnc_handleMessage;};
            private _amount = parseNumber(ctrlText _mainItemListEdit);
            if !([str _amount] call life_fnc_isNumber) exitWith {["Invalid number.", "basic"] spawn life_fnc_handleMessage;};
            if (_amount > 100) exitWith {["You cannot buy more than 100 at a time.", "basic"] spawn life_fnc_handleMessage;};
            if (_amount <= 0) exitWith {["You need to buy at least one", "basic"] spawn life_fnc_handleMessage;};
            
            private _diff = [_item, _amount, life_carryWeight, life_maxWeight] call life_fnc_calWeightDiff;
            if (_diff <= 0) exitWith {["You don't have enough space for that amount!", "basic"] spawn life_fnc_handleMessage;};
            private _amount = _diff;
            private _itemName = ["getName", _item] call life_fnc_virtItemCfg;
            private _exit = false;
            _price = round(_price * _amount);
            if ([true, _item, _amount] call life_fnc_handleInv) then {
                private _pointData = drug_flag getVariable["plb_capData", [0, "Neutral", 0.5]];
                _pointData params["_flagGangID", "_flagGangName", "_progress"];
                private _extra = "";
                private _govTaxedShops = ["market", "gas", "turf", "redburger", "hospital", "oil", "fishmarket", "diamond", "salt", "cop", "commod", "home", "vig", "delivery", "meditemshop", "medicaldispensary"];
                private _cut =
                switch (true) do {case ((_shopType == "rebel") && !(life_armsCartel select 0) && ((call life_adminLevel) <= 2)): {
                            floor(_price * 0.08)};
                    case (_shopType in _govTaxedShops): {floor(_price * (call life_fnc_getGovTax))};
                    default {0};
                }; if ((_shopType isEqualTo "rebel") && !(life_armsCartel select 0) && ((call life_adminLevel) <= 2)) then {
                    private _updateVal = (life_armsCartel select 1);
                    _updateVal = _updateVal + _cut;
                    life_armsCartel set[1, _updateVal];
                    _extra = format[", with $%1 going to the owner of the Arms Dealer", [_cut] call life_fnc_numberText];};
                if ((_shopType in _govTaxedShops) && !(life_govTax param[0, false]) && ((call life_adminLevel) <= 2)) then {
                    private _updateVal = (life_govTax select 1);
                    _updateVal = _updateVal + _cut;
                    life_govTax set[1, _updateVal];
                    _extra = format[", with $%1 going to the Govenor of %2", [_cut] call life_fnc_numberText, worldName];};
                _control ctrlEnable false;
                // NEW DRACHMA: Kabuki Electronics ("tech") takes ND ONLY -- no cash. Price is the cash
                // catalogue value at 6000:1. Server-authoritative debit (this fn is spawned, so the blocking
                // PLB_fnc_ndBuySync is scheduler-legal). Item was granted above; _exit removes it on failure.
                if (_shopType isEqualTo "tech") then {private _ndPrice = [_price] call PLB_fnc_ndFromLegacy;
                    if (!([_ndPrice] call PLB_fnc_ndAfford)) exitWith {
                        [format["Kabuki Electronics only takes New Drachma. You need %1 ND.", [_ndPrice] call PLB_fnc_ndText], "basic"] spawn life_fnc_handleMessage;
                        _exit = true;};
                    if (!([_ndPrice] call PLB_fnc_ndBuySync)) exitWith {
                        ["New Drachma payment failed -- try again.", "basic"] spawn life_fnc_handleMessage;
                        _exit = true;};} else {if (_shopType isNotEqualTo "rebel") then {if !([_price] call life_fnc_debitCard) exitWith {
                            _exit = true;};} else {if (life_cash < _price) exitWith {
                            [format["You do not have enough cash on you to purchase this. Requires $%1.", [_price] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
                            _exit = true;};
                        life_cash = (round(life_cash - _price)) max 0;
                        life_cashCacheB = ((life_cash / 4) + 9);};};
                if (_exit) exitWith {[false, _item, _amount] call life_fnc_handleInv;
                    [_shopType, _mainItemListSelect] call life_fnc_virtualShopUpdate;};
                private _nearMedSupply = nearestObjects[player, ["C_IDAP_supplyCrate_F", "I_UAV_06_medical_F", "C_IDAP_UAV_06_medical_F"], 6];
                if (count _nearMedSupply >= 1) then {
                    if (alive (_nearMedSupply select 0) && {(_nearMedSupply select 0) getVariable["plb_medSupply", false]}) then {
                        private _shopOwner = (_nearMedSupply select 0) getVariable["plb_Owner", objNull];
                        if (!(isNull _shopOwner) && !(_shopOwner isEqualTo player)) then {[
                                [player, _shopOwner, _price], "TON_fnc_medSupplyPay", 2] spawn life_fnc_MP;};};};
                private _rebelOutposts = ["Rebelop_1", "Rebelop_2", "Rebelop_3", "Rebelop_4", "Rebelop_5", "Rebelop_6"];
                if !(({player distance(getMarkerPos _x) <= 200}
                count _rebelOutposts) isEqualTo 0) then {["moneyspentrebel", _price] call life_fnc_statArrUpdate;};
                private _taxName =
                switch (true) do {case ((_shopType isEqualTo "rebel") && !(life_armsCartel select 0)): {"Arms"};
                    case (_shopType in _govTaxedShops): {"Tax"};}; private _index = life_purchasedVItems findIf {_x select 0 == _itemName};
                if (_index isEqualTo - 1) then {life_purchasedVItems pushBack[_itemName, _amount, _cut, _price, _taxName];} else {
                    private _oldValues = life_purchasedVItems select _index;
                    _oldValues params["_itemName", "_xAmount", "_tax", "_prePrice"];
                    life_purchasedVItems set[_index, [_itemName, _xAmount + _amount, _tax + _cut, _prePrice + _price, _taxName]];};
                [_shopType, _mainItemListSelect] call life_fnc_virtualShopUpdate; [
                    ["-ITEMBOUGHT-", player, (profileName), format["purchased %1 %2 for $%3 at POS: %4", [_amount] call life_fnc_numberText, ["getName", _item] call life_fnc_virtItemCfg, [_price] call life_fnc_numberText, getPosATL player]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
                // Dynamic market: a BUY raises demand -> push the demand index negative (buy -, sell +).
                if (!isNil "life_price_index" && {(life_price_index findIf {(_x isEqualType []) && {(_x param [0, ""]) isEqualTo _item}}) > -1}) then {
                    life_stock_update = [_item, -_amount, objNull];
                    publicVariable "life_stock_update";};} else {
                [format["You do not have room in your inventory for %1 %2", _amount, _itemName], "basic"] spawn life_fnc_handleMessage;};
        }; case ("sellItem"): {if !(_item in _sellItems) exitWith {["You can't sell this item!", "basic"] spawn life_fnc_handleMessage;};
                private _amount = parseNumber(ctrlText _mainItemListEdit);
                if !([str _amount] call life_fnc_isNumber) exitWith {["Invalid number.", "basic"] spawn life_fnc_handleMessage;};
                private _price =
                if ((_item in _buyItems) && (_item in _sellItems)) then {
                    private _buyPrice = ["getBasePrice", _item] call life_fnc_virtItemCfg;
                    // marketFactor MUST match the actual buy price (fn_virtualShopPopulate: base*marketFactor*discount).
                    // Without it the cap = base*discount while an OVERSUPPLIED drug BUYS for base*factor*discount (factor<1)
                    // -> buy cheap, sell at the higher cap = free money (the gang drug perk pushes sell up to that cap).
                    _buyPrice = _buyPrice * ([_item] call life_fnc_marketFactor) * ([_shopType, true] call life_fnc_getDiscount);
                    private _sellPrice = ["getLowestPrice", _item] call life_fnc_virtItemCfg;
                    _sellPrice = _sellPrice * ([_shopType, false] call life_fnc_getDiscount);
                    selectMin[_sellPrice, _buyPrice];} else {private _sellPrice = ["getLowestPrice", _item] call life_fnc_virtItemCfg;
                    if (_item == "goldbar" && (life_gang_data select 0) isEqualTo(zaros_flag getVariable["plb_turf_data", []] select 0)) then {
                        _sellPrice = _sellPrice * 1.1} else {_sellPrice};
                    _sellPrice = _sellPrice * ([_shopType, false] call life_fnc_getDiscount);
                    // LooneyBin anti-arbitrage (global): a BUYABLE good (base buy price > 0) can NEVER sell for
                    // more than its buy price. The per-shop `selectMin` guard above only caught items that are
                    // buyable+sellable at the SAME shop, so buying a raw drug cheap at shop A and selling it at
                    // the Drug Dealer -- where sell = maxPrice * marketFactor (>> base) -- was free money. Processed
                    // sell-only goods have base = -1 -> skipped, so they keep their intended max*premium sell.
                    private _basePrice = ["getBasePrice", _item] call life_fnc_virtItemCfg;
                    if (_basePrice > 0) then {
                        // * marketFactor so the cap tracks the ACTUAL buy price (base*marketFactor*discount), not just
                        // base*discount -- otherwise an oversupplied good (factor<1) buys below the cap = arbitrage.
                        _sellPrice = _sellPrice min (_basePrice * ([_item] call life_fnc_marketFactor) * ([_shopType, true] call life_fnc_getDiscount));
                    };
                    _sellPrice;};
                private _inInventory = missionNameSpace getVariable[format["life_inv_%1", _item], 0];
                private _itemName = ["getName", _item] call life_fnc_virtItemCfg;
                if (_amount <= 0) exitWith {["You need to sell at least one", "basic"] spawn life_fnc_handleMessage;};
                if (_amount > _inInventory) exitWith {["You don't have that many items to sell!", "basic"] spawn life_fnc_handleMessage;};
                private _rebelOutposts = ["Rebelop_1", "Rebelop_2", "Rebelop_3", "Rebelop_4", "Rebelop_5", "Rebelop_6"];
                if (_item isEqualTo "goldbar" && (({player distance(getMarkerPos _x) <= 200}
                count _rebelOutposts) isEqualTo 0)) exitWith {["You cannot sell this here!", "basic"] spawn life_fnc_handleMessage};
                private _buffPercent = ["questBuffs", false, _item] call life_fnc_getDiscount;
                private _addBuff =
                if (_buffPercent isEqualTo 0) then {0} else {(_price * _buffPercent)};
                // MERCHANT talents (client-side, same mechanism as the quest buff above; the server shadow-cash
                // cache validates deltas the same way it already does for _addBuff). Fence(230) = all sales +10%;
                // Kingpin(231) = drug shops +25%; Wholesaler(232) = non-drug shops +20%. Additive multipliers.
                private _isDrugShop = _shopType in ["wongs", "heroin"];
                private _sellMult = 1;
                if (230 in life_side_talents) then { _sellMult = _sellMult + 0.10; };
                if (231 in life_side_talents && {_isDrugShop}) then { _sellMult = _sellMult + 0.25; };
                if (232 in life_side_talents && {!_isDrugShop}) then { _sellMult = _sellMult + 0.20; };
                _price = round((_price + _addBuff) * _amount * _sellMult);
                if ([false, _item, _amount] call life_fnc_handleInv) then {
                    (wongs_flag getVariable["plb_capData", [0, "Neutral", 0.5]]) params["_flagGangID", "_flagGangName", "_progress"];
                    private _extra = "";
                    private _inTurf = (player inArea "turf_area_rodo_flag" || player inArea "turf_area_panagia_flag" || player inArea "turf_area_zaros_flag");
                    private _cut =
                    switch (true) do {case ((_shopType == "wongs") && !(life_wongsCartel select 0)): {floor(_price * 0.10)};
                        case ((_shopType == "heroin") && !(life_turfTax select 0) && _inTurf): {floor(_price * 0.20)};
                        default {0};
                    }; if ((_shopType == "wongs") && !(life_wongsCartel select 0) && ((call life_adminLevel) <= 2) && !(_item in ["rum_0", "scotch_0", "scotch_3", "whiskeyc_0", "whiskeyr_0"])) then {
                        private _updateVal = (life_wongsCartel select 1);
                        _updateVal = _updateVal + _cut;
                        _price = _price - _cut;
                        life_wongsCartel set[1, _updateVal];
                        _extra = format[", after a $%1 cut was taken by the owner of Wong Triad.", [_cut] call life_fnc_numberText];};
                    if ((_shopType == "heroin") && !(life_turfTax select 0) && _inTurf && ((call life_adminLevel) <= 2)) then {
                        private _updateVal = (life_turfTax select 1);
                        _updateVal = _updateVal + _cut;
                        _price = _price - _cut;
                        life_turfTax set[1, _updateVal];
                        private _nearestFlag = (nearestObjects[player, ["Flag_Red_F", "FlagPole_F"], 500] select 0);
                        private _flagName = ["Rodopoli", "Zaros", "Panagia"] param[[rodo_flag, zaros_flag, panagia_flag] find _nearestFlag, "Capture Point"];
                        _extra = format[", after a $%1 cut was taken by the owner of the %2", [_cut] call life_fnc_numberText, format["%1 Turf", _flagName]];
                    };
                    if (_shopType in ["wongs", "heroin"]) then {
                        if ((((life_lastPersistVar select 0) isEqualTo "plb_drugtrace") && ((life_lastPersistVar select 1) < time)) || !((life_lastPersistVar select 0) isEqualTo "plb_drugtrace")) then {
                            [[getPlayerUID player, "plb_drugtrace", time], "TON_fnc_varPersist", 2] spawn life_fnc_MP;
                            life_lastPersistVar = ["plb_drugtrace", (time + 30)];
                            [] spawn {private _time = time;
                                waitUntil {uiSleep 1;
                                    (life_cash isEqualTo 0) || ((time - _time) > 400)};
                                if (life_cash isEqualTo 0) then {[
                                        [getPlayerUID player, "plb_drugtrace", -1000], "TON_fnc_varPersist", 2] spawn life_fnc_MP;};};};};
                    _control ctrlEnable false;
                    // NEW DRACHMA: legacy loonycoin sells straight to the WALLET at 1 coin = 1 ND (not cash) --
                    // the straggler path for coins still sitting in trunks/houses after the switch. Items are
                    // already removed above; here we just reroute the payout.
                    if (_item isEqualTo "loonycoin") then {[format["%1", _amount], "coinsell"] call PLB_fnc_ndRequest;
                        systemChat format["You converted %1 mined coin%2 to %1 ND", _amount, ["s",""] select (_amount == 1)];} else {
                        life_cash = (round(life_cash + _price)) max 0;
                        life_cashCacheB = ((life_cash / 4) + 9);
                        [0] call life_fnc_ClupdatePartial;
                        systemChat format["You sold %1 %2 for $%3%4", _amount, _itemName, [_price] call life_fnc_numberText, _extra];};
                    private _index = life_soldVItems findIf {_x select 0 == _itemName};
                    if (_index isEqualTo - 1) then {life_soldVItems pushBack[_itemName, _amount, _cut, _price, _item];} else {
                        private _oldValues = life_soldVItems select _index;
                        _oldValues params["_itemName", "_xAmount", "_tax", "_prePrice", "_cfgName"];
                        life_soldVItems set[_index, [_itemName, _xAmount + _amount, _tax + _cut, _prePrice + _price, _cfgName]];};
                    if (_item in ["uraniump", "cokebrick", "bluemeth", "moonshine", "moonshinep", "oyster", "oysterfry"]) then {
                        [format["%1%2", _item, "_sold"], _amount] call life_fnc_statArrUpdate;} else {
                        [_item, _amount] call life_fnc_statArrUpdate;};
                    if (_item isEqualTo "goldbar") then {["goldsold", 1] call life_fnc_statArrUpdate;};
                    ["sell", _item, _amount] call life_fnc_handleQuest;
                    if (_item in ["salema", "ornate", "mackerel", "tuna", "mullet", "catshark"]) then {
                        ["sell", "fish", _amount] spawn life_fnc_handleQuest;};
                    // Dynamic market: report the sale so the server raises this good's saturation
                    // (life_stock_update PVEH -> life_price_index += _amount, rebroadcast to all clients).
                    if (!isNil "life_price_index" && {(life_price_index findIf {(_x isEqualType []) && {(_x param [0, ""]) isEqualTo _item}}) > -1}) then {
                        life_stock_update = [_item, _amount, objNull];
                        publicVariable "life_stock_update";};
                    if (_price > 2500) then {[0] call life_fnc_ClupdatePartial;
                        [true] call life_fnc_saveGear;};
                    [_shopType, _mainItemListSelect] call life_fnc_virtualShopUpdate; [
                        ["-ITEMSOLD-", player, (profileName), format["sold %1 %2 for $%3 at POS: %4", [_amount] call life_fnc_numberText, ["getName", _item] call life_fnc_virtItemCfg, [_price] call life_fnc_numberText, getPosATL player]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
                };};};