private _actionDisplayText = _this select 4;
private _handled = false;
_handled =
switch (_actionDisplayText) do {default {_handled};
}; if (player getVariable["plb_restrained", false] || player getVariable["plb_downed", false]) then {_handled = true;};
if ((call life_adminLevel) >= 2) then {_handled = false;};
_handled;