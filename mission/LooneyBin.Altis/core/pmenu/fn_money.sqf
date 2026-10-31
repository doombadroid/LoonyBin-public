disableSerialization;
private _newLoad =
if (isNull(findDisplay 341000)) then {createDialog "Life_money_menu";
    waitUntil {!isNull(findDisplay 341000)};
    [findDisplay 341000] spawn life_fnc_p_updateMenu;
    true} else {false};
private _display = findDisplay 341000;
private _moneyInfo = _display displayCtrl 341001;
private _moneyInput = _display displayCtrl 341002;
private _playerList = _display displayCtrl 341003;
private _giveMoney = _display displayCtrl 341004;
lbClear _playerList;
_giveMoney ctrlEnable true;
private _governorTaxRate = SRV_governorData param[2, 0];
private _taxRate = (call life_fnc_getGovTax) * 100;
private _richTaxRate = _taxRate - _governorTaxRate;
if (_richTaxRate < 0) then {_richTaxRate = 0;};
if (playerSide isEqualTo civilian) then {
    _moneyInfo ctrlSetStructuredText parseText format["<br/><t align='center'><img size='2' image='icons\bank.paa'/><br/><t size='1.25'>$%1</t><br/><br/><img size='2' image='icons\money.paa'/><br/><t size='1.25'>$%2</t><br/><br/><img size='2' image='icons\newdrachma.paa'/><br/><t size='1.25'>%5 ND</t><br/>Governor Tax Rate: %3%4 (+%6%4)<br/><br/><t size='1.25'>Prestige</t><br/><t size='1.25'>%7</t>", [life_atmcash] call life_fnc_numberText, [life_cash] call life_fnc_numberText, _governorTaxRate, format["%1", "%"], [life_ndStr] call PLB_fnc_ndText, _richTaxRate, [life_prestige] call life_fnc_numberText];   // NEW DRACHMA: exact string balance, trimmed
} else {
    _moneyInfo ctrlSetStructuredText parseText format["<br/><t align='center'><img size='2' image='icons\bank.paa'/><br/><t size='1.25'>$%1</t><br/><br/><img size='2' image='icons\money.paa'/><br/><t size='1.25'>$%2</t><br/>Governor Tax Rate: %3%4 (+%5%4)<br/><br/><t size='1.25'>Prestige</t><br/><t size='1.25'>%6</t></t>", [life_atmcash] call life_fnc_numberText, [life_cash] call life_fnc_numberText, _governorTaxRate, format["%1", "%"], _richTaxRate, [life_prestige] call life_fnc_numberText];
};
private _players = [];
private _vehicle = vehicle player;
private _units =
if (_vehicle isEqualTo player) then[{player nearEntities["Man", 10]}, {crew _vehicle}]; {
    if !((!isPlayer _x) || (_x isEqualTo player)) then {_players pushBack _x}}
forEach _units; {if ((!isNull _x) && (alive _x)) then {private _index = _playerList lbAdd format["%1", [name _x] call life_fnc_cleanName];
        _playerList lbSetTextRight[_index, format["[%1]", side _x]];
        _playerList lbSetData[_index, getPlayerUID _x];};}
forEach _players;
if (_newLoad) then {_giveMoney ctrlAddEventHandler["ButtonClick", "_this spawn life_fnc_giveMoney"]};
if ((lbSize _playerList) >= 1) then {_playerList lbSetCurSel 0} else {{_x ctrlEnable false}
    forEach[_playerList, _moneyInput, _giveMoney]};