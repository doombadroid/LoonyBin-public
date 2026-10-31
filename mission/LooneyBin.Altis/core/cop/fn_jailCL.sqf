params[["_unit", objNull, [objNull]]];
if (isNull _unit || !((typeOf _unit) == "Land_Bodybag_01_black_F")) exitWith {};
private _name = _unit getVariable["plb_playername", "Error"];
private _pid = _unit getVariable["plb_steamid", ""];
if (_name isEqualTo "Error" || _pid isEqualTo "") exitWith {};
if (_unit getVariable["plb_wantedAmt", 0] isEqualTo 0) exitWith {["This person was not wanted", "basic"] spawn life_fnc_handleMessage;};
if (playerSide isEqualTo independent) exitWith {["You cannot arrest this body.", "basic"] spawn life_fnc_handleMessage;};
if (playerSide isEqualTo civilian && !(_pid in life_bounty_uid)) exitWith {
    ["You cannot arrest this bounty as it's not your bounty.", "basic"] spawn life_fnc_handleMessage}; [
    [_pid], "TON_fnc_setJail", false, false] spawn life_fnc_MP; [
    ["-ARRESTCL-", player, profileName, format["(%1) arrested combat logger %2 (%3) with a bounty of $%4", side player, _name, _pid, [_unit getVariable["plb_wantedAmt", 0]] call life_fnc_numberText]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
[[0, 1, 2], format["You've arrested the Combat Logger, %1!", [_name] call life_fnc_cleanName]] call life_fnc_broadcast; [
    [_unit, player, true, false], "TON_fnc_wantedBounty", 2] spawn life_fnc_MP;