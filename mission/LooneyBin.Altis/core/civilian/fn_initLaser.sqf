params[["_team", 1, [1]]];
private _endTime = time + 200;
player setVariable["plb_laserTagged", nil, true];
player setVariable["plb_laserTeam", _team, true];
life_laser_blue = 0;
life_laser_red = 0;
life_laser_inprogress = true;
civ_gear = getUnitLoadout player;
removeVest player;
removeHeadgear player;
removeBackpack player;
removeUniform player;
removeAllWeapons player;
private _plb_dmg = player;
_plb_dmg setDamage 0;
player setFatigue 0;
private _uniform =
if (_team isEqualTo 1) then {"U_B_Protagonist_VR"} else {"U_O_Protagonist_VR"};
private _smoke =
if (_team isEqualTo 1) then {"SmokeShellBlue"} else {"SmokeShellRed"};
player forceAddUniform _uniform;
player addHeadgear "G_Goggles_VR";
player addMagazines["16Rnd_9x21_Mag", 4];
player addWeapon "hgun_Rook40_snds_F";
player assignItem "Integrated_NVG_F";
player addMagazine _smoke;
private _teamName =
if (_team isEqualTo 1) then {"BLUE"} else {"RED"};
private _enemyName =
if (_team isEqualTo 1) then {"RED"} else {
    "BLUE"}; [[0, 2], format["Get ready, the round is about to begin. You are team %1, eliminate team %2!", _teamName, _enemyName]
] call life_fnc_broadcast;
[] spawn {while {life_laser_inprogress}
    do {uiSleep 0.1;
        if (cameraView == "EXTERNAL") then {player switchCamera "INTERNAL"};};};
_uniform spawn {private _uniform = _this;
    private _oldUniform = "";
    while {life_laser_inprogress}
    do {_oldUniform = uniform player;
        waitUntil {uiSleep 1;
            !life_laser_inprogress || (_oldUniform != (uniform player))};
        if (life_laser_inprogress) then {player forceAddUniform _uniform};};};
[] spawn {while {life_laser_inprogress}
    do {private _blueScore = life_laser_blue;
        private _redScore = life_laser_red;
        waitUntil {!life_laser_inprogress || _blueScore != life_laser_blue || _redScore != life_laser_red};
        if (life_laser_inprogress) then {
            systemChat format["Blue Team: [%1 remaining] :: Red Team: [%2 remaining]", life_laser_blue, life_laser_red];};};};
waitUntil {!life_laser_inprogress || time > _endTime};
if (isWeaponDeployed player) then {player playMove "";};
life_laser_inprogress = false;
player setPosATL(player getVariable["plb_laserPos", getMarkerPos "city"]);
player setVariable["plb_laserTeam", nil, true];
[player] joinSilent life_old_group;
player setUnitLoadout civ_gear;
if !(uniform player isEqualTo "") then {[uniform player, "setUniform", ""] call life_fnc_clothingTextures;};