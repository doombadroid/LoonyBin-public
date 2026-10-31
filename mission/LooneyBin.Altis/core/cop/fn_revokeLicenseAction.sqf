params[["_cop", objNull, [objNull]], ["_type", "", [""]], ["_bool", false, [true]]];
if (isNull _cop) exitWith {};
switch (_type) do {case "driver": {license_civ_driver = false;
            [format["Your Drivers License was revoked by %1.", [name _cop] call life_fnc_cleanName], "basic"] spawn life_fnc_handleMessage;
            systemChat format["Your Drivers License was revoked by %1.", name _cop];}; case "bounty": {license_civ_bounty = false;
                if (_bool) then {
                    [format["Your Bounty Hunter License was revoked for the remaining duration of the server cycle by %1.", [name _cop] call life_fnc_cleanName], "basic"] spawn life_fnc_handleMessage;
                    systemChat format["Your Bounty Hunter License was revoked for the remaining duration of the server cycle by %1.", name _cop];
                } else {
                    [format["Your Bounty Hunter License was revoked by %1.", [name _cop] call life_fnc_cleanName], "basic"] spawn life_fnc_handleMessage;
                    systemChat format["Your Bounty Hunter License was revoked by %1.", name _cop];};
                player setVariable["plb_isBountyHunter", false, true];};};
[ 2 ] call life_fnc_ClupdatePartial;