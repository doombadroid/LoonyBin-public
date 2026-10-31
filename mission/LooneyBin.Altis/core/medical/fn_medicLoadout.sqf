private _handle = [] spawn life_fnc_stripDownPlayer;
waitUntil {scriptDone _handle};
player forceAddUniform "U_Marshal";
[] call life_fnc_giveMedkits;
player linkItem "ItemMap";
player linkItem "ItemWatch";
player linkItem "ItemCompass";
player linkItem "ItemGPS";
if (life_inv_debitcard isEqualTo 0) then {[true, "debitcard", 1] call life_fnc_handleInv;};
// owner 2026-07-13: Night Eyes (130) baked to core -- all NG medics spawn with NVGs (GPS already linked above).
player addWeapon "Integrated_NVG_F";
[false] call life_fnc_saveGear;