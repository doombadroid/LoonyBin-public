if ((call life_adminLevel) <= 1) exitWith {closeDialog 0;};
if ((lbCurSel 12901) isEqualTo - 1) exitWith {};
private _unit = lbData[12901, lbCurSel(12901)];
_unit = missionNamespace getVariable _unit;
if (isNull _unit || !((_unit getVariable["plb_adminRestrain", false]) || (_unit getVariable["plb_restrained", false]))) exitWith {}; {
    _x params["_var", "_value"];
    if (_unit getVariable[_var, true]) then {_unit setVariable[_var, _value, true];};}
forEach[["plb_adminRestrain", false], ["plb_restrained", false], ["plb_escorting", false], ["plb_transporting", false]];
detach _unit;
[format["You have un-restrained %1", name _unit], "warning"] spawn life_fnc_handleMessage; [
    ["-ADMINACTION-", player, (profileName), format["un-restrained %1", name _unit]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;