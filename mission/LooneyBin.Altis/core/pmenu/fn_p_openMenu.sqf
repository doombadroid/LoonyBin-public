#include "..\..\macro.h"
if (!isNull(findDisplay 90000)) exitWith {closeDialog 0};
if ((!alive player) || (dialog)) exitWith {};
if ((player getVariable["plb_restrained", false]) && (call(life_adminLevel) <= 1)) exitWith {
    ["You cannot access your phone because your hands are restrained", "basic"] spawn life_fnc_handleMessage};
disableSerialization;
["life_smartphone"] call life_fnc_createDialog;
waitUntil {!isNull(findDisplay 90000)};
private _display = findDisplay 90000;
private _PhoneButtons = +life_phone_buttons;
private _buttonIndex = 0;
private _allHidden = [];
private _phoneAppsArray = [];
private _globalBackground = _display displayCtrl 90001;
_allHidden pushBack _globalBackground;
private _globalButtons = [["Sync", "icons\deck_sync.paa", "[] call life_fnc_syncData", {true
    }, "Update server with your current character data"], ["Money", "icons\deck_money.paa", "[] spawn life_fnc_money", {true
    }, "Trade your cash on hand"], ["Message", "icons\deck_message.paa", "[] spawn life_fnc_cellphone", {true
    }, "Send text messages to other players"], ["Inventory", "icons\deck_inventory.paa", "[true, true] spawn life_fnc_inventory", {true
    }, "View your virtual inventory"]];
// owner 2026-07-20: REBUILD favourites from the profile every open, by NAME, resolved against the LIVE
// app lists. Previously the whole entry (action + condition code) was frozen into profileNamespace, so a
// favourited app kept coming back with its old name, old gate and old action no matter what shipped --
// e.g. ICEBREAKER OS sticking on an APD phone. Unknown names (removed/renamed apps) are simply dropped.
life_phone_buttons_fav = []; {private _want = toUpper _x;
    private _hit = (life_phone_buttons + _globalButtons) select { (toUpper (_x select 0)) isEqualTo _want };
    if !(_hit isEqualTo []) then { life_phone_buttons_fav pushBackUnique (_hit select 0); };
} forEach (profileNamespace getVariable ["PLB_favApps_v2", []]);

private _length = count life_phone_buttons_fav;
if (_length > 0) then {_favApps = life_phone_buttons_fav; {_x params["_text"];
        toUpper _text;
        private _count = 0; {_x params["_compareText"];
            if (_text == _compareText) then {_PhoneButtons deleteAt _count;};
            _count = _count + 1;}
        forEach _PhoneButtons; {_x params["_text"];
            private _button = _x;
            toUpper _text; {_x params["_compareText"];
                if (_text == _compareText) then {toUpper _compareText;
                    _phoneAppsArray pushBackUnique _compareText;};}
            forEach life_phone_buttons_fav;
            if ((_phoneAppsArray find _text) == -1) then {_PhoneButtons pushBackUnique _x;};}
        forEach _globalButtons;}
    forEach life_phone_buttons_fav;
    _globalButtons = +life_phone_buttons_fav;}; {_x params["_text", "_image", "_function", "_condition", "_tooltip"];
    if (call _condition) then {private _button = _display displayCtrl(90100 + _buttonIndex);
        _buttonIndex = _buttonIndex + 1;
        _allHidden pushBack _button;
        _button ctrlSetFade 1;
        _button ctrlCommit 0;
        _button ctrlSetTooltip _tooltip;
        _button ctrlAddEventHandler["ButtonClick", _function];
        _button ctrlSetStructuredText parseText format["<t align='center' shadow='0'><img size='2' image='%2' /><br /><t size='0.65'>%1</t></t>", _text, _image];
    };}
forEach _globalButtons;
private _buttonIndex = 0; {_x params["_text", "_image", "_function", "_condition", "_tooltip"];
    if (call _condition) then {private _button = _display displayCtrl(90200 + _buttonIndex);
        _buttonIndex = _buttonIndex + 1;
        _allHidden pushBack _button;
        _button ctrlSetFade 1;
        _button ctrlCommit 0;
        _button ctrlSetTooltip _tooltip;
        _button ctrlSetStructuredText parseText format["<t align='center' shadow='0'><img size='2' image='%2' /><br /><t size='0.65'>%1</t></t>", _text, _image];
        _button ctrlAddEventHandler["ButtonClick", _function];};}
forEach _PhoneButtons;
[_display] spawn life_fnc_p_updateMenu; {_x ctrlShow true;
    _x ctrlSetFade 0;
    _X ctrlCommit 0.10;}
forEach _allHidden;
[] call life_fnc_calTalents;