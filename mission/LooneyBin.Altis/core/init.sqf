#include "..\macro.h"
life_message_active = scriptNull;
life_firstSpawn = true;
life_session_completed = false;
life_lastDisplay = -2;
life_loadingScreenStatus = "Setting Up Client, Please Wait...";
private _timeStamp = diag_tickTime;
diag_log "------------------------------------------------------------------------------------------------------";
diag_log format["--------------------------------- Starting %1 Life Client Init ----------------------------------", PLB_worldName];
diag_log "------------------------------------------------------------------------------------------------------";
waitUntil {!isNull player && player == player};
waitUntil {!(isNull(findDisplay 46))};
[true] spawn life_fnc_loadingScreen;
uiSleep 0.05;
["initWelcomeUI"] spawn life_fnc_welcomeUI;
uiSleep 1.5;
waitUntil {!isDedicated || time > 40};
diag_log "::Life Client:: Initialization Variables";
[] call compile PreprocessFileLineNumbers "core\configuration.sqf";
// LooneyBin TEST: Owner-only phone button to toggle auto-granting roles to new players. Condition is
// evaluated at phone-open, so adminLevel need not be set yet here. New players get adminLevel 4 (not 5),
// so they never see this button.
life_phone_buttons pushBack ["Owner Mode", "icons\deck_ownermode.paa", "[] spawn life_fnc_ownerMode", {(getPlayerUID player) isEqualTo "76561190000000001"}, "Owner Mode: toggle ESP + no sway/recoil (you only) + Super Spangle scroll"];
[] call life_fnc_mapData;
// owner 2026-07-20: Kabuki Electronics (Tech) shop map marker. The Eden marker wasn't saved to mission.sqm, and the
// sqm markers live inside a 1113-entity mixed list (risky to hand-edit) -- so create it locally per client here at the
// tech NPC. Move it into mission.sqm later via a clean 3DEN save if you want it editor-visible.
if (hasInterface) then {{_x params ["_mn", "_mp"];
        createMarkerLocal [_mn, _mp];
        _mn setMarkerTypeLocal "loc_Transmitter";   // owner 2026-07-20: tech/electronics icon (markers aren't in the object export; change here if you want a different type)
        _mn setMarkerColorLocal "ColorGreen";
        _mn setMarkerTextLocal "Kabuki Electronics";} forEach [["plb_kabuki_tech",  [17819.666, 18114.539]],   // shop 1 (Sofia-side)
        ["plb_kabuki_tech2", [14145.601, 18678.988]]    // shop 2 (Athira)
    ];};
[] spawn life_fnc_dynamicMapSystem;
diag_log "::Life Client:: Variables initialized";
diag_log "::Life Client:: Eventhandlers completed";
diag_log "::Life Client:: Waiting for server functions to transfer..";
diag_log "::Life Client:: Received server functions.";
life_loadingScreenStatus = "Waiting For Server To Be Ready...";
diag_log "::Life Client:: Waiting for the server to be ready..";
waitUntil {!isNil "life_server_isReady"};
waitUntil {(life_server_isReady || !isNil "life_server_extDB_notLoaded")};
if (!isNil "life_server_extDB_notLoaded" && {!(life_server_extDB_notLoaded isEqualTo "")}) exitWith {
    diag_log "::Life Client:: Server did not load extDB3";
    life_loadingScreenStatus = "Server Side Extension EXTDB3 was not loaded into the engine. Contact an LoonyBin Developer";};
waitUntil {(!isNil "SRV_VehiclesLoaded")};
waitUntil {SRV_VehiclesLoaded};
[] call life_fnc_dataQuery;
waitUntil {life_session_completed};
life_loadingScreenStatus = "Finishing Client Setup...";
[] spawn life_fnc_initStats;
if ((isNil {profileNamespace getVariable "LoonyBinClientSettings"}) || {
    (count(profileNamespace getVariable "LoonyBinClientSettings")) < count life_clientDefaultSettings}) then {life_scrollDisabled = false;
    life_hexMode = false;
    life_showTitle = true;};
private _handle = scriptNull;
switch (playerSide) do {case west: {_handle = [] spawn life_fnc_initCop};
    case civilian: {_handle = [] spawn life_fnc_initCiv};
    case independent: {_handle = [] spawn life_fnc_initMedic};
    case east: {
            // LooneyBin (owner 2026-06-11): 4th-faction TEASER. The 26 OPFOR slots are whitelisted
            // "Coming Soon" -- the faction isn't built and nobody is on the opfor_whitelist yet, so
            // anyone who picks one gets the teaser then bounced back to the lobby. When the faction
            // ships, this case calls its real init + DB whitelist check (mirrors the cop path).
            titleText ["The 4th Faction is COMING SOON.\nThese slots are a teaser and are not playable yet.", "PLAIN DOWN", 1];
            _handle = [] spawn { uiSleep 7; endMission "loser"; };};
    default {};}; waitUntil {scriptDone _handle};
[] call life_fnc_zoneCreator;
player setVariable["plb_restrained", false, true];
player setVariable["plb_escorting", false, true];
player setVariable["plb_transporting", false, true];
diag_log "Past Settings Init";
[] execFSM "core\fsm\client.fsm";
diag_log "Executing client.fsm";
waitUntil {!(isNull(findDisplay 46))};
diag_log "Display 46 Found";
diag_log "::Life Client:: Setting up Eventhandlers";
[] call life_fnc_setupEVH;
diag_log "------------------------------------------------------------------------------------------------------";
diag_log format["---------------------------------- End of %1 Life Client Init :: Total Execution Time %2 seconds -------------------------------------", PLB_worldName, diag_tickTime - _timeStamp];
diag_log "------------------------------------------------------------------------------------------------------";
life_sidechat = true;
if (playerSide isEqualTo civilian || playerSide isEqualTo independent) then {[life_sidechat] call life_fnc_manageSidechat;};
life_loadingScreenStatus = "LoonyBin Client Loaded";
[] call life_fnc_hudSetup;
LIFE_ID_PlayerTags = addMissionEventHandler["EachFrame", {call life_fnc_playerTags}];
[] call life_fnc_settingsInit;
player setVariable["plb_steamid", getPlayerUID player, true];
player setVariable["plb_name", profileName, true];
player switchCamera "EXTERNAL";
if ((playerSide isEqualTo civilian)) then {if ((((profileNamespace getVariable["plb_coloredHexesData", [[-1, ""], []
    ]]) param[0, []]) param[1, ""]) isNotEqualTo "") then {
        player setVariable["plb_coloredHexesData", (((profileNamespace getVariable["plb_coloredHexesData", [[-1, ""], []
        ]]) param[0, []]) param[1, ""]), -2];};};
setPlayerRespawnTime life_respawn_timer;
life_fnc_moveIn = compileFinal "player moveInCargo (_this select 0);";
[] spawn life_fnc_survival;
if (playerSide isEqualTo independent) then {if (124 in life_side_talents) exitWith {life_paycheck = 1500};
    if (123 in life_side_talents) exitWith {life_paycheck = 1000};};
__SETCONST__(life_paycheck, life_paycheck); [{private _units = (player nearEntities[["CAManBase", "Car", "Air", "Ship"], 20]) select {
        isPlayer _x};
    _units = _units - [vehicle player];
    life_tag_cache = life_tag_units;
    life_tag_units = _units;}, [], 1.3] call life_fnc_addPerFrameHandler; [
    ["-INITPLAYER-", player, (profileName), format["initialised as %1 at %2", side player, getPosATL player]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
(findDisplay 12 displayCtrl 51) ctrlAddEventHandler["Draw", {params["_control"];
    _control drawPolygon[life_eviFencePoly, [0, 0, 1, 1]];}];
if (!isNull(findDisplay 17000)) then {closeDialog 0;};
"loadingScreen"
cutText["", "PLAIN"];
[] spawn life_fnc_welcomeCredits;