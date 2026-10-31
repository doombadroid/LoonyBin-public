private _filterFunction = {params[["_controlData", [], [[]]]];
    if (_controlData isEqualTo[]) exitWith {}; // was: _selectedType (undefined local -> errored -> empty market)
    _controlData params["_control", "_selectedIndex"];
    private _plb_display = findDisplay 5300;
    private _list = _plb_display displayCtrl 5301;
    private _details = _plb_display displayCtrl 5302;
    private _filterList = _plb_display displayCtrl 5303;
    private _filterType = _control lbData _selectedIndex;
    lbClear _list;
    private _shopInfo = [_filterType] call life_fnc_virt_shops;
    _shopInfo params[["_title", ""], ["_buyItems", []], ["_sellItems", []]]; {_x params["_item"];
        private _price = ["getLowestPrice", _item] call life_fnc_virtItemCfg;
        private _price = floor(_price);
        private _itemPic = ["getIcon", _item] call life_fnc_virtItemCfg;
        private _name = ["getName", _item] call life_fnc_virtItemCfg;
        _index = _list lbAdd format["%1", _name];
        _list lbSetTextRight[_index, format[" $%1", [_price] call life_fnc_numberText]];
        _list lbSetColorRight[_index, [0, 0.75, 0, 1]];
        _list lbSetSelectColorRight[_index, [0, 0.75, 0, 1]];
        _list lbSetPicture[_index, _itemPic];
        _list lbSetData[_index, _item];
        _list lbSetValue[_index, _price];}
    forEach _sellItems;};
disableSerialization;
createDialog "life_market_menu";
waitUntil {!isNull(findDisplay 5300)};
private _display = findDisplay 5300;
[_display] spawn life_fnc_p_updateMenu;
private _list = _display displayCtrl 5301;
private _details = _display displayCtrl 5302;
private _filterList = _display displayCtrl 5303;
_filterList lbSetCurSel 0; {private _shopInfo = [_x] call life_fnc_virt_shops;
    _shopInfo params[["_title", ""], ["_buyItems", []], ["_sellItems", []]];
    private _index = _filterList lbAdd _title;
    _filterList lbSetData[_index, _x];}
forEach["heroin", "wongs", "rebel", "market", "oil", "fishmarket", "diamond", "salt", "commod", "blackmarket"];
_details ctrlSetStructuredText parseText "<t size='0.90' align='center'>Market Sell Prices:</t>";
_filterList ctrlAddEventHandler["LBSelChanged", format["[_this] call %1;", _filterFunction]];
_filterList lbSetCurSel 0;