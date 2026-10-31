#include "..\..\macro.h"
disableSerialization;
closeDialog 0;
waitUntil {isNull(findDisplay 2900)};
waitUntil {isNull(findDisplay 90000)};
createDialog "life_smartphone";
waitUntil {!isNull(findDisplay 90000)};
private _display = findDisplay 90000;
private _buttonIndex = 0;
private _allHidden = [];
private _globalBackground = _display displayCtrl 90001;
_allHidden pushBack _globalBackground;
life_phone_buttons_fav = [];
profileNamespace setVariable ["PLB_favApps_v2", []];
saveProfileNamespace;
["Select up to 4 Apps to favorite!", "basic"] spawn life_fnc_handleMessage;
private _globalButtons = [["Sync", "icons\phone_sync.paa", "[] call life_fnc_syncData", {true
    }, "Update server with your current character data"], ["Money", "icons\phone_money.paa", "[] spawn life_fnc_money", {true
    }, "Trade your cash on hand"], ["Message", "icons\phone_message.paa", "[] spawn life_fnc_cellphone", {true
    }, "Send text messages to other players"], ["Inventory", "icons\phone_inventory.paa", "[true, true] spawn life_fnc_inventory", {true
    }, "View your virtual inventory"]];
private _allButtons = +life_phone_buttons;
_allButtons append _globalButtons; {_x params["_text", "_image", "_function", "_condition", "_tooltip"];
    if (call _condition) then {private _button = _display displayCtrl(90200 + _buttonIndex);
        _buttonIndex = _buttonIndex + 1;
        _allHidden pushBack _button;
        _button ctrlSetFade 1;
        _button ctrlCommit 0;
        _button ctrlSetTooltip _tooltip;
        _button setVariable["data", _text];
        _button ctrlAddEventHandler["ButtonClick", "_this call life_fnc_setFavApp;"];
        _button ctrlSetStructuredText parseText format["<t align='center' shadow='0'><img size='2' image='%2' /><br /><t size='0.65'>%1</t></t>", _text, _image];
    };}
forEach _allButtons;
private _buttonIndex = 0;
[_display] spawn life_fnc_p_updateMenu; {_x ctrlShow true;
    _x ctrlSetFade 0;
    _X ctrlCommit 0.10;}
forEach _allHidden;
[] call life_fnc_calTalents;