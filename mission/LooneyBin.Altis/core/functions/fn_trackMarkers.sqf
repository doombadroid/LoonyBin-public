private _markers = [];
private _deadUnits = [];
private _marker = "";
private _name = "";
private _down = false;
private _vehicleName = "";
addMissionEventHandler["Map", {params["_mapIsOpened", "_mapIsForced"];
    if (_mapIsOpened) then {life_mapMarkers = [];
        _markers = life_mapMarkers; {if !(isNull _x) then {
                _vehicleName = getText(configFile >> "CfgVehicles" >> typeOf _x >> "displayName");
                _marker = createMarkerLocal[format["%1_marker", _x], getPosATL _x];
                _marker setMarkerColorLocal "ColorGreen";
                _marker setMarkerTypeLocal "Mil_destroy";
                _marker setMarkerTextLocal format["%1", _vehicleName];
                _markers pushBack[_marker, _x];};}
        forEach life_tracked;
        if (((serverTime - serverStartTime) < 600)) then {{if !(_x in life_tracked) then {
                    _vehicleName = getText(configFile >> "CfgVehicles" >> typeOf _x >> "displayName");
                    _marker = createMarkerLocal[format["%1_marker", _x], getPosATL _x];
                    _marker setMarkerColorLocal "ColorGreen";
                    _marker setMarkerTypeLocal "mil_dot";
                    _marker setMarkerTextLocal format["%1%2", "Owned Vehicle - ", _vehicleName];
                    _markers pushBack[_marker, _x];};}
            forEach(life_vehicles select {!isNull _x && {alive _x && (_x isKindOf "Car" || _x isKindOf "Air" || _x isKindOf "Ship")
                    // owner 2026-06-15 (#241/#244): the post-restart "Owned Vehicle" map sweep is a CIVILIAN
                    // find-my-car QoL. #189 gated it to the viewer's side, but that still showed a COP their
                    // cop-side cars ("vehicle markers on the map on cop"). Cop/med vehicles spawn at HQ and
                    // should NEVER get a map marker -> only civ-side (and legacy "") owned vehicles are marked.
                    && {(_x getVariable ["plb_side", ""]) in ["", "civ"]}}});};
        if (playerSide isEqualTo west && {life_coprole in ["medic", "all"]}) then {_deadUnits = allDeadMen select {
                _x getVariable["plb_revivable", false] && !(isNil {_x getVariable "plb_name"})}; {
                _marker = createMarkerLocal[format["%1_dead_marker", _x], visiblePosition _x];
                _marker setMarkerColorLocal "ColorRed";
                _marker setMarkerTypeLocal "loc_Hospital";
                _marker setMarkerTextLocal format["%1 Unconscious", _x getVariable["plb_name", "Unknown Player"]];
                _markers pushBack[_marker, _x];}
            forEach _deadUnits;};
        if (playerSide isEqualTo civilian) then {   // owner 2026-07-13: Sixth Sense (71) baked to core -- all civs see group death markers
            {if ((_x getVariable["plb_group", grpNull]) isEqualTo group player) then {
                    _marker = createMarkerLocal[format["%1_groupDead_marker", _x], visiblePosition _x];
                    _marker setMarkerColorLocal "ColorRed";
                    _marker setMarkerTypeLocal "loc_Hospital";
                    _marker setMarkerTextLocal format["%1 Unconscious", _x getVariable["plb_name", "Unknown Player"]];
                    _markers pushBack[_marker, _x];};}
            forEach allDeadMen;};
 {if (_x isEqualTo player) then {_marker = createMarkerLocal[format["%1_marker", _x], getPosWorld _x];
                    _marker setMarkerColorLocal "ColorBlue";
                    _marker setMarkerTypeLocal "mil_arrow2";
                    _marker setMarkerTextLocal "YOU";
                    _marker setMarkerDirLocal(getDir _x);
                    _markers pushBack[_marker, _x];} else {
                    if (playerSide isEqualTo west && side _x isEqualTo west && !(_x getVariable["plb_blinded", false])) then {
                        _marker = createMarkerLocal[format["%1_marker", _x], getPosWorld _x];
                        _marker setMarkerColorLocal "ColorBlue";
                        _marker setMarkerTypeLocal "Mil_dot";
                        _marker setMarkerTextLocal format["%1", name _x];
                        _markers pushBack[_marker, _x];};
                    if (!(playerSide isEqualTo west) && !(side _x isEqualTo west) && !(_x getVariable["plb_blinded", false]) && !(_x getVariable["plb_restrained", false]) && !life_inEvent) then {
                        if (!isNull(group player)) then {if (group player isEqualTo group _x) then {
                                _marker = createMarkerLocal[format["%1_marker", _x], getPosWorld _x];
                                _marker setMarkerColorLocal "ColorBlue";
                                _marker setMarkerTypeLocal "Mil_dot";
                                _marker setMarkerTextLocal format["%1", name _x];
                                _markers pushBack[_marker, _x];};};
                        if !(life_gang_data isEqualTo[] && !life_inEvent) then {if !(_x getVariable["gang_data", []] isEqualTo[]) then {
                                if ((life_gang_data select 0) isEqualTo((_x getVariable["gang_data", []]) select 0)) then {
                                    _marker = createMarkerLocal[format["%1_marker", _x], getPosWorld _x];
                                    _marker setMarkerColorLocal "ColorBlue";
                                    _marker setMarkerTypeLocal "Mil_dot";
                                    _marker setMarkerTextLocal format["%1", name _x];
                                    _markers pushBack[_marker, _x];};};};};};}
            forEach allPlayers;;
        if (SRV_governorData param[3, false]) then {
            "weed_1"
            setMarkerColorLocal "ColorGreen";
            "weed_2"
            setMarkerColorLocal "ColorGreen";
            "Weed_p_2"
            setMarkerAlphaLocal 1;} else {
            "weed_1"
            setMarkerColorLocal "ColorRed";
            "weed_2"
            setMarkerColorLocal "ColorRed";
            "Weed_p_2"
            setMarkerAlphaLocal 0;};
        [] spawn {while {visibleMap}
            do {{
                    _x getVariable["plb_turf_data", [-1, "Unknown", false, "Unknown"]] params[["_gangID", -1, [0]], ["_gangName", "Unknown", [""]], ["_active", false, [false]]];
                    private _countLabel = "";
                    private _marker = format["turf_label_%1", _x];
                    private _markerPos = getMarkerPos _marker;
                    if ((life_gang_data select 0) isEqualTo _gangID) then {private _inTurf = allPlayers select {
                            _x distance _markerPos < 750};
                        _countLabel = format[" (%1)", count _inTurf];};
                    if !(_gangID isEqualTo - 1) then {_marker setMarkerTextLocal format["Turf of %1%2", _gangName, _countLabel];
                        private _markerColor =
                        if (_active) then {"ColorRed"} else {"ColorUNKNOWN"};
                        _marker setMarkerColorLocal _markerColor;
                        (format["turf_area_%1", _x]) setMarkerColorLocal _markerColor;} else {_marker setMarkerTextLocal "Uncontrolled";};
                } forEach [rodo_flag, zaros_flag, panagia_flag];
                if !(visibleMap) exitWith {};
                uiSleep 4;};};
        [] spawn {while {visibleMap}
            do {{
                    _x getVariable["plb_boatflag_data", ["", -1, "Uncontrolled"]] params[["_captureTarget", "", [""]], ["_gangID", -1, [0]], ["_gangName", "Uncontrolled", [""]]];
                    private _countLabel = "";
                    private _marker = format["boat_capture_label_%1", _captureTarget];
                    if !(_gangID isEqualTo - 1) then {if ((life_gang_data select 0) isEqualTo _gangID) then {
                            _marker setMarkerColorLocal "ColorGreen";} else {_marker setMarkerColorLocal "ColorRed";};
                        _marker setMarkerTextLocal format["%1 - %2", _captureTarget, _gangName];} else {
                        _marker setMarkerTextLocal format["%1 - Uncontrolled", _captureTarget];};
                } forEach (SRV_gangBoatFortressData select 1);
                if !(visibleMap) exitWith {};
                uiSleep 4;}};
        [] spawn {while {visibleMap}
            do {
                (gang_fortress_flag getVariable["plb_gang_fortress_data", [-1, "Unknown", false]]) params[["_gangID", -1, [0]], ["_gangName", "Unknown", [""]], ["_active", false, [false]]];
                // owner 2026-06-17: the marker now shows the CURRENT OWNER to EVERYONE. WAS: only the owning gang's
                // members saw their name; everyone else fell back to the stale GLOBAL marker text ("Gang Fortress -
                // Uncontrolled") -> a held fortress read "Uncontrolled" on the map for non-members AND after every
                // restart. Driven straight off plb_gang_fortress_data (set on capture/finish, restored on boot).
                // Owning members also get the live headcount inside the 400m zone.
                private _txt = switch (true) do {case (_active): { "Gang Fortress - Contested" };
                    case (_gangID isEqualTo -1): { "Gang Fortress - Uncontrolled" };
                    case ((_gangID isEqualTo (life_gang_data param[0, -1])) && (life_gang_data isNotEqualTo [])): {
                        format ["Gang Fortress - %1 (%2)", _gangName, count(allPlayers select {
                            (_x distance2D(getMarkerPos "gang_fortress_marker") <= 400) && (alive _x)})]};
                    default { format ["Gang Fortress - %1", _gangName] };};
                "gang_fortress_marker" setMarkerTextLocal _txt;
                if !(visibleMap) exitWith {};
                uiSleep 4;};};
        [] spawn {while {!(life_mapMarkers isEqualTo[])}
            do {{_x params["_marker", "_veh"];
                    if !(isNil "_veh") then {if !(isNull _veh) then {_marker setMarkerPosLocal(getPosWorld _veh);
                            _marker setMarkerDirLocal(getDir _veh);};};} forEach life_mapMarkers;
                uiSleep 0.025;};};} else {if !(life_mapMarkers isEqualTo[]) then {{deleteMarkerLocal(_x select 0)}
            forEach life_mapMarkers;
            life_mapMarkers = [];};};}];