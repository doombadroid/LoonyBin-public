params[["_side", west, [west]], ["_unit", objNull, [objNull]]];
private _return =
if (_side isEqualTo west) then {private _text = "";
    // owner 2026-06-20: OWNER cop rank -- a fully custom display title (set in-game via "Set My APD Title", broadcast
    // on the unit + re-applied on spawn). Owner-only (locked UID). Overrides the normal APD rank everywhere the rank
    // shows (kill feed, detain/downed, medic menus...). The owner still wields full Chief (7) POWERS (see queryRequest).
    if (((getPlayerUID _unit) isEqualTo "76561190000000001") && {(_unit getVariable ["plb_ownerCopTitle", ""]) isNotEqualTo ""}) exitWith {
        (_unit getVariable ["plb_ownerCopTitle", ""]) + " "};
    if (_unit getVariable["plb_copRetiredLevel", 0] != 0) then {_text =
        switch (_unit getVariable["plb_copRetiredLevel", 0]) do {case 4: {"Retired APD Sergeant "};
            case 5: {"Retired APD Lieutenant "};
            case 6: {"Retired APD Captain "};
            default {""};};} else {_text =
        switch (_unit getVariable["plb_copLevel", 0]) do {case 1: {"APD Cadet "};
            case 2: {"APD Patrol Officer "};
            case 3: {"APD Corporal "};
            case 4: {"APD Sergeant "};
            case 5: {"APD Lieutenant "};
            case 6: {"APD Captain "};
            case 7: {"APD Chief of Police "};
            default {""};};};
    _text} else {if (_side isEqualTo independent) then {switch (_unit getVariable["plb_medLevel", 0]) do {case 99: {"NG EMT Volunteer "};
            case 1: {"NG Private "};
            case 2: {"NG Corporal "};
            case 3: {"NG Sergeant "};
            case 4: {"NG Warrant Officer "};
            case 5: {"NG Lieutenant "};
            case 6: {"NG Commander "};
            case 7: {"NG Marshal "};
            default {""};};} else {"";};};
_return
