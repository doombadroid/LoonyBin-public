params[["_doRequest", false, [false]]];
if (time < (player getVariable["plb_next_revive", -1000])) then {
    titleText[format["You were recently revived and cannot be revived again for %1 seconds.", ceil((player getVariable["plb_next_revive", -1000]) - time)], "PLAIN"];
};
if !(life_corpse getVariable["plb_revivable", false]) then {life_corpse setVariable["plb_revivable", true, true];
    life_corpse setVariable["plb_faction", playerSide, true];};
private _toSend = (allPlayers - [allDeadMen] - [player]) select {
    (side _x isEqualTo west && _x getVariable["plb_copRole", ""] in ["medic", "all"]) || side _x isEqualTo independent};
if (_doRequest) then {
    private _action = ["You are going to request a National Guard to your location. Are you sure you want to continue?", "Request NG", "Yes", "No"] call BIS_fnc_GUIMessage;
    if !(_action) exitWith {}; [[player, life_corpse], "life_fnc_sendRequestToMedic", _toSend] spawn life_fnc_MP;};
[_doRequest] spawn {params["_doRequest"];
    private _requestBtn = (findDisplay 7300) displayCtrl 7303;
    private _allowBtn = (findDisplay 7300) displayCtrl 7306;
    if (_doRequest) then {player setVariable["plb_medRequest", true];
        _requestBtn ctrlEnable false;};
    _allowBtn ctrlEnable false;
    uiSleep(2 * 60);
    player setVariable["plb_medRequest", false];
    _requestBtn ctrlEnable true;
    _allowBtn ctrlEnable true;};
