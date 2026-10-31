// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only
/*
    File: fn_cyberdeckTerm.sqf
    LooneyBin 2026-07-18: TERMINAL BREACH minigame (Cyberdeck, heavy targets).
    Type each Linux command exactly + fast before the trace lands. Cyan deck (dialog cyberdeck_term).
    BLOCKING -- returns: 1 = root/breach, 0 = trace fail, -1 = aborted.
    _difficulty: 1 = house door (3 cmds), 2 = bank vault (6), 3 = fed (9).
*/
params [["_difficulty", 1]];
disableSerialization;
// owner 2026-07-20: Breach Kit consumable -- if armed, auto-solve this breach (skip the minigame) and spend the charge.
if (plb_breachKitArmed) exitWith {plb_breachKitArmed = false;
    ["<t color='#c9e21a'>BREACH KIT</t> -- terminal auto-solved.", "basic"] spawn life_fnc_handleMessage;
    1};

private _N   = switch (_difficulty) do { case 3: { 9 }; case 2: { 6 }; default { 3 } };
private _per = switch (_difficulty) do { case 3: { 9 }; case 2: { 11 }; default { 13 } };  // seconds budget per command
private _timeLimit = round (_N * _per * (2/3));   // base budget cut by 1/3 (owner 2026-07-21)
if (1 in (player getVariable ["plb_cdMods", []])) then { _timeLimit = _timeLimit + 4; };   // Overclock Module: +time

private _pool = ["nmap -sS 10.0.0.1","nc -zv 192.168.0.1","sudo mount /dev/sda1","ssh root@10.0.0.5",
    "hydra -l admin -P rock","chmod 777 /etc/keys","cat /etc/shadow","iptables -F",
    "kill -9 1337","rm -rf /var/lock","curl -X POST /unlock","grep -r KEY /sys",
    "./exploit --run","openssl enc -d lock","tar xzf payload.gz"];
private _p2 = +_pool;
private _cmds = [];
for "_i" from 1 to _N do {if (count _p2 isEqualTo 0) exitWith {};
    private _pick = selectRandom _p2;
    _p2 = _p2 - [_pick];
    _cmds pushBack _pick;};

plb_ctCmds = _cmds;
plb_ctIdx = 0;
plb_ctResult = -1;
plb_ctDeadline = diag_tickTime + _timeLimit;
plb_ctFeed = ["<t color='#5fd3ff'>uplink established -- icebreaker v3.1</t>",
              "<t color='#2f6b58'>enter each command EXACTLY, then [ENTER]</t>"];

life_ctRender = {private _dlg = findDisplay 941000;
    if (isNull _dlg) exitWith {};
    private _lines = plb_ctFeed;
    if ((count _lines) > 8) then { _lines = _lines select [((count _lines) - 8), 8]; };
    (_dlg displayCtrl 941010) ctrlSetStructuredText parseText format ["<t size='1' align='left'>%1</t>", (_lines joinString "<br/>")];
    if (plb_ctIdx < (count plb_ctCmds)) then {
        (_dlg displayCtrl 941020) ctrlSetStructuredText parseText format ["<t size='1.05' align='left' color='#33ffbb'>%1</t>", (plb_ctCmds select plb_ctIdx)];
    } else {
        (_dlg displayCtrl 941020) ctrlSetStructuredText parseText "<t size='1.05' align='left' color='#33ffbb'>// ROOT ACCESS GRANTED</t>";
    };};

closeDialog 0;
uiSleep 0.05;
if !(createDialog "cyberdeck_term") exitWith { -1 };
private _dlg = findDisplay 941000;
if (isNull _dlg) exitWith { -1 };
private _edit = _dlg displayCtrl 941030;
_edit ctrlAddEventHandler ["KeyDown", "if ((_this select 1) isEqualTo 28) then { [] call life_fnc_cyberdeckSubmit; true } else { false }"];
call life_ctRender;
ctrlSetFocus _edit;
// Autocomplete talent (252): pre-type the whole FIRST WORD of the command with the caret trailing at its end
// (owner 2026-07-19: was 1 char + caret parked at the start). Delayed a beat so it lands AFTER the dialog's own
// open-focus, and ctrlSetText-then-ctrlSetFocus keeps the caret at the end of the pre-typed word.
if (false) then {   // owner 2026-07-20: Autocomplete talent (252) removed with the Hacker tree; no module replacement yet
    [_edit, ((plb_ctCmds select 0) splitString " " select 0)] spawn {params ["_e", "_fw"];
        uiSleep 0.1;
        if (isNull _e) exitWith {};
        _e ctrlSetText _fw;
        ctrlSetFocus _e;};};

private _trace = _dlg displayCtrl 941040;
private _tp = ctrlPosition _trace;
private _time = _dlg displayCtrl 941041;

while { plb_ctResult isEqualTo -1 } do {if (isNull (findDisplay 941000)) exitWith { plb_ctResult = 2; };
    private _rem = plb_ctDeadline - diag_tickTime;
    if (_rem <= 0) exitWith { plb_ctResult = 0; };
    private _low = (_rem < 6);
    private _frac = (_rem / _timeLimit) max 0 min 1;
    _trace ctrlSetPosition [(_tp select 0), (_tp select 1), ((_tp select 2) * _frac), (_tp select 3)];
    _trace ctrlCommit 0;
    _trace ctrlSetBackgroundColor (if (_low) then { [1, 0.25, 0.1, 0.95] } else { [0.20, 1, 0.73, 0.95] });
    _time ctrlSetStructuredText parseText format ["<t size='0.75' align='right' color='%1'>%2s</t>",
        (if (_low) then { "#ff5a3c" } else { "#33ffbb" }), (_rem toFixed 1)];
    if (plb_ctIdx >= (count plb_ctCmds)) exitWith { plb_ctResult = 1; };
    uiSleep 0.05;};

private _won = (plb_ctResult isEqualTo 1);
if !(isNull (findDisplay 941000)) then {
    (_dlg displayCtrl 941020) ctrlSetStructuredText parseText format ["<t size='1.15' align='left' color='%1'>%2</t>",
        (["#ff5a3c","#33ffbb"] select _won), (["// TRACE LOCKED -- CONNECTION DROPPED","// ROOT ACCESS GRANTED"] select _won)];
    uiSleep 1.1;
    closeDialog 0;};

switch (plb_ctResult) do {case 1: { 1 };
    case 0: { 0 };
    default { -1 };};
