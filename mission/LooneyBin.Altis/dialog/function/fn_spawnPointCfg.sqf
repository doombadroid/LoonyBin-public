private _return = [];
params[["_side", civilian, [civilian]], ["_isRedeploy", false, [false]]];
switch (_side) do {case west: {_return = [["cop_spawn_1", "Kavala HQ"], ["cop_spawn_2", "Pyrgos HQ"], ["cop_spawn_3", "Athira HQ"],
                ["cop_spawn_7", "Sofia HQ"], ["cop_spawn_4", "Air HQ"], ["cop_spawn_5", "HW HQ"], ["cop_spawn_6", "Dump HQ"]];
            if !(isNull(SRV_mobileHQ select 1)) then {if !(speed(SRV_mobileHQ select 1) > 0) then {
                    private _spawnPoint = getPos(SRV_mobileHQ select 1);
                    _spawnPoint set[0, (_spawnPoint select 0) + 1.5];
                    _spawnPoint set[1, (_spawnPoint select 1) + 1.5];
                    _return pushBack[_spawnPoint, "Mobile HQ"];};};};
    case civilian: {_return = [["civ_spawn_3", "Athira"], ["civ_spawn_2", "Pyrgos"], ["civ_spawn_1", "Kavala"], ["civ_spawn_4", "Sofia"],
                ["donor_town", "Therisa"]];
            if (life_houses isNotEqualTo[]) then {{private _pos = parseSimpleArray(_x select 0);
                    private _notInActiveTurf = ({
                        _pos distance(getPos _x) <= 800 && (_x getVariable["plb_turf_data", [-1, "Unknown", false, "Unknown"]] select 2)}
                    count[rodo_flag, zaros_flag, panagia_flag] isEqualTo 0);
                    private _notInCartelOrWarzone = (({_pos distance(getPos _x) <= 600}
                    count[arms_flag, drug_flag, wongs_flag, oil_flag] isEqualTo 0));
                    private _notInActiveFortressAndParticipating = !((_pos distance2D gang_fortress_flag <= 5000) && ((gang_fortress_flag getVariable["plb_gang_fortress_data", [-1, "Unknown", false]]) param[2, false]) && (getPlayerUID player) in (missionNamespace getVariable ["SRV_diedInGangFort", []]));
                    private _notInActiveJewelry = !((_pos distance2D(getMarkerPos "life_jewelryEmporiumMarker") <= 800) && ((missionNamespace getVariable ["SRV_jewelryEmporiumSRV", [false,false]]) param[1, false]));
                    if (_notInActiveTurf && _notInCartelOrWarzone && _notInActiveFortressAndParticipating && _notInActiveJewelry) then {
                        // owner 2026-07-04: pick the nearest House whose TYPE is a real house type, NOT a bare
                        // param[0]. At a buyable-shed spot the derelict Land_u_Shed_Ind_F sits on the intact
                        // Land_i_Shed_Ind_F (both "House", both dist 0); param[0] grabbed the derelict, whose type
                        // is NOT in life_houseTypes -> the shed was silently dropped from the spawn list (house menu
                        // worked because ownership is tagged on the intact, but this builder re-resolves by nearest).
                        private _house = ((nearestObjects[_pos, ["House"], 10]) select { (typeOf _x) in life_houseTypes }) param[0, objNull];
                        if !(isNull _house) then {
                            private _cn = _house getVariable ["plb_houseName", ""];   // owner 2026-07-10: player-set house name
                            private _houseName =
                            if (_house getVariable["plb_house_gang", -1] isNotEqualTo - 1) then {"Gang Building"} else {
                                if (_cn isEqualTo "") then { getText(configFile >> "CfgVehicles" >> typeOf _house >> "displayName") } else { _cn }
                            };
                            private _houseType = typeOf _house;
                            if ((_houseType in life_houseTypes) && !((_house getVariable["plb_house_tax", [false]]) select 0)) then {
                                _return pushBack[format["phouse_%1", _house getVariable ["plb_houseID", _x select 1]], _houseName];};};};}
                forEach life_houses;};
            // owner 2026-06-18 (#343/344/345/347): gang-building spawn REWRITTEN. Driven off the PERSISTED gang HQ
            // pos (life_gang_data param 3, synced from gangs.house_pos to EVERY member) so ANY member can spawn there
            // even with the building's owner OFFLINE -- was keyed to the life_gangBuilding OBJECT (nil when the owner
            // is away) AND pushed a spawn name (phouse_<gid><uid>) that matched NO marker -> getMarkerPos [0,0,0] ->
            // "Error/ocean". Spawn point is now "gangbldg", resolved to the HQ pos in fn_spawnConfirm (no marker dep).
            // Dedup is a real findIf (the old `... forEach _return) >= 0` returned only the LAST element's find ->
            // 50/50 show/hide). Still hidden during a nearby active turf/cartel/fortress/jewelry event (owner: keep).
            // Tax check is best-effort -- the building object may not be loaded when you're far / owner offline, so a
            // not-found building defaults to ALLOWING the spawn.
            if !((life_gang_data param[3, [0, 0, 0]]) isEqualTo[0, 0, 0]) then {private _pos = life_gang_data select 3;
                private _alreadyListed = (_return findIf { ((_x param[1, ""]) find "Gang Building") >= 0 }) >= 0;
                if (!_alreadyListed) then {private _notInActiveTurf = ({
                        _pos distance(getPos _x) <= 800 && (_x getVariable["plb_turf_data", [-1, "Unknown", false, "Unknown"]] select 2)}
                    count[rodo_flag, zaros_flag, panagia_flag] isEqualTo 0);
                    private _notInCartelOrWarzone = (({_pos distance(getPos _x) <= 600}
                    count[arms_flag, drug_flag, wongs_flag, oil_flag] isEqualTo 0));
                    private _notInActiveFortress = !((_pos distance2D gang_fortress_flag <= 400) && ((gang_fortress_flag getVariable["plb_gang_fortress_data", [-1, "Unknown", false]]) param[2, false]));
                    private _notInActiveJewelry = !((_pos distance2D(getMarkerPos "life_jewelryEmporiumMarker") <= 800) && ((missionNamespace getVariable ["SRV_jewelryEmporiumSRV", [false,false]]) param[1, false]));
                    private _ghc = nearestObjects[_pos, ["House"], 18, true];
                    private _gh = (_ghc select { (typeOf _x) in life_houseTypes }) param [0, (_ghc param [0, objNull])];   // owner 2026-07-09: shed-proof resolve (twin of fn_spawnConfirm)
                    private _taxOk = isNull _gh || !((_gh getVariable["plb_house_tax", [false]]) select 0);
                    if (_notInActiveTurf && _notInCartelOrWarzone && _notInActiveFortress && _notInActiveJewelry && _taxOk) then {
                        _return pushBack["gangbldg", "Gang Building"];};};}; {
                if ((life_gang_data select 0) isEqualTo(_x getVariable["plb_turf_data", [-1, "Unknown", false, "Unknown"]] select 0) && !(_x getVariable["plb_turf_data", [-1, "Unknown", false, "Unknown"]] select 2)) then {
                    private _text =
                    switch (_forEachIndex) do {case 0: {"Rodopoli"};
                        case 1: {"Zaros"};
                        case 2: {"Panagia"};}; _return pushBack[format["turf_label_%1", _x], _text];};}
            forEach[rodo_flag, zaros_flag, panagia_flag];
            if (getPlayerUID player isEqualTo(SRV_governorData param[0, "GovUID"])) then {_return pushBack["gov", "Governor Office"];};
            if (!((gang_fortress_flag getVariable["plb_gang_fortress_data", [-1, "Unknown", false]]) param[2, false]) && ((gang_fortress_flag getVariable["plb_gang_fortress_data", [-1, "Unknown", false]]) param[0, -1]) isEqualTo(life_gang_data param[0, -1])) then {
                if (life_gang_data isNotEqualTo[]) then {_return pushBack["gang_fortress_marker", "Gang Fortress"];};};
            // owner 2026-06-17: during an ACTIVE Gang Fortress event, ANYONE (any civ, gang or not) can deploy to the
            // two temporary Rebel Outposts (the safezones ~1km from the flag) to join the fight -- the deliberate
            // opposite of the fort-flag spawn above (owning gang only, between events only). Markers gangf_rebel_c_0/1
            // are created on event start; fn_spawnConfirm's default civ case resolves them via getMarkerPos (and if
            // the event ends before they confirm, the [0,0,0] guard there bounces them to pick another spawn).
            if (!isNil "SRV_tempGangRebel" && {(gang_fortress_flag getVariable["plb_gang_fortress_data", [-1, "Unknown", false]]) param[2, false]}) then {
                _return pushBack["gangf_rebel_c_0", "Rebel Outpost 1"];
                _return pushBack["gangf_rebel_c_1", "Rebel Outpost 2"];};
            if (!((life_gangBoatFortressObject getVariable["plb_gang_fortress_data", [-1, "Uncontrolled", false]]) param[2, false]) && ((life_gangBoatFortressObject getVariable["plb_gang_fortress_data", [-1, "Uncontrolled", false]]) param[0, -1]) isEqualTo(life_gang_data param[0, -1])) then {
                if (life_gang_data isNotEqualTo[]) then {_return pushBack["gangboat_label", "Gang Boat"];};};};
    case independent: {_return = [["med_spawn_1", "Kavala"], ["med_spawn_2", "Pyrgos"], ["med_spawn_3", "Athira"], ["med_spawn_4", "Sofia"],
                ["med_spawn_5", "Air"], ["med_spawn_6", "Dump"]];};}; private _return =
_return;
if (playerSide in [west, civilian] && !(life_disabled_spawns isEqualTo[]) && !_isRedeploy) then {_return = _return select {
        !((_x select 0) in life_disabled_spawns)};};
if (playerSide isEqualTo west && (evidenceLaptop getVariable["plb_laptopstatus", 2] isEqualTo 2) && life_evidence_spawns < 2) then {
    _return pushBack["armory_marker", "Evidence Lockup"];};
_return;