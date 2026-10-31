// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only
/*
    File: fn_cyberdeck.sqf
    LooneyBin 2026-07-18: Cyberdeck launcher. Routes a hack by whatever the player is aiming at.
    Replaces the lockpick + drill.
      * Vehicle    -> Sequence Breach (via the lockpick path).
      * House      -> Terminal Breach -> unlock all doors 3 min. ALWAYS: $10k Breaking & Entering
                      charge + owner toast + APD alert (win or fail).
      * Crypto rig -> Terminal Breach -> full takeover. ALWAYS: $10k Cyber Crime charge (win or fail).
    Heavy targets (fed dome, bank vault) land in Phase 4.
*/
params [["_target", objNull, [objNull]]];
if (isNull _target) then { _target = cursorObject; };

if !((call PLB_fnc_hasDeck)) exitWith {["You don't have a Cyberdeck.", "basic"] spawn life_fnc_handleMessage;};
if (playerSide isEqualTo west) exitWith {
    ["The Cyberdeck's ICE locks out law enforcement credentials.", "basic"] spawn life_fnc_handleMessage;};

// ---- CRYPTO MINING RIG -> Terminal Breach -> full takeover ----
if (_target getVariable ["plb_cryptoRig", false]) exitWith {private _uid = getPlayerUID player;
    if ((_target getVariable ["plb_rigOwner", ""]) isEqualTo _uid) exitWith {
        ["This is your own rig.", "basic"] spawn life_fnc_handleMessage;};
    if (player distance _target > 8) exitWith {["Get closer to the rig to jack in.", "basic"] spawn life_fnc_handleMessage;};
    private _r = [1] call life_fnc_cyberdeckTerm;
    if (_r in [0, 1]) then {[[112, player], "TON_fnc_wantedAdd", false, false] spawn life_fnc_MP;   // Cyber Crime -- regardless
    };
    if (_r isEqualTo 1) then {[["cryptoTakeover", _target, player], "TON_fnc_cyberdeckSRV", 2] spawn life_fnc_MP;
        titleText ["Rig hijacked -- the coin stream is yours now.", "PLAIN"];
        [5] call life_fnc_addInfamy;};};

// ---- HOUSE DOOR -> Terminal Breach ----
if (_target isKindOf "House_F" && {(typeOf _target) in life_houseTypes}) exitWith {private _uid = getPlayerUID player;
    if (((_target getVariable ["plb_homeOwner", ""]) isEqualTo _uid) ||
        {_target in life_vehicles} ||
        {[_target, _uid, "accessLock"] call life_fnc_keyHolderStatus}) exitWith {
        ["You already have access to this property.", "basic"] spawn life_fnc_handleMessage;};
    if (player distance _target > 14) exitWith {["Get closer to the door to jack in.", "basic"] spawn life_fnc_handleMessage;};
    private _r = [1] call life_fnc_cyberdeckTerm;   // 3-command Terminal Breach
    if (_r in [0, 1]) then {
        // Breaking & Entering charge + owner/APD notify -- fires whether you got in or not
        [[111, player], "TON_fnc_wantedAdd", false, false] spawn life_fnc_MP;
        [["houseBreach", _target, player, (_r isEqualTo 1)], "TON_fnc_cyberdeckSRV", 2] spawn life_fnc_MP;};
    if (_r isEqualTo 1) then {
        // root access -> throw every door open (client-side global, like fn_boltcutter)
        private _nd = getNumber (configFile >> "CfgVehicles" >> typeOf _target >> "numberOfDoors");
        private _shop = (typeOf _target) in ["Land_i_Shop_01_V1_F", "Land_i_Shop_01_V2_F", "Land_i_Shop_01_V3_F"];
        for "_i" from 1 to _nd do {if !(_shop && {_i in [1, 3]}) then {_target setVariable [format ["bis_disabled_Door_%1", _i], 0, true];
                _target animate [format ["door_%1_rot", _i], 1];};};
        _target setVariable ["plb_locked", false, true];
        titleText ["Locks bypassed. Doors open for 3 minutes.", "PLAIN"];
        [5] call life_fnc_addInfamy;};};

// ---- VEHICLE / restrained -> Sequence Breach (lockpick path) ----
if (_target isKindOf "LandVehicle" ||
    _target isKindOf "Air" ||
    _target isKindOf "Ship" ||
    {_target getVariable ["plb_restrained", false]}) exitWith {[_target, false, true] spawn life_fnc_lockpick;};

["No hackable target under your cursor. Aim at a vehicle, a house door, or a mining rig.", "basic"] spawn life_fnc_handleMessage;
