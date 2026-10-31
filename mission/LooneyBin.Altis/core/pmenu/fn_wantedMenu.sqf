#include "..\..\macro.h"
params[["_forceOpen", false, [false]]];
if !(isNull(findDisplay 2400)) exitWith {closeDialog 0;};
if !(isNull(findDisplay 386000)) exitWith {};
if (PLB_Server isEqualTo 2) exitWith {};
if (!_forceOpen && {scriptAvailable(5)}) exitWith {
    ["You can only access the APD Wanted List every 5 seconds!", "basic"] spawn life_fnc_handleMessage;};
disableSerialization;
["life_wanted_menu"] call life_fnc_createDialog;
private _display = findDisplay 2400;
private _connection = _display displayCtrl 2401;
private _wantedList = _display displayCtrl 2402;
private _criminalState = _display displayCtrl 2403;
private _bountyPrice = _display displayCtrl 2404;
private _chargesList = _display displayCtrl 2405;
private _removeInput = _display displayCtrl 2406;
private _removeButton = _display displayCtrl 2407;
private _button1 = _display displayCtrl 2408;
private _button2 = _display displayCtrl 2409;
private _button3 = _display displayCtrl 2410;
private _chargesBackground = _display displayCtrl 2420; {lbClear _x}
forEach[_wantedList, _chargesList];
_connection ctrlSetText "Establishing connection";
private _buttonIndex = 0; {_x params["_title", "_code", "_condition"];
    private _currentButton =
    switch (_buttonIndex) do {case 0: {_button1};
        case 1: {_button2};
        case 2: {_button3};
        default {controlNull};}; if ((!isNull _currentButton) && ([] call _condition)) then {_buttonIndex = _buttonIndex + 1;
        _currentButton ctrlSetText _title;
        _currentButton ctrlSetEventHandler["ButtonClick", format["[] call %1", _code]];
        _currentButton ctrlShow true;
        switch (_forEachIndex) do {case 0: {if (((call life_copLevel) >= 2) || ((call life_adminLevel) >= 3)) then {{
                            private _position = ctrlPosition _x;
                            _position params["_axisX", "_axisY", "_width", "_height"];
                            _x ctrlSetPosition[_axisX, _axisY, _width, _height - 0.0452];
                            _x ctrlCommit 0;}
                        forEach[_chargesList, _chargesBackground]; {_x ctrlShow true}
                        forEach[_removeInput, _removeButton];};};
            case 1: {_currentButton ctrlEnable false;};};};}
forEach[["Pardon", {[] spawn life_fnc_pardon;}, {
    ((call life_copLevel) >= 2) || ((call life_adminLevel) >= 3) || (getPlayerUID player isEqualTo(SRV_governorData param[0, "GovUID"]))
}], ["Drop", {[] call life_fnc_dropBounty;
    closeDialog 0}, {!(life_bounty_list isEqualTo[])}]]; [[player], "TON_fnc_wantedFetch", 2] call life_fnc_MP;