params[["_caller", objNull, [objNull]], ["_corpse", objNull, [objNull]]];
if (isNull _caller || isNull _corpse) exitWith {};
if (playerSide isEqualTo west && !(life_coprole in ["medic", "all"])) exitWith {};
private _deadPlayerUID = _corpse getVariable["plb_steamid", (getPlayerUID _corpse)];
private _deadPlayerName = _corpse getVariable["plb_name", [name _corpse] call life_fnc_cleanName];
life_medicLastRequest = +[_caller, _corpse, _deadPlayerUID, _deadPlayerName];
private _oldCorpseIDX = life_medicRequestedCorpses findIf {(_x param[1, objNull]) isEqualTo _corpse};
if (_oldCorpseIDX isNotEqualTo - 1) then {
    life_medicRequestedCorpses set[_oldCorpseIDX, [_caller, _corpse, _deadPlayerUID, _deadPlayerName, time]];} else {
    life_medicRequestedCorpses pushBack[_caller, _corpse, _deadPlayerUID, _deadPlayerName, time];};
["MedicalRequestEmerg", [format["%1 is requesting a National Guard.", [name _caller] call life_fnc_cleanName]]] call BIS_fnc_showNotification;
[format["You have received a new revive request from %1 who is %2 meters away. Press 8 to accept.", name _caller, [floor(player distance _corpse)] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
