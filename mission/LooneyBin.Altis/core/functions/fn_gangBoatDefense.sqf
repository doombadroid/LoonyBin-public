if !(canSuspend) exitWith {_this spawn life_fnc_gangBoatDefense;};
if !(playerSide isEqualTo civilian) exitWith {};
(life_gangBoatFortressObject getVariable["plb_gang_fortress_data", [-1, "Uncontrolled", false]]) params[["_gangID", -1, [0]], ["_gangName", "Uncontrolled", [""]], ["_active", false, [false]]];
if (_gangID == (life_gang_data select 0)) exitWith {};
while {(((vehicle player) distance2D life_gangBoatFortressObject) < 150) && (alive player)}
do {if (((vehicle player) isKindOf "Air") && ((currentPilot(vehicle player)) isEqualTo player)) then {
        titleText["You are about to be shot down by the anti-air defense system! Leave now!", "PLAIN"];
        systemChat "You are about to be shot down by the anti-air defense system! Leave now!";
        uiSleep 5;
        if ((((vehicle player) distance2D life_gangBoatFortressObject) < 150)) then {[
                [10494.3, 10381.8, 40], "M_Titan_AA_static", 105, vehicle player, 600] spawn life_fnc_fireMissile;};} else {uiSleep 5;}};