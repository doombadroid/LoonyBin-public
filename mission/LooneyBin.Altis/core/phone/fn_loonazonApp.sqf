/*
    life_fnc_loonazonApp  (LooneyBin, owner 2026-07-16) -- the standalone LOONAZON app (dialog 987600).
    Category storefront + ADD-TO-CART with DUAL WEIGHT CAPS: 3000 virtual / 960 physical per order (the cfg's
    vcap/pcap). Cart lines are [class, name, unitPrice, isPhys, unitWeight, qty]. ORDER debits the bank
    client-side (the shop precedent) and ships the whole cart to TON_fnc_loonazonSRV, which re-validates and
    refunds on any reject. Modes: open / cat <key> / add / remove / refresh / order.
*/
#include "..\..\macro.h"
if (!hasInterface) exitWith {};
disableSerialization;
params [["_mode", "open", [""]], ["_arg", "", [""]]];

private _kraft = { params ["_idc", "_on"];
    ((findDisplay 987600) displayCtrl _idc) ctrlSetBackgroundColor (if (_on) then { [0.34, 0.42, 0.08, 1] } else { [0.047, 0.09, 0.07, 1] });
};

switch (toLower _mode) do {

    case "open": {
        if (playerSide isNotEqualTo civilian) exitWith { ["Loonazon delivers to civilians only. Company policy.", "basic"] spawn life_fnc_handleMessage; };
        closeDialog 0;
        if (!createDialog "PLB_LoonazonApp") exitWith {};
        life_lzCart = [];
        life_lzCat = "gen";
        ["cat", "gen"] call life_fnc_loonazonApp;
        ["refresh"] call life_fnc_loonazonApp;};

    case "cat": {life_lzCat = _arg;
        { [_x select 0, (_x select 1) isEqualTo _arg] call _kraft; }
            forEach [[987610, "gen"], [987611, "rebel"], [987613, "drip"], [987614, "ritems"], [987612, "seeds"]];
        private _lb = (findDisplay 987600) displayCtrl 987620;
        lbClear _lb; {_x params ["_cls", "_name", "_price", "_isPhys", "_wgt", "_icon"];
            private _i = _lb lbAdd format ["%1", _name];
            _lb lbSetData [_i, _cls];
            _lb lbSetTextRight [_i, format ["$%1", [_price] call life_fnc_numberText]];
            if (_icon isNotEqualTo "") then { _lb lbSetPicture [_i, _icon]; };
            _lb lbSetTooltip [_i, format ["%1  |  weight %2 (%3)", _name, _wgt, (["virtual", "physical"] select _isPhys)]];
        } forEach (["items", _arg] call life_fnc_loonazonCfg);};

    case "add": {private _lb = (findDisplay 987600) displayCtrl 987620;
        if ((lbCurSel _lb) isEqualTo -1) exitWith { ["Pick an item first.", "basic"] spawn life_fnc_handleMessage; };
        private _cls = _lb lbData (lbCurSel _lb);
        private _qtyTxt = ctrlText ((findDisplay 987600) displayCtrl 987621);
        if !([_qtyTxt] call life_fnc_isNumber) exitWith { ["Quantity must be a number.", "basic"] spawn life_fnc_handleMessage; };
        private _qty = round (parseNumber _qtyTxt);
        if (_qty < 1) exitWith { ["Quantity must be at least 1.", "basic"] spawn life_fnc_handleMessage; };
        private _row = ["get", _cls] call life_fnc_loonazonCfg;
        if (_row isEqualTo []) exitWith {};
        _row params ["_c", "_name", "_price", "_isPhys", "_wgt"];
        // cap preview: adding this line must keep BOTH totals inside the order caps
        private _v = 0; private _p = 0;
        { _x params ["", "", "", "_ip", "_w", "_q"]; if (_ip) then { _p = _p + _w * _q; } else { _v = _v + _w * _q; }; } forEach life_lzCart;
        private _nv = _v + ([_wgt * _qty, 0] select _isPhys);
        private _np = _p + ([0, _wgt * _qty] select _isPhys);
        if (_nv > (["vcap"] call life_fnc_loonazonCfg)) exitWith { [format ["That would put the order over the %1 VIRTUAL weight cap.", ["vcap"] call life_fnc_loonazonCfg], "basic"] spawn life_fnc_handleMessage; };
        if (_np > (["pcap"] call life_fnc_loonazonCfg)) exitWith { [format ["That would put the order over the %1 PHYSICAL weight cap.", ["pcap"] call life_fnc_loonazonCfg], "basic"] spawn life_fnc_handleMessage; };
        // merge with an existing line for the same item
        private _i = life_lzCart findIf { (_x select 0) isEqualTo _c };
        if (_i > -1) then {(life_lzCart select _i) set [5, ((life_lzCart select _i) select 5) + _qty];} else {
            life_lzCart pushBack [_c, _name, _price, _isPhys, _wgt, _qty];};
        ["refresh"] call life_fnc_loonazonApp;};

    case "remove": {private _lb = (findDisplay 987600) displayCtrl 987631;
        if ((lbCurSel _lb) isEqualTo -1) exitWith { ["Pick a cart line to remove.", "basic"] spawn life_fnc_handleMessage; };
        life_lzCart deleteAt (lbCurSel _lb);
        ["refresh"] call life_fnc_loonazonApp;};

    case "refresh": {private _lb = (findDisplay 987600) displayCtrl 987631;
        lbClear _lb;
        private _v = 0; private _p = 0; private _sum = 0; {_x params ["_cls", "_name", "_price", "_isPhys", "_wgt", "_qty"];
            private _i = _lb lbAdd format ["%1  x%2", _name, _qty];
            _lb lbSetTextRight [_i, format ["$%1", [_price * _qty] call life_fnc_numberText]];
            if (_isPhys) then { _p = _p + _wgt * _qty; } else { _v = _v + _wgt * _qty; };
            _sum = _sum + _price * _qty;} forEach life_lzCart;
        ((findDisplay 987600) displayCtrl 987630) ctrlSetStructuredText parseText format ["<t size='1.05' color='#dbe7e0'>CART</t><t size='1.05' color='#80918a'>  (%1 line%2)</t>", count life_lzCart, ["s", ""] select (count life_lzCart isEqualTo 1)];
        // dual weight meters -- 18-cell block bars, kraft while inside the cap, red at the wall
        private _vcap = ["vcap"] call life_fnc_loonazonCfg;
        private _pcap = ["pcap"] call life_fnc_loonazonCfg;
        private _fnBar = { params ["_val", "_cap"];
            private _cells = 18;
            private _fill = ceil (_cells * ((_val / _cap) min 1));
            private _col = if (_val > _cap) then { "#ff4d4d" } else { "#c9e21a" };
            private _out = "";
            for "_i" from 1 to _cells do { _out = _out + (if (_i <= _fill) then { "&#9608;" } else { "&#9617;" }); };
            format ["<t color='%1'>%2</t>", _col, _out]};
        ((findDisplay 987600) displayCtrl 987640) ctrlSetStructuredText parseText format [
            "<t size='0.8' color='#80918a'>VIRTUAL</t><br/><t size='0.72'>%1</t> <t size='0.8' color='#dbe7e0'>%2/%3</t><br/><t size='0.8' color='#80918a'>PHYSICAL</t><br/><t size='0.72'>%4</t> <t size='0.8' color='#dbe7e0'>%5/%6</t>",
            [_v, _vcap] call _fnBar, round _v, _vcap, [_p, _pcap] call _fnBar, round _p, _pcap];
        private _fee = ["fee"] call life_fnc_loonazonCfg;
        ((findDisplay 987600) displayCtrl 987641) ctrlSetStructuredText parseText format [
            "<t size='1.25' color='#dbe7e0'>$%1</t><t size='0.8' color='#80918a'>  total (+$%2 delivery)</t>",
            [_sum] call life_fnc_numberText, _fee];};

    case "order": {if (life_lzCart isEqualTo []) exitWith { ["Your cart is empty.", "basic"] spawn life_fnc_handleMessage; };
        // Loonazon runs on the headless-client driver. No HC online = no deliveries (owner 2026-07-16).
        if ((missionNamespace getVariable ["PLB_hcOwner", 0]) <= 0) exitWith {
            ["Workers are on strike, they're demanding more piss bottles. Not gonna happen. Try again later after we replace them all with minorities", "basic"] spawn life_fnc_handleMessage;
        };
        private _sum = 0; private _v = 0; private _p = 0; {_x params ["", "", "_price", "_isPhys", "_wgt", "_qty"];
            _sum = _sum + _price * _qty;
            if (_isPhys) then { _p = _p + _wgt * _qty; } else { _v = _v + _wgt * _qty; };} forEach life_lzCart;
        if (_v > (["vcap"] call life_fnc_loonazonCfg) || {_p > (["pcap"] call life_fnc_loonazonCfg)}) exitWith { ["Order is over a weight cap -- trim the cart.", "basic"] spawn life_fnc_handleMessage; };
        private _total = _sum + (["fee"] call life_fnc_loonazonCfg);
        if (life_atmcash < _total) exitWith { [format ["You need $%1 in your BANK for this order.", [_total] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage; };
        private _action = [format ["Place this order for $%1? A van will haul it to where you're standing RIGHT NOW.", [_total] call life_fnc_numberText], "Loonazon Checkout", "Order", "Cancel"] call BIS_fnc_guiMessage;
        if (!_action) exitWith {};
        life_atmcash = life_atmcash - _total;
        life_atmcashCacheB = ((life_atmcash / 4) + 11);
        private _cart = life_lzCart apply { [_x select 0, _x select 5] };   // [[class, qty], ...]
        [["order", _cart, _total], "TON_fnc_loonazonSRV", 2] spawn life_fnc_MP;
        life_lzCart = [];
        closeDialog 0;};};
