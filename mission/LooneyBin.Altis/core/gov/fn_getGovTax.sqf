private _taxRate = SRV_governorData param[2, 0];
private _richTaxRate =
switch (true) do {case (life_atmcash > 20000000): {20};
    case (life_atmcash > 10000000): {15};
    case (life_atmcash > 7500000): {12};
    case (life_atmcash > 5000000): {10};
    case (life_atmcash > 2500000): {8};
    case (life_atmcash > 1250000): {4};
    case (life_atmcash > 750000): {2};
    default {0};}; private _return = ((_taxRate + _richTaxRate) / 100);
if ((call life_adminLevel) >= 3) then {_return = 0;};
_return