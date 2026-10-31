#include "..\..\macro.h"
/*
    life_fnc_reviveDrone — AEMT+ medic revive drone (LooneyBin feature).
    Drone = AL-6 Pelican (Medical), INDEPENDENT class (I_UAV_06_medical_F) so the medic's terminal controls it,
    repainted with the IDAP orange livery. Bought as a backpack + UAV terminal (medic shops, AEMT+).
    Modes:
      "init"  — per-medic monitor. Sets up the connected drone: paint it + registration (plb_vehOwners) +
                mobile medical shop (plb_medSupply/plb_Owner) + scroll actions. Also registers the R key:
                while piloting, R opens the treatment menu (Revive / Bloodbag / FAK / Adrenaline).
      "treat" _type — apply revive / bloodbag / firstaid / adrenaline (or "auto") to the nearest valid player
                within 3 m of the drone. bloodbag/firstaid/adrenaline fall back to the PILOT (self) for solo testing.
                Revive reward -> the owning medic. Battery = 5 revive charges + 10 shared support (bloodbag/fak/adren).
                Both empty -> OUT OF BATTERY: soft-grounded (can't deploy/treat) + 2 h recharge + on-screen timer. Session-only.
*/
params [["_mode", "treat", [""]], ["_type", "auto", [""]]];
// LooneyBin persistence: server pushed life_droneState = [revives, support, remainingSecs] at load
// (DB-backed, so relog/reboot no longer refills the battery). Unpack once, remaining -> mission time.
if (!isNil "life_droneState") then {life_droneState params [["_dsR", 5, [0]], ["_dsS", 10, [0]], ["_dsRem", 0, [0]]];
    life_droneRevives = _dsR; life_droneSupport = _dsS;
    life_droneRechargeAt = if (_dsRem > 0) then { time + _dsRem } else { 0 };
    life_droneState = nil;};
if (isNil "life_droneRevives")    then { life_droneRevives = 5;  };   // battery: 5 revive charges
if (isNil "life_droneSupport")    then { life_droneSupport = 10; };   // + 10 shared support (bloodbag/fak/adren, any mix)
if (isNil "life_droneRechargeAt") then { life_droneRechargeAt = 0; };
private _DRONES = ["I_UAV_06_medical_F", "C_IDAP_UAV_06_medical_F"];

switch (toLower _mode) do {

    case "init": {if (!isNil "life_droneMonitor") exitWith {};
        life_droneMonitor = true;
        [_DRONES] spawn {params ["_DRONES"];
            private _tex = "\A3\Air_F_Orange\UAV_06\Data\C_IDAP_UAV_06_medical_CO.paa";   // IDAP orange livery (shared model)
            // UAV view doesn't show the drone's scroll actions -> R opens the treatment menu while piloting
            waitUntil { !isNull (findDisplay 46) };
            (findDisplay 46) displayAddEventHandler ["KeyDown", {params ["", "_key"];
                private _ud = getConnectedUAV player;
                // R/F only while actually viewing THROUGH the drone (UAV terminal AV view -> cameraOn is the
                // drone), not merely connected to it in your body, and never when the drone is destroyed.
                private _onDrone = (call life_medicLevel) >= 3 && {!isNull _ud} && {alive _ud} && {(typeOf _ud) in ["I_UAV_06_medical_F","C_IDAP_UAV_06_medical_F"]} && {cameraOn isEqualTo _ud};
                if (_key isEqualTo 19 && {!dialog} && _onDrone) then { createDialog "life_drone_treat_menu"; };   // R = treatment menu
                if (_key isEqualTo 33 && _onDrone) then { ["siren"] spawn life_fnc_reviveDrone; };                 // F = medic lights + siren
                false}];
            while {true} do {uiSleep 2;
                // the drone bag is AEMT+ only -> if a non-AEMT (civ/cop/lower medic) grabs it off the ground it self-destructs
                if ((backpack player) isEqualTo "I_UAV_06_medical_backpack_F" && {(call life_medicLevel) < 3}) then {
                    private _bp = backpackContainer player;
                    removeBackpack player;
                    if (!isNull _bp) then { deleteVehicle _bp; };
                    ["That medical drone kit is NG-restricted — it self-destructed.", "basic"] spawn life_fnc_handleMessage;};
                private _d = getConnectedUAV player;
                if (!isNull _d && {(typeOf _d) in _DRONES} && {(call life_medicLevel) >= 3} && {!(_d getVariable ["plb_droneSetup", false])}) then {
                    if (life_droneRechargeAt > time) then {   // battery flat -> soft block: don't deploy/set up, warn (throttled)
                        if (time > (missionNamespace getVariable ["plb_droneWarnAt", 0])) then {plb_droneWarnAt = time + 20;
                            [format ["Drone battery flat — recharging, %1 min left. Can't deploy yet.", (ceil ((life_droneRechargeAt - time) / 60)) max 0], "basic"] spawn life_fnc_handleMessage;
                        };} else {_d setVariable ["plb_droneSetup", true];
                        _d setObjectTextureGlobal [0, _tex];
                        _d setVariable ["plb_vehOwners", [[getPlayerUID player, profileName]], true];   // Check Registration
                        _d setVariable ["plb_medSupply", true, true];                                  // mobile medical shop
                        _d addEventHandler ["Killed", { (_this select 0) setVariable ["plb_medSupply", false, true]; }];   // a destroyed drone is no longer a med shop
                        _d setVariable ["plb_Owner", player, true];                                     // shop revenue -> owner
                        _d setVariable ["owner", getPlayerUID player, true];                           // mark owned so the server cleanup sweep doesn't delete the drone mid-flight
                        _d addAction ["<t color='#26ff7a'>Treatment Menu (Drone)</t>", { createDialog "life_drone_treat_menu"; }, nil, 7, true, false, "",
                            "(call life_medicLevel) >= 3 && alive _target && {((nearestObjects [_target, ['CAManBase'], 10]) findIf {_x != player && ((_x getVariable ['plb_revivable',false]) || (alive _x && damage _x > 0.15))}) > -1}"];
                    };};};};};

    case "siren": {private _d = getConnectedUAV player;
        if (isNull _d || {!((typeOf _d) in _DRONES)}) exitWith {};
        [_d] call life_fnc_medicSirenLights;   // toggle the per-rotor medic lights on the drone (plb_lights)
        if (_d getVariable ["plb_lights", false]) then {
            // siren ON -> same sound + range as the ambulance van (medicWail, say3D 650 m), emitted from the drone, looped while lights are on
            [_d] spawn {params ["_d"];
                while { !isNull _d && {alive _d} && {_d getVariable ["plb_lights", false]} } do {
                    [[_d, "medicWail", false, 650], "life_fnc_playSound", -2, false, false] spawn life_fnc_MP;
                    uiSleep 5.5688;   // medicWail clip length (matches the van's loop interval)
                };};};};

    case "treat": {private _d = getConnectedUAV player;
        if (isNull _d || {!alive _d} || {!((typeOf _d) in _DRONES)} || {(call life_medicLevel) < 3} || life_action_in_use) exitWith {};
        // recharge elapsed -> refill the battery
        if (life_droneRechargeAt > 0 && time >= life_droneRechargeAt) then {
            life_droneRevives = 5; life_droneSupport = 10; life_droneRechargeAt = 0;
            [[getPlayerUID player, 5, 10, 0], "TON_fnc_droneCharges", 2] spawn life_fnc_MP;   // persist the recharge
            ["Drone battery recharged — 5 revives / 10 support ready.", "info"] spawn life_fnc_handleMessage;};
        if (life_droneRechargeAt > time) exitWith {
            [format ["Drone battery flat — recharging, %1 min left.", (ceil ((life_droneRechargeAt - time) / 60)) max 0], "basic"] spawn life_fnc_handleMessage;
        };

        private _t = toLower _type;
        private _isRevive = _t in ["revive", "auto"];
        if (_isRevive && life_droneRevives <= 0) exitWith { ["Drone out of revive charges (support charges remain).", "basic"] spawn life_fnc_handleMessage; };
        if (!_isRevive && life_droneSupport <= 0) exitWith { ["Drone out of support charges (revive charges remain).", "basic"] spawn life_fnc_handleMessage; };

        private _R = 10;   // OTHERS must be within 10 m of the drone (it hovers above the body)
        private _cand = switch (_t) do {
            // revive targets the dead BODY: plb_revivable is set on life_corpse, which is NOT in allPlayers
            // once the engine BASE-respawns the player to a new unit -> search bodies (incl. dead) near the drone.
            case "revive";
            case "auto":   { (nearestObjects [_d, ["CAManBase"], _R]) select { _x != player && (_x getVariable ["plb_revivable", false]) } };
            case "adrenaline": { allPlayers select { _x != player && alive _x && !(_x getVariable ["plb_revivable", false]) && (_x distance _d) < _R } };
            default { allPlayers select { _x != player && alive _x && !(_x getVariable ["plb_revivable", false]) && damage _x > (if (_t isEqualTo "firstaid") then {0.15} else {0.3}) && (_x distance _d) < _R } };
        };
        if (_t isEqualTo "auto" && {(count _cand) == 0}) then {_t = "bloodbag";
            _cand = allPlayers select { _x != player && alive _x && !(_x getVariable ["plb_revivable", false]) && damage _x > 0.3 && (_x distance _d) < _R };
        };
        _isRevive = _t in ["revive", "auto"];
        _cand = _cand apply { [_x distance _d, _x] }; _cand sort true;
        private _target = if (count _cand > 0) then { (_cand select 0) select 1 } else { objNull };
        // solo testing: if nobody else qualifies, support actions (bloodbag/fak/adren) treat the PILOT regardless of drone range/health
        private _self = false;
        if (isNull _target && !_isRevive && alive player && !(player getVariable ["plb_revivable", false])) then { _target = player; _self = true; };
        if (isNull _target) exitWith { [format ["No valid patient within %1 m of the drone.", _R], "basic"] spawn life_fnc_handleMessage; };

        life_action_in_use = true;
        private _what = switch (_t) do { case "revive": {"Reviving"}; case "auto": {"Reviving"}; case "firstaid": {"Patching up"}; case "adrenaline": {"Injecting"}; default {"Transfusing"} };
        private _name = if (_self) then { "yourself" } else { _target getVariable ["plb_name", name _target] };
        disableSerialization;
        5 cutRsc ["life_progress", "PLAIN"];
        private _ui  = uiNamespace getVariable "life_progress";
        private _bar = _ui displayCtrl 38201;
        private _txt = _ui displayCtrl 38202;
        private _cP  = 0.01; private _ok = false;
        for "_i" from 0 to 1 step 0 do {uiSleep 0.18;
            _cP = _cP + 0.01;
            _bar progressSetPosition _cP;
            _txt ctrlSetText format ["%1 %2 via drone (%3%4)", _what, _name, round (_cP * 100), "%"];
            if (isNull _d || isNull _target || !alive player) exitWith {};
            if (!_self && (_target distance _d) > (_R + 2)) exitWith { ["Drone drifted off the patient.", "basic"] spawn life_fnc_handleMessage; };
            if (_isRevive && !(_target getVariable ["plb_revivable", false])) exitWith {};
            if (_cP >= 1) exitWith { _ok = true; };};
        5 cutText ["", "PLAIN"];
        life_action_in_use = false;
        if (!_ok) exitWith {};

        switch (_t) do {case "revive";
            case "auto": {[[player, false, false, false, time + 240], "life_fnc_revived", _target] spawn life_fnc_MP;
                private _fee = (call life_revive_fee) + 1000;                  // reward -> the owning medic (the pilot)
                life_atmcash = life_atmcash + _fee; life_atmcashCacheB = ((life_atmcash / 4) + 11);
                life_side_exp = life_side_exp + 50;
                [1] call life_fnc_ClupdatePartial;
                titleText [format ["Drone revived %1 — earned $%2.", _name, [_fee] call life_fnc_numberText], "PLAIN"];};
            case "adrenaline": {if (_target isEqualTo player) then { [] call life_fnc_adrenalineShotEffect; }
                else { [[player], "life_fnc_adrenalineShotEffect", _target, false, false] spawn life_fnc_MP; };
                life_side_exp = life_side_exp + 15; [1] call life_fnc_ClupdatePartial;
                titleText [format ["Drone gave %1 an adrenaline shot.", _name], "PLAIN"];};
            case "firstaid": {_target setDamage ((damage _target - 0.5) max 0);
                if (_target isEqualTo player) then { [] call life_fnc_hudUpdate; }
                else { [[0, format ["%1's drone patched you up (first aid).", profileName]], "life_fnc_broadcast", _target] spawn life_fnc_MP; };
                titleText [format ["Drone patched up %1.", _name], "PLAIN"];};
            default {_target setDamage 0;
                if (_target isEqualTo player) then { [] call life_fnc_hudUpdate; }
                else { [[0, format ["%1's revive drone gave you a blood transfusion.", profileName]], "life_fnc_broadcast", _target] spawn life_fnc_MP; };
                titleText [format ["Drone transfused %1.", _name], "PLAIN"];};};

        if (_isRevive) then { life_droneRevives = (life_droneRevives - 1) max 0; } else { life_droneSupport = (life_droneSupport - 1) max 0; };
        [[getPlayerUID player, life_droneRevives, life_droneSupport, ((life_droneRechargeAt - time) max 0)], "TON_fnc_droneCharges", 2] spawn life_fnc_MP;   // persist every use
        if (life_droneRevives <= 0 && life_droneSupport <= 0) then {
            life_droneRechargeAt = time + 7200;   // out of battery -> 2 h recharge (counts down while packed in the backpack)
            [[getPlayerUID player, 0, 0, 7200], "TON_fnc_droneCharges", 2] spawn life_fnc_MP;   // persist the flat battery
            ["Drone is OUT OF BATTERY — it can't fly until recharged. 2-hour recharge started; pack it up.", "info"] spawn life_fnc_handleMessage;
            // drive the on-screen recharge countdown (shown next to food %)
            [] spawn { while { life_droneRechargeAt > time } do { [] call life_fnc_hudUpdate; uiSleep 15; }; uiSleep 0.1; [] call life_fnc_hudUpdate; };
        } else {
            [format ["Drone charges — revives %1/5, support %2/10.", life_droneRevives, life_droneSupport], "basic"] spawn life_fnc_handleMessage;
        };};};
