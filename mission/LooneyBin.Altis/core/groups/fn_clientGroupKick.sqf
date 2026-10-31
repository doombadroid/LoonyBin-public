params["_unit", "_group"];
if (isNil "_unit" || isNil "_group") exitWith {};
openMap false;
if ((player isEqualTo _unit) && ((group player) isEqualTo _group)) then {life_my_gang = objNull;
    [player] joinSilent(createGroup civilian);
    ["You have been kicked out of the group.", "basic"] spawn life_fnc_handleMessage;
    if (isNil {(group player) getVariable "gang_id"} && !(life_gang_data isEqualTo[])) then {life_action_in_use = true;
        if !(isNull(findDisplay 2620)) then {[] spawn life_fnc_groupMenu;};
        [] spawn life_fnc_initGang;};};