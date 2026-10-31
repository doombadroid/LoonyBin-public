params[["_caseType", "", [""]]];
// owner 2026-06-16 (#262): the gang fortress is a CIVILIAN/gang event, but the server remoteExecs this client
// init to EVERY client (-2) -> cops AND medics got the "Gang Fortress Is Ready For Capture!" pop-up, the
// fortressStart sound and the capture marker ("cops/medics get a pop-up that cartels are being capped"). Gate
// the whole client init to civilians (same side-exclusion the cartel event got in #176).
if !(playerSide isEqualTo civilian) exitWith {};
if (_caseType == "drawHud" && !(player getVariable["gangFortClientInitialized", false])) exitWith {
    [format["The gang fortress hasn't initialized you yet, try again later!"], "warning"] call life_fnc_handleMessage;};
if (((gang_fortress_flag getVariable["plb_gang_fortress_data", [-1, "Unknown", false]]) param[2] == false)) exitWith {};
private _drawGangFortClient = {createMarkerLocal["gangfort_capturezone", getPosATL gang_fortress_flag];
    "gangfort_capturezone"
    setMarkerSizeLocal[125, 125];
    "gangfort_capturezone"
    setMarkerBrushLocal "Border";
    "gangfort_capturezone"
    setMarkerColorLocal "colorRed";
    "gangfort_capturezone"
    setMarkerShapeLocal "ELLIPSE";
    "gangfort_capturezone"
    setMarkerAlphaLocal 1;
    if (!isNil "SRV_tempGangRebel") then {{_x params["_weaponShop", "_vehicleShop", "_spawnPoints"];
            [_weaponShop, 'STAND'] call NPC_fnc_civRebelWeapon;
            [_vehicleShop, _spawnPoints, 'REPAIR_VEH_KNEEL', 'ground'] call NPC_fnc_civRebelVehicles;}
        forEach SRV_tempGangRebel;};
    // owner 2026-06-17: capture-the-flag action on the fortress flag (king-of-the-hill). Added ONCE per client
    // (guard var). The condition gates it to the ACTIVE event + a gang civ within 8m who doesn't already own it,
    // so it only appears during a fort event. Capturing -> life_fnc_captureGangFort flips ownership -> the server
    // scoring loop (TON_fnc_gangFortressSRV) awards the holding gang each tick.
    if !(player getVariable ["gangFortCaptureActionAdded", false]) then {player setVariable ["gangFortCaptureActionAdded", true];
        gang_fortress_flag addAction ["<t color='#FFD700'>Capture Fortress Flag</t>",
            { [gang_fortress_flag] spawn life_fnc_captureGangFort }, nil, 1.5, true, true, "",
            "playerSide isEqualTo civilian && {!(life_gang_data isEqualTo [])} && {(player distance gang_fortress_flag) < 8} && {(gang_fortress_flag getVariable ['plb_gang_fortress_data', [-1,'',false]]) param [2, false]} && {((gang_fortress_flag getVariable ['plb_gang_fortress_data', [-1,'',false]]) param [0, -1]) isNotEqualTo (life_gang_data param [0, -1])} && {!life_action_in_use}",
            8];};
    waitUntil {uiSleep 15;
        (player distance2D(getMarkerPos "gang_fortress_marker") <= 500) || ((gang_fortress_flag getVariable["plb_gang_fortress_data", [-1, "Unknown", false]]) param[2] == false)
    };
    if ((gang_fortress_flag getVariable["plb_gang_fortress_data", [-1, "Unknown", false]]) param[2]) then {
        player setVariable["gangFortParticipant", true];
        [] spawn life_fnc_gangFortHud;};};
switch (_caseType) do {case ("initMessages"): {player setVariable["gangFortClientInitialized", true];
            ["The Gang Fortress can now be captured for the next hour! The gang with the longest time holding will win! Two temporary safezone Rebel Outposts have been setup near the Gang Fortress!", "gang_fortress_long"] spawn life_fnc_handleMessage;
            [4, format["Gang Fortress Is Ready For Capture!"]] call life_fnc_broadcast;
            [objNull, "fortressStart", true] call life_fnc_playSound;
            [] call _drawGangFortClient;}; case ("missedMessages"): {
                if (player getVariable["gangFortClientInitialized", false]) exitWith {};
                player setVariable["gangFortClientInitialized", true];
                ["The Gang Fortress can now be captured, it started whilst you were offline but you still have a chance! The gang with the longest time holding will win! Two temporary safezone Rebel Outposts have been setup near the Gang Fortress!", "gang_fortress_long"] spawn life_fnc_handleMessage;
                [objNull, "fortressStart", true] call life_fnc_playSound;
                [] call _drawGangFortClient;};
        case ("drawHud"): {player setVariable["gangFortParticipant", true];
                [] spawn life_fnc_gangFortHud;};};