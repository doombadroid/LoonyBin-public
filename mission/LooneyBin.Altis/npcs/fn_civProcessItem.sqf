params["_obj_main", "_stance", "_type"];
if (_obj_main isKindOf "CAManBase") then {};
switch (_type) do {case "mineral": {
            _obj_main addAction["Process Iron", life_fnc_processAction, "iron", 1.5, false, false, "", 'life_inv_ironore > 0 && !life_is_processing', 5];
                _obj_main addAction["<t color='#33FF99'>Process Vehicle: Iron</t>", life_fnc_processVehicle, "iron", 1.5, false, false, "", '!life_is_processing', 5];
            _obj_main addAction["Process Copper", life_fnc_processAction, "copper", 1.5, false, false, "", 'life_inv_copperore > 0 && !life_is_processing', 5];
                _obj_main addAction["<t color='#33FF99'>Process Vehicle: Copper</t>", life_fnc_processVehicle, "copper", 1.5, false, false, "", '!life_is_processing', 5];
            _obj_main addAction["Process Diamond", life_fnc_processAction, "diamond", 1.5, false, false, "", 'life_inv_diamond > 0 && !life_is_processing', 5];
            // owner 2026-06-14 (#207): add the bulk vehicle-trunk diamond process. The "diamond" -> "diamondc"
            // recipe already exists in fn_processVehicle; Iron/Copper had their "Process Vehicle" action but
            // diamond was missing, so only ores could be bulk-processed at the mineral processor.
            _obj_main addAction["<t color='#33FF99'>Process Vehicle: Diamond</t>", life_fnc_processVehicle, "diamond", 1.5, false, false, "", '!life_is_processing', 5];
            _obj_main addAction["Process Sand", life_fnc_processAction, "sand", 1.5, false, false, "", 'life_inv_sand > 0 && !life_is_processing', 5];
            _obj_main addAction["Crush Rock", life_fnc_processAction, "sandr", 1.5, false, false, "", 'life_inv_rock > 0 && !life_is_processing', 5];
        }; case "cocaine": {
                _obj_main addAction["Process Cocaine", life_fnc_processAction, "cocaine", 1.5, false, false, "", 'life_inv_cocaine > 0 && !life_is_processing', 5];
                _obj_main addAction["<t color='#33FF99'>Process Vehicle: Cocaine</t>", life_fnc_processVehicle, "cocaine", 1.5, false, false, "", '!life_is_processing', 5];
                _obj_main addAction["Form Cocaine Bricks (Purify)", life_fnc_processAction, "cokebrick", 1.5, false, false, "", 'life_inv_cocainep > 0 && !life_is_processing', 5];
                _obj_main addAction["<t color='#33FF99'>Process Vehicle: Cocaine Bricks</t>", life_fnc_processVehicle, "cokebrick", 1.5, false, false, "", '!life_is_processing', 5];
            };
        case "meth": {
                _obj_main addAction["Mix Meth cocktail", life_fnc_processAction, "methcocktail", 1.5, false, false, "", 'life_inv_ephedrau > 0 && life_inv_phos > 0 && life_inv_hydro > 0 && !life_is_processing', 5];
                _obj_main addAction["<t color='#33FF99'>Process Vehicle: Meth Cocktail</t>", life_fnc_processVehicle, "methcocktail", 1.5, false, false, "", '!life_is_processing', 5];
                _obj_main addAction["Cook Meth", life_fnc_processAction, "meth", 1.5, false, false, "", 'life_inv_ephedra > 0 && !life_is_processing', 5];
                _obj_main addAction["<t color='#33FF99'>Process Vehicle: Meth</t>", life_fnc_processVehicle, "meth", 1.5, false, false, "", '!life_is_processing', 5];
                _obj_main addAction["Purify Meth (Blue)", life_fnc_processAction, "bluemeth", 1.5, false, false, "", 'life_inv_meth > 0 && !life_is_processing', 5];
                _obj_main addAction["<t color='#33FF99'>Process Vehicle: Blue Meth</t>", life_fnc_processVehicle, "bluemeth", 1.5, false, false, "", '!life_is_processing', 5];
            };
        case "marijuana": {
                _obj_main addAction["Process Marijuana", life_fnc_processAction, "marijuana", 1.5, false, false, "", 'life_inv_cannabis > 0 && !life_is_processing', 5];
                _obj_main addAction["<t color='#33FF99'>Process Vehicle: Marijuana</t>", life_fnc_processVehicle, "marijuana", 1.5, false, false, "", '!life_is_processing', 5];
                _obj_main addAction["<img image='mpmissions\__cur_mp.altis\icons\cannabisplant.paa' /> <t color='#ff547f'>Dry Indica Plant</t>", life_fnc_processAction, "cannai_2", 1.5, false, false, "", 'life_inv_cannai_2 > 0 && !life_is_processing && playerSide isEqualTo civilian', 5];
                _obj_main addAction["<img image='mpmissions\__cur_mp.altis\icons\cannabisplant.paa' /> <t color='#ff547f'>Dry Sativa Plant</t>", life_fnc_processAction, "cannas_2", 1.5, false, false, "", 'life_inv_cannas_2 > 0 && !life_is_processing && playerSide isEqualTo civilian', 5];
                // owner 2026-06-13: bud -> Golden Wax moved here from the removed purificationfactory (weed.md)
                _obj_main addAction["<img image='mpmissions\__cur_mp.altis\icons\cannabisdab.paa' /> <t color='#ff547f'>Process Indica Bud into Golden Wax</t>", life_fnc_processAction, "cannai_3", 1.5, false, false, "", 'life_inv_cannai_3 > 0 && !life_is_processing', 5];
                // owner 2026-06-17: Sativa-bud -> Golden Wax action REMOVED (wax is INDICA-only). Sativa bud sells as a bud.
                // owner 2026-06-14 (#206): bulk vehicle-trunk bud -> Golden Wax. The cannas_3/cannai_3 -> canna_dab
                // recipes already exist in fn_processVehicle, but only the hand actions were here, so a trunk of
                // home-grown weed couldn't be bulk-processed into wax. Mirrors the other "Process Vehicle" options.
                _obj_main addAction["<t color='#33FF99'>Process Vehicle: Indica Golden Wax</t>", life_fnc_processVehicle, "cannai_3", 1.5, false, false, "", '!life_is_processing', 5];
                // owner 2026-06-17: Process-Vehicle Sativa-Wax action REMOVED (wax is INDICA-only).
                _obj_main addAction["Marijuana Processing Contract ($800)", life_fnc_buyLicense, "marijuana", 1.5, false, false, "", '!license_civ_marijuana && playerSide isEqualTo civilian', 5];
            };
        case "medmarijuana": {
                _obj_main addAction["Process Marijuana", life_fnc_processAction, "marijuanam", 1.5, false, false, "", 'life_inv_cannabis > 0 && !life_is_processing && (SRV_governorData param [3, false])', 5];
                _obj_main addAction["Marijuana Processing Contract ($800)", life_fnc_buyLicense, "marijuana", 1.5, false, false, "", '!license_civ_marijuana && playerSide isEqualTo civilian', 5];
            };
        case "heroin": {
                _obj_main addAction["Process Heroin", life_fnc_processAction, "heroin", 1.5, false, false, "", 'life_inv_heroinu > 0 && !life_is_processing', 5];
                _obj_main addAction["<t color='#33FF99'>Process Vehicle: Heroin</t>", life_fnc_processVehicle, "heroin", 1.5, false, false, "", '!life_is_processing', 5];
            };
        case "oyster": {
                _obj_main addAction["Cook Oysters", life_fnc_processAction, "oyster", 1.5, false, false, "", 'life_inv_oysteru > 0 && !life_is_processing', 5];
                _obj_main addAction["Fry Oysters", life_fnc_processAction, "oysterfry", 1.5, false, false, "", 'life_inv_oysterp > 0 && !life_is_processing', 5];
            };
        case "oil": {
                _obj_main addAction["Process Oil", life_fnc_processAction, "drilledoil", 1.5, false, false, "", 'life_inv_oilu > 0 && !life_is_processing', 5];
                _obj_main addAction["<t color='#33FF99'>Process Vehicle: Oil</t>", life_fnc_processVehicle, "drilledoil", 1.5, false, false, "", '!life_is_processing', 5];
                _obj_main addAction["Oil Processing ($1,000)", life_fnc_buyLicense, "oil", 1.5, false, false, "", '!license_civ_oil && playerSide isEqualTo civilian', 5];
            };
        case "salt": {
                _obj_main addAction["Process Salt", life_fnc_processAction, "salt", 1.5, false, false, "", 'life_inv_salt > 0 && !life_is_processing && playerSide isEqualTo civilian', 5];
            };
        case "timber": {
                _obj_main addAction["Mill Pine Timber", life_fnc_processAction, "timber", 1.5, false, false, "", 'life_inv_timber > 0 && !life_is_processing && playerSide isEqualTo civilian', 5];
                _obj_main addAction["Mill Olive Timber", life_fnc_processAction, "timberl", 1.5, false, false, "", 'life_inv_timberl > 0 && !life_is_processing && playerSide isEqualTo civilian', 5];
                _obj_main addAction["Mill Hardwood Timber", life_fnc_processAction, "timberh", 1.5, false, false, "", 'life_inv_timberh > 0 && !life_is_processing && playerSide isEqualTo civilian', 5];
            };
        case "purificationfactory": {
                // owner 2026-06-13: PURIFICATION FACTORY REMOVED. Every 2nd-stage/purify recipe was moved to
                // the matching normal processor (cokebrick->cocaine, bluemeth->meth, pcpp->pcp, lsd_1->fungi,
                // scotch3->scotchHeatPump, bud->GoldenWax->marijuana). Case kept empty in case a stray NPC
                // still spawns with this type (also stripped from fn_mapData). Double-process at the normal spot.
            };
        case "scotchHeatPump": {
                _obj_main addAction["See Alcohol Recipes", life_fnc_alcoholRecipes, "", 0, false, true, "", ' !life_is_processing'];
                _obj_main addAction["Process White Lightning", life_fnc_processAction, "moonshinep", 0, false, true, "", ' life_inv_moonshine > 0 && !life_is_processing'];
                _obj_main addAction["Age Scotch (Aging Chemicals)", life_fnc_processAction, "scotch3", 0, false, true, "", ' playerSide isEqualTo civilian && life_inv_scotch_2 > 0 && !life_is_processing'];
                _obj_main addAction["Process Scotch", life_fnc_processAction, "scotch", 0, false, true, "", ' playerSide isEqualTo civilian && life_inv_water > 0 && life_inv_yeast > 0 && life_inv_barley > 0 && !life_is_processing'];
                _obj_main addAction["Process Scotch", life_fnc_processAction, "scotchsalt", 0, false, true, "", ' playerSide isEqualTo civilian && life_inv_saltwater > 0 && life_inv_yeast > 0 && life_inv_barley > 0 && !life_is_processing'];
                _obj_main addAction["Process Corn Whiskey", life_fnc_processAction, "whiskeyc", 0, false, true, "", ' playerSide isEqualTo civilian && life_inv_water > 0 && life_inv_yeast > 0 && life_inv_barley > 0 && life_inv_corn > 0 && !life_is_processing'];
                _obj_main addAction["Process Corn Whiskey", life_fnc_processAction, "whiskeycsalt", 0, false, true, "", ' playerSide isEqualTo civilian && life_inv_saltwater > 0 && life_inv_yeast > 0 && life_inv_barley > 0 && life_inv_corn > 0 && !life_is_processing'];
                _obj_main addAction["Process Rye Whiskey", life_fnc_processAction, "whiskeyr", 0, false, true, "", ' playerSide isEqualTo civilian && life_inv_water > 0 && life_inv_yeast > 0 && life_inv_barley > 0 && life_inv_rye > 0 && !life_is_processing'];
                _obj_main addAction["Process Rye Whiskey", life_fnc_processAction, "whiskeyrsalt", 0, false, true, "", ' playerSide isEqualTo civilian && life_inv_saltwater > 0 && life_inv_yeast > 0 && life_inv_barley > 0 && life_inv_rye > 0 && !life_is_processing'];
            };
        case "pcp": {
                _obj_main addAction["Mix PCP Powder", life_fnc_processAction, "pcpu", 1.5, false, false, "", 'life_inv_henbane > 0 && life_inv_hydro > 0 && !life_is_processing', 5];
                _obj_main addAction["Process PCP Pills", life_fnc_processAction, "pcp", 1.5, false, false, "", 'life_inv_pcpu > 0 && !life_is_processing', 5];
                _obj_main addAction["<t color='#33FF99'>Process Vehicle: PCP</t>", life_fnc_processVehicle, "pcp", 1.5, false, false, "", '!life_is_processing', 5];
                _obj_main addAction["Form PCP Sheets (Purify)", life_fnc_processAction, "pcpp", 1.5, false, false, "", 'life_inv_pcp > 0 && !life_is_processing', 5];
            };};