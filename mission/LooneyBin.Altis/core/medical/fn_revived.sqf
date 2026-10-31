params[["_medic", objNull, [objNull]], ["_hospital", false, [false]], ["_admin", false, [false]], ["_copMedic", false, [false]], ["_nextRevive", -1000, [0]]];
if !(life_isDead) exitWith {};
life_respawned = true;
private _gear =
if (playerSide isEqualTo west && {life_activeSWAT || life_eviSpawn}) then[{life_deadcop_gear}, {life_dead_gear}];
[_gear] call life_fnc_loadDeadGear;
// LooneyBin: guard radioChannelInfo on the unset (String "") life_radio_civ — see fn_spawnConfirm.
if (life_sidechat && (playerSide isEqualTo civilian) && (life_radio_civ isEqualType 0) && {!(player in ((radioChannelInfo life_radio_civ) param[3, []]))}) then {
    [life_sidechat] call life_fnc_manageSidechat;};
if (_hospital) then {cutText["You wake up at a hospital, feeling much better.", "BLACK FADED"];
    0 cutFadeOut 6;
    private _hospitalLocations = ["revive", "revive_1", "revive_2", "revive_3", "revive_4"];
    private _nearestHospital = [_hospitalLocations, life_corpse] call BIS_fnc_nearestPosition;
    player setPos(markerPos _nearestHospital);
    player setDir(markerDir _nearestHospital); [
        ["-REVIVE-", player, profileName, format["respawned at the hospital, POS: %1", getPosATL player]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
} else {
    // LooneyBin: a DOWNED (not dead) player never had life_corpse set -> visiblePositionASL objNull =
    // [0,0,0] = debug island. Only teleport to a VALID corpse; else leave them where they were downed.
    if (!isNull life_corpse && {!((getPosATL life_corpse) isEqualTo [0,0,0])}) then {player setDir(getDir life_corpse);
        player setPosASL(visiblePositionASL life_corpse);};
    if (_admin) then {titleText[format["The admin %1 has revived you.", [name _medic] call life_fnc_cleanName], "PLAIN"];
        if !(isNull(findDisplay 7300)) then {(findDisplay 7300) closeDisplay 0;};} else {if (playerSide isEqualTo civilian && {
            player getVariable["plb_lowtime", false]}) then {
            [format["Due to being a newer player you've only been charged $300 for these services. In the future you will have to pay $%1 for these same services.", [call(life_revive_fee)] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
        } else {
            [format["%1 has revived you and a fee of $%2 was taken from your bank account for their services.", [name _medic] call life_fnc_cleanName, [call(life_revive_fee)] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
        };}; [
        ["-REVIVE-", player, profileName, format["was revived by %1 (%2), POS: %3", name _medic, getPlayerUID _medic, getPosATL player]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
};
// LooneyBin: force-close the DeathScreen (display 7300) on EVERY revive path. It was only explicitly closed
// on the _admin branch above; a normal medic/drone revive relied solely on the closeDialog 0 below, which
// misses if another dialog is focused -> the death screen stayed open while the player was alive again, and
// the handleDowned guard (checks isNull findDisplay 7300) then early-exited forever = "can't be downed at
// all" (the Torch/Nikki bug). Belt-and-suspenders with closeDialog 0.
if !(isNull (findDisplay 7300)) then { (findDisplay 7300) closeDisplay 0; };
closeDialog 0;
life_deathCamera cameraEffect["TERMINATE", "BACK"];
camDestroy life_deathCamera;
if (!_hospital && !_admin) then {private _cost =
    if ((side _medic) in [independent, west]) then {call life_revive_fee} else {(call life_revive_fee) + 1000};
    if (playerSide isEqualTo civilian && {player getVariable["plb_lowtime", false]}) then {
        [format["Due to being a newer player you've only been charged $300 for these services. In the future you will have to pay $%1 for these same services.", [_cost] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
        _cost = 300;};
    if (life_atmcash > _cost) then {life_atmcash = life_atmcash - _cost;
        life_atmcashCacheB = ((life_atmcash / 4) + 11);
        [1] call life_fnc_ClUpdatePartial;} else {life_atmcash = 0;
        life_atmcashCacheB = ((life_atmcash / 4) + 11);
        [1] call life_fnc_ClUpdatePartial;};};
if !(isNull _medic) then {["revived", "bymedic", 1] spawn life_fnc_handleQuest;
    private _toSend = (allPlayers - [allDeadMen] - [player]) select {
        (side _x isEqualTo west && _x getVariable["plb_copRole", ""] in ["medic", "all"]) || side _x isEqualTo independent}; [
        [player, _medic], "life_fnc_medicRespondDone", _toSend] spawn life_fnc_MP;};
if (!isNull _medic && playerSide != independent && !_hospital) then {
    // LooneyBin: the _copMedic exemption (4th arg) was DEAD -- every caller hardcodes false, so cop-medics were wrongly
    // penalized. Only CIVILIAN (amateur) revives should sting; EMS (independent, gated on L91) + all cops (who can only
    // revive via the medic/detective talent anyway) stay exempt -> keeps real medics worth paying for.
    if (!_admin && side _medic isEqualTo civilian) then {[] spawn {
            player setVariable["plb_can_revive", (player getVariable["plb_can_revive", time]) + 600, true];
            private _plb_dmg = player;
            _plb_dmg setDamage 0.25;
            if (17 in life_infamy_talents && license_civ_rebel && (random 10) < 1.5) exitWith {
                systemChat "You have been revived by an unprofessional. But you do not feel weakened.";};
            life_revive_fatigue = time + 40;
            systemChat "You have been revived by an unprofessional. You feel weakened.";
            player forceWalk true;
            while {alive player && (time < life_revive_fatigue)}
            do {if (getFatigue player < 0.9) then {player setFatigue 1;};
                uiSleep 1.5;}; if (alive player) then {systemChat "You feel a bit better now.";};
            player setFatigue 0.5;
            life_revive_fatigue = 0;
            player forceWalk false;};};};
if !(isNil "life_suicide") then {life_suicide = nil}; {if !(isNil {player getVariable _x}) then {player setVariable[_x, nil, true];};}
forEach["plb_revivable", "plb_reviving", "plb_executing"];
if (life_coprole in ["all", "medic"] && {20 in life_cop_talents}) then {_nextRevive = time + 120};
if (16 in life_infamy_talents && license_civ_rebel) then {_nextRevive = time + 120};
if (playerSide isEqualTo independent) then { _nextRevive = -1000; };
player setVariable["plb_next_revive", _nextRevive, true];
life_isDead = false;
[] call life_fnc_hudUpdate;
player switchMove "amovppnemstpsnonwnondnon";
[] spawn {uiSleep 3;
    [] call life_fnc_ClUpdateRequest;};
