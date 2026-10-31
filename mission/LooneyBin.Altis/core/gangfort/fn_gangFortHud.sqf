if !((gang_fortress_flag getVariable["plb_gang_fortress_data", [-1, "Unknown", false]]) param[2]) exitWith {};
if (life_gangFortHudID != -1) then {removeMissionEventHandler["Draw3D", life_gangFortHudID];
    life_gangFortHudID = -1;};
disableSerialization;
412 cutRsc["plb_gangFortHUD", "PLAIN", -1, true];
private _plb_display = uiNamespace getVariable "plb_gangFortHUD";
private _gangFortSelfPlace = _plb_display displayCtrl 123401;
private _gangFortTopBar = _plb_display displayCtrl 123402;
private _gangFortFirstPlace = _plb_display displayCtrl 123403;
private _gangFortSecondPlace = _plb_display displayCtrl 123404;
private _gangFortThirdPlace = _plb_display displayCtrl 123405; {_x ctrlCommit 0}
forEach[_gangFortSelfPlace, _gangFortTopBar, _gangFortFirstPlace, _gangFortSecondPlace, _gangFortThirdPlace];
_handlerID = addMissionEventHandler["Draw3D", {
    // #561: self-terminate when the event ends. The server flips plb_gang_fortress_data param[2] to false globally
    // at fort end (fn_gangFortressSRV) but never tore this HUD down, so the scoreboard lingered until the next
    // restart. Remove our own Draw3D handler + clear the cutRsc title layer (412) once the fort is inactive.
    if !((gang_fortress_flag getVariable["plb_gang_fortress_data", [-1, "Unknown", false]]) param[2]) exitWith {
        removeMissionEventHandler["Draw3D", _thisEventHandler];
        life_gangFortHudID = -1;
        412 cutText["", "PLAIN"];};
    _thisArgs params["_gangFortSelfPlace", "_gangFortFirstPlace", "_gangFortSecondPlace", "_gangFortThirdPlace"];
    life_gang_data params["_playerGangID", "_playerGangName"];
    private _topGang1 = [-1, "N/a", -1];
    private _topGang2 = [-1, "N/a", -1];
    private _topGang3 = [-1, "N/a", -1];
    private _previousGang = [-1, "N/a", 0];
    private _currentGangFortData = SRV_gangFortressData; {_x params["_xGangID", "_xGangName", "_xGangPoints"];
        if (_xGangPoints > (_topGang1 select 2)) then {_topGang1 = _x;};}
    forEach _currentGangFortData; {_x params["_xGangID", "_xGangName", "_xGangPoints"];
        if (_xGangID != (_topGang1 select 0)) then {if (_xGangPoints > (_topGang2 select 2)) then {_topGang2 = _x;};};}
    forEach _currentGangFortData; {_x params["_xGangID", "_xGangName", "_xGangPoints"];
        if (_xGangID != (_topGang2 select 0) && _xGangID != (_topGang1 select 0)) then {if (_xGangPoints > (_topGang3 select 2)) then {
                _topGang3 = _x;};};}
    forEach _currentGangFortData;
    private _topGang1Name = (_topGang1 select 1);
    private _topGang1Points = (_topGang1 select 2);
    private _topGang2Name = (_topGang2 select 1);
    private _topGang2Points = (_topGang2 select 2);
    private _topGang3Name = (_topGang3 select 1);
    private _topGang3Points = (_topGang3 select 2);
    _topGang1Name = _topGang1Name select[0, 18];
    _topGang2Name = _topGang2Name select[0, 18];
    _topGang3Name = _topGang3Name select[0, 18]; {_x params["_gangText", "_gangName", "_gangPoints", "_textColor"];
        if !(_gangPoints isEqualTo - 1) then {
            _gangText ctrlSetStructuredText(parseText format["<t align='left' size='0.95' color='%1'>#%2: %3 | %4</t>", _textColor, _forEachIndex + 1, _gangName, [_gangPoints] call life_fnc_numberText]);
        } else {_gangText ctrlSetText "";};}
    forEach[[_gangFortFirstPlace, _topGang1Name, _topGang1Points, "#FFD700"], [_gangFortSecondPlace, _topGang2Name, _topGang2Points, "#C0C0C0"], [_gangFortThirdPlace, _topGang3Name, _topGang3Points, "#CD7F32"]];
    if (_currentGangFortData isEqualTo[] || life_gang_data isEqualTo[]) then {_gangFortSelfPlace ctrlSetText "";} else {
        private _gangFortDataIDX = _currentGangFortData findIf {(_x select 0) isEqualTo _playerGangID};
        if !(_gangFortDataIDX isEqualTo - 1) then {
            (_currentGangFortData select _gangFortDataIDX) params["_cGangID", "_cGangName", "_cGangPoints"];
            _gangFortSelfPlace ctrlSetStructuredText(parseText format["<t align='left' size='0.95' color='#FF0000' size='1.0'>%1 | %2</t>", _cGangName, [_cGangPoints] call life_fnc_numberText]);
        } else {
            _gangFortSelfPlace ctrlSetStructuredText(parseText format["<t align='left' size='0.95'color='#FF0000' size='1.0'>%1 | %2</t>", _playerGangName, 0]);
        };};}, [_gangFortSelfPlace, _gangFortFirstPlace, _gangFortSecondPlace, _gangFortThirdPlace]];
life_gangFortHudID = _handlerID;