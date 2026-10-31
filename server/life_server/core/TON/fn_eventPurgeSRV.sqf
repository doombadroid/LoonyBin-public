/*
    TON_fnc_eventPurgeSRV  (LooneyBin -- implemented from stub 2026-06-09)
    Admin event: THE PURGE (lawless square, locations 18-21). Start = [_locID] from the eventCfg lambda.
    Client behaviour (fn_eventPurgeClient, initClient'd at spawn) keys on life_adminEvent select 2 == 5;
    kills inside the event add no charges (onPlayerKilled gates on life_inEvent). Server = announce,
    20-min round, close.
*/
params [["_locID", -1, [0]]];
if (life_adminEvent param [0, false]) exitWith {};
if (isNil "life_event_queue") then { life_event_queue = []; };
life_event_queue = [];
life_adminEvent = [true, false, 5, _locID];
publicVariable "life_adminEvent";
private _locData = (["getLocationByID", _locID] call life_fnc_eventCfg);
private _locName = _locData param [1, "?"];
private _purgePos = _locData param [2, [0,0,0]];
// owner 2026-06-24: AUTO-ZONE PURGE. Build the global redzone (map + inArea) + center dot and publish PLB_purgeZone
// for the server-side no-charge gate (TON_fnc_wantedAdd). NO remoteExec to init clients -- CfgRE mode=1 would
// silently block an un-whitelisted server->client call; instead the client watcher in initPlayerLocal sees
// life_adminEvent select 2 == 5 (publicVariable, reliable) and runs fn_eventPurgeClient locally.
deleteMarker "PurgeRedzone"; deleteMarker "PurgeDot";
createMarker ["PurgeRedzone", _purgePos];
"PurgeRedzone" setMarkerShape "ELLIPSE";
"PurgeRedzone" setMarkerSize [450, 450];
"PurgeRedzone" setMarkerBrush "DiagGrid";
"PurgeRedzone" setMarkerColor "ColorRed";
"PurgeRedzone" setMarkerAlpha 0.55;
"PurgeRedzone" setMarkerText "THE PURGE";
createMarker ["PurgeDot", _purgePos];
"PurgeDot" setMarkerType "mil_warning";
"PurgeDot" setMarkerColor "ColorRed";
"PurgeDot" setMarkerText "Purge";
PLB_purgeZone = [_purgePos, 450]; publicVariable "PLB_purgeZone";
[[0, format ["ADMIN EVENT: THE PURGE at %1! All crime is legal inside the red zone for 20 minutes!", _locName]], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
[] spawn {uiSleep 1200;
    if (life_adminEvent param [0, false] && {(life_adminEvent param [2, 0]) isEqualTo 5}) then {
        life_adminEvent = [false, false, 0, 0]; publicVariable "life_adminEvent";
        life_event_queue = [];
        [[0, "The PURGE has ended. Law and order resume!"], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;};
    deleteMarker "PurgeRedzone"; deleteMarker "PurgeDot";
    PLB_purgeZone = nil; publicVariable "PLB_purgeZone";};
