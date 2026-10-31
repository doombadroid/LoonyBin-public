// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only
/*
    File: fn_talHome.sqf  (life_fnc_talHome)
    LooneyBin 2026-07-20: TAL OS app grid (talos.md) -- the APD phone terminal, police counterpart to
    the ICEBREAKER OS home screen. Every TAL tool lives here as well as on the SHIFT+Y ring, so an
    officer never has to learn the radial to use the kit.

    NO GOGGLES NEEDED HERE (owner 2026-07-20): TAL is standard-issue software, so the terminal works on
    any officer's handset. The VR goggles are purely a SPEED upgrade -- they unlock the SHIFT+Y ring, which
    is the same tools without opening the phone. Don't re-add a goggles gate to this screen.

    Same shape as fn_cyberdeckHome: baked backdrop + invisible hit-tiles; this driver greys the tiles
    the current context can't use and writes the live status strip. Tile order == life_fnc_talAction id.
*/
if !(playerSide isEqualTo west) exitWith {["TAL OS is APD-issue software.", "basic"] spawn life_fnc_handleMessage;};
closeDialog 0;
uiSleep 0.1;
PLB_cdTarget = cursorObject;                       // captured before the dialog frees the camera
if !(createDialog "tal_home") exitWith {};
private _d = findDisplay 941300;
if (isNull _d) exitWith {};

private _tgt   = PLB_cdTarget;
private _rank  = call life_copLevel;
private _sgt   = _rank >= 3;
private _isPly = (!isNull _tgt) && {_tgt isKindOf "CAManBase"} && {isPlayer _tgt} && {_tgt != player};
private _isVeh = (!isNull _tgt) && {(_tgt isKindOf "Car") || (_tgt isKindOf "Air") || (_tgt isKindOf "Ship") || (_tgt isKindOf "Tank")} && {!(_tgt isKindOf "CAManBase")};
private _dist  = if (isNull _tgt) then { 9999 } else { player distance _tgt };
private _cuffed = _isPly && {(_tgt getVariable ["plb_restrained", false]) || (_tgt getVariable ["plb_civRestrained", false])};
private _dirty  = _isPly && {0 in (_tgt getVariable ["plb_cdMods", []])};

// tile order matches life_fnc_talAction: 0 RECORDS 1 PLATE 2 FIELD 3 FIRMWARE 4 RESET 5 SWEEP 6 PIN 7 BACKUP
private _valid = [(_isPly && {_dist <= 25}), _isVeh, (_isPly && {_dist <= 8}), (_sgt && {_isPly} && {_dist <= 12}),
    (_sgt && {_dirty} && {_cuffed} && {_dist <= 10}), (_sgt && {diag_tickTime >= (missionNamespace getVariable ["plb_talSweepCd", 0])}),
    (diag_tickTime >= (missionNamespace getVariable ["plb_talPinCd", 0])),
    (diag_tickTime >= (missionNamespace getVariable ["plb_talBackupCd", 0]))]; {(_d displayCtrl (941310 + _forEachIndex)) ctrlEnable _x;
    (_d displayCtrl (941320 + _forEachIndex)) ctrlSetBackgroundColor (if (_x) then { [0,0,0,0] } else { [0.02,0.035,0.055,0.68] });
} forEach _valid;

// live status strip -- unit identity + what the terminal is currently pointed at
private _tname = if (isNull _tgt) then { "" } else {if (_isPly) then { toUpper (name _tgt) } else {
        private _dn = getText (configFile >> "CfgVehicles" >> (typeOf _tgt) >> "displayName");
        toUpper (if (_dn isEqualTo "") then { typeOf _tgt } else { _dn })};};
private _txt = if (isNull _tgt) then {
    "<t size='1' color='#f0a01e'>@ NO SUBJECT</t>   <t size='0.92' color='#7d8b9e'>aim at a person or vehicle, then reopen TAL</t>"} else {
    format ["<t size='1' color='#4db8ff'>@ SUBJECT</t>   <t size='1' color='#dbe4ee'>%1</t>   <t size='0.92' color='#7d8b9e'>%2 m</t>", _tname, (round (_dist * 10)) / 10]
};
(_d displayCtrl 941303) ctrlSetStructuredText parseText format [
    "%1   <t size='0.92' color='#41505f'>|</t>   <t size='0.92' color='#7d8b9e'>%2</t>", _txt, toUpper ([west, player] call life_fnc_getRankString)];
