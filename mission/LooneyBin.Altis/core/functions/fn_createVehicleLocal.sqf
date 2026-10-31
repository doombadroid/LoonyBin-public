params[["_className", "", [""]], ["_position", [], [[]]
], ["_direction", 0, [0, []]], ["_code", "", [""]], ["_xIsServer", false], ["_loadout", [], [[]]]];
if (_className isEqualTo "" || _position isEqualTo[]) exitWith {};
private _vehicle =
if (isServer && isDedicated) then {_className createVehicle[random 100, random 100, random 100];} else {
    // owner 2026-07-10: an entry carrying a LOADOUT (6th field, getUnitLoadout array from the Eden
    // round-trip) must be a REAL local unit -- simple objects are baked statues and can't wear gear.
    if (_code isEqualTo "" && {_loadout isEqualTo []}) then {createSimpleObject[_className, [random 100, random 100, random 100], true];
    } else {_className createVehicleLocal[random 100, random 100, random 100];};};
waitUntil {!isNull _vehicle};
clearBackpackCargo _vehicle;
clearWeaponCargo _vehicle;
clearMagazineCargo _vehicle;
clearItemCargo _vehicle;
if (isServer && isDedicated) then {_vehicle enableSimulation true;} else {_vehicle enableSimulation false;};
if (_vehicle isKindOf "CAManBase") then {removeAllWeapons _vehicle;
    // owner 2026-07-10: apply the Eden-edited outfit/loadout AFTER the strip (mapExportAll captures
    // getUnitLoadout per NPC; empty = keep the class-default look exactly as before).
    if (_loadout isNotEqualTo []) then {_vehicle setUnitLoadout _loadout;
        _vehicle setVariable ["BIS_enableRandomization", false];
        _vehicle setVariable ["plb_hasLoadout", true];   // NPC init strips (fn_applyCop etc.) skip dressed NPCs
    };
    _vehicle switchMove "AmovPercMstpSnonWnonDnon";};
_vehicle allowDamage false;
_vehicle enableDynamicSimulation false;   // owner 2026-07-20: exported map objects never "wake up" via dynamic simulation (sim stays off + damage off)
if (_direction isEqualType[]) then {_vehicle setVectorDirAndUp _direction;} else {_vehicle setDir _direction;};
_vehicle setPosATL _position;
if !(_code isEqualTo "") then {private _plb_code = _code;
    _vehicle spawn(compile _plb_code);};
_vehicle;