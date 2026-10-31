disableSerialization;
if ((life_gang_data select 2) > 3) exitWith {};
params["_control", "_index"];
if (_index isEqualTo - 1) exitWith {};
private _enemyGang = parseNumber(_control lbData _index);
if ((life_gang_data select 2) <= 3) then {switch (true) do {case (_enemyGang in life_gang_wars): {ctrlEnable[9584, true]};
        case (_enemyGang in life_gang_challenges && !(_enemyGang in life_gang_wars)): {ctrlEnable[9583, true]};
        case !(_enemyGang in life_gang_wars): {ctrlEnable[9582, true]};
        default {};};};