if (isNull life_placing) exitWith {};
private _index = [typeOf life_placing, life_placeable] call life_fnc_index;
if (_index isEqualTo - 1) exitWith {};
private _item = (life_placeable select _index) select 0;
if (playerSide isEqualTo west && ((player distance(getMarkerPos "armory_marker")) < 200)) exitWith {
    ["You cannot place checkpoint materials inside of the Evidence Lockup!", "basic"] spawn life_fnc_handleMessage};
if (playerSide isEqualTo west && ({player distance getMarkerPos format["police_hq_%1", _x] < 75}
count[1, 2, 3, 4, 5, 6, 7] > 0)) exitWith {
    ["You cannot place checkpoint materials inside of Police HQ's!", "basic"] spawn life_fnc_handleMessage};
if (playerSide isEqualTo west && ({player distance getMarkerPos format["police_hq_%1", _x] < 125}
count[5] > 0)) exitWith {["You cannot place checkpoint materials inside of Police HQ's!", "basic"] spawn life_fnc_handleMessage};
// LooneyBin furniture: must be at YOUR house (20m), exempt from the cartel-radius rule below
if ((_item in PLB_furnitureItems) && {((nearestObjects [player, ["House_F"], 20]) findIf { _x in life_vehicles }) isEqualTo -1}) exitWith {
    ["Furniture can only be placed within 20m of a house you own.", "basic"] spawn life_fnc_handleMessage};
if ((playerSide isEqualTo civilian) && (_item isNotEqualTo "boombox") && !(_item in PLB_furnitureItems) && (({player distance _x < 300}
count[arms_flag, drug_flag, wongs_flag, oil_flag]) isEqualTo 0)) exitWith {
    ["You can only place this object within 300m of a capture area (cartel).", "basic"] spawn life_fnc_handleMessage};
if !([false, _item, 1] call life_fnc_handleInv) exitWith {deleteVehicle life_placing;
    life_placing = objNull;};
// LooneyBin 2026-06-11: furniture keeps the exact height it was placed at (indoors / on an elevated
// floor) -- the old z=0 dropped it onto the TERRAIN, i.e. under the house floor ("vanished"). Cones/
// barriers still snap to the ground (z=0) as before.
private _furnPlacePos = getPosASL life_placing;
detach life_placing;
if (_item in PLB_furnitureItems) then {life_placing setPosASL _furnPlacePos;} else {
    life_placing setPos[(getPos life_placing select 0), (getPos life_placing select 1), 0];};
life_placing setVariable["plb_owner", player, true];
life_placing setVariable["plb_ownerID", getPlayerUID player, true];
life_placing setVariable["plb_placedItem", true, true];
life_placing removeEventHandler["HandleDamage", 0];
if !((life_placeable select _index) select 5) then {life_placing allowDamage false;};
if (typeOf life_placing isEqualTo "Land_BatteryPack_01_closed_black_F") then {["initBoomBox", [life_placing]] spawn life_fnc_boomBox;};
// LooneyBin furniture: persist into the house's DB row (server enforces the 15-per-house cap and
// deletes + refunds if over). Sim off = zero server physics cost.
if (_item in PLB_furnitureItems) then {life_placing enableSimulationGlobal false;
    life_placing setVariable ["plb_furniture", true, true];   // exempt from the server cleanup sweep (fn_cleanup)
    // owner 2026-07-10: ["House"] not ["House_F"] -- industrial sheds aren't reliably House_F (receiveHouses
    // lesson); "House" covers sheds + every normal home.
    private _houses = nearestObjects [player, ["House"], 20];
    // BUGS #151: was `_x in life_vehicles` (the VEHICLE array -- never contains houses) -> _house always
    // objNull -> the "add" was never sent -> no furniture ever persisted. Match the house YOU own.
    private _house = _houses param [_houses findIf { (_x getVariable ["plb_homeOwner", ""]) isEqualTo getPlayerUID player }, objNull];
    if (!isNull _house) then {
        // owner 2026-07-10: SERVER-SPAWN HANDOFF. The client used to keep ITS createVehicle'd object as the
        // live piece and ship the object REF to the server for tracking -- but the ref regularly arrived
        // objNull (sent the same frame the object was created), so the server's spawned-list missed it:
        // "Show Furniture" then saw nothing out and spawned a SECOND copy while "Hide" only deleted the
        // tracked one -> +1 piece per hide/show cycle, infinitely (the ladder dupe). Now the client sends
        // ONLY class/pos/dir and deletes its preview; the SERVER spawns the one authoritative copy and
        // tracks it from birth. No ref crosses the wire = no race, ever.
        // LooneyBin 2026-07-18: the crypto MINING RIG isn't furniture -- route it to its own server handler
        // (helipad-style persistence + mining accrual), NOT the house-furniture DB. The cryptoRig item was
        // already consumed above; the server spawns the composition + saves, or refunds on reject.
        if (_item isEqualTo "cryptoRig") exitWith {
            [["place", player, _house, getPosATL life_placing, getDir life_placing], "TON_fnc_miningSRV", 2] spawn life_fnc_MP;
            deleteVehicle life_placing;};
        private _hid = _house getVariable ["plb_houseID", -1];
        // owner 2026-07-10: COMPOSITION items (PLB_furnitureComps) fan out one persisted "add" per member,
        // positioned from the preview's transform (model-space offsets rotated to its facing). Each member
        // becomes a normal furniture entry. Only the FIRST member carries the placer/itemKey, so a server
        // reject can refund the consumed item exactly once (later members reject silently).
        private _ci = PLB_furnitureComps findIf { (_x select 0) isEqualTo _item };
        if (_ci isNotEqualTo -1) then {private _base = getPosATL life_placing;
            private _bdir = getDir life_placing;
            private _c = cos _bdir; private _s = sin _bdir; {_x params ["_mCls", "_mOff", "_mRel"];
                private _wp = [(_base select 0) + ((_mOff select 0) * _c) + ((_mOff select 1) * _s),
                    (_base select 1) - ((_mOff select 0) * _s) + ((_mOff select 1) * _c), (_base select 2) + (_mOff param [2, 0])];
                private _first = _forEachIndex isEqualTo 0; [
                    ["add", _hid, _mCls, _wp, _bdir + _mRel, objNull, [objNull, player] select _first, ["", _item] select _first], "TON_fnc_houseFurnitureSRV", 2] spawn life_fnc_MP;
            } forEach ((PLB_furnitureComps select _ci) select 1);} else {[
                ["add", _hid, typeOf life_placing, getPosATL life_placing, getDir life_placing, objNull, player, _item], "TON_fnc_houseFurnitureSRV", 2] spawn life_fnc_MP;
        };
        deleteVehicle life_placing;};};
life_placing = objNull;