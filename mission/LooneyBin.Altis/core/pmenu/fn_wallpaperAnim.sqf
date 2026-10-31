/*
    File: fn_wallpaperAnim.sqf  (life_fnc_wallpaperAnim)
    LooneyBin 2026-07-20: ANIMATED phone wallpapers. Arma cannot animate a PAA, so an animated wallpaper
    is a folder of baked frames that this loop swaps onto the wallpaper control (idc 90300) while the
    phone is open. A wallpaper is animated when its life_wallpapers entry carries a frame count (index 4)
    and a printf-style frame path (index 5); everything without those stays a plain static texture.

    Only one loop may run: each start stamps PLB_wpAnimTok, and an older loop exits when the token moves.
*/
private _idx = life_wallpapers findIf { (_x select 0) isEqualTo life_wallpaper };
if (_idx < 0) exitWith {};
private _entry  = life_wallpapers select _idx;
private _frames = _entry param [4, 0];
private _fmt    = _entry param [5, ""];
if (_frames < 2 || {_fmt isEqualTo ""}) exitWith {};      // static wallpaper -- nothing to drive

PLB_wpAnimTok = diag_tickTime;
[_frames, _fmt, PLB_wpAnimTok, life_wallpaper] spawn {params ["_frames", "_fmt", "_tok", "_wp"];
    private _i = 0;
    while {!isNull (findDisplay 90000)
        && {PLB_wpAnimTok isEqualTo _tok}                  // a newer loop supersedes this one
        && {life_wallpaper isEqualTo _wp}                  // player switched wallpaper -> stop
    } do {private _n = if (_i < 10) then { format ["0%1", _i] } else { str _i };
        ((findDisplay 90000) displayCtrl 90300) ctrlSetText format [_fmt, _n];
        _i = (_i + 1) % _frames;
        uiSleep 0.15;    // owner 2026-07-20: 50% slower -- one full wrap takes ~2.4s
    };};
