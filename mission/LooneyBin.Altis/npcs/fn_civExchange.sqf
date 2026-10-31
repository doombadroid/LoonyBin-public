params["_obj_main", "_stance"];
if (_obj_main isKindOf "CAManBase") then {};
_obj_main addAction["<t color='#4DF53E'>LoonyBin Grand Exchange</t>", life_fnc_exchangeMenu, nil, 1.5, false, false, "", 'playerSide isEqualTo civilian', 5];
_obj_main addAction["<t color='#4DF53E'>LoonyBin Exchange Storage</t>", life_fnc_exchangeStorageMenu, nil, 1.5, false, false, "", 'playerSide isEqualTo civilian', 5];
_obj_main addAction["<t color='#4DF53E'>LoonyBin Exchange - List Virtual Items</t>", life_fnc_exchangeCreateListing, "virtualItem", 1.5, false, false, "", 'playerSide isEqualTo civilian', 5];
_obj_main addAction["<t color='#4DF53E'>LoonyBin Exchange - List Physical Items</t>", life_fnc_exchangeCreateListing, "physicalItem", 1.5, false, false, "", 'playerSide isEqualTo civilian', 5];
_obj_main addAction["<t color='#FF7400'>Check Mailbox</t>", {[] call life_fnc_checkMailbox
}, nil, 1.5, true, true, "", 'playerSide isEqualTo civilian', 5];