/*
    TON_fnc_fedGoldSpawn  (LooneyBin NEW 2026-06-09 -- Federal Reserve rework)
    Called by fn_openVault when a dome's side door is broken in: [domeObject].
    Spawns ONE briefcase per inner safe building (Land_Research_house_V1_F / Land_Research_HQ_F within
    50 m of that dome), each holding 1-5 GOLD BARS as a lootable suitcase (plb_droppedItems -- same
    mechanic as death-drop suitcases / treasure chests). Once-per-dome per robbery (plb_goldSpawned;
    the boot/reset lockdown clears it). Cases self-delete when emptied or after 30 min.
*/
params [["_dome", objNull, [objNull]]];
diag_log format ["[LooneyBin][fed] fedGoldSpawn called: dome=%1 already=%2", _dome, if (isNull _dome) then {"NULL"} else {_dome getVariable ["plb_goldSpawned", false]}];
if (isNull _dome) exitWith {};
// owner 2026-06-16 (#302): SERVER-side mutual-exclusion backstop. If a breach slipped past the client gate
// during another event's window, refuse the payoff -- no gold spawns while another federal event is live.
if (["fed"] call PLB_fnc_fedEventActive) exitWith {
    diag_log "[LooneyBin][fed] fedGoldSpawn ABORTED -- another federal event already active (#302 server gate)";};
// owner 2026-07-24 SECURITY (audit): CfgRE allowedTargets=2 with no caller derivation, no proximity check
// and no proof the vault was ever breached -- a client could remoteExec [<dome>] from anywhere and collect
// the entire Federal Reserve gold payout without touching the heist. The per-dome plb_goldSpawned flag
// limited it to once per dome per reset, which bounded the theft but did not prevent it.
// Require, for a client call: a resolvable caller, that caller standing at the dome, and the dome actually
// UNLOCKED -- fn_openVault sets plb_vaultlocked = 0 at :153 immediately before calling this at :165, and
// fn_fedLockdown re-seals it to 1, so 0 means a breach really happened.
// NOTE (residual, not fixable here): plb_vaultlocked is set CLIENT-side in fn_openVault with public=true,
// so a modified client can still assert it. Combined with the proximity gate, the once-per-dome flag and
// the existing #302 event-exclusion check this is much harder to abuse, but a full fix needs the door
// break itself validated server-side. Tracked in AUDIT.md.
private _src = remoteExecutedOwner;   // 0 == server-internal = trusted
private _blockGold = false;
if (_src isNotEqualTo 0) then {private _caller = (allPlayers select { owner _x isEqualTo _src }) param [0, objNull];
    if (isNull _caller || {(_caller distance _dome) > 60} || {(_dome getVariable ["plb_vaultlocked", 1]) isNotEqualTo 0}) then {
        ["-SEC-", _caller, format ["BLOCKED fedGoldSpawn (dist %1, vaultlocked %2) by %3",
            if (isNull _caller) then {-1} else {round (_caller distance _dome)},
            _dome getVariable ["plb_vaultlocked", 1], getPlayerUID _caller]] call PLB_fnc_logIt;
        _blockGold = true;   // nested exitWith would only leave this then-block
    };};
if (_blockGold) exitWith {};
if (_dome getVariable ["plb_goldSpawned", false]) exitWith {};
_dome setVariable ["plb_goldSpawned", true, true];

private _buildings = nearestObjects [getPosATL _dome, ["Land_Research_house_V1_F", "Land_Research_HQ_F"], 50];
if (_buildings isEqualTo []) exitWith {
    diag_log format ["[LooneyBin][fed] no inner buildings near dome at %1 -- no gold spawned", getPosATL _dome];};
private _spawned = 0;
private _fedCases = []; {private _spots = _x buildingPos -1;
    private _pos = if (_spots isEqualTo []) then { getPosATL _x } else { selectRandom _spots };
    private _case = "Land_Suitcase_F" createVehicle _pos;
    _case setPosATL _pos;
    _case setVariable ["owner", "fed_gold", true];                       // cleanup-sweep spare
    _case setVariable ["plb_droppedItems", [["goldbar", 1 + floor random 5]], true];
    _spawned = _spawned + 1;
    _fedCases pushBack _case;
    [_case] spawn {params ["_c"];
        private _endAt = serverTime + 1800;
        waitUntil { uiSleep 2; isNull _c || {(_c getVariable ["plb_droppedItems", []]) isEqualTo []} || {serverTime > _endAt} };
        if (!isNull _c) then { deleteVehicle _c; };};} forEach _buildings;

// owner 2026-07-18: 1 crypto MINING COMPONENT per fed event, in a small case beside a RANDOM gold briefcase
// in the FIRST dome breached. Per-EVENT guard PLB_fedComponentSpawned (re-armed with plb_goldSpawned in
// fn_fedLockdown + boot). Replaces the retired standalone TON_fnc_miningSRV ["drop"] crate.
if (!(missionNamespace getVariable ["PLB_fedComponentSpawned", false]) && {_fedCases isNotEqualTo []}) then {
    missionNamespace setVariable ["PLB_fedComponentSpawned", true, true];
    private _anchor = selectRandom _fedCases;
    private _cp = (getPosATL _anchor) vectorAdd [0.6 - random 1.2, 0.6 - random 1.2, 0];
    private _comp = "Land_Suitcase_F" createVehicle _cp;
    _comp setPosATL _cp;
    _comp setVariable ["owner", "fed_component", true];                       // cleanup-sweep spare
    _comp setVariable ["plb_droppedItems", [[selectRandom ["cryptoCPU","cryptoGPU","cryptoPSU","cryptoStorage","cryptoMotherboard","cryptoRam","cryptoCooler","cryptoCase"], 1]], true];
    [_comp] spawn {params ["_c"];
        private _endAt = serverTime + 1800;
        waitUntil { uiSleep 2; isNull _c || {(_c getVariable ["plb_droppedItems", []]) isEqualTo []} || {serverTime > _endAt} };
        if (!isNull _c) then { deleteVehicle _c; };};
    diag_log format ["[LooneyBin][fed] mining component seeded beside gold at %1", _cp];};
diag_log format ["[LooneyBin][fed] spawned %1 gold case(s) for dome at %2", _spawned, getPosATL _dome];
["-FED-", objNull, format ["gold spawned: %1 case(s) at dome %2", _spawned, getPosATL _dome]] call PLB_fnc_logIt;
