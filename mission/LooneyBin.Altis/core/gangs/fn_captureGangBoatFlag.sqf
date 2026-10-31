params[["_flag", objNull, [objNull]]];
_flag getVariable["plb_boatflag_data", ["", -1, "Uncontrolled"]] params[["_captureTarget", "", [""]], ["_gangID", -1, [0]], ["_gangName", "Uncontrolled", [""]]];
if !(SRV_gangBoatFortressData select 0) exitWith {};
if ((currentWeapon player) in ["", "Binocular", "Rangefinder", "hgun_Pistol_Signal_F"]) exitWith {
    ["You can't take a flag without a weapon.", "basic"] spawn life_fnc_handleMessage;};
if (_gangID isEqualTo(life_gang_data select 0)) exitWith {["Your gang already owns this flag.", "basic"] spawn life_fnc_handleMessage;};
life_action_in_use = true;
private _text = "Capturing a Gang Boat Flag...";
5 cutRsc["life_progress", "PLAIN"];
private _ui = uiNameSpace getVariable "life_progress";
private _progress = _ui displayCtrl 38201;
private _pgText = _ui displayCtrl 38202;
_pgText ctrlSetText format["%2 (1%1)...", "%", _text];
_progress progressSetPosition 0.01;
private _cP = 0.01;
private _success = false;
for "_i"
from 0 to 1 step 0 do {uiSleep 0.3;
    _cP = _cP + 0.01;
    _progress progressSetPosition _cP;
    _pgText ctrlSetText format["%3 (%1%2)...", round(_cP * 100), "%", _text];
    if (player distance _flag > 6 || life_isDowned || player getVariable["plb_restrained", false] || !alive player) exitWith {
        ["You failed to capture the boat flag.", "basic"] spawn life_fnc_handleMessage;};
    if !(SRV_gangBoatFortressData select 0) exitWith {["You failed to capture the turf.", "basic"] spawn life_fnc_handleMessage;};
    if !(life_action_in_use) exitWith {["You failed to capture the turf.", "basic"] spawn life_fnc_handleMessage;};
    if !(isNull objectParent player) exitWith {["You failed to capture the turf.", "basic"] spawn life_fnc_handleMessage;};
    if (_cP >= 1) exitWith {_success = true;};}; 5 cutText["", "PLAIN"];
life_action_in_use = false;
if !(_success) exitWith {};
["You have claimed this boat flag for your gang. If your gang ends up having the most of the points you win the boat!", "basic"] spawn life_fnc_handleMessage;
_flag setVariable["plb_boatflag_data", [_captureTarget, life_gang_data select 0, life_gang_data select 1], true];