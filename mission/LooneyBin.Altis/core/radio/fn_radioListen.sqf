/*
    fn_radioListen.sqf  (life_fnc_radioListen) -- persistent per-client radio PLAYBACK loop (spawned once at spawn).
    Finds the radio-on vehicle this client should hear (riding in it, else nearest within PLB_radioRange), reads its
    STATION, and plays that station's current track from the SERVER broadcast PLB_radioNow[station]=[songId,startSrvTime]:

      - OCCUPANT  -> playMusic [songId, elapsed] = SEEK-synced to the station's live position (a mid-song joiner
                     hears the same spot as everyone else) + volume follows the in-game MUSIC slider. 2D.
      - BYSTANDER -> say3D on the car = positional + faint, fades out by ~PLB_radioRange metres.

    Since playMusic re-seeks to the CURRENT position, re-issuing it is seamless -> crew changes never restart an
    occupant's track (and existing occupants don't re-trigger at all: their key is unchanged when someone else gets
    in/out). Server drives all transitions so everyone tuned to a station stays synced. Nothing here is broadcast.
    Occupant playMusic needs the song in CfgMusic (core\radio\radioMusic.hpp); bystander say3D uses the CfgSounds copy.
*/
if (!isNil "PLB_radioListening") exitWith {};
PLB_radioListening = true;
PLB_radioRange = 20;                                    // bystander audible radius (m) -- owner 2026-07-07: doubled 10->20

private _cfg  = missionConfigFile >> "PLB_Radio_Cfg" >> "AutoRadio";
private _stns = getArray (_cfg >> "AUTORADIO_Radio");
private _lastKey = "";
private _mode = 0;                                       // 0 none | 1 occupant (playMusic) | 2 bystander (say3D)

private _fnStop = {if (_mode isEqualTo 1) then { playMusic ""; };
    if (_mode isEqualTo 2 && {!isNil "PLB_radioEmitter"} && {!isNull PLB_radioEmitter}) then { PLB_radioEmitter setDamage 1; };
    _mode = 0;
    _lastKey = "";};

while { true } do {uiSleep 0.35;

    if (!alive player) then {if (_lastKey isNotEqualTo "") then { call _fnStop; [-1] call life_fnc_radioHud; };
        continue;};

    // which vehicle's radio should this client hear?
    private _veh = objNull;
    private _occupant = false;
    private _pv = vehicle player;
    if (_pv isNotEqualTo player && {_pv getVariable ["plb_radioOn", false]}) then {_veh = _pv; _occupant = true;} else {
        { if ((_x getVariable ["plb_radioOn", false]) && {alive _x} && {(_x distance player) <= PLB_radioRange}) exitWith { _veh = _x; }; } forEach (nearestObjects [player, ["Car", "Ship", "Tank"], PLB_radioRange]);
    };

    if (isNull _veh || {!(_veh getVariable ["plb_radioOn", false])} || {isNil "PLB_radioNow"}) then {
        if (_lastKey isNotEqualTo "") then { private _wasOcc = _mode isEqualTo 1; call _fnStop; if (_wasOcc) then { [-1] call life_fnc_radioHud; }; };
        continue;};

    private _st   = ((_veh getVariable ["plb_radioStation", 0]) max 0) min ((count _stns) - 1);
    private _slot = if (_st < count PLB_radioNow) then { PLB_radioNow select _st } else { ["", 0] };
    _slot params [["_songId", ""], ["_start", 0]];
    if (_songId isEqualTo "") then { continue; };

    // key includes _occupant (the method); existing occupants keep the same key when others get in/out -> no restart
    private _key = format ["%1|%2|%3|%4", _veh, _st, _start, _occupant];
    if (_key isEqualTo _lastKey) then { continue; };

    call _fnStop;                                       // stop whatever was playing (method-aware)
    _lastKey = _key;

    if (_occupant) then {_mode = 1;
        playMusic [_songId, ((serverTime - _start) max 0)];   // SEEK to the station's current position
        private _songs = getArray (_cfg >> (_stns select _st));
        private _songIdx = _songs findIf { _x isEqualTo _songId };
        if (_songIdx >= 0) then { [_songIdx, _st] call life_fnc_radioHud; };} else {_mode = 2;
        if (isNil "PLB_radioEmitter" || {isNull PLB_radioEmitter}) then { PLB_radioEmitter = "Land_HelipadEmpty_F" createVehicleLocal (getPosATL _veh); };
        PLB_radioEmitter attachTo [_veh, [0, 0, 0]];
        PLB_radioEmitter setDamage 1; uiSleep 0.05; PLB_radioEmitter setDamage 0;
        PLB_radioEmitter say3D [_songId, PLB_radioRange];};};
