params[["_mode", 0, [0]], ["_kidnapper", objNull, [objNull]]];
if !(_mode in [1, 2]) exitWith {};
if (isNull player) exitWith {};
switch (_mode) do {case 1: {if !(alive player) exitWith {};
            if !(player getVariable["plb_restrained", false]) exitWith {};
            if (player getVariable["plb_blinded", false]) exitWith {};
            life_old_goggles = (goggles player);
            removeGoggles player;
            private _blindfold = "G_blindfold_01_black_F";
            player addGoggles _blindfold;
            systemChat format["You were blindfolded by %1.", _kidnapper getVariable["plb_name", [name _kidnapper] call life_fnc_cleanName]];
            player setVariable["plb_blinded", true, true];
            cutText["You are blindfolded.", "BLACK FADED"];
            0 cutFadeOut 9999999;
            life_old_group = group player;
            if !((units group player) isEqualTo[]) then {[player] join grpNull;
                if ("ItemGPS" in (assignedItems player)) then {player setVariable["hadGPS", true]; [
                        [true, player], "life_fnc_setGroupRestrainMarker", units life_old_group] spawn life_fnc_MP;};};
            player unlinkItem 'ItemMap';
            player unlinkItem 'ItemGPS';
            player removeItem 'ItemMap';
            player removeItem 'ItemGPS';
            // LooneyBin #514: this waited on the WRONG flag. In SQF `waitUntil { a; b; c }` only the LAST
            // expression is the loop condition -- the two `!getVariable` lines above were dead, and the loop
            // actually blocked on plb_RESTRAINED, not plb_blinded. So when a blindfolded prisoner had their
            // restraint cleared first (jail/relog clears plb_restrained), case 2 fired before the blackout was
            // meant to lift; and when the blindfold itself was cleared (plb_blinded set false) but restraint
            // lingered, the cleanup NEVER ran -> stuck black screen. Wait on the blindfold flag, which is what
            // case 2 actually reverses.
            waitUntil {uiSleep 1;
                !(player getVariable["plb_blinded", false])};
            [2] spawn life_fnc_blindfoldClient;};
    case 2: {if ((goggles player) in ["G_blindfold_01_black_F", "G_blindfold_01_white_F"]) then {removeGoggles player;};
            if (life_old_goggles != "") then {player addGoggles life_old_goggles;
                life_old_goggles = nil;};
            if !(isNull life_old_group) then {[player] joinSilent life_old_group;
                life_old_group = grpNull;};
            player setVariable["plb_blinded", false, true];
            player linkItem 'ItemMap';
            if (player getVariable["hadGPS", false]) then {player linkItem 'ItemGPS';
                player setVariable["hadGPS", nil];};
            0 cutFadeOut 1;};};