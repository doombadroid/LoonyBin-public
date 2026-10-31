if (life_gang_data isEqualTo[]) exitWith {};
params[["_flag", objNull, [objNull]]];
_flag getVariable["plb_turf_data", [-1, "Unknown", false, "Unknown"]] params[["_gangID", -1, [0]], ["_gangName", "Unknown", [""]], ["_active", false, [false]], ["_playerCapturer", "Unknown", [""]]];
private _ownsFortress = (!((gang_fortress_flag getVariable["plb_gang_fortress_data", [-1, "Unknown", false]]) param[2, false]) && ((gang_fortress_flag getVariable["plb_gang_fortress_data", [-1, "Unknown", false]]) param[0, -1]) isEqualTo(life_gang_data param[0, -1]));
if !(_active) exitWith {};
if (_ownsFortress) exitWith {["You can't capture a turf while owning the gang fortress!", "basic"] spawn life_fnc_handleMessage;};
if ((currentWeapon player) in ["", "Binocular", "Rangefinder", "hgun_Pistol_Signal_F"]) exitWith {
    ["You can't take a turf without a weapon.", "basic"] spawn life_fnc_handleMessage;};
if (_gangID isEqualTo(life_gang_data select 0)) exitWith {
    ["Your gang is already in line to control this turf.", "basic"] spawn life_fnc_handleMessage;};
private _turfCount = 0; {
    _x getVariable["plb_turf_data", [-1, "Unknown", false, "Unknown"]] params[["_gangID", -1, [0]], ["_gangName", "Unknown", [""]], ["_active", false, [false]], ["_playerCapturer", "Unknown", [""]]];
    if (_gangID isEqualTo(life_gang_data select 0)) then {_turfCount = _turfCount + 1};}
forEach[rodo_flag, zaros_flag, panagia_flag];
if (_turfCount >= 2) exitWith {["A gang cannot control more than two turfs at a time.", "basic"] spawn life_fnc_handleMessage;};
private _friendlyInArea = allPlayers select {
    player distance _x < 750 && (_x getVariable["gang_data", [-1]] select 0) isEqualTo(life_gang_data select 0)};
if (count _friendlyInArea > 5) exitWith {
    ["Turfs cannot be captured by a gang with more than 5 players nearby.", "basic"] spawn life_fnc_handleMessage;};
["Capturing turf. No more than 5 gang members can be inside this turf during the contested time", "basic"] spawn life_fnc_handleMessage;
life_action_in_use = true;
private _text = "Capturing Turf...";
5 cutRsc["life_progress", "PLAIN"];
private _ui = uiNameSpace getVariable "life_progress";
private _progress = _ui displayCtrl 38201;
private _pgText = _ui displayCtrl 38202;
_pgText ctrlSetText format["%2 (1%1)...", "%", _text];
_progress progressSetPosition 0.01;
private _cP = 0.01;
private _success = false;
private _pos = getPos player;
for "_i"
from 0 to 1 step 0 do {uiSleep 0.6;
    _cP = _cP + 0.01;
    _progress progressSetPosition _cP;
    _pgText ctrlSetText format["%3 (%1%2)...", round(_cP * 100), "%", _text];
    if (player distance _pos > 4 || life_isDowned || player getVariable["plb_restrained", false] || !alive player || speed player > 2) exitWith {
        ["You failed to capture the turf.", "basic"] spawn life_fnc_handleMessage;};
    private _active = _flag getVariable["plb_turf_data", []] select 2;
    if !(_active) exitWith {["You failed to capture the turf.", "basic"] spawn life_fnc_handleMessage;};
    private _friendlyInArea = allPlayers select {
        player distance _x < 750 && (_x getVariable["gang_data", [-1]] select 0) isEqualTo(life_gang_data select 0)};
    if (count _friendlyInArea > 5) exitWith {
        ["Turfs cannot be captured by a gang with more than 5 players nearby.", "basic"] spawn life_fnc_handleMessage;};
    if !(life_action_in_use) exitWith {["You failed to capture the turf.", "basic"] spawn life_fnc_handleMessage;};
    if !(isNull objectParent player) exitWith {["You failed to capture the turf.", "basic"] spawn life_fnc_handleMessage;};
    if (_cP >= 1) exitWith {_success = true;};}; 5 cutText["", "PLAIN"];
life_action_in_use = false;
if !(_success) exitWith {};
["action", "capturf", 1] spawn life_fnc_handleQuest;
["You have claimed this turf for your gang. If you're the last to do this when the capture time expires, it's yours!", "basic"] spawn life_fnc_handleMessage;
_flag setVariable["plb_turf_data", [life_gang_data select 0, life_gang_data select 1, true, profileName], true];
// LooneyBin 2026-06-11: the server turf-window finalizer (init.sqf) assigns ownership from life_turf_captor
// = [capturerName, gangName, gangID], but NOTHING ever wrote it (deobf casualty) -> captures never persisted
// to the gang (e.g. Panagia held but never transferred). Record the captor server-side; last capturer before
// the window expires wins, matching "if you're the last to do this when the capture time expires, it's yours".
life_turf_captor = [profileName, life_gang_data select 1, life_gang_data select 0];
publicVariable "life_turf_captor";