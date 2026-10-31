#include "..\..\macro.h"
if (scriptAvailable(10)) exitWith {
    ["Please wait a few seconds to allow previous upgrades to finish!", "basic"] spawn life_fnc_handleMessage;};
params[["_property", objNull, [objNull]], ["_mode", "", [""]]];
if (life_houseTxn) exitWith {["You currently have an active transaction, please wait.", "basic"] spawn life_fnc_handleMessage;};
if (isNull _property || _mode isEqualTo "") exitWith {};
if !((_property getVariable["plb_homeOwner", ""]) isEqualTo getPlayerUID player) exitWith {
    ["You don't own this property.", "basic"] spawn life_fnc_handleMessage;};
private _houseCfg = [typeOf _property] call life_fnc_houseConfig;
if (_houseCfg isEqualTo[]) exitWith {};
_houseCfg params[["_buyPrice", -1], ["_sellPrice", -1], ["_physInv", []], ["_virtInv", []]];
if (_buyPrice isEqualTo - 1 || {_sellPrice isEqualTo - 1}) exitWith {};
private _houseID = _property getVariable["plb_houseID", -1];
private _maxPhys = ((_physInv select((count _physInv) - 1)) select 0);
private _maxVirt = ((_virtInv select((count _virtInv) - 1)) select 0);
private _currentPhys = _property getVariable["plb_phys_cap", _maxPhys];
private _currentVirt = _property getVariable["plb_vcap", _maxVirt];
private _hasBarrel = _property getVariable["plb_barrel_unaged", false];
private _hasGreenhouse = _property getVariable["plb_greenhouse_unaged", false];
private _hasLeadContainer = _property getVariable["plb_leadcontainer_unaged", false];
private _nextPhysSpace = 0;
private _nextVirtSpace = 0;
private _index = 0;
private _upgradeCost = -1;
private _barrelCost = 35000;
private _greenhouseCost = 45000;
private _leadContainerCost = 250000;
private _action = false;
_mode = toLower _mode;
if (_houseID isEqualTo - 1) exitWith {["Could not fetch your house ID.", "basic"] spawn life_fnc_handleMessage};
switch (_mode) do {case "vstorage": {if (_currentVirt >= _maxVirt) exitWith {
                ["Your property has the max amount of virtual storage upgrades!", "basic"] spawn life_fnc_handleMessage;}; {
                if ((_x select 0) isEqualTo _currentVirt) then {_index = (_forEachIndex + 1);};}
            forEach _virtInv;
            _nextVirtSpace = ((_virtInv select _index) select 0);
            _upgradeCost = ((_virtInv select _index) select 1);
            if (212 in life_side_talents && {_upgradeCost > 0}) then { _upgradeCost = round (_upgradeCost * 0.65); };   // HOMESTEADER Landlord -35%
            if (_upgradeCost isEqualTo - 1) exitWith {};
            if (_upgradeCost > life_cash && _upgradeCost > life_atmcash) exitWith {
                [format["You do not have %1 on-hand or in your bank to upgrade your property.", [_upgradeCost] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
            };
            _action = [format["Upgrading your property will increase the virtual item storage to %1 space and will cost you $%2. Do you wish to continue with the purchase?", _nextVirtSpace, [_upgradeCost] call life_fnc_numberText], "Increase storage", "Upgrade", "Cancel"] call BIS_fnc_guiMessage;
            if (_action) then {life_houseTxn = true;
                life_action_in_use = true;
                if (life_cash >= _upgradeCost) then {life_cash = life_cash - _upgradeCost;
                    life_cashCacheB = ((life_cash / 4) + 9);} else {life_atmcash = life_atmcash - _upgradeCost;
                    life_atmcashCacheB = ((life_atmcash / 4) + 11);};
                [6] call life_fnc_ClupdatePartial; [
                    [_property, player, _mode, _nextVirtSpace, _houseID], "TON_fnc_updateProperty", 2] spawn life_fnc_MP;
                ["Upgrading the virtual storage on your property...", "basic"] spawn life_fnc_handleMessage;};}; case "pstorage": {
                if (_currentPhys >= _maxPhys) exitWith {
                    ["Your property has the max amount of physical storage upgrades!", "basic"] spawn life_fnc_handleMessage;}; {
                    if ((_x select 0) isEqualTo _currentPhys) then {_index = (_forEachIndex + 1);};}
                forEach _physInv;
                _nextPhysSpace = ((_physInv select _index) select 0);
                _upgradeCost = ((_physInv select _index) select 1);
                if (212 in life_side_talents && {_upgradeCost > 0}) then { _upgradeCost = round (_upgradeCost * 0.65); };   // HOMESTEADER Landlord -35%
                if (_upgradeCost isEqualTo - 1) exitWith {};
                if (_upgradeCost > life_cash && _upgradeCost > life_atmcash) exitWith {
                    [format["You do not have %1 on-hand or in your bank to upgrade your property.", [_upgradeCost] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
                };
                _action = [format["Upgrading your property will increase the physical item storage to %1 space and will cost you $%2. Do you wish to continue with the purchase?", _nextPhysSpace, [_upgradeCost] call life_fnc_numberText], "Increase storage", "Upgrade", "Cancel"] call BIS_fnc_guiMessage;
                if (_action) then {life_houseTxn = true;
                    life_action_in_use = true;
                    if (life_cash >= _upgradeCost) then {life_cash = life_cash - _upgradeCost;
                        life_cashCacheB = ((life_cash / 4) + 9);} else {life_atmcash = life_atmcash - _upgradeCost;
                        life_atmcashCacheB = ((life_atmcash / 4) + 11);};
                    [6] call life_fnc_ClupdatePartial; [
                        [_property, player, _mode, _nextPhysSpace, _houseID], "TON_fnc_updateProperty", 2] spawn life_fnc_MP;
                    ["Upgrading the physical storage on your property...", "basic"] spawn life_fnc_handleMessage;};};
        case "aging": {if (_hasBarrel) exitWith {["This property already has aging capabilities...", "basic"] spawn life_fnc_handleMessage;
                };
                if (_barrelCost > life_cash && _barrelCost > life_atmcash) exitWith {
                    [format["You do not have %1 on-hand or in your bank to upgrade your property.", [_barrelCost] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
                };
                _action = [format["Upgrading your property to have an aging barrel allows you to create valuable liqours at your property and will cost you $%1. Do you wish to continue with the purchase?", [_barrelCost] call life_fnc_numberText], "Add Aging Barrel", "Upgrade", "Cancel"] call BIS_fnc_guiMessage;
                if (_action) then {life_houseTxn = true;
                    life_action_in_use = true;
                    if (life_cash >= _barrelCost) then {life_cash = life_cash - _barrelCost;
                        life_cashCacheB = ((life_cash / 4) + 9);} else {life_atmcash = life_atmcash - _barrelCost;
                        life_atmcashCacheB = ((life_atmcash / 4) + 11);};
                    [6] call life_fnc_ClupdatePartial; [
                        [_property, player, _mode, -1, _houseID], "TON_fnc_updateProperty", 2] spawn life_fnc_MP;
                    ["Adding aging barrel capabilties to your property...", "basic"] spawn life_fnc_handleMessage;};};
        case "greenhouse": {if (_hasGreenhouse) exitWith {
                    ["This property already has greenhouse capabilities...", "basic"] spawn life_fnc_handleMessage;};
                if (_greenhouseCost > life_cash && _greenhouseCost > life_atmcash) exitWith {
                    [format["You do not have %1 on-hand or in your bank to upgrade your property.", [_greenhouseCost] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
                };
                _action = [format["Upgrading your property to have an greenhouse allows you to grow cannabis at your property and will cost you $%1. Do you wish to continue with the purchase?", [_greenhouseCost] call life_fnc_numberText], "Add Greenhouse", "Upgrade", "Cancel"] call BIS_fnc_guiMessage;
                if (_action) then {life_houseTxn = true;
                    life_action_in_use = true;
                    if (life_cash >= _greenhouseCost) then {life_cash = life_cash - _greenhouseCost;
                        life_cashCacheB = ((life_cash / 4) + 9);} else {life_atmcash = life_atmcash - _greenhouseCost;
                        life_atmcashCacheB = ((life_atmcash / 4) + 11);};
                    [6] call life_fnc_ClupdatePartial; [
                        [_property, player, _mode, -1, _houseID], "TON_fnc_updateProperty", 2] spawn life_fnc_MP;
                    ["Adding greenhouse capabilties to your property...", "basic"] spawn life_fnc_handleMessage;};};
        case "leadcontainer": {if (_hasLeadContainer) exitWith {
                    ["This property already has lead container capabilities...", "basic"] spawn life_fnc_handleMessage;};
                if (_leadContainerCost > life_cash && _leadContainerCost > life_atmcash) exitWith {
                    [format["You do not have %1 on-hand or in your bank to upgrade your property.", [_leadContainerCost] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
                };
                _action = [format["Upgrading your property to have an lead container allows you to store more Uranium (Weapon Grade) at your property and will cost you $%1. Do you wish to continue with the purchase?", [_leadContainerCost] call life_fnc_numberText], "Add Lead Container", "Upgrade", "Cancel"] call BIS_fnc_guiMessage;
                if (_action) then {life_houseTxn = true;
                    life_action_in_use = true;
                    if (life_cash >= _leadContainerCost) then {life_cash = life_cash - _leadContainerCost;
                        life_cashCacheB = ((life_cash / 4) + 9);} else {life_atmcash = life_atmcash - _leadContainerCost;
                        life_atmcashCacheB = ((life_atmcash / 4) + 11);};
                    [6] call life_fnc_ClupdatePartial; [
                        [_property, player, _mode, -1, _houseID], "TON_fnc_updateProperty", 2] spawn life_fnc_MP;
                    ["Adding lead container capabilties to your property...", "basic"] spawn life_fnc_handleMessage;};};};