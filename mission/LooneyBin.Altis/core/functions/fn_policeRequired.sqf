params[["_required", 1, [1]], ["_ignoreFed", false, [false]], ["_showMessage", true, [false]]];
// owner 2026-06-17 (#333): beta zero-cop waiver TURNED OFF. PLB_betaZeroCops now defaults FALSE (matching the
// server-side checks in fedAlarm/bankDrillVault/jewelryEmporiumSRV + the publicVariable set in init.sqf:535),
// so cop requirements ENFORCE even on a JIP client whose flag hasn't synced. Only an explicit =true (none ship
// now) re-waives. The whole heist suite (bank/fed/prison/evidence/convoy/jewelry/Loony Bin) gates through here.
if (missionNamespace getVariable ["PLB_betaZeroCops", false]) exitWith { true };
// owner 2026-07-03: floor EVERY heist/fed/prison-break cop requirement at 1 online officer. Several callers
// pass 0 (fed dome/gate/safe [0,true]) or a server-data field left at 0 for beta; this makes at-least-1-cop
// the universal minimum without touching each call site. The PLB_betaZeroCops admin override above still waives.
_required = _required max 1;
private _initRequired = _required;
private _cops = west countSide allPlayers;
private _message = "You";
if (_initRequired < _required) then {_message = "Because of crimes already in progress, you"};
if (((_cops < _required) && !(life_fed_robbed select 0)) && _showMessage) then {
    [format["%1 cannot initiate this crime with fewer than %2 police officers online. An additional %3 officers are required.", _message, _required, _required - _cops], "basic"] spawn life_fnc_handleMessage;
};
(_cops >= _required)