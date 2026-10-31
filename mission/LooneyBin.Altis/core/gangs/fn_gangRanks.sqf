params[["_rank", 0, [0]]];
life_gang_data set[2, _rank];
if !(_rank isEqualTo - 1) then {[format["Your gang rank is now: %1", _rank], "basic"] spawn life_fnc_handleMessage;};
player setVariable["gang_data", life_gang_data, true];
switch (_rank) do {case -1: {if !(isNull(findDisplay 9620)) then {closeDialog 0};
            ["You are no longer a member of your gang.", "basic"] spawn life_fnc_handleMessage;
            if !(isNil {(group player) getVariable "gang_id"}) then {[player] joinSilent(createGroup civilian);};
            deleteMarkerLocal life_gangBldgMark;
            life_gang_data = [];
            life_gangBuilding = [objNull, []];
            life_gangBldgMark = "";
            player setVariable["gang_data", nil, true];};
    case 1: {["You are now the leader of your gang!", "basic"] spawn life_fnc_handleMessage;
            if !(isNil {(group player) getVariable "gang_id"}) then {player setRank "COLONEL";
                group player selectLeader player;};};
    case 2: {
            ["You can now promote, withdraw funds, access the gang house storage and kick members from your gang.", "basic"] spawn life_fnc_handleMessage;
        };
    case 3: {["You can now invite other players to your gang.", "basic"] spawn life_fnc_handleMessage;};};