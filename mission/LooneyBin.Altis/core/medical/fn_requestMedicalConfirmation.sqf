params[["_medic", objNull, [objNull]], ["_medicName", "", [""]], ["_caller", objNull, [objNull]], ["_corpse", objNull, [objNull]]];
if (isNull _medic) exitWith {};
private _medicFormat = format["%1 Medic %2", [independent, _medic] call life_fnc_getRankString, _medicName];
private _dialogQuestion = [format["Do you wish to accept medical attention from %1, whom is %2 meters away?", _medicFormat, [round(_medic distance2D _corpse)] call life_fnc_numberText], "Medical Attention", "Yes", "No"] call BIS_fnc_guiMessage;
if !(_dialogQuestion) exitWith {};
life_medic_enroute = _medic;
_corpse setVariable["plb_requestAcceptor", [_medic, _medicName], true];