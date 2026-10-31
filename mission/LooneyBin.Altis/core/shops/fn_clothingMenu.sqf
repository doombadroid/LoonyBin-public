if !(params["_target", "_caller", "_actionID", ["_parameters", "", ["", []]]]) exitWith {};
private _type =
if !(_parameters isEqualType[]) then {_parameters} else {_parameters select 0};
private _ndShop =
if !(_parameters isEqualType[]) then {false} else {_parameters select 1};
if ((player distance _target) > 7) exitWith {["You are too far away", "basic"] spawn life_fnc_handleMessage;};
if !((vehicle player) isEqualTo player) exitWith {
    ["This action cannot be performed from within a vehicle", "basic"] spawn life_fnc_handleMessage;};
if (lineIntersects[eyePos player, aimPos _target, player, _target]) exitWith {
    ["It would be hard to buy things through the wall, don't you think?", "basic"] spawn life_fnc_handleMessage;};
if (player getVariable["plb_restrained", false]) exitWith {};
if (player getVariable["plb_surrendered", false]) exitWith {};
if ((_type in ["civ", "dive", "rebcloth", "kart", "skip"]) && !(playerSide isEqualTo civilian) && !(life_coprole in ["all", "detective"])) exitWith {
    ["You need to be a civilian to use this store!", "basic"] spawn life_fnc_handleMessage;};
if ((_type in ["cop", "copdive"]) && !(playerSide isEqualTo west)) exitWith {
    ["You need to be a cop to use this store!", "basic"] spawn life_fnc_handleMessage;};
if ((_type in ["med"]) && !(playerSide isEqualTo independent)) exitWith {
    ["You need to be a medic to use this store!", "basic"] spawn life_fnc_handleMessage;};
// owner 2026-07-13: go-kart clothing store baked to core (Speed Racer 69 pruned) -- open to everyone.
if ((_type in ["skip"]) && !(8 in life_side_talents)) exitWith {
    ["You must be a Master Bounty Hunter to shop here!", "basic"] spawn life_fnc_handleMessage;};
if (life_eviSpawn) exitWith {};
if (player getVariable["plb_surrendered", false]) exitWith {["Put your hands down!", "basic"] spawn life_fnc_handleMessage;};
if ((_type isEqualTo "rebcloth") && !(license_civ_rebel) && !(_target getVariable["plb_turfCloth", false])) exitWith {
    ["You don't have a rebel license to buy from this shop.", "basic"] spawn life_fnc_handleMessage;};
if ((_type isEqualTo "skip") && !(license_civ_bounty)) exitWith {
    ["You don't have a bounty hunter license to buy from this shop.", "basic"] spawn life_fnc_handleMessage;};
private _oldFace = face player;
private _oldGlasses = goggles player;
private _oldHeadgear = headgear player;
private _findSimpleItems = {if !(params[["_itemList", []]]) exitWith {[]};
    private _returnList = []; {if !(_x in (magazines player)) then {_returnList pushBack _x}}
    forEach _itemList;
    _returnList};
private _oldUniform = uniform player;
private _oldUniformItems = [uniformItems player] call _findSimpleItems;
private _oldVest = vest player;
private _oldVestItems = [vestItems player] call _findSimpleItems;
private _oldBackpack = backpack player;
private _oldBackpackItems = [backpackItems player] call _findSimpleItems;
private _oldMagazines = magazinesAmmo player;
private _oldTexture = player getVariable["plb_customTexture", []];
life_dead_gear = [player] call life_fnc_fetchDeadGear;
["Life_Clothing"] call life_fnc_createDialog;
disableSerialization;
// LooneyBin failsafe: ALWAYS terminate the preview camera when this dialog unloads (cancel, Escape,
// buy, or any aborted purchase). The normal terminate (cameraEffect/camDestroy below) is gated on the
// main thread reaching it; an error in buyClothes/saveGear could leave the player locked in the
// preview camera with no way out. This EH fires on close regardless of the main thread.
(findDisplay 3100) displayAddEventHandler ["Unload", {if (!isNil "life_shop_cam" && {!isNull life_shop_cam}) then {
        life_shop_cam cameraEffect ["terminate", "back"];
        camDestroy life_shop_cam;
        camUseNVG false;
        life_shop_cam_vision = false;};}];
life_clothing_store = _type;
life_clothesPurchased = nil;
life_clothing_purchase = [0, 0, 0, 0, 0];
life_shop_cam =
if (isNull life_shop_cam) then {
    "camera"
    camCreate(getPosATL player)} else {life_shop_cam};
waitUntil {!isNull life_shop_cam};
private _distance = 4;
while {_distance > 1}
do {if (!lineIntersects[ATLToASL(player modelToWorld[1, _distance, 2]), ATLToASL(player modelToWorld[0, 0, 1]), player]) exitWith {};
    _distance = _distance - 0.5;}; life_shop_cam camSetTarget(player modelToWorld[0, 0, 1]);
life_shop_cam camSetPos(player modelToWorld[1, _distance, 2]);
life_shop_cam camSetFOV 0.33;
life_shop_cam camSetFocus[50, 0];
life_shop_cam camCommit 0;
showCinemaBorder false;
if (currentVisionMode player isEqualTo 1) then {camUseNVG true;
    life_shop_cam_vision = true;} else {life_shop_cam_vision = false;};
life_shop_cam cameraEffect["internal", "back"];
private _display = findDisplay 3100;
if (isNull _display) exitWith {};
if (_ndShop) then {life_ndShop = true};
private _preNd = life_nd;
private _list = _display displayCtrl 3101;
private _filter = _display displayCtrl 3102;
private _total = _display displayCtrl 3106;
private _price = _display displayCtrl 3107;
private _cancel = _display displayCtrl 1000;
private _purchase = _display displayCtrl 1001;
private _vision = _display displayCtrl 1002;
_purchase ctrlEnable false; {lbClear _x}
forEach[_filter, _list]; {_x ctrlSetText "$0"}
forEach[_total, _price];
if !(_type isEqualTo "faces") then {for "_selection"
    from 0 to 4 do {private _clothesFound =
        switch (_type) do {case "civ": {[_selection] call life_fnc_clothing_civ}; case "cop": {[_selection] call life_fnc_clothing_cop};
                case "skip": {[_selection] call life_fnc_clothing_reb};
                case "rebcloth": {[_selection] call life_fnc_clothing_reb};
                case "dive": {[_selection] call life_fnc_clothing_dive};
                case "copdive": {[_selection] call life_fnc_clothing_copdive};
                case "kart": {[_selection] call life_fnc_clothing_kart};
                case "med": {[_selection] call life_fnc_clothing_med};}; if !(_clothesFound isEqualTo[]) then {private _index =
            switch (_selection) do {case 0: {_filter lbAdd "Uniforms"};
                case 1: {_filter lbAdd "Headgear"};
                case 2: {_filter lbAdd "Glasses"};
                case 3: {_filter lbAdd "Vests"};
                case 4: {_filter lbAdd "Backpacks"};}; _filter lbSetValue[_index, _selection];};};} else {_filter lbAdd "Faces";};
private _oldLoadout = [_oldUniform, _oldHeadgear, _oldGlasses, _oldVest, _oldBackpack];
_purchase ctrlSetEventHandler["ButtonClick", format["[%1] spawn life_fnc_buyClothes", [_type, _oldUniform, _oldHeadgear, _oldGlasses, _oldVest, _oldBackpack]]];   // NEW DRACHMA: spawn (was call) so the async ND debit can block via PLB_fnc_ndBuySync
_vision ctrlSetEventHandler["ButtonClick", "[] call life_fnc_changeVision"];
_list ctrlSetEventHandler["LBSelChanged", format["[_this, '%1', %2] call life_fnc_changeClothes", _type, _oldLoadout]];
_filter ctrlSetEventHandler["LBSelChanged", format["[_this, '%1', %2] call life_fnc_clothingFilter", _type, _oldLoadout]];
_filter lbSetCurSel 0;
// owner 2026-07-10: search box under the list -- each KeyUp re-runs the current category filter through the
// name query (life_clothingFilterArgs is stashed by clothingFilter each real populate). The typed text only
// ever feeds toLower/find, never compile/call, so the live edit field has no script-injection surface.
private _search = _display displayCtrl 3110;
_search ctrlSetText "";
_search ctrlSetEventHandler ["KeyUp", "private _a = uiNamespace getVariable ['life_clothingFilterArgs', []]; if (_a isEqualType [] && {count _a >= 3}) then { (_a + [true]) call life_fnc_clothingFilter; };"];
waitUntil {isNull _display};
[6] call life_fnc_ClupdatePartial;
life_ndShop = false;
life_shop_cam cameraEffect["terminate", "back"];
camDestroy life_shop_cam;
life_clothing_store = "";
camUseNVG false;
life_shop_cam_vision = false;
// LooneyBin: persist a purchased outfit. buyClothes runs while life_clothing_store != "" so its own
// gear save (ClupdatePartial 3) was skipped by the shop guard; now the shop is closed, save the new
// gear so it survives a relog.
if !(isNil "life_clothesPurchased") then { [true] call life_fnc_saveGear; };
if (isNil "life_clothesPurchased") exitWith {if (_type isEqualTo "faces") exitWith {player setFace _oldFace};
    if !(_oldUniform isEqualTo "") then {player forceAddUniform _oldUniform} else {removeUniform player};
    if !(_oldHeadgear isEqualTo "") then {player addHeadgear _oldHeadgear} else {removeHeadgear player};
    if !(_oldGlasses isEqualTo "") then {player addGoggles _oldGlasses} else {removeGoggles player};
    if !((backpack player) isEqualTo "") then {if (_oldBackpack isEqualTo "") then {removeBackpack player} else {removeBackpack player;
            player addBackpack _oldBackpack;
            // owner 2026-06-13: re-apply the invisible-bag hide. This cancel-restore re-creates the worn
            // pack as a FRESH (visible) object, so a previously-bought invisible pack reappeared whenever you
            // reopened + closed the clothing store. plb_invisBag persists the state -> re-hide it globally.
            if (profileNamespace getVariable ["plb_invisBag", false]) then { [true] call life_fnc_invisBag; };
            clearAllItemsFromBackpack player;
            if ((count _oldBackpackItems) > 0) then {{[_x, true, true] call life_fnc_handleItem}
                forEach _oldBackpackItems};};};
    if (((count _oldUniformItems) >= 1) && !((uniform player) isEqualTo "")) then {{[_x, true, false, false, true] call life_fnc_handleItem
        }
        forEach _oldUniformItems};
    if !((vest player) isEqualTo "") then {if (_oldVest isEqualTo "") then {removeVest player} else {removeVest player;
            player addVest _oldVest;
            if ((count _oldVestItems) > 0) then {{[_x, true, false, false, true] call life_fnc_handleItem}
                forEach _oldVestItems};};};
    if ((count _oldMagazines) > 0) then {{player addMagazine _x}
        forEach _oldMagazines};
    [uniform player, "setUniform", ""] call life_fnc_clothingTextures;
    [backpack player, "setBackpack", ""] call life_fnc_clothingTextures;};