params[["_mode", 0, [0]]];
if ((call life_adminLevel) <= 1) exitWith {closeDialog 0;};
if !(_mode in [1, 2]) exitWith {closeDialog 0;};
switch (_mode) do {case 1: {if ((lbCurSel 12901) isEqualTo - 1) exitWith {
                ["You did not select a player.", "basic"] spawn life_fnc_handleMessage;};
            private _unit = lbData[12901, lbCurSel 12901];
            _unit = missionNamespace getVariable _unit;
            if (isNil "_unit" || {isNull _unit}) exitWith {}; [[player, false, true, false], "life_fnc_revived", _unit] spawn life_fnc_MP;
            _unit setVariable["plb_suicideVestDeath", false, true]; [
                ["-ADMINACTION-", player, profileName, format["admin revived %1.", name _unit]], "TON_fnc_logIt", 2] spawn life_fnc_MP;};
    case 2: {private _action = ["Are you sure you want to revive everyone?", "Admin Revive All", "Yes", "No"] call BIS_fnc_guiMessage;
            if !(_action) exitWith {}; [[player, false, true, false], "life_fnc_revived", allPlayers] spawn life_fnc_MP; [
                ["-ADMINACTION-", player, profileName, "admin revived all players."], "TON_fnc_logIt", 2] spawn life_fnc_MP;};
    default {};};