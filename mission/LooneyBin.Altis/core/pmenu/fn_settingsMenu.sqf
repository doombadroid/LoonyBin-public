#include "..\..\macro.h"
disableSerialization;
createDialog "ClientSettings";
waitUntil {!isNull(findDisplay 2900)};
private _display = findDisplay 2900;
[_display] spawn life_fnc_p_updateMenu;
private _settingsGroup = _display displayCtrl 2901;
private _fixUniform = _display displayCtrl 2902;
private _favApp = _display displayCtrl 2903;
private _cops = 0; {if ((side _x isEqualTo west) && !(_x getVariable["plb_copRole", ""] in ["sheriff"])) then {private _toAdd =
        switch (_x getVariable["plb_copLevel", 0]) do {case 1: {0.5};
            default {1};}; _cops = _cops + _toAdd;};}
forEach allPlayers;
private _settingsArray = [["HEADER", "Life_RscTextCentered", -1, "Information", ""],
    ["TEXT", "Life_RscText", -1, format["Cop count: %1", _cops], ""], ["HEADER", "Life_RscTextCentered", -1, "View Distances", ""],
    ["SPACER", "Life_RscText", -1, "", ""], ["SLIDER_DISTANCE", "Life_PhoneSliderSettings", 1002, "Foot", "View distance while on foot"],
    ["SLIDER_DISTANCE", "Life_PhoneSliderSettings", 1004, "Car", "View distance while in a land vehicle"],
    ["SLIDER_DISTANCE", "Life_PhoneSliderSettings", 1041, "Air", "View distance while in a air vehicle"],
    ["SPACEREND", "Life_RscText", -1, "", ""], ["HEADER", "Life_RscTextCentered", -1, "Earplug Volume", ""],
    ["SPACER", "Life_RscText", -1, "", ""], ["SLIDER_VOLUME", "Life_PhoneSliderSettings", 1008, "", "Earplug volume"],
    ["SPACEREND", "Life_RscText", -1, "", ""], ["HEADER", "Life_RscTextCentered", -1, "Night Brightness", ""],
    ["SPACER", "Life_RscText", -1, "", ""], ["SLIDER_VOLUME", "Life_PhoneSliderSettings", 1043, "", "Night brightness"],
    ["SPACEREND", "Life_RscText", -1, "", ""], ["HEADER", "Life_RscTextCentered", -1, "Toggle Settings", ""],
    ["SPACER", "Life_RscText", -1, "", ""], ["CHECKBOX", "Life_PhoneCheckboxSettings", 1009, "Phone Ringer:", ""],
    ["CHECKBOX", "Life_PhoneCheckboxSettings", 1010, "Sidechat:", ""], ["CHECKBOX", "Life_PhoneCheckboxSettings", 1011, "Player Tags:", ""],
    ["CHECKBOX", "Life_PhoneCheckboxSettings", 1012, "Environment Sounds:", ""],
    ["CHECKBOX", "Life_PhoneCheckboxSettings", 1018, "Colored Group Hexes:", ""],
    ["CHECKBOX", "Life_PhoneCheckboxSettings", 1019, "Show Player Titles:", ""],
    ["CHECKBOX", "Life_PhoneCheckboxSettings", 1017, "Additional Earplug Level:", ""],
    ["CHECKBOX", "Life_PhoneCheckboxSettings", 1020, "Ignore Incoming Calls:", ""],
    ["CHECKBOX", "Life_PhoneCheckboxSettings", 1021, "Ignore Gang Invites:", ""],
    ["CHECKBOX", "Life_PhoneCheckboxSettings", 1022, "Enable Ambient Life:", ""],
    ["CHECKBOX", "Life_PhoneCheckboxSettings", 1023, "Enable Custom Hexes:", ""],
    ["CHECKBOX", "Life_PhoneCheckboxSettings", 1025, "Enable Dom HUD:", ""],
    ["CHECKBOX", "Life_PhoneCheckboxSettings", 1027, "Enable Dom HUD Flag Icons:", ""],
    ["CHECKBOX", "Life_PhoneCheckboxSettings", 1029, "Enable Dom Flag Icons:", ""],
    ["CHECKBOX", "Life_PhoneCheckboxSettings", 1033, "Enable kill notifications:", ""],
    ["CHECKBOX", "Life_PhoneCheckboxSettings", 1044, "Streamer Mode:", ""], ["SPACEREND", "Life_RscText", -1, "", ""],
    ["HEADER", "Life_RscTextCentered", -1, "Miscellaneous", ""], ["SPACER", "Life_RscText", -1, "", ""],
    ["COMBO", "Life_PhoneRscCombo", 1100, "Hex Icon", "Change your group hex icon"],
    ["COMBO", "Life_PhoneRscCombo", 1101, "Colored Hexes", "Change your group hexes color"],
    ["COMBO", "Life_PhoneRscCombo", 1102, "Spray Image", "Change your spray can image"],
    ["COMBO", "Life_PhoneRscCombo", 1103, "Title Color", "Change your titles color"],
    ["BUTTON", "Life_RscButtonMenu", 1200, "Casino Ban", "Permanently block yourself from the casino app -- an admin must undo it"],
    ["SPACEREND", "Life_RscText", -1, "", ""]];
private _settingsGroupWidth = (ctrlPosition _settingsGroup) select 2;
private _spacing = 0;
private _allGroupControls = []; {_x params["_type", "_class", "_idc", "_text", "_toolTipText", "_evhCode"];
    private _xPos = 0;
    private _width = _settingsGroupWidth;
    private _height = 0.0500;
    private _colorBackground = [0, 0, 0, 0.50];
    private _addSpacing = 0;
    switch (_type) do {case "HEADER": {_addSpacing = 0.005;
                _colorBackground = [0.10, 0.14, 0.05, 0.9]; // deck reskin: section-header bar (was red)
            }; case "SPACER": {_height = 0.0250;
                    _addSpacing = 0.005;};
            case "TEXT": {_height = 0.04;
                    _addSpacing = 0.005;};
            case "SPACEREND": {_height = 0.0250;
                    _addSpacing = 0.02;};
            case "SLIDER_DISTANCE": {private _ctrlLeftText = _display ctrlCreate["Life_RscText", -1, _settingsGroup];
                    _ctrlLeftText ctrlSetPosition[0, _spacing, _width, _height];
                    _ctrlLeftText ctrlSetText _text;
                    _ctrlLeftText ctrlSetFontHeight 0.032;
                    _ctrlLeftText ctrlSetBackgroundColor _colorBackground;
                    _ctrlLeftText ctrlCommit 0;
                    private _ctrlRightText = _display ctrlCreate["Life_RscTextRight", _idc - 1, _settingsGroup];
                    _ctrlRightText ctrlSetPosition[0, _spacing, _width, _height];
                    _ctrlRightText ctrlSetText "12,000m";
                    _ctrlRightText ctrlSetFontHeight 0.032;
                    _ctrlRightText ctrlCommit 0;
                    _xPos = 0.050;
                    _width = _settingsGroupWidth - ((_xPos + _settingsGroupWidth * 0.210));
                    _addSpacing = 0.005;};
            case "SLIDER_VOLUME": {private _ctrlRightText = _display ctrlCreate["Life_RscTextRight", _idc - 1, _settingsGroup];
                    _ctrlRightText ctrlSetPosition[0, _spacing, _width, _height];
                    _ctrlRightText ctrlSetText "[100%]";
                    _ctrlRightText ctrlSetFontHeight 0.032;
                    _ctrlRightText ctrlSetBackgroundColor _colorBackground;
                    _ctrlRightText ctrlCommit 0;
                    _width = _settingsGroupWidth - ((_xPos + _settingsGroupWidth * 0.180));
                    _addSpacing = 0.005;};
            case "CHECKBOX": {private _ctrlLeftText = _display ctrlCreate["Life_RscText", -1, _settingsGroup];
                    _ctrlLeftText ctrlSetPosition[0, _spacing, _width, _height];
                    _ctrlLeftText ctrlSetText _text;
                    _ctrlLeftText ctrlSetFontHeight 0.032;
                    _ctrlLeftText ctrlSetBackgroundColor _colorBackground;
                    _ctrlLeftText ctrlCommit 0;
                    _xPos = _settingsGroupWidth - 0.075;
                    _width = _settingsGroupWidth - _xPos;
                    _addSpacing = 0.005;};
            case "COMBO": {private _ctrlLeftText = _display ctrlCreate["Life_RscText", -1, _settingsGroup];
                    _ctrlLeftText ctrlSetPosition[0, _spacing, _width, _height];
                    _ctrlLeftText ctrlSetText _text;
                    _ctrlLeftText ctrlSetFontHeight 0.032;
                    _ctrlLeftText ctrlSetBackgroundColor _colorBackground;
                    _ctrlLeftText ctrlCommit 0;
                    _xPos = 0.15;
                    _width = _settingsGroupWidth - (_xPos + 0.010);
                    _addSpacing = 0.005;};
            case "SLIDER_MARKER": {private _ctrlLeftText = _display ctrlCreate["Life_RscText", -1, _settingsGroup];
                    _ctrlLeftText ctrlSetPosition[0, _spacing, _width, _height];
                    _ctrlLeftText ctrlSetText _text;
                    _ctrlLeftText ctrlSetFontHeight 0.032;
                    _ctrlLeftText ctrlSetBackgroundColor _colorBackground;
                    _ctrlLeftText ctrlCommit 0;
                    _xPos = 0.1275;
                    _width = _settingsGroupWidth - (_xPos + 0.010);
                    _addSpacing = 0.005;};}; private _ctrl = _display ctrlCreate[_class, _idc, _settingsGroup];
    _ctrl ctrlSetPosition[_xPos, _spacing, _width, _height];
    if (_type in ["HEADER", "SPACER", "SPACEREND", "TEXT"]) then {_ctrl ctrlSetBackgroundColor _colorBackground;};
    if (_type in ["HEADER"]) then {_ctrl ctrlSetText _text;};
    if (_type in ["TEXT"]) then {_ctrl ctrlSetText _text;
        _ctrl ctrlSetFontHeight 0.032;};
    if (_type in ["HEADER", "SPACER", "SPACEREND"]) then {_ctrl ctrlSetFontHeight 0.032;};
    if (_type in ["SLIDER_DISTANCE", "SLIDER_VOLUME", "SLIDER_MARKER", "COMBO"]) then {_ctrl ctrlSetTooltip _toolTipText;};
    if (_type isEqualTo "SLIDER_MARKER") then {_ctrl ctrlAddEventHandler["SliderPosChanged", _evhCode];};
    _ctrl ctrlCommit 0;
    _spacing = _spacing + _height + _addSpacing;
    _allGroupControls pushBack _ctrl;}
forEach _settingsArray;
_fixUniform ctrlSetText "Fix Uniform";
_fixUniform ctrlAddEventHandler["ButtonClick", "[player, _this select 0] spawn life_fnc_fixUniform"];
_favApp ctrlSetText "Select Favorite Apps";
_favApp ctrlAddEventHandler["ButtonClick", "(_this select 0) spawn life_fnc_favoriteApps; closeDialog 0;"];
private _casinoBanBtn = _settingsGroup controlsGroupCtrl 1200;   // LooneyBin: casino self-exclusion
_casinoBanBtn ctrlSetTooltip "Permanently block yourself from the casino app -- an admin must undo it";
_casinoBanBtn ctrlSetText (if (player getVariable ["plb_casinoBanned", false]) then { "Casino Ban (active)" } else { "Casino Ban" });
_casinoBanBtn ctrlEnable !(player getVariable ["plb_casinoBanned", false]);
_casinoBanBtn ctrlAddEventHandler["ButtonClick", { [] spawn life_fnc_casinoBanConfirm; }];
if (time < life_uniformCooldown) then {_fixUniform ctrlEnable false;
    [_fixUniform] spawn {if !(params[["_button", controlNull]]) exitWith {};
        while {!isNull _button}
        do {private _timeRemaining = toArray([ceil(life_uniformCooldown - time), "MM:SS"] call BIS_fnc_secondsToString);
            if ((_timeRemaining select 0) in [48]) then {_timeRemaining deleteAt 0};
            private _timeRemaining = toString _timeRemaining;
            _button ctrlSetText format["Fix Uniform [%1]", _timeRemaining];
            uiSleep 1;}; _button ctrlSetText "Fix Uniform";
        _button ctrlEnable true;};};
private _clientSettings = profileNamespace getVariable["PLBClientSettings", life_clientDefaultSettings]; {
    _x params["_controlIDC", "_viewDistance", "_updateMode"];
    (_display displayCtrl(_controlIDC + 1)) sliderSetSpeed[100, 100, 100];
    slidersetRange[_controlIDC + 1, 100, 12000];
    sliderSetPosition[_controlIDC + 1, _viewDistance];
    ctrlSetText[_controlIDC, format["%1m", [_viewDistance] call life_fnc_numberText]];
    (_display displayCtrl(_controlIDC + 1)) ctrlAddEventHandler["SliderPosChanged", format["[%1, _this select 1] call life_fnc_s_onSliderChange", _forEachIndex]];
}
forEach[[1001, tawvd_foot], [1003, tawvd_car], [1040, tawvd_air]];
slidersetRange[1008, 0.01, 1];
sliderSetPosition[1008, life_volume];
(_display displayCtrl 1008) sliderSetSpeed[0.01, 0.01, 0.01];
ctrlSetText[1007, format["[%1%2]", round(life_volume * 100), "%"]];
(_display displayCtrl 1008) ctrlAddEventHandler["SliderPosChanged", "[7, _this select 1] call life_fnc_s_onSliderChange"];
slidersetRange[1043, 0.01, 1];
sliderSetPosition[1043, life_nightBrightness];
(_display displayCtrl 1043) sliderSetSpeed[0.01, 0.01, 0.01];
ctrlSetText[1042, format["[%1%2]", round(life_nightBrightness * 100), "%"]];
(_display displayCtrl 1043) ctrlAddEventHandler["SliderPosChanged", "[9, _this select 1] call life_fnc_s_onSliderChange"];
private _ringerToggle = _settingsGroup controlsGroupCtrl 1009;
private _sidechatToggle = _settingsGroup controlsGroupCtrl 1010;
private _playerTagsToggle = _settingsGroup controlsGroupCtrl 1011;
private _envSoundsToggle = _settingsGroup controlsGroupCtrl 1012;
private _earplugsVolumeToggle = _settingsGroup controlsGroupCtrl 1017;
private _grpHexToggle = _settingsGroup controlsGroupCtrl 1018;
private _titlesToggle = _settingsGroup controlsGroupCtrl 1019;
private _ignoreCallToggle = _settingsGroup controlsGroupCtrl 1020;
private _ignoreGangInvToggle = _settingsGroup controlsGroupCtrl 1021;
private _enableAmbientLifeToggle = _settingsGroup controlsGroupCtrl 1022;
private _enableCustomHexesToggle = _settingsGroup controlsGroupCtrl 1023;
private _enableDomHudToggle = _settingsGroup controlsGroupCtrl 1025;
private _enableDomHudIconsToggle = _settingsGroup controlsGroupCtrl 1027;
private _enableFlagIconsToggle = _settingsGroup controlsGroupCtrl 1029;
private _enableKillNotificationToggle = _settingsGroup controlsGroupCtrl 1033;
private _streamerModeToggle = _settingsGroup controlsGroupCtrl 1044;
private _hexIconCombo = _settingsGroup controlsGroupCtrl 1100;
private _coloredHexesCombo = _settingsGroup controlsGroupCtrl 1101;
private _sprayImageCombo = _settingsGroup controlsGroupCtrl 1102;
private _titleColorCombo = _settingsGroup controlsGroupCtrl 1103; {private _xControl = _x;
    if (true) then { // LB has no donor subscription -- hex/spray/title combos are free for everyone (was: if (_subscriber))
        switch (_xControl) do {case (_hexIconCombo): {[0] call life_fnc_coloredHexesMenu;};
            case (_coloredHexesCombo): {};
            case (_sprayImageCombo): {[0] call life_fnc_sprayPaintMenu;};
            case (_titleColorCombo): {[0] call life_fnc_titleColorMenu;};
        }; _xControl ctrlSetEventHandler["LBSelChanged", format["[%1, _this select 0, _this select 1] call %2", _forEachIndex, life_fnc_s_onComboChange]];
    } else {_xControl ctrlEnable false;};}
forEach[_hexIconCombo, _coloredHexesCombo, _sprayImageCombo, _titleColorCombo]; {
    (_x select 0) ctrlSetChecked(_clientSettings select(_x select 1))}
forEach[[_ringerToggle, 5], [_envSoundsToggle, 6], [_grpHexToggle, 8], [_titlesToggle, 9], [_earplugsVolumeToggle, 10], [_ignoreCallToggle, 11], [_ignoreGangInvToggle, 12], [_enableAmbientLifeToggle, 13], [_enableCustomHexesToggle, 14], [_enableDomHudToggle, 15], [_enableDomHudIconsToggle, 16], [_enableFlagIconsToggle, 17], [_enableKillNotificationToggle, 19], [_streamerModeToggle, 24]]; {
    (_x select 0) ctrlSetChecked(_x select 1)}
forEach[[_sidechatToggle, life_sidechat], [_playerTagsToggle, life_playerTags]]; {
    (_x select 0) ctrlAddEventHandler["CheckBoxesSelChanged", _x select 1]}
forEach[[_ringerToggle, {params["_control", "_selectedIndex", "_currentState"];
    life_isRingEnabled = (_currentState isEqualTo 1);}], [_sidechatToggle, {params["_control", "_selectedIndex", "_currentState"];
    if ((time - life_last_sold) < 5) exitWith {_control ctrlSetChecked life_sidechat;
        ["You have just changed this setting. Please try again in a moment!", "basic"] spawn life_fnc_handleMessage;};
    life_sidechat = ((_this select 2) isEqualTo 1);
    [life_sidechat] call life_fnc_manageSidechat;
    life_last_sold = time;}], [_playerTagsToggle, {params["_control", "_selectedIndex", "_currentState"];
    life_playerTags = ((_this select 2) isEqualTo 1);
    if (life_playerTags) then {LIFE_ID_PlayerTags = addMissionEventHandler["EachFrame", {call life_fnc_playerTags}];} else {
        removeMissionEventHandler["EachFrame", LIFE_ID_PlayerTags];};}], [_envSoundsToggle, {
    params["_control", "_selectedIndex", "_currentState"];
    life_envSounds = (_currentState isEqualTo 1);
    enableEnvironment[life_ambientLifeEnabled, life_envSounds];}], [_grpHexToggle, {params["_control", "_selectedIndex", "_currentState"];
    life_hexMode = _currentState isEqualTo 1;
    if (life_hexMode) then {[] spawn life_fnc_coloredHexes;};}], [_titlesToggle, {params["_control", "_selectedIndex", "_currentState"];
    life_showTitle = (_currentState isEqualTo 1);
    life_tag_cache = [];}], [_earplugsVolumeToggle, {params["_control", "_selectedIndex", "_currentState"];
    life_earplugsToggle = _currentState isEqualTo 1;}], [_ignoreCallToggle, {params["_control", "_selectedIndex", "_currentState"];
    life_incomingCallsIgnored = _currentState isEqualTo 1;}], [_ignoreGangInvToggle, {
    params["_control", "_selectedIndex", "_currentState"];
    life_gangInvitesIgnored = _currentState isEqualTo 1;}], [_enableAmbientLifeToggle, {
    params["_control", "_selectedIndex", "_currentState"];
    life_ambientLifeEnabled = (_currentState isEqualTo 1);
    enableEnvironment[life_ambientLifeEnabled, life_envSounds];}], [_enableCustomHexesToggle, {
    params["_control", "_selectedIndex", "_currentState"];
    life_isCustomHexesEnabled = _currentState isEqualTo 1;}], [_enableDomHudToggle, {params["_control", "_selectedIndex", "_currentState"];
    life_enableDomHUD = _currentState isEqualTo 1;}], [_enableDomHudIconsToggle, {params["_control", "_selectedIndex", "_currentState"];
    life_enableDomHUDIcons = _currentState isEqualTo 1;}], [_enableFlagIconsToggle, {params["_control", "_selectedIndex", "_currentState"];
    life_enableFlagIcons = _currentState isEqualTo 1;}], [_enableKillNotificationToggle, {
    params["_control", "_selectedIndex", "_currentState"];
    life_enableKillNotifications = _currentState isEqualTo 1;
    player setVariable["plb_ShowPlusIcon", life_enableKillNotifications, true];}], [_streamerModeToggle, {
    params["_control", "_selectedIndex", "_currentState"];
    life_streamerMode = _currentState isEqualTo 1;
    player setVariable["plb_streamerMode", life_streamerMode, true];}]];
waitUntil {isNull _display};
profileNamespace setVariable["PLBClientSettings", [life_wallpaper, tawvd_foot, tawvd_car, tawvd_air, life_volume, life_isRingEnabled, life_envSounds, life_scrollDisabled, life_hexMode, life_showTitle, life_earplugsToggle, life_incomingCallsIgnored, life_gangInvitesIgnored, life_ambientLifeEnabled, life_isCustomHexesEnabled, life_enableDomHUD, life_enableDomHUDIcons, life_enableFlagIcons, life_enablePlusIcon, life_enableKillNotifications, life_nightBrightness, life_enableGroupHud, life_enableInteractiveLockpicking, life_compassHudToggle, life_streamerMode]];