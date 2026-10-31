params[["_function", {}, [{}]], ["_args", []], ["_delay", 0, [0]]];
if (_function isEqualTo {}) exitWith {-1};
private _handle = life_eachFrameHandles pushBack count life_eachFrameHandlerArray;
life_eachFrameHandlerArray pushBack[_function, _args, _delay, diag_tickTime, diag_tickTime, _handle];
_handle