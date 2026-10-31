params["_unit1", "_unit2", "_vehicle"];
if !(playerSide isEqualTo civilian) exitWith {};
if (_vehicle getVariable["plb_side", ""] isEqualTo "med") then {
    if (_unit1 isEqualTo(driver _vehicle) || ([player] call life_fnc_isUnitCopilot)) then {moveOut player;
        ["Only trained Medical and Fire personnel are able to operate this vehicle!", "basic"] spawn life_fnc_handleMessage;};};