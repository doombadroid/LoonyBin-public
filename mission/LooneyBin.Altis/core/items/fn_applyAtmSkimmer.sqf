/*
    life_fnc_applyAtmSkimmer  (LooneyBin, owner 2026-07-16) -- plant an ATM Skimmer on the ATM you're facing.
    Civ-only, needs the $50k rebel "atmskimmer" item. Consumes one, then tells the server to mark the physical
    ATM (server sets plb_skimOwner, persists to DB). Planting on an already-skimmed ATM takes it over.
*/
#include "..\..\macro.h"
if (!hasInterface) exitWith {};
private _atm = cursorObject;
if (isNull _atm) exitWith {};
// physical ATM machines only -- NPC bankers have no ATM object so they never reach here anyway
if (!((typeOf _atm) in ["Land_Atm_01_F","Land_Atm_02_F","Land_Mattaust_ATM","Land_atm"]) && {!([str _atm, "atm_0"] call KRON_StrInStr)}) exitWith {
    ["That's not an ATM you can rig.", "basic"] spawn life_fnc_handleMessage;};
if (playerSide isNotEqualTo civilian) exitWith { ["Only civilians rig ATMs.", "basic"] spawn life_fnc_handleMessage; };
if (life_inv_atmskimmer < 1) exitWith { ["You don't have an ATM Skimmer.", "basic"] spawn life_fnc_handleMessage; };
if ((_atm call life_fnc_atmSkimOwner) isEqualTo (getPlayerUID player)) exitWith {
    ["You already have a skimmer on this ATM.", "basic"] spawn life_fnc_handleMessage;};
if (player distance _atm > 4) exitWith {};

// consume the device up front (client-authoritative inventory, like every other item use)
if !([false, "atmskimmer", 1] call life_fnc_handleInv) exitWith {};
[format ["Rigging the ATM..."], "basic"] spawn life_fnc_handleMessage;
// ATM is a terrain object -> its ref is null over the network; send its POSITION (server keys skimmers by pos)
[["apply", getPosATL _atm, 0, player], "TON_fnc_atmSkimSRV", 2] spawn life_fnc_MP;
