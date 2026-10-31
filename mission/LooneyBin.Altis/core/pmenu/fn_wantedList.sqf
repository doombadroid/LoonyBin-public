params[["_info", [], [[]]]];
disableSerialization;
private _display = findDisplay 2400;
if (isNull _display) exitWith {};
private _connection = _display displayCtrl 2401;
private _wantedList = _display displayCtrl 2402;
private _criminalState = _display displayCtrl 2403;
private _bountyPrice = _display displayCtrl 2404;
private _chargesList = _display displayCtrl 2405;
private _removeButton = _display displayCtrl 2407;
private _isAdmin = call life_adminLevel >= 3;
private _isPolice = playerSide isEqualTo west;
private _isGovernor = (getPlayerUID player) isEqualTo(SRV_governorData param[0, ""]);
private _civilians = allPlayers select {side _x isEqualTo civilian};
private _criminals = (_civilians select {private _playerID = getPlayerUID _x;
    private _isBounty = (life_bounty_list findIf {(_x select 0) isEqualTo _playerID}
    isNotEqualTo - 1) && (_x getVariable["plb_wantedAmt", 0] >= 25000);
    // owner 2026-06-30: the phone-redux import (54a44110) swapped the working `A_stats_crimes select 0` for the
    // A1013 var `life_wantedAmount`, which does not exist in LB. `&&` with a bare RHS evaluates it eagerly for EVERY
    // civilian in this select-filter -> undefined-var throw -> the predicate aborts before the _isPolice OR below ->
    // _criminals comes out empty -> "No criminals found" for everyone, cops included. Restore the player's own
    // bounty via the safe param form (A_stats_crimes can be malformed; select 0 would footgun).
    private _isSelf = _playerID isEqualTo(getPlayerUID player) && (A_stats_crimes param [0, 0]) > 0;
    private _inCourt = (player distance2D(getMarkerPos "courtroom") < 150) && {
        (player in (SRV_trialData select 1)) && (_playerID isEqualTo(getPlayerUID(SRV_trialData select 0)))};
    _isAdmin || _isPolice || _isGovernor || _isBounty || _isSelf || _inCourt}) apply {getPlayerUID _x}; {_x params["_name", "_uid"];
    private _unit = _civilians param[_civilians findIf {(getPlayerUID _x) isEqualTo _uid}, objNull];
    if !(isNull _unit) then {if (_uid in _criminals) then {private _index = _wantedList lbAdd _name;
            _wantedList lbSetData[_index, str _x];
            if (_unit getVariable["plb_arrested", false]) then {_wantedList lbSetColor[_index, [1, 1, 1, 0.70]];
                _wantedList lbSetSelectColor[_index, [1, 1, 1, 0.70]];};};};}
forEach _info;
lbSort _wantedList;
_connection ctrlSetText "Connection Established"; {_x ctrlSetFade 0;
    _x ctrlCommit 0.20}
forEach[_wantedList, _criminalState, _bountyPrice, _chargesList];
if ((lbSize _wantedList) isEqualTo 0) exitWith {_wantedList lbAdd "No criminals found";};
_removeButton ctrlSetEventHandler["ButtonClick", "_this call life_fnc_dropCharge"];
_wantedList ctrlSetEventHandler["LBSelChanged", "_this call life_fnc_wantedInfo"];
_wantedList lbSetCurSel - 1;