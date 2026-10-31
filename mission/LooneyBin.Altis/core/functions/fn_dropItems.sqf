params[["_unit", objNull, [objNull]]];
if (isNull _unit || playerSide isEqualTo west || playerSide isEqualTo independent) exitWith {};
private _pos =
if (isNull objectParent _unit) then {getPosASL _unit;} else {private _tempPos = (vehicle _unit) modelToWorldWorld[0, -8, 0];
    _tempPos set[2, 0];
    AGLToASL _tempPos;};
private _hackDetected = false;
if (playerSide isEqualTo civilian) then {private _totalItemsActual = 0; {
        _totalItemsActual = _totalItemsActual + (missionNameSpace getVariable [_x, 0]);}
    forEach life_invMonVars;
    if (_totalItemsActual > (life_invMonitor - life_invRVar) || _totalItemsActual >= 130) exitWith {_hackDetected = true;
        private _hackedItemArray = []; {if ((missionNameSpace getVariable [_x, 0]) > 0) then {
                _hackedItemArray pushBack[_x, (missionNameSpace getVariable [_x, 0])];};}
        forEach life_invMonVars; [
            [player, [3, (life_invMonitor - life_invRVar), _totalItemsActual, str _hackedItemArray]], "TON_fnc_dongClient", 2] call life_fnc_MP;
        [] spawn {uiSleep 2;
            diag_log "[LooneyBin] MemHackCash AC neutered (no kick)";};
        // BUGS.md #79/#80: same item-count monitor as fn_handleInv -- log + resync, don't block the drop
        life_invMonitor = _totalItemsActual + life_invRVar;
        _hackDetected = false;};};
if (_hackDetected) exitWith {};
private _items = [];
private["_item", "_value", "_shortName"]; {_item = _x;
    _value = missionNamespace getVariable [_item, 0];
    if (_value > 0) then {_shortName = ["getShortName", _item] call life_fnc_virtItemCfg;
        if !(_shortName in ["debitcard", "firstAidKit", "giftAdmin", "giftHallo", "giftXmas"]) then {
            _items pushBackUnique[_shortName, _value];
            missionNamespace setVariable[_x, 0];};};}
forEach([1] call life_fnc_virtItemCfg);
if (life_cash > 0) then {_items pushBack["money", life_cash]; [
        ["-CASHDROPPED-", player, (profileName), format["dropped $%1 at POS: %2", [life_cash] call life_fnc_numberText, getPosATL player]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
    if (playerSide isEqualTo civilian && {A_stats_civTime < 300 && life_cash >= 74999}) then {[
            ["-MONEYWARNING-", player, profileName, format["dropped $%1 on death. Civ time: %2 minutes | Bank: $%3 | Position: %4 | Experience: %5.", [life_cash] call life_fnc_numberText, A_stats_civTime, [life_atmCash] call life_fnc_numberText, getPosATL player, [life_side_exp] call life_fnc_numberText]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
    };};
life_cash = 0;
life_cashCacheB = ((life_cash / 4) + 9);
[0] call life_fnc_ClupdatePartial;
if !(_items isEqualTo[]) then {[[_items, _pos, "Land_Suitcase_F", []], "TON_fnc_createItem", 2] spawn life_fnc_MP;};