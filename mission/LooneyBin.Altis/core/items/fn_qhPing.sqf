// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only
/*
    File: fn_qhPing.sqf  (life_fnc_qhPing)
    Ping.exe / Pursuit Tag readout. The SERVER feeds the samples so a Scrambler Chip can lie to the
    hacker -- if the position came from the hacker's own client no counter-chip could ever work.
*/
params [["_pos", [], [[]]], ["_label", "TARGET", [""]], ["_last", false, [false]]];
if (_pos isEqualTo []) exitWith {};
if (isNil "plb_qhPingMarker") then {plb_qhPingMarker = createMarkerLocal [format ["qh_ping_%1", round diag_tickTime], _pos];
    plb_qhPingMarker setMarkerTypeLocal "hd_dot";
    plb_qhPingMarker setMarkerColorLocal "ColorOrange";};
plb_qhPingMarker setMarkerPosLocal _pos;
plb_qhPingMarker setMarkerTextLocal _label;
if (_last) then {
    [] spawn { uiSleep 1; if (!isNil "plb_qhPingMarker") then { deleteMarkerLocal plb_qhPingMarker; plb_qhPingMarker = nil; }; };};
