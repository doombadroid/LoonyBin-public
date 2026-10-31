/*
    File: fn_blackJackReceive.sqf  (LooneyBin -- Casino phone app, blackjack)
    Receiver half of TON_fnc_blackJackSRV. Runs on the betting player's client when the SERVER settles a
    blackjack game and credits the total RETURN (bet back + winnings) to BANK. Server-initiated only (not
    in the CfgRemoteExec whitelist -- the server is exempt from mode=1). The table result is shown by the
    render path (life_fnc_blackJack); this fn only moves money. Args: [_return]
*/
params [["_return", 0, [0]]];
// Server-origin gate: TON_fnc_blackJackSRV (server, owner 2) is the ONLY legit caller. Credits bank cash,
// so a local / non-server call must never self-award a payout (mirrors life_fnc_copSplitReceive).
if (remoteExecutedOwner != 2) exitWith {};
if (_return <= 0) exitWith {};

life_atmcash = life_atmcash + _return;
life_atmcashCacheB = ((life_atmcash / 4) + 11);
[1] call life_fnc_ClupdatePartial;
