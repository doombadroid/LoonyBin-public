params[["_target", objNull, [objNull]]];
if (isNull _target) exitWith {};
if !(isPlayer _target) exitWith {};
if (_target getVariable["plb_passivemode", false]) exitWith {
    ["This player is in passive mode and cannot be robbed.", "basic"] spawn life_fnc_handleMessage;};
private _BH = 8 in life_side_talents;
private _idx = life_bounty_list findIf {(getPlayerUID _target) in _x};
private _bhTarget =
if (_idx isEqualTo - 1) then {false} else {true}; [
    [player, _BH && 17 in life_honor_talents && (_bhTarget || 22 in life_honor_talents), _BH && 18 in life_honor_talents && (_bhTarget || 22 in life_honor_talents)], "life_fnc_robPerson", _target] spawn life_fnc_MP;