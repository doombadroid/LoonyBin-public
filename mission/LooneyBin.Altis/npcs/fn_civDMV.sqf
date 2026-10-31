params["_obj_main", "_stance"];
if (_obj_main isKindOf "CAManBase") then {};
_obj_main addAction["Drivers License ($100)", life_fnc_buyLicense, 'driver', 1.5, false, false, "", '!license_civ_driver && playerSide isEqualTo civilian', 5];
_obj_main addAction["Boating License ($150)", life_fnc_buyLicense, 'boat', 1.5, false, false, "", '!license_civ_boat && playerSide isEqualTo civilian', 5];
_obj_main addAction["Pilots License ($4,000)", life_fnc_buyLicense, 'pilot', 1.5, false, false, "", '!license_civ_air && playerSide isEqualTo civilian', 5];
_obj_main addAction["Truck License ($4,000)", life_fnc_buyLicense, 'truck', 1.5, false, false, "", '!license_civ_truck && playerSide isEqualTo civilian', 5];
_obj_main addAction["Home Owner License ($3,500)", life_fnc_buyLicense, 'home', 1.5, false, false, "", '!license_civ_home && playerSide isEqualTo civilian', 5];
_obj_main addAction["Firearm License ($250)", life_fnc_buyLicense, 'gun', 1.5, false, false, "", '!license_civ_gun && playerSide isEqualTo civilian', 5];
_obj_main addAction["Diving License ($200)", life_fnc_buyLicense, 'dive', 1.5, false, false, "", '!license_civ_dive && playerSide isEqualTo civilian', 5];
_obj_main addAction["Diamond Processing ($3,500)", life_fnc_buyLicense, 'diamond', 1.5, false, false, "", '!license_civ_diamond && playerSide isEqualTo civilian', 5];
_obj_main addAction["Salt Processing ($900)", life_fnc_buyLicense, 'salt', 1.5, false, false, "", '!license_civ_salt && playerSide isEqualTo civilian', 5];
_obj_main addAction["Sand Processing ($700)", life_fnc_buyLicense, 'sand', 1.5, false, false, "", '!license_civ_sand && playerSide isEqualTo civilian', 5];
_obj_main addAction["Iron Processing ($950)", life_fnc_buyLicense, 'iron', 1.5, false, false, "", '!license_civ_iron && playerSide isEqualTo civilian', 5];
_obj_main addAction["Copper Processing ($600)", life_fnc_buyLicense, 'copper', 1.5, false, false, "", '!license_civ_copper && playerSide isEqualTo civilian', 5];
// LoonyBin (owner 2026-06-12): "Unlearn talents" action removed -- the talent system was stripped, so a respec
// could corrupt player state. life_fnc_respec left in place but no longer reachable from the DMV.