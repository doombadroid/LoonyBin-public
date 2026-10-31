params[["_policeMan", objNull], ["_vehicle", objNull]];
if (isNull _policeMan) exitWith {};
player setVariable["plb_disarmed", true, true];
life_dead_gear params["_primary", "_launcher", "_handgun", "_magazines", "_uniform", "_vest"];
private _weaponAccessories = [life_dead_gear select 8, life_dead_gear select 9]; {life_dead_gear set[_x select 0, _x select 1]}
forEach[[0, ""], [1, ""], [2, ""], [3, []], [8, []], [9, []]];
if (_vest isEqualTo "V_HarnessOGL_brn") then {life_dead_gear set[5, ""]};
if (_vehicle isEqualType objNull) then {if (!isNull _vehicle) then {{_vehicle addItemCargoGlobal[_x, 1]}
        forEach[_primary, _launcher, _handgun]; {_vehicle addMagazineAmmoCargo[_x select 0, 1, _x select 1]}
        forEach _magazines;
        if (_vest isEqualTo "V_HarnessOGL_brn") then {_vehicle addItemCargoGlobal[_vest, 1]}; {{_vehicle addItemCargoGlobal[_x, 1]}
            forEach _x}
        forEach _weaponAccessories;};}; [[0, 1, 2], format["Your weapons have been removed by officer %1.", name _policeMan]
] call life_fnc_broadcast;