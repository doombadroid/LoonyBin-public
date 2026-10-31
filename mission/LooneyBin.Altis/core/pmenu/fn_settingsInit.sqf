#include "..\..\macro.h"
private _clientSettings = profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings];
private _markerSettings = profileNamespace getVariable["PLBMarkerSettings", life_markerDefaultSettings];
if !((count _clientSettings) isEqualTo(count life_clientDefaultSettings)) then {
    private _missingSettings = life_clientDefaultSettings select[count _clientSettings, (count life_clientDefaultSettings) - 1];
    _clientSettings append _missingSettings;
    profileNamespace setVariable["PLBClientSettings", _clientSettings];};
if !((count _markerSettings) isEqualTo(count life_markerDefaultSettings)) then {
    private _missingSettings = life_markerDefaultSettings select[count _markerSettings, (count life_markerDefaultSettings) - 1];
    _markerSettings append _missingSettings;
    profileNamespace setVariable["PLBMarkerSettings", _markerSettings];};
private _corruptSettings = []; {_x params["_value"];
    private _passed =
    switch (true) do {case (_forEachIndex isEqualTo 0): {((life_wallpapers findIf {(_value isEqualTo(_x select 0)) && (call(_x select 3))
                }) >= 0)};
        case (_forEachIndex isEqualTo 7): {(!(_value) || (call(life_adminLevel) >= 3))};
        default {true};}; private _passed =
    if (!isNil "_x" && {_value isEqualType(life_clientDefaultSettings select _forEachIndex)}) then[{_passed}, {false}];
    if !(_passed) then {_corruptSettings pushBack[_forEachIndex, life_clientDefaultSettings select _forEachIndex];
        [player, [303, "PLBClientSettings", _forEachIndex, str _value]] remoteExec["TON_fnc_wacClient", 2];};}
forEach _clientSettings; {_clientSettings set[_x select 0, _x select 1]}
forEach _corruptSettings; {if (_x isEqualType 1) then {if ((_x > 1) || (_x < 0)) then {_markerSettings set[_forEachIndex, 1]};} else {
        _markerSettings set[_forEachIndex, 1]};}
forEach _markerSettings;
profileNamespace setVariable["PLBClientSettings", _clientSettings];
profileNamespace setVariable["PLBMarkerSettings", _markerSettings];
life_wallpaper = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 0;
tawvd_foot = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 1;
tawvd_car = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 2;
tawvd_air = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 3;
life_volume = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 4;
life_isRingEnabled = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 5;
life_envSounds = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 6;
life_scrollDisabled = false;
life_hexMode = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 8;
life_showTitle = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 9;
life_earplugsToggle = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 10;
life_incomingCallsIgnored = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 11;
life_gangInvitesIgnored = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 12;
life_ambientLifeEnabled = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 13;
life_isCustomHexesEnabled = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 14;
life_enableDomHUD = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 15;
life_enableDomHUDIcons = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 16;
life_enableFlagIcons = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 17;
life_enablePlusIcon = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 18;
life_enableKillNotifications = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 19;
life_nightBrightness = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 20;
life_enableGroupHud = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 21;
life_enableInteractiveLockpicking = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 22;
life_compassHudToggle = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 23;
life_streamerMode = (profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]) select 24;
player setVariable["plb_streamerMode", life_streamerMode, true];
["init"] call life_fnc_brightNight;
tawvd_addon_disable = true;
life_playerTags = true;
life_sidechat = true;
if (life_hexMode) then {[] spawn life_fnc_coloredHexes;};
player setVariable["plb_ShowPlusIcon", life_enablePlusIcon, true];
enableEnvironment[life_ambientLifeEnabled, life_envSounds]; {
    missionNamespace setVariable[_x, (profileNamespace getVariable['PLBMarkerSettings', life_markerDefaultSettings]) select _forEachIndex];
}
forEach["Marker_Town", "Marker_Cop", "Marker_Race", "Marker_Illegal", "Marker_Reb", "Marker_DMV", "Marker_Gas", "Marker_Legal", "Marker_DPs", "Marker_Turfs", "Marker_Garage", "Marker_PlayerHouse", "Marker_Misc"];
[] spawn {{private _alpha =
        switch (MarkerColor _x) do {case ("ColorGreen");
            case ("ColorWhite"): {Marker_Town}; case ("ColorWEST"): {Marker_Cop};
                case ("ColorBrown"): {Marker_Race};
                case ("ColorRed"): {Marker_Illegal};
                case ("ColorEAST"): {Marker_Reb};
                case ("ColorBlue"): {Marker_DMV};
                case ("ColorGUER"): {Marker_Gas};
                case ("ColorYellow");
                case ("ColorCIV"): {Marker_Legal};
                case ("ColorKhaki"): {Marker_DPs};
                case ("ColorUNKNOWN"): {Marker_Turfs};
                case ("ColorOrange"): {Marker_Garage};
                case ("ColorBlack"): {Marker_Misc};
                default {0};}; if !((_x find "phouse_") >= 0) then {_x setMarkerAlphaLocal _alpha} else {
            _x setMarkerAlphaLocal Marker_PlayerHouse};}
    forEach allMapMarkers;};