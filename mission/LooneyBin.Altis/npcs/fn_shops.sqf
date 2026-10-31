params["_obj_main", "_stance", ["_type", "", [""]]];
if (_obj_main isKindOf "CAManBase") then {};
// owner 2026-06-13 (#170): block the building this shop NPC sits in from being bought as a house. The
// plb_restricted_house guard exists in fn_buyHouse/fn_houseMenu but was NEVER set anywhere, so NPC shop
// buildings (e.g. the Kavala gun store) were purchasable. Flag the nearest house-type building (runs per
// client when the NPC spawns; fn_buyHouse reads the flag locally on the buyer).
if (!isNull _obj_main) then {private _ht = if (isNil "life_houseTypes") then { ["House_F"] } else { life_houseTypes };
    // owner 2026-06-20: flag the nearest UN-OWNED house-type building (the shop's own building), SKIPPING registered
    // player houses. A player house that happens to sit within 10m of a shop NPC (e.g. the Athira big house by the
    // market, oid 1403618707) was being grabbed as the "nearest" and flagged plb_restricted_house=true -> the owner
    // lost their House Menu + grab-ID. Owned houses carry plb_homeOwner (set by fn_receiveHouses/_tagHouses, broadcast
    // global) so a connecting client sees it here; iterate by distance and flag the first that ISN'T an owned house.
    {if ((_x getVariable ["plb_homeOwner", ""]) isEqualTo "") exitWith { _x setVariable ["plb_restricted_house", true]; };
    } forEach (nearestObjects [getPosATL _obj_main, _ht, 10]);};
switch (_type) do {case "wongs": {
            _obj_main addAction["Wong's Food Court", life_fnc_virtualShopMenu, _type, 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player', 5];
            _obj_main setVariable["plb_name", "Wong The Dong"]}; case "redburger": {
                _obj_main addAction["Red Burger", life_fnc_virtualShopMenu, _type, 1.5, false, false, "", '', 5];};
        case "diamond": {
                _obj_main addAction["Jewelry Store", life_fnc_virtualShopMenu, _type, 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player', 5];
            };
        case "oil": {
                _obj_main addAction["Oil Trader", life_fnc_virtualShopMenu, _type, 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player', 5];
            };
        case "paintshop": {
                _obj_main addAction["Pay 'n' Spray", life_fnc_vehicleSkinShopMenu, _type, 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player', 5];
            };
        case "home": {_obj_main addAction["Locate Homes for Sale", {
                    ["Houses listed for sale by owner have been marked on your map.", "basic"] spawn life_fnc_handleMessage;
                    private _houses = (player nearObjects["House_F", 25000]) select {_x getVariable["plb_house_price", -1] > 1}; {
                        private _marker = createMarkerLocal[format["listhouse_%1", _forEachIndex], getPos _x];
                        _marker setMarkerTypeLocal "hd_warning";
                        _marker setMarkerColorLocal "colorRed";
                        _marker setMarkerTextLocal format["House For Sale: $%1", [_x getVariable "plb_house_price"] call life_fnc_numberText];
                        life_houseListMarkers pushBack _marker;}
                    forEach _houses;
                }, nil, 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player && life_houseListMarkers isEqualTo []', 6];
                _obj_main addAction["Remove House Markers", {["Markers removed from your map.", "basic"] spawn life_fnc_handleMessage; {
                        deleteMarkerLocal _x}
                    forEach life_houseListMarkers;
                    life_houseListMarkers = []
                }, "", 1.5, false, false, "", '!(life_houseListMarkers isEqualTo []) && playerSide isEqualTo civilian && isNull objectParent player', 5];
            };
        case "fishmarket": {
                _obj_main addAction["Fish Market", life_fnc_virtualShopMenu, _type, 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player', 5];
            };
        case "salt": {
                _obj_main addAction["Salt Trader", life_fnc_virtualShopMenu, _type, 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player', 5];
            };
        case "market": {
                _obj_main addAction["Market", life_fnc_virtualShopMenu, _type, 1.5, false, false, "", 'isNull objectParent player', 5];};
        case "heroin": {
                _obj_main addAction["Drug Dealer", life_fnc_virtualShopMenu, _type, 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player', 5];
                _obj_main addAction["<t color='#ff547f'>Sell Vehicle Inventory</t>", life_fnc_sellVehicleInv, _type, 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player && !(missionNamespace getVariable ["plb_bulkSell", false])', 5];
                _obj_main addAction["<img image='mpmissions\__cur_mp.altis\icons\cannabisplant.paa' /> <t color='#ff547f'>Dry Indica Plant</t>", life_fnc_processAction, "cannai_2", 1.5, false, false, "", 'life_inv_cannai_2 > 0 && !life_is_processing && playerSide isEqualTo civilian', 5];
                _obj_main addAction["<img image='mpmissions\__cur_mp.altis\icons\cannabisplant.paa' /> <t color='#ff547f'>Dry Sativa Plant</t>", life_fnc_processAction, "cannas_2", 1.5, false, false, "", 'life_inv_cannas_2 > 0 && !life_is_processing && playerSide isEqualTo civilian', 5];
                // owner 2026-06-22: bud -> Golden Wax REMOVED from the Drug Dealer -- wax is now made ONLY at the weed
                // processor (fn_civProcessItem "marijuana" case: hand "Process Indica Bud into Golden Wax" + the bulk
                // vehicle option). The plant -> bud DRYING actions above STAY at the dealer; only the bud -> wax step
                // moved back to weed-processing-only. (Reverses the 2026-06-14 "wax at every dealer" change.)
            };
        case "commod": {
                _obj_main addAction["Commodities Trading", life_fnc_virtualShopMenu, _type, 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player', 5];
            };
        case "gun": {
                _obj_main addAction["Firearm License ($250)", life_fnc_buyLicense, _type, 1.5, false, false, "", '!license_civ_gun && playerSide isEqualTo civilian', 5];
                _obj_main addAction["Gun Store", life_fnc_weaponShopMenu, _type, 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player && license_civ_gun', 5];
            };
        case "genstore": {
                _obj_main addAction["General Store", life_fnc_weaponShopMenu, "genstore", 1.5, false, false, "", 'isNull objectParent player', 5];
            };
        case "civ": {
                _obj_main addAction["Clothing Shop", life_fnc_clothingMenu, _type, 1.5, false, false, "", 'isNull objectParent player', 5];
            };
        case "dive": {
                _obj_main addAction["Diving License ($200)", life_fnc_buyLicense, 'dive', 1.5, false, false, "", '!license_civ_dive && playerSide isEqualTo civilian', 5];
                _obj_main addAction["Diving Shop", life_fnc_clothingMenu, _type, 1.5, false, false, "", 'license_civ_dive && playerSide isEqualTo civilian', 5];
            };
        case "vig": {
                _obj_main addAction["Bounty Hunter Training ($6,500) <t color='#FF0000'>(replace rebel)</t>", life_fnc_buyLicense, "bounty", 1.5, false, false, "", '!license_civ_bounty && playerSide isEqualTo civilian && (1 in life_side_talents)', 5];
                _obj_main addAction["Bounty Hunter Shop", life_fnc_weaponShopMenu, "bounty", 1.5, false, false, "", 'license_civ_bounty && playerSide isEqualTo civilian', 5];
                _obj_main addAction["Bounty Hunter Item Shop", life_fnc_virtualShopMenu, _type, 1.5, false, false, "", 'license_civ_bounty && playerSide isEqualTo civilian', 5];
                _obj_main addAction["Request Bounty", {[] call life_fnc_requestBounty
                }, nil, 1.5, false, false, "", 'license_civ_bounty && playerSide isEqualTo civilian', 5];
                _obj_main addAction["<t color='#ADFF2F'>ATM</t>", {[] call life_fnc_atmMenu
                }, nil, 2, true, true, "", 'isNull objectParent player', 5];
                _obj_main addAction["<t color='#FFFF2F'>Gang Account</t>", {[] call life_fnc_gangAtmMenu
                }, nil, 2, true, true, "", '(count life_gang_data > 0)', 5];};
        case "laser": {
                _obj_main addAction["Queue for Laser tag", life_fnc_laserJoin, "", 0, false, false, "", ' playerSide isEqualTo civilian', 5];
            };
        case "medicaldispensary": {
                _obj_main addAction["Medical Dispensary", life_fnc_virtualShopMenu, _type, 1.5, false, false, "", 'isNull objectParent player', 5];
            };
        case "tech": {
                // owner 2026-07-23: the per-module scroll-buy loop is GONE -- deck modules + firewall permanents
                // sell as $1M chips in the Kabuki virtual shop (USE installs; see fn_virt_shops / fn_useItem).
                // Only the two bootstrap actions remain on the NPC: firmware flash + VR goggles.
                // FLASH FIRMWARE ($1,000) -- the Cyberdeck is no longer an item; this is what turns your phone into a deck.
                _obj_main addAction [
                    "<t color='#ff5a3c'>Flash Cyberdeck Firmware</t> <t color='#c9e21a'>($1,000)</t> <t color='#7f918a'>-- enables ICEBREAKER OS</t>",
                    { [0] call life_fnc_cyberdeckBuyModule }, nil, 1.6, false, false, "",
                    "playerSide isEqualTo civilian && isNull objectParent player && !(call PLB_fnc_hasDeck)", 5];
                // VR GOGGLES ($1,000) -- the visor half of the deck: unlocks the SHIFT+Y quick-hack ring.
                _obj_main addAction ["Buy VR Goggles <t color='#c9e21a'>($1,000)</t> <t color='#7f918a'>-- SHIFT+Y visor ring</t>", {
                        private _paid = if (life_cash >= 1000) then { ["cash", "take", 1000] call life_fnc_uC }
                                        else { (life_inv_debitcard >= 1) && {["atm", "take", 1000] call life_fnc_uC} };
                        if !(_paid) exitWith { ["You need $1,000 -- cash, or bank with a debit card.", "basic"] spawn life_fnc_handleMessage; };
                        player addGoggles "G_Goggles_VR";
                        ["<t color='#c9e21a'>VR GOGGLES</t> -- visor online. Wear them and press <t color='#c9e21a'>SHIFT+Y</t> for the quick-hack ring.", "basic"] spawn life_fnc_handleMessage;
                    }, nil, 1.5, false, false, "",
                    "playerSide isEqualTo civilian && isNull objectParent player && !((goggles player) isEqualTo 'G_Goggles_VR')", 5];
                // the store: consumables + every purchasable chip (T1 hacks, modules, firewall permanents)
                _obj_main addAction ["<t color='#33ffbb'>Kabuki Electronics -- Chips & Consumables</t>", life_fnc_virtualShopMenu, _type, 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player', 5];
                // CHIP RECYCLER (owner 2026-07-23): melt 3 duplicate hack chips into 1 random Tier-3 chip.
                _obj_main addAction ["<t color='#c9e21a'>Chip Recycler</t> <t color='#7f918a'>-- melt 3 chips into 1 random Tier 3</t>", { [] spawn life_fnc_qhRecycle; }, nil, 1.5, false, false, "", 'playerSide isEqualTo civilian && isNull objectParent player && (call PLB_fnc_hasDeck)', 5];
            };};