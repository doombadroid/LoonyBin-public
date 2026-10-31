#include "..\..\macro.h"
/*
    life_fnc_vehicleToHouseStore  (owner 2026-07-06) -- REVERSE of houseToVehicleStore. From an OPEN vehicle trunk,
    bulk-move the HIGHLIGHTED virtual item into the nearest HOUSE you have access to, within 25m. Progress bar,
    10 units/sec, capped by the house's plb_vcap.

    House storage is the most data-loss-prone subsystem here, so this reuses the EXACT proven machinery instead of a
    new write path: it HYDRATES the target house (TON_fnc_initHouseInventory, same as fn_openInventory's open),
    mutates the live plb_vinv, then PERSISTS via TON_fnc_updateHouseTrunk with the session gen + trunkLock settle
    (same as fn_openInventory's close). The house is trunkLocked for the whole run so no one can open it mid-deposit
    (which would bump the gen and get our persist stale-skipped). Vehicle side = broadcast plb_vinv (world-save).
    Dispatched from the trunk button (idc 4523) when the open container is a vehicle (see fn_houseToVehicleStore).
*/
disableSerialization;
if (missionNamespace getVariable ["plb_bulkStore", false]) exitWith { ["You're already moving items.", "basic"] spawn life_fnc_handleMessage; };
private _veh = life_trunk_vehicle;
if (isNull _veh || {_veh isKindOf "House_F"} || {!(_veh isKindOf "Car" || _veh isKindOf "Air" || _veh isKindOf "Ship")}) exitWith { ["Open a vehicle's trunk to do this.", "basic"] spawn life_fnc_handleMessage; };
if !(life_is_virtual) exitWith { ["Switch to the Virtual Inventory to bulk-store into a house.", "basic"] spawn life_fnc_handleMessage; };
if (isNull (findDisplay 4500)) exitWith {};

// highlighted vehicle item (trunk listbox 4502)
private _selIdx = lbCurSel 4502;
if (_selIdx < 0) exitWith { ["Highlight the item you want to store first.", "basic"] spawn life_fnc_handleMessage; };
private _selCls = lbData [4502, _selIdx];
if (_selCls isEqualTo "") exitWith { ["Highlight the item you want to store first.", "basic"] spawn life_fnc_handleMessage; };

// items a house physically can't hold (mirror fn_storeInventory's house gates)
if (_selCls in ["goldbar", "bank_money", "crank", "crankp", "uraniumu"]) exitWith { ["You can't store that in a house.", "basic"] spawn life_fnc_handleMessage; };
if (_selCls in ["jewelHope", "jewelRolex", "jewelAP", "jewelDiamonds", "jewelGoldBag", "jewelExoJewels", "jewelRing", "jewelBling", "jewelBag"]) exitWith { ["The African Warlord's henchmen won't let you store that in a house.", "basic"] spawn life_fnc_handleMessage; };

// nearest ACCESSIBLE house within 25m (owner / keyholder / gangmate -- mirror fn_openInventory's access model), free
private _uid = getPlayerUID player;
private _myGang = life_gang_data param [0, -1];
private _house = objNull; {private _cand = _x;
    private _owner = _cand getVariable ["plb_homeOwner", ""];
    private _isOwner = (_owner isEqualType "") && {_owner != ""} && {_owner != "NoPidVar"} && {_uid isEqualTo _owner};
    private _isKey  = ([_cand, _uid, "accessInv"] call life_fnc_keyHolderStatus) isEqualTo true;
    private _hGang  = _cand getVariable ["plb_house_gang", -1];
    private _isGang = (_hGang isEqualType 0) && {_hGang > 0} && {_myGang isEqualType 0} && {_hGang isEqualTo _myGang};
    if ((_isOwner || _isKey || _isGang)
        && {!(_cand getVariable ["plb_trunkLock", false])}
        && {(_cand getVariable ["plb_activeTrunk", objNull]) isEqualTo objNull}
        && {(_cand getVariable ["plb_house_tax", [false]]) select 0 isEqualTo false}) exitWith { _house = _cand; };
} forEach (nearestObjects [player, ["House_F"], 25]);
if (isNull _house) exitWith { ["No house you have access to is within 25m (or it's in use / tax overdue).", "basic"] spawn life_fnc_handleMessage; };

// how much of the highlighted item is in the vehicle?
private _vInv0 = +((_veh getVariable ["plb_vinv", [[], 0]]) select 0);
private _vi0 = _vInv0 findIf { (_x param [0, ""]) isEqualTo _selCls };
private _haveInVeh = if (_vi0 < 0) then { 0 } else { (_vInv0 select _vi0) param [1, 0] };
if (_haveInVeh < 1) exitWith { ["That item isn't in this vehicle.", "basic"] spawn life_fnc_handleMessage; };

// ---- reserve + HYDRATE the target house (mirror fn_openInventory open-hydrate) ----
missionNamespace setVariable ["plb_bulkStore", true];
life_action_in_use = true;
_house setVariable ["plb_trunkLock", true, true];        // block anyone opening it mid-deposit (gen safety)
_house setVariable ["plb_activeTrunk", player, true];
{ if (!isNull (findDisplay 4500)) then { ((findDisplay 4500) displayCtrl _x) ctrlEnable false; }; } forEach [4507, 4508, 4519, 4520, 4521, 4518, 4523];   // lock the vehicle trunk buttons

private _fnRelease = {
    if (!isNull _house) then { _house setVariable ["plb_trunkLock", false, true]; _house setVariable ["plb_activeTrunk", nil, true]; };
    missionNamespace setVariable ["plb_bulkStore", false];
    life_action_in_use = false;
    { if (!isNull (findDisplay 4500)) then { ((findDisplay 4500) displayCtrl _x) ctrlEnable true; }; } forEach [4507, 4508, 4519, 4520, 4521, 4518, 4523];
};

_house setVariable ["plb_vinv", nil];
_house setVariable ["plb_pinv", nil];
[[_house, _house getVariable ["plb_houseID", -1]], "TON_fnc_initHouseInventory", 2] call life_fnc_MP;
private _exitTime = time + 6;
waitUntil { uiSleep 0.1; time > _exitTime || (!isNil { _house getVariable "plb_vinv" } && !isNil { _house getVariable "plb_pinv" }) };
if (isNil { _house getVariable "plb_vinv" } || {isNil { _house getVariable "plb_pinv" }}) exitWith {call _fnRelease;
    ["Couldn't load the house storage -- try again.", "basic"] spawn life_fnc_handleMessage;};
private _gen = _house getVariable ["plb_invGen", 0];

private _fnWeight = { params ["_arr"]; private _w = 0; { _w = _w + ((_x select 1) * (["getItemWeight", _x select 0] call life_fnc_virtItemCfg)); } forEach _arr; _w; };

// house live copies
private _hLive = +((_house getVariable ["plb_vinv", [[], 0]]) select 0);
private _hPinv = +(_house getVariable ["plb_pinv", [[], 0]]);
private _hcap  = _house getVariable ["plb_vcap", 100];
if (_hcap <= 0) then { _hcap = 100; };

// how many units fit (weight cap; uraniump also capped to 50 without a lead container)
private _w1 = ["getItemWeight", _selCls] call life_fnc_virtItemCfg;
private _room = _hcap - ([_hLive] call _fnWeight);
private _fit = if (_w1 <= 0) then { _haveInVeh } else { floor (_room / _w1) };
_fit = _fit min _haveInVeh;
if (_selCls isEqualTo "uraniump" && {!(_house getVariable ["plb_leadcontainer_unaged", false])}) then {
    private _hi2 = _hLive findIf { (_x param [0, ""]) isEqualTo "uraniump" };
    private _hu = if (_hi2 < 0) then { 0 } else { (_hLive select _hi2) param [1, 0] };
    _fit = _fit min (50 - _hu);};
if (_fit < 1) exitWith {call _fnRelease;
    ["That house is full (or can't hold more of that item).", "basic"] spawn life_fnc_handleMessage;};

// ---- deposit loop: 10 units/sec, vehicle -> house (both broadcast each tick) ----
5 cutRsc ["life_progress", "PLAIN"];
private _ui = uiNamespace getVariable "life_progress";
private _pg = _ui displayCtrl 38201;
private _pgT = _ui displayCtrl 38202;
_pg progressSetPosition 0.01;

private _hPos = getPosATL _house;
private _moved = 0;
private _itemName = ["getName", _selCls] call life_fnc_virtItemCfg;

for "_loop" from 0 to 1 step 0 do {if (isNull (findDisplay 4500)) exitWith {};                       // vehicle trunk closed
    if (life_trunk_vehicle isNotEqualTo _veh) exitWith {};
    if (isNull _veh || {!alive _veh}) exitWith {};
    if (isNull _house || {(player distance _house) > 25}) exitWith {}; // walked away from the house
    if (player getVariable ["plb_restrained", false] || {player getVariable ["plb_downed", false]}) exitWith {};

    // how many can we still take from the vehicle this run?
    private _vCur = +((_veh getVariable ["plb_vinv", [[], 0]]) select 0);
    private _vi = _vCur findIf { (_x param [0, ""]) isEqualTo _selCls };
    private _vHave = if (_vi < 0) then { 0 } else { (_vCur select _vi) param [1, 0] };
    private _n = (10 min (_fit - _moved)) min _vHave;
    if (_n < 1) exitWith {};

    // remove _n from the vehicle
    private _rem = _vHave - _n;
    if (_rem > 0) then { _vCur set [_vi, [_selCls, _rem]]; } else { _vCur deleteAt _vi; };
    _veh setVariable ["plb_vinv", [_vCur, [_vCur] call _fnWeight], true];

    // add _n to the house (live copy) + broadcast
    private _hi = _hLive findIf { (_x param [0, ""]) isEqualTo _selCls };
    if (_hi < 0) then { _hLive pushBack [_selCls, _n]; } else { _hLive set [_hi, [_selCls, ((_hLive select _hi) param [1, 0]) + _n]]; };
    _house setVariable ["plb_vinv", [_hLive, [_hLive] call _fnWeight], true];

    _moved = _moved + _n;
    _pg progressSetPosition ((_moved / _fit) min 1);
    _pgT ctrlSetText format ["Storing %1 %2 into the house (%3%4)...", _moved, _itemName, round (((_moved / _fit) min 1) * 100), "%"];

    if (_moved >= _fit) exitWith {};
    uiSleep 1;};

5 cutText ["", "PLAIN"];
[true] call life_fnc_saveGear;

// ---- persist the house (mirror fn_openInventory close): trunkLock stays up through the settle, then updateHouseTrunk ----
private _finalVinv = [_hLive, [_hLive] call _fnWeight];
[player, _house, _finalVinv, _hPinv, _gen, _veh] spawn {params ["_pl", "_obj", "_v", "_p", "_g", "_vh"];
    uiSleep 1.25;                                                    // let the setVariable broadcasts settle
    [[_pl, _obj, _v, _p, _g], "TON_fnc_updateHouseTrunk", false, false] spawn life_fnc_MP;   // persists + dehydrates
    uiSleep 0.75;
    if (!isNull _obj) then { _obj setVariable ["plb_trunkLock", false, true]; _obj setVariable ["plb_activeTrunk", nil, true]; };
    missionNamespace setVariable ["plb_bulkStore", false];
    life_action_in_use = false;
    { if (!isNull (findDisplay 4500)) then { ((findDisplay 4500) displayCtrl _x) ctrlEnable true; }; } forEach [4507, 4508, 4519, 4520, 4521, 4518, 4523];
};

[["-HOUSEINV-", player, profileName, format ["bulk-stored %1 %2 from vehicle %3 into house (ID: %4). POS: %5", _moved, _selCls, typeOf _veh, _house getVariable ["plb_houseID", -1], getPosATL player]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
titleText [format ["Stored %1 %2 into your house.", _moved, _itemName], "PLAIN"];
