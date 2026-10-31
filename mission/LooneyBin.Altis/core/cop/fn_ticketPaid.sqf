params[["_value", 5, [0]], ["_unit", objNull, [objNull]], ["_cop", objNull, [objNull]]];
if (isNull _unit || {_unit != life_ticket_unit}) exitWith {};
if (isNull _cop || {_cop != player}) exitWith {};
life_atmcash = life_atmcash + _value;
life_atmcashCacheB = ((life_atmcash / 4) + 11);