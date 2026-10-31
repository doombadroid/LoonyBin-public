/*
    life_fnc_uC (LooneyBin compat -- reverse-drift; real impl)
*/
// LooneyBin compat: LoonyBin money helper  ['cash'|'atm','take'|'add'|'set',amount]
params [["_account","",[""]],["_op","",[""]],["_amount",0,[0]]];
private _ret = true;
switch (toLower _account) do {case "cash": { switch (toLower _op) do {
        case "take": { if (life_cash < _amount) exitWith {_ret=false}; life_cash = life_cash - _amount; };
        case "add": { life_cash = life_cash + _amount; };
        case "set": { life_cash = _amount; }; }; };
    case "atm": { switch (toLower _op) do {
        case "take": { if (life_atmcash < _amount) exitWith {_ret=false}; life_atmcash = life_atmcash - _amount; };
        case "add": { life_atmcash = life_atmcash + _amount; };
        case "set": { life_atmcash = _amount; }; }; };};
_ret
