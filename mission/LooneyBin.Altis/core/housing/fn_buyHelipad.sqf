/*
    life_fnc_buyHelipad  (LooneyBin, owner 2026-07-10)
    House-menu purchase of the SHED HELIPAD upgrade. Client side: guards + confirm + charge (the
    fn_upgradeProperty idiom: cash first, else bank, cacheB re-arm, [6] partial sync), then hands the
    write + instant comp spawn to TON_fnc_shedHelipadSRV (owner-gated server-side again).
    Sheds only. $1,000,000. One per shed, permanent (no refund path -- it's construction, not furniture).
*/
#define HELIPAD_COST 1000000
params [["_house", objNull, [objNull]]];
if (isNull _house) exitWith {};
if !(typeOf _house isEqualTo "Land_i_Shed_Ind_F") exitWith {
    ["Helipads can only be built on industrial sheds.", "basic"] spawn life_fnc_handleMessage;};
if ((_house getVariable ["plb_homeOwner", ""]) isNotEqualTo (getPlayerUID player)) exitWith {
    ["Only the shed's owner can build a helipad.", "basic"] spawn life_fnc_handleMessage;};
if (_house getVariable ["plb_helipad", false]) exitWith {["This shed already has a helipad.", "basic"] spawn life_fnc_handleMessage;};
if (HELIPAD_COST > life_cash && HELIPAD_COST > life_atmcash) exitWith {
    [format ["You do not have $%1 on-hand or in your bank for the helipad.", [HELIPAD_COST] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
};
private _ok = [
    format ["Build a rooftop helipad on this shed for $%1?<br/><br/>Your air vehicles become pullable and storable right at the shed. The pad stands whenever you (or your gang, for a gang shed) are online.", [HELIPAD_COST] call life_fnc_numberText],
    "Shed Helipad", "Build", "Cancel"] call BIS_fnc_guiMessage;
if !(_ok) exitWith {};
if (life_cash >= HELIPAD_COST) then {life_cash = life_cash - HELIPAD_COST;
    life_cashCacheB = ((life_cash / 4) + 9);} else {life_atmcash = life_atmcash - HELIPAD_COST;
    life_atmcashCacheB = ((life_atmcash / 4) + 11);};
[6] call life_fnc_ClupdatePartial;
[["buy", _house, player], "TON_fnc_shedHelipadSRV", 2] spawn life_fnc_MP;
closeDialog 0;
["Construction crew dispatched...", "basic"] spawn life_fnc_handleMessage;
