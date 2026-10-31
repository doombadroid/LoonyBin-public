params[["_item", "", [""]]];
if (_item isEqualTo "") exitWith {};
if !([false, _item, 1] call life_fnc_handleInv) exitWith {};
private _addInc =
switch _item do {case "beer": {0.10}; default {0.15};}; life_alcohol_level = selectMin[1, life_alcohol_level + _addInc];
plbv_thirst = selectMin[100, plbv_thirst + 10];
[] call life_fnc_hudUpdate;
private _center = selectMax[0.2, 0.5 - (life_alcohol_level / 2)];
"RadialBlur"
ppEffectEnable true;
"RadialBlur"
ppEffectAdjust[0.05, 0.05, _center, _center];
"RadialBlur"
ppEffectCommit 1;
"chromAberration"
ppEffectEnable true;
"chromAberration"
ppEffectAdjust[life_alcohol_level / 20, life_alcohol_level / 20, true];
"chromAberration"
ppEffectCommit 1;
uiSleep 180;
life_alcohol_level = selectMax[0, life_alcohol_level - 0.10];
if (life_alcohol_level > 0) then {
    "RadialBlur"
    ppEffectEnable true;
    "RadialBlur"
    ppEffectAdjust[0.05, 0.05, _center, _center];
    "RadialBlur"
    ppEffectCommit 1;
    "chromAberration"
    ppEffectEnable true;
    "chromAberration"
    ppEffectAdjust[life_alcohol_level / 20, life_alcohol_level / 20, true];
    "chromAberration"
    ppEffectCommit 1;} else {
    "RadialBlur"
    ppEffectEnable false;
    "chromAberration"
    ppEffectEnable false;};
private _updatedSway = selectMax[life_alcohol_level * 35, 0.25];  // LoonyBin: sober floor = 0.25 default (was 0.7); alcohol still adds sway on top
player setCustomAimCoef _updatedSway;