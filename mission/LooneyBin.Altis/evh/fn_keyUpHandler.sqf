#include "..\macro.h"
#include "\a3\editor_f\Data\Scripts\dikCodes.h"
params["_ctrl", "_code", "_shift", "_ctrlKey", "_alt"];
private _handled = false;
if !(isNull findDisplay 7300) exitWith {false};
if (_code in (actionKeys "NextAction") || _code in (actionKeys "PrevAction")) then {if !(life_show_actions) then {
        [] spawn life_fnc_enableActions;};};
life_lastActiveInput = time + 305;
switch (_code) do {case 2: {if (count(actionKeys "User16") != 0) exitWith {};
            if (playerSide isEqualTo independent && ((call life_adminLevel) <= 2)) exitWith {};
            if (playerSide isEqualTo civilian && ((call life_adminLevel) <= 2) && (life_bounty_list isEqualTo[]) && (A_stats_crimes select 0) < 0) exitWith {};
            if !(isNull(findDisplay 39500)) exitWith {};
            [] call life_fnc_wantedMenu;};
    case 7: {if (!_alt && !_ctrlKey) then {[vehicle player] spawn life_fnc_activateNitro;};};
    case 9: {if (life_medicLastRequest isNotEqualTo[objNull, "", "", ""]) then {
                if (((life_medicLastRequest param[0, objNull]) distance2D(getMarkerPos "respawn_west") <= 1000) && !(isNull(life_medicLastRequest param[1, objNull]))) then {
                    private _xCorpse = (life_medicLastRequest param[1, objNull]);
                    private _requestID = (life_medicRequestedCorpses findIf {_xCorpse isEqualTo(_x param[1, objNull])});
                    [_requestID] spawn life_fnc_acceptMedicalRequest;} else {
                    ["The last player to send a medic request is no longer in need of assistance.", "basic"] spawn life_fnc_handleMessage;
                };} else {if (playerSide isEqualTo civilian && !(life_bounty_list isEqualTo[])) then {if (life_arrestingBounty) then {
                        life_arrestingBounty = false};};};};
    case 10: {if (playerSide isEqualTo west && !isNil "life_copEviReq") then {if (life_inCombat) exitWith {
                    ["You were recently near or in combat. Leave combat and try again.", "basic"] spawn life_fnc_handleMessage;};
                if !(isNull objectParent player) exitWith {["Exit the vehicle first.", "basic"] spawn life_fnc_handleMessage;};
                [] spawn life_fnc_redeployMenu;};
            if ((playerSide isEqualTo independent) || (playerSide isEqualTo west && (life_coprole in ["medic", "all"]))) then {
                [] spawn life_fnc_medicRespondMenu;};
            if (!isNil "life_adminEvent" && !life_inEvent) then {if (life_adminEvent select 0 && playerSide isEqualTo civilian) then {
                    if (life_adminEvent select 2 isEqualTo 1) then {[2] spawn life_fnc_eventGunGameClient;};
                    if (life_adminEvent select 2 isEqualTo 2) then {[] spawn life_fnc_eventBRClient;};
                    if (life_adminEvent select 2 isEqualTo 4) then {["startEvent"] spawn life_fnc_eventGraveyardClient;};
                    if ((life_adminEvent select 2) isEqualTo 7) then {[] spawn life_fnc_eventSmirnoffJumpingClient;};};};
            // owner 2026-06-13: civilians -> "Gangs Online" roster (9 has no APD-redeploy / medic-respond
            // binding on this side). Skipped while participating in an admin event (that owns 9 for civs).
            if (playerSide isEqualTo civilian && !life_inEvent && {isNil "life_adminEvent" || !(life_adminEvent param [0, false])}) then {
                [] call life_fnc_gangListMenu;};
            // owner 2026-06-22 (#498): cops get the same "Gangs Online" roster on 9. 9 is APD redeploy for cops
            // while life_copEviReq is set (and medic-respond for medic-role cops), so open the roster ONLY when 9
            // isn't already claimed -> redeploy is untouched. The cop phone button "Gangs Online" covers the case
            // where redeploy owns 9. life_fnc_gangListMenu is side-agnostic (just reads broadcast gang_data).
            if (playerSide isEqualTo west && {isNil "life_copEviReq"} && {!(life_coprole in ["medic", "all"])} && !life_inEvent) then {
                [] call life_fnc_gangListMenu;};};
    case 15: {
            if (playerSide isEqualTo west && !_alt && !_ctrlKey && !dialog && vehicle player != player && (driver(vehicle player)) == player) then {
                private _veh = vehicle player;
                if (!(_veh getVariable["plb_side", ""] isEqualTo "cop")) exitWith {};
                [] call life_fnc_p_openLightSwitchBox;
                _handled = true;} else {if (!_alt && !_ctrlKey && dialog && !((findDisplay 96000) isEqualTo displayNull)) then {
                    closeDialog 0;
                    _handled = true;};
                if (!_alt && !_ctrlKey && !_shift && !dialog && !life_isDowned) then {
                    if (player getVariable["plb_surrendered", false]) then {player setVariable["plb_surrendered", false, true];} else {
                        [] spawn life_fnc_surrender;};
                    _handled = true;};};};
    case 22: {if (!_alt && !_ctrlKey) then {private _veh =
                if (vehicle player isEqualTo player) then {cursorObject} else {vehicle player;};
                private _vehType = typeOf _veh;
                private _otherDoorObjects = ["Land_City_Gate_F", "Land_Stone_Gate_F"];
                if (player getVariable["plb_restrained", false] || player getVariable["plb_downed", false]) exitWith {
                    ["How could you possibly reach your keys right now?", "basic"] spawn life_fnc_handleMessage};
                if !(_veh isKindOf "House_F" || _vehType in _otherDoorObjects) exitWith {private _locked = locked _veh;
                    private _owners = _veh getVariable["plb_vehOwners", []];
                    private _ownsVehicle = !(_owners findIf {getPlayerUID player in _x}
                    isEqualTo - 1);
                    if ((_ownsVehicle || _veh in life_vehicles) && player distance _veh < 10) then {if (_locked isEqualTo 2) then {
                            _veh lock 0;
                            if !(local _veh) then {[[_veh, 0], "life_fnc_lockVehicle", _veh] spawn life_fnc_MP};
                            PlaySound "unlock";
                            systemChat "You have unlocked your vehicle.";} else {_veh lock 2;
                            if !(local _veh) then {[[_veh, 2], "life_fnc_lockVehicle", _veh] spawn life_fnc_MP};
                            PlaySound "car_lock";
                            systemChat "You have locked your vehicle.";};
                        [_veh] call life_fnc_slingAndMass;};};
                if (_veh isKindOf "House_F" || _vehType in _otherDoorObjects) exitWith {private _door = [_veh] call life_fnc_nearestDoor;
                    if (_door isEqualTo 0) exitWith {["You are not near a door.", "basic"] spawn life_fnc_handleMessage;};
                    private _locked = _veh getVariable[format["bis_disabled_Door_%1", _door], 0];
                    private _shopDoor = false;
                    if ((typeOf _veh in ["Land_i_Shop_01_V1_F", "Land_i_Shop_01_V2_F", "Land_i_Shop_01_V3_F"]) && (_door == 1 || _door == 3)) then {
                        _shopDoor = true;};
                    if ((_veh in life_vehicles || _veh in life_gangBuilding || ([_veh, getPlayerUID player, "accessLock"] call life_fnc_keyHolderStatus)) && playerSide isEqualTo civilian && !(_shopDoor)) then {
                        if ((_veh getVariable["plb_house_tax", [false]]) select 0) exitWith {
                            ["houseTaxAccess"] call life_fnc_manageHouseTax;};
                        if (_locked isEqualTo 0) then {_veh setVariable[format["bis_disabled_Door_%1", _door], 1, true];
                            _veh animate[format["door_%1_rot", _door], 0];
                            systemChat "Door locked.";} else {_veh setVariable[format["bis_disabled_Door_%1", _door], 0, true];
                            _veh animate[format["door_%1_rot", _door], 1];
                            systemChat "Door unlocked.";};} else {if (_locked isEqualTo 0) then {private _getAnimDoor =
                            switch (true) do {case (_vehType isEqualTo "Land_Hospital_main_F" && _door in [2, 3, 4]): {
                                        ["door_%1a_move", "door_%1b_move"]};
                                case (_vehType isEqualTo "Land_FuelStation_01_shop_F" && _door isEqualTo 1): {
                                        ["door_%1a_rot", "door_%1b_rot"]};
                                case (_vehType in ["Land_Carrier_01_island_01_F", "Land_Carrier_01_island_02_F"]): {
                                        ["door_handle_%1_rotate_1", "door_%1_rotate"]};
                                default {["door_%1_rot"]};}; private _doorState =
                            if ((_veh animationPhase format[_getAnimDoor select 0, _door]) isEqualTo 1) then {0} else {1}; {
                                _veh animate[format[_x, _door], _doorState];}
                            forEach _getAnimDoor;
                            if (_doorState isEqualTo 1) then {systemChat "Door opened.";} else {systemChat "Door closed.";};} else {
                            if ((call life_copLevel) >= 5 || (call life_medicLevel) >= 4) then {
                                if (_veh animationPhase format["door_%1_rot", _door] isEqualTo 1) then {
                                    _veh animate[format["door_%1_rot", _door], 0];
                                    systemChat "Door closed. (Player Home)";} else {_veh animate[format["door_%1_rot", _door], 1];
                                    systemChat "Door opened. (Player Home)";};} else {titleText["This door is locked!", "PLAIN"];};};};};};
        };
    case 33: {if !(playerSide in [west, independent]) exitWith {};
            if !(isNull(findDisplay 2400)) exitWith {};
            private _veh = vehicle player;
            if ((player isEqualTo(driver vehicle player)) && !(isNull objectParent player) && !(isNull _veh)) then {
                if (playerSide isEqualTo west && !(_veh getVariable["plb_side", ""] isEqualTo "cop")) exitWith {};
                if (playerSide isEqualTo independent && !(_veh getVariable["plb_side", ""] isEqualTo "med")) exitWith {};
                if (_veh getVariable["plb_siren", false]) then {titleText["Sirens Off", "PLAIN", 0.1];
                    _veh setVariable["plb_siren", false, true];
                    if !(isNull life_siren_obj) then {deleteVehicle life_siren_obj;};} else {titleText["Sirens On", "PLAIN", 0.1];
                    _veh setVariable["plb_siren", true, true];
                    if !(isNull life_siren_obj) then {deleteVehicle life_siren_obj};
                    life_siren_obj = createVehicle["Land_ClutterCutter_small_F", [0, 0, 0], [], 0, "CAN_COLLIDE"];
                    life_siren_obj allowDamage false;
                    life_siren_obj enableSimulation false;
                    life_siren_obj attachTo[_veh, [0, 1, 0]];
                    switch (playerSide) do {case west: {
                                if ((typeOf _veh) in ["B_MRAP_01_F", "I_MRAP_03_F", "O_MRAP_02_F", "O_APC_Wheeled_02_rcws_v2_F"]) then {[
                                        [_veh, "siren2", life_siren_obj, player], "life_fnc_copSiren", -2, false, false] spawn life_fnc_MP;
                                } else {if !(_ctrlKey || _shift) then {[
                                            [_veh, "SirenWail", life_siren_obj, player], "life_fnc_copSiren", -2, false, false] spawn life_fnc_MP;
                                    } else {if (_ctrlKey) then {[
                                                [_veh, "SirenYelp", life_siren_obj, player], "life_fnc_copSiren", -2, false, false] spawn life_fnc_MP;
                                        };
                                        if (_shift) then {[
                                                [_veh, "SirenPhaser", life_siren_obj, player], "life_fnc_copSiren", -2, false, false] spawn life_fnc_MP;
                                        };};};
                                if !(_veh getVariable["plb_lights", false]) then {[vehicle player] call life_fnc_sirenLights;};};
                        case independent: {if !(_ctrlKey || _shift) then {private _wailType =
                                    if (typeOf _veh in ["O_Truck_03_medical_F", "O_Truck_03_fuel_F"]) then {"medicQwail"} else {
                                        "medicWail"}; [
                                        [_veh, _wailType, life_siren_obj, player], "life_fnc_medicSiren", -2, false, false] spawn life_fnc_MP;
                                } else {if (_shift) then {[
                                            [_veh, "medicYelp", life_siren_obj, player], "life_fnc_medicSiren", -2, false, false] spawn life_fnc_MP;
                                    };};
                                if !(_veh getVariable["plb_lights", false]) then {[vehicle player] call life_fnc_medicSirenLights;};};
                        default {};};};};
            _handled = true;};
    case 211: {if (((call life_adminLevel) <= 2) || (dialog) || (visibleMap)) exitWith {};
            if (isNull cursorObject) exitWith {
                ["Make sure you're looking at the object you want to delete!", "basic"] spawn life_fnc_handleMessage;};
            if ((cursorObject isKindOf "landVehicle") || (cursorObject isKindOf "Ship") || (cursorObject isKindOf "Air")) then {[
                    [cursorObject, player], "TON_fnc_adminDelVeh", 2] spawn life_fnc_MP;};};}; if (_shift && (_code isEqualTo 20)) then {
	private _cooldown = 15;
	 if (call life_copLevel >= 3 && side player == west && 40 in life_cop_talents) then {_cooldown = 10;};
	if (life_last_ping > time - _cooldown) exitWith { ["You cannot use Tactical Ping repetitively!", "basic"] spawn life_fnc_handleMessage; };
	private _pingPosition = [0,0,0];
	private _text = "ping";

	_pingPosition = lineIntersectsSurfaces [AGLToASL positionCameraToWorld [0,0,0], AGLToASL positionCameraToWorld [0,0,3000], objNull,
		vehicle player, true, 1,"FIRE","VIEW", true];

	switch (true) do {case !(isNull cursorObject): {
			_pingPosition = if (count _pingPosition isEqualTo 0) then {getPos cursorObject} else {ASLToAGL (_pingPosition select 0 select 0)};
			_text = format ["%1:", (getText (configFile >> "CfgVehicles" >> (typeOf cursorObject) >> "DisplayName"))];};
		case !(isNull cursorTarget): {
			_pingPosition = if (count _pingPosition isEqualTo 0) then {getPos cursorTarget} else {ASLToAGL (_pingPosition select 0 select 0)};
			_text = format ["%1:", (getText (configFile >> "CfgVehicles" >> (typeOf cursorTarget) >> "DisplayName"))];};
		default {_pingPosition = screenToWorld [0.5,0.5];
			_text = "E:"};};
	private _countPingNames = {((_x) find _text) >= 0} count life_ping_list;
	_text = if (_countPingNames >= 0) then {format ["%1(%2) ", _text, (_countPingNames + 1)]} else {format ["%1", _text]};
	// owner 2026-06-14 (#174) reconcile: tac pings reach ONLY confirmed team-mates. The shared default civ slot-group is
	// NOT a real team, so verify against the authoritative rosters (own gang_data / a REGISTERED squad) before sending --
	// else pings leak to random ungrouped players. (Keeps infamous's raycast ping position above + the ping sound below.)
	private _grp = group player;
	private _myGangId = if (life_gang_data isEqualTo []) then { -1 } else { life_gang_data select 0 };
	private _inGang  = (_myGangId isNotEqualTo -1) && {(_grp getVariable ["gang_id", -1]) isEqualTo _myGangId};
	private _inSquad = (randomized_life_group_list findIf { (_x select 1) isEqualTo _grp }) >= 0;
	private _toSend = if (_inGang || _inSquad) then {(units _grp) select { isPlayer _x && {(_x distance player) <= 1000} }} else {[player]};
	if !(player in _toSend) then { _toSend pushBack player; };
	[[_pingPosition, _text], "life_fnc_tacticalPing", _toSend] spawn life_fnc_MP;
	life_last_ping = time;
	_handled = true;
	playsound "TacticalPing4";};
if (_shift && (_code isEqualTo 48)) then {if (life_inv_spraycan isEqualTo 0) exitWith {
        ["You need a spray can to spray!"] spawn life_fnc_handleMessage};
    
    if ((life_inv_spraycan >= 1) && (isNull life_sprayObject)) exitWith {["createSpray", [cursorObject]] spawn life_fnc_sprayPaint;};
    if ((life_inv_spraycan >= 1) && !(isNull life_sprayObject)) exitWith {["setSpray", [life_sprayObject]] spawn life_fnc_sprayPaint;};};
if (_code isEqualTo 11) then {if !(isNull(findDisplay 385000)) then {(findDisplay 385000) closeDisplay 0;};};
if (_shift && (_code isEqualTo 2)) then {if (playerSide isEqualTo independent) exitWith {[] spawn life_fnc_medicRespondMenu};};
if (_code in (actionKeys "User3")) then {if (!_alt && !_ctrlKey) then {if (player getVariable["plb_restrained", false]) then {
            ["You cannot access your inventory while you're restrained!", "basic"] spawn life_fnc_handleMessage;} else {
            [true, true] spawn life_fnc_inventory;
            _handled = true;};};};
if (_code in (actionKeys "User4")) then {
    if ((isNull objectParent player) && cursorObject isKindOf "CAManBase" && (isPlayer cursorObject) && speed player < 1 && speed cursorObject < 1 && alive cursorObject && alive player && cursorObject distance player < 3 && !(cursorObject getVariable["plb_escorting", false]) && !(cursorObject getVariable["plb_restrained", false])) then {
        if ((cursorObject getVariable["plb_downed", false]) || (cursorObject getVariable["plb_surrendered", false])) then {
            if !(player getVariable["plb_restrained", false] || player getVariable["plb_downed", false] || player getVariable["plb_surrendered", false]) then {
                if ((playerSide isEqualTo west) && {side cursorObject isEqualTo west}) exitWith {
                    ["Trying to be corrupt are we?", "basic"] spawn life_fnc_handleMessage;};
                if ((playerSide isEqualTo civilian) && {life_inv_ziptie < 1}) exitWith {};
                if (playerSide isEqualTo independent) exitWith {
                    ["You're a medic. Let's leave the fuzzy handcuffs at home.", "basic"] spawn life_fnc_handleMessage;};
                if (time - life_last_restrained > 5) then {[cursorObject] spawn life_fnc_restrain;
                    life_last_restrained = time;} else {
                    ["You cannot rapidly use the restrain action key!", "basic"] spawn life_fnc_handleMessage;};};};};};
if (_code in (actionKeys "User8")) then {[] call life_fnc_radar;};
if (_code in (actionKeys "User5")) then {if (isNull objectParent player) then {[] spawn life_fnc_autoRun;} else {
        [] spawn life_fnc_autoDrive;};};
if (_code in (actionKeys "User9")) then {if (!_alt && !_ctrlKey) then {closeDialog 0;
        _handled = true;
        if ([false, "spikeStrip", 1] call life_fnc_handleInv) then {[] spawn life_fnc_spikeStrip;};};};
if (_code in (actionKeys "User15")) then {if (playerSide isEqualTo civilian) then {if (vest player == "V_HarnessOGL_brn") then {
            if (life_clothing_store isEqualTo "") then {if (alive player && {playerSide isEqualTo civilian} && {
                    !(player getVariable["plb_downed", false])} && {!(player getVariable["plb_restrained", false])} && {
                    !(player getVariable["plb_escorting", false])} && {!(player getVariable["plb_transporting", false])}) then {
                    ["self"] spawn life_fnc_suicideVest;};};};};
    _handled = true;};
if (_code in (actionkeys "User7")) then {if (playerside isEqualTo west) then {if ((call life_copLevel) >= 2) then {
            private _notificationText =
            if (player getVariable["plb_nonlethal", false]) then {"You have loaded lethal rounds."} else {
                "You have loaded non-lethal rounds."};
            [_notificationText, "basic"] spawn life_fnc_handleMessage;
            [] spawn life_fnc_nonLethal;};};};
if (_code in (actionKeys "User13")) then {if (player distance cursorObject < 3.5) then {[cursorObject, false] spawn life_fnc_lockpick;};
    _handled = true;};
if (_code in (actionkeys "User16")) then {if (playerSide isEqualTo independent && ((call life_adminLevel) <= 2)) exitWith {};
    if (playerSide isEqualTo civilian && ((call life_adminLevel) <= 2) && (life_bounty_list isEqualTo[]) && (A_stats_crimes select 0) < 0) exitWith {};
    if !(isNull(findDisplay 39500)) exitWith {};
    [] call life_fnc_wantedMenu;};
if (_code in (actionkeys "User17")) then {player playActionNow "gestureYes"};
if (_code in (actionkeys "User18")) then {player playActionNow "gestureNo"};
if (_code in (actionkeys "User19")) then {player playActionNow "gestureGo"};
if (_code in (actionkeys "User20")) then {
    // Open the Cyberdeck home menu (was the Halt/Stop gesture). Capture the aimed target NOW, before the
    // dialog frees the mouse, so life_fnc_cyberdeckHome can lock onto it.
    if ((call PLB_fnc_hasDeck)) then {PLB_cdTarget = cursorObject;
        [] spawn life_fnc_cyberdeckHome;};};
_handled;