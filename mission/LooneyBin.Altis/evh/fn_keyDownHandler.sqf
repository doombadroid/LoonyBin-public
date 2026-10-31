#include "..\macro.h"
#include "\a3\editor_f\Data\Scripts\dikCodes.h"
params["_ctrl", "_code", "_shift", "_ctrlKey", "_alt"];
// owner 2026-07-20: SHIFT+Y (DIK 21) -- ICEBREAKER VISOR quick-hack ring. The fn itself enforces
// "VR goggles worn" + "illegal firmware flashed", so the bind is inert for everyone else.
// owner 2026-07-22: while restrained, the phone (and thus the console) is locked, so SHIFT+Y instead fires the
// CUFF CRACKER -- breach your own restraints, no goggles. Free with the firmware.
if (_shift && {_code isEqualTo 21} && {!_alt} && {!_ctrlKey} && {!dialog} && {alive player}) exitWith {
    if (((player getVariable ["plb_restrained", false]) || {player getVariable ["plb_civRestrained", false]}) && {call PLB_fnc_hasDeck}) then {
        [] spawn life_fnc_qhCuffHack;} else {[] spawn life_fnc_qhDock;           // owner 2026-07-22: visor DOCK replaces the radial ring
    };
    true};
if (_shift && (_code isEqualTo 74 || _code isEqualTo 25)) exitWith {
    ["This feature is disabled on LoonyBin Servers.", "basic"] spawn life_fnc_handleMessage;
    disableUserInput true;
    disableUserInput false;
    true};
if (_code in (actionKeys "Diary") || inputAction "diary" > 0) exitWith {true};
if (visibleMap && {(_ctrlKey || _code isEqualTo 29) && !(currentChannel in [3, 4])}) exitWith {true};
private["_veh", "_locked"];
private _handled = false;
// owner 2026-06-15: CONSUME Shift+T on keydown so Arma's ENGINE tactical ping never fires. The engine ping is
// GROUP-scoped and leaked to the shared civilian slot-group ("tac pings seen by anyone"). The mission's OWN
// pseudo-ping is on KeyUP (fn_keyUpHandler) and is gated to your gang/squad -> it still works; this only kills
// the leaky engine duplicate. (This display's KeyDown EH doesn't fire while a chat/edit box has focus, so it
// never blocks typing a capital T.)
if (_shift && {_code isEqualTo 20} && {!visibleMap}) exitWith { true };
private _interactionKey =
if (((count actionKeys "User10") isEqualTo 0) && life_scrollDisabled) then {219} else {((actionKeys "User10") select 0)};
private _mapKey = ((actionKeys "ShowMap") select 0);
private _interruptionKeys = [17, 30, 31, 32];
private _functionKeys = [4, 5, 6, 24, 15, 20, 38, 33, 34, 22];
private _allowedKeys = [1]; {_allowedKeys append _x}
forEach[actionKeys "User12"];
if ((life_action_in_use) && !(_code in _allowedKeys)) exitWith {};
private _restrained = player getVariable["plb_restrained", false];
if (life_isDowned && {!_restrained}) exitWith {true};
if (_restrained && {((_code in (actionKeys "ShowMap")) && (call life_adminLevel) <= 1)}) exitWith {true};
if (_restrained && {
    _code in (actionKeys "MiniMap") || _code in (actionKeys "MiniMapToggle") || _code in (actionKeys "GetOver") || _code in (actionKeys "ReloadMagazine") || _code in (actionKeys "salute") || _code in (actionKeys "Throw") || _code in (actionKeys "GetOut") || _code in (actionKeys "Eject") || _code in (actionKeys "DefaultAction") || _code in (actionKeys "SitDown") || _code in (actionKeys "MenuSelect") || _code in (actionKeys "ForceCommandingMode") || _code in (actionKeys "PrevAction") || _code in (actionKeys "NextAction") || _code in (actionKeys "Action") || _code in (actionKeys "ActionContext") || _code in (actionKeys "OpenDLCmenu")
}) exitWith {true};
if ((outlw_MR_keybindingMenuActive || outlw_MR_isRepacking) && {_code in (actionKeys "ReloadMagazine")}) exitWith {
    ["You cannot reload while repacking your magazines.", "basic"] spawn life_fnc_handleMessage;
    true};
// LooneyBin: Outlawed mag-repack trigger. The deobf kept the addon but dropped the keybind CHECK that
// opens it (default CTRL+R = [shift F, ctrl T, alt F, key 19=R]). Open the repack dialog on the combo.
if (!isNil "outlw_MR_keybinding" && {!dialog} && {alive player} && {!(outlw_MR_isRepacking)} && {!(outlw_MR_keybindingMenuActive)} && {_shift isEqualTo outlw_MR_shift} && {_ctrlKey isEqualTo outlw_MR_ctrl} && {_alt isEqualTo outlw_MR_alt} && {_code isEqualTo outlw_MR_keybinding}) exitWith {
    call outlw_MR_createDialog;
    true};
if ((call life_adminLevel) >= 2) then {if (_code in (actionKeys("User14"))) then {if !(isNull(findDisplay 12900)) then {closeDialog 0;
        } else {createDialog "life_admin_menu";};};};
// LooneyBin (#23): Custom 4 (User4) = restrain hotkey. fn_restrain self-validates the rest
// (distance, ziptie, passive, west-vs-west). Mirror the scroll-action gating here.
if (_code in (actionKeys "User4")) exitWith {private _t = cursorObject;
    if (alive player && {!isNull _t} && {isPlayer _t} && {alive _t} && {_t isKindOf "CAManBase"} && {(speed _t) < 1} && {isNull objectParent player} && {isNull objectParent _t} && {!(_t getVariable ["plb_restrained", false])}) then {
        private _allowed = if (playerSide isEqualTo west) then { (side _t) != west } else { (_t getVariable ["plb_surrendered", false]) || (_t getVariable ["plb_downed", false]) };
        if (_allowed) then { [_t] call life_fnc_restrain; };};
    true};
if (!isNull findDisplay 7300 && {!(_code in (actionKeys "User12"))}) exitWith {false};
if ((_code in _interruptionKeys) && !(isNull life_sittingChair)) then {[life_sittingChair] spawn life_fnc_handleChair;};
if (_code in (actionKeys "TacticalView")) exitWith {true;};
if (_code in actionKeys "NavigateMenu") then {true};
if (_code in (actionKeys "Gear")) exitWith {if (_restrained) then {
        ["You cannot access your inventory while you're restrained!", "basic"] spawn life_fnc_handleMessage;
        true;};};
if (_code in (actionKeys "GetOver") && speed player > 10) exitWith {[] call life_fnc_jump;
    true;};
if (_code in (actionKeys "PushToTalk") || _code in (actionKeys "PushToTalkSide")) exitWith {if (currentChannel in [0, 1, 6]) then {
        systemChat format["The LoonyBin does not allow voice in this channel."];
        true;};};
if (_code in ((actionKeys "Diary") + (actionKeys "NetworkPlayers") + (actionKeys "forceCommandingMode") + (actionKeys "menuBack"))) exitWith {
    true;};
// owner 2026-06-28 (exact reference parity -- the player-preferred behavior): the 5s name/distance REVEAL pulse fires
// on ~ (DIK 41) + SelectAll + SwitchCommand. The 2026-06-25 User14 workaround (added when ~ was flagged "unusable" by
// Northhhhh, then superseded by a b0100 rollback that restored ~) is REMOVED so the keyset matches the reference 1:1.
// The command-mode keys are STILL consumed here so Arma's squad command menu never pops (players are in real groups).

// prevent command mode 
{if (_code in actionKeys format ["CommandingMenu%1", _x]) exitWith {true};} forEach [0,1,2,3,4,5,6,7,8,9];

if (_code isEqualTo 41 || _code in (actionKeys "SelectAll") || _code in (actionKeys "SwitchCommand")) exitWith {if !(life_targetTag) then {
		[] spawn{life_targetTag = true;
			uiSleep 5;
			life_targetTag = false;};};
	true;};

if (count(actionKeys "User10") != 0 && {(_code in (actionKeys "User10"))}) exitWith {if !(life_action_in_use) then {[] spawn {
            private _handle = [] spawn life_fnc_actionKeyHandler;
            waitUntil {scriptDone _handle};
            if (life_action_in_use) then {life_action_in_use = false;};};};
    true;};
if ((_code in _functionKeys) && {scriptAvailable(0.4)}) exitWith {false;};
if (_alt && _code isEqualTo 62) exitWith {if ((call life_adminlevel) isEqualTo 0) then {[] spawn {disableUserInput true;
            uiSleep 2;
            disableUserInput false;
            disableUserInput true;
            disableUserInput false;};
        _handled = true;};};
switch (_code) do {case 1: {if (life_action_in_use) then {life_action_in_use = false;
                _handled = true;};
            if (playerSide isEqualTo west && !isNil "life_trafficCam") then {[-1] call life_fnc_trafficCams;};};
    case 5: {if (playerSide isEqualTo west && !isNil "life_trafficCam") then {[-1] call life_fnc_trafficCams;};};
    case 6: {if (alive player) then {if (_restrained && (call life_adminLevel) <= 1) then {
                    ["You cannot open your cell phone when you're restrained!", "basic"] spawn life_fnc_handleMessage;} else {
                    if !(dialog) then {[] spawn life_fnc_cellphone;};};};};
    case 7: {
            if (((call life_adminLevel) >= 2) && ((life_adminMode) || (player getVariable["plb_invisOn", false])) && (isNull objectParent player)) then {
                [] call life_fnc_adminTeleportFacing;};};
    case 9: {if (life_phoneCallStatus isEqualTo 1) then {["answerPhoneCall"] spawn life_fnc_phoneCallClient;};};
    case 10: {if (life_phoneCallStatus isEqualTo 1) then {["declinePhoneCallReciever"] spawn life_fnc_phoneCallClient;};};
    case 11: {
            // owner 2026-06-24: the 0 key opens the online ROSTER -- every GANG with online members AND every active
            // GROUP/squad, each with member names, for civs AND cops. fn_gangListMenu self-toggles (re-press to close);
            // built client-side from broadcast gang_data + allPlayers groups.
            [] call life_fnc_gangListMenu;};
    case 35: {if (!_alt && !_ctrlKey && !dialog && (isNull objectParent player)) then {if !((currentWeapon player) isEqualTo "") then {
                    [true] spawn life_fnc_holsterWeapon;} else {[false] spawn life_fnc_holsterWeapon;};};};
    case 38: {if (playerSide in [west, independent] && _shift && (player isEqualTo(driver vehicle player))) then {
                if (!(isNull objectParent player) && (objectParent player != player)) then {if (!isNil {
                        vehicle player getVariable "plb_lights"}) then {if (playerSide isEqualTo west) then {
                            [vehicle player] call life_fnc_sirenLights;} else {[vehicle player] call life_fnc_medicSirenLights;};
                        _handled = true;};};};};
    case _interactionKey: {if (!(life_action_in_use) && life_scrollDisabled) then {[] spawn {
                    private _handle = [] spawn life_fnc_actionKeyHandler;
                    waitUntil {scriptDone _handle};
                    life_action_in_use = false;};};};
    case 20: {if !(isNull(findDisplay 2400)) exitWith {};
            // owner 2026-06-18 (#367): a vehicle you OWN but relogged/world-restored with isn't in life_vehicles
            // (life_vehicles = your KEYCHAIN). Login rebuilds the keychain from a server list (`_this select 18`)
            // that misses out-in-world vehicles (stream-in timing) -> the trunk keybind (gated on `in
            // life_vehicles`) failed = "can lock/unlock but can't open the trunk until you store+pull". plb_vehOwners
            // (the PERSISTED owner/keyholder list lock/unlock use) IS restored, so if you're in it, restore the key
            // to your keychain here -> the `in life_vehicles` checks below pass. (keyDrop also clears plb_vehOwners,
            // so a key you intentionally dropped won't match -> no unwanted re-grant.)
            private _trunkTgt = if (vehicle player != player) then { vehicle player } else { cursorTarget };
            if (!isNull _trunkTgt && {(_trunkTgt isKindOf "Car") || (_trunkTgt isKindOf "Air") || (_trunkTgt isKindOf "Ship") || (_trunkTgt isKindOf "Tank")} && {!(_trunkTgt in life_vehicles)}) then {   // owner 2026-07-23: + Tank (Nyx)
                if (((_trunkTgt getVariable ["plb_vehOwners", [[]]]) findIf { (_x param [0, ""]) isEqualTo (getPlayerUID player) }) != -1) then {
                    life_vehicles pushBackUnique _trunkTgt;};};
            if (!_alt && !_ctrlKey) then {if (vehicle player != player && alive vehicle player && !_shift) then {
                    if ((vehicle player) in life_vehicles) then {[vehicle player, false] spawn life_fnc_openInventory;} else {
                        if ((call life_adminLevel) >= 3) then {[vehicle player, true] spawn life_fnc_openInventory;};};} else {
                    if ((cursorTarget isKindOf "Car" || cursorTarget isKindOf "Air" || cursorTarget isKindOf "Ship" || cursorTarget isKindOf "Tank" || cursorTarget isKindOf "House_F" || typeOf cursorTarget in ["Land_TentA_F", "Land_TentDome_F"]) && player distance cursorTarget < (7 + 0.5 * (sizeOf typeOf cursorTarget)) && vehicle player == player && alive cursorTarget) then {   // owner 2026-07-23: + Tank (Nyx)
                        if (playerSide isEqualTo civilian) then {if (!(life_gang_data isEqualTo[]) && {
                                (cursorTarget getVariable["plb_house_gang", -1] isEqualTo(life_gang_data select 0))}) then {
                                if ((life_gang_data select 2) <= 4) then {[cursorTarget, false] spawn life_fnc_openInventory;};} else {
                                if (cursorTarget in life_vehicles || ([cursorObject, getPlayerUID player, "accessInv"] call life_fnc_keyHolderStatus)) then {
                                    if ((cursorTarget getVariable["plb_house_tax", [false]]) select 0) exitWith {
                                        ["houseTaxAccess"] call life_fnc_manageHouseTax;};
                                    [cursorTarget, false] spawn life_fnc_openInventory;} else {if ((call life_adminLevel) >= 3) then {
                                        [cursorTarget, true] spawn life_fnc_openInventory;};};};} else {
                            if (cursorTarget in life_vehicles || {!(cursorTarget getVariable["plb_locked", true])}) then {
                                [cursorTarget, false] spawn life_fnc_openInventory;} else {if ((call life_adminLevel) >= 3) then {
                                    [cursorTarget, true] spawn life_fnc_openInventory;};};};} else {private _object = cursorObject;
                        private _plb_display = findDisplay 39500;
                        if ((isNull _plb_display) && (_object isKindOf "CAManBase")) then {private _objectActionIDs = actionIDs _object;
                            private _shopActionIndex = _objectActionIDs findIf {
                                "life_fnc_virtualShopMenu" in ((_object actionParams _x) select 1)};
                            private _hasShopAction = _shopActionIndex isNotEqualTo - 1;
                            if (_hasShopAction) then {
                                (_object actionParams _shopActionIndex) params["_title", "_script", "_args", "", "", "", "", "_condition", "_radius"];
                                _condition =
                                if (_condition isEqualTo "") then {"true"} else {_condition};
                                if (((player distance _object) <= _radius) && {call compile _condition}) then {
                                    [_object, player, _shopActionIndex, _args] spawn(compile _script);};};};};};};};
    case 33: {if !(playerSide isEqualTo west) exitWith {};
            private _veh = vehicle player;
            if (!(isNull objectParent player) && !(isNull _veh) && (player isEqualTo(driver vehicle player)) && _shift) then {
                _handled = true;};};
    case 21: {if (!_alt && !_ctrlKey && !dialog) then {[] call life_fnc_p_openMenu;};};}; if (_code in (actionKeys "User2")) then {
    if (!_alt && !_ctrlKey) then {if (isNull objectParent player) then {if !(_restrained) then {if (alive player) then {closeDialog 0;
                    private _idx = (nearestObjects[player, [], 5]) findIf {!((_x getVariable["plb_droppedItems", []]) isEqualTo[])};
                    if !(_idx isEqualTo - 1) then {[nearestObjects[player, [], 3] select _idx] spawn life_fnc_menuPickupItems;};
                    _handled = true;};};};};};
if (_code in (actionKeys "User11")) then {if (life_inv_cocainep > 0) then {[] spawn life_fnc_cocaine;} else {[] spawn life_fnc_redgull;};
    _handled = true;};
if (_code in (actionKeys "User6")) then {if (isNull objectParent player) then {if (life_inv_firstAidKit > 0) then {private _unit =
            switch (true) do {
                case (isPlayer cursorObject && isNull objectParent player && (player distance cursorObject <= 2) && ((damage cursorObject > 0.25) || (cursorObject getHit "legs" >= 0.5))):
                    {cursorObject};
                case (isNull objectParent player && ((damage player > 0.25) || (player getHit "legs" >= 0.5))): {player};
                default {objNull};}; if !(isNull _unit) then {["", "", "", _unit] spawn life_fnc_medKit;
                _handled = true;};} else {["You don't have a Virtual First Aid Kit to use!", "basic"] spawn life_fnc_handleMessage;};
    } else {["You can't use a FAK from within a vehicle!", "basic"] spawn life_fnc_handleMessage;};};
if (_code in (actionKeys "User12")) then {if (life_earplugsToggle && soundVolume isEqualTo life_volume) then {
        0 fadeSound(parseNumber((life_volume * 0.5) toFixed 2));} else {if (soundVolume < (life_volume + 0.01)) then {0 fadeSound 1;
        } else {0 fadeSound life_volume;};};
    systemChat format["Sound volume changed to %1%2.", soundVolume * 100, "%"];
    _handled = true;};
_handled;