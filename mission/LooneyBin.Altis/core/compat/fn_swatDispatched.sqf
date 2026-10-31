// life_fnc_swatDispatched -- LooneyBin: SWAT summons receiver (restored 2026-06-11).
// Server PLB_fnc_swatDispatch remoteExecs [ _locations, _center ] to each eligible officer when the
// Federal Reserve alarm trips. Notifies + offers a "Join SWAT" scroll action. Accepting applies SWAT
// kit and calls TON_fnc_registerSwat, which adds the officer to life_swat_active server-side; the
// (intact) server flow then assigns roles, spawns the SWAT MRAP/boat and deploys the squad.
params [["_locations", [], [[]]], ["_center", [0,0,0], [[]]]];
if (side player != west) exitWith {};

life_SWATActionAvail = true; [
    "<t color='#316dff'><t size='1.6'><t align='center'>SWAT Activated</t></t></t><br/><br/><t align='left'><t size='0.85'><t color='#ffffff'>A major crime is in progress and SWAT has been called up.<br/><br/><t color='#33CC33'>Use your scroll wheel -> <t color='#ffffff'>Join SWAT Deployment<t color='#33CC33'> to gear up and deploy with the squad.",
    "copmsg"] spawn life_fnc_handleMessage;
if (!(_center isEqualTo [0,0,0]) && {(_center select 0) > 0}) then {
    ["SWAT", _center, " SWAT Staging -", "colorBLUFOR", "mil_warning", 240] spawn life_fnc_createLMarker;};

// Add the join action exactly once per session; visibility is gated by the condition string.
if (isNil { player getVariable "plb_swatJoinAct" }) then {private _act = player addAction ["<t color='#3399FF'>Join SWAT Deployment</t>", {
            if (life_activeSWAT) exitWith {};
            life_swatLoadout = getUnitLoadout player;
            player setUnitLoadout [["srifle_DMR_03_F", "", "acc_pointer_IR", "optic_Arco_blk_F", ["20Rnd_762x51_Mag", 20],
                [], ""], [], [], ["U_B_CombatUniform_mcam_worn", [["FirstAidKit", 2], ["SmokeShellBlue", 2, 1], ["SmokeShell", 2, 1],
                ["SmokeShellGreen", 2, 1]]], ["V_PlateCarrier1_blk", [["20Rnd_762x51_Mag", 10, 20]]], ["B_AssaultPack_blk", [
                ["20Rnd_762x51_Mag", 10, 20]]], "H_CrewHelmetHeli_B", "G_Balaclava_blk", ["Rangefinder", "", "", "", [],
                [], ""], ["ItemMap", "ItemGPS", "", "ItemCompass", "", "Integrated_NVG_F"]];
            [] spawn {uiSleep 0.5;
                [uniform player, "setIdx", 10] call life_fnc_clothingTextures;
                [] call life_fnc_giveMedkits;};
            life_activeSWAT = true;
            life_isSwat = true;
            [[player], "TON_fnc_registerSwat", 2] spawn life_fnc_MP;
            ["You joined SWAT. Stand by -- the squad MRAP is being staged for deployment.", "basic"] spawn life_fnc_handleMessage;},
        nil, 1.5, false, true, "","life_SWATActionAvail && !life_activeSWAT"];
    player setVariable ["plb_swatJoinAct", _act];};
