/*
    TON_fnc_insertGang  (LooneyBin: 2020 name-based gang creation)
    2020 client args : [player, gangName]   (fn_createGang)
    Creates a name-based gang (the 2017 file was house/building-based + used KRON_Replace, a MISSION-only
    fn undefined on the server -> insertGang threw -> gang never created). Now: unique-name check -> gen a
    gang id -> INSERT gangs row -> set creator's gang0/gangrank0 (+ deduct the $25k fee from the bank) ->
    push to the client via life_fnc_gangCreated (sets life_gang_data + deducts life_atmcash for display).
*/
if (life_server_training) exitWith {};
params [["_player", objNull, [objNull]], ["_name", "", [""]]];
if (isNull _player || _name == "") exitWith {};
private _uid = getPlayerUID _player;
if (_uid == "") exitWith {};

// KRON_Replace is mission-only; SQF has no string-minus operator. Strip unsafe chars (\ ' ") by
// splitting on each (they become dropped delimiters) then rejoining.
private _safeName = (_name splitString "\'""") joinString "";
if (_safeName == "") exitWith {};

// name already taken?
private _row = [format ["SELECT id FROM gangs WHERE name='%1' AND instance='%2'", _safeName, life_server_instance], 2] call DB_fnc_asyncQuery;
if (!isNil "_row" && {!(_row isEqualTo [])}) exitWith {
    [[1, "There is already an existing gang using the name which you provided."], "life_fnc_broadcast", _player, false] spawn life_fnc_MP;
};

// next free gang id (numeric col -> compiles clean, no QUOTE needed)
private _idRow = [format ["SELECT COALESCE(MAX(id),0)+1 FROM gangs"], 2] call DB_fnc_asyncQuery;
private _gangId = if (isNil "_idRow" || {_idRow isEqualTo []}) then { 1 } else { parseNumber (format ["%1", _idRow select 0]) };
if (_gangId < 1) then { _gangId = 1; };

[format ["INSERT INTO gangs (id, name, inviterank, kickrank, bank, experience, instance) VALUES ('%1','%2','2','2','0','0','%3')", _gangId, _safeName, life_server_instance]] call DB_fnc_asyncQuery;
[format ["UPDATE players SET gang0='%1', gangrank0='1', bankacc=GREATEST(CAST(bankacc AS SIGNED)-25000,0) WHERE playerid='%2'", _gangId, _uid]] call DB_fnc_asyncQuery;

[[group _player, _safeName, _gangId], "life_fnc_gangCreated", _player, false] spawn life_fnc_MP;
