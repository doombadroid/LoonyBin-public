params[["_jail", false, [false]]];
if !(isNull life_escort) then {[] call life_fnc_stopEscorting;};
private _bountyAmount = A_stats_crimes select 0;
if ((A_stats_crimes select 0) <= 0) exitWith {};
if (player getVariable["plb_restrained", false]) exitWith {
    ["Turning yourself in is not available while restrained!", "basic"] spawn life_fnc_handleMessage;};
if (player getVariable["plb_surrendered", false]) exitWith {
    ["Turning yourself in is not available while your hands are up!", "basic"] spawn life_fnc_handleMessage;};
if (_jail && (_bountyAmount > 100000)) exitWith {
    ["You cannot turn yourself in to jail at this time. Pay your warrant value in full instead.", "basic"] spawn life_fnc_handleMessage;};
private _action = false;
private _exit = false;
if (_jail) then {private _curPos = getPos player;
    _action = ["Are you sure you want to turn yourself in and go to prison?", "Go To Prison", "Yes", "No"] call BIS_fnc_guiMessage;
    if (!(_action) || (_curPos distance(getPos player) >= 10) || (player getVariable["plb_restrained", false])) exitWith {_exit = true;}; [
        [getPlayerUID player], "TON_fnc_setJail", false, false] spawn life_fnc_MP;
    [player, false] spawn life_fnc_jailPlayer;
    _exit = true;
    if (life_allPointsBulletin param[1, "hehe"] isEqualTo(getPlayerUID player)) then {life_allPointsBulletin = [];
        publicVariable "life_allPointsBulletin";};};
if (_exit) exitWith {};
_action = [format["You are currently wanted for $%1! Pay this off in full now?", [_bountyAmount] call life_fnc_numberText], "Pay Off Bounty", "Yes", "No"] call BIS_fnc_guiMessage;
if !(_action) exitWith {};
if (life_atmcash >= _bountyAmount) then {[999, getPlayerUID player] call life_fnc_wantedListAdd; [
        [getPlayerUID player], "TON_fnc_wantedRemove", 2] spawn life_fnc_MP;
    life_atmcash = life_atmcash - _bountyAmount;
    life_atmcashCacheB = ((life_atmcash / 4) + 11);
    [1] call life_fnc_ClUpdatePartial;
    private _bountyHunters = allPlayers select {!(((_x getVariable["plb_myBounties", []]) findIf {(getPlayerUID player) in _x
        }) isEqualTo - 1)};
    if !(_bountyHunters isEqualTo[]) then {[getPlayerUID player, false] remoteExec["life_fnc_removeBounty", _bountyHunters];};
    if (life_allPointsBulletin param[1, "hehe"] isEqualTo(getPlayerUID player)) then {life_allPointsBulletin = [];
        publicVariable "life_allPointsBulletin";};} else {
    ["You cannot afford to pay your fines in full. Consider serving a prison sentence instead.", "basic"] spawn life_fnc_handleMessage;};