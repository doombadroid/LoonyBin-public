if !(playerSide isEqualTo civilian) exitWith {};
if (life_adminEvent select 1) exitWith {["You cannot join the admin event in progress.", "basic"] spawn life_fnc_handleMessage;};
if (player getVariable["plb_downed", false] || player getVariable["plb_restrained", false] || ((life_is_arrested param [0,0]) isEqualTo 1)) exitWith {
    ["You cannot join the admin event at this time.", "basic"] spawn life_fnc_handleMessage;};
life_inEvent = true;
life_gunGameKills = 0;
private _preEventLoadout = getUnitLoadout player;
private _preEventSkins = life_uniformBackpack_skins;
private _preEventPos =
if (surfaceIsWater(getPosATL player)) then {getPosASL player} else {getPosATL player};
private _plb_player = player;
private _location = (["getLocationByID", (life_adminEvent select 3)] call life_fnc_eventCfg) select 2; [
    [true, player], "TON_fnc_eventParticipants", 2] spawn life_fnc_MP;
[_location, 0, {life_adminEvent select 1 || !(life_adminEvent select 0)}, "Gun Game Admin Event"] spawn life_fnc_uavCinematic;
titleText["Welcome to the Gun Game Admin Event<br/>To win, you must get a kill with each of the 15 weapons<br/>A kill will proceed you to the next weapon<br/>Leaving the play area will kill you<br/>May the best shooter win!", "PLAIN", -1, true, true];
disableUserInput true;
life_old_group = group player;   // owner 2026-06-24: was unset here -> end-of-event joinSilent restored a stale/null group
[player] join grpNull;
if !(isNull objectParent player) then {moveOut player;};
uiSleep 2;
private _plb_pos = _location;
while {_plb_pos isEqualTo _location}
do {_plb_pos = [_location, 1, 250, 1, 0, 0, 0, [], _location] call BIS_fnc_findSafePos;}; player setPos _plb_pos;
[_plb_player] spawn {params[["_plb_player", objNull, [objNull]]];
    private _location = (["getLocationByID", (life_adminEvent select 3)] call life_fnc_eventCfg) select 2;
    while {!isNil "life_adminEvent" && life_adminEvent select 0 && ((life_adminEvent select 2) isEqualTo 1)}
    do {if (player distance _location > 300 && !(player distance(getMarkerPos "Respawn_west") < 1000)) then {_plb_player setDamage 1;
            systemChat "You stepped out of the play area!";};
        uiSleep 1;};};
waitUntil {life_adminEvent select 1 || !(life_adminEvent select 0)};
disableUserInput false;
player switchMove "AmovPercMstpSnonWnonDnon";
if (sunOrMoon < 0.5) then {player action["nvGoggles", player];};
if (life_adminEvent select 1) then {private _defaultGear = [["LMG_Zafir_F", "", "", "", ["150Rnd_762x54_Box", 150], [], ""], [], [],
        ["U_B_Wetsuit", []], ["V_TacVest_oli", []], ["B_Carryall_cbr", [["150Rnd_762x54_Box", 2, 150]]], "H_HelmetB_light", "", [],
        ["ItemMap", "", "", "ItemCompass", "ItemWatch", "Integrated_NVG_F"]];
    player setUnitLoadout _defaultGear; {_x params["_item"];
        private _num = missionNamespace getVariable(format["life_inv_%1", _item]);
        if (_num > 0) then {[false, _item, _num] call life_fnc_handleInv};}
    forEach["defib", "bloodbag", "cocainep", "redgull"];
    waitUntil {!(life_adminEvent select 0) && !life_isDead && !(player distance(getMarkerPos "respawn_west") < 1000)};
    uiSleep 10;}; [[false, player], "TON_fnc_eventParticipants", 2] spawn life_fnc_MP;
if (life_isDead) then {
    ["You have 45 seconds to respawn, in order to keep your pre-event position and loadout!", "warning"] spawn life_fnc_handleMessage;
    uiSleep 45;};
life_inEvent = false;
life_gunGameKills = 0;
player setUnitLoadout _preEventLoadout;
life_uniformBackpack_skins = _preEventSkins;
if (surfaceIsWater _preEventPos) then {player setPosASL _preEventPos} else {player setPosATL _preEventPos};
player setDamage 0;
[player] joinSilent life_old_group;
titleText["You have been given back your previous loadout", "PLAIN"];
[] call life_fnc_hudUpdate;
[] spawn {uiSleep 0.5;
    [uniform player, "setUniform", ""] call life_fnc_clothingTextures;
    [backpack player, "setBackpack", ""] call life_fnc_clothingTextures;
    [] call life_fnc_hudUpdate;};