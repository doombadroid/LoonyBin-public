// life_fnc_createDispatch (LooneyBin compat) -- MIRROR of server/life_server/core/wantedsys/fn_createDispatch.sqf
// FIX 2026-07-18 (compat-stub shadow): this file shipped as a reverse-drift no-op stub
// (`if (true) exitWith {};`). Because the mission ALSO registers life_fnc_createDispatch, the no-op
// SHADOWED the real @life_server impl on the server (mission CfgFunctions wins) -> every
// server-internal call silently did nothing -> cops got NO APD dispatch alerts/pings for prison-break, bank vault drill, federal reserve, or store robberies (life_dispatchTasks never populated).
// Restored to the real impl. The isServer guard makes it a safe no-op on clients (which lack
// the server-authoritative vars); all real callers are server-internal. Keep in sync w/ the twin.
if (!isServer) exitWith {};
 
private["_id","_desc","_value","_chance"]; 
 
_id = [_this,0,0,[0]] call BIS_fnc_param; 
_desc = [_this,1,"",[""]] call BIS_fnc_param; 
_value = [_this,2,0,[0]] call BIS_fnc_param; 
_chance = [_this,3,0,[0]] call BIS_fnc_param; 
_maxCops = [_this,4,4,[0]] call BIS_fnc_param; 
_position = [_this,5,[0,0,0],[[]]] call BIS_fnc_param; 
_unitUID = [_this,6,"",[""]] call BIS_fnc_param; 
 
if (isNull life_dispatcher && _unitUID == "") then {{if (side _x == west) then {
[[_id,_desc,_value,_position], "life_fnc_newDispatch", _x, false] spawn life_fnc_MP;};} forEach allPlayers;};
 
life_dispatchTasks pushBack [_id,_desc,_value,_maxCops,[],_position,_unitUID]; 
if (!isNull life_dispatcher) then { (life_dispatcher getVariable ["ownerID", -1]) publicVariableClient "life_dispatchTasks" };