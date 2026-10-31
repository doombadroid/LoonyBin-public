/*
    life_fnc_removeFiringPin  (LooneyBin, owner 2026-06-11)
    APD (all ranks) scroll option on a RESTRAINED civilian -> disables their weapons ("firing pin removed").
    Runs on the COP. Validates, then tells the suspect's machine to break their guns (life_fnc_breakGuns).
    The civ repairs it themselves via "Fix Firing Pin" (only while UNRESTRAINED, 60s) -- see fn_fixFiringPin.
*/
params [["_civ", objNull, [objNull]]];
if (isNull _civ || {!isPlayer _civ} || {!(side _civ isEqualTo civilian)}) exitWith {};
if !(_civ getVariable ["plb_restrained", false]) exitWith {
    ["The suspect has to be in restraints first.", "basic"] spawn life_fnc_handleMessage;};
if (_civ getVariable ["plb_gunBroken", false]) exitWith {
    ["This suspect's firing pin is already removed.", "basic"] spawn life_fnc_handleMessage;};
if ((player distance _civ) > 5) exitWith {};
[[], "life_fnc_breakGuns", _civ] spawn life_fnc_MP;   // run on the suspect's client (their weapons are local there)
[["-FIRINGPIN-", _civ, name _civ, format ["firing pin REMOVED by APD %1 (%2)", profileName, getPlayerUID player]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
[format ["You removed %1's firing pin -- their weapons are disabled until they repair it.", [name _civ] call life_fnc_cleanName], "basic"] spawn life_fnc_handleMessage;
