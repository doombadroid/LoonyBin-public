// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only
/*
    File: fn_cyberdeckLaunch.sqf  (life_fnc_cyberdeckLaunch)
    LooneyBin 2026-07-19: Cyberdeck HOME MENU dispatcher. Runs hack #_id against the target the player had
    locked when they opened the menu (PLB_cdTarget, captured on the Custom-20 keypress -- see fn_keyUpHandler).
    Closes the menu FIRST so the cursorTarget-reading heist fns (openSafe/openVault) re-read the still-aimed
    object (a dialog freezes the camera, so the aim is intact). Every hack does its own client gate + a
    server-authoritative action; this is only the router.
*/
params [["_id", -1]];
private _tgt = missionNamespace getVariable ["PLB_cdTarget", objNull];
closeDialog 0;
switch (_id) do {case 0: { [_tgt] spawn life_fnc_cyberdeck; };             // Vehicle Unlock  (router -> lockpick / Sequence Breach)
    case 1: { [_tgt] spawn life_fnc_cyberdeckIgnition; };     // Hack Ignition
    case 2: { [_tgt] spawn life_fnc_cyberdeck; };             // Breach House    (router -> Terminal Breach)
    case 3: { [] spawn life_fnc_openSafe; };                  // Crack Safe      (reads cursorTarget -- still aimed)
    case 4: { [] spawn life_fnc_cyberdeckBank; };             // Bank Vault      (marker-proximity)
    case 5: { [] spawn life_fnc_openVault; };                 // Fed Reserve     (dome side door; reads cursorTarget)
    case 6: { [_tgt] spawn life_fnc_cyberdeck; };             // Hijack Rig      (router -> takeover)
    case 7: { [_tgt] spawn life_fnc_cyberdeckATM; };          // ATM Jackpot
    case 8: { [] spawn life_fnc_cyberdeckWardrive; };         // Wardrive Scan   (no target)
    default {};};
