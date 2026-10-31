/*
    TON_fnc_srvSellHouse  (LooneyBin) -- sell a house back to the bank. Runs on the SERVER.
    2020 client args: [_house, _player]   (fn_sellHouse)

    Was a broken passthrough: `_this call DB_fnc_deleteHouse` fed deleteHouse `[_house, _player]`,
    but it reads arg0 as the oid and arg1 as the house -> it operated on the PLAYER as the house
    (getPos player / getBuildID player) -> wrong/no DB row deleted, and nothing ever told the seller's
    client to finalise -> "houses can't be sold" (txn hung: no money, house stayed, life_houseTxn stuck).

    Now: delete the row by the house's oid (= plb_houseID, the unique key addHouse REPLACE'd on / receiveHouses
    loads), drop it from the server ownership list, then call life_fnc_handleHouse mode 2 on the seller --
    which pays the sell price, removes it from life_houses/life_vehicles, deletes the marker, clears the
    house vars, and resets life_houseTxn / life_action_in_use.
*/
params [["_house", objNull, [objNull]], ["_player", objNull, [objNull]]];
if (isNull _house || isNull _player) exitWith {};

// owner 2026-07-11 (Malden Makeover): a sale ends the makeover -- restore the original building BEFORE the
// row goes away (the swap registry is keyed by plb_houseID). revert DELETES the shell _house points at and
// returns the restored original -- continue the sale on THAT (getPosWorld objNull would derive posOid
// "00" and the row DELETE below would miss). No-op for non-maldened houses.
if (_house getVariable ["plb_malden", false]) then {private _restored = ["revert", _house] call TON_fnc_maldenSRV;
    if (!isNull _restored) then { _house = _restored; };};

// owner 2026-06-17 (#318): the DELETE was gated on plb_houseID, which is ""/-1 whenever the boot ownership
// re-tag hasn't stamped the object (the #305/#307 timing). When empty, the sell PAID the seller and cleared
// their client (mode 2 below) but the DB row SURVIVED with owners=seller -> the shed read "already owned"
// forever and nobody could re-buy it (addHouse's theft pre-check refunded every buyer = the #318 report).
// The oid is deterministic from the house POSITION (the same getPosWorld hash addHouse builds), so derive it
// here and ALWAYS delete by it -- plus by plb_houseID too if it's a valid, different value (legacy oids).
private _oid = _house getVariable ["plb_houseID", ""];
private _p = getPosWorld _house;
private _posOid = format ["%1%2", round (_p select 0), round (_p select 1)];
private _delIds = [_posOid];
if (!(_oid isEqualTo "") && {!((str _oid) isEqualTo "-1")} && {!((str _oid) isEqualTo _posOid)}) then {_delIds pushBack (str _oid);};
{ [format ["DELETE FROM houses WHERE `oid`='%1'", _x]] call DB_fnc_asyncQuery; } forEach _delIds;

// owner 2026-07-22 (multi-rig): a sale takes any placed mining rigs with it -- despawn the compositions
// and drop their house_rigs rows, else the orphaned rows respawn rigs in a house the seller no longer
// owns at next boot. No auto-collect/refund: pack rigs up BEFORE selling (delete refunds the item).
if (!isNil "PLB_cryptoRigs") then {private _gone = 0; {private _rid = _x; private _rec = _y;
        if ((format ["%1", _rec param [3, ""]]) in _delIds) then {
            { if (!isNull _x) then { deleteVehicle _x; }; } forEach (_rec param [2, []]);
            PLB_cryptoRigs deleteAt _rid;
            _gone = _gone + 1;};} forEach +PLB_cryptoRigs;
    if (_gone > 0) then {{ [format ["DELETE FROM house_rigs WHERE oid='%1'", _x]] call DB_fnc_asyncQuery; } forEach _delIds;
        [[format ["%1 mining rig%2 went with the house -- pack rigs up before selling next time.", _gone, ["s",""] select (_gone == 1)], "basic"], "life_fnc_handleMessage", _player, false, false] spawn life_fnc_MP;
        ["-MINING-", _player, name _player, format ["sold house %1 with %2 rig(s) inside (forfeited)", _delIds param [0, ""], _gone]] call TON_fnc_logIt;
    };};

// owner 2026-06-21: if the sold house IS a gang house, CLEAR that gang's house_pos. Otherwise the gang HQ lingers
// pointing at a house someone else now owns (the reported bug: a leader sold their gang house ages ago and it
// stayed the gang HQ -> stale marker/spawn). plb_house_gang = the gang id tagged on the building by the boot
// re-tag (init.sqf gang-house block). Untag the object too so a later re-tag pass doesn't re-stamp it.
private _ghGang = _house getVariable ["plb_house_gang", -1];
if (_ghGang isNotEqualTo -1) then {[format ["UPDATE gangs SET house_pos=NULL WHERE id='%1'", _ghGang]] call DB_fnc_asyncQuery;
    _house setVariable ["plb_house_gang", -1, true];};

// server-side ownership bookkeeping (cleanup/ownership scans read life_house_owners) -- drop by either oid
if (!isNil "life_house_owners") then {
    private _i = life_house_owners findIf { private _e = str (_x param [0, ""]); (_e isEqualTo _posOid) || {_e isEqualTo (str _oid)} };
    if (_i != -1) then { life_house_owners deleteAt _i; };};

// finalise on the seller: mode 2 = sold -> pay sellPrice + drop from lists + marker + reset txn (whitelisted cb)
_house setVariable ["plb_houseName", "", true];   // owner 2026-07-10: drop the custom name when sold to bank/market
[2, _house, getPlayerUID _player] remoteExec ["life_fnc_handleHouse", owner _player];

// owner 2026-06-17: CLEAR the sale lock. fn_sellHouse sets plb_house_sold=true (global) to lock the house WHILE
// the sale processes, but it was NEVER cleared anywhere -> every house sold back to the bank stayed "recently sold
// and still being processed by the server" FOREVER, so NOBODY could re-buy it (until a restart wiped the in-memory
// var). Clear it (global) a few seconds after the DELETE has committed AND the seller's client set-true has landed
// (the 2 broadcasts race -> the delay makes this one cleanly last), so the now-unowned house is buyable again.
[_house] spawn { params ["_h"]; uiSleep 5; if (!isNull _h) then { _h setVariable ["plb_house_sold", nil, true]; }; };

diag_log format ["[LooneyBin][srvSellHouse] sold oid=%1 by %2 (%3)", _oid, name _player, getPlayerUID _player];
