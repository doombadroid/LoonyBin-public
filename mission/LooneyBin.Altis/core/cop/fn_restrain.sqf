params[["_unit", objNull, [objNull]]];
if (isNull _unit || player isEqualTo _unit || !(isNull objectParent player) || !(_unit isKindOf "CAManBase")) exitWith {};
if (player distance(getMarkerPos "courtroom") < 50) exitWith {};
if ((playerSide isEqualTo west) && (side _unit isEqualTo west)) exitWith {};
if (_unit getVariable["plb_restrained", false] || _unit getVariable["plb_escorting", false]) exitWith {};
if ((player getVariable["plb_surrendered", false]) || (player getVariable["plb_restrained", false])) exitWith {
    ["How could you possibly restrain someone right now?", "basic"] spawn life_fnc_handleMessage;};
if (player distance _unit > 8 && (call life_adminLevel <= 1)) exitWith {};
private _exit = false;
if !(playerSide isEqualTo west) then {if (_unit getVariable["plb_passivemode", false]) exitWith {
        ["This player is in passive mode and cannot be restrained.", "basic"] spawn life_fnc_handleMessage;
        _exit = true};
    if (life_inv_ziptie < 1) exitWith {["You need a zip tie to restrain someone.", "basic"] spawn life_fnc_handleMessage;
        _exit = true};
    if !([false, "ziptie", 1] call life_fnc_handleInv) exitWith {_exit = true};
    ["ziptied", 1] call life_fnc_statArrUpdate;
    private _groupMembersBounties = units player apply {(_x getVariable["plb_myBounties", []]) apply {_x select 0}};
    private _lawfulRestraint = (8 in life_side_talents && !(_groupMembersBounties findIf {getPlayerUID _unit in _x}
    isEqualTo - 1)) || !(life_bounty_list findIf {getPlayerUID _unit in _x}
    isEqualTo - 1) || group _unit isEqualTo group player;
    if !(_lawfulRestraint) then {[[20, player], "TON_fnc_wantedAdd", 2] spawn life_fnc_MP;};};
if (_exit) exitWith {};
private _toSend = (allPlayers - [allDeadMen]) select {(_x distance player) <= 10};
private _restrainSound =
if (playerSide isEqualTo west) then {"handcuffs"} else {
    "ziptie"}; [[_unit, _restrainSound], "life_fnc_playSound", _toSend] spawn life_fnc_MP; [
    [player, _unit, false], "life_fnc_restrainAction", _unit] spawn life_fnc_MP; [
    ["-RESTRAIN-", player, (profileName), format["(%1) restrained %2 (%3) (%4) at %5", playerSide, name _unit, getPlayerUID _unit, side _unit, getPosATL player]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;