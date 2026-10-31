private _markers = [];
private _units = [];
private _medics = [];
private _marker = "";
private _name = "";
addMissionEventHandler["Map", {params["_mapIsOpened", "_mapIsForced"];
    if (_mapIsOpened) then {life_mapMarkers = [];
        _markers = life_mapMarkers;
        _medics = allPlayers select {side _x isEqualTo independent};
        _units = allDeadMen select {_x getVariable["plb_revivable", false] && !(isNil {_x getVariable "plb_name"})}; {
            if !(isNull _x) then {_name = getText(configFile >> "CfgVehicles" >> typeOf _x >> "displayName");
                _marker = createMarkerLocal[format["%1_marker", _x], getPosATL _x];
                _marker setMarkerColorLocal "ColorGreen";
                _marker setMarkerTypeLocal "Mil_destroy";
                _marker setMarkerTextLocal format["%1", _name];
                _markers pushBack[_marker, _x];};}
        forEach life_tracked; {_marker = createMarkerLocal[format["%1_dead_marker", _x], visiblePosition _x];
            _marker setMarkerColorLocal "ColorRed";
            _marker setMarkerTypeLocal "loc_Hospital";
            _marker setMarkerSizeLocal[1.2, 1.2];
            _marker setMarkerTextLocal format["%1 Unconscious", _x getVariable["plb_name", "Unknown Player"]];
            _markers pushBack[_marker];}
        forEach _units; {if (_x isEqualTo player) then {_marker = createMarkerLocal[format["%1_marker", _x], getPosWorld _x];
                _marker setMarkerColorLocal "ColorBlue";
                _marker setMarkerTypeLocal "mil_arrow2";
                _marker setMarkerTextLocal "YOU";
                _marker setMarkerDirLocal(getDir _x);
                _markers pushBack[_marker, _x];} else {_marker = createMarkerLocal[format["%1_marker", _x], getPosWorld _x];
                _marker setMarkerColorLocal "ColorBlue";
                _marker setMarkerTypeLocal "Mil_dot";
                _marker setMarkerTextLocal format["%1", name _x];
                _markers pushBack[_marker, _x];};}
        forEach _medics;
        [] spawn {while {!(life_mapMarkers isEqualTo[])}
            do {{_x params["_marker", "_veh"];
                    if !(isNil "_veh") then {if !(isNull _veh) then {_marker setMarkerPosLocal(getPosWorld _veh);
                            _marker setMarkerDirLocal(getDir _veh);};};} forEach life_mapMarkers;
                uiSleep 0.025;};};} else {if !(life_mapMarkers isEqualTo[]) then {{deleteMarkerLocal(_x select 0)}
            forEach life_mapMarkers;
            life_mapMarkers = [];};};}];