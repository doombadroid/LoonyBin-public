private _preAchieve = str life_achievements;
private _preTitle = player getVariable["plb_prefix", ""];
private _removedAchievements = [37]; {_x params[["_id", -1, [0]], ["_sides", [civilian, west, independent], [[]]
    ], ["_title", "", [""]], ["_condition", {false}, [{}]]];
    if ((_id in _removedAchievements) && (_id in life_achievements)) then {life_achievements deleteAt(life_achievements find _id);
        if (_title isEqualTo _preTitle) then {player setVariable["plb_prefix", nil, true];
            [15] call life_fnc_ClupdatePartial;};};
    if !(_id in life_achievements) then {if (playerSide in _sides && (call _condition)) then {life_achievements pushBack _id;
            ["Achievement", [format["Achievement Unlocked: %1", _title]]] call BIS_fnc_showNotification;};} else {
        if (playerSide in _sides && (!(call _condition) && !(_condition isEqualTo {false}))) then {
            life_achievements deleteAt(life_achievements find _id);
            if (player getVariable["plb_prefix", ""] isEqualTo _title) then {player setVariable["plb_prefix", nil, true];
                if (player getVariable["plb_prefix", ""] isNotEqualTo _preTitle) then {[15] call life_fnc_ClupdatePartial;};};};};}
forEach life_achievementInfo;
private _postAchieve = str life_achievements;
if (_preAchieve isNotEqualTo _postAchieve) then {[7] call life_fnc_ClupdatePartial;};