if (!isNull(uiNamespace getVariable["life_message_hud", displayNull])) exitWith {true};
10 cutRsc["life_message_hud", "PLAIN"];
private _display = uiNamespace getVariable["life_message_hud", displayNull];
life_message_active = scriptNull;
life_message_list = [];
!isNull _display;