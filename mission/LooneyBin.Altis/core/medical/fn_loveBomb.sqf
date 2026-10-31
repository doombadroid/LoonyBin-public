#include "..\..\macro.h"
/*
    life_fnc_loveBomb -- LooneyBin (owner 2026-06-11): "Ultimate Healing Sunshine Love Bomb".
    Y-inventory item (NG shop, $10,000,000). Use it -> 10s arming progress bar -> server detonates a huge
    (cosmetic) explosion + heals/revives EVERY player within 1km to full. Consumed on arm.
*/
if (player getVariable ["plb_loveBombArming", false]) exitWith {
    ["You are already arming a Love Bomb.", "basic"] spawn life_fnc_handleMessage;};
if !([false, "ultimateHealBomb", 1] call life_fnc_handleInv) exitWith {
    ["You don't have an Ultimate Healing Sunshine Love Bomb.", "basic"] spawn life_fnc_handleMessage;};
player setVariable ["plb_loveBombArming", true];
closeDialog 0;
["<t color='#ff66cc' size='1.4'>ULTIMATE HEALING SUNSHINE LOVE BOMB</t><br/>Arming... hold tight. In 10 seconds everyone within 1km is healed to full.", "basic"] spawn life_fnc_handleMessage;

disableSerialization;
5 cutRsc ["life_progress", "PLAIN"];
private _ui = uiNamespace getVariable "life_progress";
private _bar = _ui displayCtrl 38201;
private _txt = _ui displayCtrl 38202;
private _dur = 10;
private _t = 0;
private _ok = true;
while { _t < _dur } do {uiSleep 0.1;
    _t = _t + 0.1;
    _bar progressSetPosition (_t / _dur);
    _txt ctrlSetText format ["Arming Love Bomb... (%1%2)", round ((_t / _dur) * 100), "%"];
    if (!alive player || {player getVariable ["plb_restrained", false]}) exitWith { _ok = false; };};
5 cutText ["", "PLAIN"];
player setVariable ["plb_loveBombArming", nil];
if (!_ok) exitWith {
    ["The Love Bomb fizzled out (you were downed or restrained). It has been consumed.", "basic"] spawn life_fnc_handleMessage;};
[[getPosATL player], "TON_fnc_loveBombSRV", 2] spawn life_fnc_MP;
