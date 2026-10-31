#include "..\..\macro.h"
params[["_house", objNull, [objNull]]];
if (isNull _house) exitWith {};
if !(_house isKindOf "House_F") exitWith {};
if (life_action_in_use) exitWith {["You're already performing another action.", "basic"] spawn life_fnc_handleMessage;};
if (life_houseTxn) exitWith {["You are currently in the process of buying or selling a home.", "basic"] spawn life_fnc_handleMessage;};
if (isNil {_house getVariable["plb_homeOwner", ""]}) exitWith {["There is no owner for this house.", "basic"] spawn life_fnc_handleMessage
};
closeDialog 0;
private _houseCfg = [typeOf _house] call life_fnc_houseConfig;
if (_houseCfg isEqualTo[]) exitWith {};
_houseCfg params[["_buyPrice", -1], ["_sellPrice", -1], ["_physInv", []], ["_virtInv", []]];
private _action = [format["Are you sure you want to sell your house? It will sell for: <t color='#8cff9b'>$%1</t>", [_sellPrice] call life_fnc_numberText, _houseCfg select 1], "Sell House", "Sell", "Cancel"] call BIS_fnc_guiMessage;
if (_action) then {if (life_houseTxn) exitWith {
        ["You are currently in the process of buying or selling a home.", "basic"] spawn life_fnc_handleMessage;};
    if (life_lastSoldHouse isEqualTo _house) exitWith {
        ["You cannot sell the same house multiple times! This action has been logged!", "basic"] spawn life_fnc_handleMessage; [
            ["-EXPLOIT-", player, (profileName), format["attempted to sell a house multiple times. Position(XYZ): %1", getPosATL _house]], "TON_fnc_logIt", 2] spawn life_fnc_MP;
    };
    life_lastSoldHouse = _house;
    life_houseTxn = true;
    life_action_in_use = true;
    ["Attempting to sell your house to the bank...", "basic"] spawn life_fnc_handleMessage; [
        [_house, player], "TON_fnc_srvSellHouse", 2] call life_fnc_MP;
    _house setVariable["plb_house_sold", true, true];};