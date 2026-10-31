/*
    TON_fnc_wantedSyncList  (LooneyBin) -- runs on the SERVER.
    The OFFENDER's client (life_fnc_wantedListAdd) is the single source of truth for wanted level:
    A_stats_crimes = [totalBounty, count_of_crime_1, count_of_crime_2, ...]. It pushes that state here on
    every change + on load; we rebuild the cop-facing life_wanted_list entry from it so the Wanted menu AND
    the payout (TON_fnc_wantedBounty reads entry index 3) match the REAL wanted amount. Args: [uid,name,crimes].
*/
params [["_uid", "", [""]], ["_name", "", [""]], ["_crimes", [], [[]]]];
if (_uid isEqualTo "") exitWith {};
// owner 2026-07-24 SECURITY (audit): CfgRE allowedTargets=2 with no caller derivation, so the uid/name/
// crimes were whatever the caller claimed. That made this the unlocked back door around the hardened
// TON_fnc_wantedAdd: any client could rebuild ANY player's life_wanted_list entry -- zero out its own
// bounty to clear its wanted level, or fabricate a huge bounty on someone else. Entry index 3 is the cash
// the arrest payout reads (TON_fnc_wantedBounty), so a forged entry is also a payout exploit.
// The DESIGN is that the offender's own client is the source of truth for its wanted state (see header),
// so the fix keeps that exactly and only removes the impersonation: for a remote call the identity is
// forced to the calling machine, never the claimed one. server-internal (_src == 0) is unchanged.
private _src = remoteExecutedOwner;   // 0 == server-internal = trusted
if (_src isNotEqualTo 0) then {private _caller = (allPlayers select { owner _x isEqualTo _src }) param [0, objNull];
    if (isNull _caller) then {
        _uid = "";   // unattributable -> the top-level guard below drops it (nested exitWith would only leave this block)
    } else {private _realUid = getPlayerUID _caller;
        if (_realUid isNotEqualTo _uid) then {
            ["-SEC-", _caller, format ["BLOCKED wantedSyncList impersonation: claimed %1, really %2", _uid, _realUid]] call PLB_fnc_logIt;
        };
        _uid  = _realUid;
        _name = name _caller;};};
if (_uid isEqualTo "") exitWith {};
if (isNil "life_wanted_list") then { life_wanted_list = []; };
private _bounty = round (_crimes param [0, 0]);
private _flat = [];
private _jail = 0;
for "_i" from 1 to ((count _crimes) - 1) do {private _cnt = round (_crimes select _i);
    if (_cnt > 0) then {for "_j" from 1 to _cnt do { _flat pushBack _i; };
        private _row = ["getRow", _i] call TON_fnc_wantedChargesConfig;
        _jail = _jail + ((_row param [3, 0]) * _cnt);};};
private _idx = life_wanted_list findIf { (_x param [1, ""]) isEqualTo _uid };
if (_bounty <= 0) then {if (_idx != -1) then { life_wanted_list deleteAt _idx; };} else {
    private _entry = [_name, _uid, _flat, _bounty, _jail];
    if (_idx != -1) then { life_wanted_list set [_idx, _entry]; } else { life_wanted_list pushBack _entry; };};
