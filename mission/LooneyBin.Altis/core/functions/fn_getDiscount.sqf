params[["_shop", "", [""]], ["_purchase", false, [false]], ["_item", "", [""]]];
if (_shop isEqualTo "questBuffs") exitWith {private _discount =
    switch (true) do {default {0};}; _discount ;};
private _discount = 1;
_shop = toLower(_shop);
if (_purchase) then {if (3 in life_achievements) then {_discount = _discount - 0.02;};
    if (playerSide isEqualTo civilian) then {
        if (_shop in ["rebelwep", "rebel", "rebcloth"] && {   // LooneyBin: arms cartel now discounts ALL rebel purchases (weapons + virtual items + clothing), not just weapons -- owning the Arms Dealer was only cutting rebelwep prices before.
            (arms_flag getVariable["plb_capData", [0, "Neutral", 0.5]] select 0) isEqualTo(life_gang_data select 0)}) then {
            _discount = _discount - 0.15;};
        if (_shop isEqualTo "vehshop" && {14 in life_side_talents}) then {_discount = _discount - 0.10;};
        if (_shop isEqualTo "rebel" && {1 in life_gang_talents}) then {_discount = _discount - 0.10;};
        if (_shop isEqualTo "rebcloth" && {2 in life_gang_talents}) then {_discount = _discount - 0.05;};
        if (_shop isEqualTo "rebelwep" && {3 in life_gang_talents}) then {_discount = _discount - 0.05;};
        if (_shop isEqualTo "vehshop" && {(life_veh_shop select 0) isEqualTo "reb_car" && 30 in life_infamy_talents && license_civ_rebel
        }) then {_discount = _discount - 0.10;};
        _discount = selectMax[_discount, 0.8];};
    if (playerSide isEqualTo west) then {if (_shop in ["cop", "police_weapons", "police_equipment"] && {SRV_communityEvent param [1, false]
        }) then {_discount = 0.5};
        _discount = selectMax[_discount, 0.5];};
    if (playerSide isEqualTo independent) then {_discount;};} else {if (playerSide isEqualTo civilian) then {
        if (_shop in ["wongs", "heroin"] && {4 in life_gang_talents}) then {_discount = _discount + 0.05;};
        if (_shop isEqualTo "heroin" && {5 in life_gang_talents}) then {_discount = _discount + 0.02;};
        if (_shop isEqualTo "wongs" && {6 in life_gang_talents}) then {_discount = _discount + 0.02;};
        // owner 2026-06-18: SRV_bustBonusActive is READ here but never SET anywhere (no server writer) -> every
        // shop discount calc threw "Undefined variable: srv_bustbonusactive" (recurring -SCRIPTERR-). Guard the
        // read with a false default so it can't error; if the bust-bonus EVENT is ever wired server-side
        // (publicVariable SRV_bustBonusActive), this picks it up automatically.
        if ((missionNamespace getVariable ["SRV_bustBonusActive", false]) && _shop in ["rebel", "wongs", "heroin", "fishmarket", "diamond", "salt", "commod", "blackmarket", "market", "turf"]) then {
            _discount = _discount + 0.12;};
        if (_shop in ["rebel", "wongs", "heroin"] && {26 in life_infamy_talents && license_civ_rebel}) then {_discount = _discount + 0.07;
        };};
    if (playerSide isEqualTo west) then {_discount;};
    if (playerSide isEqualTo independent) then {_discount;};
    _discount = selectMax[_discount, 0.8];};
_discount;