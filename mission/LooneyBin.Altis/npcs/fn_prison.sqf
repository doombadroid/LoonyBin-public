params["_obj_main", "_stance"];
if (_obj_main isKindOf "CAManBase") then {};
_obj_main addAction["Pay Bail", {[player] call life_fnc_postBail
}, nil, 1.5, false, false, "", '((life_is_arrested param [0,0]) isEqualTo 1)', 5];
_obj_main addAction["Request a Court Trial", {["defendantRequestTrial", [player]] spawn life_fnc_trialSystem
}, nil, 1.5, false, false, "", '((life_is_arrested param [0,0]) isEqualTo 1)', 5];
_obj_main addAction["Let me out!", {if (playerSide isEqualTo west && (SRV_prisonData select 1)) exitWith {
        ["You cannot do this while a prison break is ongoing!", "basic"] spawn life_fnc_handleMessage};
    private _plb_pos =
    if (playerSide isEqualTo west) then {[16846, 13529.6, 1.02138378]} else {getMarkerPos "jail_release2"};
    player setPos _plb_pos;
}, "", 1.5, false, false, "", '((life_is_arrested param [0,0]) isEqualTo 0) && !(player getVariable ["plb_arrested", false])', 5];
_obj_main addAction["Queue for Laser tag", life_fnc_laserJoin, "", 0, false, false, "", ' playerSide isEqualTo civilian && ((life_is_arrested param [0,0]) isEqualTo 1)', 5];