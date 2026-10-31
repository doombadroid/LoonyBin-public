params[["_source", objNull, [objNull]], ["_shanked", false, [false]]];
if ((call life_adminLevel) isEqualTo 0) then {(findDisplay 49) closeDisplay 1;};
private _vehSource = false;
private _plb_dmg = player;
private _sourceStatArr = [];
private _RemoteStats = [];
_plb_dmg setDamage 0;
if (isNull _source) exitWith {player allowDamage true;
    life_isDowned = false;};
// LooneyBin: clear a STALE life_isDowned. If we're flagged downed but NOT actually incapacitated (no
// downed UI [display 7300] + alive), the flag is stale -- left true after a botched revive/recovery -- and
// it was permanently blocking the guard below, so every stun/down round early-exited and did NOTHING while
// lethal rounds still killed (the "<player> can't be downed, only killed" bug -- per-client, hits one
// person). Reset it so a genuine down can fire. When ACTUALLY down (display 7300 present) this won't clear.
if (life_isDowned && {alive player} && {(isNull (findDisplay 7300)) || {(time - (missionNamespace getVariable ["PLB_downStamp", -1e9])) > 65}}) then { life_isDowned = false; };   // LooneyBin: also self-heal a flag stuck true for >65s (longer than any real down) even if the downed UI (7300) is wedged open -- recovers a "can't be downed" client WITHOUT a relog.
// LooneyBin (Torch/Nikki bug): a STUCK DeathScreen (display 7300) left open on a player who is ALIVE is
// stale -- a real death screen only shows while the player is a corpse (!alive). It came from a medic/drone
// revive that didn't close 7300 (see fn_revived). It permanently fails the guard below -> "can't be downed
// at all." If alive, close it so a genuine down can fire (self-heals already-stuck clients, no relog needed).
if (alive player && {!isNull (findDisplay 7300)}) then { (findDisplay 7300) closeDisplay 0; };
if !(!life_isDowned && alive player && isNull(findDisplay 7300)) exitWith {};
// LooneyBin: stamp who downed us (+ when) so a later DEATH can still be attributed to them. Revivable
// players (esp. cops, life_revive_cops) often DIE by bleed-out/scripted setDamage, where the "Killed" EH
// _killer = the victim (not the shooter) -> fn_onPlayerKilled's charge gate (_killer != _unit) skipped
// -> no Manslaughter on the killer. onPlayerKilled reads this to recover the real killer. Timestamped so
// a stale downer (downed -> revived -> later unrelated death) is ignored.
if (!isNull _source) then { player setVariable ["plb_downedBy", [_source, time]]; };
if (vehicle _source isKindOf "LandVehicle" && {driver(vehicle _source) isEqualTo _source}) then {_vehSource = true; [
        [0, format["%1 has been run over by %2.", [profileName] call life_fnc_cleanName, [name _source] call life_fnc_cleanName]], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
    if (alive _source && !(side _source isEqualTo west)) then {[[10, _source], "TON_fnc_wantedAdd", false, false] spawn life_fnc_MP;};
} else {private _extra =
    switch (true) do {case ((side _source isEqualTo west) && (_source getVariable["plb_showrank", true])): {
                [west, _source] call life_fnc_getRankString;};
        case (side _source isEqualTo civilian): {(group _source) getVariable["plb_grpTag", ""];};
        case (typeOf _source in ["B_G_Offroad_01_armed_F", "I_C_Offroad_02_LMG_F", "O_LSV_02_armed_F"] && {!isNull gunner _source
        } && side _source isEqualTo civilian): {(group(gunner _source)) getVariable["plb_grpTag", ""];};
        default {""};}; private _groupTag =
    switch (true) do {case (playerSide isEqualTo civilian && !((group player) getVariable["plb_grpTag", ""] isEqualTo "")): {
                (group player) getVariable "plb_grpTag"};
        case (playerSide isEqualTo west && player getVariable["plb_showrank", true]): {[west, player] call life_fnc_getRankString};
        case (playerSide isEqualTo independent): {[independent, player] call life_fnc_getRankString};
        default {""};}; if ((side _source isEqualTo civilian) && (playerSide isEqualTo west)) then {
        _sourceStatArr pushBack["civ_cops_downed", 1];};
    // LooneyBin: guard the quest/inv vars. For a civ victim whose life_completedLifetimeQuests is nil or
    // not an array (e.g. a new player), `456 in <bad>` THREW here and aborted handleDowned before the
    // actual down -> civ took damage but never died or downed, while medics (side check short-circuits)
    // downed fine. Type/nil-check before using them.
    if ((playerSide isEqualTo civilian) && {life_completedLifetimeQuests isEqualType []} && {456 in life_completedLifetimeQuests} && {(round random 100) <= 5} && {!isNil "life_inv_adrenalineShot" && {life_inv_adrenalineShot >= 1}}) then {
        [] spawn {uiSleep 5;
            [false, "adrenalineShot", 1] call life_fnc_handleInv;
            [] call life_fnc_adrenalineShotEffect;};};
    if !(_shanked) then {if (isPlayer _source && !(_source isEqualTo player)) then {[[
                    [0], format["%1%2 was downed by %3%4.", _groupTag, profileName, _extra, name _source]
                ], "life_fnc_broadcast", -2, false, false] spawn life_fnc_MP;
            _RemoteStats pushBack[16, 1, false, [], [profileName, false, true]];
            private _isAtWar =
            if (!(_source getVariable["gang_data", []] isEqualTo[]) && !(group _source isEqualTo group player) && {
                (_source getVariable["gang_data", [-1]] select 0) in life_gang_wars}); [
                ["-DOWNED-", player, (profileName), format["(%5) was downed by %1 (%2) (%6) with a %3, DIST: %4m. Shooter: %7, Target: %8, In War: %9", (name _source), (getPlayerUID _source), (getText(configFile >> "CfgWeapons" >> (currentWeapon(vehicle _source)) >> "DisplayName")), (floor(player distance _source)), (side player), (side _source), getPos _source, getPosATL player, _isAtWar]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
            [
                ["-DOWNED-", _source, (name _source), format["(%5) downed %1 (%2) (%6) with a %3, DIST: %4m. Shooter: %7, Target: %8, In War: %9", (profileName), (getPlayerUID player), (getText(configFile >> "CfgWeapons" >> (currentWeapon(vehicle _source)) >> "DisplayName")), (floor(player distance _source)), (side _source), (side player), getPos _source, getPosATL player, _isAtWar]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
        };} else {[
            ["-SHANKED-", _source, (name _source), format["(%1) shanked %2 (%3) (%4).", side _source, (profileName), (getPlayerUID player), playerSide]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
    };};
if !(_sourceStatArr isEqualTo[]) then {[["", -1, _sourceStatArr], "life_fnc_statArrUpdate", _source] spawn life_fnc_MP;};
if !(_RemoteStats isEqualTo[]) then {[[0, 0, false, _RemoteStats], "life_fnc_updateRemoteStat", _source] spawn life_fnc_MP;};
if !(isNull(player getVariable["plb_escortObj", objNull])) then {[] call life_fnc_stopEscorting;};
if (player getVariable["plb_escorting", false]) then {private _escort = player getVariable["plb_escortee", objNull]; [
        [], "life_fnc_stopEscorting", _escort, false, false] spawn life_fnc_MP;};
if !(isNull objectParent player) then {private _vehicle = vehicle player;
    if (player isEqualTo(driver _vehicle)) then {if (_vehicle isKindOf "Helicopter") then {[
                [_vehicle], "TON_fnc_enableCoPilot", 2] spawn life_fnc_MP;};};};
life_isDowned = true;
PLB_downStamp = time;   // LooneyBin: down-start timestamp -> lets the stale-flag self-heal (top of file) distinguish a real ongoing down from a wedged-true flag.
player setVariable["plb_downed", true, true];
player setVariable["plb_adrenaline", false, true];
player setUnconscious true;
disableUserInput true;
private _hndlBlur = ppEffectCreate["DynamicBlur", 501];
_hndlBlur ppEffectEnable true;
_hndlBlur ppEffectAdjust[5];
_hndlBlur ppEffectCommit 0;
private _hndlBlack = ppEffectCreate["colorCorrections", 1501];
_hndlBlack ppEffectEnable true;
_hndlBlack ppEffectAdjust[1.0, 1.0, 0.0, [0, 0, 0, 0.9], [1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 1.0, 0.0]];
_hndlBlack ppEffectCommit 0;
private _effects = true;
private _eff1 = 5;
private _eff2 = 0.9;
private _time = 0;
private _dead = false;
private _downed = true;
while {_downed}
do {if (alive player) then {
        if ((_vehSource && _time isEqualTo 5) || (_time isEqualTo 60 && !(_vehSource)) || player getVariable["plb_adrenaline", false]) exitWith {
            _downed = false;
            player setVariable["plb_adrenaline", false]};} else {_downed = false;
        _dead = true;};
    if (_dead) exitWith {};
    _time = _time + 1;
    uiSleep 1;};
[ _hndlBlur , _hndlBlack, _eff1, _eff2, _effects] spawn {params["_hndlBlur", "_hndlBlack", "_eff1", "_eff2", "_effects"];
    while {_effects}
    do {_eff1 = _eff1 - 0.025;
        _eff2 = _eff2 - 0.0045;
        _hndlBlur ppEffectAdjust[_eff1];
        _hndlBlur ppEffectCommit 0;
        _hndlBlack ppEffectAdjust[1.0, 1.0, 0.0, [0, 0, 0, _eff2], [1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 1.0, 0.0]];
        _hndlBlack ppEffectCommit 0;
        uiSleep 0.01;
        if (_eff2 <= 0) then {_effects = false;};}; ppEffectDestroy _hndlBlur;
    ppEffectDestroy _hndlBlack;};
player setUnconscious false;
disableUserInput false;
disableUserInput true;
disableUserInput false;
if (stance player isEqualTo "STAND") then {player playMoveNow "AidlPercMstpSnonWnonDnon_G01";} else {
    player playMoveNow "AmovPpneMstpSnonWnonDnon";};
life_isDowned = false;
player setVariable["plb_downed", false, true];