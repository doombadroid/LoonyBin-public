disableSerialization;
private _medicsOnline = (findDisplay 7300) displayCtrl 7304;
private _medicsNear = (findDisplay 7300) displayCtrl 7305;
private _nearby = 999999;
private _distance = 999999;
waitUntil {_nearby = 99999; {if ((side _x isEqualTo independent || (("cop_medic"
        find str _x) != -1)) && alive _x && !(_x isEqualTo player)) then {_distance = (getPosATL life_corpse) distance _x;
            if (_distance < _nearby) then {_nearby = _distance;};};}
    forEach allPlayers;
    _medicsOnline ctrlSetText format["National Guard Online: %1", ({side _x isEqualTo independent}
    count allPlayers) + ({("cop_medic"find str _x) != -1}
    count allPlayers)];
    if (_nearby isEqualTo 99999) then {_medicsNear ctrlSetText format["Nearest NG Medic: None", _nearby];} else {
        _medicsNear ctrlSetText format["Nearest NG Medic: %1m", [(round _nearby)] call life_fnc_numberText];};
    uiSleep 1;
    (isNull(findDisplay 7300))};
