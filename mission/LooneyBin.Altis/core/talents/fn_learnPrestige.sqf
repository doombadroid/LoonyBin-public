params[["_side", "", [""]]];
if (_side isEqualTo "") exitWith {};
[_side] spawn {params[["_side", "", [""]]];
    private _plb_display = findDisplay 123000;
    private _specialityListDisplayCtrl = _plb_display displayCtrl 123001;
    private _specialityInfoText = _plb_display displayCtrl 123002;
    private _specialityPointsText = _plb_display displayCtrl 123006;
    private _specialityButton = _plb_display displayCtrl 123004;
    private _specialityTreeTitle = _plb_display displayCtrl 123005;
    private _specialityID = parseNumber(lbData[123001, lbCurSel 123001]); (switch (_side) do {case "bh": {
                [life_honor_talents, ["getRowByID", "bh", _specialityID] call life_fnc_prestigeCfg]}; case "cop": {
                    [life_cop_talents, ["getRowByID", "cop", _specialityID] call life_fnc_prestigeCfg]};
            case "rebel": {[life_infamy_talents, ["getRowByID", "rebel", _specialityID] call life_fnc_prestigeCfg]};
            case "medic": {[life_medic_talents, ["getRowByID", "medic", _specialityID] call life_fnc_prestigeCfg]};
    }) params["_playerSpecialitysUnlocked", "_requestedSpecialityRow"];
    if (_requestedSpecialityRow isEqualTo[]) exitWith {systemChat "Error."};
    _requestedSpecialityRow params["_specialityID", "_requestSide", "_prerequisiteSpecialityID", "_depth", "_title", "_description", "_prestigeReq"];
    if (_specialityID in _playerSpecialitysUnlocked) then {private _child = ["getChild", _side, _specialityID] call life_fnc_prestigeCfg;
        if !(_child isEqualTo[]) exitWith {
            [format["You can't unlearn this speciality as it has a child talent, %1, which will need to be unlearned first.", _child select 4], "basic"] spawn life_fnc_handleMessage;
        };
        switch (_side) do {case "bh": {private _action = true;
                    _action = ["Unlearning an honor speciality will cost $5,000 - are you sure?", "Unlearn and refund honor", "Yes", "No"] call BIS_fnc_guiMessage;
                    if !(_action) exitWith {};
                    if !([5000] call life_fnc_debitCard) exitWith {};
                    _playerSpecialitysUnlocked deleteAt(_playerSpecialitysUnlocked findIf {_x isEqualTo _specialityID});
                    life_honor_exp = life_honor_exp + _prestigeReq;
                    [format["You have unlearned the speciality %1 and been refunded %2 honor.", _title, [_prestigeReq] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
                }; case "cop": {};
                case "rebel": {private _action = true;
                        _action = ["Unlearning an infamy speciality will cost $5,000 - are you sure?", "Unlearn and refund infamy", "Yes", "No"] call BIS_fnc_guiMessage;
                        if !(_action) exitWith {};
                        if !([5000] call life_fnc_debitCard) exitWith {};
                        _playerSpecialitysUnlocked deleteAt(_playerSpecialitysUnlocked findIf {_x isEqualTo _specialityID});
                        life_infamy_exp = life_infamy_exp + _prestigeReq;
                        [format["You have unlearned the speciality %1 and been refunded %2 infamy.", _title, [_prestigeReq] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
                    };
                case "medic": {};
                default {};};} else {switch (_side) do {case "bh": {
                    if (_prerequisiteSpecialityID > 0 && !(_prerequisiteSpecialityID in _playerSpecialitysUnlocked)) exitWith {
                        ["This speciality requires another speciality that you don't have!", "basic"] spawn life_fnc_handleMessage};
                    if (count life_honor_talents > 14) exitWith {
                        ["You may only have a maximum of 15 specialities in the skiptracer system", "basic"] spawn life_fnc_handleMessage};
                    if (_prestigeReq > life_honor_exp) exitWith {
                        ["You don't have enough honor to learn this.", "basic"] spawn life_fnc_handleMessage};
                    if (playerSide isEqualTo civilian && (_specialityID isEqualTo 11 && !(10 in life_honor_talents && 7 in life_honor_talents && 4 in life_honor_talents) || _specialityID isEqualTo 22 && !(15 in life_honor_talents && 18 in life_honor_talents && 21 in life_honor_talents))) exitWith {
                        ["This is a master level talent which requires all previous talents.", "basic"] spawn life_fnc_handleMessage};
                    _playerSpecialitysUnlocked pushBack _specialityID;
                    life_honor_exp = life_honor_exp - _prestigeReq;
                    [format["You have learned the speciality %1.", _title], "basic"] spawn life_fnc_handleMessage;
                    systemChat format["You have learned the speciality: %1.", _title];}; case "cop": {
                        if (_prerequisiteSpecialityID > 0 && !(_prerequisiteSpecialityID in _playerSpecialitysUnlocked)) exitWith {
                            ["This speciality requires another speciality that you don't have!", "basic"] spawn life_fnc_handleMessage};
                        if (_prestigeReq > life_prestige) exitWith {
                            ["You don't have enough prestige to learn this.", "basic"] spawn life_fnc_handleMessage};
                        _playerSpecialitysUnlocked pushBack _specialityID;
                        life_prestige = life_prestige - _prestigeReq;
                        [format["You have learned the speciality %1.", _title], "basic"] spawn life_fnc_handleMessage;
                        systemChat format["You have learned the speciality: %1.", _title];};
                case "rebel": {if (_prerequisiteSpecialityID > 0 && !(_prerequisiteSpecialityID in _playerSpecialitysUnlocked)) exitWith {
                            ["This speciality requires another speciality that you don't have!", "basic"] spawn life_fnc_handleMessage};
                        if (count life_infamy_talents > 20) exitWith {
                            ["You may only have a maximum of 21 specialities in the infamy system!", "basic"] spawn life_fnc_handleMessage
                        };
                        if (_prestigeReq > life_infamy_exp) exitWith {
                            ["You don't have enough infamy to learn this.", "basic"] spawn life_fnc_handleMessage};
                        if (playerSide isEqualTo civilian && !license_civ_rebel) exitWith {
                            ["You must have a rebel license to learn specialities.", "basic"] spawn life_fnc_handleMessage};
                        _playerSpecialitysUnlocked pushBack _specialityID;
                        life_infamy_exp = life_infamy_exp - _prestigeReq;
                        [format["You have learned the speciality %1.", _title], "basic"] spawn life_fnc_handleMessage;
                        systemChat format["You have learned the speciality: %1.", _title];};
                case "medic": {if (_prerequisiteSpecialityID > 0 && !(_prerequisiteSpecialityID in _playerSpecialitysUnlocked)) exitWith {
                            ["This speciality requires another speciality that you don't have!", "basic"] spawn life_fnc_handleMessage};
                        if ((call life_medicLevel) < 3) exitWith {
                            ["You must be an AEMT or higher to learn NG specialities.", "basic"] spawn life_fnc_handleMessage};
                        if (_prestigeReq > life_medic_exp) exitWith {
                            ["You don't have enough prestige to learn this.", "basic"] spawn life_fnc_handleMessage};
                        _playerSpecialitysUnlocked pushBack _specialityID;
                        life_medic_exp = life_medic_exp - _prestigeReq;
                        [format["You have learned the speciality %1.", _title], "basic"] spawn life_fnc_handleMessage;
                        systemChat format["You have learned the speciality: %1.", _title];};
                default {};};};
    [_side] spawn life_fnc_populatePrestigeTree;};