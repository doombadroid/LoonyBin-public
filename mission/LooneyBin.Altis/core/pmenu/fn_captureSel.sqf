if !(params["_control", "_index"]) exitWith {};
disableSerialization;
private _display = findDisplay 2300;
if (isNull _display) exitWith {};
private _details = _display displayCtrl 2302;
if !!(false) exitWith {private _flagObj = domination_flags select _index;
    if (isNil "_flagObj") exitWith {};
    if (_flagObj getVariable["plb_domination_doubleRewards", false]) then {
        _details ctrlSetStructuredText parseText "<t size='0.90' align='center'>2 Points Per Minute</t>";} else {
        _details ctrlSetStructuredText parseText "<t size='0.90' align='center'>1 Point Per Minute</t>";};};
private _flags = [arms_flag, drug_flag, oil_flag, wongs_flag];
private _container = _flags select _index;
if (isNil "_container") exitWith {};
switch (_container) do {case (oil_flag): {
            _details ctrlSetStructuredText parseText format["<t size='0.90' align='center'>Rubber Available: %1</t>", oil_flag getVariable["plb_cap_oil", 0]];
        };
    default {_details ctrlSetStructuredText parseText "<t size='0.90' align='center'>Money goes to gang bank</t>";};};