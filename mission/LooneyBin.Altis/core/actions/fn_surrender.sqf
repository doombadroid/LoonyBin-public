if (player getVariable["plb_escorting", false] || player getVariable["plb_restrained", false]) exitWith {};
if (speed player > 1 || player getVariable["plb_downed", false]) exitWith {};
if !(isNull objectParent player) exitWith {};
if (player getVariable["plb_surrendered", false]) then {player setVariable["plb_surrendered", false, true]} else {
    player setVariable["plb_surrendered", true, true];};
waitUntil {player playMove "AmovPercMstpSnonWnonDnon_AmovPercMstpSsurWnonDnon";
    if (player getVariable["plb_downed", false] || !(alive player)) exitWith {player setVariable["plb_surrendered", false, true];
        true;};
    !(player getVariable["plb_surrendered", false]);};
player playMoveNow "AmovPercMstpSsurWnonDnon_AmovPercMstpSnonWnonDnon";