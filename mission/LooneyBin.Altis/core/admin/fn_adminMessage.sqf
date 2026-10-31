#include "..\..\macro.h"
/*
    life_fnc_adminMessage  (LooneyBin: admin -> ALL players message)
    The display side (clientMessage / handleMessage "adminall") existed, but nothing ever SENT it
    (deobf gap -- clientMessage type 5 had no caller). This wires the send: prompt the admin, then
    broadcast through life_fnc_broadcast (client->all, already CfgRE-whitelisted via the death-message
    path) using new broadcast type 3 -> handleMessage "adminall" (big red box + ping). Staff-gated.
*/
if ((call life_adminLevel) < 2) exitWith { ["Admin Message is staff-only.", "basic"] spawn life_fnc_handleMessage; };
closeDialog 0;
uiSleep 0.2;
["<t align='center'>Enter the message to send to ALL players.</t>", "Admin Message", "Send"] call life_fnc_inputMenu;
private _msg = life_input_response;
life_input_response = "";
if (_msg isEqualTo "") exitWith {};
[[profileName, _msg], "TON_fnc_adminMsg", 2] spawn life_fnc_MP;   // server relays it as a privileged "Admin Message" (server-origin -> passes handleMessage's adminall anti-spoof gate; client broadcast would be blocked/spoofable)
[format ["Admin message sent to all players: %1", _msg], "basic"] spawn life_fnc_handleMessage;
