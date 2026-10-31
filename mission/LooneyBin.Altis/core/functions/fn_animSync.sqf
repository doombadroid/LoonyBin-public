/*
    life_fnc_animSync  (LooneyBin NEW 2026-06-09 -- was referenced by fn_boltcutter but never existed,
    so every boltcutter use threw a script error each anim re-assert.)
    [unit, animation] broadcast to all: plays the unit's action animation on remote machines so
    bystanders see the cutting/working pose (local machine already switchMoved).
*/
params [["_unit", objNull, [objNull]], ["_anim", "", [""]]];
if (isNull _unit || {_anim isEqualTo ""}) exitWith {};
if (local _unit) exitWith {};   // owner already plays it
_unit switchMove _anim;
