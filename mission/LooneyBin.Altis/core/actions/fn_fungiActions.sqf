#include "..\..\macro.h"
params[["_typeAction", "", [""]]];
switch (_typeAction) do {case ("enterDen"): {
            private _action = ["Would you like to enter the Dark Fungi Den?", "Elevator 3000", "Yes!", "No!"] call BIS_fnc_guiMessage;
            if !(_action) exitWith {};
            disableUserInput true;
            cutText["", "BLACK OUT", 0];
            uiSleep 1;
            _plb_pos = [9068.34, 22446.6, 0.00187492];
            player setPos _plb_pos;
            // owner 2026-06-19: mark the player as INSIDE the den. fn_mineFungi requires this to dig, so backing a
            // Tempest up to the surface rocks above the den (within the dig's 300m guard) no longer lets you gather
            // without taking the elevator. Cleared on exit (below) + on respawn (fn_onPlayerRespawn).
            player setVariable ["plb_inFungiDen", true, true];
            uiSleep 0.5;
            player playMoveNow "";
            uiSleep 2;
            player playMoveNow "";
            cutText["", "BLACK IN", 0];
            titleText[format["You are currently 250 meters below %1", worldName], "PLAIN"];
            titleFadeOut 4;
            disableUserInput false;}; case ("exitDen"): {
                private _action = ["Would you like to exit the Dark Fungi Den?", "Elevator 3000", "Yes!", "No!"] call BIS_fnc_guiMessage;
                if !(_action) exitWith {};
                cutText["", "BLACK OUT", 0];
                disableUserInput true;
                uiSleep 1;
                _plb_pos = [7862.53, 18042.6, 0.00143433];
                player setPos _plb_pos;
                player setVariable ["plb_inFungiDen", false, true];   // owner 2026-06-19: back on the surface -> can't dig
                uiSleep 0.5;
                player playMoveNow "";
                uiSleep 2;
                player playMoveNow "";
                cutText["", "BLACK IN", 0];
                titleText[format["You have returned to the surface of %1", worldName], "PLAIN"];
                titleFadeOut 4;
                disableUserInput false;};};