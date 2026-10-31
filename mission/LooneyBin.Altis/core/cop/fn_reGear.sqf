if !(playerSide isEqualTo west) exitWith {};
if (life_activeSWAT || life_eviSpawn) exitWith {};
private _weapons = (["police_weapons"] call life_fnc_weaponShopCfg) select 1;
private _weaponAddons = ["police_weapons"] call life_fnc_weaponAddons;
private _nades = [["miniGrenade", nil, 1000], ["handGrenade", nil, 5000], ["smokeShell", nil, 100], ["chemlight", nil, 100]];
private _clothing = [];
for "_i"
from 0 to 4 do {_clothing pushBack([_i] call life_fnc_clothing_cop);
}; _clothing params["_uniforms", "_hats", "_glasses", "_vests", "_backpacks"];
life_dead_gear params["_primary", "_launcher", "_handgun", "_magazines", "_uniform", "_vest", "_backpack", "_items", "_primaryItems", "_secondaryItems", "_handgunItems", "_uniformItems", "_vestItems", "_equipmentItems", "_headgear", "_goggles"];
private _totalPrice = 0; {_x params["_prices", "_gear"]; {private _element = _x;
        if (_element isEqualType[]) then {{_x params["_magazine", "_ammoCount"];
                private _price = (_prices param[_prices findIf {(_x select 0) == _magazine}, 0]) param[2, 0];
                _totalPrice = _totalPrice + _price;}
            forEach _element;} else {private _price = (_prices param[_prices findIf {(_x select 0) == _element}, 0]) param[2, 0];
            _totalPrice = _totalPrice + _price;};}
    forEach _gear;}
forEach[[_weapons, [_primary, _launcher, _handgun]], [_weaponAddons, [_primaryItems, _secondaryItems, _handgunItems, _equipmentItems, _magazines]], [_uniforms, [_uniform]], [_vests, [_vest]], [_nades, [_magazines]]];
_totalPrice =
if (SRV_communityEvent param [1, false]) then {_totalPrice - (_totalPrice * 0.5)} else {_totalPrice};
private _action = [format["Do you wish to purchase your old loadout which you had before your death for a price of $%1?", [_totalPrice] call life_fnc_numberText], "Rebuy Gear?", "Yes", "No"] call BIS_fnc_guiMessage;
if !(_action) exitWith {};
if (life_atmcash < _totalPrice) exitWith {
    ["You don't have enough money in your bank account for this gear.", "basic"] spawn life_fnc_handleMessage;};
["Now acquiring your loadout. Do not go further than 10 meters or get in a vehicle, else this process will fail.", "basic"] spawn life_fnc_handleMessage;
disableSerialization;
5 cutRsc["life_progress", "PLAIN"];
private _ui = uiNamespace getVariable "life_progress";
private _progress = _ui displayCtrl 38201;
private _pgText = _ui displayCtrl 38202;
private _text = "Regearing, please wait...";
_pgText ctrlSetText format["%2 (1%1)...", "%", _text];
_progress progressSetPosition 0.01;
private _cP = 0.01;
life_action_in_use = true;
private _success = false;
private _startPos = getPos player;
for "_i"
from 0 to 1 step 0 do {uiSleep 0.15;
    _cP = _cP + 0.01;
    _progress progressSetPosition _cP;
    _pgText ctrlSetText format["%3 (%1%2)...", round(_cP * 100), "%", _text];
    if (player distance _startPos > 10) exitWith {};
    if !(life_action_in_use) exitWith {};
    if !(isNull objectParent player) exitWith {};
    if (_cp >= 1) exitWith {_success = true;};}; 5 cutText["", "PLAIN"];
life_action_in_use = false;
if !(_success) exitWith {["The regearing process has failed.", "basic"] spawn life_fnc_handleMessage;};
life_atmcash = (round(life_atmcash - _totalPrice)) max 0;
life_atmcashCacheB = ((life_atmcash / 4) + 11);
[1] call life_fnc_ClupdatePartial;
[life_dead_gear] spawn life_fnc_loadDeadGear;
["You have been outfitted with all of your old gear.", "basic"] spawn life_fnc_handleMessage;
["action", "regear", 1] call life_fnc_handleQuest;
life_uniformBackpack_skins = life_preRespawnUniformBackpackSkins;
[uniform player, "setUniform", ""] call life_fnc_clothingTextures; [
    ["-REGEAR-", player, (profileName), format["cop regeared for $%1 at POS: %2 - %3", _totalPrice, getPosATL player, life_dead_gear]], "TON_fnc_logIt", 2] spawn life_fnc_MP;