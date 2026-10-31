/*
    TON_fnc_radioSRV  (server) -- car-radio STATION MASTER. Every station broadcasts continuously from the server
    (like real radio), independent of any driver, so a car keeps playing after the driver leaves and everyone tuned
    to a station hears the same track. Broadcasts PLB_radioNow = per-station [songId, startServerTime]; the client
    listener (life_fnc_radioListen) plays PLB_radioNow[ car's station ].

    BUILD A (live/website control): the per-station playlist comes from the DB table `radio_schedule` (station, idx,
    song_id, song_len), which a poller keeps in sync with https://projectloonybin.com/radio.json every ~60s. The
    owner edits that JSON -> the rotation changes live, no restart. Any station with no schedule row FALLS BACK to
    the packed config (core\radio\radioCfg.hpp). song_id must be a PACKED CfgSounds class either way (Arma can't
    stream web audio). Reloaded every 60s so website edits propagate.
*/
if (!isServer) exitWith {};

private _cfg   = missionConfigFile >> "PLB_Radio_Cfg" >> "AutoRadio";
private _stns  = getArray (_cfg >> "AUTORADIO_Radio");
private _lenKs = getArray (_cfg >> "AUTORADIO_RadioLengh");
private _n     = count _stns;
if (_n isEqualTo 0) exitWith {};

PLB_radioSt  = [];
PLB_radioNow = [];
{ PLB_radioSt pushBack [-1, 0]; PLB_radioNow pushBack ["", 0]; } forEach _stns;
PLB_radioCount = []; { PLB_radioCount pushBack 0; } forEach _stns;   // per-station advance counter -> ad every 3rd track

// per-station playlist [[songId, len], ...]: website schedule (radio_schedule) first, packed config as fallback
PLB_radioPlaylists = [];
private _fnLoad = {private _pl = []; { _pl pushBack []; } forEach _stns;
    private _rows = ["SELECT station, QUOTE(song_id), song_len FROM radio_schedule ORDER BY station, idx", 2, true] call DB_fnc_asyncQuery;   // QUOTE: song_id is a plain varchar -> read as a proper SQF string, not a bareword
    if (!isNil "_rows" && {_rows isEqualType []}) then {{_x params [["_st", -1, [0]], ["_sid", "", [""]], ["_len", 0, [0]]];
            if (_st >= 0 && {_st < _n} && {_sid isNotEqualTo ""}) then { (_pl select _st) pushBack [_sid, (_len max 1)]; };} forEach _rows;
    };
    // fallback: any station the schedule didn't populate uses the packed config
    for "_i" from 0 to (_n - 1) do {if ((_pl select _i) isEqualTo []) then {private _songs = getArray (_cfg >> (_stns select _i));
            private _lens  = getArray (_cfg >> (_lenKs select _i));
            { (_pl select _i) pushBack [_x, ((_lens param [_forEachIndex, 30]) max 1)]; } forEach _songs;};};
    // Malden-migration ad: force it onto every POPULATED station (whether the playlist came from the DB
    // schedule or the packed config) so it can be broadcast every 3rd track. Skips empty stations.
    {if ((count _x) > 0 && {(_x findIf { (_x select 0) isEqualTo "radio_ad_malden" }) < 0}) then {_x pushBack ["radio_ad_malden", 145];};
    } forEach _pl;
    PLB_radioPlaylists = _pl;};
call _fnLoad;

// advance station _si to its next track. Every 3rd advance = the Malden ad (forced); the other two are a
// fresh random non-repeat song that is NEVER the ad (so the ad plays exactly 1-in-3, not by chance too).
private _fnPick = {params ["_si"];
    private _list = PLB_radioPlaylists select _si;
    private _cnt  = count _list;
    if (_cnt isEqualTo 0) exitWith {};
    private _prev  = (PLB_radioSt select _si) select 0;
    private _adIdx = _list findIf { (_x select 0) isEqualTo "radio_ad_malden" };

    private _c = (PLB_radioCount select _si) + 1;
    PLB_radioCount set [_si, _c];

    private _pick = -1;
    if (_adIdx >= 0 && {(_c mod 3) isEqualTo 0} && {_cnt > 1}) then {
        _pick = _adIdx;                                    // every 3rd track -> the ad
    } else {_pick = floor random _cnt;                         // random song, no immediate repeat, never the ad
        if (_cnt > 1) then {while { _pick isEqualTo _prev || {_pick isEqualTo _adIdx} } do { _pick = floor random _cnt; };};};
    PLB_radioSt  set [_si, [_pick, serverTime]];
    PLB_radioNow set [_si, [(_list select _pick) select 0, serverTime]];};

for "_i" from 0 to (_n - 1) do { [_i] call _fnPick; };
publicVariable "PLB_radioNow";

private _hb = serverTime;
private _reload = serverTime;
while { true } do {uiSleep 1;
    if (serverTime >= (_reload + 60)) then { call _fnLoad; _reload = serverTime; };   // pull website schedule changes
    private _changed = false;
    for "_i" from 0 to (_n - 1) do {(PLB_radioSt select _i) params ["_cur", "_start"];
        private _list = PLB_radioPlaylists select _i;
        private _len  = if (_cur >= 0 && {_cur < count _list}) then { (_list select _cur) select 1 } else { 30 };
        if (serverTime >= (_start + _len)) then { [_i] call _fnPick; _changed = true; };};
    if (_changed || {serverTime >= (_hb + 10)}) then { publicVariable "PLB_radioNow"; _hb = serverTime; };};
