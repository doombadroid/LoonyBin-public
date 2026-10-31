params[["_shopType", ""], ["_control", controlNull]];
if (isNull _control) exitWith {};
if (_shopType isEqualTo "") exitWith {};
if !(ctrlEnabled _control) exitWith {};
private _display = findDisplay 39400;
if (isNull _display) exitWith {};
private _title = _display displayCtrl 39401;
private _filterList = _display displayCtrl 39402;
private _mainListGroup = _display displayCtrl 39404;
private _mainItemList = _mainListGroup controlsGroupCtrl 1000;
private _mainItemListButton = _mainListGroup controlsGroupCtrl 1001;
private _sideListGroup = _display displayCtrl 39405;
private _sideItemList = _sideListGroup controlsGroupCtrl 1000;
private _sideItemListButton = _sideListGroup controlsGroupCtrl 1001;
private _filterListSelect = lbCurSel _filterList;
private _sideItemListSelect = lbCurSel _sideItemList;
private _mainItemListSelect = lbCurSel _mainItemList;
if ((_control isEqualTo _mainItemListButton) && (_mainItemListSelect isEqualTo - 1)) exitWith {
    ["You need to select an item to buy", "basic"] spawn life_fnc_handleMessage;};
if ((_control isEqualTo _sideItemListButton) && (_sideItemListSelect isEqualTo - 1)) exitWith {
    ["You need to select an item to buy", "basic"] spawn life_fnc_handleMessage;};
private _itemInfo =
switch (_control) do {case _mainItemListButton: {
            [_mainItemList lnbData[_mainItemListSelect, 0], _mainItemList lnbValue[_mainItemListSelect, 1]]};
    case _sideItemListButton: {[_sideItemList lnbData[_sideItemListSelect, 0], _sideItemList lnbValue[_sideItemListSelect, 1]]};
    default {[]};}; if !(_itemInfo params["_class", "_price"]) exitWith {};
// owner 2026-06-16 (#267/#297): REMOVE the LMG belt/box tracer mags ENTIRELY (any shop) -- the MK200 etc.
// "200Rnd cased Box Tracer" auto-lists at the $100 default = cheap stun ammo. Match "box"+"tracer" so it kills
// the LMG box/belt tracers everywhere while LEAVING the bounty/skiptracer 30Rnd "Rubber" stanag mags (the BH
// downing ammo, #281) and the cop 9mm SMG_02 tracer (neither contains "box"). The rebel/turf rule still bars
// ALL tracers from those two shops.
private _lc = toLower _class;
if (((_lc find "box" >= 0) && (_lc find "tracer" >= 0)) || (_shopType in ["rebelwep", "turf"] && {(_lc find "tracer" >= 0)})) exitWith {
    ["Tracer rounds aren't sold here.", "basic"] spawn life_fnc_handleMessage;};
private _itemDetails = [_class] call life_fnc_fetchCfgDetails;
private _exit = false;
if !((_itemDetails select 6) isEqualTo "CfgVehicles") then {
    if (((_itemDetails select 4) in [4096, 131072, 0]) || ((_itemDetails select 6) isEqualTo "CfgMagazines")) then {
        if !(player canAdd _class) then {_exit = true};};};
if (_exit) exitWith {["You don't have enough room for that item", "basic"] spawn life_fnc_handleMessage;};
private _action = true;
private _dlcInfo = getAssetDLCInfo[_class, configFile >> "CfgWeapons"];
if (_dlcInfo select 0 && !(_dlcInfo select 1)) then {
    _action = [format["You need the %1 DLC in order to re-equip this weapon if you place it on the ground or into a vehicle/crate. Purchase anyway?", _dlcInfo select 5], "Purchase anyway?", "Yes", "No"] call BIS_fnc_guiMessage;
};
if !(_action) exitWith {};
private _itemType =
switch (true) do {case (_class isKindOf["Rifle", configFile >> "CfgWeapons"]): {[!((primaryWeapon player) isEqualTo ""), "primary weapon"]
        };
    case (_class isKindOf["Launcher", configFile >> "CfgWeapons"]): {[!((secondaryWeapon player) isEqualTo ""), "secondary weapon"]};
    case (_class isKindOf["Pistol", configFile >> "CfgWeapons"]): {[!((handgunWeapon player) isEqualTo ""), "handgun"]};
    default {[false, ""]};}; private _action =
if (_itemType select 0) then {
    [format["You already have a %1 equipped, buying another will replace it. Purchase anyway?", _itemType select 1], "Duplicate Item Warning", "Yes", "No"] call BIS_fnc_guiMessage;
} else {true};
if !(_action) exitWith {};
// NEW DRACHMA: capture whether this is the wallet (ND) shop NOW -- the ND debit is async and the
// global could be cleared if the player closes the shop before the callback lands.
private _isND = life_ndShop;
// ND price is INDEPENDENT of the cash price (fn_ndPriceCfg table). Fall back to 6000:1 with an RPT
// warn if a key was missed -- that means "add a row", not "ship this price".
private _ndPrice = "";
if (_isND) then {_ndPrice = [_class] call life_fnc_ndPriceCfg;
    if (_ndPrice isEqualTo "") then { _ndPrice = [_price] call PLB_fnc_ndFromLegacy; diag_log format ["[LooneyBin][ND] weapon shop missing price key %1 -- 6000:1 fallback", _class]; };
};
private _priceText =
if (_isND) then {format["%1 ND", [_ndPrice] call PLB_fnc_ndText]} else {format["$%1", [_price] call life_fnc_numberText]};
// --- grant continuation: everything after payment. Self-contained (runs in ndResult's scope on the ND
// path), so it takes all state via _this, never weaponShopBuy locals. Cash path calls it inline. ---
private _finishBuy = {params ["_class", "_shopType", "_price", "_priceText", "_itemType", "_itemDetails", "_isND"];
    if (_shopType in ["skiptracer"]) then {["action", "skiptracerspend", _price] spawn life_fnc_handleQuest;};
    [_class, true, false, true, false, false, false, false] call life_fnc_handleItem;
    private _cfgClass = if ("Grenade" in _class) then { "CfgMagazines" } else { "CfgWeapons" };
    if (((_itemType select 1) in ["primary weapon", "secondary weapon", "handgun"]) || (toLower _class in ["handgrenade", "minigrenade"])) then {
        [["-WEAPONBOUGHT-", player, (profileName), format["purchased a %1 for %2 at POS: %3", getText(configFile >> _cfgClass >> _class >> "displayName"), _priceText, getPosATL player]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
        if (_shopType == "gun") then { ["buy", "gunstoregun", 1] spawn life_fnc_handleQuest; };};
    private _extra = "";
    private _cut = 0;
    // cartel/gov cuts are CASH-economy only -- never on the ND path (gated on !_isND, not the global).
    if (!(_isND) && (_shopType == "rebelwep") && !(life_armsCartel select 0) && ((call life_adminLevel) <= 2)) then {
        _cut = floor((_price) * 0.08);
        life_armsCartel set[1, (life_armsCartel select 1) + _cut];
        _extra = "Arms";};
    if (!(_isND) && (_shopType isNotEqualTo "rebelwep") && ((call life_adminLevel) <= 2)) then {
        _cut = floor((_price) * (call life_fnc_getGovTax));
        life_govTax set[1, (life_govTax select 1) + _cut];
        _extra = "Tax";};
    playSound "purchase";
    private _index = life_purchasedGear findIf { _x select 0 == _class };
    if (_index isEqualTo - 1) then {life_purchasedGear pushBack[_class, 1, _cut, _itemDetails select 1, _price, _extra];} else {
        (life_purchasedGear select _index) params["_item", "_amount", "_tax", "_itemName", "_prePrice"];
        life_purchasedGear set[_index, [_item, _amount + 1, _tax + _cut, _itemName, _prePrice + _price, _extra]];};
    // refresh list colours + title from the (now updated) balances. Re-resolve controls -- the dialog may
    // have changed between request and callback on the ND path.
    private _disp = findDisplay 39400;
    if (!isNull _disp) then {private _mlg = _disp displayCtrl 39404; private _slg = _disp displayCtrl 39405; {
            _x params["_itemList", "_itemListButton"];
            private _selectedIndex = lbCurSel _itemList;
            for "_rowIndex" from 0 to((lbSize _itemList) - 1) do {private _rClass = _itemList lnbData[_rowIndex, 0];
                private _rPrice = _itemList lnbValue[_rowIndex, 1];
                private _color = [1, 1, 1, 0.5];
                if (_shopType in ["rebelwep", "turf"]) then {if (_isND) then {
                        if ([[_rClass] call life_fnc_ndPriceCfg] call { private _n = _this select 0; if (_n isEqualTo "") then {_n = [_rPrice] call PLB_fnc_ndFromLegacy}; [_n] call PLB_fnc_ndAfford }) then { _color set[3, 1] };
                    } else {if (life_cash >= _rPrice) then { _color set[3, 1] };};};
                if (((life_cash >= _rPrice) || ((life_atmcash >= _rPrice) && (life_inv_debitcard >= 1))) && !(_shopType in ["rebelwep", "turf"])) then { _color set[3, 1] };
                for "_columnIndex" from 0 to 1 do { _itemList lnbSetColor[[_rowIndex, _columnIndex], _color] };
                if (_rowIndex isEqualTo _selectedIndex) then { _itemListButton ctrlEnable(((_itemList lnbColor[_selectedIndex, 0]) select 3) isEqualTo 1) };
            };
        } forEach [[_mlg controlsGroupCtrl 1000, _mlg controlsGroupCtrl 1001], [_slg controlsGroupCtrl 1000, _slg controlsGroupCtrl 1001]];
        private _titleText = ([_shopType] call life_fnc_weaponShopCfg) select 0;
        if (_isND) then { _titleText = _titleText + (format[" - %1 ND", [life_ndStr] call PLB_fnc_ndText]) };
        (_disp displayCtrl 39401) ctrlSetText _titleText;};};
private _ctx = [_class, _shopType, _price, _priceText, _itemType, _itemDetails, _isND];
if (_isND) then {if !([_ndPrice] call PLB_fnc_ndAfford) exitWith {
        [format["You cannot afford this item. You need %1.", _priceText], "basic"] spawn life_fnc_handleMessage;};
    [_ndPrice, _finishBuy, _ctx] call PLB_fnc_ndBuy;   // async: server debits, then _finishBuy runs on success
} else {if ((_price > life_cash) && (_shopType in ["rebelwep", "turf"])) exitWith {
        [format["You do not have enough cash on you to pay for this. You need %1.", _priceText], "basic"] spawn life_fnc_handleMessage;};
    if !([round _price] call life_fnc_debitCard) exitWith {
        [format["You cannot afford this item. You need $%1.", [_price] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;};
    _ctx call _finishBuy;};