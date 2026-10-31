/*
    life_fnc_loonazonOpen  (LooneyBin, owner 2026-07-16) -- open a Loonazon delivery box with the HOUSE-STORAGE
    trunk menu (virtual + physical tabs). LEAN fork of fn_openInventory: the box is a transient prop with its
    stock in plb_vinv/plb_pinv (the house list format -- weight-capped, holds bulk like 200 rifles, no native
    cargo container needed, keeps the paper-box model). Skips everything house-specific in the full opener --
    the DB hydrate (TON_fnc_initHouseInventory), the close-persist (updateHouseTrunk), tax, cop-seize -- because
    the box lives and dies in-session. The existing take/store/move/drop fns run UNCHANGED: they operate on
    life_trunk_vehicle's plb_vinv/plb_pinv and their caps read plb_vcap/plb_phys_cap straight off the object,
    which the server sets at delivery. The 4518 tab switch is a plain life_is_virtual toggle (no House_F gate),
    and refreshInventory only blocks the physical tab for Car/Air/Ship -- a Land_ prop passes.
*/
#include "..\..\macro.h"
disableSerialization;
params [["_crate", objNull, [objNull]]];
if (isNull _crate) exitWith {};
if !(isNull (findDisplay 4500)) exitWith {};
if !(isNull (findDisplay 3000)) exitWith {};
if ((_crate getVariable ["plb_packageOwner", ""]) isNotEqualTo (getPlayerUID player)) exitWith {
    ["That box has someone else's name on it.", "basic"] spawn life_fnc_handleMessage;};
if (_crate getVariable ["plb_carrying", false]) exitWith { ["Set the box down first.", "basic"] spawn life_fnc_handleMessage; };
if ((player distance _crate) > 6) exitWith { ["You are too far from the box.", "basic"] spawn life_fnc_handleMessage; };
if (player getVariable ["plb_restrained", false] || {player getVariable ["plb_downed", false]}) exitWith {};
if (isNil { (_crate getVariable ["plb_vinv", [[], 0]]) select 1 } || {isNil { (_crate getVariable ["plb_pinv", [[], 0]]) select 1 }}) exitWith {
    ["Could not load the box's inventory. Try again.", "basic"] spawn life_fnc_handleMessage;};

// single-user gate (same var the trunk system uses everywhere)
private _activeTrunk = _crate getVariable ["plb_activeTrunk", objNull];
if ((_activeTrunk isNotEqualTo objNull) && (_activeTrunk isNotEqualTo player)) exitWith {
    ["Someone is already in this box.", "basic"] spawn life_fnc_handleMessage;};
_crate setVariable ["plb_activeTrunk", player, true];
life_trunk_vehicle = _crate;

while { dialog } do { closeDialog 0 };
["TrunkMenu"] call life_fnc_createDialog;

// box view: both tabs live, TAKE-ONLY -- store button + qty + the move gutter (which can push player items in)
// all dead; fn_storeInventory has a matching hard guard. 4523 (house<->vehicle bulk) hidden -- house-only path.
life_is_virtual = true;
((findDisplay 4500) displayCtrl 4518) ctrlSetText "Switch to Physical Inventory";
((findDisplay 4500) displayCtrl 4518) ctrlShow true;
((findDisplay 4500) displayCtrl 4507) ctrlSetText "Take";
((findDisplay 4500) displayCtrl 4507) ctrlEnable true;
((findDisplay 4500) displayCtrl 4508) ctrlEnable false;
((findDisplay 4500) displayCtrl 4506) ctrlEnable false;
((findDisplay 4500) displayCtrl 4519) ctrlEnable false;
((findDisplay 4500) displayCtrl 4520) ctrlEnable false;
((findDisplay 4500) displayCtrl 4521) ctrlEnable true;
((findDisplay 4500) displayCtrl 4522) ctrlEnable false;
((findDisplay 4500) displayCtrl 4523) ctrlShow false;
((findDisplay 4500) displayCtrl 4509) ctrlShow false;    // SWAP trades a player item INTO the box -- take-only, hide it
((findDisplay 4500) displayCtrl 4509) ctrlEnable false;
ctrlSetText [4501, "Loonazon Box"];
private _vData = _crate getVariable ["plb_vinv", [[], 0]];
ctrlSetText [4504, format ["Weight: %1/%2", _vData select 1, _crate getVariable ["plb_vcap", 100]]];

// in-dialog monitor (fork of the fn_openInventory one, house paths dropped)
[_crate] spawn {params ["_crate"];
    while { !(isNull (findDisplay 4500)) } do {uiSleep 0.25;
        // the 4518 tab switch re-shows the SWAP button (baked into its onButtonClick) -- keep it dead (take-only)
        ((findDisplay 4500) displayCtrl 4509) ctrlShow false;
        ((findDisplay 4500) displayCtrl 4508) ctrlEnable false;
        ((findDisplay 4500) displayCtrl 4519) ctrlEnable false;
        ((findDisplay 4500) displayCtrl 4520) ctrlEnable false;
        if (isNull _crate) exitWith { while { dialog } do { closeDialog 0 }; };
        if (_crate getVariable ["plb_carrying", false]) exitWith { while { dialog } do { closeDialog 0 }; };
        if ((player distance _crate) > 8) exitWith { while { dialog } do { closeDialog 0 }; };
        if ((_crate getVariable ["plb_activeTrunk", objNull] isNotEqualTo player) && (_crate getVariable ["plb_activeTrunk", objNull] isNotEqualTo objNull)) exitWith {
            while { dialog } do { closeDialog 0 };};
        if (player getVariable ["plb_restrained", false]) exitWith { while { dialog } do { closeDialog 0 }; };
        if (player getVariable ["plb_downed", false]) exitWith { while { dialog } do { closeDialog 0 }; };
        if !(isNull (findDisplay 49)) exitWith { closeDialog 0; };};};

[["-LOONAZON-", player, (profileName), format ["opened box menu. Virtual: %1, Physical: %2", _crate getVariable ["plb_vinv", [[], 0]], _crate getVariable ["plb_pinv", [[], 0]]]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
[_crate, life_is_virtual] call life_fnc_refreshInventory;
player playActionNow "Gear";

// close handler: release the gate, save gear if we touched it, re-broadcast if the move-gutter mutated locally
// (fn_moveItemInventory writes plb_vinv/pinv WITHOUT the public flag + sets life_movedItem, exactly like houses).
[_crate] spawn {params ["_crate"];
    waitUntil { isNull (findDisplay 4500) };
    if (!isNull _crate) then { _crate setVariable ["plb_activeTrunk", nil, true]; };
    life_action_in_use = false;
    if (life_inventoryInteraction) then {[true] call life_fnc_saveGear;
        life_inventoryInteraction = false;};
    if (life_movedItem && {!isNull _crate}) then {_crate setVariable ["plb_vinv", (_crate getVariable ["plb_vinv", [[], 0]]), true];
        _crate setVariable ["plb_pinv", (_crate getVariable ["plb_pinv", [[], 0]]), true];
        life_movedItem = false;};
    life_trunk_vehicle = objNull;};
