params["_obj_main", "_stance", "_type"];
if (_obj_main isKindOf "CAManBase") then {};
switch (_type) do {case "vehicles": {_obj_main addAction["Access Factory Systems", {["vehicles"] call life_fnc_factory
            }, nil, 1.5, false, false, "", 'playerSide isEqualTo civilian', 5];}; case "weapons": {
                _obj_main addAction["Access Factory Systems", {["weapons"] call life_fnc_factory
                }, nil, 1.5, false, false, "", 'playerSide isEqualTo civilian', 5];};
        case "blackmarket": {_obj_main addAction["Black Market Production", {["blackmarket"] call life_fnc_factory
                }, nil, 0, false, false, "", 'playerSide isEqualTo civilian', 5];
                _obj_main addAction["Black Market", life_fnc_virtualShopMenu, "blackmarket", 0, false, false, "", 'playerSide isEqualTo civilian', 5];
                _obj_main addAction["Break Down Gold Bar", life_fnc_processAction, "goldnugget", 1.5, false, false, "", 'life_inv_goldbar > 0 && !life_is_processing', 5];
            };};