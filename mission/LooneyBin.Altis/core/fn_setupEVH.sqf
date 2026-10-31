player addEventHandler["HandleDamage", {_this call life_fnc_handleDamage;}];
player addEventHandler["Respawn", {_this call life_fnc_onPlayerRespawn}];
player addEventHandler["Take", {_this call life_fnc_onTakeItem}];
player addEventHandler["FiredMan", {_this call life_fnc_onFired}];
player addEventHandler["Put", {_this spawn life_fnc_onPutItem;}];
player addEventHandler["InventoryClosed", {_this call life_fnc_inventoryClosed}];
player addEventHandler["InventoryOpened", {_this call life_fnc_inventoryOpened}];
player addEventHandler["GetInMan", {_this call life_fnc_getInMan}];
player addEventHandler["GetOutMan", {_this call life_fnc_getOutMan}];
player addEventHandler["HandleRating", {0}];
player addEventHandler["FiredNear", {if ((call life_adminLevel) <= 1) then {life_inCombat = true;
        life_inCombatTime = diag_tickTime;};}];
addMissionEventHandler["EachFrame", {call life_fnc_onEachFrame}];
// Streamer Mode: censor profanity in player names on the MP score table (IDD 175) while it is open. The engine
// repopulates the rows each frame, so we re-apply every frame; gated to streamers and only when the board is up.
// Matches by text content (handles plain text controls and listbox rows) so it is independent of the engine IDCs.
addMissionEventHandler["EachFrame", {if (isNil "life_streamerMode" || {!life_streamerMode}) exitWith {};
    private _d = findDisplay 175;
    if (isNull _d) exitWith {}; {if ((ctrlType _x) isEqualTo 5) then {for "_i" from 0 to ((lbSize _x) - 1) do {private _t = _x lbText _i;
                if (_t isNotEqualTo "") then {private _f = [_t] call life_fnc_profanityFilter;
                    if (_f isNotEqualTo _t) then { _x lbSetText [_i, _f]; };};};} else {private _t = ctrlText _x;
            if (_t isNotEqualTo "") then {private _f = [_t] call life_fnc_profanityFilter;
                if (_f isNotEqualTo _t) then { _x ctrlSetText _f; };};};} forEach (allControls _d);}];
addMissionEventHandler["HandleChatMessage", {call life_fnc_handleChatMessage}];
addMissionEventHandler["ProjectileCreated", {params["_projectile"];
    if ((netId _projectile) isEqualTo "0:0") then {private _projectileClass = typeOf _projectile;
        if (getNumber(configFile >> "CfgAmmo" >> _projectileClass >> "explosive") isEqualTo 1 && {
            (_projectileClass find "Smoke") isEqualTo - 1}) then {private _distanceToExplosion = player distance2D _projectile; [
                [player, [69, _projectileClass, str(getPosATL _projectile), str(getPosATL player), _distanceToExplosion]], "TON_fnc_dongClient", 2] call life_fnc_MP;
            deleteVehicle _projectile;};};}];
if (playerSide isEqualTo civilian) then {player addEventHandler["SeatSwitchedMan", {_this call life_fnc_seatSwitchedMan}];};
player addEventHandler["Killed", {_this spawn life_fnc_onPlayerKilled}];
(findDisplay 46) displayAddEventHandler["MouseButtonDown", "_this call life_fnc_mouseDownHandler"];
(findDisplay 46) displayAddEventHandler["MouseButtonUp", "_this call life_fnc_mouseUpHandler"];
(findDisplay 46) displayAddEventHandler["KeyDown", "_this call life_fnc_keyDownHandler"];
(findDisplay 46) displayAddEventHandler["KeyUp", "_this call life_fnc_keyUpHandler"];
(findDisplay 46) displayAddEventHandler["MouseZchanged", "_this spawn life_fnc_enableActions"];
if (hasInterface) then {(findDisplay 46) displayAddEventHandler["KeyDown", {_this call RWT_fnc_chatcomVerify}];}; [{
    if (cameraView isEqualTo "GROUP") then {player switchCamera "EXTERNAL";};}, [], 0.5] call life_fnc_addPerFrameHandler;
"life_allPointsBulletin"
addPublicVariableEventHandler {if (life_allPointsBulletin isEqualTo[] && playerSide isEqualTo west) exitWith {
        ["The current APB has been lifted!", "copalert"] spawn life_fnc_handleMessage;
        [] call life_fnc_hudUpdate;};
    if (life_allPointsBulletin isEqualTo[]) exitWith {};
    if (getPlayerUID player isEqualTo(life_allPointsBulletin select 1)) exitWith {
        ["AllPointsBulletin", ["An APB has been issued for your arrest!"]] call BIS_fnc_showNotification;
        ["An APB has been issued for your arrest!", "basic"] spawn life_fnc_handleMessage;
        [] call life_fnc_hudUpdate;};
    if !(playerSide isEqualTo west) exitWith {};
    ["AllPointsBulletin", [format["APB issued for the arrest of %1!", life_allPointsBulletin select 0]]] call BIS_fnc_showNotification;
    [format["APB issued for the arrest of %1, their last known location has been marked on your map!", life_allPointsBulletin select 0], "copalert"] spawn life_fnc_handleMessage;
    [] call life_fnc_hudUpdate;
    [] call life_fnc_trackAPB;};