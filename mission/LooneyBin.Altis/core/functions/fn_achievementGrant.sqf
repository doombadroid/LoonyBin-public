params[["_id", -1, [-1]]];
if (_id in life_achievements) exitWith {};
if (_id < 0) exitWith {};
private _achievement = life_achievementInfo param[life_achievementInfo findIf {_id isEqualTo(_x select 0)}, []];
if !(playerSide in (_achievement select 1)) exitWith {};
life_achievements pushBack _id;
["Achievement", [format["Achievement Unlocked: %1", _achievement select 2]]] call BIS_fnc_showNotification;
[7] call life_fnc_ClupdatePartial;