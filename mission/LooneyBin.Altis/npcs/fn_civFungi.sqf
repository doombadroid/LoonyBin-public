params["_obj_main", "", "_type"];
if (_obj_main isKindOf "CAManBase") then {};
switch (_type) do {case ("enterDen"): {_obj_main addAction["<t color='#ADFF2F'>Enter Fungi Den</t>", {
                ["enterDen"] spawn life_fnc_fungiActions}, nil, 2, true, true, "", 'isNull objectParent player', 5];}; case ("exitDen"): {
                _obj_main addAction["<t color='#ADFF2F'>Exit Fungi Den</t>", {["exitDen"] spawn life_fnc_fungiActions
                }, nil, 2, true, true, "", 'isNull objectParent player', 5];};
        case ("mineFungi"): {_obj_main addAction["<t color='#ADFF2F'>Dig for Dark Fungi</t>", {[] spawn life_fnc_mineFungi
                }, nil, 10, true, true, "", 'isNull objectParent player && playerSide isEqualTo civilian && (player getVariable ["plb_inFungiDen", false])', 10];   // owner 2026-06-19: only inside the den (took the elevator) -- hides the action on the surface rocks (Tempest exploit)
            };
        case ("processFungi"): {
                _obj_main addAction["Extract LSD from Moist Fungi", life_fnc_processAction, "fungi", 1.5, false, false, "", 'life_inv_fungi > 0 && !life_is_processing && playerSide isEqualTo civilian'];
                _obj_main addAction["Form LSD Sheets (Purify)", life_fnc_processAction, "lsd_1", 1.5, false, false, "", 'life_inv_lsd_0 > 0 && !life_is_processing && playerSide isEqualTo civilian'];
                // owner 2026-06-17 (#322): the Fungi Den (LSD processor) was the only processor with NO bulk
                // "Process Vehicle" options, so a trunk full of Dark Fungi / LSD Pills couldn't be processed here
                // ("can't process vehicle inventory at the LSD processor"). Mirror the other processors.
                _obj_main addAction["<t color='#33FF99'>Process Vehicle: LSD</t>", life_fnc_processVehicle, "fungi", 1.5, false, false, "", '!life_is_processing', 5];
                _obj_main addAction["<t color='#33FF99'>Process Vehicle: LSD Sheets</t>", life_fnc_processVehicle, "lsd_1", 1.5, false, false, "", '!life_is_processing', 5];
            };};