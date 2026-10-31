life_use_atm = true;
plbv_hunger = 100;
plbv_thirst = 100;
life_carryWeight = 0;
life_preRespawnUniformBackpackSkins = life_uniformBackpack_skins;
life_uniformBackpack_skins = [-1, -1];
life_respawned = true;
life_isDead = false;
if !(playerSide isEqualTo west) then {life_cash = 0;
    life_cashCacheB = ((life_cash / 4) + 9);};
player playMove "amovpercmstpsnonwnondnon"; {if !(isNil {player getVariable _x}) then {player setVariable[_x, nil, true];};}
forEach["plb_revivable", "plb_reviving", "plb_executing"];
private _handle = scriptNull;
switch (playerSide) do {case west: {_handle = [] spawn life_fnc_copLoadout};
    case civilian: {_handle = [] spawn life_fnc_civLoadout};
    case independent: {_handle = [] spawn life_fnc_medicLoadout};}; waitUntil {scriptDone _handle};
life_deathCamera cameraEffect["TERMINATE", "BACK"];
camDestroy life_deathCamera;
if ((life_is_arrested param [0,0]) isEqualTo 1) exitWith {life_is_arrested set[0, 0];
    [player, false] spawn life_fnc_jailPlayer;
    [] call life_fnc_ClupdateRequest;};
[] call life_fnc_ClupdateRequest;
[] call life_fnc_hudUpdate;

// owner 2026-07-12: everyone carries a GPS -- the map's G-search / route HUD is gated on it
if !("ItemGPS" in assignedItems player) then { player linkItem "ItemGPS"; };
