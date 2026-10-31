params[["_caseType", "", [""]]];
switch (_caseType) do {case ("openPresent"): {life_christmasTreeGiftData params["_playerUID", "_needsGift", "_lastTimeOpened"];
            if (_playerUID isNotEqualTo(getPlayerUID player)) exitWith {};
            if !(_needsGift) exitWith {
                [format["You have no available christmas gifts at the moment! Come back tomorrow"], "christmas_present"] spawn life_fnc_handleMessage;
            };
            if (_lastTimeOpened >= time) exitWith {
                [format["Stop trying to abuse santa by robbing him from all his presents. Give him a second you grinch!"], "christmas_present"] spawn life_fnc_handleMessage;
            };
            private _dialogQuestion = ["Do you want to open your christmas gift crate? (doing so is at your own risk if you do not have any room for the items you will receive they will be dropped at your feet)", "Santa's christmas gift", "Yes", "No"] call BIS_fnc_guiMessage;
            if !(_dialogQuestion) exitWith {["You chose not open your christmas Crate!", "christmas_present"] spawn life_fnc_handleMessage;
                closeDialog 0;};
            life_christmasTreeGiftData set[2, (time + 15)];
            ['give'] spawn life_fnc_openChristmasTreePresentCL;}; case ("give"): {
                life_christmasTreeGiftData params["_playerUID", "_needsGift", "_lastTimeOpened"];
                life_christmasTreeGiftData set[1, false];
                (systemTimeUTC) params["", "", "_dayIndex", "", ""];
                (["getTierData", _dayIndex] call life_fnc_christmasTreePresentsCfg) params["_tierIDX", "_lootArray", "_isVirtual", "_isPhysical", "_isVehicle", "_isWeapon"];
                _lootArray params["_itemClassname", "_itemCount"];
                private _rewardString = "";
                switch (true) do {case (_isVirtual): {if (_itemClassname in ["money", "newdrachma"]) then {
                                if (_itemClassname isEqualTo "newdrachma") then {
                                    // NEW DRACHMA: config amount is native ND, server-credited (reason "event").
                                    _rewardString = format["You were given %1 New Drachma directly into your wallet", [_itemCount] call PLB_fnc_ndText];
                                    [_itemCount, "event"] call PLB_fnc_ndRequest;} else {
                                    _rewardString = format["You were given $%1 Cold, Hard Cash directly into your bank account", [_itemCount] call life_fnc_numberText, (["getName", _itemClassname] call life_fnc_virtItemCfg)];
                                    life_atmcash = life_atmcash + _itemCount;
                                    life_atmcashCacheB = ((life_atmcash / 4) + 11);
                                    [1] call life_fnc_ClupdatePartial;};} else {
                                private _totalWeightLeftToCarry = [_itemClassname, _itemCount, life_carryWeight, life_maxWeight] call life_fnc_calWeightDiff;
                                _rewardString = format["You were given %1 %2", [_itemCount] call life_fnc_numberText, (["getName", _itemClassname] call life_fnc_virtItemCfg)];
                                if (_totalWeightLeftToCarry <= 0) then {
                                    [format["You could not hold all these items, they have been dropped on the ground near your feet!"], "christmas_present"] spawn life_fnc_handleMessage;
                                    private _pos =
                                    if (objectParent player isKindOf "Ship") then {(objectParent player) modelToWorld[0, -8, -1]} else {
                                        getPosASL player}; [[[[_itemClassname, _itemCount]
                                            ], _pos, "Land_Suitcase_F"], "TON_fnc_createItem", 2] spawn life_fnc_MP;} else {
                                    if ([true, _itemClassname, _itemCount] call life_fnc_handleInv) then {};};};};
                    case (_isPhysical): {
                            _rewardString = format["You were given a %1", (([_itemClassname] call life_fnc_fetchCfgDetails) param[1, ""])];
                            private _holder = nearestObject[player, "groundWeaponHolder"];
                            [_itemClassname, _itemCount, player, _holder] call life_fnc_dropPhysicalItem;
                            [format["Your loot has been dropped on the ground."], "christmas_present"] spawn life_fnc_handleMessage;};
                    case (_isWeapon): {
                            _rewardString = format["You were given a %1", (([_itemClassname] call life_fnc_fetchCfgDetails) param[1, ""])];
                            private _weaponType =
                            switch (true) do {case (_itemClassname isKindOf["Rifle", configFile >> "CfgWeapons"]): {
                                        [!((primaryWeapon player) isEqualTo ""), "primary weapon"]};
                                case (_itemClassname isKindOf["Launcher", configFile >> "CfgWeapons"]): {
                                        [!((secondaryWeapon player) isEqualTo ""), "secondary weapon"]};
                                case (_itemClassname isKindOf["Pistol", configFile >> "CfgWeapons"]): {
                                        [!((handgunWeapon player) isEqualTo ""), "handgun"]};
                                default {[false, ""]};}; private _action =
                            if ((_itemCount isEqualTo 1) && (_weaponType param[0, false])) then {
                                [format["You already have a %1 equipped, gathering another will replace it. Gather anyway?", _weaponType select 1], "Duplicate Item Warning", "Yes", "No"] call BIS_fnc_guiMessage;
                            } else {true};
                            private _weaponAttachmentsArray = _lootArray param[2, []];
                            private _weaponAmmoArray = _lootArray param[3, []];
                            if (_action && (_itemCount isEqualTo 1) && (_weaponAmmoArray isEqualTo[]) && (count _weaponAttachmentsArray isEqualTo 1)) then {
                                player addWeapon _itemClassname; {player addWeaponItem[_itemClassname, _x]}
                                forEach _weaponAttachmentsArray;
                                [format["Your weapon has been given into your hands!"], "christmas_present"] spawn life_fnc_handleMessage;
                            } else {private _holder = nearestObject[player, "groundWeaponHolder"];
                                [_itemClassname, _itemCount, player, _holder] call life_fnc_dropPhysicalItem;
                                if (_weaponAttachmentsArray isNotEqualTo[]) then {{
                                        private _holder = nearestObject[player, "groundWeaponHolder"];
                                        [_x, 1, player, _holder] call life_fnc_dropPhysicalItem;}
                                    forEach _weaponAttachmentsArray;};
                                if (_weaponAmmoArray isNotEqualTo[]) then {{private _holder = nearestObject[player, "groundWeaponHolder"];
                                        [_x param[0, ""], _x param[1, 0], player, _holder] call life_fnc_dropPhysicalItem;}
                                    forEach _weaponAmmoArray;};
                                [format["Your loot and all its content have fallen to the floor!"], "christmas_present"] spawn life_fnc_handleMessage;
                            };};
                    case (_isVehicle): {life_garageCount = -1; [
                                [getPlayerUID player, playerSide, player], "TON_fnc_garageCount", 2] spawn life_fnc_MP;
                            uiSleep 3;
                            if (life_garageCount >= (call life_maxGarageVeh)) then {
                                private _vehSellPrice = (["getVehicleRowParsed", "", _itemClassname] call life_fnc_vehicleConfig) param[8, 5000];
                                life_atmcash = life_atmcash + _vehSellPrice;
                                life_atmcashCacheB = ((life_atmcash / 4) + 11);
                                [1] call life_fnc_ClupdatePartial;
                                _rewardString = format["Since you had too many vehicles in your garage. You were given $%1 as compensation into your bank account", [_vehSellPrice] call life_fnc_numberText];
                            } else {
                                _rewardString = format["You were awarded a fancy brand new %1!", ([_itemClassname] call life_fnc_fetchCfgDetails) param[1, ""]];
                                [["giveCar", [getPlayerUID player, player, _itemClassname]], "TON_fnc_loginBonusSRV", 2] spawn life_fnc_MP;
                            };};
                    default {};
                }; private _formatString = format["%1. Thank you for playing during the winter", _rewardString, (life_christmasTreeGiftData param[1, 0])];
                [_formatString, "christmas_present"] spawn life_fnc_handleMessage;
                player switchMove ""; [
                    ["updatePlayerData", [getPlayerUID player, player]], "TON_fnc_xmasTreeAndPresentsSRV", 2] spawn life_fnc_MP;};};