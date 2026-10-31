disableSerialization;
createDialog "life_capture_menu";
waitUntil {!isNull(findDisplay 2300)};
private _display = findDisplay 2300;
[_display] spawn life_fnc_p_updateMenu;
private _list = _display displayCtrl 2301;
private _details = _display displayCtrl 2302;
private _keyList = _display displayCtrl 2303;
_details ctrlSetStructuredText parseText "<t size='0.90' align='center'>Select a capture location</t>";
lbClear _list;
if !!(false) exitWith {_details ctrlSetStructuredText parseText "<t size='0.90' align='center'>Select a domination flag</t>"; {
        private _flag = _x;
        private _flagData = _flag getVariable["plb_domination_data", [-1, "Unknown"]];
        private _defaultFlagName = ["Capture Point: Alpha", "Capture Point: Bravo", "Capture Point: Charlie", "Capture Point: Delta"] param[domination_flags find _flag, "Capture Point"];
        _flagData params["_xGangID", "_xGangName"];
        _xGangName =
        if (_xGangID isEqualTo - 1) then {"Uncapped"} else {_xGangName};
        private _nearbyGangs = [];
        private _gangID = life_gang_data param[0, -25]; {private _insideX = _x;
            if (!(toLower(primaryWeapon _insideX) in life_nonCartelGuns) && (side _insideX isEqualTo civilian)) then {
                private _targetsGang = ((_insideX getVariable["gang_data", [0]]) select 0);
                if (!(_targetsGang in _nearbyGangs) && !(_targetsGang isEqualTo 0) && alive _insideX && !(_targetsGang isEqualTo _gangID)) then {
                    _nearbyGangs pushBack _targetsGang;};};}
        forEach(nearestObjects[_flag, ["Man"], 60]);
        private _index = _list lbAdd format["%1 - [%2]", _defaultFlagName, _xGangName];
        if !(_nearbyGangs isEqualTo[]) then {_list lbSetPictureRight[_index, "a3\Ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa"]};}
    forEach domination_flags; {private _index = _keyList lbAdd format["%1", _x select 0];
        _keyList lbSetPictureRight[_index, _x select 1]}
    forEach[["Contested", "a3\Ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa"]];
    _list ctrlAddEventHandler["LBSelChanged", "_this spawn life_fnc_captureSel"];}; {_x params["_flag", "_marker"];
    private _captureData = _flag getVariable["plb_capData", [0, "Neutral", 0.5]];
    private _onCooldown = (serverTime < (_flag getVariable["plb_capture_cooldown", serverTime - 100]));
    private _currentCaptureProgress = round((_captureData select 2) * 100);
    private _cartelNames = ["Arms Cartel", "Drug Cartel", "Oil Cartel", "Wong Triad"];
    _captureData params["_gangID", "_gangName", "_progress"];
    private _nearbyGangs = []; {private _insideX = _x;
        if (!(toLower(primaryWeapon _insideX) in life_nonCartelGuns) && (_insideX getVariable["plb_cartCap", false]) && !(_insideX getVariable['plb_isBountyHunter', false]) && (side _insideX isEqualTo civilian)) then {
            private _targetsGang = ((_insideX getVariable["gang_data", [0]]) select 0);
            if (!(_targetsGang in _nearbyGangs) && !(_targetsGang isEqualTo 0) && alive _insideX && !(_targetsGang isEqualTo _gangID)) then {
                _nearbyGangs pushBack _targetsGang;};};}
    forEach(nearestObjects[getMarkerPos _marker, ["Man"], 60]);
    private _index = _list lbAdd format["%1 - [%2%3]", _cartelNames select _forEachIndex, _currentCaptureProgress, "%"];
    if !(_nearbyGangs isEqualTo[]) then {_list lbSetPictureRight[_index, "a3\Ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa"]};
    if (_onCooldown) then {_list lbSetPictureRight[_index, "icons\stopwatch.paa"]};}
forEach[[arms_flag, "arms_cartel"], [drug_flag, "drug_cartel"], [oil_flag, "oil_cartel"], [wongs_flag, "wongs_cartel"]]; {
    private _index = _keyList lbAdd format["%1", _x select 0];
    _keyList lbSetPictureRight[_index, _x select 1]}
forEach[["Contested", "a3\Ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa"], ["Cooldown", "icons\stopwatch.paa"]];
_list ctrlAddEventHandler["LBSelChanged", "_this spawn life_fnc_captureSel"];