params[["_control", controlNull]];
disableSerialization;
private _display = findDisplay 2700;
if (isNull _display) exitWith {};
private _vehicleList = _display displayCtrl 2702;
private _playerList = _display displayCtrl 2703;
private _vehicle = life_vehicles select(lbCurSel _vehicleList);
private _unit = allPlayers param[allPlayers findIf {(lbData[2703, lbCurSel 2703]) isEqualTo(_x getVariable["plb_steamid", getPlayerUID _x])
}, objNull];
if (isNull _unit) exitWith {};
if (isNil "_unit") exitWith {["The player selected doesn't seem to exist?", "basic"] spawn life_fnc_handleMessage;};
if (_vehicle isKindOf "House_F" && {(_vehicle getVariable["plb_homeOwner", "Error UID"]) != getPlayerUID player}) exitWith {
    ["You cannot give house keys from a house you do not own!", "basic"] spawn life_fnc_handleMessage;};
private _vehicleOwners = _vehicle getVariable["plb_vehOwners", []];
if !((_vehicleOwners findIf {getPlayerUID _unit isEqualTo(_x param[0, "Error UID"])}) isEqualTo - 1) exitWith {
    ["This player already has keys", "basic"] spawn life_fnc_handleMessage;};
_vehicleOwners pushBackUnique[getPlayerUID _unit, [name _unit] call life_fnc_cleanName];
_vehicle setVariable["plb_vehOwners", _vehicleOwners, true];
[format["You have given %1 keys to your %2", [name _unit] call life_fnc_cleanName, getText(configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName")], "basic"] spawn life_fnc_handleMessage;
[[_vehicle, player], "life_fnc_addVehicle2Chain", _unit, false, false] spawn life_fnc_MP;