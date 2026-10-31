/*
    life_fnc_gangBank  (LooneyBin: REPAIRED -- gang/gov bank reply handler)
    The server (TON_fnc_gangBank) sends the current fund balance here after any query/deposit/withdraw/
    transfer. Update the client's view and release the deposit/withdraw wait so the bank UI stops hanging
    on "Loading...". Server-only sender.
*/
if (remoteExecutedOwner != 2) exitWith {};   // only the server sets the balance; ignore spoof attempts
params [["_funds", -1, [0]]];
life_gang_funds     = _funds;
life_gangfund_ready = true;
life_gfunds_active  = false;
