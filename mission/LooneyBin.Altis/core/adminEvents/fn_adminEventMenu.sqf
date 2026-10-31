#include "..\..\macro.h"
showChat true;   // LooneyBin 2026-07-23: self-heal a prior stranded showChat false (see fn_adminMenu note)
disableSerialization;
createDialog "life_admin_event_menu";
if ((call life_adminLevel) <= 2) exitWith {closeDialog 0;};
waitUntil {!isNull(findDisplay 3900)};
private _display = findDisplay 3900;
private _eventList = _display displayCtrl 3901;
private _eventLocationsList = _display displayCtrl 3902;
showChat false;
private _eventData = ["getEvents"] call life_fnc_eventCfg;
lbClear _eventList;
private _index = -1; {if (_x select 4 && (call life_adminLevel) < 4) then {Continue};
    _index = _eventList lbAdd format["%1", _x select 1];
    _eventList lbSetData[_index, str(_x select 0)];}
forEach _eventData; [
    ["-ADMINACTION-", player, (profileName), format["accessed the admin event menu."]], "TON_fnc_logIt", 2, false, false] spawn life_fnc_MP;
waitUntil {isNull _display};
showChat true;