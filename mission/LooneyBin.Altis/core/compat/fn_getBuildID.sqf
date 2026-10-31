/*
    life_fnc_getBuildID (LooneyBin compat -- reverse-drift; real impl)
*/
// LooneyBin compat: stable building id for houses/gang houses
params [["_obj",objNull,[objNull]]];
if (isNull _obj) exitWith {-1};
private _id = _obj getVariable ["houseId", -1];
if (_id isEqualTo -1) then { _id = _obj getVariable ["plb_buildID", -1]; };
if (_id isEqualTo -1) then { private _p = getPosWorld _obj; _id = parseNumber (format ["%1%2", round (_p select 0), round (_p select 1)]); };
_id
