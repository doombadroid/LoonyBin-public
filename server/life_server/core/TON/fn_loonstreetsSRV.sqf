/*
    TON_fnc_loonstreetsSRV  (LooneyBin, owner 2026-07-15) -- loonstreets.com data feed.
    Server-only. Every 5 min (init loop) rebuild + publicVariable PLB_loonstreets:
      [ [fortWinnerName, fortActive], [[turfId, gangName], ...], [[gangName, bank, xp], ...top 8 by xp] ]
    Names are plain varchars -> QUOTE() on read (the shed-ownership footgun rule).
*/
if (!isServer) exitWith {};

private _fortRows = ["SELECT QUOTE(COALESCE(winner_name,'')), active FROM gangfort WHERE id=1", 2, true] call DB_fnc_asyncQuery;
private _fort = ["", 0];
if (_fortRows isEqualType [] && {(count _fortRows) > 0}) then {
    _fort = [format ["%1", (_fortRows select 0) param [0, ""]], parseNumber (format ["%1", (_fortRows select 0) param [1, 0]])];};

private _turfRows = ["SELECT t.id, QUOTE(COALESCE(g.name,'')) FROM turf t LEFT JOIN gangs g ON g.id = t.gang ORDER BY t.id", 2, true] call DB_fnc_asyncQuery;
private _turfs = [];
if (_turfRows isEqualType []) then {
    { _turfs pushBack [parseNumber (format ["%1", _x param [0, 0]]), format ["%1", _x param [1, ""]]]; } forEach _turfRows;};

private _gangRows = ["SELECT QUOTE(name), bank, experience FROM gangs ORDER BY experience DESC LIMIT 8", 2, true] call DB_fnc_asyncQuery;
private _gangs = [];
if (_gangRows isEqualType []) then {
    { _gangs pushBack [format ["%1", _x param [0, ""]], parseNumber (format ["%1", _x param [1, 0]]), parseNumber (format ["%1", _x param [2, 0]])]; } forEach _gangRows;
};

PLB_loonstreets = [_fort, _turfs, _gangs];
publicVariable "PLB_loonstreets";
