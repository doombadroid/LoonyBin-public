params["_ctrl", "_code"];
private _handled = false;
if (life_show_actions) then {life_show_actions = false;
    private _obj_main = player;
    removeAllActions _obj_main;
    life_actions = [];};
_handled