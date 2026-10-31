params[["_mode", 0, [0]], ["_group", grpNull, [grpNull]], ["_tag", "", [""]]];
if !(_mode in [1, 2, 3, 4]) exitWith {};
switch (_mode) do {case 1: {private _nonGangGroup = !(randomized_life_group_list findIf {_group in _x}
            isEqualTo - 1);
            if (_nonGangGroup) exitWith {
                ["You can't do this while in a temporary group, get back into your proper gang.", "basic"] spawn life_fnc_handleMessage};
            createDialog "life_ticket_give";
            private _button = findDisplay 2650 displayCtrl 1337;
            _button ctrlSetText "Set Tag";
            ctrlSetText[2651, format["Set tag for %1", life_gang_data select 1]];
            ["Here you can choose a tag, up to 4 characters, which will be displayed overhead and in kill messages.", "basic"] spawn life_fnc_handleMessage;
        };
    case 2: {["<t align='center'>Enter your desired gang tag.</t>", "Gang Tag", "Submit"] call life_fnc_inputMenu;
            if (life_input_response isEqualTo "") exitWith {["You failed to enter a gang tag.", ""] spawn life_fnc_handleMessage;};
            private _tag = life_input_response;
            life_input_response = "";
            if (count _tag > 4) exitWith {["This tag is too long and must be 4 characters or less.", "basic"] spawn life_fnc_handleMessage
            };
            if (_tag == "APD" || _tag == "NG") exitWith {["This tag is not allowed.", "basic"] spawn life_fnc_handleMessage}; [
                [life_gang_data select 0, _tag, group player, true], "TON_fnc_setGangTagSRV", 2] spawn life_fnc_MP;
            closeDialog 0;
            [format["You have chosen your gang tag as [%1]", _tag], "basic"] spawn life_fnc_handleMessage;};
    case 3: {profileNamespace setVariable[format["plb_tag%1", _group], _tag];};
    case 4: {_group setVariable["gangTag", profileNamespace getVariable[format["plb_tag%1", _tag], ""], true];};};