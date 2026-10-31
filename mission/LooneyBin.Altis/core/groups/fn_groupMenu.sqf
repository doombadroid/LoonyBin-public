private _menuType =
if (isNull life_my_gang) then {"groupMenuBrowse"} else {"groupMenuMain"};
[_menuType] spawn life_fnc_createDialog;