params[["_state", true, [true]]];
if !(isNull objectParent player) exitWith {};
if (!_state && !isNull life_object_inhand) exitWith {};
if (_state) then {player action["hideWeapon", player, player, 100];} else {player action["hideWeapon", player, player, 0];};
life_holstered = _state;