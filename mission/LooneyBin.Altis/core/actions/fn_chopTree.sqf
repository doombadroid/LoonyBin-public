params[["_tree", objNull, [objNull]]];
if (isNull _tree || life_action_in_use || life_inv_woodaxe <= 0) exitWith {};
if (((player distance(getMarkerPos "city")) < 1000) || ((player distance(getMarkerPos "civ_spawn_3")) < 500) || ((player distance(getMarkerPos "civ_spawn_4")) < 500) || ((player distance(getMarkerPos "civ_spawn_2")) < 500) || ((player distance(getMarkerPos "donor_town")) < 500)) exitWith {
    ["You cannot cut down a tree within city limits.", "basic"] spawn life_fnc_handleMessage;};
if !(alive _tree) exitWith {["You cannot chop an already fallen tree. Find another!", "basic"] spawn life_fnc_handleMessage};
if !(((str(_tree) find " t_") >= 0) || ((str(_tree) find " palm_") >= 0)) exitWith {};
private _pos3D = getPos _tree;
private _pos2D = [_pos3D select 0, _pos3D select 1, 0];
if ((getPosATL player) distance _pos2D > 4) exitWith {["You are too far from the tree to chop it.", "basic"] spawn life_fnc_handleMessage};
private _height = _pos2D distance _pos3D;
private _amount = round(_height / 3);
if (_amount > 4) then {_amount = 4};
life_action_in_use = true;
player playMoveNow "ReloadRPG";
playSound "chop";
uiSleep 2.2;
life_action_in_use = false;
if (isNull _tree || !(alive _tree)) exitWith {};
// owner 2026-07-03 (#536): send the chop to the server FIRST, while the tree is STILL STANDING. setDamage below
// has a GLOBAL effect -> felling the tree here first replicates to the server before this RPC, so TON_fnc_chopTreeSRV's
// `alive` re-validation saw a dead tree and early-exited (no pile, no timber, no -CHOPTREE- log). Sending the RPC
// before the fell lets the server validate a live tree + compute the correct species/pile. Anti-mint is unchanged
// (the server still re-acquires the tree by position and validates distance/cooldown/one-pile-per-tree itself).
[[_tree, _pos3D], "TON_fnc_chopTreeSRV", 2] spawn life_fnc_MP;
private _plb_dmg = _tree;
_plb_dmg setDamage 1;
private _pileSize = _amount * 4;
private _treeType = ((getModelInfo _tree) select 0);
private _pile =
switch (_treeType) do {case ("t_pinuss1s_f.p3d"): {"timber"}; case ("t_pinuss2s_f.p3d"): {"timber"}; case ("t_pinuss2s_b_f.p3d"): {
                    "timber"}; case ("t_pinusp3s_f.p3d"): {"timberh"}; case ("t_ficusb1s_f.p3d"): {
                            "timber"}; case ("t_broussonetiap1s_f.p3d"): {"timber"}; case ("t_oleae1s_f.p3d"): {
                                    "timberl"}; case ("t_oleae2s_f.p3d"): {"timberl"}; case ("t_ficusb2s_f.p3d"): {
                                            "timber"}; case ("t_fraxinusav2s_f.p3d"): {"timberh"}; case ("t_phoenixc1s_f.p3d"): {
                                                    "timberh"}; case ("t_phoenixc3s_f.p3d"): {"timberh"}; case ("t_quercusir2s_f.p3d"): {
                                                            "timberh"}; case ("t_populusn3s_f.p3d"): {
                                                                "timberh"}; case ("t_poplar2f_dead_f.p3d"): {"timberh"}; default {
                                                                    "timber"};
}; titleText [format["You chopped %1 %2 from a %3m tall tree.", _pileSize, (["getName", _pile] call life_fnc_virtItemCfg), round(_height * 100) / 100], "PLAIN"];
// owner 2026-06-24: SERVER-AUTHORITATIVE chop. Was a CLIENT-side TON_fnc_createItem of the pile -> a cheat client
// could remoteExec createItem directly to MINT timber with no tree (player093 76561190000000038). Now send the TREE to
// TON_fnc_chopTreeSRV, which re-validates a real, live, in-range tree + computes + spawns the pile server-side
// (the _pile/_pileSize above is now only the local titleText estimate; createItem additionally strips client timber).
// NOTE: the TON_fnc_chopTreeSRV RPC is fired ABOVE (before setDamage) so the server validates a live tree -- see #536.
if !(isNull _tree) then {[[_tree, 180], "TON_fnc_setCleanTime", 2] spawn life_fnc_MP;};
["action", "choptree", 1] call life_fnc_handleQuest;