/*
    life_fnc_breakGuns  (LooneyBin, owner 2026-06-11)
    Runs on the SUSPECT's machine (remoteExec'd by the arresting APD officer via fn_removeFiringPin).
    Sets the "firing pin removed" flag and keeps the suspect's guns EMPTY so they can't fire, until the suspect
    repairs it (fn_fixFiringPin, unrestrained, 60s). A Fired EH in initPlayerLocal is the instant backstop.
    Owner 2026-06-11: don't DESTROY the loaded magazine -- pop it (with its remaining rounds) into the suspect's
    BACKPACK so the ammo isn't lost; the loop then just keeps the guns dry to prevent firing.
*/
if (player getVariable ["plb_gunBroken", false]) exitWith {};
player setVariable ["plb_gunBroken", true, true];
["<t color='#FF8000' size='1.3'>FIRING PIN REMOVED</t><br/>The APD disabled your weapons -- they won't fire (your loaded mag was put in your backpack). Once you are UNRESTRAINED, use the scroll menu -> <t color='#00FF00'>Fix Firing Pin</t> (takes 60s) to repair them.", "warning"] spawn life_fnc_handleMessage;

// One-time at removal: move each weapon's loaded magazine (preserving its round count) into the backpack.
{_x params ["_wep", "_mag"];
    if (_wep isNotEqualTo "" && {_mag isNotEqualTo ""} && {(player ammo _wep) > 0}) then {private _rounds = player ammo _wep;
        player setAmmo [_wep, 0];
        private _bp = backpackContainer player;
        if (!isNull _bp) then {_bp addMagazineAmmoCargo [_mag, 1, _rounds];} else {player addMagazine [_mag, _rounds];};};} forEach [
    [primaryWeapon player, (primaryWeaponMagazine player) param [0, ""]], [handgunWeapon player, (handgunMagazine player) param [0, ""]],
    [secondaryWeapon player, (secondaryWeaponMagazine player) param [0, ""]]];

// Keep the guns dry while broken (catches reloads); does NOT stash again, so no magazine duplication.
[] spawn {while { (player getVariable ["plb_gunBroken", false]) && {alive player} } do {{
            if !(_x isEqualTo "") then { player setAmmo [_x, 0]; };
        } forEach [primaryWeapon player, handgunWeapon player, secondaryWeapon player];
        uiSleep 0.3;};};
