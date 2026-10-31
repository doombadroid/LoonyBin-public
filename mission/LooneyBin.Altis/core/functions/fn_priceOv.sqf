/*
    life_fnc_priceOv  (LooneyBin Economy, owner request 2026-06-11)
    Returns the live price-override row for an item, or [] if none.
      [_family, _key] call life_fnc_priceOv  ->  [family, key, p0, p1, p2]  |  []
    Families + slot meaning:
      "virt"  p0=base(buy)  p1=lowest(sell)  p2=max(market)
      "weap"  p0=price
      "veh"   p0=buy        p1=garage sell-back
      "cloth" p0=price
    A slot of -1 means "leave the hardcoded config value for that slot".
    PLB_priceOv (server-owned, publicVariable'd) is a flat array of these rows; overrides are few
    (only items the owner has touched) so a linear findIf is cheaper than maintaining a hashmap.
*/
params [["_family", "", [""]], ["_key", "", [""]]];
if (_family isEqualTo "" || {_key isEqualTo ""}) exitWith { [] };
if (isNil "PLB_priceOv" || {!(PLB_priceOv isEqualType [])}) exitWith { [] };
private _i = PLB_priceOv findIf { ((_x select 0) isEqualTo _family) && {(_x select 1) isEqualTo _key} };
if (_i isEqualTo -1) exitWith { [] };
PLB_priceOv select _i
