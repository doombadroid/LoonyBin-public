// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only
/*
    File: fn_ringLoadoutAssign.sqf  (life_fnc_ringLoadoutAssign)
    Put the highlighted AVAILABLE tool into the highlighted slot. If that tool is already equipped
    elsewhere the two slots SWAP, so a loadout can never hold the same tool twice.
*/
private _d = findDisplay 941400;
if (isNull _d) exitWith {};
// firewall mode: assign into one of the 2 chip slots instead
if ((missionNamespace getVariable ["PLB_ringLoadMode", 0]) isEqualTo 1) exitWith {private _av = _d displayCtrl 941411;
    private _s = lbCurSel _av;
    if (_s < 0) exitWith { ["Pick a chip first.", "basic"] spawn life_fnc_handleMessage; };
    private _cid = _av lbData _s;
    private _slot = (missionNamespace getVariable ["PLB_ringLoadSel", 0]) min 1;
    while { count PLB_fwWork < 2 } do { PLB_fwWork pushBack "" };
    private _other = PLB_fwWork find _cid;
    if (_other > -1) then { PLB_fwWork set [_other, PLB_fwWork select _slot]; };
    PLB_fwWork set [_slot, _cid];
    [PLB_fwWork select { _x isNotEqualTo "" }] call PLB_fnc_fwSave;
    call life_fnc_ringLoadoutRefresh;
    ["Firewall updated.", "basic"] spawn life_fnc_handleMessage;};
private _av = _d displayCtrl 941411;
private _sel = lbCurSel _av;
if (_sel < 0) exitWith { ["Pick a tool from the AVAILABLE list first.", "basic"] spawn life_fnc_handleMessage; };
private _id = _av lbData _sel;
if (_id isEqualTo "") exitWith {};
private _slot = PLB_ringLoadSel min 4;
private _cur = PLB_ringLoadWork select _slot;
if (_cur isEqualTo _id) exitWith {};
private _other = PLB_ringLoadWork find _id;
if (_other > -1) then { PLB_ringLoadWork set [_other, _cur]; };   // swap instead of duplicating
PLB_ringLoadWork set [_slot, _id];
[PLB_ringLoadWork] call PLB_fnc_ringSaveLoadout;
call life_fnc_ringLoadoutRefresh;
[format ["<t color='#c9e21a'>SLOT %1</t> -- %2 equipped.", _slot + 1, PLB_ringNames getOrDefault [_id, _id]], "basic"] spawn life_fnc_handleMessage;
