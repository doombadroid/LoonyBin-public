if !(life_canJump && isNull objectParent player && isTouchingGround player) exitWith {};
life_canJump = false;
private _height = 2.5;
private _maxVel =
5.3;
private _vel = (velocity player) apply {[selectMin[_maxVel, _x], selectMax[-1 * _maxVel, _x]] select(_x < 0)};
private _dir = direction player;
private _speed = 0.4;
player setVelocity[(_vel select 0) + (sin _dir * _speed), (_vel select 1) + (cos _dir * _speed), (_vel select 2) + _height];
player switchMove "AovrPercMrunSrasWrflDf"; [
    ["AovrPercMrunSrasWrflDf", 0, "switchMove", player], "life_fnc_handleAnim", (allPlayers select {(_x distance player) <= 30}) - [player]
] spawn life_fnc_MP;
[] spawn {uiSleep 2;
    life_canJump = true;};