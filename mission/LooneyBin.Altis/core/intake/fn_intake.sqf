/*
    life_fnc_intake  (LooneyBin, owner 2026-07-11)
    THE INTAKE, Act 1 -- "Committed". A brand-new player doesn't get a spawn menu: they wake up INSIDE
    the Loony Bin. Flow (all client-local; persistence + stipend via TON_fnc_intakeSRV):

        cinematic fly-in over the asylum (skippable)
        -> padded ward: learn MOVE, then LOOK, then the SCROLL MENU (talk to the Doctor)
        -> the interview: 3 questions, NC dialog; answers secretly pick the starting path
           (1 worker / 2 criminal / 3 do-gooder -- Act 2/3 read it later)
        -> release: fade, "THREE WEEKS LATER", wake in Kavala square with the stipend + parole toast

    Trigger: fn_initCiv replaces the spawn menu with this when life_intakePath == 0 (fresh accounts;
    veterans are grandfathered to 9 by the run-boot2 backfill). Disconnect mid-intake -> still 0 ->
    it simply runs again next login. A "Skip the intake" action exists the whole way through (alts).

    Modes:
        ["start"]          spawned by fn_initCiv (also owner-testable: [] spawn life_fnc_intake)
        ["answer", _i]     interview button handler (0/1/2)
        ["skip"]           skip action -> server persists 9, straight to Kavala
        ["ack", _amount]   SERVER-ONLY stipend push (sender-gated: remoteExecutedOwner must be 2)
*/
// ── tuning (owner 2026-07-11: exact Kavala-hospital ward spots; release still Athira via marker). ──
#define INTAKE_CELL           [3761.87, 13016.4, 0.16]   // new-player wake spot
#define INTAKE_DOC_POS        [3772.55, 13010.6, 0.15]   // Doctor NPC spot
#define INTAKE_DOC_DIR        0                           // Doctor faces north
#define INTAKE_CAM_TIME       14
#define INTAKE_RELEASE_MARKER "civ_spawn_3"               // Athira
#define IDD_INTAKE            515900

params [["_mode", "start", [""]], ["_arg", 0]];

// ── ACK (server -> this client): pay the release stipend. Online money is client-authoritative in
//     this codebase; the sender gate keeps another CLIENT from remoteExec-gifting money around. ────
if (_mode isEqualTo "ack") exitWith {if (remoteExecutedOwner isNotEqualTo 2) exitWith {};   // server only
    private _amt = 0 max (_arg param [0, _arg]);
    if (_amt isEqualType 0 && {_amt > 0}) then {life_atmcash = life_atmcash + _amt;
        life_atmcashCacheB = ((life_atmcash / 4) + 11);
        [6] call life_fnc_ClupdatePartial;
        [format ["Release stipend deposited: <t color='#c7a24e'>$%1</t>. Don't spend it all in one asylum.", [_amt] call life_fnc_numberText], "basic"] spawn life_fnc_handleMessage;
    };};

// ── ANSWER (interview button) ───────────────────────────────────────────────────────────────────
if (_mode isEqualTo "answer") exitWith {private _i = _arg max 0 min 2;
    PLB_intakeTally set [_i, (PLB_intakeTally select _i) + 1];
    PLB_intakeQ = PLB_intakeQ + 1;
    if (PLB_intakeQ >= count PLB_intakeQs) then {closeDialog 0;
        PLB_intakeDone = true;} else {["paint"] call life_fnc_intake;};};

// ── PAINT (fill the dialog with the current question) ──────────────────────────────────────────
if (_mode isEqualTo "paint") exitWith {private _disp = findDisplay IDD_INTAKE;
    if (isNull _disp) exitWith {};
    (PLB_intakeQs param [PLB_intakeQ, ["", ["", "", ""]]]) params ["_q", "_answers"];
    (_disp displayCtrl 515910) ctrlSetStructuredText parseText format ["<t color='#ebeff4'>%1</t>", _q];
    (_disp displayCtrl 515911) ctrlSetText format ["Q %1 / %2", PLB_intakeQ + 1, count PLB_intakeQs];
    { (_disp displayCtrl (515912 + _forEachIndex)) ctrlSetText (_answers param [_forEachIndex, ""]); } forEach [0, 1, 2];};

// ── SKIP ────────────────────────────────────────────────────────────────────────────────────────
if (_mode isEqualTo "skip") exitWith {PLB_intakeSkipped = true;
    PLB_intakeDone = true;};

// ── START ───────────────────────────────────────────────────────────────────────────────────────
if !(_mode isEqualTo "start") exitWith {};
if (!isNil "PLB_intakeRunning") exitWith {};
PLB_intakeRunning = true;

private _restoreDamage = isDamageAllowed player;
player allowDamage false;
player setVariable ["plb_inIntake", true, true];

private _cell = INTAKE_CELL;

// wake in the ward, facing the Doctor
titleCut ["", "BLACK FADED", 0.5];
player setPosATL _cell;
player setDir ([_cell, INTAKE_DOC_POS] call BIS_fnc_dirTo);

// the Doctor -- local-only unit (each newbie gets their own; the mapData NPC path proves local men work).
// owner 2026-07-11: exact coords + explicit up-vector; setPosATL the given z so he can't sink.
private _doc = "C_scientist_F" createVehicleLocal [INTAKE_DOC_POS select 0, INTAKE_DOC_POS select 1, 0];
_doc allowDamage false;
_doc disableAI "ALL";
_doc setVectorUp [0, 0, 1];
_doc setPosATL INTAKE_DOC_POS;
_doc setDir INTAKE_DOC_DIR;
_doc switchMove "Acts_A_M01_briefing";   // idle clipboard-lecture loop; falls back to stand if absent
_doc setVariable ["owner", "plb_intake"];   // cleanup-reap exemption (client-local anyway)

// skip hatch -- available the entire act
private _skipId = player addAction ["<t color='#8993a0'>Skip the intake (I've been here before)</t>", {["skip"] call life_fnc_intake;
}, nil, 0.5, false, true, "", "isNil ""PLB_intakeDone"" || {!PLB_intakeDone}"];
PLB_intakeSkipped = false;
PLB_intakeDone = false;

// ── cinematic fly-in (any-key skippable), military typewriter title (BIS_fnc_typeText = the
//     campaign-style scrolling text with the static/noise SFX) ──────────────────────────────────
private _camFrom = _cell vectorAdd [-165, -190, 135];
private _camTo   = _cell vectorAdd [-4, -7, 6];
private _cam = "camera" camCreate _camFrom;
_cam cameraEffect ["internal", "back"];
_cam camSetTarget (_cell vectorAdd [0, 0, 1.5]);
_cam camSetPos _camFrom;
_cam camCommit 0;
titleCut ["", "BLACK IN", 2]; [[["THE LOONY BIN", "<t align='center' size='2.4' font='PuristaBold'>%1</t><br/>", 8],
    ["ALTIS DEPARTMENT OF BEHAVIORAL CORRECTION", "<t align='center' size='0.9' font='EtelkaMonospacePro'>%1</t><br/>", 10],
    ["PATIENT INTAKE - DAY 1", "<t align='center' size='0.9' font='EtelkaMonospacePro' color='#37e8f0'>%1</t>", 10]
]] spawn BIS_fnc_typeText;
_cam camSetPos _camTo;
_cam camSetTarget (_cell vectorAdd [0, 0, 1.5]);
_cam camCommit INTAKE_CAM_TIME;
PLB_intakeCamSkip = false;
private _kd = (findDisplay 46) displayAddEventHandler ["KeyDown", "PLB_intakeCamSkip = true; false"];
private _t0 = time;
waitUntil { camCommitted _cam || PLB_intakeCamSkip || PLB_intakeDone || {time - _t0 > (INTAKE_CAM_TIME + 2)} };
(findDisplay 46) displayRemoveEventHandler ["KeyDown", _kd];
titleCut ["", "BLACK OUT", 0.6];
uiSleep 0.7;
_cam cameraEffect ["terminate", "back"];
camDestroy _cam;
titleCut ["", "BLACK IN", 1.2];

// ── beats (each auto-passes on timeout so nobody ever gets stuck) ───────────────────────────────
private _beat = {params ["_text", "_cond", ["_timeout", 90]];
    if (PLB_intakeDone) exitWith {};
    cutText [format ["<t size='1.1' align='center'>%1</t>", _text], "PLAIN DOWN", 0.5, true, true];
    private _t = time;
    waitUntil { uiSleep 0.2; (call _cond) || PLB_intakeDone || {time - _t > _timeout} };
    cutText ["", "PLAIN DOWN"];};

if (!PLB_intakeDone) then {["You wake up on a cot that smells like bleach and regret.<br/>Take a few steps. (W A S D)",
        { (player distance2D _cell) > 1.6 }] call _beat;};
if (!PLB_intakeDone) then {private _d0 = getCameraViewDirection player;
    ["Good. Now have a look around your accommodations. (move the mouse)",
        { ((getCameraViewDirection player) vectorCos _d0) < 0.5 }] call _beat;};
if (!PLB_intakeDone) then {PLB_intakeTalk = false;
    private _talkId = _doc addAction ["<t color='#37e8f0'>Talk to the Doctor</t>", { PLB_intakeTalk = true; }, nil, 6, true, true, "", "true", 4];
    ["Someone is watching you. Use the SCROLL WHEEL on the Doctor and select <t color='#37e8f0'>Talk</t>.",
        { PLB_intakeTalk }, 180] call _beat;
    _doc removeAction _talkId;};

// ── the interview ───────────────────────────────────────────────────────────────────────────────
if (!PLB_intakeDone) then {PLB_intakeQs = [
        ["So. Why are you here?", ["I work too hard. Apparently that's a disorder now.", "I hurt people. Allegedly.", "I kept helping strangers. They found that suspicious."]],
        ["Look at this inkblot. What do you see?", ["A paycheck.", "A getaway car.", "An ambulance, arriving in time for once."]],
        ["Final question. The door is unlocked. What do you do?", ["Ask for a job application on the way out.", "Run and never look back.", "Hold it open for the others."]]
    ];
    PLB_intakeTally = [0, 0, 0];   // worker / criminal / do-gooder
    PLB_intakeQ = 0;
    createDialog "PLB_Intake";
    ["paint"] call life_fnc_intake;
    waitUntil { uiSleep 0.2; PLB_intakeDone || {isNull findDisplay IDD_INTAKE} };
    // ESC'd out before answering everything = a skip, not a half-tallied path
    if (PLB_intakeQ < count PLB_intakeQs) then { PLB_intakeSkipped = true; };
    PLB_intakeDone = true;};
if (!isNull findDisplay IDD_INTAKE) then { closeDialog 0; };

// ── release ─────────────────────────────────────────────────────────────────────────────────────
player removeAction _skipId;
deleteVehicle _doc;
titleCut ["", "BLACK OUT", 1];
uiSleep 1.2;
if (PLB_intakeSkipped) then {[["skip", player], "TON_fnc_intakeSRV", 2] call life_fnc_MP;} else {
    // path = highest tally; a tie breaks toward the calmer option (worker < criminal < do-gooder)
    private _path = 1 + (PLB_intakeTally find (selectMax PLB_intakeTally));
    [["complete", player, _path], "TON_fnc_intakeSRV", 2] call life_fnc_MP;
    life_intakePath = _path;
    private _tt = [[["THREE WEEKS LATER", "<t align='center' size='2' font='PuristaBold'>%1</t>", 8]]] spawn BIS_fnc_typeText;
    private _t0 = time;
    waitUntil { scriptDone _tt || {time - _t0 > 6} };   // let the type-on play out over the black
    uiSleep 0.5;};
private _release = getMarkerPos INTAKE_RELEASE_MARKER;
if (_release distance2D [0, 0] < 10) then { _release = [14051.9, 18728.7, 0]; };   // Athira fallback
player setPosATL _release;
player setDir (random 360);
player setVariable ["plb_inIntake", nil, true];
if (_restoreDamage) then { player allowDamage true; };
titleCut ["", "BLACK IN", 2];
if (!PLB_intakeSkipped) then {uiSleep 1; [[["WELCOME TO THE LOONYBIN", "<t align='center' size='1.9' font='PuristaBold'>%1</t><br/>", 8],
        ["CERTIFIED SANE ENOUGH FOR ATHIRA. BARELY.", "<t align='center' size='0.9' font='EtelkaMonospacePro'>%1</t>", 10]
    ]] spawn BIS_fnc_typeText;
    ["Your parole papers are in order. Press <t color='#37e8f0'>Y</t> for your phone -- Quests, Talents and the Market live there.", "basic"] spawn life_fnc_handleMessage;
    // Act 2: the PAROLE PAPERS contract arc picks up right here (fresh accounts start at step 0)
    life_intakeStep = 0;
    [] spawn { uiSleep 9; ["start"] call life_fnc_parole; };};
PLB_intakeRunning = nil;
