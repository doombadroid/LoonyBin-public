/*
    fn_ndResult.sqf  (life_fnc_ndResult)  — New Drachma debit result + purchase continuation.
    The server ran the atomic SQL debit; this pops the pending token and, on success, runs the grant
    continuation the shop stashed (item/vehicle/clothes/loadout). Balance is always synced to the exact
    server value first. Called via life_fnc_MP from TON_fnc_ndSRV.
      [ ok(bool), "<newBalanceStr>", "<token>" ]
*/
params [["_ok", false, [false]], ["_newStr", "", [""]], ["_tok", "", [""]]];
if (_newStr isNotEqualTo "") then {life_ndStr = _newStr;
    life_nd = parseNumber _newStr;
    life_ndCacheB = ((life_nd / 4) + 5);
    if (!isNull (findDisplay 341000)) then { [] call life_fnc_money; };};
// publish the result for any blocking waiter (PLB_fnc_ndBuySync) BEFORE the continuation check --
// sync tokens carry no continuation, so they'd otherwise fall out at the pending-empty exit below.
if (isNil "PLB_ndResults") then { PLB_ndResults = createHashMap; };
PLB_ndResults set [_tok, [_ok, _newStr]];
private _pending = PLB_ndPending getOrDefault [_tok, []];
if (_pending isEqualTo []) exitWith {};        // unknown/expired token -> nothing to do (balance already synced)
PLB_ndPending deleteAt _tok;
_pending params [["_onOk", {}, [{}]], ["_ctx", [], [[]]], ["_t0", 0, [0]]];
life_action_in_use = false;
if (_ok) then {_ctx call _onOk;} else {
    [format ["Insufficient New Drachma. You have <t color='#ef3139'>%1 ND</t>.", [life_ndStr] call PLB_fnc_ndText], "basic"] spawn life_fnc_handleMessage;
};
