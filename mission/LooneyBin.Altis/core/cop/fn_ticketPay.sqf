if (isNil {life_ticket_val} || isNil {life_ticket_cop}) exitWith {};
if ((life_is_arrested param [0,0]) isEqualTo 1) exitWith {};
life_ticket_attempted = true;
private _copPaidAmount = life_ticket_val;
private _arrestCap = 1000000;
if ((call life_adminLevel) >= 2) then {if (_copPaidAmount > _arrestCap) then {_copPaidAmount = _arrestCap;};};
if (life_atmcash < life_ticket_val) exitWith {
    ["You don't have enough money in your bank account or on you to pay the ticket.", "basic"] spawn life_fnc_handleMessage; [
        [1, format["%1 couldn't pay the ticket due to not having enough money.", [profileName] call life_fnc_cleanName]], "life_fnc_broadcast", life_ticket_cop, false, false] spawn life_fnc_MP;
    closeDialog 0;};
if (life_ticket_val < 0) exitWith {[[player, [70, str life_ticket_val]], "TON_fnc_dongClient", 2] call life_fnc_MP;
    closeDialog 0;};
life_ticket_paid = true;
[format["You have paid the ticket of $%1", [life_ticket_val] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
life_atmcash = (round(life_atmcash - life_ticket_val)) max 0;
life_atmcashCacheB = ((life_atmcash / 4) + 11);
[1] call life_fnc_ClupdatePartial; [
    [0, format["%1 paid the ticket of $%2", profileName, [life_ticket_val] call life_fnc_numberText]], "life_fnc_broadcast", west, false, false] spawn life_fnc_MP;
[[life_ticket_cop, _copPaidAmount], "TON_fnc_copSplit", 2] spawn life_fnc_MP; [
    [2, format["$%1 has been spread amongst the active police force for a ticket paid by %2", [_copPaidAmount] call life_fnc_numberText, [profileName] call life_fnc_cleanName]], "life_fnc_broadcast", life_ticket_cop, false, false] spawn life_fnc_MP;
[999, getPlayerUID player] call life_fnc_wantedListAdd; [[getPlayerUID player], "TON_fnc_wantedRemove", 2] spawn life_fnc_MP;
player setVariable["plb_wantedAmt", (A_stats_crimes select 0), true];
[8] call life_fnc_ClupdatePartial;
[3] call life_fnc_ClupdatePartial;
[] call life_fnc_hudUpdate; [
    ["-TICKET-", player, (profileName), format["paid a ticket of %1 at POS: %2", life_ticket_val, getPosATL player]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
closeDialog 0;
private _uid = getPlayerUID player;
private _bountyHunters = allPlayers select {!(((_x getVariable["plb_myBounties", []]) findIf {_uid in _x}) isEqualTo - 1)};
if !(_bountyHunters isEqualTo[]) then {[_uid] remoteExec["life_fnc_removeBounty", _bountyHunters];};
if (life_allPointsBulletin param[1, "hehe"] isEqualTo _uid) then {life_allPointsBulletin = [];
    publicVariable "life_allPointsBulletin";};
if (life_ticket_val > 250) then {[life_ticket_val * 0.0012] remoteExec["life_fnc_addExperience", life_ticket_cop];
    [floor(life_ticket_val / 25)] remoteExec["life_fnc_earnPrestige", life_ticket_cop];};
["ticketspaidamount", life_ticket_val] call life_fnc_statArrUpdate;
["ticketspaid", 1] call life_fnc_statArrUpdate;