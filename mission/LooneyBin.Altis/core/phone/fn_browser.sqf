/*
    life_fnc_browser  (LooneyBin -- phone web browser "LoonyNet")
    Modes:
      ["open"]        phone-app entry: create the dialog, go to the start page
      ["go", url]     navigate to a url (string, no scheme; "loonynet.start" = home)
      ["url"]         navigate to whatever is typed in the url bar
      ["nav"]         navigate to the selected nav-rail entry (lbData = url)
      ["back"]        one step back in history
    Rendering data comes from life_fnc_browserSites (url -> [pageTitle, navTitle, [[navLabel, navUrl]...], html-ish structured text]).
    Purely client-side + cosmetic: no server calls, no money, nothing to exploit.
*/
#include "..\..\macro.h"
disableSerialization;
params [["_mode", "open", [""]], ["_arg", "", ["", []]]];   // _arg: url string, or [market, sel] for betprompt

private _render = {params ["_url", ["_pushHist", true]];
    private _d = findDisplay 936100;
    if (isNull _d) exitWith {};
    private _site = [_url] call life_fnc_browserSites;
    _site params [["_tab", "LoonyNet"], ["_railTitle", ""], ["_links", []], ["_body", ""]];

    // history (don't push when navigating via Back)
    if (_pushHist) then {private _cur = life_browser_url;
        if (_cur isNotEqualTo "" && {_cur isNotEqualTo _url}) then { life_browser_hist pushBack _cur; };};
    life_browser_url = _url;

    // url bar shows the pretty url (home shows empty)
    ctrlSetText [936110, ([_url, ""] select (_url isEqualTo "loonynet.start"))];

    // nav rail
    private _rail = _d displayCtrl 936120;
    lbClear _rail;
    if (_railTitle isNotEqualTo "") then {private _hdr = _rail lbAdd _railTitle;
        _rail lbSetColor [_hdr, [0.55, 0.6, 0.7, 1]];
        _rail lbSetData [_hdr, ""];}; {_x params ["_label", "_target"];
        if !(_label isEqualTo "") then {private _i = _rail lbAdd _label;
            _rail lbSetData [_i, _target];};} forEach _links;
    // highlight the rail row matching the current url (suppressed: onLBSelChanged fires on lbSetCurSel)
    life_browser_suppress = true;
    private _hit = -1;
    for "_i" from 0 to ((lbSize _rail) - 1) do {if ((_rail lbData _i) isEqualTo _url) exitWith { _hit = _i; };};
    if (_hit < 0 && {(lbSize _rail) > 0}) then { _hit = 0; };   // combo: show the menu header as the label
    lbSetCurSel [936120, _hit];
    life_browser_suppress = false;

    // page body + scroll back to top
    (_d displayCtrl 936131) ctrlSetStructuredText parseText _body;
    // owner 2026-07-15: AUTO-SIZE the page text control to its content. It had a FIXED height, so any page
    // taller than that (a long looner feed, a full DataBattle article) clipped -- the scroll group can only
    // scroll as far as the child control is tall. Height scales with the line-break count.
    private _txt = _d displayCtrl 936131;
    private _nbr = 0; private _rem = _body;
    while { (_rem find "<br") >= 0 } do { _nbr = _nbr + 1; _rem = _rem select [(_rem find "<br") + 3]; };
    private _tp = ctrlPosition _txt;
    _tp set [3, (((_nbr + 8) * 0.052) max 3.4) * 40 * pixelGrid * pixelH];   // deck reskin: was 79.66 (old frame); 40 = deck's 20*UI_GRID_H span
    _txt ctrlSetPosition _tp; _txt ctrlCommit 0;
    private _grp = _d displayCtrl 936130;
    private _gp = ctrlPosition _grp;
    _grp ctrlSetPosition _gp; _grp ctrlCommit 0;

    // Looner: show the compose bar + shrink the feed for it; ask the server for the live feed
    private _onLooner = (_url find "looner.") isEqualTo 0;
    { (_d displayCtrl _x) ctrlShow _onLooner; } forEach [936140, 936141, 936142];
    (_d displayCtrl 936104) ctrlSetText (call {   // per-site page ground (baked, scroll-safe)
        if ((_url find "databattle.") isEqualTo 0) exitWith { "images\browser_bg_port_news.paa" };
        if ((_url find "loonybets.") isEqualTo 0) exitWith { "images\browser_bg_port_bets.paa" };
        if (_url isEqualTo "loonynet.start") exitWith { "images\browser_bg_port_home.paa" };
        if ((_url find "loonstreets.") isEqualTo 0) exitWith { "images\browser_bg_port_streets.paa" };
        if ((_url find "loonazon.") isEqualTo 0) exitWith { "images\browser_bg_port_loonazon.paa" };
        ["images\browser_bg_port.paa", "images\browser_bg_port_looner.paa"] select _onLooner});
    private _gh = if (_onLooner) then { 0.7350 } else { 0.8560 };   // landscape redesign: pane y -4.75..8.95 (13.7 GH = 0.856*16); looner compose reserves the bottom 1.95
    _grp ctrlSetPositionH (_gh * 40 * pixelGrid * pixelH); _grp ctrlCommit 0;   // deck reskin: was 79.66 (old frame); 40 = deck's 20*UI_GRID_H span
    if (_onLooner) then {["updateCount"] call life_fnc_browser;
        [["feed"], "TON_fnc_loonerSRV", 2, false, false] spawn life_fnc_MP;   // server pushes -> life_fnc_loonerReceive
    };};

switch (_mode) do {case "open": {closeDialog 0;
        life_browser_hist = [];
        life_browser_url = "";
        life_browser_suppress = false;
        createDialog "life_browser";
        waitUntil { !isNull (findDisplay 936100) };
        // in-page links (structured text <a href>): "like:<id>" boosts a loon, "go:<url>" navigates
        ((findDisplay 936100) displayCtrl 936131) ctrlAddEventHandler ["HTMLLink", {params ["", "_link"];
            private _l = toLower _link;
            private _i = _l find "like:";
            if (_i >= 0) exitWith {private _pid = parseNumber (_link select [_i + 5]);
                if (_pid > 0) then { [["like", _pid], "TON_fnc_loonerSRV", 2, false, false] spawn life_fnc_MP; };};
            _i = _l find "bet:";
            if (_i >= 0) exitWith {private _p = (_l select [_i + 4]) splitString ":";
                if (count _p >= 2) then { [["betprompt", [_p select 0, _p select 1]]] spawn { (_this select 0) call life_fnc_browser; }; };
            };
            _i = _l find "shop:";
            if (_i >= 0) exitWith {private _it = _l select [_i + 5];
                [["shopprompt", [_it, ""]]] spawn { (_this select 0) call life_fnc_browser; };   // inputMenu blocks -> scheduled
            };
            _i = _l find "go:";
            if (_i >= 0) exitWith {["go", _link select [_i + 3]] call life_fnc_browser;};}];
        ["loonynet.start", false] call _render;};
    case "go": {[_arg, true] call _render;};
    case "shopprompt": {   // tap ORDER on loonazon.com -> quantity window -> pay -> drone dispatch
        _arg params [["_it", "", [""]]];
        private _row = ["get", _it] call life_fnc_loonazonCfg;
        if (_row isEqualTo []) exitWith {};
        private _fee = ["fee"] call life_fnc_loonazonCfg;
        closeDialog 0;
        uiSleep 0.2;
        [format ["<t align='center' size='1.3'>%1</t><br/><t align='center' color='#e88b2d'>$%2 each  --  max %3</t><br/><br/><t align='center'>Delivery: $%4 flat</t><br/><t align='center'>Bank: $%5</t><br/><br/><t align='center'>How many?</t>", _row select 1, _row select 2, _row select 3, _fee, [life_atmcash] call life_fnc_numberText], "Loonazon", "ORDER"] call life_fnc_inputMenu;
        private _typed = life_input_response;
        life_input_response = "";
        ["open"] call life_fnc_browser;
        ["go", "loonazon.com"] call life_fnc_browser;
        if (_typed isEqualTo "") exitWith {};
        private _qty = round (parseNumber _typed);
        if (_qty < 1 || {_qty > (_row select 3)}) exitWith { [format ["Loonazon: quantity must be 1-%1.", _row select 3], "basic"] spawn life_fnc_handleMessage; };
        private _cost = (_row select 2) * _qty + _fee;
        if (life_atmcash < _cost) exitWith { [format ["Loonazon: that's $%1 -- your bank can't cover it.", [_cost] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage; };
        life_atmcash = life_atmcash - _cost; [1] call life_fnc_ClupdatePartial;
        [["order", _it, _qty], "TON_fnc_loonazonSRV", 2, false, false] spawn life_fnc_MP;};
    case "betprompt": {   // tap YES/NO on loonybets.com -> stake window ($5k-$50k) -> place the bet
        _arg params [["_bk", "", [""]], ["_bs", "", [""]]];
        if !(_bs in ["yes", "no"]) exitWith {};
        private _mkts = missionNamespace getVariable ["PLB_sportsbook", []];
        private _mi = _mkts findIf { (_x select 0) isEqualTo _bk };
        if (_mi < 0) exitWith { ["LoonyBets: that market just closed.", "basic"] spawn life_fnc_handleMessage; };
        // the input dialog will NOT stack on top of the browser dialog (createDialog silently fails),
        // so: drop the browser, take the stake, then reopen the browser on the board.
        closeDialog 0;
        uiSleep 0.2;
        [format ["<t align='center'>%1</t><br/><t align='center' size='1.2' color='#d99a2b'>Betting %2</t><br/><br/><t align='center'>Stake: $5,000 min  --  $50,000 max</t><br/><t align='center'>Bank: $%3</t>", (_mkts select _mi) select 1, toUpper _bs, [life_atmcash] call life_fnc_numberText], "LoonyBets", "PLACE BET"] call life_fnc_inputMenu;
        private _typed = life_input_response;
        life_input_response = "";
        ["open"] call life_fnc_browser;                       // browser back (open blocks until the display exists)
        ["go", "loonybets.com"] call life_fnc_browser;        // straight to the board
        if (_typed isEqualTo "") exitWith {};                 // cancelled
        private _ba = round (parseNumber _typed);
        if (_ba < 5000)  exitWith { ["LoonyBets: minimum stake is $5,000.", "basic"] spawn life_fnc_handleMessage; };
        if (_ba > 50000) exitWith { ["LoonyBets: maximum stake is $50,000.", "basic"] spawn life_fnc_handleMessage; };
        if (life_atmcash < _ba) exitWith { ["LoonyBets: your bank can't cover that.", "basic"] spawn life_fnc_handleMessage; };
        if (((missionNamespace getVariable ["PLB_sportsbook", []]) findIf { (_x select 0) isEqualTo _bk }) < 0) exitWith { ["LoonyBets: that market just closed.", "basic"] spawn life_fnc_handleMessage; };
        life_atmcash = life_atmcash - _ba; [1] call life_fnc_ClupdatePartial;
        [["bet", _bk, _bs, _ba], "TON_fnc_sportsbookSRV", 2, false, false] spawn life_fnc_MP;
        uiSleep 0.8;   // server republishes pools -> refresh the board
        if (!isNull (findDisplay 936100) && {(missionNamespace getVariable ["life_browser_url", ""]) find "loonybets." isEqualTo 0}) then { ["go", "loonybets.com"] call life_fnc_browser; };
    };
    case "url": {private _typed = toLower (ctrlText 936110);
        if ((_typed select [0, 4]) isEqualTo "bet ") exitWith {private _parts = (_typed select [4]) splitString " ";
            (findDisplay 936100) displayCtrl 936110 ctrlSetText "";
            if (count _parts < 3) exitWith { ["LoonyBets: format is  bet <market> <yes/no> <amount>", "basic"] spawn life_fnc_handleMessage; };
            private _bk = _parts select 0; private _bs = _parts select 1; private _ba = round (parseNumber (_parts select 2));
            if !(_bs in ["yes","no"]) exitWith { ["LoonyBets: pick yes or no.", "basic"] spawn life_fnc_handleMessage; };
            if (_ba < 5000) exitWith { ["LoonyBets: minimum stake is $5,000.", "basic"] spawn life_fnc_handleMessage; };
            if (_ba > 50000) exitWith { ["LoonyBets: maximum stake is $50,000.", "basic"] spawn life_fnc_handleMessage; };
            if (life_atmcash < _ba) exitWith { ["LoonyBets: your bank can't cover that.", "basic"] spawn life_fnc_handleMessage; };
            if (((missionNamespace getVariable ["PLB_sportsbook", []]) findIf { (_x select 0) isEqualTo _bk }) < 0) exitWith { ["LoonyBets: unknown market -- see loonybets.com.", "basic"] spawn life_fnc_handleMessage; };
            life_atmcash = life_atmcash - _ba; [1] call life_fnc_ClupdatePartial;
            [["bet", _bk, _bs, _ba], "TON_fnc_sportsbookSRV", 2, false, false] spawn life_fnc_MP;};
        _typed = _typed splitString " " joinString "";                          // strip spaces
        if ((_typed select [0, 7]) isEqualTo "http://")  then { _typed = _typed select [7]; };
        if ((_typed select [0, 8]) isEqualTo "https://") then { _typed = _typed select [8]; };
        if ((_typed select [0, 4]) isEqualTo "www.")     then { _typed = _typed select [4]; };
        if (_typed isEqualTo "") exitWith {};
        [_typed, true] call _render;};
    case "nav": {if (missionNamespace getVariable ["life_browser_suppress", false]) exitWith {};
        private _rail = (findDisplay 936100) displayCtrl 936120;
        private _sel = lbCurSel _rail;
        if (_sel < 0) exitWith {};
        private _target = _rail lbData _sel;
        if (_target isEqualTo "") exitWith {};                                  // rail header row
        [_target, (_target isNotEqualTo life_browser_url)] call _render;        // same row = refresh (no hist)
    };
    case "back": {if (life_browser_hist isEqualTo []) exitWith {};
        private _prev = life_browser_hist deleteAt ((count life_browser_hist) - 1);
        [_prev, false] call _render;};
    case "loonpost": {private _d = findDisplay 936100;
        private _txt = trim (ctrlText 936140);
        if (_txt isEqualTo "") exitWith {};
        (_d displayCtrl 936140) ctrlSetText "";
        // "like <#>" boosts a loon instead of posting a new one
        if ((toLower (_txt select [0, 5])) isEqualTo "like " && {(parseNumber (_txt select [5])) > 0}) then {
            [["like", parseNumber (_txt select [5])], "TON_fnc_loonerSRV", 2, false, false] spawn life_fnc_MP;
            (_d displayCtrl 936142) ctrlSetStructuredText parseText "<t color='#e0245e'>Liking...</t>";} else {
            if ((count _txt) > 180) then { _txt = _txt select [0, 180]; };
            [["post", _txt], "TON_fnc_loonerSRV", 2, false, false] spawn life_fnc_MP;   // server validates identity + inserts + broadcasts
            (_d displayCtrl 936142) ctrlSetStructuredText parseText "<t color='#8899aa'>Posting...</t>";};};
    case "updateCount": {private _d = findDisplay 936100;
        if (isNull _d) exitWith {};
        private _n = count (ctrlText 936140);
        private _col = if (_n > 160) then { "#c0392b" } else { "#5a7c8e" };
        (_d displayCtrl 936142) ctrlSetStructuredText parseText format ["<t align='right' size='1.0' color='%2'>%1</t>", 180 - _n, _col];};
};
