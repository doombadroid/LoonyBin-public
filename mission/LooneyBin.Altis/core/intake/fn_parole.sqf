/*
    life_fnc_parole  (LooneyBin, owner 2026-07-11)
    PAROLE PAPERS -- Act 2 of onboarding: a fixed 6-contract chain that teaches the core loops with
    escalating server-paid rewards. Runs after THE INTAKE releases the player into Athira; resumes on
    relog from players.intake_step (via login payload -> life_intakeStep). Progress = BIS task HUD +
    a local map marker per step; completion events ride the EXISTING quest chokepoint (fn_handleQuest
    forwards every [type, key, amount] here while the arc is active -- zero new tracking plumbing).

    Steps (index = intake_step; owner 2026-07-11: license+wheels FIRST -- the peach field is 1.3km out):
        0  Get a driver's license         (action buylicense_driver -- hook in fn_buyLicense)
        1  Buy any vehicle                (buy invehiclevalue)
        2  Pick 15 peaches                (collect peach)
        3  Sell 10 peaches at the market  (sell peach)
        4  Learn a talent                 (action learntalent -- hook in fn_learnTalent)
        5  Report to the Parole Officer   (scroll action on the local NPC; finale payout)
        255 = arc complete (never runs again)

    Modes:
        ["start"]                 begin/resume (fn_intake finale + fn_initCiv relog-resume call this)
        ["event", _type,_key,_n]  forwarded by fn_handleQuest while active
        ["officer"]               finale NPC action
*/
// ── tuning (owner-supplied exact spots, 2026-07-11) ─────────────────────────────────────────────
#define PAROLE_PEACHES   [13118.8, 19672.2, 0]      // peach field NW of Athira
#define PAROLE_MARKET    [14041.3, 18786.6, 0.44]   // Athira market NPC
#define PAROLE_DMV_LIC   [14036.5, 18760.1, 0.44]   // Athira DMV -- driver's license NPC
#define PAROLE_DMV_CAR   [14034.9, 18757.5, 0.28]   // Athira car dealer
#define PAROLE_OFFICER   [14060.9, 18747.3, 0]      // Parole Officer NPC spot (owner-supplied)
#define PAROLE_OFFICER_DIR 310                       // faces north-west

params [["_mode", "start", [""]], ["_a1", ""], ["_a2", ""], ["_a3", 0]];

// step table: [taskTitle, taskDesc, markerPos (or []), matcher [type, key, neededCount]]
private _steps = [
    ["Parole 1/6: Driver's license", "The state insists you're licensed before you're dangerous. Buy a driver's license at the Athira DMV -- your stipend covers it.", PAROLE_DMV_LIC, ["action", "buylicense_driver", 1]],
    ["Parole 2/6: Get wheels", "Walking is for patients. Buy any vehicle at the Athira car dealer -- a quadbike will do fine.", PAROLE_DMV_CAR, ["buy", "invehiclevalue", 1]],
    ["Parole 3/6: Pick peaches", "Your caseworker suggests honest work. Drive to the orchard northwest of Athira and pick 15 peaches (scroll wheel in the field).", PAROLE_PEACHES, ["collect", "peach", 15]],
    ["Parole 4/6: Sell the peaches", "Take them back to the Athira market NPC and sell at least 10. Watch the market prices on your phone (Y).", PAROLE_MARKET, ["sell", "peach", 10]],
    ["Parole 5/6: Learn a talent", "Open your phone (Y) -> Talents and spend a point. Any point. Your brain is technically certified now.", [], ["action", "learntalent", 1]],
    ["Parole 6/6: Report in", "Report to your Parole Officer near the Athira square to close out your papers.", PAROLE_OFFICER, ["officer", "", 1]]
];

private _fnClearUi = {
    if (!isNil "PLB_paroleTask" && {!isNull PLB_paroleTask}) then { PLB_paroleTask setTaskState "SUCCEEDED"; player removeSimpleTask PLB_paroleTask; PLB_paroleTask = nil; };
    if ((missionNamespace getVariable ["PLB_paroleMarker", ""]) isNotEqualTo "") then { deleteMarkerLocal PLB_paroleMarker; PLB_paroleMarker = ""; };
    ("PLB_paroleHud" call BIS_fnc_rscLayer) cutText ["", "PLAIN"];};

// static objective card, top-right notification area -- pinned until the step completes
private _fnHud = {params ["_idx", ["_count", -1]];
    private _s = _steps param [_idx, []];
    if (_s isEqualTo []) exitWith {};
    _s params ["_title", "_desc", "", "_match"];
    private _need = _match param [2, 1];
    private _progress = if (_count >= 0 && {_need > 1}) then { format ["<br/><t color='#c7a24e' size='1.1'>%1 / %2</t>", _count, _need] } else { "" };
    private _disp = uiNamespace getVariable ["PLB_ParoleHud", displayNull];
    if (isNull _disp) then {("PLB_paroleHud" call BIS_fnc_rscLayer) cutRsc ["PLB_ParoleHud", "PLAIN", 0, false];
        _disp = uiNamespace getVariable ["PLB_ParoleHud", displayNull];};
    (_disp displayCtrl 515950) ctrlSetStructuredText parseText format [
        "<t color='#37e8f0' size='1.05' font='PuristaSemibold'>%1</t><br/><t color='#dfe5ec' size='0.85'>%2</t>%3",
        _title, _desc, _progress];};

// paint the CURRENT step's task + marker
private _fnShowStep = {params ["_idx"];
    call _fnClearUi;
    private _s = _steps param [_idx, []];
    if (_s isEqualTo []) exitWith {};
    _s params ["_title", "_desc", "_mpos", "_match"];
    PLB_paroleTask = player createSimpleTask [format ["plb_parole_%1", _idx]];
    PLB_paroleTask setSimpleTaskDescription [_desc, _title, _title];
    PLB_paroleTask setTaskState "ASSIGNED";
    player setCurrentTask PLB_paroleTask;
    if (_mpos isNotEqualTo []) then {PLB_paroleTask setSimpleTaskDestination _mpos;
        PLB_paroleMarker = createMarkerLocal [format ["plb_parole_m%1", _idx], _mpos];
        PLB_paroleMarker setMarkerTypeLocal "mil_objective";
        PLB_paroleMarker setMarkerColorLocal "ColorCIV";
        PLB_paroleMarker setMarkerTextLocal (_title select [7]);   // strip "Parole "
    };
    [format ["<t color='#37e8f0'>%1</t> -- check your map.", _title], "basic"] spawn life_fnc_handleMessage;
    [_idx, 0] call _fnHud;};

// spawn the Parole Officer (local, like the intake Doctor) once the arc is running
private _fnOfficer = {if (!isNil "PLB_paroleNpc" && {!isNull PLB_paroleNpc}) exitWith {};
    PLB_paroleNpc = "C_man_hunter_1_F" createVehicleLocal [PAROLE_OFFICER select 0, PAROLE_OFFICER select 1, 0];
    PLB_paroleNpc allowDamage false;
    PLB_paroleNpc disableAI "ALL";
    PLB_paroleNpc setVectorUp [0, 0, 1];
    PLB_paroleNpc setPosATL PAROLE_OFFICER;
    PLB_paroleNpc setDir PAROLE_OFFICER_DIR;
    // owner 2026-07-11: gendarmerie uniform + police vest (local unit -> local dressing is fine)
    removeAllWeapons PLB_paroleNpc;
    removeUniform PLB_paroleNpc;
    removeVest PLB_paroleNpc;
    PLB_paroleNpc forceAddUniform "U_B_GEN_Soldier_F";
    PLB_paroleNpc addVest "V_TacVest_gen_F";
    PLB_paroleNpc addHeadgear "H_MilCap_gen_F";
    PLB_paroleNpc setVariable ["BIS_enableRandomization", false];
    PLB_paroleNpc setVariable ["owner", "plb_intake"];
    PLB_paroleNpc addAction ["<t color='#37e8f0'>Report in (Parole Officer)</t>", {["officer"] call life_fnc_parole;
    }, nil, 6, true, true, "", "(missionNamespace getVariable ['PLB_paroleStep', -1]) isEqualTo 5", 4];};

private _fnAdvance = {params ["_done"];
    // server persists + pays; -ONBOARD- logs the funnel
    [["step", player, _done], "TON_fnc_intakeSRV", 2] call life_fnc_MP;
    private _next = _done + 1;
    life_intakeStep = if (_done isEqualTo 5) then { 255 } else { _next };
    PLB_paroleStep = life_intakeStep;
    if (_done isEqualTo 5) exitWith {call _fnClearUi;
        PLB_paroleActive = nil;
        if (!isNil "PLB_paroleNpc") then { deleteVehicle PLB_paroleNpc; PLB_paroleNpc = nil; };
        private _flavor = switch (life_intakePath) do {
            case 2: { "Between us? The real money on this island was never legal. Ask around about licenses." };
            case 3: { "The National Guard is always hiring people like you. So is everyone who ever bleeds." };
            default { "Runs get bigger the further you drive. Copper, salt, oil -- the island pays the patient." };}; [[
            ["PAROLE COMPLETE", "<t align='center' size='1.9' font='PuristaBold'>%1</t><br/>", 8],
            ["THE LOONYBIN IS YOURS NOW. TRY TO STAY OUT.", "<t align='center' size='0.9' font='EtelkaMonospacePro'>%1</t>", 10]
        ]] spawn BIS_fnc_typeText;
        [format ["<t color='#c7a24e'>Parole Officer:</t> %1", _flavor], "basic"] spawn life_fnc_handleMessage;};
    [_next] call _fnShowStep;};

// ── EVENT (forwarded by fn_handleQuest while active) ────────────────────────────────────────────
if (_mode isEqualTo "event") exitWith {if (isNil "PLB_paroleActive") exitWith {};
    private _idx = missionNamespace getVariable ["PLB_paroleStep", -1];
    private _s = _steps param [_idx, []];
    if (_s isEqualTo []) exitWith {};
    (_s select 3) params ["_mt", "_mk", "_need"];
    if !(_a1 isEqualTo _mt && {_mk isEqualTo "" || {_a2 isEqualTo _mk}}) exitWith {};
    private _amt = if (_a3 isEqualType 0) then { _a3 max 1 } else { 1 };
    PLB_paroleCount = (missionNamespace getVariable ["PLB_paroleCount", 0]) + _amt;
    if (PLB_paroleCount < _need) exitWith {[_idx, PLB_paroleCount] call _fnHud;   // live counter on the pinned card
    };
    PLB_paroleCount = 0;
    [_idx] call _fnAdvance;};

// ── NUDGE (server DIRECTOR push; sender-gated) ──────────────────────────────────────────────────
if (_mode isEqualTo "nudge") exitWith {if (remoteExecutedOwner isNotEqualTo 2) exitWith {};   // server only
    if (isNil "PLB_paroleActive") exitWith {};
    private _idx = missionNamespace getVariable ["PLB_paroleStep", -1];
    [_idx] call _fnShowStep;
    [_idx, missionNamespace getVariable ["PLB_paroleCount", 0]] call _fnHud;
    ["<t color='#c7a24e'>Parole Officer:</t> Lost? The map marker shows the way -- and side chat is full of Loonies who help. Ask.", "basic"] spawn life_fnc_handleMessage;
};

// ── OFFICER (finale action) ─────────────────────────────────────────────────────────────────────
if (_mode isEqualTo "officer") exitWith {if ((missionNamespace getVariable ["PLB_paroleStep", -1]) isNotEqualTo 5) exitWith {};
    [5] call _fnAdvance;};

// ── START / RESUME ──────────────────────────────────────────────────────────────────────────────
if !(_mode isEqualTo "start") exitWith {};
if (!isNil "PLB_paroleActive") exitWith {};
private _step = missionNamespace getVariable ["life_intakeStep", 255];
if (!(_step isEqualType 0) || {_step > 5}) exitWith {};   // done/never -> nothing to do
PLB_paroleActive = true;
PLB_paroleStep = _step;
PLB_paroleCount = 0;
call _fnOfficer;
[_step] call _fnShowStep;
