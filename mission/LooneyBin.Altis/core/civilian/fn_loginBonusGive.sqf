params[["_tierIndex", 0, [0]]];
life_loginBonusData params["_playerUID", "_consecutiveDays", "_needsGift", "_wipeProgress"];
if (_playerUID isNotEqualTo(getPlayerUID player)) exitWith {};
if !(_needsGift) exitWith {
    [format["You have no login bonus loot at the moment! You have been playing everyday for the past %1 day(s)", life_loginBonusData param[1, 0]], "basic"] spawn life_fnc_handleMessage;
};
(["getTierData", _tierIndex] call life_fnc_loginBonusCfg) params["_tierIDX", "_lootArray", "_isVirtual", "_isPhysical", "_isVehicle", "_isWeapon"];
_lootArray params["_itemClassname", "_itemCount"];
private _rewardString = "";
switch (true) do {case (_isVirtual): {if (_itemClassname in ["money", "newdrachma"]) then {
                if (_itemClassname isEqualTo "newdrachma") then {
                    // NEW DRACHMA: config amount is native ND, server-credited (reason "loginbonus").
                    _rewardString = format["You were awarded %1 New Drachma directly into your wallet", [_itemCount] call PLB_fnc_ndText];
                    [_itemCount, "loginbonus"] call PLB_fnc_ndRequest;} else {
                    _rewardString = format["You were awarded $%1 Cold, Hard Cash directly into your bank account", [_itemCount] call life_fnc_numberText, (["getName", _itemClassname] call life_fnc_virtItemCfg)];
                    life_atmcash = life_atmcash + _itemCount;
                    life_atmcashCacheB = ((life_atmcash / 4) + 11);
                    [1] call life_fnc_ClupdatePartial;};} else {
                private _totalWeightLeftToCarry = [_itemClassname, _itemCount, life_carryWeight, life_maxWeight] call life_fnc_calWeightDiff;
                _rewardString = format["You were awarded %1 %2", [_itemCount] call life_fnc_numberText, (["getName", _itemClassname] call life_fnc_virtItemCfg)];
                if (_totalWeightLeftToCarry <= 0) then {
                    [format["You could not hold all these items, they have been dropped on the ground near your feet!"], "basic"] spawn life_fnc_handleMessage;
                    private _pos =
                    if (objectParent player isKindOf "Ship") then {(objectParent player) modelToWorld[0, -8, -1]} else {getPosASL player}; [
                        [[[_itemClassname, _itemCount]], _pos, "Land_Suitcase_F"], "TON_fnc_createItem", 2] spawn life_fnc_MP;} else {
                    if ([true, _itemClassname, _itemCount] call life_fnc_handleInv) then {};};};};
    case (_isPhysical): {_rewardString = format["You were awarded a %1", (([_itemClassname] call life_fnc_fetchCfgDetails) param[1, ""])];
            private _holder = nearestObject[player, "groundWeaponHolder"];
            [_itemClassname, _itemCount, player, _holder] call life_fnc_dropPhysicalItem;
            [format["Your loot has been dropped on the ground."], "basic"] spawn life_fnc_handleMessage;};
    case (_isWeapon): {_rewardString = format["You were awarded a %1", (([_itemClassname] call life_fnc_fetchCfgDetails) param[1, ""])];
            private _weaponType =
            switch (true) do {case (_itemClassname isKindOf["Rifle", configFile >> "CfgWeapons"]): {
                        [!((primaryWeapon player) isEqualTo ""), "primary weapon"]};
                case (_itemClassname isKindOf["Launcher", configFile >> "CfgWeapons"]): {
                        [!((secondaryWeapon player) isEqualTo ""), "secondary weapon"]};
                case (_itemClassname isKindOf["Pistol", configFile >> "CfgWeapons"]): {[!((handgunWeapon player) isEqualTo ""), "handgun"]
                    };
                default {[false, ""]};}; private _action =
            if ((_itemCount isEqualTo 1) && (_weaponType param[0, false])) then {
                [format["You already have a %1 equipped, gathering another will replace it. Gather anyway?", _weaponType select 1], "Duplicate Item Warning", "Yes", "No"] call BIS_fnc_guiMessage;
            } else {true};
            private _weaponAttachmentsArray = _lootArray param[2, []];
            private _weaponAmmoArray = _lootArray param[3, []];
            if (_action && (_itemCount isEqualTo 1) && (_weaponAmmoArray isEqualTo[]) && (count _weaponAttachmentsArray isEqualTo 1)) then {
                player addWeapon _itemClassname; {player addWeaponItem[_itemClassname, _x]}
                forEach _weaponAttachmentsArray;
                [format["Your weapon has been given into your hands!"], "basic"] spawn life_fnc_handleMessage;} else {
                private _holder = nearestObject[player, "groundWeaponHolder"];
                [_itemClassname, _itemCount, player, _holder] call life_fnc_dropPhysicalItem;
                if (_weaponAttachmentsArray isNotEqualTo[]) then {{private _holder = nearestObject[player, "groundWeaponHolder"];
                        [_x, 1, player, _holder] call life_fnc_dropPhysicalItem;}
                    forEach _weaponAttachmentsArray;};
                if (_weaponAmmoArray isNotEqualTo[]) then {{private _holder = nearestObject[player, "groundWeaponHolder"];
                        [_x param[0, ""], _x param[1, 0], player, _holder] call life_fnc_dropPhysicalItem;}
                    forEach _weaponAmmoArray;};
                [format["Your loot and all its content have fallen to the floor!"], "basic"] spawn life_fnc_handleMessage;};};
    case (_isVehicle): {life_garageCount = -1; [[getPlayerUID player, playerSide, player], "TON_fnc_garageCount", 2] spawn life_fnc_MP;
            uiSleep 3;
            if (life_garageCount >= (call life_maxGarageVeh)) then {
                private _vehSellPrice = (["getVehicleRowParsed", "", _itemClassname] call life_fnc_vehicleConfig) param[8, 5000];
                life_atmcash = life_atmcash + _vehSellPrice;
                life_atmcashCacheB = ((life_atmcash / 4) + 11);
                [1] call life_fnc_ClupdatePartial;
                _rewardString = format["Since you had too many vehicles in your garage. You were given $%1 as compensation into your bank account", [_vehSellPrice] call life_fnc_numberText];
            } else {
                _rewardString = format["You were awarded a fancy brand new %1!", ([_itemClassname] call life_fnc_fetchCfgDetails) param[1, ""]];
                [["giveCar", [getPlayerUID player, player, _itemClassname]], "TON_fnc_loginBonusSRV", 2] spawn life_fnc_MP;};};
    default {};
}; private _formatString = format["%1. Thank you for playing everyday for the past %2 day(s)", _rewardString, (life_loginBonusData param[1, 0])];
[_formatString, "login_bonus"] spawn life_fnc_handleMessage; [
    ["-LOGINBONUS-", player, profileName, format["Retrieved a login bonus, Loot: %1, Played for %2 Day(s), POS: %3", _lootArray, (life_loginBonusData param[1, 0]), getPosATL player]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
player switchMove "";
life_loginBonusData set[2, false];
["loginbonusopened", 1] call life_fnc_statArrUpdate; [
    ["updatePlayerData", [getPlayerUID player, (life_loginBonusData param[1, 0])]], "TON_fnc_loginBonusSRV", 2] spawn life_fnc_MP;

// owner 2026-07-19: re-baseline the inventory monitor after a login-bonus grant. Weapon/physical/vehicle rewards
// add items OUTSIDE handleInv (addWeapon / dropPhysicalItem / garage), leaving life_invMonitor out of balance so
// the [3] item-count anti-cheat false-flags the legit reward in a burst (every code-3 DONG on GrimReaper followed
// a login bonus). Resync to the current virtual total -- same idiom as fn_dropItems / fn_ClupdateRequest.
private _invMonTotal = 0;
{ _invMonTotal = _invMonTotal + (missionNamespace getVariable [_x, 0]); } forEach life_invMonVars;
life_invMonitor = _invMonTotal + life_invRVar;