params[["_function", "", [""]]];
if (_function isEqualTo "") exitWith {};
if ((call life_adminLevel) <= 3) exitWith {["Insufficient Permissions", "basic"] spawn life_fnc_handleMessage;};
private _action = ["You are about to set/change the server weather. Are you sure?", "Weather change", "Confirm", "Cancel"] call BIS_fnc_guiMessage;
if (_action) then {[_function] remoteExec["TON_fnc_changeWeather", 2]} else {
    ["Weather adjustment canceled.", "basic"] spawn life_fnc_handleMessage;};