if ((call life_adminLevel) <= 1) exitWith {closeDialog 0;};
params[["_toMe", false, [false]], ["_toThem", false, [false]]];
if (_toMe || _toThem) exitWith {private _unit = missionNamespace getVariable(lbData[12901, lbCursel 12901]);
    if (isNil "_unit") exitWith {};
    if (isNull _unit || {_unit isEqualTo player}) exitWith {};
    if (_toMe) then {(vehicle _unit) setPosATL(getPosATL player);
        if (_unit getVariable["plb_timeTrialActive", false]) then {_unit setVariable['plb_timeTrialActive', false, true];}; [
            ["-ADMINACTION-", player, profileName, format["TPed %1 (%2) to self. Nearby players: %3.", name _unit, getPlayerUID _unit, (allPlayers select {
                _x distance player < 100}) apply {name _x}]], 'TON_fnc_logIt', 2, false, false] spawn life_fnc_MP;} else {
        player setPosATL(getPosATL vehicle _unit); [
            ["-ADMINACTION-", player, profileName, format["TPed to %1 (%2). Nearby players: %3.", name _unit, getPlayerUID _unit, (allPlayers select {
                _x distance player < 100}) apply {name _x}]], 'TON_fnc_logIt', 2, false, false] spawn life_fnc_MP;};};
[] spawn {while {dialog}
    do {closeDialog 0;
        uiSleep 0.05;};};
if !("itemMap" in (assignedItems player)) then {player addItem "itemMap";
    player assignItem "itemMap";};
openMap[true, false];
onMapSingleClick "
	private '_action';
	[_pos select 0, _pos select 1, _pos select 2] spawn{
		_action = ['Are you sure you want to teleport to this location?','Teleport Warning','Yes','No'] call BIS_fnc_guiMessage;
		if (_action) then {
			_plb_pos = [_this select 0, _this select 1, _this select 2];
			(vehicle player) setPos [_plb_pos select 0, _plb_pos select 1, 0];
			onMapSingleClick '';
			openMap [false, false];

			_nearPlayersString = '( Near units: ';

			{
				if (_x distance vehicle player < 800) then {
					_nearPlayersString = format['%3 [%1 _ %2m] -', _x getVariable ['plb_name',name _x], _x distance vehicle player, _nearPlayersString];
				};
			} forEach playableUnits;

			_nearPlayersString = _nearPlayersString + ')';

			[['-ADMINACTION-', player, (profileName), format ['Tped to Map Pos: %1 - Near Players: %2.', _plb_pos, _nearPlayersString]], 'TON_fnc_logIt', 2, false, false] spawn life_fnc_MP;
		};
	};
	true";
waitUntil {!visibleMap};
onMapSingleClick "";