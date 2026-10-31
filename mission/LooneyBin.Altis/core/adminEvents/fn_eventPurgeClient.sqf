/*
    life_fnc_eventPurgeClient  --  THE PURGE (auto-zone).  owner 2026-06-24 rebuild.
    Driven by the client watcher in initPlayerLocal which fires this on a purge START (life_adminEvent select 2 == 5).
    The server (TON_fnc_eventPurgeSRV) owns the GLOBAL PurgeRedzone/PurgeDot markers + PLB_purgeZone; the actual
    "crime is legal" mechanic is the server-side no-charge gate in TON_fnc_wantedAdd. This client side is just the
    flavour: the government announcement + sirens (skipped for JIP joiners) and an entry/exit warning while inside
    the zone. No triggers, no opt-in -- the zone applies to everyone present.
*/
params [["_thisList", [], []], ["_mode", "", [""]], ["_jip", false, [false]]];
if (_mode == "") exitWith {};
if !((!isNil "life_adminEvent") && {life_adminEvent param [0, false]} && {(life_adminEvent param [2, 0]) isEqualTo 5}) exitWith {};

switch (_mode) do {case "initClient": {
        private _locName = (["getLocationByID", life_adminEvent select 3] call life_fnc_eventCfg) param [1, "?"];
        // race guard: the server publishes life_adminEvent + the markers as separate network messages -- wait briefly
        // for the global zone marker to exist before using inArea (else early ticks read [0,0,0] -> never "inside").
        private _t = time + 20;
        waitUntil { uiSleep 0.5; ((getMarkerPos "PurgeRedzone") isNotEqualTo [0,0,0]) || (time > _t) || !(life_adminEvent param [0, false]) };
        if !(life_adminEvent param [0, false]) exitWith {};

        if !(_jip) then {
            [format ["<t size='1.5' color='#FF0000'>The PURGE</t><br/><br/>The government of Altis has announced the annual purge will be held in %1.<br/><br/>Please stay seated for a message from the government.", _locName], "event"] spawn life_fnc_handleMessage;
            uiSleep 8;   // owner 2026-06-24: dropped the old [objNull,"purgeMessage"] playSound -- that CfgSounds entry doesn't exist (only purgeSiren does), so the original 31.3s wait was just dead air for a clip that never played.
            if !(life_adminEvent param [0, false]) exitWith {};
            [format ["<t size='1.5' color='#FF0000'>The PURGE</t><br/><br/>The purge is now ACTIVE in %1.<br/><br/>All crimes including MURDER are legal inside the red zone marked on your map.<br/><br/>(RDM rules do NOT apply inside the zone.)", _locName], "event"] spawn life_fnc_handleMessage;
            for "_i" from 0 to 4 do { [objNull, "purgeSiren", true] spawn life_fnc_playSound; uiSleep 3; };};

        // entry/exit warning -- one watcher per player, runs until the purge ends
        if (player getVariable ["plb_purgeWatch", false]) exitWith {};
        player setVariable ["plb_purgeWatch", true];
        [] spawn {private _was = false;
            while { (!isNil "life_adminEvent") && {life_adminEvent param [0, false]} && {(life_adminEvent param [2, 0]) isEqualTo 5} } do {
                private _in = ((getMarkerPos "PurgeRedzone") isNotEqualTo [0,0,0]) && {player inArea "PurgeRedzone"};
                if (_in && !_was) then {_was = true;
                    ["<t color='#FF0000'>YOU'VE ENTERED THE PURGE ZONE</t><br/>All crime is legal here for the event duration. RDM rules do NOT apply.", "turf"] spawn life_fnc_handleMessage;
                };
                if (!_in && _was) then {_was = false;
                    ["You've left the Purge zone -- normal laws apply again.", "turf"] spawn life_fnc_handleMessage;};
                uiSleep 2;};
            player setVariable ["plb_purgeWatch", false];};};};
