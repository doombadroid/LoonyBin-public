if ((call life_adminLevel) <= 1) exitWith {closeDialog 0;};
private _unit = lbData[12901, lbCurSel(12901)];
_unit = missionNamespace getVariable _unit;
if (isNil "_unit") exitwith {};
if (isNull _unit) exitWith {};
if !(isPlayer _unit) exitWith {};
private _action = false;
if (_unit isEqualTo player) then {
    _action = ["Are you sure you want to admin restrain yourself?", "Admin Restrain Self", "Yes", "No"] call BIS_fnc_guiMessage;};
if (_action || !(_unit isEqualTo player)) then {if (_unit getVariable["plb_adminRestrain", false]) exitWith {}; [
        [], "life_fnc_closeMap", _unit, false] spawn life_fnc_MP;
    uisleep 0.1;
    _unit setVariable["plb_adminRestrain", true, true];
    _unit setVariable["plb_restrained", true, true]; [[player], "life_fnc_unitRestrain", _unit, false] spawn life_fnc_MP;
    [format["You have restrained %1", name _unit], "warning"] spawn life_fnc_handleMessage; [
        ["-ADMINACTION-", player, (profileName), format["Restrained %1", name _unit]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
};