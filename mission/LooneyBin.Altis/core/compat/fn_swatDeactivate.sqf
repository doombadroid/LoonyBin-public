// life_fnc_swatDeactivate -- LooneyBin: SWAT stand-down (restored 2026-06-11).
// The server calls this via "[] call life_fnc_swatDeactivate" during fed/bank/prison cleanup, which
// runs it on the SERVER (no player there). So when invoked on the server we re-broadcast to the
// summoned officers; on each officer's client we restore the pre-SWAT loadout and clear SWAT state.
if (isServer) exitWith {{if (!isNull _x) then { [[], "life_fnc_swatDeactivate", _x, false] spawn life_fnc_MP; };
    } forEach (missionNamespace getVariable ["life_swat_officers", []]);};
if (!life_activeSWAT && !life_SWATActionAvail) exitWith {};
["SWAT deployment has ended. Returning you to your patrol gear.", "basic"] spawn life_fnc_handleMessage;
if (!isNil "life_swatLoadout") then {player setUnitLoadout life_swatLoadout;
    life_swatLoadout = nil;
    [] spawn {uiSleep 0.5;
        [uniform player, "setIdx", 0] call life_fnc_clothingTextures;};};
life_activeSWAT = false;
life_SWATActionAvail = false;
life_isSwat = false;
