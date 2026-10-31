/*
    fn_asyncQuery.sqf  —  extDB3 (LooneyBin migration of the 2017 extDB2 version)

    Single chokepoint for all server SQL. Migrated extDB2 (DB_RAW_V2) -> extDB3 (SQL protocol).
    Caller contract is UNCHANGED so all existing callers keep working:
      params: 0=query string, 1=mode (1=async no-return, 2=async return), 2=multiarr (true=all rows)
      returns: mode 1 -> true ; mode 2 -> first row, or all rows if _multiarr

    extDB3 differences vs extDB2 handled here:
      - extension name "extDB" -> "extDB3"
      - result read via "4:<key>" ("[3]" = not ready), multi-part drained via "5:<key>"
      - result rows live at (result select 1) (one level, not two as in DB_RAW_V2)
      - (result select 0)==0 means protocol error
*/
waitUntil {!DB_Async_Active};
private["_queryStmt","_mode","_multiarr","_key","_queryResult","_pipe","_return"];
_queryStmt = [_this,0,"",[""]]       call BIS_fnc_param;
_mode      = [_this,1,1,[0]]          call BIS_fnc_param;
_multiarr  = [_this,2,false,[false]] call BIS_fnc_param;

if(_queryStmt == "") exitWith {"_INVALID_SQL_STMT"};
diag_log format["SQL Query: %1", _queryStmt];

DB_Async_Active = true;
_key = "extDB3" callExtension format["%1:%2:%3",_mode,life_sql_id,_queryStmt];

// mode 1 = fire & forget (INSERT/UPDATE/DELETE), no result wanted
if(_mode == 1) exitWith {DB_Async_Active = false; true};

_key = call compile format["%1",_key];
_key = _key select 1;

_queryResult = "extDB3" callExtension format["4:%1",_key];

// "[3]" = result not ready yet -> spin until ready
if(_queryResult isEqualTo "[3]") then {while {true} do {if !(_queryResult isEqualTo "[3]") exitWith {};
        uiSleep 0.005;   // LooneyBin [PERF step 4]: the not-ready spin had NO yield -> starved the whole scheduler under load (asyncQuery always runs scheduled: the waitUntil above guarantees it)
        _queryResult = "extDB3" callExtension format["4:%1",_key];};};

// "[5]" = multi-part message -> drain via 5:<key> until empty
if(_queryResult isEqualTo "[5]") then {_queryResult = "";
    while {true} do {_pipe = "extDB3" callExtension format["5:%1",_key];
        if(_pipe isEqualTo "") exitWith {};
        _queryResult = _queryResult + _pipe;};};

DB_Async_Active = false;

_queryResult = call compile _queryResult;
if((_queryResult select 0) isEqualTo 0) exitWith {diag_log format["extDB3: Protocol Error: %1 (query: %2)",_queryResult,_queryStmt]; []};

_return = (_queryResult select 1);
if(count _return == 0) exitWith {[]};
if(!_multiarr) then { _return = _return select 0; };

_return;
