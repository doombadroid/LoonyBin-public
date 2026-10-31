#include "..\..\macro.h"
params[["_mode", "", ["", 0]], ["_shop", "", [""]], ["_className", "", [""]], ["_vehicle", objNull, [objNull]]];
if (_mode isEqualTo "") exitWith {};
if (_mode isEqualTo "getSellPrice" && {isNull _vehicle}) exitWith {};
// LooneyBin 2026-06-12: server-safe (TON_fnc_srvSellVehicle calls "getVehicleRowParsed" server-side for an
// authoritative sell-back; the dedicated server / HC has no player, so life_copLevel/life_medicLevel would
// throw). These two are unused by the getVehicleRowParsed/getEconList price paths anyway.
private _copLevel = if (hasInterface) then {call life_copLevel} else {0};
private _medicLevel = if (hasInterface) then {call life_medicLevel} else {0};
// LooneyBin NG patch: Volunteers (level 99) get same vehicle access as Privates (level 1)
if (_medicLevel isEqualTo 99) then { _medicLevel = 1; };
private _donorLevel = 10;
if (isNil "PLB_vehConfigTable") then { PLB_vehConfigTable = [
    // owner 2026-06-20 (Payton): SWAT garage consolidated to ONE of each at set prices. Strider $15k, Hunter $15k,
    // Prowler $6k, Van $6k. The duplicate (pricier) copies elsewhere in this config had their swat_car flag stripped
    // so the SWAT shop shows this clean dedicated block only. SWAT pulls are unlimited (fn_vehicleShopBuy).
    ["O_MRAP_02_F", "", [west], ["srt_car", "swat_car"], 0, 0, 0, 15000, 12000, 2000, 900, [], [50, 50, 50]], ["B_MRAP_01_F", "", [west],
        ["srt_car", "swat_car"], 0, 0, 0, 15000, 12000, 2000, 900, [], [50, 50, 50]], ["I_MRAP_03_F", "", [west],
        ["srt_car", "swat_car"], 0, 0, 0, 15000, 12000, 2000, 900, [], [50, 50, 50]], ["B_T_LSV_01_unarmed_F", "", [west],
        ["srt_car", "swat_car"], 0, 0, 0, 6000, 3000, 2000, 900, [], [50, 50, 50]], ["O_T_LSV_02_unarmed_F", "", [west],
        ["srt_car", "swat_car"], 0, 0, 0, 5000, 3000, 2000, 900, [], [50, 50, 50]], ["O_Heli_Light_02_unarmed_F", "", [west],
        ["srt_car", "swat_car"], 0, 0, 0, 20000, 15000, 2000, 900, [], [50, 50, 50]], ["C_Van_02_transport_F", "", [west],
        ["srt_car", "swat_car"], 0, 0, 0, 6000, 3000, 2000, 900, [], [60, 60, 60]], ["B_T_VTOL_01_infantry_F", "", [west],
        ["cop_air"], 6, 0, 0, 200000, 100000, 2000, 3000, [], [50, 50, 50]], ["B_T_Boat_Transport_02_F", "", [west],
        ["cop_ship"], 3, 0, 0, 8000, 4000, 1000, 500, [], [50, 50, 50]], ["C_Kart_01_Blu_F", "", [civilian],
        ["civ_kart"], 0, 0, 0, 250, 175, 0, 10, [], [0, 0, 0]], ["C_Kart_01_Fuel_F", "", [civilian],
        ["civ_kart"], 0, 0, 0, 250, 175, 0, 10, [], [0, 0, 0]], ["C_Kart_01_Red_F", "", [civilian],
        ["civ_kart"], 0, 0, 0, 250, 175, 0, 10, [], [0, 0, 0]], ["C_Kart_01_Vrana_F", "", [civilian],
        ["civ_kart"], 0, 0, 0, 250, 175, 0, 10, [], [0, 0, 0]], ["B_Quadbike_01_F", "", [civilian],
        ["civ_car", "reb_car"], 0, 0, 0, 200, 100, 0, 50, [], [10, 10, 10]], ["I_Quadbike_01_F", "", [west],
        ["cop_car"], 1, 0, 0, 150, 75, 0, 0, [], [10, 10, 10]], ["C_Quadbike_01_black_F", "", [independent],
        ["med_car"], 0, 1, 0, 150, 75, 0, 0, [], [10, 10, 10]], ["C_Hatchback_01_F", "", [civilian, west],
        ["civ_car", "cop_car", "reb_car"], 0, 0, 0, 750, 500, 150, 100, [], [34, 34, 34], 24],
    ["C_Offroad_01_F", "", [civilian, west, independent], ["civ_car", "cop_car", "med_car"], 1, 1, 0, [2500, 500, 500], [1500, 250, 400],
        [250, 250, 250], [150, 150, 0], [], [42, 42, 42], 25], ["C_Offroad_01_repair_F", "", [independent],
        ["med_car"], 0, 2, 0, 800, 400, 250, 100, [], [42, 42, 42]], ["C_Offroad_01_comms_F", "", [west, independent],
        ["cop_car", "med_car"], 0, 3, 0, [4000, 3000, 3000], [1500, 1500, 1500], [250, 250, 250], [300, 300, 300], [], [42, 42, 42]],
    ["C_Offroad_01_covered_F", "", [civilian], ["civ_car"], 3, 3, 0, 4000, 1500, 250, 300, [], [42, 42, 42]],
    ["B_G_Offroad_01_F", "", [civilian, west], ["reb_car", "bh_car", "cop_car"], 0, 0, 0, [3000, 3000, 3000], [1500, 1500, 1500],
        [350, 350, 350], [150, 150, 150], [], [42, 42, 42], 26], ["B_G_Offroad_01_armed_F", "", [civilian],
        ["reb_car", "nd_car"], 0, 0, 0, 100000, 50000, 3000, 0, [19], [42, 42, 42]], ["C_SUV_01_F", "", [civilian, west, independent],
        ["civ_car", "med_car", "bh_car", "cop_car"], 2, 2, 0, [3500, 3500, 3500], [1500, 1500, 1500], [200, 200, 200], [125, 125, 125],
        [100, 112], [34, 34, 34], 26], ["C_Van_02_medevac_F", "", [independent], ["med_car"], 0, 2, 0, 5000, 1250, 350, 0, [112],
        [50, 50, 50]],
    ["C_Hatchback_01_sport_F", "", [civilian, west, independent], ["civ_car", "med_car", "bh_car", "cop_car", "reb_car"], 2, 1, 0, [6500, 5000, 5000], [2250, 2500, 2500], [235, 235, 235], [100, 100, 100], [100], [34, 34, 34], 26],
    ["C_Van_01_transport_F", "", [civilian, west],
        ["civ_car", "bh_car", "cop_car", "civ_truck"], 1, 0, 0, 8500, 5000, 750, 250, [],   // owner 2026-06-17 (#314): transport van was cop-LEVEL 3 (corporal+) so low-rank APD saw "no van in the shop". Dropped to 1 (constable+) -- the prisoner-transport van is standard APD kit.
        [50, 50, 50], 26], ["O_MRAP_02_F", "", [civilian, west], ["reb_car", "nd_car", "cop_car"], 5, 0, 0, [120000, 65000, 0],
        [70000, 27500, 0], [3000, 1500, 0], [120, 120, 0], [19], [34, 34, 34]],
    // LooneyBin (owner, 2026-06-11): Ifrit HMG (machine gun, NOT the GMG) -> rebel shop
    // owner 2026-06-19: REMOVED from rebel store (shop keys emptied; was ["reb_car","nd_car"]). Entry kept so existing units keep sell-back/chop price.
    // owner 2026-07-24: REMOVED from the shop again (shop keys emptied). The RCWS zoom + T auto-range can't be
    // nerfed server-side (client-rendered optic; mission config can't override a base vehicle's turret -- proven
    // via merged-config dump), so the armed HMG is un-limitable and too strong. Entry kept for existing units'
    // sell-back/chop price. (Was ["nd_car"] @ 60 ND for ~a day this session.)
    // owner 2026-07-24 FIX (money printer reopened by 87e30d4): emptying the shop-key list to pull the Ifrit
    // from the shop ALSO cleared its ND marker, because both payout paths derive "is this an ND vehicle" from
    // this same list ("nd_car" in idx 3). An Ifrit bought for 60 ND then sold/chopped back for CASH. The list
    // was doing double duty: "which shops sell it" AND "what currency it settles in". "nd_priced" is a
    // currency-only sentinel -- shops match with `_shop in (_x select 3)` against real shop names, so it can
    // never list the vehicle anywhere, but the sell/chop paths now still recognise it as ND.
    ["O_MRAP_02_hmg_F", "", [civilian], ["nd_priced"], 0, 0, 0, [350000, 0, 0], [150000, 0, 0], [5000, 0, 0], [120, 0, 0], [19],
        [34, 34, 34]],
    // owner 2026-07-23: AWC Nyx (autocannon variant sold as a TURRETLESS armored hull -- turret hidden by
    // the civ_nyx preset in fn_vehicleAnimate, all turret mags stripped in fn_clearVehicleAmmo) -> ND
    // shop (33.3333 ND). Caliber gate in fn_handleVehicleDamage: nothing under 7.62 hurts it.
    ["I_LT_01_cannon_F", "AWC Nyx", [civilian], ["nd_car"], 0, 0, 0, [200000, 0, 0], [80000, 0, 0], [5000, 0, 0], [120, 0, 0], [],
        [40, 40, 40]], ["B_MRAP_01_F", "", [civilian, west, independent],
        ["bh_car", "cop_car", "med_car"], 3, 3, 0, [60000, 30000, 30000],   // owner 2026-06-20 (Payton): swat_car stripped -- SWAT Hunter is the $15k dedicated entry, not this $30k copy
        [30000, 15000, 15000], [2000, 1000, 1000], [120, 120, 120], [101], [34, 34, 34]],
    // LooneyBin (owner, 2026-06-11): Hunter HMG (machine gun) -> APD shop, Lieutenant+ (cop level 5)
    // owner 2026-06-19: REMOVED from cop store (shop keys emptied; was ["cop_car","swat_car"]). Entry kept so existing units keep sell-back/chop price.
    ["B_MRAP_01_hmg_F", "", [west], [], 5, 0, 0, [0, 200000, 0], [0, 100000, 0], [0, 3000, 0], [0, 120, 0], [101], [34, 34, 34]],
    ["I_MRAP_03_F", "", [civilian, west, independent], ["cop_car", "med_car", "nd_car", "reb_car"], 4, 5, 0, [50000, 35000, 35000], // owner 2026-07-07: Strider added to the REBEL cash shop (reb_car) for $50k. Prices are side-indexed [civ,west,indep] (NOT per-shop), so the civ price 50000 governs BOTH reb_car (CASH) and nd_car (New Drachma) -- can't split them. SWAT Strider is the separate $15k swat_car entry.
        [27500, 17500, 17500], [1500, 1500, 1500], [150, 150, 150], [101, 115], [34, 34, 34]], ["Land_CargoBox_V1_F", "", [civilian],
        ["chop_shop"], 0, 0, 0, 1400, 700, 500, 200, [], [10, 10, 10]], ["Land_Cargo20_red_F", "", [civilian],
        ["chop_shop"], 0, 0, 0, 1700, 850, 550, 200, [], [10, 10, 10]], ["O_Truck_03_covered_F", "", [civilian],
        ["chop_shop"], 0, 0, 0, 70000, 35000, 2000, 900, [], [50, 50, 50]], ["B_T_Truck_01_ammo_F", "", [civilian],
        ["chop_shop"], 0, 0, 0, 180000, 35000, 2000, 900, [], [50, 50, 50]], ["B_T_Truck_01_box_F", "", [civilian],
        ["chop_shop"], 0, 0, 0, 360000, 35000, 2000, 900, [], [50, 50, 50]], ["O_T_Truck_03_repair_ghex_F", "", [civilian],
        ["chop_shop"], 0, 0, 0, 540000, 35000, 2000, 900, [], [50, 50, 50]], ["O_APC_Wheeled_02_rcws_v2_F", "", [west],
        ["cop_car"], 6, 0, 0, [75000, 90000, 0], [40000, 27500, 0], [3000, 1500, 0], [100, 100, 0], [19], [34, 34, 34]],
    ["C_Tractor_01_F", "", [civilian, west], ["civ_truck", "cop_car"], 0, 0, 0, 1250, 625, 100, 150, [], [5, 5, 5], 26],
    ["C_Van_01_fuel_F", "", [civilian], ["civ_truck", "civ_special"], 0, 0, 0, [8700, 8700, 0], [4400, 4400, 0], [750, 1000, 0],
        [350, 350, 0], [], [15, 15, 15]],
    // BUGS.md #77: box truck ($7,100) undercut the plain transport van ($8,500) at identical 50 storage.
    // Re-slotted mid-ladder: van 8.5k/50 -> van02 12k/60 -> BOX 15k/65 -> zamak 20k/70 -> covered 25k/80.
    ["C_Van_01_box_F", "", [civilian, west],
        ["civ_truck", "cop_car", "civ_special"], 1, 0, 0, [15000, 15000, 0],   // owner 2026-06-25: cop rank 0->1 so the van shows/buys in the APD shop (rank-0 cop_car = sell/chop-only, hidden by the :603 !=0 gate)
        [7500, 7500, 0], [750, 1000, 0], [350, 350, 0], [], [65, 65, 65], 27], ["C_Van_02_vehicle_F", "", [civilian, west],
        ["civ_truck", "cop_car"], 1, 0, 0, [12000, 12000, 0],   // owner 2026-06-25: cop rank 0->1 so the van shows/buys in the APD shop
        [6000, 6000, 0], [850, 850, 0], [400, 400, 0], [100], [60, 60, 60], 26], ["C_Van_02_transport_F", "", [civilian, west],
        ["civ_truck", "cop_car"], 1, 0, 0, [12000, 12000, 0],   // owner 2026-06-20 (Payton): swat_car stripped; owner 2026-06-25: cop rank 0->1 so this van shows/buys in the APD shop
        [6000, 6000, 0], [850, 850, 0], [400, 400, 0], [100], [60, 60, 60], 26], ["I_Truck_02_transport_F", "", [civilian, west],
        ["civ_truck", "cop_car"], 4, 0, 0, [20000, 20000, 0], [10000, 10000, 0], [1000, 1000, 0], [600, 600, 0], [17], [70, 70, 70], 27],
    ["C_Truck_02_fuel_F", "", [civilian, west], ["civ_truck", "cop_car"], 0, 0, 0, [30000, 30000, 0], [15000, 15000, 0], [1250, 1250, 0],
        [700, 700, 0], [17], [30, 30, 30], 27], ["I_Truck_02_covered_F", "", [civilian, west],
        ["civ_truck", "cop_car"], 0, 0, 0, [25000, 25000, 0], [12500, 12500, 0], [1250, 1250, 0], [700, 700, 0], [17], [80, 80, 80], 27],
    ["B_Truck_01_transport_F", "", [civilian, west], ["civ_truck", "cop_car"], 5, 0, 0, [30000, 30000, 0], [15000, 15000, 0],
        [1500, 1500, 0], [850, 850, 0], [17], [100, 100, 100], 27], ["B_Truck_01_box_F", "", [civilian, west],
        ["civ_truck", "cop_car"], 0, 0, 0, [45000, 45000, 0], [22500, 22500, 0], [1750, 1750, 0], [1000, 1000, 0], [17],
        [120, 120, 120], 27], ["B_Truck_01_fuel_F", "", [civilian, west], ["civ_truck", "cop_car"], 0, 0, 0, [50000, 50000, 0],
        [25000, 25000, 0], [1750, 1750, 0], [1000, 1000, 0], [17], [30, 30, 30], 27], ["O_Truck_03_device_F", "", [civilian],
        ["civ_truck"], 0, 0, 0, 125000, 60000, 5000, 1250, [17], [50, 50, 50]], ["O_Truck_03_medical_F", "", [independent],
        ["med_car"], 0, 2, 0, 15000, 7500, 2000, 250, [113], [50, 50, 50]], ["O_Truck_03_fuel_F", "", [independent],
        ["med_car", "firefighter_car"], 0, 3, 0, 15000, 7500, 2000, 250, [113], [50, 50, 50]],
    ["O_T_LSV_02_unarmed_F", "", [civilian, west, independent], ["reb_car", "bh_car", "cop_car", "med_car"], 3, 2, 0, [25000, 20000, 20000], [15000, 15000, 15000], [750, 750, 750], [175, 175, 175], [], [30, 30, 30], 27],
    // LooneyBin: NG prestige Xi'an (Trauma Team Executive Package, talent 10) — independent-only, med_air shop
    ["I_Vtol_02_infantry_dynamicLoadout_F", "Xi'an (Medical)", [independent], ["med_air"], 0, 7, 0, [250000, 250000, 250000], [125000, 125000, 125000], [1000, 1000, 1000], [175, 175, 175], [], [30, 30, 30], 213],
    ["B_T_LSV_01_unarmed_F", "", [civilian, west],
        ["reb_car", "bh_car", "cop_car"], 3, 0, 0, [22500, 17500, 0],   // owner 2026-06-20 (Payton): swat_car stripped -- SWAT Prowler is the $6k dedicated entry, not this $17.5k copy
        [10000, 10000, 0], [700, 700, 0], [175, 175, 175], [101], [30, 30, 30], 27], ["I_C_Offroad_02_LMG_F", "", [civilian, west],
        ["reb_car", "cop_car"], 4, 0, 0, 45000, 22500, 1000, 0, [17], [30, 30, 30]], ["O_LSV_02_armed_F", "", [civilian],
        ["reb_car", "nd_car"], 0, 0, 0, 90000, 42500, 3000, [175, 175, 175], [17], [30, 30, 30]],
    ["O_T_LSV_02_armed_black_F", "", [civilian], ["chop_shop"], 0, 0, 0, 90000, 42500, 3000, 175, [], [30, 30, 30]],
    ["C_Offroad_02_unarmed_F", "", [civilian, west], ["civ_car", "bh_car", "cop_car"], 2, 0, 0, [3500, 3500, 3500], [1750, 1750, 1750],
        [250, 250, 250], [150, 150, 150], [99], [30, 30, 30], 25], ["I_G_Offroad_01_repair_F", "", [civilian],
        ["reb_car", "bh_car"], 2, 0, 10, [3500, 3500, 3500], [1750, 1750, 1750], [250, 250, 250], [150, 150, 150], [99], [30, 30, 30], 25],
    ["C_Plane_Civil_01_F", "", [civilian, west], ["civ_air", "cop_air"], 5, 0, 0, 30000, 15000, 1500, 150, [], [9, 9, 9]],
    ["I_Plane_Fighter_03_CAS_F", "", [civilian], ["civ_air"], 0, 0, 0, 60000, 12500, 750, 100, [], [9, 9, 9]],
    ["C_Heli_Light_01_civil_F", "", [civilian, independent, west], ["civ_air", "med_air", "cop_air"], 2, 2, 0, [35000, 20000, 20000],
        [22500, 10000, 10000], [750, 750, 750], [80, 80, 80], [114], [17, 17, 17], 28],
    ["B_Heli_Light_01_F", "", [civilian, west, independent], ["civ_air", "cop_air", "bh_car", "med_air", "reb_car"], 2, 1, 0, [45000, 25000, 25000], [25000, 17500, 10000], [750, 750, 750], [80, 80, 0], [102, 114], [17, 17, 17], 28],
    ["I_Heli_light_03_unarmed_F", "Hellcat", [civilian, west, independent], ["reb_car", "bh_car", "cop_air", "med_air"], 3, 2, 0, [60000, 50000, 50000], [30000, 20000, 20000], [850, 850, 850], [100, 100, 100], [20, 103, 114], [34, 34, 34], 29],
    ["I_Heli_light_03_F", "Hellcat (benches)", [civilian, west, independent],
        ["reb_car", "bh_car", "cop_air"], 0, 5, 0, [60000, 50000, 50000], [30000, 20000, 20000], [850, 850, 850], [100, 100, 100],
        [20, 103, 114], [34, 34, 34], 29],
    ["O_Heli_Light_02_unarmed_F", "", [civilian, west, independent], ["civ_air", "cop_air", "reb_car", "bh_car", "med_air"], 4, 3, 0, [65000, 55000, 55000], [32500, 30000, 30000], [750, 750, 750], [80, 80, 80], [20, 104], [50, 50, 50], 29],
    // owner 2026-07-03: armed helis in the REBEL air shop (reb_car), missiles stripped on spawn (fn_clearVehicleAmmo).
    ["B_Heli_Light_01_armed_F", "Pawnee (Guns)", [civilian], ["reb_car"], 0, 0, 0, 1000000, 500000, 750, 80, [], [50, 50, 50]],
    ["O_Heli_Light_02_dynamicLoadout_F", "Orca (Guns)", [civilian], ["reb_car"], 0, 0, 0, 1200000, 600000, 750, 80, [], [50, 50, 50]],
    // owner 2026-07-03: Blackfish vehicle transport in the CIV air shop. $300k, 3000 virtual-inv cap
    // BEFORE upgrades (field 10 = getVirtCap base; storage upgrades add on top via fn_prepareVehicle _mods).
    ["B_T_VTOL_01_infantry_F", "Blackfish (Transport)", [civilian], ["civ_air"], 0, 0, 0, 300000, 150000, 15000, 3000, [], [100, 100, 100]],
    ["I_Heli_Transport_02_F", "", [civilian, west], ["civ_air", "cop_air"], 4, 0, 0, [80000, 60000, 0], [40000, 30000, 0], [1000, 1000, 0],
        [300, 300, 0], [20], [84, 84, 84], 30], ["B_Heli_Transport_03_unarmed_F", "", [west],
        ["cop_air"], 5, 0, 0, 65000, 35000, 2000, 80, [104], [100, 100, 100]], ["O_Heli_Transport_04_F", "", [civilian],
        ["reb_car"], 0, 0, 0, 90000, 45000, 2000, 100, [20], [67, 67, 67]], ["O_Heli_Transport_04_bench_F", "", [civilian],
        ["reb_car"], 0, 0, 0, 75000, 37500, 1500, 100, [20], [67, 67, 67]], ["O_Heli_Transport_04_medevac_F", "", [independent],
        ["med_air"], 0, 3, 0, 70000, 37500, 1500, 100, [20, 114], [67, 67, 67]], ["O_Heli_Transport_04_F", "", [independent],
        ["med_air"], 0, 4, 0, 75000, 37500, 1500, 100, [20, 114], [67, 67, 67]], ["O_T_VTOL_02_infantry_F", "", [independent],
        ["med_air"], 0, 4, 0, 75000, 37500, 1500, 100, [20, 114], [67, 67, 67]], ["B_Heli_Transport_01_F", "", [west],
        ["cop_air"], 6, 0, 0, 70000, 35000, 2500, 80, [104], [50, 50, 50]], ["I_Plane_Fighter_04_F", "", [civilian],
        ["civ_air"], 0, 0, 0, 150000, 30000, 750, 100, [], [9, 9, 9]], ["C_Rubberboat", "", [civilian],
        ["civ_ship"], 0, 0, 0, 350, 175, 50, 60, [], [9, 9, 9]], ["C_Scooter_Transport_01_F", "", [civilian],
        ["civ_ship"], 0, 0, 0, 1500, 750, 100, 75, [], [9, 9, 9]], ["C_Boat_Civil_01_F", "", [civilian],
        ["civ_ship"], 0, 0, 0, 3000, 1500, 200, 200, [], [9, 9, 9]], ["C_Boat_Civil_01_rescue_F", "", [civilian, independent],
        ["civ_ship", "med_ship"], 0, 3, 0, [3000, 3000, 3000], [1500, 1500, 1500], [200, 200, 200], [200, 200, 200], [], [9, 9, 9]],
    ["C_Boat_Transport_02_F", "", [civilian, independent], ["civ_ship", "med_ship"], 0, 3, 0, [5000, 5000, 5000], [2500, 2500, 2500],
        [300, 300, 300], [200, 100, 100], [], [9, 9, 9]], ["O_SDV_01_F", "", [civilian], ["civ_ship"], 0, 0, 0, 3000, 1500, 200, 200, [],
        [9, 9, 9]], ["B_Boat_Transport_01_F", "", [west], ["cop_ship"], 2, 0, 0, 300, 150, 50, 200, [], [9, 9, 9]],
    ["C_Boat_Civil_01_police_F", "", [west], ["cop_ship"], 2, 0, 0, 2000, 1000, 200, 200, [], [9, 9, 9]],
    ["B_Boat_Armed_01_minigun_F", "", [west], ["cop_ship"], 5, 0, 0, 85000, 37500, 2500, 200, [], [9, 9, 9]],
        // --- NG rank-issued military fleet (owner 2026-06-27) ---
        ["C_Van_01_transport_F", "", [independent], ["med_car"], 0, 1, 0, 2000, 1000, 500, 100, [], [100, 100, 100]],
        ["C_Truck_02_transport_F", "", [independent], ["med_car"], 0, 1, 0, 8000, 4000, 1000, 200, [], [200, 200, 200]],
        ["B_T_LSV_01_unarmed_F", "", [independent], ["med_car"], 0, 2, 0, 12000, 6000, 1500, 200, [], [40, 40, 40]],
        ["B_G_Offroad_01_armed_F", "", [independent], ["med_car"], 0, 3, 0, 25000, 12000, 3000, 200, [], [40, 40, 40]],
        ["O_MRAP_02_F", "", [independent], ["med_car"], 0, 6, 0, 35000, 17500, 5000, 300, [], [50, 50, 50]],  
        ["B_APC_Wheeled_01_cannon_F", "", [independent], ["med_car"], 0, 7, 0, 150000, 75000, 8000, 400, [], [60, 60, 60]],
        ["I_Heli_Transport_02_F", "", [independent], ["med_air"], 0, 3, 0, 60000, 30000, 4000, 300, [], [60, 60, 60]],  
        ["C_Plane_Civil_01_F", "", [independent], ["med_air"], 0, 3, 0, 50000, 30000, 3000, 250, [], [30, 30, 30]],
        ["B_UAV_01_F", "", [independent], ["med_air"], 0, 5, 0, 40000, 20000, 2000, 100, [], [10, 10, 10]],
        ["I_Plane_Fighter_03_CAS_F", "", [independent], ["med_air"], 0, 5, 0, 150000, 100000, 8000, 400, [], [20, 20, 20]],
        ["B_Heli_Transport_01_F", "", [independent], ["med_air"], 0, 6, 0, 200000, 120000, 10000, 400, [], [60, 60, 60]],
        ["B_Heli_Transport_03_unarmed_F", "", [independent], ["med_air"], 0, 6, 0, 180000, 100000, 9000, 400, [], [80, 80, 80]],
        ["B_T_VTOL_01_infantry_F", "", [independent], ["med_air"], 0, 7, 0, 300000, 150000, 15000, 3000, [], [100, 100, 100]],
        ["C_Offroad_01_F", "", [independent], ["med_car"], 0, 1, 0, 2500, 1250, 250, 100, [], [34, 34, 34]],
        ["C_Van_02_medevac_F", "", [independent], ["med_car"], 0, 1, 0, 5000, 2500, 350, 100, [], [50, 50, 50]],
        ["I_MRAP_03_F", "", [independent], ["med_car"], 0, 3, 0, 35000, 17500, 1500, 150, [], [34, 34, 34]],
        ["B_MRAP_01_F", "", [independent], ["med_car"], 0, 3, 0, 30000, 15000, 1500, 150, [], [34, 34, 34]],
        ["O_Heli_Light_02_unarmed_F", "", [independent], ["med_air"], 0, 3, 0, 55000, 30000, 750, 80, [], [50, 50, 50]],
        ["C_Boat_Civil_01_F", "", [independent], ["med_ship"], 0, 1, 0, 2000, 1000, 500, 100, [], [30, 30, 30]],
        ["B_Boat_Transport_01_F", "", [independent], ["med_ship"], 0, 1, 0, 3000, 1500, 500, 100, [], [30, 30, 30]],
        ["C_Scooter_Transport_01_F", "", [independent], ["med_ship"], 0, 2, 0, 5000, 2500, 800, 100, [], [10, 10, 10]],
        ["O_SDV_01_F", "", [independent], ["med_ship"], 0, 2, 0, 30000, 15000, 3000, 200, [], [30, 30, 30]],
        ["B_Boat_Armed_01_minigun_F", "", [independent], ["med_ship"], 0, 7, 0, 80000, 40000, 5000, 300, [], [40, 40, 40]]];
    // owner 2026-07-08 (perf + SWAT-shop fix): build the srt-excluded VIEW once, alongside the full table. The old
    // code REBUILT the ~90-row literal every call then re-filtered it; worse, the global srt_car filter stripped the
    // SWAT/SRT rows (tagged srt_car) from their OWN shop -> empty garage. Now shopVehicles reads the FULL table and
    // every other case reads the srt-excluded view (dup classnames still resolve to the civ/non-srt row, as before).
    PLB_vehConfigNonSrt = PLB_vehConfigTable select { !("srt_car" in (_x param[3, []])) };};
private _vehicleArray = PLB_vehConfigNonSrt;   // srt-excluded (default -- identical to the old global-filtered array)
private _fullTable    = PLB_vehConfigTable;    // full table incl srt/swat rows (shopVehicles only)
private "_return";
switch (_mode) do {case "getVehicleRow": {_return = []; {if ((_className == (_x select 0)) && !("srt_car" in (_x param[3, []]))) exitWith {
                    _return = +_x;   // deep copy -- a caller could mutate the row; with the cached table a bare ref would corrupt the shared table
                };}
            forEach _vehicleArray;}; case "getVehicleRowParsed": {_return = []; {
                    if ((_className == (_x select 0)) && !("srt_car" in (_x param[3, []]))) exitWith {
                        _return = +_x;   // deep copy -- getVehicleRowParsed mutates _return in place (set 7/8/9/10); with the cached table a bare ref would corrupt the shared row
                    };}
                forEach _vehicleArray;
                // Slots 7/8/9/10 (buy/sell/rent/...) may each hold a per-side array [civ, cop, ind];
                // flatten to this player's side. No default arm on purpose: east/other sides leave the
                // arrays untouched, exactly as the three-case switch this replaced did.
                private _sideIdx = switch (playerSide) do {case civilian: {0}; case west: {1}; case independent: {2}; default {-1}};
                if (_sideIdx > -1) then {
                    {if ((_return select _x) isEqualType[]) then {_return set[_x, ((_return select _x) select _sideIdx)];};} forEach [7, 8, 9, 10];
                };
                // LooneyBin Economy: owner vehicle-price overrides (veh p0=buy idx7, p1=sell idx8)
                if (_return isNotEqualTo []) then {private _ov = ["veh", _className] call life_fnc_priceOv;
                    if (_ov isNotEqualTo []) then {if ((_ov select 2) >= 0) then { _return set [7, _ov select 2]; };
                        if ((_ov select 3) >= 0) then { _return set [8, _ov select 3]; };};};};
        case "getEconList":   // LooneyBin Economy UI: [[class,name,buy,sell],...] (civ tier 0)
            {_return = _vehicleArray apply {private _b = _x param [7, 0]; if (_b isEqualType []) then { _b = _b param [0, 0]; };
                    private _s = _x param [8, 0]; if (_s isEqualType []) then { _s = _s param [0, 0]; };
                    [_x select 0, getText (configFile >> "CfgVehicles" >> (_x select 0) >> "displayName"), _b, _s]};};
        case "shopVehicles": {_return = [];
                // owner 2026-07-08: removed the -VEHSHOPDBG- diag (fired a remoteExec + DB log on every cop/SWAT/SRT
                // shop open) now the empty-garage root cause is fixed (shopVehicles reads _fullTable above).
                {if ((_shop in (_x select 3)) && (playerSide in (_x select 2))) then {switch (playerSide) do {case civilian: {
                                    if (_donorLevel >= (_x select 6)) then {_return pushBackUnique _x;};};
                            case west: {
                                    // owner 2026-06-25 (SWAT/SRT garage STILL empty -- the REAL cause): these two branches
                                    // used `exitWith`, not `then`. `exitWith` here terminates the whole fn_vehicleConfig
                                    // `call` and makes it RETURN the value of its block -- `_return pushBackUnique _x`, which
                                    // yields the new index (a NUMBER, 0), not the array. So the caller got `0`; the -VEHSHOP-
                                    // diag showed exactly `swat_car -> 0 veh: []` (count 0 / apply []). The 2026-06-21 isSwat
                                    // tweak never touched this. Use `then` like every sibling branch (civ donor / cop rank /
                                    // medic) so each matching vehicle is pushed and the forEach keeps going -> all 7 show.
                                    if (_shop isEqualTo "swat_car") then {_return pushBackUnique _x;};
                                    if (_shop isEqualTo "srt_car") then {_return pushBackUnique _x;};
                                    if (_copLevel >= (_x select 4) && !(_x select 4 isEqualTo 0)) then {_return pushBackUnique _x;};
                                    if ((_x param[13, -1] in life_cop_talents) && (life_coprole in ["all", "detective"])) then {
                                        _return pushBackUnique _x;};};
                            case independent: {
                                    // owner 2026-06-25: same exitWith-returns-from-the-call bug as swat_car/srt_car above
                                    // (would blank the firefighter shop). Use `then` so the forEach keeps building the list.
                                    if (life_isActiveFirefighter && _shop isEqualTo "firefighter_car") then {_return pushBackUnique _x;};
                                    // LooneyBin: NG prestige-gated vehicles -> shown ONLY if the matching prestige
                                    // talent is owned (overrides the rank gate for these specific classes).
                                    private _ngVehRank = if (_medicLevel isEqualTo 99) then {0} else {_medicLevel};
                                    private _pGate = switch (_x select 0) do {
                                        case "B_Heli_Light_01_F": {6};                      // Flight Medic -> Hummingbird
                                        case "I_Heli_light_03_unarmed_F";
                                        case "I_Heli_light_03_F": {7};                      // Hellcat
                                        case "O_Heli_Light_02_unarmed_F": {8};              // Orca
                                        case "I_Vtol_02_infantry_dynamicLoadout_F": {10};   // Xi'an
                                        case "O_T_LSV_02_unarmed_F";
                                        case "O_LSV_02_unarmed_F": {12};                    // Qilin
                                        case "B_MRAP_01_F": {13};                           // Hunter
                                        case "I_MRAP_03_F": {14};                           // Strider
                                        default {-1};};
                                    // owner 2026-06-25: was `exitWith` (same footgun as swat_car/srt_car above) -- on the
                                    // FIRST prestige-gated medic vehicle the forEach hit, it bailed out of the list-build,
                                    // truncating/blanking the NG vehicle shop. if/else keeps the intent (prestige vehicles
                                    // gated by talent, the rest by rank) while letting the forEach finish every entry.
                                    if (_pGate != -1) then {
                                        if ((_pGate in life_medic_talents) && (_ngVehRank >= (_x select 5))) then { _return pushBackUnique _x; };
                                    } else {if (_ngVehRank >= (_x select 5)) then { _return pushBackUnique _x; };};};};};}
                forEach _fullTable;   // owner 2026-07-08: shopVehicles reads the FULL table so SWAT/SRT rows (tagged srt_car) show in their own shop; non-matching srt rows are still filtered by the per-shop tag test above
                _return = _return apply { +_x };   // copy rows out of the cached table so a shop consumer can't mutate the shared cache in place
            };
        case "talentCheck": {if (playerSide isEqualTo west && {life_activeSWAT}) exitWith {_return = "";};
                _return = "";
                private _allSideTalents = ["getFactionTalentsIDs"] call life_fnc_talentCfg;
                private "_requiredVehTalents"; {if (_className == (_x select 0)) exitWith {_requiredVehTalents = (_x select 11);};}
                forEach _vehicleArray;
                if ((count _requiredVehTalents) isEqualTo 0) exitWith {_return = "";};
                private _talentsNeeded = _requiredVehTalents arrayIntersect _allSideTalents; {if !(_x in life_side_talents) exitWith {
                        _return = ["getTalentName", _x] call life_fnc_talentCfg;};}
                forEach _talentsNeeded;};
        case "getVirtCap": {_return = 0; {if (_className isEqualTo(_x param[0, ""])) exitWith {if ((_x select 10) isEqualType[]) then {
                            _return = (_x select 10) select 0;} else {_return = _x select 10;};};}
                forEach _vehicleArray;};
        case "getPhysCap": {_return = 0; {if (_className isEqualTo(_x param[0, ""])) exitWith {if ((_x select 12) isEqualType[]) then {
                            _return = (_x select 12) select 0;} else {_return = _x select 12;};};}
                forEach _vehicleArray;};}; _return ;
