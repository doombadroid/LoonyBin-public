params[["_unit", objNull, [objNull]]];
private _plb_dmg = player;
_plb_dmg setDamage 0;
if (life_istagged) exitWith {};
player allowDamage false;
player setVariable["plb_laserTagged", true, true];
life_istagged = true; [[player], "TON_fnc_laserEliminated", 2] spawn life_fnc_MP;
disableUserInput true;
private _obj = "Land_ClutterCutter_small_F"
createVehicle(getPosATL player);
_obj setPosATL(getPosATL player);
player attachTo[_obj, [0, 0, 0]];
player playMove "AmovPercMstpSsurWnonDnon_AmovPercMstpSnonWnonDnon";
private _toSend = ((getMarkerPos "lasertag") nearEntities["CAManBase", 35]) select {isPlayer _x && alive _x}; [
    [0, format["%1 was tagged by %2.", profileName, name _unit]], "life_fnc_broadcast", _toSend] spawn life_fnc_MP;
uiSleep 5;
disableUserInput false;
detach player;
deleteVehicle _obj;
player setPos(player getVariable["plb_laserPos", getMarkerPos "city"]);
[player] joinSilent life_old_group;
life_laser_inprogress = false;
life_istagged = false;
uiSleep 2;
player allowDamage true;