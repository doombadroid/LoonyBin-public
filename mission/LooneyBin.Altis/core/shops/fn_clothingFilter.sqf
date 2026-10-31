params["_basic", ["_type", ""], ["_oldLoadout", ""], ["_searchRefresh", false]];
_basic params["_filter", "_selection"];
if (_type isEqualTo "") exitWith {};
disableSerialization;
// owner 2026-07-10: remember the last real (category) filter call so the search box's KeyUp can re-run us
// with the SAME category + loadout and just re-apply the name filter (_searchRefresh=true on those re-runs).
uiNamespace setVariable ["life_clothingFilterArgs", [_basic, _type, _oldLoadout]];
private _selection = _filter lbValue _selection;
// on a SEARCH refresh, skip the preview-camera repositioning -- same category/angle, so re-committing it
// every keystroke is pointless jitter. Only the list gets rebuilt through the name filter below.
if (!_searchRefresh) then {if (_selection isEqualTo 4) then {private _distance = -4;
    while {_distance < -1}
    do {
        if (!lineIntersects[ATLToASL(player modelToWorld[1, _distance, 2]), ATLToASL(player modelToWorld[0, -.15, 1.3]), player]) exitWith {};
        _distance = _distance + 0.5;}; life_shop_cam camSetTarget(player modelToWorld[0, -.15, 1.3]);
    life_shop_cam camSetPos(player modelToWorld[1, _distance, 2]);
    life_shop_cam camCommit 1;} else {private _distance = 4;
    while {_distance > 1}
    do {if (!lineIntersects[ATLToASL(player modelToWorld[1, _distance, 2]), ATLToASL(player modelToWorld[0, 0, 1]), player]) exitWith {};
        _distance = _distance - 0.5;}; life_shop_cam camSetTarget(player modelToWorld[0, 0, 1]);
    life_shop_cam camSetPos(player modelToWorld[1, _distance, 2]);
    life_shop_cam camCommit 1;};};
private _display = findDisplay 3100;
if (isNull _display) exitWith {};
disableSerialization;
private _list = _display displayCtrl 3101;
// owner 2026-07-10: search-bar filter. The typed text only feeds toLower/find (substring match) below --
// never compiled or executed -- so the live edit box has no script-injection surface. Dim placeholder
// (3111) shows only while the box is empty.
private _q = toLower ctrlText (_display displayCtrl 3110);
(_display displayCtrl 3111) ctrlShow (_q isEqualTo "");
private _cancel = _display displayCtrl 1000;
private _priceText = _display displayCtrl 3107;
lbClear _list;
private _items =
switch (_type) do {case "civ": {[_selection] call life_fnc_clothing_civ}; case "cop": {[_selection] call life_fnc_clothing_cop};
        case "skip": {[_selection] call life_fnc_clothing_reb};
        case "rebcloth": {[_selection] call life_fnc_clothing_reb};
        case "dive": {[_selection] call life_fnc_clothing_dive};
        case "copdive": {[_selection] call life_fnc_clothing_copdive};
        case "kart": {[_selection] call life_fnc_clothing_kart};
        case "barber": {[_selection] call life_fnc_clothing_barber};
        case "faces": {[_selection] call life_fnc_clothing_faces};
        case "med": {[_selection] call life_fnc_clothing_med};
        default {[]};}; if !(_items isEqualType[]) exitWith {};
if (_items isEqualTo[]) exitWith {};
// LooneyBin Economy: owner clothing-price overrides (cloth p0 = price, entry index 2)
{if (_x isEqualType [] && {count _x >= 3}) then {private _ov = ["cloth", _x select 0] call life_fnc_priceOv;
        if (_ov isNotEqualTo [] && {(_ov select 2) >= 0}) then { _x set [2, _ov select 2]; };};} forEach _items;
private _oldLoadout = parseSimpleArray format["%1", _oldLoadout];
if !(_oldLoadout isEqualType[]) exitWith {};
private _oldItem = _oldLoadout select _selection;
private _priceTextFormat =
if !(life_ndShop) then {"$0"} else {"0 ND"};
_priceText ctrlSetText _priceTextFormat;
private _index = _list lbAdd "Remove purchase";
_list lbSetData[_index, str["remove", ""]];
_list lbSetValue[_index, 0];
if !(_oldItem isEqualTo "") then {_list lbSetPicture[_index, ([_oldItem] call life_fnc_fetchCfgDetails) select 2]};
private _ownAndInFortress = ([
    ["gang_fortress_marker"], 400, player] call life_fnc_inZone) && (((gang_fortress_flag getVariable["plb_gang_fortress_data", [-1, "Unknown", false]]) param[0, -1]) isEqualTo(life_gang_data param[0, -1])); {
    private _details = [_x select 0] call life_fnc_fetchCfgDetails;
    if (_details params["_class", "_displayName", "_picture"]) then {
        if !(isClass(configFile >> (_details select 6) >> _class)) exitWith {};
        private _price = _x select 2;
        _price =
        if (life_ndShop || (_type isEqualTo "rebcloth")) then {_price} else {_price + (_price * (call life_fnc_getGovTax))};
        _price = round(_price);
        _price =
        if (_ownAndInFortress) then {_price - (_price * 0.15)} else {_price};
        _price =
        _price;
        private _displayName =
        if (isNil {_x select 1}) then {_displayName} else {_x select 1};
        private _customTexture =
        if (isNil {_x select 3}) then {""} else {_x select 3};
        private _picture =
        if (_type isEqualTo "faces") then {""} else {_picture};
        // LooneyBin (owner, 2026-06-11): show the armor value next to each vest/clothing item. Take the
        // highest `armor` across the item's protected hitpoints (vest=chest/body, helmet=head). A `for`
        // loop (not forEach) so the outer clothing-loop `_x` isn't clobbered before lbSetData below.
        private _armor = 0;
        private _hpInfo = configFile >> "CfgWeapons" >> (_x select 0) >> "ItemInfo" >> "HitpointsProtectionInfo";
        if (isClass _hpInfo) then {for "_ci" from 0 to ((count _hpInfo) - 1) do {private _sub = _hpInfo select _ci;
                if (isClass _sub) then { private _a = getNumber (_sub >> "armor"); if (_a > _armor) then { _armor = _a; }; };};};
        if (_armor > 0) then { _displayName = format ["%1  [Armor %2]", _displayName, _armor]; };
        if (_q isEqualTo "" || {(toLower _displayName) find _q >= 0}) then {private _index = _list lbAdd format["%1", _displayName];
            _list lbSetPicture[_index, _picture];
            _list lbSetData[_index, str([_x select 0, _customTexture])];
            _list lbSetValue[_index, _price];};};}
forEach _items;
// owner 2026-07-10: don't steal focus back to the list on a search refresh -- it would yank the caret out
// of the search box after every keystroke. Only grab focus on the initial/category populate.
if (!_searchRefresh) then {ctrlSetFocus _list;
    _list lbSetCurSel - 1;};