params["_obj_main", "_stance", "_deliveryModifier"];
if (_obj_main isKindOf "CAManBase") then {};
if (_deliveryModifier < 0) then {
    _obj_main addAction["Steal Low Value Shipment ($10,000 bribe)", life_fnc_startConvoyRobbery, 0, 1.5, false, false, "", 'playerSide isEqualTo civilian', 5];
    _obj_main addAction["Steal Medium Value Shipment ($15,000 bribe)", life_fnc_startConvoyRobbery, 1, 1.5, false, false, "", 'playerSide isEqualTo civilian', 5];
    _obj_main addAction["Steal High Value Shipment ($25,000 bribe)", life_fnc_startConvoyRobbery, 2, 1.5, false, false, "", 'playerSide isEqualTo civilian', 5];
} else {
    _obj_main addAction["Deliever Stolen Shipment", life_fnc_finishConvoyRobbery, _deliveryModifier, 1.5, false, false, "", '(SRV_convoy_status select 0) && playerSide isEqualTo civilian', 5];
    // BUGS.md #94 (rev 2): fence markers for civilians, but ONLY while a convoy robbery is ACTIVE --
    // rev 1 drew them permanently ("shipment thing shows up even when the event isnt going on").
    // Each fence registers here; one watcher loop per client draws/erases the whole set with the event.
    if (playerSide isEqualTo civilian) then {if (isNil "life_convoyFences") then { life_convoyFences = []; };
        life_convoyFences pushBack [getPosATL _obj_main, _deliveryModifier];
        if (isNil "life_convoyFenceWatcher") then {life_convoyFenceWatcher = true; [{params ["_st"];
                private _drawn = _st getOrDefault ["drawn", false];
                private _active = (missionNamespace getVariable ["SRV_convoy_status", [false]]) param [0, false];
                if (_active && !_drawn) then {{_x params ["_p", "_m"];
                        private _mk = format ["convoy_fence_%1", _forEachIndex];
                        createMarkerLocal [_mk, _p];
                        _mk setMarkerTypeLocal "loc_Tourism";
                        _mk setMarkerColorLocal "ColorOrange";
                        _mk setMarkerTextLocal format ["Shipment Drop Off (%1%2 cut)", round (_m * 100), "%"];} forEach life_convoyFences;
                    _st set ["drawn", true];};
                if (!_active && _drawn) then {{ deleteMarkerLocal format ["convoy_fence_%1", _forEachIndex]; } forEach life_convoyFences;
                    _st set ["drawn", false];};}, createHashMap, 5] call life_fnc_addPerFrameHandler;};};};