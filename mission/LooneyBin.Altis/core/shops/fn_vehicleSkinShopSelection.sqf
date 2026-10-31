params["_basic", ["_shop", "", [""]]];
_basic params[["_control", controlNull, [controlNull]], ["_index", -1, [0]]];
if (isNull _control || _index isEqualTo - 1) exitWith {closeDialog 0;};
private _display = findDisplay 39400;
private _priceTag = _display displayCtrl 39404;
private _price = _control lbValue _index;
if ((life_cash >= _price) || ((life_atmcash >= _price) && (life_inv_debitcard >= 1))) then {
    _priceTag ctrlSetStructuredText parseText format["<t size='0.75'>Price: <t color='#8cff9b'>$%1</t>", [(_price)] call life_fnc_numberText];
} else {
    _priceTag ctrlSetStructuredText parseText format["<t size='0.75'>Price: <t color='#ff0000'>$%1</t>", [(_price)] call life_fnc_numberText];
};