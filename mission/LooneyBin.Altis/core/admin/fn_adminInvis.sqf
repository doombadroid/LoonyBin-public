if ((call life_adminLevel) <= 1) exitWith {closeDialog 0;};
private _isInvis = player getVariable["plb_invisOn", false];
if !(_isInvis) then {player setVariable["plb_invisOn", true, true];
    ["You are now invisible.", "basic"] spawn life_fnc_handleMessage; [
        [player, true, call life_adminLevel], "TON_fnc_visible", 2] spawn life_fnc_MP; [
        ["-ADMINACTION-", player, (profileName), format["went invisible."]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;} else {
    player setVariable["plb_invisOn", false, true];
    ["You are now visible.", "basic"] spawn life_fnc_handleMessage; [
        [player, false, call life_adminLevel], "TON_fnc_visible", 2] spawn life_fnc_MP; [
        ["-ADMINACTION-", player, (profileName), format["removed invisibility."]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;};