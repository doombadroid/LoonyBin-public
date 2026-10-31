if (life_action_in_use) exitWith {};
if !(life_bank_robbed select 0) exitWith {["The bank vault is not being drilled!", "basic"] spawn life_fnc_handleMessage;};
// owner 2026-06-16 (#290 + flashing-bar): the old code keyed the disarm on cursorObject==life_bank_building
// AND distance to the "life_bank_door" MARKER. With two bank doors (life_bank_door / _2) and any cursor/marker
// drift, the in-loop marker check tripped on the first tick -> the progress bar "flashed and vanished" and the
// disarm never ran. Track the DRILL OBJECT itself instead: stand near the drill and hold it. The loop still
// cancels the instant the cop dies / is downed / restrained / surrendered, so killing the defusing cop stops
// the defuse.
private _drill = (nearestObjects[player, ["Land_DrillAku_F"], 6]) param [0, objNull];
if (isNull _drill) exitWith {["Get closer to the drill please.", "basic"] spawn life_fnc_handleMessage;};
private _success = false;
private _title = "Disabling Drill";
disableSerialization;
5 cutRsc["life_progress", "PLAIN"];
private _ui = uiNamespace getVariable["life_progress", displayNull];
private _progressBar = _ui displayCtrl 38201;
private _titleText = _ui displayCtrl 38202;
_titleText ctrlSetText format["%2 (1%1)...", "%", _title];
_progressBar progressSetPosition 0.01;
private _cP = 0.01;
life_action_in_use = true;
["AinvPknlMstpSnonWnonDnon_medic_1", 21] spawn life_fnc_handleAnim;
while {true} do {uiSleep 0.3;
    _cP = _cP + 0.01;
    _progressBar progressSetPosition _cP;
    _titleText ctrlSetText format["%3 (%1%2)...", round(_cP * 100), "%", _title];
    // cancel the moment the cop can no longer work the drill (killing the defuser stops the defuse) ...
    if (!alive player || {player getVariable ["plb_downed", false]} || {player getVariable ["plb_surrendered", false]} || {player getVariable ["plb_restrained", false]}) exitWith {};
    // ... or they leave the drill / it's gone / the robbery already ended (cop on another door finished it)
    if (isNull _drill || {(player distance _drill) > 6} || {!(life_bank_robbed select 0)}) exitWith {};
    if (_cP >= 1) exitWith { _success = true; };
    if !(life_action_in_use) exitWith {};};
life_action_in_use = false;
[] spawn life_fnc_handleAnim;
player switchMove "";
5 cutText["", "PLAIN"];
if (_success) then {[[player, life_bank_building], "TON_fnc_bankRobbery", 2] spawn life_fnc_MP;};