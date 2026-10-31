/*
    File: fn_ndCreditSrv.sqf  (TON_fnc_ndCreditSrv)
    LooneyBin 2026-07-23: SERVER-INTERNAL trusted New Drachma credit. Used by systems that computed the
    amount themselves (mining rigs, and any future server-side payout). Deliberately NOT registered in
    CfgRE.hpp -> a client cannot remoteExec it (mode=1 whitelist blocks it), so there is no rate cap and
    no owner check to fool. Call it only via a direct server-side `call`.

      [_player, "<amtStr>", "<reason>"] call TON_fnc_ndCreditSrv;
*/
params [["_pl", objNull, [objNull]], ["_amt", "", [""]], ["_reason", "srv", [""]]];
if (!isServer) exitWith {};   // belt-and-suspenders: only ever runs on the server
if (isNull _pl) exitWith {};
if (!(_amt regexMatch "\d{1,14}(\.\d{1,4})?") || {_amt isEqualTo "0"}) exitWith {
    diag_log format ["[LooneyBin][ND] ndCreditSrv bad amount '%1' (%2)", _amt, _reason];};
private _uid = getPlayerUID _pl;
if !(_uid regexMatch "\d{17}") exitWith {};
if (isNil "PLB_ndLocks") then { PLB_ndLocks = createHashMap };
private _t0 = diag_tickTime;
waitUntil { !(PLB_ndLocks getOrDefault [_uid, false]) || {diag_tickTime - _t0 > 8} };
if (PLB_ndLocks getOrDefault [_uid, false]) exitWith { diag_log format ["[LooneyBin][ND] ndCreditSrv lock bail %1", _uid]; };
PLB_ndLocks set [_uid, true];
[format ["UPDATE players SET new_drachma = new_drachma + %1 WHERE playerid='%2'", _amt, _uid], 2] call DB_fnc_asyncQuery;
private _row = [format ["SELECT QUOTE(new_drachma) FROM players WHERE playerid='%1'", _uid], 2] call DB_fnc_asyncQuery;
PLB_ndLocks set [_uid, false];
private _new = "";
if (_row isEqualType [] && {(_row param [0, ""]) isEqualType ""}) then { _new = _row select 0; };
if (_new isEqualTo "") exitWith { diag_log format ["[LooneyBin][ND] ndCreditSrv reselect failed %1", _uid]; };
diag_log format ["[LooneyBin][ND] creditSrv +%1 (%2) -> %3 = %4", _amt, _reason, _uid, _new];
[[_new, _reason, _amt], "life_fnc_ndSync", _pl, false] spawn life_fnc_MP;
