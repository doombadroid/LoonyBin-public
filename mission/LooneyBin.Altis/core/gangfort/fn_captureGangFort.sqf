/*
    life_fnc_captureGangFort  (LooneyBin, owner 2026-06-17)
    Capture the Gang Fortress flag for your gang (king-of-the-hill). While the event is active, a gang member
    stands at the flag and captures it (~30s, must keep a weapon out + stay put + not be downed/restrained).
    On success the flag's owner var flips to your gang -> the server scoring loop (TON_fnc_gangFortressSRV)
    then awards your gang points each tick AS LONG AS you HOLD it (a member alive in the 125m zone). A rival
    gang re-captures to flip ownership. Mirrors fn_captureGangBoatFlag.
    Call: [gang_fortress_flag] spawn life_fnc_captureGangFort;
*/
params [["_flag", objNull, [objNull]]];
if (isNull _flag) exitWith {};
if (life_gang_data isEqualTo []) exitWith {["You need to be in a gang to capture the fortress.", "basic"] spawn life_fnc_handleMessage;};
if !((gang_fortress_flag getVariable ["plb_gang_fortress_data", [-1, "Unknown", false]]) param [2, false]) exitWith {
    ["The Gang Fortress event isn't active right now.", "basic"] spawn life_fnc_handleMessage;};
if (life_action_in_use) exitWith {["You're already doing something.", "basic"] spawn life_fnc_handleMessage;};
if ((currentWeapon player) in ["", "Binocular", "Rangefinder", "hgun_Pistol_Signal_F"]) exitWith {
    ["You can't capture the fortress without a weapon out.", "basic"] spawn life_fnc_handleMessage;};
if (((gang_fortress_flag getVariable ["plb_gang_fortress_data", [-1, "Unknown", false]]) param [0, -1]) isEqualTo (life_gang_data param [0, -1])) exitWith {
    ["Your gang already holds the fortress flag -- defend it!", "basic"] spawn life_fnc_handleMessage;};
life_action_in_use = true;
private _text = "Capturing the Gang Fortress...";
disableSerialization;
5 cutRsc ["life_progress", "PLAIN"];
private _ui = uiNamespace getVariable "life_progress";
private _progress = _ui displayCtrl 38201;
private _pgText = _ui displayCtrl 38202;
_pgText ctrlSetText format ["%2 (1%1)...", "%", _text];
_progress progressSetPosition 0.01;
private _cP = 0.01;
private _success = false;
for "_i" from 0 to 1 step 0 do {uiSleep 0.3;
    _cP = _cP + 0.01;
    _progress progressSetPosition _cP;
    _pgText ctrlSetText format ["%3 (%1%2)...", round (_cP * 100), "%", _text];
    if (player distance _flag > 8 || life_isDowned || (player getVariable ["plb_restrained", false]) || !alive player) exitWith {
        ["You failed to capture the fortress flag -- stay at the flag.", "basic"] spawn life_fnc_handleMessage;};
    if !((gang_fortress_flag getVariable ["plb_gang_fortress_data", [-1, "Unknown", false]]) param [2, false]) exitWith {
        ["The Gang Fortress event ended before you finished.", "basic"] spawn life_fnc_handleMessage;};
    if !(life_action_in_use) exitWith {["You failed to capture the fortress flag.", "basic"] spawn life_fnc_handleMessage;};
    if !(isNull objectParent player) exitWith {["You can't capture from a vehicle.", "basic"] spawn life_fnc_handleMessage;};
    if (_cP >= 1) exitWith { _success = true; };};
5 cutText ["", "PLAIN"];
life_action_in_use = false;
if !(_success) exitWith {};
// flip ownership globally (same client-set pattern as the boat flag). The server scoring loop reads this.
gang_fortress_flag setVariable ["plb_gang_fortress_data", [life_gang_data param [0, -1], life_gang_data param [1, "Unknown"], true], true];
["Your gang CAPTURED the Gang Fortress flag! Keep a member in the zone to earn points -- and defend it from rival gangs.", "basic"] spawn life_fnc_handleMessage;
[[1, format ["<t size='1.3' color='#FFD700'>Gang Fortress</t><br/><t size='1.0' color='#ffffff'>%1 has captured the fortress flag!</t>", life_gang_data param [1, "Unknown"]]], "life_fnc_broadcast", [civilian], false, false] spawn life_fnc_MP;
[["-GANGFORT-", player, profileName, format ["captured the fortress flag for gang %1 (%2)", life_gang_data param [0, -1], life_gang_data param [1, "Unknown"]]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
