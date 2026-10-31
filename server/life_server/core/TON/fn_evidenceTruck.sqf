/*
    TON_fnc_evidenceTruck  (LooneyBin -- implemented from stub 2026-06-09)
    Client (core/actions/fn_evidenceVaultOpen.sqf) calls [_groupMems] ([[uid,name],..]) after the vault
    demo pops. Spawns the evidence loot TRUCK near the vault with the seized pool in its trunk
    (plb_Trunk = [[items], weight]) -- the robbers' getaway prize. Keys to the breaching group.
*/
params [["_groupMems", [], [[]]]];
// owner 2026-06-23 SECURITY (security.md §2.2): caller = fn_evidenceVaultOpen (the civ crew that just breached
// the lockup). Ungated, ANY client could remoteExec [[[myUID,myName]]] at any time to dump the entire seized
// SRV_evidencePool into a getaway truck for themselves -- instant theft of all contraband cops ever seized,
// no breach required. Gate server-side on the SAME breach state the client checks (defenses DOWN + evidence on
// site) AND require the real caller (remoteExecutedOwner, non-spoofable) to be one of the breaching _groupMems.
// Server-internal passes.
private _src = remoteExecutedOwner;
private _caller = if (_src isEqualTo 0) then { objNull } else { (allPlayers select { owner _x isEqualTo _src }) param [0, objNull] };
if (_src isNotEqualTo 0) then {private _callerUID = getPlayerUID _caller;
    private _evi = missionNamespace getVariable ["SRV_evidence_status", [false, true]];
    private _breachLive = (_evi param [0, false]) && {!(_evi param [1, true])};   // hasEvidence && defensesDown
    private _inCrew = (_groupMems findIf { (_x param [0, ""]) isEqualTo _callerUID }) isNotEqualTo -1;
    if (!_breachLive || {!_inCrew}) exitWith { ["-SEC-", _caller, format ["BLOCKED evidenceTruck by %1 (breachLive=%2 inCrew=%3)", _callerUID, _breachLive, _inCrew]] call PLB_fnc_logIt; };
};
if (isNil "SRV_evidencePool") then { SRV_evidencePool = []; };
if (isNil "SRV_evidenceWeps") then { SRV_evidenceWeps = []; };

private _pos = getMarkerPos "armory_vault";
if (_pos isEqualTo [0,0,0]) then { _pos = [20898.6, 19221.7, 0]; };
private _spawnPos = [_pos, 12, 30, 5, 0, 0.5, 0] call BIS_fnc_findSafePos;
private _truck = "I_Truck_02_transport_F" createVehicle _spawnPos;
_truck setDir (random 360);
_truck setVariable ["plb_side", "civ", true];
_truck setVariable ["plb_vehOwners", _groupMems, true];
_truck setVariable ["owner", (_groupMems param [0, ["",""]]) select 0, true];   // cleanup-sweep spare

// trunk: the seized virtual pool (+ a floor reward so an empty pool still pays something)
private _items = +SRV_evidencePool;
if (_items isEqualTo []) then { _items = [["goldbar", 3]]; };
private _weight = 0;
{ _weight = _weight + (_x select 1); } forEach _items;
_truck setVariable ["plb_Trunk", [_items, _weight], true];
// physical weapons land in the truck's real cargo
clearWeaponCargoGlobal _truck; clearItemCargoGlobal _truck; clearMagazineCargoGlobal _truck;
{ _truck addWeaponCargoGlobal [_x, 1]; } forEach SRV_evidenceWeps;

// pool is paid out -> empty it + disarm the event until cops seize more
SRV_evidencePool = [];
SRV_evidenceWeps = [];
if (!isNil "SRV_evidence_status") then { SRV_evidence_status set [0, false]; publicVariable "SRV_evidence_status"; };
diag_log format ["[LooneyBin][evidence] truck spawned at %1 for %2 (loot %3)", _spawnPos, _groupMems, _items];
