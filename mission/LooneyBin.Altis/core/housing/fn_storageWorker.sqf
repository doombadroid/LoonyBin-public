/*
    life_fnc_storageWorker  (LooneyBin, owner 2026-07-11)
    NPC init hook for THE STORAGE WORKER. Put this on the NPC's Eden/map-data INIT field:

        [_this] spawn life_fnc_storageWorker;

    map-data NPCs are spawned per-machine by life_fnc_createVehicleLocal (which runs the init as
    `_obj spawn compile <init>`), so this fires on every client. It just adds the scroll-wheel action that
    opens the vault dialog. Dedicated server (no interface) does nothing -- actions are client-local.
*/
private _npc = _this;
if (_npc isEqualType []) then { _npc = _this param [0, objNull]; };
if (isNull _npc) exitWith {};
if (!hasInterface) exitWith {};                                   // dedi copy: no scroll action
if (_npc getVariable ["plb_vaultActionAdded", false]) exitWith {}; // idempotent (init double-run guard)
_npc setVariable ["plb_vaultActionAdded", true];

_npc addAction ["<t color='#37e8f0'>Storage Worker</t>", { [] call life_fnc_storageVault; }, nil, 6, true, true,"",
    "_this distance _target < 3.5", 3.5];
