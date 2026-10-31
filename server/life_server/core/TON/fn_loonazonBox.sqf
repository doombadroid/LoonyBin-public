/*
    TON_fnc_loonazonBox  (LooneyBin, owner 2026-07-16) -- spawn a Loonazon delivery box seeded with an ORDER CART.
    Shared by the normal delivery AND the robbery break-open (the robber becomes the box's owner -- the same
    owner-gated open/carry actions then just work for whoever claimed it). House-storage format: virtual stock
    in plb_vinv, physical (weapons/mags/gear, +2 default mags per weapon) in plb_pinv; opened take-only via
    life_fnc_loonazonOpen.

    [_pos, _uid, _cart]   _cart = [[class, qty], ...]  ->  the crate object
*/
params [["_pos", [0,0,0], [[]]], ["_uid", "", [""]], ["_cart", [], [[]]]];

// never on a road -- nudge off tarmac
private _boxPos = [_pos select 0, _pos select 1, 0];
if (isOnRoad _boxPos) then {for "_a" from 0 to 315 step 45 do {private _try = _pos getPos [4.5, _a];
        if (!(isOnRoad _try)) exitWith { _boxPos = [_try select 0, _try select 1, 0]; };};};
private _crate = createVehicle ["Land_PaperBox_01_small_closed_brown_F", _boxPos, [], 0, "CAN_COLLIDE"];
_crate setPosATL _boxPos;
_crate setVectorUp (surfaceNormal (getPosATL _crate));
_crate allowDamage false;
_crate setVariable ["owner", _uid, true];               // fn_cleanup spare (ownerless = instant reap)
_crate setVariable ["plb_packageOwner", _uid, true];

private _vList = []; private _pList = [];
private _fnMerge = { params ["_list", "_cls", "_qty"];
    private _i = _list findIf { (_x select 0) isEqualTo _cls };
    if (_i > -1) then { (_list select _i) set [1, ((_list select _i) select 1) + _qty]; } else { _list pushBack [_cls, _qty]; };}; {
    _x params [["_cls", "", [""]], ["_qty", 1, [0]]];
    if (_cls isNotEqualTo "" && {_qty > 0}) then {private _isMag = isClass (configFile >> "CfgMagazines" >> _cls);
        private _isBag = (isClass (configFile >> "CfgVehicles" >> _cls)) && {_cls isKindOf "Bag_Base"};
        private _isWpn = ((isClass (configFile >> "CfgWeapons" >> _cls)) || {isClass (configFile >> "CfgGlasses" >> _cls)}) && {!_isBag};
        if (_isWpn || _isMag || _isBag) then {[_pList, _cls, _qty] call _fnMerge;
            if (_isWpn) then {private _defMag = (getArray (configFile >> "CfgWeapons" >> _cls >> "magazines")) param [0, ""];
                if (_defMag isNotEqualTo "") then { [_pList, _defMag, 2 * _qty] call _fnMerge; };};} else {
            [_vList, _cls, _qty] call _fnMerge;};};} forEach _cart;

private _vw = 0;
{ _vw = _vw + ((["getItemWeight", _x select 0] call life_fnc_virtItemCfg) * (_x select 1)); } forEach _vList;
private _vinv = [_vList, _vw];
private _pinv = [_pList, _pList call life_fnc_physicalInventoryWeight];
_crate setVariable ["plb_vinv", _vinv, true];
_crate setVariable ["plb_pinv", _pinv, true];
_crate setVariable ["plb_vcap", (_vinv select 1) max 1, true];      // TAKE-ONLY: cap = delivered weight
_crate setVariable ["plb_phys_cap", (_pinv select 1) max 1, true];

// reaper: despawn when BOTH inventories are empty (and nobody's in the menu), or at 15 min
[_crate] spawn {params ["_c"];
    private _end = time + 900;
    waitUntil {uiSleep 8;
        (isNull _c) || {time > _end} || {((_c getVariable ["plb_vinv", [[], 0]]) select 0 isEqualTo [])
            && {(_c getVariable ["plb_pinv", [[], 0]]) select 0 isEqualTo []}
            && {isNull (_c getVariable ["plb_activeTrunk", objNull])}}};
    if (!isNull _c) then { deleteVehicle _c; };};
_crate
