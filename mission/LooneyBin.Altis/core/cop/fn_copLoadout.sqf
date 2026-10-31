private _handle = [] spawn life_fnc_stripDownPlayer;
waitUntil {scriptDone _handle};
// owner 2026-06-18: undercover/detective gear leaked to CADETS on respawn. coprole "all" is set for
// adminLevel>=3 OR copLevel>=6 (fn_initCop:48), so an ADMIN playing a low-rank cop (e.g. cadet) got "all"
// -> detectiveGear here = "cadets on death get undercover loadout". Gate the "all" clause on ACTUALLY being a
// high-rank cop (copLevel>=6 = a real Captain), so admins below that rank get their RANK loadout. Real captains
// still spawn undercover (owner's call); detective SLOTS unchanged.
if (((life_coprole isEqualTo "all") && ((call life_copLevel) >= 6)) || (str player in ["cop_detective_1", "cop_detective_2", "cop_detective_3", "cop_detective_4"])) exitWith {
    [] call life_fnc_detectiveGear;};
// LoonyBin (owner 2026-06-13): APD spawns in their RANK's default uniform (polo retexture; was U_Rangemaster)
player forceAddUniform "U_Rangemaster";
private _plbRankTex = switch ((call life_copLevel) min 7) do {case 1: { "images\skins\apd\cadet.jpg" };
    case 2: { "images\skins\apd\po.jpg" };
    case 3: { "images\skins\apd\cpl.jpg" };
    case 4: { "images\skins\apd\sgt.jpg" };
    case 5: { "images\skins\apd\lt.jpg" };
    case 6: { "images\skins\apd\capt.jpg" };
    case 7: { "images\skins\apd\chief.jpg" };   // owner 2026-06-26: Chief gets its own skin (was reusing Captain via min 6)
    default { "images\skins\apd\cadet.jpg" };};
player setObjectTextureGlobal [0, _plbRankTex];
if (life_inv_debitcard isEqualTo 0) then {[true, "debitcard", 1] call life_fnc_handleInv;};
if (83 in life_side_talents) then {player addVest "V_tacVest_blk_police"} else {player addVest "V_Rangemaster_belt"};
if (129 in life_side_talents) then {player addWeapon "Integrated_NVG_F";
    player linkItem "ItemGPS"};
player addHeadgear "H_Cap_police";
player linkItem "ItemMap";
player linkItem "ItemCompass";
player addWeapon "Binocular";
player linkItem "ItemGPS";
[] call life_fnc_giveMedkits;
player addMagazines["30Rnd_9x21_Mag", 3];
player addMagazines["SmokeShell", 2];
player addWeapon "hgun_P07_F";
player addHandgunItem "muzzle_snds_L";
switch (true) do {case (43 in life_cop_talents && (call life_copLevel) >= 5): {
            [player, "arifle_MXM_Black_F", 6, "30Rnd_65x39_caseless_black_mag"] call BIS_fnc_addWeapon;
            player addMagazines["30Rnd_65x39_caseless_black_mag", 2];};
    case (41 in life_cop_talents && (call life_copLevel) >= 4): {
            [player, "arifle_MX_Black_F", 6, "30Rnd_65x39_caseless_black_mag"] call BIS_fnc_addWeapon;
            player addMagazines["30Rnd_65x39_caseless_black_mag", 2];};
    case (81 in life_side_talents && (call life_copLevel) >= 2): {
            [player, "arifle_SPAR_01_blk_F", 6, "30Rnd_556x45_Stanag"] call BIS_fnc_addWeapon;
            player addMagazines["30Rnd_556x45_Stanag", 2];};
    default {[player, "SMG_05_F", 7, "30Rnd_9x21_Mag_SMG_02_Tracer_Yellow"] call BIS_fnc_addWeapon;};
}; player addPrimaryWeaponItem "optic_ACO_grn_smg";
private _uniformTextureIndex =
if (call life_copLevel isEqualTo 1) then {63} else {call life_copLevel};
[uniform player, "setIdx", _uniformTextureIndex] call life_fnc_clothingTextures;
// owner 2026-06-16 (#257/#263): this hard-set the BACKPACK skin index to -1 on every cop gear-up. The login
// path (fn_requestReceived) had just restored the player's saved backpack skin (plb_clothingSkinsCop), so the
// re-gear wiped it -> "invisible backpack reverts after restart" (#263); and a revive re-gears, so it also
// reverted "after being revived" (#257). PRESERVE the saved backpack skin index and re-apply it (the skin
// only paints if its class matches the equipped pack, so a mismatch is a harmless no-op).
private _savedBackpackSkin = (profileNamespace getVariable ["plb_clothingSkinsCop", [-1, -1]]) param [1, -1];
life_uniformBackpack_skins = [_uniformTextureIndex, _savedBackpackSkin];
if (_savedBackpackSkin != -1 && {!(backpack player isEqualTo "")}) then {
    [backpack player, "setBackpack", ""] call life_fnc_clothingTextures;};
[false] call life_fnc_saveGear;