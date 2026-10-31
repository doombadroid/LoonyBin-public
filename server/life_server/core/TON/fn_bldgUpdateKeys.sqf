/*
    TON_fnc_bldgUpdateKeys  (LooneyBin: apply a house keyholder change)
    2020 client args: [_bldg, _keyholders, player]   (fn_manageBldgKeys)
      _keyholders : the full updated list, each entry [uid, rank, name]. [] = locks changed (revoke all).
    Was a no-op stub (logged only) -> giving/removing/changing keys did nothing. Now stamp plb_house_keys
    on the building (global) -- the var fn_keyHolderStatus / the T-access check / the menu all read.
    NOTE: not persisted across relog yet (houses table has no keys column -- part of the house
    persistence rebuild). In-session only for now.
*/
params [["_bldg", objNull, [objNull]], ["_keyholders", [], [[]]], ["_player", objNull, [objNull]]];
if (isNull _bldg) exitWith {};
// owner 2026-07-24 SECURITY (audit): this is CfgRE allowedTargets=2 and had NO authorisation whatsoever --
// it never resolved the caller and never checked the caller owns _bldg (the owner gate lived only in the
// client, fn_manageBldgKeys). Since houses are ordinary world objects and plb_houseID/plb_homeOwner are
// broadcast globally, any client could pass ANOTHER player's house and write its keyholder list: grant
// itself a key (-> the house-storage access checks then pass, so the whole stash is lootable), or pass []
// to wipe the real owner's keyholders as grief. The write persists to houses.keyholders, so it survives
// a restart. Require the NON-SPOOFABLE caller to be the OWNER -- deliberately not owner-OR-keyholder (the
// idiom in fn_barrelSRV:75), because a keyholder must not be able to hand out further keys.
// server-internal (_src == 0) passes. Top-level exitWith, not nested in a then{}.
private _src = remoteExecutedOwner;   // 0 == server-internal = trusted
private _caller = if (_src isEqualTo 0) then { objNull } else { (allPlayers select { owner _x isEqualTo _src }) param [0, objNull] };
if (_src isNotEqualTo 0 && {isNull _caller || {(_bldg getVariable ["plb_homeOwner", ""]) isNotEqualTo (getPlayerUID _caller)}}) exitWith {
    ["-SEC-", _caller, format ["BLOCKED bldgUpdateKeys on house %1 (caller %2 is not the owner %3)",
        _bldg getVariable ["plb_houseID", -1], getPlayerUID _caller, _bldg getVariable ["plb_homeOwner", "?"]]] call PLB_fnc_logIt;};
private _oldKeys = _bldg getVariable ["plb_house_keys", []];
_bldg setVariable ["plb_house_keys", _keyholders, true];
// persist keyholders (mres-encoded; SQL-escape single quotes since names can contain apostrophes)
private _oid = _bldg getVariable ["plb_houseID", -1];
if !(_oid isEqualTo -1) then {if !(_oid isEqualType "") then { _oid = str _oid; };
    private _enc = (([_keyholders] call DB_fnc_mresArray) splitString "'") joinString "''";
    [format ["UPDATE houses SET keyholders='%1' WHERE oid='%2'", _enc, _oid]] call DB_fnc_asyncQuery;};
// LooneyBin (owner 2026-06-15): log every key ADD/DROP. houses.keyholders is only a *current* snapshot,
// so the shed-access forensics can't tell who held a key *at the time* of an open (e.g. player100/player099-alt).
// This builds a permanent -HOUSEKEY- audit trail in the `log` table for exactly that cross-reference.
private _oldU = _oldKeys     apply { _x param [0, ""] };
private _newU = _keyholders  apply { _x param [0, ""] };
private _added   = _keyholders select { !((_x param [0, ""]) in _oldU) };
private _removed = _oldKeys    select { !((_x param [0, ""]) in _newU) };
if ((count _added) + (count _removed) > 0) then {
    private _fmt = { (_this apply { format ["%1(%2)", _x param [2, "?"], _x param [0, "?"]] }) joinString ", " };
    ["-HOUSEKEY-", _player, name _player,
        format ["house key change (HouseID: %1 | Owner: %2). ADDED: [%3] | REMOVED: [%4] | NewHolders: %5",
            _oid, _bldg getVariable ["plb_homeOwner", "?"], _added call _fmt, _removed call _fmt, _keyholders]] call TON_fnc_logIt;};
