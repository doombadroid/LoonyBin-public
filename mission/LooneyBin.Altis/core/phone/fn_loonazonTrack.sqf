/*
    life_fnc_loonazonTrack  (LooneyBin, owner 2026-07-16) -- PRIVATE Loonazon delivery tracker.
    The server pushes the delivery van's live position to the BUYER only; this drops a client-LOCAL map
    marker (createMarkerLocal -> invisible to every other player) that follows the van in, labelled with the
    live distance to you. Cleared when the van arrives or despawns. The van is HC-owned and often far away,
    so the client can't read its position itself -- that's why the server feeds it here.
      ["update", vanPos]   create/move the marker
      ["clear"]            remove it
*/
if (!hasInterface) exitWith {};
params [["_cmd", "", [""]], ["_pos", [], [[]]]];

switch (toLower _cmd) do {case "update": {if (count _pos < 2) exitWith {};
        if (isNil "PLB_loonazonTrkMkr") then {PLB_loonazonTrkMkr = createMarkerLocal ["plb_loonazon_trk", _pos];
            "plb_loonazon_trk" setMarkerTypeLocal "mil_box";
            "plb_loonazon_trk" setMarkerColorLocal "ColorOrange";
            "plb_loonazon_trk" setMarkerSizeLocal [0.9, 0.9];};
        "plb_loonazon_trk" setMarkerPosLocal _pos;
        "plb_loonazon_trk" setMarkerTextLocal format ["Loonazon Van  %1m", round (player distance2D _pos)];};
    case "clear": {if (!isNil "PLB_loonazonTrkMkr") then {deleteMarkerLocal "plb_loonazon_trk";
            PLB_loonazonTrkMkr = nil;};};
    // owner 2026-07-17: OFF-ROAD DROP marker. When the van can't reach an off-road buyer it drops the package at
    // the nearest road; this persistent local marker shows exactly where. Auto-clears in 15 min (the crate TTL) or
    // on relog. Separate marker from the transit tracker, so the arrival "clear" above doesn't remove it.
    case "drop": {if (count _pos < 2) exitWith {};
        if (isNil "PLB_loonazonDropMkr") then {PLB_loonazonDropMkr = createMarkerLocal ["plb_loonazon_drop", _pos];
            "plb_loonazon_drop" setMarkerTypeLocal "mil_box";
            "plb_loonazon_drop" setMarkerColorLocal "ColorOrange";
            "plb_loonazon_drop" setMarkerSizeLocal [1, 1];
            "plb_loonazon_drop" setMarkerTextLocal "Loonazon Package";};
        "plb_loonazon_drop" setMarkerPosLocal _pos;
        [] spawn { uiSleep 900; if (!isNil "PLB_loonazonDropMkr") then { deleteMarkerLocal "plb_loonazon_drop"; PLB_loonazonDropMkr = nil; }; };
    };};
