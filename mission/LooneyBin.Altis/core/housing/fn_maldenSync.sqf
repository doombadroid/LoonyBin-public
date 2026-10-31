/*
    life_fnc_maldenSync  (LooneyBin, owner 2026-07-11)
    MALDEN MAKEOVER client registry sync (CfgRE targets=1; broadcast by TON_fnc_maldenSRV's swap/unswap).
    A swap replaces the house OBJECT mid-session, but clients built their house registries at login --
    life_vehicles (the fn_lockHouse ownership gate: "can't unlock doors once I switch") and life_gangBuilding
    still point at the OLD object. Replace the ref in place; no-op on clients that never had it.
    args: [_old, _new]
*/
params [["_old", objNull, [objNull]], ["_new", objNull, [objNull]]];
if (!hasInterface) exitWith {};
if (isNull _new) exitWith {};

if (_old in life_vehicles) then {life_vehicles = life_vehicles - [_old];
    life_vehicles pushBackUnique _new;} else {
    // registry never had the old ref (login raced the boot swap / resolve miss): if this client OWNS or
    // key-holds the new building, register it outright -- the door-lock gate must always see the standing object.
    private _uid = getPlayerUID player;
    private _owns = (format ["%1", _new getVariable ["plb_homeOwner", ""]]) isEqualTo _uid;
    private _keyed = ((_new getVariable ["plb_house_keys", []]) findIf { (format ["%1", _x param [0, ""]]) isEqualTo _uid }) > -1;
    if (_owns || _keyed) then { life_vehicles pushBackUnique _new; };};
// gang-house ref (Change/Remove Gang House compares against it)
if ((life_gangBuilding param [0, objNull]) isEqualTo _old) then {life_gangBuilding set [0, _new];};
