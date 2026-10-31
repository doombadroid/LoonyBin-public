/*
    life_fnc_plbInvDemo  (LooneyBin, ui branch, PROOF) -- STRONGBOX inventory "Y menu" the real way (custom PAA,
    no mod). Graphite panel (dialog\plbInv.hpp) + a clean scrollable LIST of item rows ctrlCreate'd here (row PAA
    + name + brass qty + weight), brass full-frame selection, a brass capacity meter, Use/Give/Drop (each fires a
    STRONGBOX slip so both systems show at once). Owner test: !invdemo. Does NOT touch the live player menu.
    Modes:  []  open+build  |  ["sel",_i]  select  |  ["use"]/["give"]/["drop"]  demo feedback
*/
params [["_mode", "open", [""]], ["_arg", 0, [0]]];
disableSerialization;
if (!hasInterface) exitWith {};

// [ name, weight, qty ]
private _items = [["Cocaine", 3, 2], ["Cocaine Brick", 2, 1], ["Heroin", 3, 4], ["Crystal Meth", 2, 3],
    ["Reggie Cannabis", 2, 6], ["LSD Pill", 1, 8], ["Gold Bar", 64, 0], ["Gold Nugget", 2, 5],
    ["RedGull", 1, 2], ["Water Bottle", 1, 3], ["Apple", 1, 2], ["Lockpick", 1, 4],
    ["Blood Bag", 3, 1], ["Bolt Cutter", 4, 1], ["Remote Explosive", 10, 1], ["Oil Barrel", 1, 2]];

switch (_mode) do {

    case "open": {if (isNull (findDisplay 515400)) then { createDialog "PLB_Inv"; };
        private _d = uiNamespace getVariable ["PLB_Inv", displayNull];
        if (isNull _d) exitWith {};
        uiNamespace setVariable ["PLB_InvItems", _items];

        (_d displayCtrl 515401) ctrlSetStructuredText parseText "YOUR POCKETS";
        (_d displayCtrl 515402) ctrlSetStructuredText parseText "What you're holding";
        (_d displayCtrl 515411) ctrlSetStructuredText parseText "<t align='right'>12 / 64</t>";

        private _grp = _d displayCtrl 515420;
        private _bgs = []; {_x params ["_nm", "_wt", "_q"];
            private _i = _forEachIndex;
            private _yy = _i * 0.053;

            private _bg = _d ctrlCreate ["PLB_InvRowBg", -1, _grp];
            _bg ctrlSetPosition [0, _yy, 0.385, 0.05]; _bg ctrlCommit 0; _bgs pushBack _bg;

            private _nc = _d ctrlCreate ["PLB_InvRowName", -1, _grp];
            _nc ctrlSetStructuredText parseText _nm; _nc ctrlSetPosition [0.016, _yy + 0.011, 0.22, 0.03]; _nc ctrlCommit 0;

            private _qc = _d ctrlCreate ["PLB_InvRowQty", -1, _grp];
            _qc ctrlSetStructuredText parseText format ["x%1", _q]; _qc ctrlSetPosition [0.245, _yy + 0.011, 0.05, 0.03]; _qc ctrlCommit 0;

            private _wc = _d ctrlCreate ["PLB_InvRowWt", -1, _grp];
            _wc ctrlSetStructuredText parseText format ["%1 kg", _wt]; _wc ctrlSetPosition [0.30, _yy + 0.011, 0.078, 0.03]; _wc ctrlCommit 0;

            private _hit = _d ctrlCreate ["Life_RscButtonInvisible", -1, _grp];
            _hit ctrlSetPosition [0, _yy, 0.385, 0.05]; _hit ctrlCommit 0;
            _hit setVariable ["ridx", _i];
            _hit ctrlAddEventHandler ["ButtonClick", { ["sel", (_this select 0) getVariable ["ridx", 0]] call life_fnc_plbInvDemo; }];
        } forEach _items;
        uiNamespace setVariable ["PLB_InvRowBgs", _bgs];

        ["sel", 0] call life_fnc_plbInvDemo;};

    case "sel": {uiNamespace setVariable ["PLB_InvSel", _arg];
        { _x ctrlSetText (["images\ui\shop_row.paa", "images\ui\shop_row_sel.paa"] select (_forEachIndex isEqualTo _arg)); } forEach (uiNamespace getVariable ["PLB_InvRowBgs", []]);
    };

    case "use";
    case "give";
    case "drop": {private _sel = uiNamespace getVariable ["PLB_InvSel", 0];
        (uiNamespace getVariable ["PLB_InvItems", []]) param [_sel, ["item", 0, 0]] params ["_nm"];
        private _verb = switch (_mode) do { case "use": { "Used" }; case "give": { "Gave" }; default { "Dropped" } };
        ["neutral", format ["%1 %2", _verb, _nm], "", "Your Pockets"] call life_fnc_hudToast;};};
