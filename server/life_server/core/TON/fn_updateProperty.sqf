/*
    TON_fnc_updateProperty  (LooneyBin: apply a house upgrade)
    2020 client args : [_house, player, _mode, _value, _houseID]   (fn_upgradeProperty / fn_manageBldgKeys)
      _mode : "vstorage" | "pstorage" | "aging" | "greenhouse" | "leadcontainer" | "spareKey"
      _value: vstorage/pstorage -> the new capacity ; spareKey -> the CURRENT keycap (we +1) ; else -1
    Was a passthrough to the 2017 DB_fnc_updateHouse (params [oid,locked,worldspace]) -> wrong args ->
    upgrade never applied + the client's life_houseTxn/life_action_in_use locks never cleared (no
    completion callback exists in this build) -> "you already have an active transaction" forever.
    Now: stamp the matching plb_* var on the house (global) so the upgrade takes effect, then release the
    caller's locks via publicVariableClient (same proven path as fn_lagCheck / fn_garageCount).
    NOTE: not persisted across relog yet -- the houses table has no cap/upgrade columns (whole house
    persistence layer is a separate rebuild). In-session only for now.
*/
params [["_house", objNull, [objNull]], ["_player", objNull, [objNull]], ["_mode", "", [""]], ["_value", -1, [0]], ["_houseID", "", ["", 0]]];
if (isNull _house || isNull _player) exitWith {};

// owner 2026-06-23 SECURITY (security.md §2.1 MED — value amplifier): CfgRE-whitelisted -> a client could
// remoteExec [house, player, "vstorage", 2e9, oid] for UNLIMITED house storage (no owner check, _value used
// raw as the cap). (1) Derive the actor from the non-spoofable remoteExecutedOwner (model fn_seizeLock:22).
// (2) Verify they OWN the house (plb_homeOwner == callerUID) -- the exact client gate in fn_upgradeProperty.
// (3) CLAMP _value to the house's real config storage ceiling so even the owner can't inflate it. The cost is
// debited client-side; this fn only writes the cap, so clamping the cap is the authoritative control.
private _src = remoteExecutedOwner;
private _caller = if (_src isEqualTo 0) then { objNull } else { (allPlayers select { owner _x isEqualTo _src }) param [0, objNull] };
if (_src isNotEqualTo 0) then { _player = _caller; };
if (_src isNotEqualTo 0 && {isNull _caller || {(format ["%1", _house getVariable ["plb_homeOwner", ""]]) isNotEqualTo (getPlayerUID _caller)}}) exitWith {
    ["-SEC-", _caller, format ["BLOCKED updateProperty (not house owner) by %1", getPlayerUID _caller]] call PLB_fnc_logIt;
    if (!isNull _caller) then { life_houseTxn = false; (owner _caller) publicVariableClient "life_houseTxn"; life_action_in_use = false; (owner _caller) publicVariableClient "life_action_in_use"; };
};
// clamp the new storage/key cap to the house config max (vstorage/pstorage) or the global key cap (sparekey).
if (_src isNotEqualTo 0) then {private _cfg = [typeOf _house] call life_fnc_houseConfig;
    if (_cfg isEqualType [] && {count _cfg >= 4}) then {private _physInv = _cfg select 2; private _virtInv = _cfg select 3;
        private _maxV = if (_virtInv isEqualType [] && {_virtInv isNotEqualTo []}) then { (_virtInv select ((count _virtInv) - 1)) param [0, 0] } else { 0 };
        private _maxP = if (_physInv isEqualType [] && {_physInv isNotEqualTo []}) then { (_physInv select ((count _physInv) - 1)) param [0, 0] } else { 0 };
        switch (toLower _mode) do {case "vstorage": { _value = (_value max 0) min _maxV; };
            case "pstorage": { _value = (_value max 0) min _maxP; };
            case "sparekey": { _value = (_value max 0) min ((missionNamespace getVariable ["life_maxHouseKeys", 5]) - 1); };   // +1 applied below -> cap at maxKeys
            default {};};};};

// set the var (global) AND persist the matching houses column so the upgrade survives a restart
// owner 2026-06-23 SECURITY (security.md §2.3 — SQLi, _houseID only): the client _houseID flows into
// `WHERE oid='%2'` RAW. Per the coordination split, ONLY the _houseID SQL escape is done here (money/authz for
// this fn are handled separately -- not touched). Strip quotes/backslash from the oid before interpolation.
private _oid = if (_houseID isEqualType "") then { _houseID } else { str _houseID };
_oid = (format ["%1", _oid]) splitString "\'""" joinString "";
private _col = "";
switch (toLower _mode) do {
    case "vstorage":      { _house setVariable ["plb_vcap", _value, true];                _col = format ["vcap='%1'", _value]; };
    case "pstorage":      { _house setVariable ["plb_phys_cap", _value, true];            _col = format ["phys_cap='%1'", _value]; };
    case "aging":         { _house setVariable ["plb_barrel_unaged", true, true];         _col = "barrel='1'"; };
    case "greenhouse":    { _house setVariable ["plb_greenhouse_unaged", true, true];     _col = "greenhouse='1'"; };
    case "leadcontainer": { _house setVariable ["plb_leadcontainer_unaged", true, true]; _col = "leadcontainer='1'"; };
    case "sparekey":      { _house setVariable ["plb_keycap", _value + 1, true];          _col = format ["keycap='%1'", _value + 1]; };};
if (_col != "" && {_oid != "" && _oid != "-1"}) then {[format ["UPDATE houses SET %1 WHERE oid='%2'", _col, _oid]] call DB_fnc_asyncQuery;
};

// release the client's house-transaction locks (no dedicated completion callback exists in this build)
life_houseTxn = false;      (owner _player) publicVariableClient "life_houseTxn";
life_action_in_use = false; (owner _player) publicVariableClient "life_action_in_use";
