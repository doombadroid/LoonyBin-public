// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only
/*
    File: fn_cyberdeckPick.sqf
    LooneyBin 2026-07-18: Sequence Breach click handler. Called from each grid button's ButtonClick EH
    with that cell's flat index (0..24). Validates against the active row + the next buffer code.
*/
params [["_i", -1]];
if (isNil "plb_cbResult") exitWith {};
if !(plb_cbResult isEqualTo -1) exitWith {};
if (_i < 0) exitWith {};

private _activeRow = plb_cbIdx % plb_cbRows;
private _r = floor (_i / plb_cbCols);

// clicking outside the highlighted row -- small trace penalty, no advance
if !(_r isEqualTo _activeRow) exitWith {plb_cbDeadline = plb_cbDeadline - 1.5;
    playSound "FD_CP_Not_Clear_F";};

private _code = plb_cbGrid select _i;
private _need = plb_cbBuffer select plb_cbIdx;
if (_code isEqualTo _need) then {plb_cbIdx = plb_cbIdx + 1;      // correct code -> advance the buffer + active row
    playSound "FD_Finish_F";} else {plb_cbDeadline = plb_cbDeadline - 2.5;   // wrong code -> bigger trace penalty
    playSound "FD_CP_Not_Clear_F";};
call life_cbRender;
