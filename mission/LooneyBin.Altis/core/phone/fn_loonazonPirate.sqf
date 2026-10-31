/*
    life_fnc_loonazonPirate  (LooneyBin, owner 2026-07-16) -- PORCH PIRATE van tracking.
    The server broadcasts every Loonazon van's position to ALL clients every 30s; only players holding the
    Porch Pirate talent (260) render anything -- everyone else exits immediately, so the server never needs to
    know who has the talent. Local orange truck marker per delivery (multiple vans = multiple markers), plus a
    one-time heads-up when a new van hits the road. Cleared when that delivery ends.
      ["update", id, pos, ownerUID]   create/move the marker for delivery <id>
      ["clear",  id, pos, ownerUID]   remove it
    The buyer never pirates their own shipment: if this client's UID is the van's owner, bail before rendering.
*/
if (!hasInterface) exitWith {};
params [["_cmd", "", [""]], ["_id", 0, [0]], ["_pos", [0,0,0], [[]]], ["_owner", "", [""]]];
if (!(260 in life_side_talents)) exitWith {};
if ((getPlayerUID player) isEqualTo _owner) exitWith {};   // your own order -- no perk ping on it

private _mk = format ["plb_lzpirate_%1", _id];
switch (toLower _cmd) do {case "update": {if ((markerType _mk) isEqualTo "") then {createMarkerLocal [_mk, _pos];
            _mk setMarkerTypeLocal "c_car";
            _mk setMarkerColorLocal "ColorOrange";
            _mk setMarkerSizeLocal [0.9, 0.9];
            ["<t color='#e88b2d'>PORCH PIRATE</t> -- a Loonazon van just hit the road. Its route pings on your map every 30 seconds...", "basic"] spawn life_fnc_handleMessage;
        };
        _mk setMarkerPosLocal _pos;
        _mk setMarkerTextLocal format ["Loonazon Van (%1)", _id];};
    case "clear": {if ((markerType _mk) isNotEqualTo "") then { deleteMarkerLocal _mk; };};};
