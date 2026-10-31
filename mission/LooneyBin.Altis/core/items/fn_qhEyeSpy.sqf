// Altis Life game mechanic — fictional in-game "quickhack" ability, client-local camera only.
/*
    File: fn_qhEyeSpy.sqf  (life_fnc_qhEyeSpy)
    LooneyBin 2026-07-21: EYE SPY viewer. The server (TON_fnc_qhSRV "eyespy") picked the nearest CCTV in the
    PLB_cctvCams registry, validated range + cooldown and rolled Loop Detection, then handed this client the
    camera index to open. Pure client-local camera (same camCreate/cameraEffect pattern the APD cop-cam uses)
    -- nothing here is authoritative; it just renders a feed for _dur seconds and always closes itself.

      [_camSpec, _dur]   _camSpec = [pos, dir, tiltDeg, name] -- a fixed registry cam OR a placed street cam
*/
params [["_camSpec", [], [[]]], ["_dur", 30, [0]]];
if (_camSpec isEqualTo []) exitWith {};
_camSpec params ["_pos", "_dir", "_tilt", ["_name", "CAMERA"]];
if (!isNil "life_qhSpyCam") exitWith {};                       // one feed at a time

disableSerialization;
life_qhSpyCam = "camera" camCreate _pos;
life_qhSpyCam camSetFov 0.7;
life_qhSpyCam setDir _dir;
[life_qhSpyCam, _tilt, 0] call BIS_fnc_setPitchBank;
life_qhSpyCam camCommit 0;
life_qhSpyCam switchCamera "INTERNAL";

// any key drops the feed early -- the hijack is fragile, you are standing blind in the world while you watch.
private _disp = findDisplay 46;
private _ehKey = _disp displayAddEventHandler ["KeyDown", { missionNamespace setVariable ["life_qhSpyBail", true]; false }];
life_qhSpyBail = false;

[_camIndex, _dur, _ehKey, _name] spawn {params ["_camIndex", "_dur", "_ehKey", "_name"];
    private _end = diag_tickTime + _dur;
    while { diag_tickTime < _end && {!isNull life_qhSpyCam} && {!life_qhSpyBail} && {alive player} } do {
        private _rem = ceil (_end - diag_tickTime);
        titleText [format ["ICEBREAKER TAP -- %1\nfeed drops in %2s   [any key: disconnect]", toUpper _name, _rem], "PLAIN DOWN"];
        uiSleep 0.5;};
    // teardown -- restore the player's own view no matter which exit fired
    (findDisplay 46) displayRemoveEventHandler ["KeyDown", _ehKey];
    if (!isNil "life_qhSpyCam") then {life_qhSpyCam cameraEffect ["terminate", "back"];
        camDestroy life_qhSpyCam;
        life_qhSpyCam = nil;};
    player switchCamera cameraView;
    titleText ["", "PLAIN"];
    life_qhSpyBail = nil;
    ["<t color='#7f918a'>FEED DISCONNECTED</t>", "basic"] spawn life_fnc_handleMessage;};
