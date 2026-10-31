/*
    File: fn_casinoReceive.sqf  (life_fnc_casinoReceive)  -- LooneyBin Casino, generic payout credit.
    Receiver half of TON_fnc_casinoSRV (Coin Flip / Wheel / Slots / Roulette / Hi-Lo). Runs on the
    betting player's client when the SERVER settles a game and credits the total RETURN to BANK.
    Server-initiated only (CfgRE allowedTargets=1). Game-agnostic -- it just moves money; the table
    result is drawn by life_fnc_casino. Mirror of life_fnc_blackJackReceive. Args: [_return]
*/
params [["_return", 0, [0]]];
// Server-origin gate: TON_fnc_casinoSRV (server, owner 2) is the ONLY legit caller. Credits bank cash,
// so a local / non-server call must never self-award a payout (mirrors life_fnc_blackJackReceive).
if (remoteExecutedOwner != 2) exitWith {};
if (_return <= 0) exitWith {};

life_atmcash = life_atmcash + _return;
life_atmcashCacheB = ((life_atmcash / 4) + 11);
[1] call life_fnc_ClupdatePartial;
