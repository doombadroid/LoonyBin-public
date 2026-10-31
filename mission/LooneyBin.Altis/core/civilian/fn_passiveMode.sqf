params[["_caseType", "", [""]], ["_values", [], [[]]]];
// LooneyBin: passive mode NUKED (disabled for now; re-enable later by removing this block). Never turn
// it on, and clear the flags so the damage handlers that key on life_passivemode/plb_passivemode stop
// protecting the player + their vehicle.
life_passivemode = false;
life_passiveModeJIP = false;
if (!isNull player) then { player setVariable ["plb_passivemode", false, true]; };
if (true) exitWith {};

switch (_caseType) do {case "start": {if (!(call life_newplayer) || life_passivemode) exitWith {};
            life_passivemode = true;
            life_passiveModeJIP = true;
            player setVariable["plb_passivemode", true, true];
            // LooneyBin (owner, 2026-06-11): MyLoonyBin donation/gold reward popup removed.
            if (A_stats_civTime > 120) exitWith {["stop"] spawn life_fnc_passiveMode;};
            if ((A_stats_crimes select 0) >= 1500) exitWith {["disable", [1]] spawn life_fnc_passiveMode;};
            private _inWarzone = ((getPosATL player) inPolygon life_warzonePoly) || ((getPosATL player) inPolygon life_drugPenPoly);
            if (_inWarzone) exitWith {["disable", [2]] spawn life_fnc_passiveMode;};
            [] spawn {uiSleep 15;
                while {life_passivemode}
                do {if (A_stats_civTime > 120) exitWith {["stop"] spawn life_fnc_passiveMode;};
                    if ((A_stats_crimes select 0) >= 1500) exitWith {["disable", [1]] spawn life_fnc_passiveMode;};
                    private _inWarzone = ((getPosATL player) inPolygon life_warzonePoly) || ((getPosATL player) inPolygon life_drugPenPoly);
                    if (_inWarzone) exitWith {["disable", [2]] spawn life_fnc_passiveMode;};
                    uiSleep 20;};};}; case "initMessage": {if (!life_passivemode) exitWith {};
                [format["<t color='#FF0000'><t size='1.5'><t align='center'>Passive Mode<br/><br/></t></t></t>Since you are a new player, passive mode has been enabled.<br/><br/>This means you are not vulnerable to other civilians for 2 hours. Some features will be limited like picking up guns, etc.<br/><br/>Passive mode will be removed after 2 hours or when you choose to disable it in your Phone (Y) -> 'Passive' app. <br/><br/>It can also be TEMPORARY disabled which makes you vulnerable, but some features will still be disabled if you have the following things:<br/><br/>- Having a bounty of $1,500 or higher.<br/>- Being in an illegal area.<br/>- Using a firearm."], "warning"] spawn life_fnc_handleMessage;
            };
        case "disable": {_values params[["_type", 0, [0]]];
                if (!life_passivemode) exitWith {};
                life_passivemode = false;
                player setVariable["plb_passivemode", false, true];
                private _message =
                switch (_type) do {case 1: {"- Having a bounty of $1,500 or higher."};
                    case 2: {"- Being in an illegal area/zone."};
                    default {"- Having a bounty of $1,500 or higher.<br/>- Being in an illegal area/zone."};};
                [ format ["<t color='#FF0000'><t size='1.5'><t align='center'>Passive Mode<br/><br/></t></t></t>WARNING! You are now vulnerable again due to: <br/><br/><t color='#FF0000'>%1</t><br/><br/>Since you are in Passive Mode, some features are still disabled. You can disable Passive Mode completely in your Phone (Y) -> 'Passive' app.<br/><br/>To get unvulnerable again, make sure to follow the requirements and relog.", _message], "warning"] spawn life_fnc_handleMessage;
                [] call life_fnc_hudUpdate;};
        case "stopPhone": {if (!life_passiveModeJIP) exitWith {};
                private _action = ["Do you want to disable passive mode? This action cannot be undone.", "Passive Mode", "No", "Yes"] call BIS_fnc_GUIMessage;
                if (_action) exitWith {};
                life_passivemode = false;
                life_passiveModeJIP = false;
                player setVariable["plb_passivemode", false, true];
                [24] call life_fnc_ClupdatePartial;
                ["You have disabled passive mode!", "basic"] spawn life_fnc_handleMessage;
                [] call life_fnc_hudUpdate;};
        case "stop": {if (!life_passiveModeJIP) exitWith {};
                life_passivemode = false;
                life_passiveModeJIP = false;
                player setVariable["plb_passivemode", false, true];
                [24] call life_fnc_ClupdatePartial;
                [format["<t color='#FF0000'><t size='1.5'><t align='center'>Passive Mode<br/><br/></t></t></t>Passive mode has been disabled because you have reached 2 hours of playtime!"], "warning"] spawn life_fnc_handleMessage;
                [] call life_fnc_hudUpdate;};
        default {};};