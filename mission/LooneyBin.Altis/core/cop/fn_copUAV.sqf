#include "..\..\macro.h"
/*
    life_fnc_copUAV  (LooneyBin, owner 2026-06-25) -- APD Captain+ deploy the uav05 item.
    Consume the item, make sure we hold a UAV terminal, and ask the server (TON_fnc_copUAVSRV) to spawn B_UAV_05_F
    airborne in front of us (it's spawned SERVER-side so it's a real global object). Then open the terminal + connect.
*/
if ((call life_copLevel) < 6) exitWith { ["Only Captain or above can deploy a UAV.", "basic"] spawn life_fnc_handleMessage; };
if (life_inv_uav05 < 1) exitWith { ["You don't have a UAV to deploy. Buy one from the APD shop.", "basic"] spawn life_fnc_handleMessage; };
if !(isNull objectParent player) exitWith { ["Get out of your vehicle first.", "basic"] spawn life_fnc_handleMessage; };
if !([false, "uav05", 1] call life_fnc_handleInv) exitWith {};   // consume the item (false = remove)
// make sure we hold a UAV terminal so we can connect to the drone
if !("B_UavTerminal_01_F" in (assignedItems player)) then { player linkItem "B_UavTerminal_01_F"; };
[[getDir player], "TON_fnc_copUAVSRV", 2] spawn life_fnc_MP;
["UAV deployed in the air ahead. Open your UAV terminal ( \\ key ) and CONNECT to it.", "info"] spawn life_fnc_handleMessage;
