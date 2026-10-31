/*
    life_fnc_gangListMenu  --  owner 2026-06-13, extended 2026-06-24
    Press 0 (civ OR cop) -> roster of EVERY gang with online members AND EVERY active group/squad, each with member
    names. Pure client-side: players broadcast gang_data (public setVariable) so we group allPlayers by gang id; groups
    come straight off `group _x`. Styled like the APD wanted list (dialog\gang_list.hpp, idd 2450). Toggles on repeat
    press. gang_data = [id, name, rank, ...]. Unified PLB_rosterData = [[kind, label, [memberNames]], ...] keyed by the
    list ROW INDEX (lbData), so fn_gangListSelect can fill members for a gang OR a group uniformly.
*/
disableSerialization;
if (!isNull (findDisplay 2450)) exitWith { closeDialog 0 };
createDialog "life_gang_list_menu";
private _display = findDisplay 2450;
if (isNull _display) exitWith {};
private _gangBox = _display displayCtrl 2451;
lbClear _gangBox;

private _roster = [];   // [[kind("GANG"/"GROUP"), label, [memberNames]], ...]

// ---- GANGS: group online players by their broadcast gang id ----
private _gangs = []; {private _gd = _x getVariable ["gang_data", []];
    if (_gd isEqualType [] && {count _gd >= 2} && {(_gd select 0) isEqualType 0} && {(_gd select 0) > 0}) then {
        private _gid = _gd select 0;
        private _idx = _gangs findIf { (_x select 0) isEqualTo _gid };
        if (_idx isEqualTo -1) then { _gangs pushBack [_gid, _gd select 1, [name _x]]; }
        else { ((_gangs select _idx) select 2) pushBack (name _x); };};} forEach allPlayers;
_gangs = [_gangs, [], { count (_x select 2) }, "DESCEND"] call BIS_fnc_sortBy;   // most members first
{ _x params ["_gid", "_gname", "_mem"]; _roster pushBack ["GANG", _gname, _mem]; } forEach _gangs;

// ---- GROUPS: group online players by their Arma group/squad (skip 1-man groups -- that's not a "group") ----
private _groups = []; {private _grp = group _x;
    private _idx = _groups findIf { (_x select 0) isEqualTo _grp };
    if (_idx isEqualTo -1) then { _groups pushBack [_grp, [name _x]]; }
    else { ((_groups select _idx) select 1) pushBack (name _x); };} forEach (allPlayers select { !isNull _x });
// owner 2026-06-25 (Northhhhh): exclude GANG groups -- gang members all share ONE Arma group (fn_initGang joins them, tags it gang_id),
// so a gang was listed once as a GANG (above) AND again here as a GROUP = the "it doubles the groups" report. Real squads have no gang_id.
_groups = _groups select { count (_x select 1) > 1 && {((_x select 0) getVariable ["gang_id", -1]) isEqualTo -1} };
_groups = [_groups, [], { count (_x select 1) }, "DESCEND"] call BIS_fnc_sortBy;
{ _x params ["_grp", "_mem"]; _roster pushBack ["GROUP", format ["%1's group", name (leader _grp)], _mem]; } forEach _groups;

uiNamespace setVariable ["PLB_rosterData", _roster];

private _gangN = count _gangs; private _groupN = count _groups;
private _totalMem = 0; { _totalMem = _totalMem + count (_x select 2) } forEach _gangs;
(_display displayCtrl 2453) ctrlSetText format ["Gangs Online: %1   |   Groups: %2   |   Gang members online: %3", _gangN, _groupN, _totalMem];

if (_roster isEqualTo []) then {_gangBox lbAdd "  No gangs or groups currently online";} else {{_x params ["_kind", "_label", "_mem"];
        private _i = _gangBox lbAdd format ["%1%2   (%3 online)", (["", "[Group] "] select (_kind isEqualTo "GROUP")), _label, count _mem];
        _gangBox lbSetData [_i, str _forEachIndex];} forEach _roster;
    _gangBox lbSetCurSel 0;   // fires onLBSelChanged -> fills the member list
};
