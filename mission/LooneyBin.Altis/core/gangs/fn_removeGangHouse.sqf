params[["_building", objNull, [objNull]], ["_gangid", -1, [0]], ["_houseOwner", "", [""]]];
if (isNull _building || _gangid isEqualTo - 1) exitWith {};
if !((life_gang_data select 0) isEqualTo _gangid) exitWith {};
deleteMarkerLocal life_gangBldgMark;
life_gangBldgMark = "";
life_vehicles deleteAt(life_vehicles find _building);
life_houses deleteAt(life_houses find(str(getPosATL _building)));
life_gangBuilding = [objNull, []];
life_gang_data set[3, [0, 0, 0]];
private _text =
if (life_gang_data param[2, 0] isEqualTo 1) then {"You have removed this house as your gang house."} else {
    "The leader has removed or sold the gang house, and it has been removed from your spawn options..."};
[_text, "basic"] spawn life_fnc_handleMessage;