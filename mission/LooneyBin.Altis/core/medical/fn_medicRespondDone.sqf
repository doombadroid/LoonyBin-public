params[["_caller", objNull, [objNull]], ["_responder", objNull, [objNull]]];
if (isNil "life_session_completed" || {!life_session_completed}) exitWith {};
if (_responder isEqualTo _caller && _responder isEqualTo player || (isNull(life_medicAcceptedCorpse param[1, objNull]))) exitWith {};
if (_responder isNotEqualTo player && {
    isNull _caller || (isNull(life_medicAcceptedCorpse param[1, objNull])) || playerSide isEqualTo civilian || (playerSide isEqualTo west && !(life_copRole in ["medic", "all"]))
}) exitWith {};
private _travelBonus =
if ((life_medicAcceptedCorpse param[4, [0, 0, 0]]) isEqualTo[0, 0, 0]) then {0} else {
    0.2 * (round(getPos player distance(life_medicAcceptedCorpse param[4, [0, 0, 0]])))};
if ((life_medicAcceptedCorpse param[1, objNull]) isEqualTo _responder) then {life_atmcash = (round(life_atmcash + _travelBonus)) max 0;
    life_atmcashCacheB = ((life_atmcash / 4) + 11);
    [format["%1 bled out and no longer requires medical attention. You have received $%2 for your troubles.", name _caller, _travelBonus], "basic"] spawn life_fnc_handleMessage;
    life_medicAcceptedCorpse = [objNull, objNull, "", "", [0, 0, 0], -1800];} else {if (_responder isNotEqualTo player) then {
        life_atmcash = (round(life_atmcash + _travelBonus)) max 0;
        life_atmcashCacheB = ((life_atmcash / 4) + 11);
        [format["%1 was revived by %2 and no longer requires medical attention. You have received $%3 for your troubles.", name _caller, name _responder, _travelBonus], "basic"] spawn life_fnc_handleMessage;
        life_medicAcceptedCorpse = [objNull, objNull, "", "", [0, 0, 0], -1800];} else {
        if ((life_medicAcceptedCorpse param[0, objNull]) isEqualTo _caller) then {
            _travelBonus = 0.25 * (round(getPos player distance(life_medicAcceptedCorpse param[4, [0, 0, 0]])));
            life_medicAcceptedCorpse = [objNull, objNull, "", "", [0, 0, 0], -1800];} else {_travelBonus = 0;};
        private _reviveReward = (call life_revive_fee);
        if (playerSide isEqualTo independent && side _caller isEqualTo independent) then {_travelBonus = 0;} else {
            _reviveReward = _reviveReward + 1000;
            if (122 in life_side_talents) then {_reviveReward = _reviveReward * 1.2};};
        _reviveReward = _reviveReward + _travelBonus;
        if (_reviveReward < 0) then {_reviveReward = 0;};
        if (playerSide isEqualTo independent) then {private _partners = [];
            if !(life_medPartners isEqualTo[]) then {_partners = [7, objNull] call life_fnc_medicPartners;};
            if (_partners isEqualTo[]) then {life_atmcash = life_atmcash + _reviveReward;
                life_atmcashCacheB = ((life_atmcash / 4) + 11);
                titleText[format["You have revived %1 and received $%2 for rendering aid.", name player, [_reviveReward] call life_fnc_numberText], "PLAIN"];
            } else {_reviveReward = round(_reviveReward / ((count _partners) + 1));
                life_atmcash = life_atmcash + _reviveReward;
                life_atmcashCacheB = ((life_atmcash / 4) + 11);
                titleText[format["You have revived %1 and received $%2 for rendering aid.", name player, [_reviveReward] call life_fnc_numberText], "PLAIN"];
                [
                    [format["You have received %1 for a revive performed by %2.", [_reviveReward] call life_fnc_numberText, profileName]], "life_fnc_handleMessage", _partners] call life_fnc_MP;
                [[_partners, _reviveReward], "TON_fnc_medicSplit", 2] spawn life_fnc_MP;};} else {
            life_atmcash = (round(life_atmcash + (_reviveReward + _travelBonus))) max 0;
            life_atmcashCacheB = ((life_atmcash / 4) + 11);};
        titleText[format["You have revived %1 and received $%2 for your services.", name _caller, [_reviveReward] call life_fnc_numberText], "PLAIN"];
        private _xpReward =
        if (playerSide isEqualTo independent) then {50} else {30};
        life_side_exp = life_side_exp + _xpReward;};};
[1] call life_fnc_ClupdatePartial;