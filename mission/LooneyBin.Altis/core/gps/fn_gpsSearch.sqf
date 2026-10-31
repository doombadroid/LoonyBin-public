/*
    life_fnc_gpsSearch  (LooneyBin, owner 2026-07-12)
    GPS destination search (dialog\gpsSearch.hpp, idd 91500). Index = every CfgWorlds named place
    (cities/villages/locals) + every named map marker (shops, processing, POIs -- the map already
    names them all). Built once per session, filtered live as you type.

    Modes:
        ["open"]     build index (first time), open dialog, fill list
        ["filter"]   repaint list from the search box (edit onKeyUp)
        ["go"]       route to the selected entry via life_fnc_gps "set"
*/
params [["_mode", "", [""]]];
if (!hasInterface) exitWith {};
if ((toLower _mode) in ["open", "go"] && {(vehicle player) getVariable ["plb_robotaxi", false]}) exitWith {
    ["<t color='#e7c757'>ROBOTAXI:</t> destination is locked for the ride.", "basic"] spawn life_fnc_handleMessage;};

private _typeLabel = {switch (_this) do {case "NameCityCapital": { "CITY" };
        case "NameCity":        { "TOWN" };
        case "NameVillage":     { "VILLAGE" };
        case "NameLocal":       { "PLACE" };
        case "Airport":         { "AIRPORT" };
        default                 { "AREA" };}};

switch (toLower _mode) do {case "open": {if (isNil "PLB_gpsPOIs") then {
            // owner 2026-07-12: CURATED index -- spawn towns, drug fields + their processors, and
            // federal event sites ONLY. Everything else is ALT+Click territory.
            private _idx = []; {private _name = getText (_x >> "name");
                private _type = getText (_x >> "type");
                if (_name isNotEqualTo "" && {_type in ["NameCityCapital", "NameCity"]}) then {private _pos = getArray (_x >> "position");
                    _idx pushBack [_name, _type call _typeLabel, [_pos param [0, 0], _pos param [1, 0]]];};
            } forEach configProperties [configFile >> "CfgWorlds" >> worldName >> "Names", "isClass _x", true];
            private _keep = ["cannabis", "weed", "marijuana", "heroin", "poppy", "cocaine", "coca ", "crank", "meth", "moonshine", "mushroom", "federal", "bank of", "blackwater"];
            // MOTORIST -- Networker (203): also surface live gang turfs, cartels, and running events
            if (203 in life_side_talents) then { _keep append ["turf", "cartel", "fortress", "gang", "purge", "capture", "event"]; }; {
                private _txt = markerText _x;
                if (_txt isNotEqualTo "" && {markerAlpha _x > 0}) then {private _low = toLower _txt;
                    if (_keep findIf { _x in _low } >= 0) then {_idx pushBack [_txt, "POI", markerPos _x];};};} forEach allMapMarkers;
            _idx sort true;
            PLB_gpsPOIs = _idx;};
        if (isNull findDisplay 91500) then { createDialog "PLB_GpsSearch"; };
        ["filter"] call life_fnc_gpsSearch;};
    case "filter": {private _disp = findDisplay 91500;
        if (isNull _disp) exitWith {};
        private _q = toLower ctrlText (_disp displayCtrl 91501);
        private _lb = _disp displayCtrl 91502;
        lbClear _lb; {_x params ["_name", "_tag", "_pos"];
            if (_q isEqualTo "" || {_q in toLower _name}) then {private _row = _lb lbAdd format ["%1        [%2]", _name, _tag];
                _lb lbSetValue [_row, _forEachIndex];};} forEach PLB_gpsPOIs;
        if (lbSize _lb > 0) then { _lb lbSetCurSel 0; };};
    case "go": {private _disp = findDisplay 91500;
        if (isNull _disp) exitWith {};
        private _lb = _disp displayCtrl 91502;
        private _sel = lbCurSel _lb;
        if (_sel < 0) exitWith {};
        private _poi = PLB_gpsPOIs param [_lb lbValue _sel, []];
        if (_poi isEqualTo []) exitWith {};
        closeDialog 0;
        ["set", _poi select 2] call life_fnc_gps;
        if (!visibleMap) then { openMap true; };};};
