params["_control"];
private _buttonData = _control getVariable "data";
_buttonData = toUpper _buttonData;
private _globalButtons = [["Sync", "icons\phone_sync.paa", "[] call life_fnc_syncData", {true
    }, "Update server with your current character data"], ["Money", "icons\phone_money.paa", "[] spawn life_fnc_money", {true
    }, "Trade your cash on hand"], ["Message", "icons\phone_message.paa", "[] spawn life_fnc_cellphone", {true
    }, "Send text messages to other players"], ["Inventory", "icons\phone_inventory.paa", "[true, true] spawn life_fnc_inventory", {true
    }, "View your virtual inventory"]];
private _favApps = +life_phone_buttons_fav;
private _phoneButtons = +life_phone_buttons;
private _apps = count _favApps;
private _allButtons = [];
_allButtons append _phoneButtons;
_allButtons append _globalButtons;
if (_apps > 4 || _apps == 4) exitWith {
    ["You cannot favorite more than 4 phone Applications at once!", "basic"] spawn life_fnc_handleMessage;
    closeDialog 0;}; {_x params["_text", "_image", "_function", "_condition", "_tooltip"];
    private _string = toUpper _text;
    if (_string == _buttonData) then {_favApps pushBackUnique _x;
        [format["You've set %1 as a favorite!", _text], "basic"] spawn life_fnc_handleMessage;};}
forEach _allButtons;
life_phone_buttons_fav = _favApps;
// owner 2026-07-20: store NAMES ONLY. Storing the whole entry froze its action + condition code into the
// client profile, so a favourited app survived every mission update -- a removed/renamed/re-gated app kept
// resurrecting from the profile with its OLD rules. Names are re-resolved against the live list at open.
profileNamespace setVariable ["PLB_favApps_v2", _favApps apply { toUpper (_x select 0) }];
saveProfileNamespace;