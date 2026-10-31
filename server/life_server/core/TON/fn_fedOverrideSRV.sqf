/*
    TON_fnc_fedOverrideSRV  (owner 2026-06-19 -- "Fed Control" owner-menu tool)
    OWNER-ONLY. Client (admin menu) args: [_action, _pObj].
      "reset" -> clear the Federal Reserve / bank lockout state right now (calls PLB_fnc_resetFed).
      "on"    -> FED OVERRIDE on: disable ALL heist cop-requirements (PLB_betaZeroCops, the central
                 fn_policeRequired waiver) + keep every heist COOLDOWN timestamp cleared via a loop, so
                 the fed/bank/jewelry/loonybin can be run back-to-back. Persisted in server_control.fedoverride.
      "off"   -> restore normal cop-requirements + cooldown tracking.
    The cooldown loop only zeroes the cooldown TIMESTAMP fields (SRV_lastRobbery, life_*_robbed[1],
    SRV_loonyBinData[0]); it never touches the ACTIVE-robbery flags ([0]), so it can't break an in-progress event.
*/
params [["_action", "", [""]], ["_pObj", objNull, [objNull]]];
if (isNull _pObj) exitWith {};
// owner 2026-07-24 SECURITY: the owner check read getPlayerUID off _pObj -- a CLIENT-SUPPLIED object -- so
// any client could pass the OWNER's player object (trivially obtainable from allPlayers) and satisfy it,
// granting itself the cop-requirement waiver and permanently-cleared heist cooldowns. Latent while this fn
// had no CfgRE entry; it is being whitelisted now so the owner's dead "Fed Control" button works, which
// would have made it live. Derive from the non-spoofable remoteExecutedOwner and reply to that caller.
private _src = remoteExecutedOwner;   // 0 == server-internal = trusted
private _caller = if (_src isEqualTo 0) then { _pObj } else { (allPlayers select { owner _x isEqualTo _src }) param [0, objNull] };
if !((getPlayerUID _caller) isEqualTo "76561190000000001") exitWith {
    [["Fed Control is owner-only.", "basic"], "life_fnc_handleMessage", _caller, false] spawn life_fnc_MP;
    if (_src isNotEqualTo 0) then { ["-SEC-", _caller, format ["BLOCKED fedOverrideSRV '%1' (not the owner; claimed %2)", _action, getPlayerUID _pObj]] call PLB_fnc_logIt; };
};
_pObj = _caller;   // downstream logging/messaging uses the verified actor

switch (toLower _action) do {case "reset": {[] call PLB_fnc_resetFed;
        ["-FEDOVERRIDE-", _pObj, "manually RESET the Federal Reserve / bank lockout"] call PLB_fnc_logIt;
        [["Federal Reserve / bank lockout CLEARED + domes re-locked. Retry enabled.", "basic"], "life_fnc_handleMessage", _pObj, false] spawn life_fnc_MP;
    };

    case "on": {PLB_fedOverride  = true;
        PLB_betaZeroCops = true;                       // central cop-requirement waiver (fn_policeRequired)
        publicVariable "PLB_fedOverride"; publicVariable "PLB_betaZeroCops";
        ["UPDATE server_control SET fedoverride=1 WHERE id=1"] call DB_fnc_asyncQuery;
        ["-FEDOVERRIDE-", _pObj, "Fed Override ON -- cop requirements + heist cooldowns DISABLED"] call PLB_fnc_logIt;
        // cooldown-clear loop: zero the cooldown TIMESTAMPS only (not the active flags) while the override is on.
        [] spawn {while { missionNamespace getVariable ["PLB_fedOverride", false] } do {
                if (!isNil "SRV_lastRobbery" && {SRV_lastRobbery != -99999}) then { SRV_lastRobbery = -99999; publicVariable "SRV_lastRobbery"; };
                if (!isNil "life_fed_robbed"  && {(life_fed_robbed  param [1, 0]) != -99999}) then { life_fed_robbed  set [1, -99999]; publicVariable "life_fed_robbed"; };
                if (!isNil "life_bank_robbed" && {(life_bank_robbed param [1, 0]) != -99999}) then { life_bank_robbed set [1, -99999]; publicVariable "life_bank_robbed"; };
                if (!isNil "SRV_loonyBinData" && {(SRV_loonyBinData param [0, 0]) != -99999}) then { SRV_loonyBinData set [0, -99999]; publicVariable "SRV_loonyBinData"; };
                uiSleep 4;};};
        [["Fed Override is now ON. Cop requirements + all heist cooldowns are DISABLED.", "basic"], "life_fnc_handleMessage", _pObj, false] spawn life_fnc_MP;
    };

    case "off": {PLB_fedOverride  = false;
        PLB_betaZeroCops = false;
        publicVariable "PLB_fedOverride"; publicVariable "PLB_betaZeroCops";
        ["UPDATE server_control SET fedoverride=0 WHERE id=1"] call DB_fnc_asyncQuery;
        ["-FEDOVERRIDE-", _pObj, "Fed Override OFF -- normal cop requirements + cooldowns restored"] call PLB_fnc_logIt;
        [["Fed Override is now OFF. Cop requirements + heist cooldowns are back to normal.", "basic"], "life_fnc_handleMessage", _pObj, false] spawn life_fnc_MP;
    };};
