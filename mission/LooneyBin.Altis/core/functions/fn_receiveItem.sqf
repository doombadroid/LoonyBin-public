params[["_unit", objNull, [objNull]], ["_val", 0, [0]], ["_item", "", [""]], ["_from", objNull, [objNull]]];
if (isNull _unit || isNull _from) exitWith {};
if !(_unit isEqualTo player) exitWith {};
private _diff = [_item, _val, life_carryWeight, life_maxWeight] call life_fnc_calWeightDiff;
private _type = ["getName", _item] call life_fnc_virtItemCfg;
if !(_diff isEqualTo _val) then {if ([true, _item, _diff] call life_fnc_handleInv) then {
        [format["%1 has given you %2 %3 but you can only hold %4, so %5 was returned back.", [name _from] call life_fnc_cleanName, _val, _type, _diff, _val - _diff], "basic"] spawn life_fnc_handleMessage;
        [[_from, _item, _val - _diff, _unit], "life_fnc_giveDiff", _from] spawn life_fnc_MP; [
            ["-ITEMRECEIVE-", player, profileName, format["was given %1 %2 from %3 (%4) at POS: %5, but only had room for %6", _val, _item, name _from, getPlayerUID _from, getPosATL player, _diff]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
    } else {[[_from, _item, _val, _unit, false], "life_fnc_giveDiff", _from] spawn life_fnc_MP;};} else {
    if ([true, _item, _val] call life_fnc_handleInv) then {
        [format["%1 has gave you %2 %3", [name _from] call life_fnc_cleanName, _val, _type], "basic"] spawn life_fnc_handleMessage;
        if (_item isEqualTo "bank_money") then {private _time = _from getVariable["plb_banktrace", -1000];
            if (time - _time < 400) then {[[getPlayerUID player, "plb_banktrace", _time], "TON_fnc_varPersist", 2] spawn life_fnc_MP;};}; [
            ["-ITEMRECEIVE-", player, profileName, format["was given %1 %2 from %3 (%4) at POS: %5", _val, _item, name _from, getPlayerUID _from, getPosATL player]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
    } else {[[_from, _item, _val, _unit, false], "life_fnc_giveDiff", _from] spawn life_fnc_MP;};};