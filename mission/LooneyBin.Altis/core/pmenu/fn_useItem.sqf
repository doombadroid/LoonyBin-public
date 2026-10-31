disableSerialization;
if (player getVariable["plb_restrained", false]) exitWith {};
if ((lbCurSel 361001) isEqualTo - 1) exitWith {["You need to select an item first!", "basic"] spawn life_fnc_handleMessage};
private _item = lbData[361001, lbCurSel 361001];
switch (true) do {
    // owner 2026-07-20: cyberdeck consumables -- USE to ARM a one-shot effect on your next hack.
    case (_item isEqualTo "proxychain"): {
            if (player getVariable ["plb_proxyActive", false]) exitWith { ["Proxy Chain already active -- your next hack won't ping the APD.", "basic"] spawn life_fnc_handleMessage; };
            if ([false, "proxychain", 1] call life_fnc_handleInv) then {
                player setVariable ["plb_proxyActive", true, true];   // synced -> server-side hack alerts honour it
                ["<t color='#33ffbb'>PROXY CHAIN ACTIVE</t> -- your next hack leaves no trace for the APD.", "basic"] spawn life_fnc_handleMessage;
            };};
    case (_item isEqualTo "breachkit"): {
            if (plb_breachKitArmed) exitWith { ["Breach Kit already armed -- your next breach auto-completes.", "basic"] spawn life_fnc_handleMessage; };
            if ([false, "breachkit", 1] call life_fnc_handleInv) then {plb_breachKitArmed = true;
                ["<t color='#c9e21a'>BREACH KIT ARMED</t> -- your next Sequence or Terminal breach auto-completes.", "basic"] spawn life_fnc_handleMessage;
            };};
    // NEW DRACHMA: legacy loonycoin -> USE converts the WHOLE held stack straight to the wallet at
    // 1 coin = 1 ND (the intuitive path for coins pulled out of a house/trunk after the switch, which
    // the login sweep never saw). Server-authoritative credit; the item is consumed client-side first.
    case (_item isEqualTo "loonycoin"): {private _n = missionNamespace getVariable ["life_inv_loonycoin", 0];
            if (_n < 1) exitWith { ["You have no New Drachma coins to convert.", "basic"] spawn life_fnc_handleMessage; };
            if ([false, "loonycoin", _n] call life_fnc_handleInv) then {[format ["%1", _n], "coinsell"] call PLB_fnc_ndRequest;
                [format ["Converted %1 mined coin%2 to <t color='#5be39c'>%1 New Drachma</t>.", _n, ["s", ""] select (_n == 1)], "basic"] spawn life_fnc_handleMessage;
            };};
    // drop-only chip: USE installs the Plate Ghost quickhack permanently (id 201 in plb_cdMods)
    case (_item isEqualTo "ghostplatechip"): {
            if (201 in (player getVariable ["plb_cdMods", []])) exitWith { ["Ghost Plate Chip already installed -- Plate Ghost is on your deck.", "basic"] spawn life_fnc_handleMessage; };
            if !(call PLB_fnc_hasDeck) exitWith { ["You need ICEBREAKER firmware before this chip can install. Flash it at an electronics shop.", "basic"] spawn life_fnc_handleMessage; };
            if ([false, "ghostplatechip", 1] call life_fnc_handleInv) then {
                [["installHack", 201, player], "TON_fnc_cyberdeckSRV", 2] spawn life_fnc_MP;};};
    // drop-only Tier 4 chips + the ICE Firewall. Same shape as the Ghost Plate Chip: consume the item client
    // side, then the SERVER validates and writes the id into plb_cdMods (persisted). One table, one path.
    case (_item in ["blackoutdaemon", "flatlinecharge", "memoryholechip", "icefirewall", "puppetchip", "deadmanchip", "chauffeurchip",
                    "pingchip", "distractchip", "staticchip", "whiteoutchip", "stickychip", "jamchip", "wiretapchip",
                    "crybabychip", "synapsechip", "leechchip", "shortchip", "eyespychip", "valetchip",
                    "overclockchip", "coolingrigchip", "signalampchip", "scramblerchip", "opticfilterchip", "audiolimiterchip",
                    "hardenedfwchip", "deadboltchip", "freqhopchip", "encryptedsimchip", "surgechip", "copilotchip", "sealedtankchip"]): {
            // owner 2026-07-23: the chip->[id,label] map is now PLB_chipItemMap (configuration.sqf), the single
            // source shared with the PLB_itemDesc hover-text seed. Was an inline literal rebuilt on every USE.
            (PLB_chipItemMap get _item) params ["_hackId", "_label"];
            if !(call PLB_fnc_hasDeck) exitWith { ["You need ICEBREAKER firmware before this chip can install. Flash it at an electronics shop.", "basic"] spawn life_fnc_handleMessage; };
            // ICE Firewall re-arm cooldown (owner 2026-07-23): after one shatters, its firmware needs ~5 min
            // before it will seat another (plb_iceRearm set server-side on shatter). Blocks chain-replacing a
            // cheap consumable that hard-counters Tier-4-rarity hacks. Item stays in inventory to retry later.
            if (_hackId isEqualTo 108 && {serverTime < (player getVariable ["plb_iceRearm", 0])}) exitWith {
                private _secs = ceil ((player getVariable ["plb_iceRearm", 0]) - serverTime);
                [format ["ICE firmware still cooling down -- %1s before it can seat another firewall.", _secs], "basic"] spawn life_fnc_handleMessage;
            };
            // ALL of these are permanent installs (owner 2026-07-22 -- Flatline/Puppet no longer burn per
            // cast), so a duplicate chip is refused and the item stays in inventory (trade it away).
            // (108 ICE Firewall is the exception -- a consumable that re-installs after it shatters.)
            if (_hackId isNotEqualTo 108 && {_hackId in (player getVariable ["plb_cdMods", []])}) exitWith {
                [format ["%1 is already installed on your deck.", _label], "basic"] spawn life_fnc_handleMessage;};
            if ([false, _item, 1] call life_fnc_handleInv) then {
                [["installHack", _hackId, player], "TON_fnc_cyberdeckSRV", 2] spawn life_fnc_MP;};};
    case (_item isEqualTo ""): {
            ["Loot crate keys are used to open loot crates, which can get you awesome and rare rewards. You can find loot crates while exploring the world, but they can also be purchased from the market.", "basic"] spawn life_fnc_handleMessage;
        };
    case ((_item isEqualTo "water") || (_item isEqualTo "coffee") || (_item isEqualTo "soda")): {
            if ([false, _item, 1] call life_fnc_handleInv) then {plbv_thirst = 100;
                if (life_revive_fatigue isEqualTo 0) then {player setFatigue 0};
                [] call life_fnc_hudUpdate;
                [_item, 1] call life_fnc_statArrUpdate;};};
    case (_item in ["beer", "moonshine", "scotch_1", "scotch_2", "scotch_3", "rum_0", "rum_1", "rum_2", "rum_3"]): {
            [_item] spawn life_fnc_drinkAlcohol;};
    case (_item in ["canna_bong", "canna_rig", "canna_joint", "canna_vape", "canna_papers"]): {[_item] spawn life_fnc_cannabisItems;};
    case (_item in ["spraycan"]): {['sprayMenu'] call life_fnc_createDialog;};
    case (_item in ["marijuanam", "marijuana"]): {
            ["You must roll this into a joint or pack a bowl for a bong to smoke it!", "basic"] spawn life_fnc_handleMessage;};
    case (_item isEqualTo "ducttape"): {
            if (([false, "plateMetal", 1] call life_fnc_handleInv) && ([false, "ducttape", 1] call life_fnc_handleInv)) exitWith {
                [true, "shank", 1] call life_fnc_handleInv;
                ["You crafted a shank from this piece of sharp scrap metal and duct tape.", "basic"] spawn life_fnc_handleMessage;};
            ["You could craft a shank with this if you had something hard and sharp.", "basic"] spawn life_fnc_handleMessage;};
    case (_item isEqualTo "campfire"): {[] spawn life_fnc_campFire;};
    // phone-redux: removed the self-use "blindfold" case -- it called the undefined life_fnc_blindfold (LB only has
    // life_fnc_blindfoldClient, applied via the action menu on a RESTRAINED target, never self-used) and wrongly
    // consumed a blindfold first. The item now falls through to the default "not usable" path.
    case ((_item in ["", "lootcrate1"]) && (life_inv_lootcrate1 > 0)): {[1] call life_fnc_inspectLootCrate};
    case ((_item in ["", "lootcrate2"]) && (life_inv_lootcrate2 > 0)): {[2] call life_fnc_inspectLootCrate};
    case ((_item in ["", "lootcrate3"]) && (life_inv_lootcrate3 > 0)): {[3] call life_fnc_inspectLootCrate};
    case ((_item in ["", "lootcrate4"]) && (life_inv_lootcrate4 > 0)): {[4] call life_fnc_inspectLootCrate};
    case ((_item in ["", "lootcrate5"]) && (life_inv_lootcrate5 > 0)): {[5] call life_fnc_inspectLootCrate};
    case ((_item in ["", "lootcrate6"]) && (life_inv_lootcrate6 > 0)): {[6] call life_fnc_inspectLootCrate};
    case ((_item in ["", "lootcrate7"]) && (life_inv_lootcrate7 > 0)): {[7] call life_fnc_inspectLootCrate};
    case ((_item in ["", "lootcrate8"]) && (life_inv_lootcrate8 > 0)): {[8] call life_fnc_inspectLootCrate};
    case ((_item in ["", "lootcrate9"]) && (life_inv_lootcrate9 > 0)): {[9] call life_fnc_inspectLootCrate};
    case ((_item in ["", "lootcrate10"]) && (life_inv_lootcrate10 > 0)): {[10] call life_fnc_inspectLootCrate};
    case ((_item in ["", "lootcrate11"]) && (life_inv_lootcrate11 > 0)): {[11] call life_fnc_inspectLootCrate};
    case ((_item in ["", "lootcrate12"]) && (life_inv_lootcrate12 > 0)): {[12] call life_fnc_inspectLootCrate};
    case ((_item in ["", "lootcrate13"]) && (life_inv_lootcrate13 > 0)): {[13] call life_fnc_inspectLootCrate};
    case ((_item in ["", "lootcrate14"]) && (life_inv_lootcrate14 > 0)): {[14] call life_fnc_inspectLootCrate};
    case ((_item in ["", "lootcrate15"]) && (life_inv_lootcrate15 > 0)): {[15] call life_fnc_inspectLootCrate};
    case ((_item in ["", "lootcrate16"]) && (life_inv_lootcrate16 > 0)): {[16] call life_fnc_inspectLootCrate};
    case ((_item in ["", "lootcrate17"]) && (life_inv_lootcrate17 > 0)): {[17] call life_fnc_inspectLootCrate};
    case (_item isEqualTo "cratekey_0" && {life_lootKeys select 0 > 0}): {[1] call life_fnc_inspectLootCrate};
    case (_item isEqualTo "cratekey_1" && {life_lootKeys select 1 > 0}): {[2] call life_fnc_inspectLootCrate};
    case (_item isEqualTo "cratekey_2" && {life_lootKeys select 2 > 0}): {[3] call life_fnc_inspectLootCrate};
    case (_item isEqualTo "cratekey_3" && {life_lootKeys select 3 > 0}): {[4] call life_fnc_inspectLootCrate};
    case (_item isEqualTo "cratekey_4" && {life_lootKeys select 4 > 0}): {[5] call life_fnc_inspectLootCrate};
    case (_item isEqualTo "cratekey_5" && {life_lootKeys select 5 > 0}): {[6] call life_fnc_inspectLootCrate};
    case (_item isEqualTo "cratekey_6" && {life_lootKeys select 6 > 0}): {[7] call life_fnc_inspectLootCrate};
    case (_item isEqualTo "cratekey_7" && {life_lootKeys select 7 > 0}): {[8] call life_fnc_inspectLootCrate};
    case (_item isEqualTo "cratekey_8" && {life_lootKeys select 8 > 0}): {[9] call life_fnc_inspectLootCrate};
    case (_item isEqualTo "cratekey_9" && {life_lootKeys select 9 > 0}): {[10] call life_fnc_inspectLootCrate};
    case (_item isEqualTo "cratekey_10" && {life_lootKeys select 10 > 0}): {[11] call life_fnc_inspectLootCrate};
    case (_item isEqualTo "cratekey_11" && {life_lootKeys select 11 > 0}): {[12] call life_fnc_inspectLootCrate};
    case (_item isEqualTo "cratekey_12" && {life_lootKeys select 12 > 0}): {[13] call life_fnc_inspectLootCrate};
    case (_item isEqualTo "cratekey_13" && {life_lootKeys select 13 > 0}): {[14] call life_fnc_inspectLootCrate};
    case (_item isEqualTo "cratekey_14" && {life_lootKeys select 14 > 0}): {[15] call life_fnc_inspectLootCrate};
    case (_item isEqualTo "cratekey_15" && {life_lootKeys select 15 > 0}): {[16] call life_fnc_inspectLootCrate};
    case (_item isEqualTo "cratekey_16" && {life_lootKeys select 16 > 0}): {[17] call life_fnc_inspectLootCrate};
    case (_item in ["giftAdmin", "giftHallo", "giftXmas"]): {[_item] call life_fnc_openGift;};
    case (_item in ["defib", "bloodbag"]): {
            titleText["This item is used via the action menu while looking at an injured person.", "PLAIN DOWN"]};
    case (_item isEqualTo "redgull"): {while {dialog}
            do {closeDialog 0};
            [] spawn life_fnc_redgull;};
    case (_item isEqualTo "supermale"): {while {dialog} do {closeDialog 0};
            [] spawn life_fnc_supermale;};
    case (_item isEqualTo "pparachute"): {[] spawn life_fnc_pocketparachute;};
    case (_item isEqualTo "vammo"): {[] spawn life_fnc_vehAmmo};
    case (_item isEqualTo "protest"): {[] spawn life_fnc_protest};
    // owner 2026-07-10: RESTORED -- the phone-redux import (54a4411) overwrote this file and dropped the
    // furniture routing, so every furn_* item fell through to the default "This item is not usable".
    // Verbatim from the pre-redux file: civilian-only here; the owned-house/20m gates live in
    // fn_holdObject / fn_placeObject, and persistence in TON_fnc_houseFurnitureSRV.
    case (_item in PLB_furnitureItems): {if !(playerSide isEqualTo civilian) exitWith {
                ["Only civilians can place house furniture.", "basic"] spawn life_fnc_handleMessage};
            [_item] spawn life_fnc_holdObject;};
    case (_item in ["roadBarrierSmall", "roadConelight", "roadCone", "roadBarrier", "cncBarrier", "cncBarrierL", "barGate", "bagwallshort", "bagwalllong", "bagwallround", "razorwire", "ied"]):
        {
            if ((playerSide isEqualTo independent) && (_item in ["roadBarrier", "roadBarrierSmall", "roadConelight", "roadCone"]) && !((call life_medicLevel) >= 1)) exitWith {
                ["You must be AEMT+ to use this item!", "basic"] spawn life_fnc_handleMessage;};
            [_item] spawn life_fnc_holdObject;};
    case (_item isEqualTo "pcp"): {if ([false, _item, 1] call life_fnc_handleInv) then {[] spawn life_fnc_pcp;};};
    case (_item isEqualTo "spikeStrip"): {if (([false, _item, 1] call life_fnc_handleInv)) then {[] spawn life_fnc_spikeStrip};};
    case (_item isEqualTo "excavator"): {[] spawn life_fnc_searchWreck};
    case (_item isEqualTo "nitro"): {[cursorObject] spawn life_fnc_nitro};
    case (_item isEqualTo "speedbomb"): {[] spawn life_fnc_speedBomb;};
    case (_item isEqualTo "ignitionbomb"): {if (isNull objectParent player) then {
                ["You must be in the driver seat of a vehicle to use this."] spawn life_fnc_handleMessage;} else {closeDialog 0;
                [vehicle player] spawn life_fnc_ignitionBomb;};};
    case (_item in ["caralarm", "airalarm"]): {[cursorObject, _item] spawn life_fnc_alarm};
    case (_item isEqualTo "manflesh"): {
            ["Human organs can't be eaten. Maybe if they were cooked on a fire?", "basic"] spawn life_fnc_handleMessage};
    case (_item isEqualTo "fuelF"): {if !((vehicle player) isEqualTo player) exitWith {
                ["You can't refuel the vehicle while in it!", "basic"] spawn life_fnc_handleMessage};
            [] spawn life_fnc_jerryRefuel;};
    case (_item isEqualTo "adrenalineShot"): {[nil, nil, nil, player] spawn life_fnc_adrenalineShot;};
    case (_item isEqualTo "boltCutter"): {if (cursorObject isKindOf "CAManBase") then {[cursorObject, true] spawn life_fnc_lockpick;};};
    case (_item in ["manfleshp", "berry", "apple", "salema", "ornate", "mackerel", "tuna", "mullet", "catshark", "turtle", "turtlesoup", "donuts", "tbacon", "peach", "redburger", "chickenp", "dogp", "sheepp", "goatp", "rabbitp", "snakep", "kebab", "donerkebab", "pizza_cheese", "pizza_pepperoni", "pizza_hawaiian", "pizza_supreme"]):
        {[_item] call life_fnc_eatFood};
    case (_item isEqualTo "tracker"): {[cursorObject] spawn life_fnc_tracker};
    case (_item in ["cocainep", "cokebrick"]): {[] spawn life_fnc_cocaine};
    case (_item isEqualTo "heroinp"): {[] spawn life_fnc_heroin};
    case (_item in ["meth", "bluemeth"]): {[] spawn life_fnc_meth};
    case (_item in ["lsd_0", "lsd_1"]): {[_item] spawn life_fnc_lsd};
    case (_item isEqualTo "crankp"): {[] spawn life_fnc_crank};
    case (_item in ["tent1", "tent2"]): {[_item] spawn life_fnc_tent};
    case (_item isEqualTo "bank_money"): {if (playerSide isEqualTo west) then {
                ["This item must be seized via HQ/Vehicle", "basic"] spawn life_fnc_handleMessage;} else {
                if ((serverTime - (life_bank_robbed select 1)) < 400) exitWith {
                    ["The dye packs are still active, so you can't break the money bands yet.", "basic"] spawn life_fnc_handleMessage;};
                life_cash = life_cash + life_inv_bank_money;
                life_ucashCacheC = ((life_cash / 2) + 5);
                [format["You have broken down %1 banded bank money into cash.", [life_inv_bank_money] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
                ["bankmoneyconv", life_inv_bank_money] call life_fnc_statArrUpdate;
                life_inv_bank_money = 0;};};
    case (_item isEqualTo "treasuremap"): {[] spawn life_fnc_treasureMapOpen;};
    case (_item isEqualTo "medDrop"): {if !(playerSide isEqualTo independent) exitWith {
                ["This signal flare is for medics only!", "basic"] spawn life_fnc_handleMessage;};
            if !((call life_medicLevel) >= 3) exitWith {
                ["Your medic rank does not permit using this!", "basic"] spawn life_fnc_handleMessage;};
            private _nearCrates = vehicles select {((typeOf _x) isEqualTo "C_IDAP_supplyCrate_F") && ((((_x getVariable["plb_vehOwners", [
                    ["", ""]]]) select 0) select 0) isEqualTo(getPlayerUID player))};
            if (count _nearCrates >= 1) exitWith {["You can only have one active supply crate!", "basic"] spawn life_fnc_handleMessage;};
            if (SRV_lastMedSupply > serverTime - 900) exitWith {
                ["You can only call a supply crate every 15 minutes.", "basic"] spawn life_fnc_handleMessage;};
            if !([false, "medDrop", 1] call life_fnc_handleInv) exitWith {}; [[player], "TON_fnc_medSupplySpawn", 2] call life_fnc_MP;};
    case (_item isEqualTo "painkillers"): {if ([false, _item, 1] call life_fnc_handleInv) then { [player] spawn life_fnc_painkillers; }};
    case (_item in ["ifrit", "ammo", "orca", "weapDrop", "hummingbird", "boxtruck", "qilin"]): {
            if !(playerSide isEqualTo civilian) exitWith {
                ["This care package can only be called in by civilians!", "basic"] spawn life_fnc_handleMessage;};
            if ((player distance(getMarkerPos "city") < 800) || (player distance(getMarkerPos "civ_spawn_1") < 800) || (player distance(getMarkerPos "civ_spawn_3") < 800) || (player distance(getMarkerPos "donor_town") < 800) || (player distance(getMarkerPos "civ_spawn_4") < 800) || (player distance(getMarkerPos "civ_spawn_2") < 800)) exitWith {
                ["You're too close to a town. The aircraft cannot be called here.", "basic"] spawn life_fnc_handleMessage;};
            if !(isNull objectParent player) exitWith {
                ["You cannot request a care package while inside another vehicle.", "basic"] spawn life_fnc_handleMessage;};
            if (player distance(getMarkerPos "casino_marker") < 350) exitWith {
                ["You're too close to the casino's restricted airspace.", "basic"] spawn life_fnc_handleMessage;};
            if (surfaceIsWater(getPosATL player)) exitWith {
                ["You cannot request a care package in water.", "basic"] spawn life_fnc_handleMessage;};
            if (player distance(getMarkerPos "courtroom") < 300) exitWith {["Really???", "basic"] spawn life_fnc_handleMessage;};
            if (player distance(getMarkerPos "Respawn_west") < 1000) exitWith {["Really???", "basic"] spawn life_fnc_handleMessage;};
            if ((count(nearestTerrainObjects[(getPosATL player), ["House"], 4, true, true])) > 0) exitWith {
                ["You're too close to a house. It could end up on the roof.", "basic"] spawn life_fnc_handleMessage;};
            private _carePackageTalents = [["ifrit", 50], ["hummingbird", 48], ["orca", 49], ["boxtruck", 46], ["qilin", 47],
                ["weapDrop", -1], ["ammo", -1]];
            private _talentID = (_carePackageTalents select {_x select 0 isEqualTo _item}) param[0, [-1, -1]] select 1;
            if (_talentID > -1 && !((_talentID in life_infamy_talents) || (_talentID in life_honor_talents))) exitWith {
                ["You do not have the required prestige talent to call this care package.", "basic"] spawn life_fnc_handleMessage;};
            if !([false, _item, 1] call life_fnc_handleInv) exitWith {}; [
                [player, _item], "TON_fnc_rebelCarePackages", 2] call life_fnc_MP;};
    case (_item in ["quad", "hatchback", "offroad", "hatchback2"]): {[_item] spawn life_fnc_pocketCars};
    case (_item isEqualTo "distressBeacon"): {[] spawn life_fnc_distressBeacon;};
    case (_item isEqualTo "cyberdeck"): {[cursorObject] spawn life_fnc_cyberdeck};
    default {["This item is not usable", "basic"] spawn life_fnc_handleMessage;};};
[ false ] spawn life_fnc_inventory;
[] call life_fnc_hudUpdate;
