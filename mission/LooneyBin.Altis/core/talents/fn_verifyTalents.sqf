if !(playerSide isEqualTo civilian) exitWith {};
private _talentsToRemove = life_side_talents select {["getRowByID", _x] call life_fnc_talentCfg isEqualTo[]};
if (_talentsToRemove isNotEqualTo[]) then {{private _talent = _x;
        life_side_talents deleteAt(life_side_talents findIf {_x isEqualTo _talent});}
    forEach _talentsToRemove;
    [4] call life_fnc_ClupdatePartial;};