params[["_vehicle", objNull, [objNull]]];
if (isNull _vehicle) exitWith {};
if (_vehicle isKindOf "House_F") exitWith {};
if (isNil {_vehicle getVariable "plb_defaultMass"}) then {_vehicle setVariable["plb_defaultMass", getMass _vehicle, true];};
private _ropeEnabled = ropeAttachEnabled _vehicle;
private _locked = (locked _vehicle) isEqualTo 2;
private _currentMass = getMass _vehicle;
private _defaultMass = _vehicle getVariable["plb_defaultMass", getMass _vehicle];
private _nonSlingItems = ["goldbar", "oilb", "oilp", "oilu", "jewelHope", "jewelRolex", "jewelAP", "jewelDiamonds", "jewelGoldBag", "jewelExoJewels", "jewelRing", "jewelBling", "jewelBag"];
(_vehicle getVariable["plb_vinv", [[], 0]]) params["_items", "_vehWeight"];
private _goldAmount = (_items param[_items findIf {"goldbar" in _x}, 0]) param[1, 0];
if !(_goldAmount isEqualTo 0) then {private _goldMass = _goldAmount * 400;
    private _intendedMass = _defaultMass + _goldMass;
    if ((_intendedMass <= 60000) && !(_currentMass isEqualTo _intendedMass)) then {_vehicle setMass _intendedMass;};} else {
    if !(_currentMass isEqualTo _defaultMass) then {_vehicle setMass _defaultMass;};};
private _slingEnabled = ropeAttachEnabled _vehicle;
private _shouldEnableSling = (_items findIf {(_x select 0) in _nonSlingItems}
isEqualTo - 1) && !(_ropeEnabled && _locked) && (_vehicle getVariable["plb_canChop", true]);
if (!_shouldEnableSling && !(isNull(ropeAttachedTo _vehicle))) then {(ropeAttachedTo _vehicle) setSlingLoad objNull};
if (_slingEnabled isNotEqualTo _shouldEnableSling) then {_vehicle enableRopeAttach _shouldEnableSling};