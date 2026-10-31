// LooneyBin: the missing counterpart to fn_addPerFrameHandler. The custom single-EVH scheduler (fn_onEachFrame) had
// NO way to remove a registered per-frame handler -> callers that re-registered (civ position/gear save in fn_initCiv,
// the jewelry-emporium PFHs) ACCUMULATED duplicate handlers across respawns/relogs, firing the same save 2-3x/cycle
// (documented in fn_initCiv.sqf and worked around there with a nil-guard). Ported from the original lineage; uses the
// exact handle contract fn_addPerFrameHandler writes: _handle indexes life_eachFrameHandles, which maps to the slot in
// life_eachFrameHandlerArray (each entry's 6th element is its own handle). Deletes the entry, frees the handle, then
// re-indexes the remaining handles. Deferred through life_fnc_directCall so it's safe to call from inside a frame tick.
params[["_handle", -1, [0]]];
if (_handle < 0) exitWith {false}; [{params["_handle"];
    life_eachFrameHandlerArray deleteAt(life_eachFrameHandles select _handle);
    life_eachFrameHandles set[_handle, nil]; {_x params["", "", "", "", "", "_index"];
        life_eachFrameHandles set[_index, _forEachIndex];} forEach life_eachFrameHandlerArray;
    true}, _handle] call life_fnc_directCall;
