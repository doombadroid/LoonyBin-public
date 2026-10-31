#include "..\..\macro.h"
if (scriptAvailable(2.5)) exitWith {["Slow it down buddy!"] spawn life_fnc_handleMessage;};
params[["_veh", objNull, [objNull]]];
_veh = vehicle player;
if (isNull _veh) exitWith {};

if !((driver _veh) isEqualTo player) exitWith {["You must be the driver to toggle SWAT Lights!"] spawn life_fnc_handleMessage};
if (_veh isEqualTo player) exitWith {["You must be in a vehicle to toggle SWAT Lights!"] spawn life_fnc_handleMessage};
if ((typeOf _veh) == "Steerable_Parachute_F") exitWith {};
private _SWATlightState = _veh getVariable["plb_SWATLights", false];
if (_SWATlightState) then {_veh setVariable["plb_SWATLights", false, true];
    if (_veh getVariable "plb_lights") then {_veh setVariable["plb_lights", false, true];
        uiSleep 0.2;
        [_veh] call life_fnc_sirenLights;};} else {_veh setVariable["plb_SWATLights", true, true];
    if (_veh getVariable "plb_lights") then {_veh setVariable["plb_lights", false, true];
        uiSleep 0.2;
        [_veh] call life_fnc_sirenLights;} else {[_veh] call life_fnc_sirenLights;}};