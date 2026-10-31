params[["_newLoad", true], ["_isPhone", false]];
disableSerialization;
private _isPhone = isNull(findDisplay 602);
private _phoneDisplay = findDisplay 361000;
if (_newLoad && !(isNull _phoneDisplay)) exitWith {};
if ((_newLoad) && (_isPhone)) then {private _dialogName = "Life_inventory_menu";
    private _dialogID = getNumber(missionconfigfile >> _dialogName >> "idd");
    private _location = "noAnim";
    createDialog _dialogName;
    [_dialogID, _location, true] spawn life_fnc_animateDialog;
    private _closeDialogEVH = compile format["{
			_dialog = _this select 0;_key = _this select 1;_handled = (_key isEqualTo 0x01);_location = %1; _noEscape = %2;
			if (_handled && !_noEscape) then {[] spawn{closeDialog 0; uiSleep 0.01; closeDialog 0;};};
			_handled;
	}", str(_location), (isNumber(missionconfigfile >> _dialogName >> "noEVH"))];
    (findDisplay _dialogID) displayAddEventHandler["keyDown", _this call _closeDialogEVH];
    [findDisplay _dialogID] spawn life_fnc_p_updateMenu;};
private _plb_display =
if (_isPhone) then[{findDisplay 361000}, {findDisplay 602}];
if ((life_action_in_use) && !(_isPhone)) then {closeDialog 0};
if (life_action_in_use) exitWith {["You can't open your inventory while performing another action", "basic"] spawn life_fnc_handleMessage};
if ((_newLoad) && (!life_virt_open) && !(_isPhone)) then {life_virt_open = true;
    systemChat "Press CTRL+R to repack magazine ammo";
    private _mainX = getNumber(configfile >> "RscDisplayInventory" >> "controls" >> "CA_PlayerBackground" >> "x");
    private _mainW = getNumber(configfile >> "RscDisplayInventory" >> "controls" >> "CA_PlayerBackground" >> "w");
    private _panelX = getNumber(configfile >> "RscDisplayInventory" >> "controls" >> "CA_ContainerBackground" >> "x");
    private _panelY = getNumber(configfile >> "RscDisplayInventory" >> "controls" >> "CA_ContainerBackground" >> "y");
    private _panelW = getNumber(configfile >> "RscDisplayInventory" >> "controls" >> "CA_ContainerBackground" >> "w");
    private _panelH = getNumber(configfile >> "RscDisplayInventory" >> "controls" >> "CA_ContainerBackground" >> "h");
    private _progressX = getNumber(configfile >> "RscDisplayInventory" >> "controls" >> "GroundLoad" >> "x");
    private _progressY = getNumber(configfile >> "RscDisplayInventory" >> "controls" >> "GroundLoad" >> "y");
    private _progressW = getNumber(configfile >> "RscDisplayInventory" >> "controls" >> "GroundLoad" >> "w");
    private _progressH = getNumber(configfile >> "RscDisplayInventory" >> "controls" >> "GroundLoad" >> "h");
    private _containerX = getNumber(configfile >> "RscDisplayInventory" >> "controls" >> "GroundContainer" >> "x");
    private _containerY = getNumber(configfile >> "RscDisplayInventory" >> "controls" >> "GroundContainer" >> "y");
    private _containerW = getNumber(configfile >> "RscDisplayInventory" >> "controls" >> "GroundContainer" >> "w");
    private _containerH = getNumber(configfile >> "RscDisplayInventory" >> "controls" >> "GroundContainer" >> "h");
    private _padding = _progressX - _panelX;
    private _panel = _plb_display ctrlCreate["RscBackground", -1];
    _panel ctrlSetBackgroundColor[0.05, 0.05, 0.05, 0.7];
    private _panelX = (_mainX + _mainW) + (_mainX - _panelX - _panelW);
    _panel ctrlSetPosition[_panelX, _panelY, _panelW, _panelH];
    _panel ctrlCommit 0;
    private _loadProgress = _plb_display ctrlCreate["RscProgress", 6501];
    _loadProgress ctrlSetTextColor[0.9, 0.9, 0.9, 0.9];
    _loadProgress ctrlSetPosition[_panelX + _padding, _progressY, _progressW, _progressH];
    _loadProgress progressSetPosition(life_carryWeight / life_maxWeight);
    _loadProgress ctrlCommit 0;
    private _loadFrame = _plb_display ctrlCreate["RscFrame", -1];
    _loadFrame ctrlSetTextColor[1, 1, 1, 1];
    _loadFrame ctrlSetPosition[_panelX + _padding, _progressY, _progressW, _progressH];
    _loadFrame ctrlCommit 0;
    private _loadText = _plb_display ctrlCreate["RscStructuredText", 6502];
    _loadText ctrlSetTextColor[0, 0, 0, 0.7];
    _loadText ctrlSetPosition[_panelX + _padding, _progressY, _progressW, _progressH];
    _loadText ctrlSetStructuredText parseText format["<t align='center'>%1/%2</t>", life_carryWeight, life_maxWeight];
    _loadText ctrlCommit 0;
    private _itemList = _plb_display ctrlCreate["RscListBox", 361001];
    _itemList ctrlSetPosition[_panelX + _padding, _containerY, _containerW, _containerH];
    _itemList ctrlSetBackgroundColor[0, 0, 0, 0];
    _itemList ctrlCommit 0;
    private _quantityInput = _plb_display ctrlCreate["RscEdit", 361002];
    _quantityInput ctrlSetPosition[_panelX + _padding + (_progressW / 1.90), _panelY + _padding, _progressW / 2.10, _progressH];
    _quantityInput ctrlSetText "1";
    _quantityInput ctrlCommit 0;
    private _playerList = _plb_display ctrlCreate["RscCombo", 361003];
    _playerList ctrlSetPosition[_panelX + _padding, _panelY + _padding, _progressW / 2, _progressH];
    _playerList ctrlCommit 0;
    private _buttonGive = _plb_display ctrlCreate["RscButtonMenu", 361004];
    _buttonGive ctrlSetPosition[_panelX + _padding + ((_containerW / 3) * 1), _panelY + _padding + _progressH + (_progressH / 6), _containerW / 3, _progressH];
    _buttonGive ctrlSetText "Give";
    _buttonGive ctrlCommit 0;
    private _buttonUse = _plb_display ctrlCreate["RscButtonMenu", 361005];
    _buttonUse ctrlSetPosition[_panelX + _padding + ((_containerW / 3) * 0), _panelY + _padding + _progressH + (_progressH / 6), _containerW / 3, _progressH];
    _buttonUse ctrlSetText "Use";
    _buttonUse ctrlCommit 0;
    private _buttonDrop = _plb_display ctrlCreate["RscButtonMenu", 361006];
    _buttonDrop ctrlSetPosition[_panelX + _padding + ((_containerW / 3) * 2), _panelY + _padding + _progressH + (_progressH / 6), _containerW / 3, _progressH];
    _buttonDrop ctrlSetText "Drop";
    _buttonDrop ctrlCommit 0;
    private _centerX = getNumber(configfile >> "RscDisplayInventory" >> "controls" >> "BackgroundSlotPrimary" >> "x");
    _offset = _centerX - 0.5; {_x ctrlSetPosition[((ctrlPosition _x) select 0) - _offset, ((ctrlPosition _x) select 1)];
        _x ctrlCommit 0}
    forEach(allControls _plb_display);
    [] spawn {disableSerialization;
        waitUntil {isNull(findDisplay 602)};
        life_virt_open = false};};
private _itemList = _plb_display displayCtrl 361001;
private _quantityInput = _plb_display displayCtrl 361002;
private _playerList = _plb_display displayCtrl 361003;
private _buttonGive = _plb_display displayCtrl 361004;
private _buttonUse = _plb_display displayCtrl 361005;
private _buttonDrop = _plb_display displayCtrl 361006;
if (_newLoad) then {_itemList ctrlAddEventHandler["LBDblClick", "[361001, 361002, false] spawn life_fnc_doubleClickItem"];
    _buttonGive ctrlAddEventHandler["ButtonClick", "(_this select 0) ctrlEnable false; _this spawn life_fnc_giveItem; (_this select 0) ctrlEnable true"];
    _buttonUse ctrlAddEventHandler["ButtonClick", "_this spawn life_fnc_useItem"];
    _buttonDrop ctrlAddEventHandler["ButtonClick", "[] spawn life_fnc_dropItem"];}; {lbClear _x}
forEach[_itemList, _playerList];
if (_plb_display isEqualTo(findDisplay 602)) then {private _progressBar = _plb_display displayCtrl 6501;
    private _progressText = _plb_display displayCtrl 6502;
    _progressBar progressSetPosition(life_carryWeight / life_maxWeight);
    _progressText ctrlSetStructuredText parseText format["<t align='center'>%1/%2</t>", life_carryWeight, life_maxWeight];};
private _players = [];
private _vehicle = vehicle player;
private _units =
if (_vehicle isEqualTo player) then[{player nearEntities["Man", 10]}, {crew _vehicle}]; {
    if !((!isPlayer _x) || (_x isEqualTo player)) then {_players pushBack _x}}
forEach _units; {if ((!isNull _x) && (alive _x) && !(_x getVariable["plb_invisOn", false])) then {
        private _index = _playerList lbAdd format["%1", [name _x] call life_fnc_cleanName];
        if (_isPhone) then {_playerList lbSetTextRight[_index, format["[%1]", side _x]]};
        _playerList lbSetData[_index, getPlayerUID _x];};}
forEach _players; {_x ctrlEnable((lbSize _playerList) >= 1)}
forEach[_playerList, _buttonGive];
if ((lbSize _playerList) >= 1) then {_playerList lbSetCurSel 0}; {_x params["_keys"];
    private _text =
    switch (_forEachIndex) do {case 0: {"Loot Crate Keys"};
        case 1: {"Guardian Crate Keys"};
        case 2: {"Aggressor Crate Keys"};
        case 3: {"Destruction Crate Keys"};
        case 4: {"Revival Crate Keys"};
        case 5: {"Horn Crate 1 Keys"};
        case 6: {"Horn Crate 2 Keys"};
        case 7: {"Crypto Crate Keys"};
        case 8: {"Camo Crate 1 Keys"};
        case 9: {"Camo Crate 2 Keys"};
        case 10: {"Blasphemy Crate Keys"};
        case 11: {"Horn Crate 3 Keys"};
        case 12: {"Retribution Crate Keys"};
        case 13: {"Takeover Crate Keys"};
        case 14: {"Uniform Crate 1 Keys"};
        case 15: {"Vengeance Crate Keys"};
        case 16: {"Futuristic Crate Keys"};
        default {""};}; if (_keys >= 1) then {private _index = _itemList lbAdd format["%1x - %2", [_keys] call life_fnc_numberText, _text];
        _itemList lbSetPicture[_index, "icons\lootcrate_key.paa"];
        _itemList lbSetData[_index, format["cratekey_%1", _forEachIndex]];};}
forEach life_lootKeys; {private _index = _itemList lbAdd format["%1's scalp", _x select 2];
    _itemList lbSetPicture[_index, format["icons\%1.paa", "skull"]];
    _itemList lbSetData[_index, ""];}
forEach life_infamyScalps; {_x params["_item"];
    private _quantity = missionNameSpace getVariable[_x, 0];
    if (_quantity >= 1) then {private _name = ["getName", _item] call life_fnc_virtItemCfg;
        private _short = ["getShortName", _item] call life_fnc_virtItemCfg;
        if ((_short isEqualTo "humanscalp") && ((profileNamespace getVariable["plb_recent_scalp", [0, 0, ""]] select 2) != "")) then {
            _name = format["%1's Scalp", (profileNamespace getVariable["plb_recent_scalp", [0, 0, ""]] select 2)];};
        private _index = _itemList lbAdd format["%1x - %2 ", [_quantity] call life_fnc_numberText, _name];
        _itemList lbSetPicture[_index, ["getIcon", _short] call life_fnc_virtItemCfg];
        _itemList lbSetData[_index, _short];
        _itemList lbSetTooltip[_index, PLB_itemDesc getOrDefault [_item, _name]];   // 0.2.0: hover = chip/hack explainer (same PLB_itemDesc the shop uses); plain items fall back to their name
    };}
forEach([1] call life_fnc_virtItemCfg);