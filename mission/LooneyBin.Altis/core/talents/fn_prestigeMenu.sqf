params[["_side", "", [""]]];
if (_side isEqualTo "") exitWith {closeDialog 0};
// LooneyBin: NG prestige is AEMT+ only (lower medic ranks have no access)
if (_side isEqualTo "medic" && {(call life_medicLevel) < 3}) exitWith {
    ["You must be an AEMT or higher to access the NG prestige system.", "basic"] spawn life_fnc_handleMessage;};
disableSerialization;
createDialog "life_talent_menu";
waitUntil {!isNull(findDisplay 123000)};
private _plb_display = findDisplay 123000;
[_plb_display] spawn life_fnc_p_updateMenu;
private _plb_display = findDisplay 123000;
private _specialityListDisplayCtrl = _plb_display displayCtrl 123001;
private _specialityInfoText = _plb_display displayCtrl 123002;
private _specialityPointsText = _plb_display displayCtrl 123006;
private _specialityButton = _plb_display displayCtrl 123004;
private _specialityTreeTitle = _plb_display displayCtrl 123005;
private _specialityRequiredPointsTitle = _plb_display displayCtrl 123003;
_specialityButton ctrlSetText "SELECT SPECIALITY";
_specialityButton ctrlShow false;
_specialityButton ctrlEnable false;
if (playerSide isEqualTo civilian) then {_specialityButton ctrlEnable false} else {_specialityButton ctrlShow false};
if (_side isEqualTo "cop") then {_specialityButton ctrlShow false};
_specialityButton ctrlShow true;
_specialityButton ctrlEnable false; (switch (_side) do {case "bh": {[life_honor_talents, "Available %1: %2", "Honor", life_honor_exp, 14]
        }; case "cop": {[life_cop_talents, "Available %1: %2", "Prestige", life_prestige, 16]};
        case "rebel": {[life_infamy_talents, "Available %1: %2", "Infamy", life_infamy_exp, 22]};
        case "medic": {[life_medic_talents, "Available %1: %2", "Prestige", life_medic_exp, 23]};
}) params["_playerSpecialitysUnlocked", "_statsText", "_specialityName", "_specialityValue", "_partialSyncNumber"];
_specialityTreeTitle ctrlSetStructuredText parseText format["<t size='0.90' align='center'>%1 Talent Tree</t>", _specialityName];
_specialityPointsText ctrlSetStructuredText parseText format["<t size='0.70' align='center'>Available %1: %2</t>", _specialityName, [_specialityValue] call life_fnc_numberText];
_specialityInfoText ctrlSetStructuredText parseText format["<t size='0.60' align='center'>Select a speciality from the tree for more information on its requirements and the benefits it brings. You must have enough prestige in order to learn a speciality.</t>"];
_specialityRequiredPointsTitle ctrlSetStructuredText parseText "<t size='0.70' align='center'></t>";
[_side] call life_fnc_populatePrestigeTree;
_specialityListDisplayCtrl ctrlSetEventHandler["LBSelChanged", format["['%1'] call life_fnc_prestigeInfo", _side]];
_specialityButton ctrlSetEventHandler["ButtonClick", format["['%1'] call life_fnc_learnPrestige", _side]];
if (life_prestigeSync) exitWith {};
[_playerSpecialitysUnlocked, _specialityValue, _partialSyncNumber] spawn {
    params["_playerSpecialitysUnlocked", "_specialityValue", "_partialSyncNumber"];
    life_prestigeSync = true;
    private _preSpecialitysUnlocked = str _playerSpecialitysUnlocked;
    private _preSpecialityValue = str _specialityValue;;
    waitUntil {isNull(findDisplay 123000)};
    life_prestigeSync = false;
    if ((str _specialityValue != _preSpecialityValue) || (str _playerSpecialitysUnlocked != _preSpecialitysUnlocked)) then {
        [_partialSyncNumber] call life_fnc_ClupdatePartial;};
    if (playerSide isEqualTo west) then {life_track_radius =
        switch (true) do {case (8 in life_cop_talents): {200};
            case (7 in life_cop_talents): {300};
            case (6 in life_cop_talents): {400};
            case (5 in life_cop_talents): {500};
            case (4 in life_cop_talents): {800};
            case (3 in life_cop_talents): {900};
            case (2 in life_cop_talents): {1000};
            default {1400};};};};