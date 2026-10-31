/*
    TON_fnc_gangGarageCount  (LooneyBin: gang-garage count adapter)
    client args: [gangID, player, uid]
    Push the gang's owned-vehicle count to the client as life_gangGarageCount.
    Was: parseNumber on a pre-typed COUNT(*) col + delivered via life_fnc_MP (which runs a
    FUNCTION, but life_gangGarageCount is a VARIABLE -> no-op). Now counts rows + publicVariableClient
    (same proven path as fn_garageCount / life_garageCount).
*/
params [["_gangID",-1,[0]],["_player",objNull,[objNull]],["_uid","",[""]]];
if (_gangID < 0 || isNull _player) exitWith {};
private _rows = [format ["SELECT id FROM gang_vehicles WHERE gang_id='%1'", _gangID], 2, true] call DB_fnc_asyncQuery;
private _count = if (isNil "_rows" || {!(_rows isEqualType [])}) then { 0 } else { count _rows };
// fn_gangGarageAdd sets `life_garageCount = -1` then waitUntil's on it (NOT life_gangGarageCount) —
// set that one or the transfer hangs forever. Set both so any other consumer is covered too.
life_garageCount = _count;
life_gangGarageCount = _count;
(owner _player) publicVariableClient "life_garageCount";
(owner _player) publicVariableClient "life_gangGarageCount";
