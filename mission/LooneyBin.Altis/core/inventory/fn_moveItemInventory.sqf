#include "..\..\macro.h"
params["_isVirtual", "_isUp"];
disableSerialization;
if (!life_didServerRespond) exitWith {["Awaiting server response, try again in a few seconds...", "basic"] spawn life_fnc_handleMessage};
// LooneyBin 2026-07-16: Loonazon delivery boxes are TAKE-ONLY -- the move gutter can push player items in, so
// block it here too (the opener greys these buttons; belt for any other entry).
if ((life_trunk_vehicle getVariable["plb_packageOwner", ""]) isNotEqualTo "") exitWith {
    ["The Loonazon box is take-only.", "basic"] spawn life_fnc_handleMessage;};
private _lbSelected = lbCurSel 4502;
if (_lbSelected isEqualTo - 1) exitWith {};
private _playerItemSelected = getSelData(4502);
if (_playerItemSelected isEqualTo "") exitWith {};
private _vehPos = getPos life_trunk_vehicle;
private _playerPos = getPos player;
if (_vehPos distance _playerPos > 10) exitWith {["You are too far away!", "basic"] spawn life_fnc_handleMessage;
    closeDialog 0;};
private _trunkDetails =
if (_isVirtual) then {(life_trunk_vehicle getVariable["plb_vinv", [[], 0]]);} else {(life_trunk_vehicle getVariable["plb_pinv", [[], 0]]);
};
private _trunkInv = _trunkDetails select 0;
private _trunkWeight = _trunkDetails select 1;
private _trunkLength = count _trunkInv;
if (((_lbSelected isEqualTo 0) && _isUp) || ((_lbSelected isEqualTo(_trunkLength - 1)) && !(_isUp))) exitWith {};
private _arrayItemSelected = _trunkInv select _lbSelected;
private _newTrunkInventory = [];
_newTrunkInventory =
if (_isUp) then {private _newInv = _trunkInv select[0, _lbSelected - 1];
    _newInv append[(_trunkInv select _lbSelected)];
    _newInv append[(_trunkInv select(_lbSelected - 1))];
    _newInv append(_trunkInv select[_lbSelected + 1, (_trunkLength - (_lbSelected + 1))]);
    _newInv;} else {private _newInv = _trunkInv select[0, _lbSelected];
    _newInv append[(_trunkInv select _lbSelected + 1)];
    _newInv append[(_trunkInv select(_lbSelected))];
    _newInv append(_trunkInv select[_lbSelected + 2, (_trunkLength - (_lbSelected + 1))]);
    _newInv;};
if (count _newTrunkInventory isEqualTo 0) exitWith {};
if (_isVirtual) then {life_trunk_vehicle setVariable["plb_vinv", [_newTrunkInventory, _trunkWeight]];
    [life_trunk_vehicle, life_is_virtual] call life_fnc_refreshInventory;} else {
    life_trunk_vehicle setVariable["plb_pinv", [_newTrunkInventory, _trunkWeight]];
    [life_trunk_vehicle, life_is_virtual] call life_fnc_refreshInventory;};
if (_isUp) then {lbSetCurSel[4502, _lbSelected - 1];} else {lbSetCurSel[4502, _lbSelected + 1];};
life_movedItem = true;