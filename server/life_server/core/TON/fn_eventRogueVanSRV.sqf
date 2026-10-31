/*
    TON_fnc_eventRogueVanSRV  (LooneyBin, owner 2026-07-17) -- ROGUE LOONAZON VAN.
    Admin-menu dynamic event. A malfunctioning driverless Loonazon delivery van (C_Van_02_vehicle_F) tears off
    JOYRIDING with a cash JACKPOT ($250k-$750k) welded in the back and a stash of rebel gear. It's LOCKED (lock 2)
    so nobody can just hop in and drive off with it -- the ONLY way in is to shoot the engine out (HitEngine >= 0.9).
    Kill the engine, the van coughs to a stop and cracks open: the closest player to the wreck gets the cash paid
    straight to their bank, and a loot box (rebel guns/gear, reuses TON_fnc_loonazonBox) drops at the van for them.
    Until then it ROAMS -- hcDrive hauls it to a random far road; on arrival it picks a NEW road and keeps rolling.
    Signature: params [["_pos", [0,0,0], [[]]]];  // the admin event menu passes the chosen LOCATION position.
    HC-online -> the headless client physics-drives the driverless van (madmax). No HC -> temporary AI driver + doMove.
    Watchdog: cracked, destroyed, or 25-min timeout all despawn everything (van/driver/marker). No leaks.
*/
if (!isServer) exitWith {};
params [["_pos", [0,0,0], [[]]]];

// --- pick a road near the chosen location to spawn on ---
private _spawnRoads = _pos nearRoads 800;
if (_spawnRoads isEqualTo []) then { _spawnRoads = _pos nearRoads 3000; };
private _spRoad = _spawnRoads param [0, objNull];
private _sp = if (isNull _spRoad) then { [_pos select 0, _pos select 1, 0] } else { getPosATL _spRoad };

private _van = createVehicle ["C_Van_02_vehicle_F", _sp, [], 0, "NONE"];
_van setPosATL _sp;
_van setVectorUp (surfaceNormal (getPosATL _van));
_van setFuel 1;
_van lock 2;                                          // locked: no joyriders, cracking the engine is the only way in
_van enableRopeAttach false;                          // no slingload heist
_van setVariable ["owner", "event", true];            // fn_cleanup spare (ownerless = instant reap)
_van setVariable ["hc_ap_lock", true, true];          // hcDrive re-asserts the lock where the van is LOCAL
_van setVariable ["plb_rogueVan", true, true];        // client-side identifier hook
_van limitSpeed 90;

private _jackpot = round (random [250000, 500000, 750000]);
// rebel-tier consolation stash for the box (loonazonBox auto-adds 2 default mags per weapon)
private _loot = selectRandom [[["arifle_Katiba_F", 1], ["30Rnd_65x39_caseless_green", 4], ["FirstAidKit", 3]],
    [["arifle_AKM_F", 1], ["30Rnd_762x39_Mag_F", 4], ["FirstAidKit", 3]], [["srifle_EBR_F", 1], ["20Rnd_762x51_Mag", 4], ["optic_Arco", 1]],
    [["arifle_MX_Black_F", 1], ["hgun_Pistol_heavy_01_F", 1], ["30Rnd_65x39_caseless_mag", 4], ["11Rnd_45ACP_Mag", 3]],
    [["LMG_Mk200_F", 1], ["200Rnd_65x39_cased_Box", 2], ["FirstAidKit", 4]]];
// deck-loot rider (owner 2026-07-21): every cracked van carries a Proxy Chain; Breach Kit and the
// drop-only Ghost Plate Chip roll on top. Virtual classes ride the same cart -- loonazonBox
// sorts them into plb_vinv automatically.
_loot = +_loot;
_loot pushBack ["proxychain", 1];
if (random 1 < 0.4)  then { _loot pushBack ["breachkit", 1]; };
if (random 1 < 0.2)  then { _loot pushBack ["ghostplatechip", 1]; };

// --- live map marker on the van ---
private _mk = format ["plb_rogueVan_%1", floor serverTime];
createMarker [_mk, getPosATL _van];
_mk setMarkerType "mil_destroy";
_mk setMarkerColor "ColorOrange";
_mk setMarkerText "ROGUE LOONAZON VAN";
[_van, _mk] spawn {params ["_van", "_mk"];
    while { !isNull _van && {markerType _mk isNotEqualTo ""} } do {_mk setMarkerPos (getPosATL _van);
        uiSleep 4;};};

[[0, format ["A LOONAZON delivery van has gone ROGUE -- driverless, doors welded shut, and packing a $%1 jackpot in the back. It's marked on the map. Doors won't open, so shoot the ENGINE out to crack it. Finders keepers.", _jackpot]], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
["-ROGUEVAN-", objNull, "SERVER", format ["rogue van spawned at %1 (jackpot $%2)", _sp, _jackpot]] call TON_fnc_logIt;

// helper: pick a random far road destination to roam to
private _fnPickDest = {params ["_from"];
    private _dest = [];
    for "_i" from 1 to 20 do {private _cand = _from getPos [1500 + random 2500, random 360];
        private _rr = _cand nearRoads 500;
        if !(_rr isEqualTo []) exitWith { _dest = getPosATL (selectRandom _rr); };};
    if (_dest isEqualTo []) then { _dest = _from getPos [2000, random 360]; };
    _dest};

[_van, _mk, _jackpot, _loot, _fnPickDest, _sp] spawn {params ["_van", "_mk", "_jackpot", "_loot", "_fnPickDest", "_sp"];

    // driver: HC physics-drives the driverless van (madmax joyride); no HC -> temporary captive AI driver.
    private _useHC = (!isNil "PLB_hcOwner") && {PLB_hcOwner > 0};
    private _grp = grpNull; private _drv = objNull;
    private _fnAiDriver = {_grp = createGroup [civilian, true];
        _drv = _grp createUnit ["C_man_1", getPosATL _van, [], 0, "NONE"];
        _drv moveInDriver _van;
        _drv setCaptive true; _drv allowDamage false;
        _grp setBehaviour "CARELESS"; _grp setSpeedMode "FULL"; _grp setCombatMode "BLUE";};
    if (_useHC) then {_van setVariable ["hc_ap_mode", "madmax", true];
        _van setVariable ["hc_ap_want", true, true];
        _van setOwner PLB_hcOwner;
        // handoff verify: setOwner is occasionally a silent no-op. If the van never leaves the server after ~8s,
        // reclaim to the server (dedicated = id 2) and drive it with an AI driver instead.
        private _giveUp = time + 8;
        waitUntil { uiSleep 1; (!local _van) || {_van getVariable ["hc_ap_driving", false]} || {time > _giveUp} };
        if (local _van && {!(_van getVariable ["hc_ap_driving", false])}) then {_van setVariable ["hc_ap_want", false, true];
            _van setOwner 2;
            uiSleep 1;
            _useHC = false;
            call _fnAiDriver;};} else {call _fnAiDriver;};

    private _hardEnd = time + 1500;                    // 25-min absolute backstop
    private _cracked = false;
    private _dest = [getPosATL _van] call _fnPickDest;

    while { !_cracked && {alive _van} && {time < _hardEnd} } do {if (_useHC) then {_van setVariable ["hc_ap_dest", _dest, true];
            _van setVariable ["hc_ap_arrive", 12, true];
            _van setVariable ["hc_ap_done", "", true];
            _van setVariable ["hc_ap_want", true, true];} else {if (!isNull (driver _van)) then { (driver _van) doMove _dest; };};
        private _legEnd = time + 300;                  // per-leg ceiling; arrival/timeout picks a fresh road
        waitUntil {uiSleep 2;
            if (!_useHC && {alive _van} && {!isNull (driver _van)} && {(_van distance2D _dest) > 15}) then { (driver _van) doMove _dest; };
            _cracked = alive _van && {(_van getHitPointDamage "HitEngine") >= 0.9};
            (!alive _van) || {_cracked}
                || {(_van getVariable ["hc_ap_done", ""]) isNotEqualTo ""}
                || {(_van distance2D _dest) < 25}
                || {time > _legEnd}};
        if (_cracked || {!alive _van}) exitWith {};
        _dest = [getPosATL _van] call _fnPickDest;     // arrived / leg over -> roam somewhere new
    };

    // ---- resolve ----
    if (_cracked && {alive _van}) then {_van setVariable ["hc_ap_want", false, true];
        _van setVariable ["hc_ap_abort", true, true];  // hard-stop any HC drive loop
        private _vp = getPosATL _van;
        // closest player to the wreck is the cracker
        private _near = (call PLB_fnc_realPlayers) select { alive _x && {(_x distance _van) < 250} };
        private _cracker = objNull; private _bd = 1e9;
        { private _dd = _x distance _van; if (_dd < _bd) then { _bd = _dd; _cracker = _x; }; } forEach _near;
        _mk setMarkerType "mil_dot";
        _mk setMarkerColor "ColorGreen";
        _mk setMarkerText "ROGUE VAN CRACKED";
        if (!isNull _cracker) then {private _uid = getPlayerUID _cracker;
            [_vp, _uid, _loot] call TON_fnc_loonazonBox;   // rebel-gear box, owner-gated to the cracker
            [[_jackpot], "life_fnc_casinoReceive", _cracker, false] spawn life_fnc_MP;
            [[format ["<t color='#e88b2d'>ROGUE VAN CRACKED</t> -- $%1 jackpot wired to your bank. There's a box of goodies at the van too. Try not to get robbed on the way home.", _jackpot], "info"], "life_fnc_handleMessage", _cracker, false, false] spawn life_fnc_MP;
            [[0, format ["%1 cracked the ROGUE LOONAZON VAN and walked off with the $%2 jackpot. The van's carcass is being scrapped.", name _cracker, _jackpot]], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
            ["-ROGUEVAN-", _cracker, name _cracker, format ["cracked rogue van, +$%1 + loot %2", _jackpot, _loot]] call TON_fnc_logIt;
        } else {
            // engine died with nobody nearby -- no payout, just tidy up
            ["-ROGUEVAN-", objNull, "SERVER", "van engine died with no player nearby -> no payout"] call TON_fnc_logIt;};
        uiSleep 20;} else {
        // destroyed outright, or 25-min timeout -- no jackpot
        [[0, "The ROGUE LOONAZON VAN has been recovered by the company. Nobody got the jackpot. Better luck next breakdown."], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
        ["-ROGUEVAN-", objNull, "SERVER", format ["rogue van resolved with no crack (alive=%1)", alive _van]] call TON_fnc_logIt;};

    // ---- cleanup: no leaks ----
    if (!isNull _drv) then { deleteVehicle _drv; };
    if (!isNull _grp) then { deleteGroup _grp; };
    if (!isNull _van) then { deleteVehicle _van; };
    deleteMarker _mk;};
