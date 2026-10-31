params[["_math", false, [false]], ["_item", "", [""]], ["_num", 0, [0]]];
if (_item isEqualTo "" || _num isEqualTo 0) exitWith {false};
private _var = format["life_inv_%1", _item];
if (_math) then {private _diff = [_item, _num, life_carryWeight, life_maxWeight] call life_fnc_calWeightDiff;
    _num = _diff;
    if (_num <= 0) exitWith {false};};
private _weight = (["getItemWeight", _item] call life_fnc_virtItemCfg) * _num;
// owner 2026-06-24 FIX: default 0. A DYNAMIC item whose counter was never boot-initialised (e.g. a named
// foreskin foreskin_<uid> registered AFTER boot -- the registry was empty at boot, so the case-0 init loop never
// set life_inv_foreskin_<uid>) returned nil here -> `nil + _num` errored -> the item silently failed to add
// ("harvested foreskin not in Y inventory"). Defaulting nil->0 makes the first add create the counter cleanly.
private _value = missionNamespace getVariable [_var, 0];
private _totalItemsActual = 0; {_totalItemsActual = _totalItemsActual + (missionNameSpace getVariable [_x, 0]);}
forEach life_invMonVars;
private _hackExit = false;
if (_totalItemsActual > (life_invMonitor - life_invRVar) || _totalItemsActual >= 130) then {_hackExit = true;
    private _hackedItemArray = [];
    private _count = 0; {if ((missionNameSpace getVariable [_x, 0]) > 0) then {
            _hackedItemArray pushBack[_x, (missionNameSpace getVariable [_x, 0])];
            _count = _count + (missionNamespace getVariable [_x, 0]);};}
    forEach life_invMonVars;
    if (_count <= (life_invMonitor - life_invRVar)) exitWith {_hackExit = false;}; [
        [player, [3, (life_invMonitor - life_invRVar), _totalItemsActual, str _hackedItemArray]], "TON_fnc_dongClient", 2] call life_fnc_MP;
    [] spawn {uiSleep 2;
        diag_log "[LooneyBin] MemHackCash AC neutered (no kick)";};
    // BUGS.md #79/#80: this item-count monitor (hard 130-item cap + drift tracker) hard-rejected adds
    // even with plenty of WEIGHT room -> "Mining done. You can't hold more minerals." at the quarries
    // with 100 free space. Weight (life_maxWeight) is the real inventory limit; log + resync, don't block.
    life_invMonitor = _totalItemsActual + life_invRVar;
    _hackExit = false;};
if (_hackExit) exitWith {false};
private "_return";
if (_math) then {if ((life_carryWeight + _weight) <= life_maxWeight) then {life_invMonitor = life_invMonitor + _num;
        missionNamespace setVariable[_var, (_value + _num)];
        if ((missionNamespace getVariable _var) > _value) then {life_carryWeight = life_carryWeight + _weight;
            _return = true;} else {_return = false;};} else {_return = false;};} else {if ((_value - _num) < 0) then {_return = false;
    } else {missionNamespace setVariable[_var, (_value - _num)];
        life_invMonitor = life_invMonitor - _num;
        if ((missionNamespace getVariable _var) < _value) then {life_carryWeight = life_carryWeight - _weight;
            _return = true;} else {_return = false;};};};
// LooneyBin: dupe-proofing write-through. On ANY real inventory change, persist gear+virtual-inv to
// the DB ~2s later (debounced to coalesce bursts like crafting/processing) via the canonical saveGear
// path -- the SAME one the periodic sync uses. Closes the relog/crash dupe window: the source-side
// decrement now persists as promptly as the trunk/storage/drop increment, so a stale reload can't
// leave the same item in both places. Window was up to one ClupdateRequest cycle / the 7min buffer
// flush. Session-gated so it can't fire mid-login while inventory is still being restored.
if (_return && {life_session_completed} && {isNil "life_invWriteThrough"}) then {life_invWriteThrough = true;
    [] spawn { uiSleep 2; [true] call life_fnc_saveGear; [6] call life_fnc_ClupdatePartial; life_invWriteThrough = nil; };  // [6]=cash+bank: inv+money ops are paired (buy/sell/process), so persist money alongside the gear to close the buy-dupe (cash back on relog while keeping the item).
};
_return;