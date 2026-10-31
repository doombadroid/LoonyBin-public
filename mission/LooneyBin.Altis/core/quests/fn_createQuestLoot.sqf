params[["_player", objNull, [objNull, []]], ["_virtualArray", [], [[]]], ["_PhysArray", [], [[]]
], ["_questID", -1, [0]], ["_relog", false, [false]]];
private _plb_pos =
if (_player isEqualType[]) then {_player} else {[(getPosATL player), 0, 80, 5, 0, 0.5, 0, [], [[15769.1, 18534.7, 0], [15769.1, 18534.7, 0]
        ]] call BIS_fnc_findSafePos};
private _lootChest = "Box_Syndicate_WpsLaunch_F"
createVehicleLocal _plb_pos;
_lootChest allowDamage false;
_lootChest setPos _plb_pos;
_lootChest setVariable["plb_owner", player];
clearWeaponCargo _lootChest;
clearWeaponCargo _lootChest;
clearMagazineCargo _lootChest;
clearBackpackCargo _lootChest;
clearItemCargo _lootChest;
if !(_PhysArray isEqualTo[]) then {{_lootChest addItemCargo _x}
    forEach _PhysArray;};
_lootChest setVariable["plb_droppedItems", _virtualArray];
_lootChest setVariable["plb_questloot", true];
life_questChestTask = player createSimpleTask["Quest Chest"];
player setCurrentTask life_questChestTask;
life_questChestTaskPos = _plb_pos;
life_questChestTask setSimpleTaskDestination _plb_pos;
life_questChestTask setSimpleTaskDescription["", "Quest Chest", ""];
life_questChestTaskWaypoint = (findDisplay 12 displayCtrl 51) ctrlAddEventHandler["Draw", "
	(_this select 0) drawLine [
		getPos player,
		life_questChestTaskPos,
		[0,0,1,1]
	];
"];
if !(_relog) then {private _restartTime =
    if (isNil "serverStartTime") then {round((14400 - serverTime) / 60)} else {
        round((serverCycleLength - (serverTime - serverStartTime)) / 60)};
    private _serverTime =
    if (_restartTime <= 25) then {5000} else {serverTime};
    profileNamespace setVariable["plb_questChestLootArray", [PLB_SessionID, _plb_pos, _virtualArray, _PhysArray, _questID, _serverTime]];};
private _lootDataSaved = profileNamespace getVariable["plb_questChestLootArray", []];
private _marker = createMarkerLocal[format["seasonal_quest_loot%1", (round random 999999)], _plb_pos];
_marker setMarkerShapeLocal "ICON";
_marker setMarkerTypeLocal "mil_dot";
_marker setMarkerColorLocal "ColorOrange";
_marker setMarkerTextLocal "Quest Chest";
[_relog, _lootDataSaved, _lootDataSaved select 5, _questID] spawn {params["_relog", "_lootDataSaved", "_serverTime", "_questID"];
    uiSleep 5;
    [format["<t color='#c154c1'><t size='1.5'><t align='center'>Quest Chest<br/><br/></t></t></t>Your Completetion of %1 has gave you rewards!<br/><br/>A Loot Chest has been spawned near you, it has also been marked on your map, it contains epic loot!<br/><br/>Quickly grab the loot! before its too late, you must act fast!<br/><br/>but don't worry! Only you can see the chest.", ((["getQuestRowByID", _questID] call life_fnc_questsCfg) select 8), ceil((_serverTime - (serverTime - (25 * 60))) / 60)], "warning"] spawn life_fnc_handleMessage;
};
[_lootChest, _marker] spawn {params["_chest", "_marker"];
    waitUntil {uiSleep 0.25;
        (((_chest getVariable["plb_droppedItems", []]) isEqualTo[]) && (((magazineCargo _chest) + (weaponCargo _chest) + (itemCargo _chest) + (weaponsItemsCargo _chest)) isEqualTo[]))
    };
    deleteVehicle _chest;
    deleteMarkerLocal _marker;
    profileNamespace setVariable["plb_questChestLootArray", []];
    (findDisplay 12 displayCtrl 51) ctrlRemoveEventHandler["Draw", life_questChestTaskWaypoint];
    player removeSimpleTask life_questChestTask};
_lootChest spawn {while {!isNull _this}
    do {private _lootData = profileNamespace getVariable["plb_questChestLootArray", []];
        private _virtualLoot = _this getVariable["plb_droppedItems", []];
        private _physArray = ((magazineCargo _this) + (weaponCargo _this) + (itemCargo _this) + (weaponsItemsCargo _this));
        private _newPhysArray = []; {_newPhysArray pushBack[_x, 1]}
        forEach _physArray;
        if (_lootData isEqualTo[]) exitWith {};
        profileNamespace setVariable["plb_questChestLootArray", [_lootData select 0, _lootData select 1, _virtualLoot, _newPhysArray, _lootData select 4, _lootData select 5]];
        uiSleep 0.15;}; profileNamespace setVariable["plb_questChestLootArray", []];};