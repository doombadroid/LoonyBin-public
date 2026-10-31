params[["_save", false, [false]]];
// LooneyBin: respawn_west marker is ABSENT from mission.sqm -> getMarkerPos returns [0,0,0]. The
// "don't save gear at the APD base" guard then became "don't save within 1000m of map origin", which
// fires during spawn-in (player sits ~229m from [0,0,0] in the holding spot before teleporting to
// town) -> EVERY spawn gear save aborted -> civ_gear never saved -> permanent default/naked. Only
// apply the proximity guard when respawn_west actually exists.
private _rwPos = getMarkerPos "respawn_west";
private _nearRespawnWest = (_rwPos isNotEqualTo [0,0,0]) && {(player distance _rwPos) < 1000};
// owner 2026-06-21 (#440 "can't use guns after restart"): do NOT save gear while the gun is in the cop
// "firing pin removed" broken state. fn_breakGuns empties the loaded mag in-place (setAmmo 0) + a while-loop
// keeps it dry; getUnitLoadout captures that EMPTY-mag gun, so a periodic/restart save baked a permanently-
// unfireable weapon into civ_gear that reloaded broken EVERY restart (the plb_gunBroken FLAG isn't persisted,
// but the damaged loadout WAS). Skipping the save while broken keeps the last GOOD loadout; fixFiringPin
// reloads on repair so post-repair saves are clean too. Relog/restart-while-broken now restore a full gun.
if (((life_is_arrested param [0,0]) isEqualTo 1) || _nearRespawnWest || life_isDead || (player getVariable ["plb_gunBroken", false])) exitWith {};
private _loadout = getUnitLoadout player;
private _formatedInv = [];
private _formatedWeight = 0; {private _val = missionNameSpace getVariable [format["life_inv_%1", _x], 0];
    if (_val > 0) then {private _itemWeight = (["getItemWeight", _x] call life_fnc_virtItemCfg) * _val;
        _formatedInv pushBack[_x, _val];
        _formatedWeight = _formatedWeight + _itemWeight;};}
forEach([2] call life_fnc_virtItemCfg);
// LooneyBin: life_uniformBackpack_skins (clothing texture indices) is never globally initialized and
// the side-specific setter (requestReceived) doesn't always run -> it was nil -> serialized into the
// saved gear as `any`, corrupting civ_gear so the reload couldn't parse it (player got default
// clothes). Default it before building the save packet.
if (isNil "life_uniformBackpack_skins") then { life_uniformBackpack_skins = [-1, -1]; };
private _return = [_loadout, [_formatedInv, _formatedWeight], life_uniformBackpack_skins];
life_gear = _return;
if (_save && {playerSide isEqualTo civilian}) then {[3] call life_fnc_ClupdatePartial;};