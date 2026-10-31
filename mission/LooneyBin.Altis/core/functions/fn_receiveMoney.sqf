params[["_to", objNull, [objNull]], ["_val", 0, [0]], ["_from", objNull, [objNull]]];
if ((isNull _to) || (isNull _from) || (_val <= 0)) exitWith {};
if (player != _to) exitWith {};
if (_to isEqualTo _from) exitWith {};
if (((remoteExecutedOwner isEqualTo clientOwner) || !isRemoteExecuted) && ((call life_adminLevel) <= 2)) exitWith {[
        [player, [75, [_val] call life_fnc_numberText, str(getPosATL player)]], "TON_fnc_dongClient", 2] call life_fnc_MP;};
if (_to distance2D _from > 40) exitWith {[[player, [76, [
            [_val] call life_fnc_numberText, name _from, getPlayerUID _from, _to distance2D _from, str(getPosATL _from), str(getPosATL player)] call life_fnc_numberText, str(getPosATL player)]], "TON_fnc_dongClient", 2] call life_fnc_MP;
};
if ((isNull _from) || !(_from in allPlayers)) exitWith {[
        [player, [77, [_val] call life_fnc_numberText, str(getPosATL player)]], "TON_fnc_dongClient", 2] call life_fnc_MP;};
if (_val > 9999999) exitWith {[
        [player, [78, [_val] call life_fnc_numberText, name _from, getPlayerUID _from, str(getPosATL player)]], "TON_fnc_dongClient", 2] call life_fnc_MP;
};
[format["%1 has given you $%2", (name _from), [_val] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
life_cash = life_cash + _val;
life_cashCacheB = ((life_cash / 4) + 9);
[0] call life_fnc_ClUpdatePartial; [
    ["-CASHRECEIVE-", player, (profileName), format["received $%1 cash from %2 (%3).", [_val] call life_fnc_numberText, (name _from), (getPlayerUID _from)]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
private _time = _from getVariable["plb_drugtrace", -1000];
if (time - _time < 400) then {systemChat "Druggies!"; [
        [getPlayerUID player, "plb_drugtrace", _time], "TON_fnc_varPersist", 2] spawn life_fnc_MP;
    [_time] spawn {params["_time"];
        waitUntil {uiSleep 1;
            (life_cash isEqualTo 0) || ((time - _time) > 400)};
        if (life_cash isEqualTo 0) then {[[getPlayerUID player, "plb_drugtrace", -1000], "TON_fnc_varPersist", 2] spawn life_fnc_MP;};};};