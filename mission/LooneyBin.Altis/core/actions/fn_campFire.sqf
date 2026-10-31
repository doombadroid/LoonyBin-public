if !(isNull objectParent player) exitWith {
    ["Starting a fire in a vehicle is hazardous to your health!", "basic"] spawn life_fnc_handleMessage;};
if ((count(nearestObjects[player, ["Land_Campfire_F"], 25]) > 0) || (count(nearestObjects[player, ["MetalBarrel_burning_F"], 25]) > 0)) exitWith {
    ["There's already a campfire nearby!", "basic"] spawn life_fnc_handleMessage};
private _plb_pos = [(getPos player), 1, 5, 1, 0, 0, 0, [], [0, 0, 50]] call BIS_fnc_findSafePos;
if (isOnRoad _plb_pos || _plb_pos isEqualTo[0, 0, 50]) exitWith {
    ["The fire would be too close to a road or building to setup safely!", "basic"] spawn life_fnc_handleMessage;};
private _barrel =
if ((player distance(getMarkerPos "city") < 1000) || (player distance(getMarkerPos "civ_spawn_2") < 1100) || (player distance(getMarkerPos "civ_spawn_3") < 500) || (player distance(getMarkerPos "civ_spawn_4") < 500)) then {
    true} else {false};
if ([false, "campfire", 1] call life_fnc_handleInv) then {private _obj_main =
    if !(_barrel) then {
        "Land_Campfire_F"
        createVehicle _plb_pos;} else {
        "MetalBarrel_burning_F"
        createVehicle _plb_pos;};
    ["You build youself a little fire nearby to cook with.", "basic"] spawn life_fnc_handleMessage;
    _obj_main setVariable["plb_owner", player, true]; [[_obj_main, 900], "TON_fnc_setCleanTime", 2] spawn life_fnc_MP;};