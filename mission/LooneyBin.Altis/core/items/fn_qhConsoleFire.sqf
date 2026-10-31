// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only.
/*
    File: fn_qhConsoleFire.sqf  (life_fnc_qhConsoleFire)
    LooneyBin 2026-07-22: tap a loadout tile -> cast that slot's hack at the locked target. This is the
    "fire without goggles" path: it does NOT touch the goggle gate (that only ever guarded the SHIFT+Y ring).
    It just resolves the slot id and hands off to life_fnc_qhCast, which reads PLB_cdTarget, validates range /
    LOS / kind / authorisation client-side, then TON_fnc_qhSRV runs the authoritative upload clock. A modified
    client still can't skip the channel -- this is only a new BUTTON onto the same audited pipeline.
*/
if (!hasInterface) exitWith {};
params [["_slot", 0, [0]]];
private _id = PLB_qhConsoleLoad param [_slot, ""];
if (_id isEqualTo "") exitWith {
    ["<t color='#ff5a3c'>EMPTY SLOT</t> -- load a hack from the library first.", "basic"] spawn life_fnc_handleMessage;};
// UTILITY breaches route to the deck's own breach fns (not the qhSRV upload path). They target the object you
// were aiming at when the app opened (PLB_cdBreachTarget); fn_cyberdeck routes car vs house by its type.
if (_id in ["unlock", "house", "atm", "cuffs"]) exitWith {closeDialog 0;
    [_id] spawn {params ["_id"];
        uiSleep 0.15;
        private _bt = missionNamespace getVariable ["PLB_cdBreachTarget", objNull];
        switch (_id) do {case "atm":   { [_bt] spawn life_fnc_cyberdeckATM; };
            case "cuffs": { [] spawn life_fnc_qhCuffHack; };
            default       { [_bt] spawn life_fnc_cyberdeck; };};};};
[_id] call life_fnc_qhCast;
// reflect the new cooldown on the tile
[] spawn { uiSleep 0.2; call PLB_fnc_qhConsoleTiles; };
