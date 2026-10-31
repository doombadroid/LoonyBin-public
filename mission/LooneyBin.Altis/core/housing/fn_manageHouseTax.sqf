params[["_caseType", "", [""]], ["_data", [], [[]]]];
switch (_caseType) do {case ("taxMenu"): {if !(SRV_HousesSetup) exitWith {
                ["Please wait a bit while houses are being initalized...", "basic"] spawn life_fnc_handleMessage;};
            if (life_houseTxn) exitWith {["You are currently in the process of paying house taxes.", "basic"] spawn life_fnc_handleMessage;
            };
            if (playerSide != civilian) exitWith {};
            if (life_houses isEqualTo[]) exitWith {};
            if (serverRestartLock) exitWith {
                ["You cannot pay your tax right now. Try again after the restart!", "basic"] spawn life_fnc_handleMessage;};
            createDialog "life_housetax_menu";
            waitUntil {!isNull(findDisplay 13000)};
            disableSerialization;
            private _plb_display = findDisplay 13000;
            private _houseTaxTitle = _plb_display displayCtrl 13001;
            private _houseTaxList = _plb_display displayCtrl 13002;
            private _houseTaxInfo = _plb_display displayCtrl 13003;
            private _houseTaxPrice = _plb_display displayCtrl 13004;
            private _houseButtonPaySel = _plb_display displayCtrl 13005;
            private _houseButtonPayAll = _plb_display displayCtrl 13006;
            [_plb_display] spawn life_fnc_p_updateMenu;
            _houseButtonPaySel ctrlEnable false;
            _houseButtonPayAll ctrlEnable false;
            _houseTaxTitle ctrlSetStructuredText parseText "<t size='0.90' align='center'>House Taxes</t>";
            ["taxMenuPopulate"] call life_fnc_manageHouseTax;
            _houseTaxPrice ctrlSetStructuredText parseText "<t size='0.90' align='center'>Current Tax Price: N/A</t>";
            _houseTaxInfo ctrlSetStructuredText parseText format["<t size='0.7' align='center'>Select a house to see tax information.</t>"];
            _houseTaxList ctrlSetEventHandler["LBSelChanged", "['taxMenuSelected'] call life_fnc_manageHouseTax"];
            _houseButtonPaySel ctrlSetEventHandler["ButtonClick", "['taxPaySelected'] spawn life_fnc_manageHouseTax"];
            _houseButtonPayAll ctrlSetEventHandler["ButtonClick", "['taxPayALL'] spawn life_fnc_manageHouseTax"];
            _houseButtonPayAll ctrlEnable true;}; case ("taxMenuPopulate"): {disableSerialization;
                private _plb_display = findDisplay 13000;
                if (isNull _plb_display) exitWith {};
                private _houseTaxList = _plb_display displayCtrl 13002;
                lbClear _houseTaxList;
                life_taxHouses = []; {private _pos = parseSimpleArray(_x select 0);
                    // owner 2026-07-09: houseTypes-filtered resolve (twin of fn_CLinitHouses) -- the raw select 0
                    // could grab the hidden coincident derelict at a replaced-shed spot, and the old House_F guard
                    // then skipped the row entirely (sheds aren't reliably House_F) = owned shed missing from the
                    // tax menu / listed as "unfinished".
                    private _houses = nearestObjects[_pos, ["House"], 18, true];
                    if !(_houses isEqualTo[]) then {
                        private _houseObject = (_houses select { (typeOf _x) in life_houseTypes }) param [0, (_houses select 0)];
                        if !((_houseObject isKindOf "House_F") || {(typeOf _houseObject) in life_houseTypes}) exitWith {};
                        private _displayName = getText(configFile >> "CfgVehicles" >> (typeOf _houseObject) >> "displayName");
                        private _distance = [round(player distance _houseObject)] call life_fnc_numberText;
                        private _index = _houseTaxList lbAdd format["%1 - %2m", _displayName, _distance];
                        life_taxHouses pushBack _houseObject;};}
                forEach life_houses;};
        case ("taxMenuSelected"): {private _plb_display = findDisplay 13000;
                if (isNull _plb_display) exitWith {};
                private _houseTaxList = _plb_display displayCtrl 13002;
                private _houseTaxInfo = _plb_display displayCtrl 13003;
                private _houseTaxPrice = _plb_display displayCtrl 13004;
                private _houseButtonPaySel = _plb_display displayCtrl 13005;
                _houseButtonPaySel ctrlEnable false;
                _houseTaxInfo ctrlSetStructuredText parseText "";
                _houseTaxPrice ctrlSetStructuredText parseText "<t size='0.90' align='center'>Current Tax Price: N/A</t>";
                private _houseObject = life_taxHouses select(lbCurSel _houseTaxList);
                if (isNull _houseObject) exitWith {};
                private _houseData = _houseObject getVariable["plb_house_tax", []];
                if !(_houseData isEqualTo[]) then {_houseData params["_overdue", "_canPayTax", "_playtime", "_lastPayed"];
                    private _houseStatus = call {if (_overdue && _lastPayed > 32) exitWith {"Overdue (+20%)"};
                        if (_overdue) exitWith {"Overdue"};
                        if (_canPayTax) exitWith {"Paid - Can pay tax"};
                        if (true) exitWith {"Paid"};};
                    _houseTaxInfo ctrlSetStructuredText parseText format["<t size='0.8'>House Status: %1<br/>Last tax paid: %2 day(s) ago<br/>Playtime recorded: %3 minute(s)</t>", _houseStatus, _lastPayed, _playtime];
                    if (_canPayTax) then {private _taxPrice = ["calculateTax", [_houseObject]] call life_fnc_manageHouseTax;
                        if (_taxPrice <= 0) exitWith {
                            _houseTaxInfo ctrlSetStructuredText parseText "<t size='0.8'>Something went wrong.</t>";};
                        _houseTaxPrice ctrlSetStructuredText parseText format["<t size='0.90' align='center'>Current Tax Price: $%1</t>", [_taxPrice] call life_fnc_numberText];
                        _houseButtonPaySel ctrlEnable true;};} else {
                    _houseTaxInfo ctrlSetStructuredText parseText "<t size='0.8'>No data found yet.</t>";};};
        case ("calculateTax"): {_data params[["_houseObject", objNull, [objNull]]];
                private _return = 0;
                if (isNull _houseObject) exitWith {0};
                private _houseData = _houseObject getVariable["plb_house_tax", []];
                if (_houseData isEqualTo[]) exitWith {0};
                private _houseType = typeOf _houseObject;
                private _houseConfig = [_houseType] call life_fnc_houseConfig;
                if (_houseConfig isEqualTo[]) exitWith {0};
                private _upkeep = _houseConfig select 4;
                _houseData params["_overdue", "_canPayTax", "_playtime", "_lastPayed"];
                if (_lastPayed <= 0) exitWith {0};
                private _reduction = 1;
                private _houseCount = count life_houses;
                private _playtimeHours = _playtime / 60;
                private _timeArrayConfig = [[1.0, 0.9, 0.8, 0.6, 0.4, 0.25], [1.2, 1.2, 1.1, 1.1, 1.0, 1.0, 0.8, 0.6, 0.5, 0.4, 0.25],
                    [1.3, 1.3, 1.2, 1.2, 1.1, 1.1, 1.0, 0.9, 0.8, 0.6, 0.5, 0.4, 0.4, 0.3, 0.3, 0.25],
                    [1.5, 1.5, 1.5, 1.4, 1.4, 1.4, 1.3, 1.3, 1.2, 1.1, 1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.4, 0.3, 0.3, 0.25],
                    [2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 1.9, 1.8, 1.7, 1.6, 1.5, 1.4, 1.3, 1.2, 1.1, 1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.4, 0.3, 0.3, 0.25]
                ];
                private _selectTimeConfig = _timeArrayConfig select(_houseCount - 1);
                private _selectReduction = floor _playtimeHours;
                if (_selectReduction > ((count _selectTimeConfig) - 1)) then {_reduction = 0.25;} else {
                    _reduction = _selectTimeConfig select _selectReduction;};
                if (_reduction < 0.25) then {_reduction = 0.25;};
                if (_reduction > 2.0) then {_reduction = 2.0;};
                if (_overdue && _lastPayed > 32) then {_reduction = _reduction + 0.2;};
                private _houseTax = _lastPayed * _upkeep * _reduction;
                if (210 in life_side_talents) then { _houseTax = _houseTax * 0.6; };   // HOMESTEADER -40% property tax
                _return = _houseTax;
                _return;};
        case ("taxPaySelected"): {private _plb_display = findDisplay 13000;
                if (isNull _plb_display) exitWith {};
                private _houseTaxList = _plb_display displayCtrl 13002;
                private _houseButtonPaySel = _plb_display displayCtrl 13005;
                _houseButtonPaySel ctrlEnable false;
                if (life_taxHouses isEqualTo[]) exitWith {};
                if ((lbCurSel _houseTaxList) isEqualTo - 1) exitWith {
                    ["You did not select a house.", "basic"] spawn life_fnc_handleMessage;};
                private _houseObject = life_taxHouses select(lbCurSel _houseTaxList);
                if (isNull _houseObject) exitWith {};
                private _houseID = _houseObject getVariable["plb_houseID", -1];
                if (_houseID isEqualTo - 1) exitWith {};
                private _houseData = _houseObject getVariable["plb_house_tax", []];
                if (_houseData isEqualTo[]) exitWith {};
                _houseData params["_overdue", "_canPayTax", "_playtime", "_lastPayed"];
                if (!_canPayTax) exitWith {};
                private _taxPrice = ["calculateTax", [_houseObject]] call life_fnc_manageHouseTax;
                if (_taxPrice <= 0) exitWith {["Something went wrong!", "basic"] spawn life_fnc_handleMessage;};
                private _action = [format["You are going to pay $%1 tax for the selected house. Are you sure you want to continue?", [_taxPrice] call life_fnc_numberText], "Pay House Tax", "Yes", "No"] call BIS_fnc_GUIMessage;
                if !(_action) exitWith {["You decided not to pay.", "basic"] spawn life_fnc_handleMessage;};
                if (serverRestartLock) exitWith {
                    ["You cannot pay your tax right now. Try again after the restart!", "basic"] spawn life_fnc_handleMessage;};
                if (life_atmcash < _taxPrice) exitWith {["You can't afford to pay the house tax!", "basic"] spawn life_fnc_handleMessage;};
                if (life_houseTxn) exitWith {
                    ["You are currently in the process of paying house taxes.", "basic"] spawn life_fnc_handleMessage;};
                life_houseTxn = true;
                closeDialog 0;
                life_atmcash = life_atmcash - _taxPrice;
                life_atmcashCacheB = ((life_atmcash / 4) + 11);
                [1] call life_fnc_ClupdatePartial;
                ["Sending tax to the Altis Realtor...", "basic"] spawn life_fnc_handleMessage; [
                    ["paySingleHouse", [player, _houseObject, _houseID]], "TON_fnc_houseTaxSRV", 2] call life_fnc_MP; [
                    ["-HOUSETAX-", player, profileName, format["paid $%1 house tax for house id: %2", [_taxPrice] call life_fnc_numberText, _houseID]], "TON_fnc_logIt", 2] call life_fnc_MP;
                ["buy", "housetax", _taxPrice] spawn life_fnc_handleQuest;};
        case ("taxPayALL"): {if (life_taxHouses isEqualTo[]) exitWith {};
                private _taxHouses = [];
                private _taxPriceTotal = 0;
                private _houseIDLog = ""; {private _houseObject = _x;
                    if (!isNull _houseObject) then {private _houseID = _houseObject getVariable["plb_houseID", -1];
                        if (_houseID isEqualTo - 1) exitWith {};
                        private _houseData = _houseObject getVariable["plb_house_tax", []];
                        if (_houseData isEqualTo[]) exitWith {};
                        _houseData params["_overdue", "_canPayTax", "_playtime", "_lastPayed"];
                        if (!_canPayTax) exitWith {};
                        private _taxPrice = ["calculateTax", [_houseObject]] call life_fnc_manageHouseTax;
                        if (_taxPrice <= 0) exitWith {};
                        _taxPriceTotal = _taxPriceTotal + _taxPrice;
                        _taxHouses pushBack[_houseObject, _houseID];
                        if (_houseIDLog isEqualTo "") then {_houseIDLog = format["%1", _houseID];} else {
                            _houseIDLog = _houseIDLog + format[", %1", _houseID];};};}
                forEach life_taxHouses;
                if (_taxHouses isEqualTo[] || _taxPriceTotal <= 0) exitWith {
                    ["You do not have any houses that can pay tax yet.", "basic"] spawn life_fnc_handleMessage;};
                private _action = [format["You are going to pay $%1 for %2 house(s) that needs to pay tax. Are you sure you want to continue?", [_taxPriceTotal] call life_fnc_numberText, count _taxHouses], "Pay House Tax", "Yes", "No"] call BIS_fnc_GUIMessage;
                if !(_action) exitWith {["You decided not to pay.", "basic"] spawn life_fnc_handleMessage;};
                if (serverRestartLock) exitWith {
                    ["You cannot pay your tax right now. Try again after the restart!", "basic"] spawn life_fnc_handleMessage;};
                if (life_atmcash < _taxPriceTotal) exitWith {
                    ["You can't afford to pay the house tax!", "basic"] spawn life_fnc_handleMessage;};
                if (life_houseTxn) exitWith {
                    ["You are currently in the process of paying house taxes.", "basic"] spawn life_fnc_handleMessage;};
                life_houseTxn = true;
                closeDialog 0;
                life_atmcash = life_atmcash - _taxPriceTotal;
                life_atmcashCacheB = ((life_atmcash / 4) + 11);
                [1] call life_fnc_ClupdatePartial;
                ["Sending tax to the Altis Realtor...", "basic"] spawn life_fnc_handleMessage; [
                    ["payAllHouses", [player, _taxHouses]], "TON_fnc_houseTaxSRV", 2] call life_fnc_MP; [
                    ["-HOUSETAX-", player, profileName, format["paid $%1 house tax for house ids: %2", [_taxPriceTotal] call life_fnc_numberText, _houseIDLog]], "TON_fnc_logIt", 2] call life_fnc_MP;
                ["buy", "housetax", _taxPriceTotal] spawn life_fnc_handleQuest;};
        case "houseTaxReminder": {_data params[["_warningCount", 0, [0]]];
                if (_warningCount isEqualTo 0) exitWith {};
                waitUntil {!isNil "life_quitWelcomeUI" && {life_quitWelcomeUI}};
                uiSleep 10;
                private _message = format["House Tax: %1 house(s) require tax attention. Open the Housing app on your phone to pay the house tax.", _warningCount];
                [_message, "warning"] spawn life_fnc_handleMessage;
                systemChat _message;};
        case "houseTaxAccess": {
                ["This house has tax overdue, house tax has to be paid to gain access again.", "basic"] spawn life_fnc_handleMessage;};
        default {};};