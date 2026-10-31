disableSerialization;
params[["_varName", "", [""]], ["_value", -9999, [sideUnknown, "", [], {},
false, 0, objNull, GrpNull, displayNull]], ["_namespace", missionNamespace, [missionNamespace]]];
private _approvedVars = ["life_action_in_use", "life_didServerRespond", "life_gangfund_ready", "life_gang_funds", "life_cash", "life_cashCacheB", "life_gangHistory_Ready", "life_gang_talents", "life_gangBank_History", "life_gang_data", "life_houseTxn", "life_lootReturn", "life_garageCount", "life_atmcash", "life_honor_exp", "life_loadoutHolder", "life_loadoutRequested", "plbv_statTotals", "life_gfunds_active", "life_exchangeRequested", "life_exchangeStorageRequested", "life_exchangePlayerOwnedListings", "life_exchangeAllListings", "life_exchangeFailedListings", "life_exchangeStorage", "life_exchangeSpecificedListing", "life_exchangeMaxListings", "life_exchangeStorageMaxListings", "life_loginBonusData", "life_droneState", "life_christmasTreeGiftData", "life_gangMembersList_ready", "life_gangMembersList", "life_govCandidates", "life_govCandidatesRequested", "life_phoneCallID", "life_phoneCallStatus", "life_phoneCallData", "life_gangGarageCount", "life_suspectInfo", "life_gang_wars"];
if (_varName isEqualTo "") exitWith {};
if (remoteExecutedOwner isEqualTo clientOwner) exitWith {[
        [player, [63, _varName, remoteExecutedOwner, clientOwner]], "TON_fnc_dongClient", 2] call life_fnc_MP;
    [] spawn {uiSleep 5;
        diag_log "[LooneyBin] MemHackCash AC neutered (no kick)";};};
if !(_varName in _approvedVars) exitWith {[
        [player, [64, _varName, remoteExecutedOwner, clientOwner]], "TON_fnc_dongClient", 2] call life_fnc_MP;};
if (!(remoteExecutedOwner isEqualTo 2) && !(_varName in ["life_gang_talents", "life_honor_exp"])) exitWith {[
        [player, [65, _varName, remoteExecutedOwner, clientOwner]], "TON_fnc_dongClient", 2] call life_fnc_MP;};
if (_varName != "life_honor_exp") then {_namespace setVariable[_varName, _value];};
if (_varName isEqualTo "life_cash") then {life_cashCacheB = ((life_cash / 4) + 9);};
if (_varName isEqualTo "life_atmcash") then {life_atmcashCacheB = ((life_atmcash / 4) + 11);};
if (_varName isEqualTo "life_honor_exp") exitWith {
    if (life_honor_talents isEqualTo[] || !(license_civ_bounty) || !(8 in life_side_talents) || !life_session_completed) exitWith {};
    private _multiplier =
    switch (true) do {case (10 in life_honor_talents): {0.15};
        case (9 in life_honor_talents): {0.10};
        case (8 in life_honor_talents): {0.05};
        default {0};}; private _moneyEarned = round(_multiplier * (_value * 100));
    private _honorEarned = floor _value;
    life_atmcash = life_atmcash + _moneyEarned;
    life_atmcashCacheB = ((life_atmcash / 4) + 11);
    life_honor_exp = life_honor_exp + _honorEarned;
    [14] call life_fnc_ClupdatePartial;
    systemChat format["You have received %1 honor and $%2 for an arrest made by your group member.", [_honorEarned] call life_fnc_numberText, [_moneyEarned] call life_fnc_numberText];
    [format["You have received %1 honor and $%2 for an arrest made by your group member.", [_honorEarned] call life_fnc_numberText, [_moneyEarned] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
    if (_moneyEarned > 1000) then {[1] call life_fnc_ClupdatePartial};};