params[["_mode", 0, [0]]];
if !(_mode in [1, 2]) exitWith {};
private _val = parseNumber(ctrlText 12918);
if ((call life_adminLevel) < 3) exitWith {["Insufficient permissions", "basic"] spawn life_fnc_handleMessage;};
if !([str _val] call life_fnc_isNumber) exitWith {["You didn't enter a positive integer.", "basic"] spawn life_fnc_handleMessage;};
if (_val < 100) exitWith {["You must send a minimum of $100.", "basic"] spawn life_fnc_handleMessage;};
if (_val > 9999999) exitWith {["You must enter a number less than $9,999,999.", "basic"] spawn life_fnc_handleMessage;};
switch (_mode) do {case 1: {if ((lbCurSel 12901) isEqualTo - 1) exitWith {
                ["You did not select a player.", "basic"] spawn life_fnc_handleMessage;};
            private _unit = lbData[12901, lbCurSel 12901];
            _unit = missionNamespace getVariable _unit;
            if (isNil "_unit" || {isNull _unit}) exitWith {["Player does not exist.", "basic"] spawn life_fnc_handleMessage;};
            private _action = [format["Are you sure you want to give $%1 to %2?", [_val] call life_fnc_numberText, (name _unit)], "Admin Add Money", "Yes", "No"] call BIS_fnc_guiMessage;
            if !(_action) exitWith {};
            if (_val > 0) then {[[_val, player, _unit, _val, [1]], "TON_fnc_handleWireTransfer", 2, false, false] spawn life_fnc_MP; [
                    ["-ADMINACTION-", player, profileName, format["added $%1 to %2's bank account.", _val, name _unit]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
                [format["You added $%1 to %2's bank account.", [_val] call life_fnc_numberText, name _unit]] spawn life_fnc_handleMessage;
            };};
    case 2: {life_atmcash = (round(life_atmcash + _val)) max 0;
            life_atmcashCacheB = ((life_atmcash / 4) + 11); [
                ["-ADMINACTION-", player, profileName, format["added $%1 to their bank account.", _val]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
            [format["You added $%1 to your bank account.", [_val] call life_fnc_numberText]] spawn life_fnc_handleMessage;};
    default {};};