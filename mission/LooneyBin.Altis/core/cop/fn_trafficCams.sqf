// owner 2026-07-21: the 14 hardcoded camera positions moved to the shared PLB_cctvCams registry
// (configuration.sqf) so the civilian Eye Spy quickhack hijacks the SAME cameras. Indices 0-13 are
// unchanged, so the cop scroll-menu that passes literal indices still lines up exactly.
params[["_camera", -2, [0]]];
if (_camera isEqualTo - 2) exitWith {};
if (_camera isEqualTo - 1) exitWith {life_trafficCam cameraEffect["terminate", "back"];
    camDestroy life_trafficCam;
    life_trafficCam = nil;
    player switchCamera cameraView;
    ["Security Camera Closed.", "basic"] spawn life_fnc_handleMessage;};
private _cam = PLB_cctvCams param [_camera, []];
if (_cam isEqualTo []) exitWith {};
_cam params ["_pos", "_dir", "_tilt"];
life_trafficCam = "camera"
camCreate _pos;
life_trafficCam camSetFov 0.7;
life_trafficCam setDir _dir;
[life_trafficCam, _tilt, 0] call BIS_fnc_setPitchBank;
life_trafficCam camCommit 0;
life_trafficCam switchCamera "INTERNAL";
["Press 4 to close the camera.", "basic"] spawn life_fnc_handleMessage;