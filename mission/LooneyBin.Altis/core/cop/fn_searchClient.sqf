params[["_cop", objNull, [objNull]]];
if (isNull _cop) exitWith {};
private _inv = [];
private _clothes = [];
private _robber = false;
private _runner = false;
private _seizableMoney = 0;
private _val = 0;
private _licenses = "";
private _illegalExempt =
if (SRV_governorData param[3, false]) then {life_governorLegalisableItems} else {[]}; {_x params["_item"];
    private _val = missionNamespace getVariable [format["life_inv_%1", _item], 0];
    if ((_val > 0) && !(_item in _illegalExempt)) then {_inv pushBack[_item, _val];};}
forEach(["getIllegalItems"] call life_fnc_virtItemCfg);
if (license_civ_bounty) then {missionNamespace setVariable["license_civ_gun", true]}; {_x params["_license", "_side"];
    _val = missionNamespace getVariable[_license, false];
    if (!isNil "_val") then {if (_val && _side isEqualTo "civ") then {
            _licenses = _licenses + (["varToStr", _license] call life_fnc_licenseCfg) + "<br/>";};};}
forEach life_licenses; {private _item = _x;
    if (_item in ["V_HarnessOGL_brn", "U_B_CombatUniform_mcam_worn", "U_I_CombatUniform_shortsleeve", "U_BG_Guerrilla_6_1", "U_Rangemaster", "V_TacVest_gen_F"]) then {
        private _clothingExists = _clothes findIf {(_x select 0) isEqualTo _item};
        if (_clothingExists isEqualTo - 1) then {_clothes pushBack[_item, 1];} else {
            _clothes set[_clothingExists, [_item, ((_clothes select _clothingExists) select 1) + 1]];};};}
forEach([uniform player, vest player] + (items player));
private _illegalActivity = "";
if (time - (player getVariable["plb_drugtrace", -1000]) < 400) then {if (life_cash > 0) then {_seizableMoney = life_cash};
    life_cash = 0;
    life_cashCacheB = ((life_cash / 4) + 9);
    [0] call life_fnc_CLupdatePartial; [[getPlayerUID player, "plb_drugtrace", -1000], "TON_fnc_varPersist", 2] spawn life_fnc_MP;
    _illegalActivity = "drugRunner";};
if (time - (player getVariable["plb_banktrace", -1000]) < 400) then {if (life_cash > 0) then {_seizableMoney = life_cash};
    life_cash = 0;
    life_cashCacheB = ((life_cash / 4) + 9);
    [0] call life_fnc_CLupdatePartial; [[getPlayerUID player, "plb_banktrace", -1000], "TON_fnc_varPersist", 2] spawn life_fnc_MP;
    _illegalActivity = "bankRobber";};
if (time - (player getVariable["plb_choptrace", -1000]) < 200) then {if (life_cash > 0) then {_seizableMoney = life_cash};
    life_cash = 0;
    life_cashCacheB = ((life_cash / 4) + 9);
    [0] call life_fnc_CLupdatePartial; [[getPlayerUID player, "plb_choptrace", -1000], "TON_fnc_varPersist", 2] spawn life_fnc_MP;
    _illegalActivity = "vehicleChop";};
life_lastPersistVar = ["", time];
if !(life_use_atm) then {if (life_cash > 0) then {_seizableMoney = life_cash};
    life_cash = 0;
    life_cashCacheB = ((life_cash / 4) + 9);
    [0] call life_fnc_CLupdatePartial;
    _illegalActivity = "gasStationRobber";};
private _newPlayer =
if (A_stats_civTime < 1440) then {"(NEW PLAYER)"} else {""}; [
    [player, _inv, _clothes, _illegalActivity, _licenses, _seizableMoney, life_alcohol_level, life_drug_level, _newPlayer, (call PLB_fnc_hasDeck)], "life_fnc_copSearch", _cop] spawn life_fnc_MP;   // owner 2026-07-20: 10th = illegal cyberdeck firmware flashed