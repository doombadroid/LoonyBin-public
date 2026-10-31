disableSerialization;
if (isNull(findDisplay 2540)) then {private _dialog = findDisplay 2520;
    private _gangs = _dialog displayCtrl 2521;
    private _sel = lbCurSel _gangs;
    private _data = _gangs lbData _sel;
    if (life_passiveModeJIP) exitWith {
        ["You cannot join a group while in passive mode! You can disable it on your phone (Y).", "basic"] spawn life_fnc_handleMessage;};
    private _index = [_data, randomized_life_group_list] call life_fnc_index;
    if (_index isEqualTo - 1) exitWith {["Couldn't find that group.", "basic"] spawn life_fnc_handleMessage;};
    private _gang = randomized_life_group_list select _index;
    _gang params["_name", "_group", "_locked", "_ownerID", "_password"];
    if !(isNull _group) then {if ((call life_adminLevel >= 5) || !(_locked)) then {[player] join _group;
            life_my_gang = _group;
            [format["You have joined the group: %1", _name], "basic"] spawn life_fnc_handleMessage;
            [] spawn life_fnc_groupMenu;} else {life_targetGroup = _gang;
            ["groupMenuPassword"] spawn life_fnc_createDialog;};
        _name spawn {uiSleep 0.5;
            private _units = (units group player) apply {getPlayerUID _x}; [
                ["-GROUP-", player, (profileName), format["joined the group named: %1. Members: %2", _this, _units]], "TON_fnc_logIt", 2] call life_fnc_MP;
        };} else {["Group is not valid", "basic"] spawn life_fnc_handleMessage;};} else {private _dialog = findDisplay 2540;
    private _password = ctrlText 2543;
    life_targetGroup params["_name", "_group", "_locked", "_ownerID", "_groupPassword"];
    if !(isNull _group) then {if (_password == _groupPassword && _password != "") then {closeDialog 0;
            [player] join _group;
            life_my_gang = _group;
            [format["You have joined the group: %1", _name], "basic"] spawn life_fnc_handleMessage;
            _name spawn {uiSleep 0.5;
                private _units = (units group player) apply {getPlayerUID _x}; [
                    ["-GROUP-", player, (profileName), format["joined the passworded group named: %1. Members: %2", _this, _units]], "TON_fnc_logIt", 2] call life_fnc_MP;
            };} else {["Incorrect password.", "basic"] spawn life_fnc_handleMessage;
            [] spawn life_fnc_groupMenu;};} else {["Group is not valid", "basic"] spawn life_fnc_handleMessage;};};