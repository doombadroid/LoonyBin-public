// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only
/*
    File: fn_cyberdeckRing.sqf  (life_fnc_cyberdeckRing)
    LooneyBin 2026-07-20: ICEBREAKER VISOR quick-hack RING (artifact 5c41381f, built 1:1).
    Bound to SHIFT+Y, only while WEARING VR GOGGLES and running the illegal firmware.

    True radial: a full-screen invisible catcher (941201) reports the mouse; we convert to the deck's
    UI grid (where 1 GW == 1 GH in pixels, so the angle is undistorted), take atan2 -> wedge index,
    light that wedge's baked overlay and write the hub readout. Click fires it; ESC/right-click closes.

    Wedge order (clockwise from top) MUST match render_ring.py's icon order:
      0 WARDRIVE  1 UNLOCK  2 KILLSWITCH (id "ignition")  3 ATM  4 HOUSE  5 RIG  6 PROXY  7 BREACH KIT
*/
if !((goggles player) isEqualTo "G_Goggles_VR") exitWith {
    ["You need your VR goggles on for the visor overlay.", "basic"] spawn life_fnc_handleMessage;};
// owner 2026-07-20: APD runs TAL OS off the same ring (talos.md) -- different wedge set, different
// palette, different art. Civilians need the illegal firmware; officers are issued TAL with the goggles.
private _isCop = playerSide isEqualTo west;
if (!_isCop && {!(call PLB_fnc_hasDeck)}) exitWith {
    ["No deck firmware. Flash it at an electronics shop first.", "basic"] spawn life_fnc_handleMessage;};
if (!isNull (findDisplay 941200)) exitWith {};
if (dialog) exitWith {};

private _tgt   = cursorObject;
private _tt    = if (isNull _tgt) then { "" } else { typeOf _tgt };
private _isVeh = (!isNull _tgt) && {(_tgt isKindOf "Car") || (_tgt isKindOf "Air") || (_tgt isKindOf "Ship")} && {!(_tgt isKindOf "CAManBase")};
private _isHouse = (!isNull _tgt) && {_tgt isKindOf "House_F"} && {_tt in life_houseTypes};
private _isRig   = (!isNull _tgt) && {_tgt getVariable ["plb_cryptoRig", false]};
private _isATM   = _tt in ["Land_Atm_01_F", "Land_Atm_02_F"];
private _mods    = player getVariable ["plb_cdMods", []];

// ATM context: drained this restart / deck cooling down
private _atmWhy = "";
if (_isATM) then {private _apos = getPosATL _tgt;
    private _akey = format ["%1_%2", round (_apos select 0), round (_apos select 1)];
    if (_akey in (missionNamespace getVariable ["plb_atmDoneKeys", []])) then { _atmWhy = "ALREADY DRAINED" };
    private _cd = missionNamespace getVariable ["plb_atmHackCd", 0];
    if (_atmWhy isEqualTo "" && {diag_tickTime < _cd}) then { _atmWhy = format ["COOLDOWN %1 MIN", ceil ((_cd - diag_tickTime) / 60)] };};
private _wdCd = missionNamespace getVariable ["plb_wardriveCd", 0];

// PALETTE per side. Civ deck = outlaw acid/cyan on black-green. TAL = police MDT: badge amber primary,
// light-bar ice blue flavour, police red danger, steel-blue dim. [primary, flavour, danger, dim, faint]
PLB_ringPal = if (_isCop) then { ["#f0a01e", "#4db8ff", "#ff3b30", "#7d8b9e", "#41505f"] }
                     else { ["#c9e21a", "#33ffbb", "#ff3b1e", "#7f918a", "#4c5a55"] };

// ============================ TOOL CATALOGUE ============================
// Entry: [label, fullName, blurb, tone(0 primary/1 flavour/2 danger), ok, whyBlocked, code, id, icon]
// ids 7/8 are appended so the existing hub/label code (which reads 0-6) keeps working untouched.
// Ring art is ICONLESS -- icons are live controls, so a tool keeps its glyph in ANY slot.
private _cat = [];
if (_isCop) then {private _rank   = call life_copLevel;
    private _isPly  = (!isNull _tgt) && {_tgt isKindOf "CAManBase"} && {isPlayer _tgt} && {_tgt != player};
    private _dist   = if (isNull _tgt) then { 9999 } else { player distance _tgt };
    private _cuffed = _isPly && {(_tgt getVariable ["plb_restrained", false]) || (_tgt getVariable ["plb_civRestrained", false])};
    private _dirty  = _isPly && {0 in (_tgt getVariable ["plb_cdMods", []])};
    private _sgt    = _rank >= 3;
    private _capt   = _rank >= 6;                                  // Captain+ (matches fn_copUAV's gate)
    private _jamCd  = missionNamespace getVariable ["plb_talJamCd", 0];
    private _swCd   = missionNamespace getVariable ["plb_talSweepCd", 0];
    private _pinCd  = missionNamespace getVariable ["plb_talPinCd", 0];
    private _bkCd   = missionNamespace getVariable ["plb_talBackupCd", 0];
    private _stopCd = missionNamespace getVariable ["plb_talStopCd", 0];
    _cat = [["RECORDS", "Records Lookup", "Priors, gang and time served.", 1,
            (_isPly && {_dist <= 25}), (if (_isPly) then {"OUT OF RANGE"} else {"NO SUSPECT"}),
            { [0] spawn life_fnc_talAction }, "records", "records"],
        ["PLATE", "Plate Scan", "Registered owner. Flags a driver with no keys.", 0,
            _isVeh, "NO VEHICLE", { [1] spawn life_fnc_talAction }, "plate", "plate"],
        ["FIELD TEST", "Field Test", "Breathalyser + drug screen on a suspect.", 1,
            (_isPly && {_dist <= 8}), (if (_isPly) then {"TOO FAR"} else {"NO SUSPECT"}),
            { [2] spawn life_fnc_talAction }, "field", "field"],
        ["FIRMWARE", "Firmware Scan", "Is this handset running an illegal deck OS?", 1,
            (_isPly && {_dist <= 12} && {_sgt}), (if (!_sgt) then {"SGT+ ONLY"} else {if (_isPly) then {"TOO FAR"} else {"NO SUSPECT"}}),
            { [3] spawn life_fnc_talAction }, "firmware", "firmware"],
        ["RESET", "Factory Reset", "Wipes illegal firmware. Their upgrades survive.", 2, (_dirty && {_cuffed} && {_dist <= 10} && {_sgt}),
            (if (!_sgt) then {"SGT+ ONLY"} else {if (!_isPly) then {"NO SUSPECT"} else {if (!_cuffed) then {"NOT RESTRAINED"} else {if (!_dirty) then {"FIRMWARE CLEAN"} else {"TOO FAR"}}}}),
            { [4] spawn life_fnc_talAction }, "reset", "reset"], ["BOLO", "BOLO Board", "Active APBs and who the APD wants.", 1,
            true, "", { [] call life_fnc_wantedMenu }, "bolo", "bolo"], ["UNITS", "Unit Board", "Every officer on duty right now.", 1,
            true, "", {private _u = allPlayers select { (side _x) isEqualTo west && {alive _x} };
                private _s = "";
                { _s = _s + format ["<t color='#dbe4ee'>%1</t> <t color='#7d8b9e'>%2</t><br/>", name _x, toUpper ([west, _x] call life_fnc_getRankString)]; } forEach _u;
                if (_s isEqualTo "") then { _s = "<t color='#7d8b9e'>no units on duty</t>" };
                [format ["<t color='#f0a01e' size='1.2'>UNITS ON DUTY -- %1</t><br/>%2", count _u, _s], "basic"] spawn life_fnc_handleMessage;
            }, "units", "units"], ["SWEEP", "Contraband Sweep", "Marks rigs and ATM skimmers within 300m.", 0,
            (_sgt && {diag_tickTime >= _swCd}), (if (!_sgt) then {"SGT+ ONLY"} else {format ["RECHARGING %1s", ceil (_swCd - diag_tickTime)]}),
            { [5] spawn life_fnc_talAction }, "sweep", "sweep"], ["DISPATCH", "Dispatch Pin", "Marks your position for every unit.", 0,
            (diag_tickTime >= _pinCd), format ["RECHARGING %1s", ceil (_pinCd - diag_tickTime)],
            { [6] spawn life_fnc_talAction }, "dispatch", "dispatch"],
        ["BACKUP", "Backup Beacon", "Panic button. Alerts all units and medics.", 2,
            (diag_tickTime >= _bkCd), format ["RECHARGING %1s", ceil (_bkCd - diag_tickTime)],
            { [7] spawn life_fnc_talAction }, "backup", "backup"],
        ["JAMMER", "Deck Jammer", "80m intrusion blackout for 60s. Park it on the Fed.", 0, (_capt && {diag_tickTime >= _jamCd}),
            (if (!_capt) then {"CAPTAIN+ ONLY"} else {format ["RECHARGING %1s", ceil (_jamCd - diag_tickTime)]}),
            { [8] spawn life_fnc_talAction }, "jammer", "jammer"],
        ["HONEYPOT", "Honeypot ATM", "Rigs this machine. The next deck that hits it burns.", 0,
            (_capt && {_isATM}), (if (!_capt) then {"CAPTAIN+ ONLY"} else {"NO ATM"}),
            { [9] spawn life_fnc_talAction }, "honeypot", "honeypot"],
        ["DRONE", "Drone Uplink", "Launch the UCAV straight from the visor.", 1,
            _capt, "CAPTAIN+ ONLY", { [] spawn life_fnc_copUAV }, "drone", "drone"],
        ["SAFE STOP", "Remote Vehicle Stop", "8s uplink stalls a wanted suspect's vehicle.", 0,
            (_sgt && {_isVeh} && {diag_tickTime >= _stopCd}),
            (if (!_sgt) then {"SGT+ ONLY"} else {if (!_isVeh) then {"NO VEHICLE"} else {format ["RECHARGING %1s", ceil (_stopCd - diag_tickTime)]}}),
            { [10] spawn life_fnc_talAction }, "vehstop", "vehstop"],
        ["BREACH ORDER", "Breach Order", "Warranted entry. Instant unlock, on the record.", 0,
            (_sgt && {_isVeh}), (if (!_sgt) then {"SGT+ ONLY"} else {"NO VEHICLE"}),
            { [11] spawn life_fnc_talAction }, "breachorder", "breachorder"],
        ["ASSET FREEZE", "Asset Freeze", "Lock a wanted suspect's ATM and bank for 10 minutes.", 0,
            (_sgt && {_isPly}), (if (!_sgt) then {"SGT+ ONLY"} else {"NO SUSPECT"}),
            { [12] spawn life_fnc_talAction }, "assetfreeze", "assetfreeze"],
        ["GRID PRIORITY", "Grid Priority", "Restore street lights a deck blacked out nearby.", 1,
            _sgt, "SGT+ ONLY", { [13] spawn life_fnc_talAction }, "gridpriority", "gridpriority"],
        ["BLACK BOX", "Black Box Subpoena", "Recover who wiped a suspect's memory.", 1,
            (_sgt && {_isPly}), (if (!_sgt) then {"SGT+ ONLY"} else {"NO SUSPECT"}),
            { [14] spawn life_fnc_talAction }, "blackbox", "blackbox"],
        ["REMOTE DETAIN", "Remote Detain", "10s channel, then a full ragdoll. Felony only.", 2,
            (_sgt && {_isPly}), (if (!_sgt) then {"SGT+ ONLY"} else {"NO SUSPECT"}), { [15] spawn life_fnc_talAction }, "detain", "detain"],
        ["WARRANT", "Warrant Request", "Request a lawful-entry warrant. A senior officer signs off.", 1,
            _isPly, "NO SUSPECT", { [16] spawn life_fnc_talAction }, "warrant", "warrant"]];} else {_cat = [
        ["WARDRIVE", "Wardrive Scan", "Maps every hackable target near you for 30s.", 1,
            (diag_tickTime >= _wdCd), format ["RECHARGING %1s", ceil (_wdCd - diag_tickTime)],
            { [] spawn life_fnc_cyberdeckWardrive }, "wardrive", "wardrive"],
        ["UNLOCK", "Vehicle Unlock", "Sequence breach a locked vehicle's doors.", 0,
            (_isVeh && {(locked _tgt) != 0}), (if (_isVeh) then {"ALREADY UNLOCKED"} else {"NO VEHICLE"}),
            { [PLB_cdTarget] spawn life_fnc_cyberdeck }, "unlock", "unlock"],
        ["KILLSWITCH", "Killswitch.dll", "Fries the engine for ~20s. Stops a runner.", 0,
            _isVeh, "NO VEHICLE", { [PLB_cdTarget] spawn life_fnc_cyberdeckIgnition }, "ignition", "ignition"],
        ["ATM", "ATM Jackpot", "Skims an ATM for cash. Once each per restart.", 0,
            (_isATM && {_atmWhy isEqualTo ""}), (if (_isATM) then {_atmWhy} else {"NO ATM"}),
            { [PLB_cdTarget] spawn life_fnc_cyberdeckATM }, "atm", "atm"],
        ["HOUSE", "Breach House", "Terminal breach someone else's front door.", 0,
            _isHouse, "NO DOOR", { [PLB_cdTarget] spawn life_fnc_cyberdeck }, "house", "house"],
        ["RIG", "Hijack Rig", "Takes over a rig. Payout reroutes to you.", 0,
            _isRig, "NO RIG", { [PLB_cdTarget] spawn life_fnc_cyberdeck }, "rig", "rig"],
        ["TURF", "Turf Sniffer", "Live capture points, holders and timers.", 1, true, "", { [] spawn life_fnc_capture }, "turf", "turf"],
        ["MARKET", "Market Sniffer", "What every sellable item is paying right now.", 1,
            true, "", { [] spawn life_fnc_market }, "market", "market"],
        ["PROXY", "Proxy Chain", "Arms a proxy. Next hack leaves no trace.", 1,
            ((missionNamespace getVariable ["life_inv_proxychain", 0]) > 0 && {!(player getVariable ["plb_proxyActive", false])}),
            (if ((missionNamespace getVariable ["life_inv_proxychain", 0]) > 0) then {"ALREADY ARMED"} else {"NONE LEFT"}),
            { if ([false, "proxychain", 1] call life_fnc_handleInv) then {player setVariable ["plb_proxyActive", true, true];
                  ["<t color='#33ffbb'>PROXY CHAIN ACTIVE</t> -- your next hack leaves no trace.", "basic"] spawn life_fnc_handleMessage;
              }; }, "proxy", "proxy"], ["BREACH KIT", "Breach Kit", "Arms a kit. Next breach auto-solves.", 2,
            ((missionNamespace getVariable ["life_inv_breachkit", 0]) > 0 && {!plb_breachKitArmed}),
            (if ((missionNamespace getVariable ["life_inv_breachkit", 0]) > 0) then {"ALREADY ARMED"} else {"NONE LEFT"}),
            { if ([false, "breachkit", 1] call life_fnc_handleInv) then {plb_breachKitArmed = true;
                  ["<t color='#c9e21a'>BREACH KIT ARMED</t> -- your next breach auto-completes.", "basic"] spawn life_fnc_handleMessage;
              }; }, "breachkit", "breachkit"], ["CUFFS", "Cuff Cracker", "Breach your own restraints. (Or just SHIFT+Y while cuffed.)", 0,
            ((player getVariable ["plb_restrained", false]) || {player getVariable ["plb_civRestrained", false]}), "NOT CUFFED",
            { [] spawn life_fnc_qhCuffHack }, "cuffs", "cuffs"]];};

// ---- Tier-1 QUICKHACKS: built generically from the catalogue so new ones are drop-in ----
private _qhIsPly = (!isNull _tgt) && {_tgt isKindOf "CAManBase"} && {isPlayer _tgt} && {_tgt != player};
private _qhDist  = if (isNull _tgt) then { 9999 } else { player distance _tgt }; {
    _x params ["_qid", "_qname", "_qblurb", "_qicon", "", "", "_qcd", "_qrange", "_qlos", "_qauth", "_qkind", "", ["_qreq", -1]];
    private _cdLeft = (missionNamespace getVariable ["plb_qhCd_" + _qid, 0]) - diag_tickTime;
    private _ok = true; private _why = "";
    if (_cdLeft > 0) then { _ok = false; _why = format ["RECHARGING %1s", ceil _cdLeft]; };
    if (_ok && {_qreq > -1} && {!(_qreq in _mods)}) then { _ok = false; _why = "CHIP NOT INSTALLED"; };
    if (_ok && {_qkind isEqualTo "vehicle"}) then {if (!_isVeh) then { _ok = false; _why = "NO VEHICLE"; }
        else {if !(_tgt in life_vehicles) then { _ok = false; _why = "NOT YOUR RIDE"; }
            else { if (_qhDist > _qrange) then { _ok = false; _why = "OUT OF RANGE"; }; };};};
    if (_ok && {_qkind isEqualTo "drivable"}) then {
        // Puppet Strings: aim at any car (empty or occupied) that isn't your own seat. Autopilot/analog are
        // re-checked server-side; the ring only greys when there's plainly no car under the cursor.
        private _dv = if (!isNull _tgt && {_tgt isKindOf "CAManBase"}) then { vehicle _tgt } else { _tgt };
        if (isNull _dv || {!((_dv isKindOf "Car") || (_dv isKindOf "Ship"))}) then { _ok = false; _why = "NO VEHICLE"; }
        else {if (_dv isEqualTo (vehicle player)) then { _ok = false; _why = "YOUR OWN SEAT"; }
            else { if ((player distance _dv) > _qrange) then { _ok = false; _why = "OUT OF RANGE"; }; };};};
    if (_ok && {_qkind isEqualTo "occupied"}) then {
        // Chauffeur Override: aim at an occupied enemy car (or its driver). Autopilot / analog are re-checked
        // server-side; the ring only greys the wedge when there is plainly no valid target under the cursor.
        private _ov = if (!isNull _tgt && {_tgt isKindOf "CAManBase"}) then { vehicle _tgt } else { _tgt };
        if (isNull _ov || {!((_ov isKindOf "Car") || (_ov isKindOf "Ship"))}) then { _ok = false; _why = "NO VEHICLE"; }
        else {
            if (isNull (driver _ov) || {!(isPlayer (driver _ov))} || {(driver _ov) isEqualTo player}) then { _ok = false; _why = "NOT OCCUPIED"; }
            else { if ((player distance _ov) > _qrange) then { _ok = false; _why = "OUT OF RANGE"; }; };};};
    if (_ok && {_qkind isEqualTo "player"}) then {if (!_qhIsPly) then { _ok = false; _why = "NO TARGET"; }
        else {if (_qhDist > _qrange) then { _ok = false; _why = "OUT OF RANGE"; }
            else {
                if (_qlos && {!([objNull, "VIEW"] checkVisibility [eyePos player, eyePos _tgt] > 0.3)}) then { _ok = false; _why = "NO LINE OF SIGHT"; };
                if (_ok) then {switch (_qauth) do {
                        case "wanted": { if ((_tgt getVariable ["plb_wantedAmt", 0]) <= 0) then { _ok = false; _why = "NOT WANTED"; }; };
                        case "restrained": { if (!((_tgt getVariable ["plb_restrained", false]) || (_tgt getVariable ["plb_civRestrained", false]))) then { _ok = false; _why = "NOT RESTRAINED"; }; };
                        case "wantedArmed": {if ((_tgt getVariable ["plb_wantedAmt", 0]) <= 0) then { _ok = false; _why = "NOT WANTED"; }
                            else { if ((currentWeapon _tgt) isEqualTo "") then { _ok = false; _why = "NOT ARMED"; }; };};
                        default {};};};};};};
    _cat pushBack [toUpper _qname, _qname, _qblurb, 1, _ok, _why, compile format ["[""%1""] spawn life_fnc_qhCast", _qid], _qid, _qicon];
} forEach ([(if (_isCop) then {"cop"} else {"civ"})] call life_fnc_qhCfg);

// ---- compose the 8 wedges: 3 FIXED tools keep their home slots, 5 come from the player's loadout ----
PLB_ringVectors = []; {private _id = _x;
    private _hit = _cat select { (_x select 7) isEqualTo _id };
    PLB_ringVectors pushBack (if (_hit isEqualTo []) then { [] } else { _hit select 0 });} forEach ([] call PLB_fnc_ringSlots);

PLB_cdTarget = _tgt;
PLB_ringSel  = -1;

if !(createDialog "cyberdeck_ring") exitWith { PLB_ringVectors = nil; };
private _d = findDisplay 941200;

// ---- RESOLUTION-INDEPENDENT LAYOUT (owner 2026-07-20: the UI_GRID macros are a FIXED PIXEL size
// (2.5 * pixelW * pixelGrid), so the ring shrank on high-res / ultrawide displays). Everything is
// re-laid out here from safezone: the ring is a share of screen HEIGHT (so 16:9 and 21:9 both read
// the same) and kept square in PIXELS via the pixelW/pixelH ratio. ----
PLB_ringGeo = [];
call {private _ringH = 0.55 * safezoneH;                  // ring = 55% of screen height, any resolution
    private _ringW = _ringH * (pixelW / pixelH);        // square in real pixels, aspect-corrected
    private _cx = 0.5;
    private _cy = 0.5;
    PLB_ringGeo = [_cx, _cy, _ringW, _ringH];
    private _rect = [_cx - _ringW / 2, _cy - _ringH / 2, _ringW, _ringH];
    { private _c = _d displayCtrl _x; _c ctrlSetPosition _rect; _c ctrlCommit 0; } forEach [941210,941220,941221,941222,941223,941224,941225,941226,941227];

    // Labels sit INSIDE the wedge band, one notch ABOVE the baked icon (render_ring.py draws the icon at
    // band-centre +0.048 screen-down, so the pair reads as label-over-icon in every wedge). Band centre is
    // (r0+r1)/2 = 0.337; the narrowest chord there is ~0.22 ring-widths, which caps the label box.
    private _lw = 0.22 * _ringW;
    private _lh = 0.055 * _ringH;
    for "_i" from 0 to 7 do {private _mid = (_i / 8) * 360 - 90;             // wedge centre, degrees, clockwise from top
        private _ox = 0.337 * _ringW * cos _mid;
        private _oy = (0.337 * _ringH * sin _mid) - (0.048 * _ringH);
        private _c = _d displayCtrl (941230 + _i);
        _c ctrlSetPosition [_cx + _ox - _lw / 2, _cy + _oy - _lh / 2, _lw, _lh];
        _c ctrlSetFontHeight (0.040 * _ringH);
        _c ctrlCommit 0;
        // live tool icon, one notch BELOW its label (the art no longer carries glyphs)
        private _is = 0.105 * _ringH;
        private _ic = _d displayCtrl (941260 + _i);
        _ic ctrlSetPosition [_cx + _ox - (_is * (pixelW / pixelH)) / 2, _cy + (0.337 * _ringH * sin _mid) + (0.050 * _ringH) - _is / 2,
                             _is * (pixelW / pixelH), _is];
        _ic ctrlCommit 0;};
    // Hub block. Inner disc radius is 0.215*ring, so a centred box tops out ~0.30 ring-widths before it
    // clips the ring wall. Rows stack with NO overlap: name / blurb (up to 3 lines) / status.
    private _hw = 0.30 * _ringW;
    { _x params ["_idc", "_dy", "_fs", "_hh"];
      private _c = _d displayCtrl _idc;
      _c ctrlSetPosition [_cx - _hw / 2, _cy + _dy * _ringH, _hw, _hh * _ringH];
      _c ctrlSetFontHeight (_fs * _ringH);
      _c ctrlCommit 0;} forEach [[941240,-0.130,0.056,0.060],[941241,-0.060,0.032,0.120],[941242,0.068,0.038,0.090]];

    // telemetry pinned to the safezone corners so ultrawide spreads instead of clipping
    private _tw = 0.30 * safezoneW;
    private _th = 0.12 * safezoneH;
    private _fs = 0.026 * safezoneH;
    private _mx = safezoneX + 0.018 * safezoneW;
    private _my = safezoneY + 0.030 * safezoneH;
    private _rx = safezoneX + safezoneW - _tw - 0.018 * safezoneW;
    private _by = safezoneY + safezoneH - _th - 0.030 * safezoneH;
    { _x params ["_idc", "_px", "_py"];
      private _c = _d displayCtrl _idc;
      _c ctrlSetPosition [_px, _py, _tw, _th];
      _c ctrlSetFontHeight _fs;
      _c ctrlCommit 0;} forEach [[941250,_mx,_my],[941251,_rx,_my],[941252,_mx,_by],[941253,_rx,_by]];};

// ---- APD art swap: same ring geometry, police-issue skin ----
if (_isCop) then {(_d displayCtrl 941210) ctrlSetText "images\cyberdeck\ring_pd_base.paa";
    for "_k" from 0 to 7 do { (_d displayCtrl (941220 + _k)) ctrlSetText format ["images\cyberdeck\ring_pd_hl_%1.paa", _k]; };};

// ---- labels: colour carries state (primary ready / flavour utility / danger blocked) ----
PLB_ringPal params ["_pPri", "_pFla", "_pDan", "_pDim", "_pFai"]; {private _lc = _d displayCtrl (941230 + _forEachIndex);
    private _ic = _d displayCtrl (941260 + _forEachIndex);
    if (_x isEqualTo []) then {                       // empty slot (shouldn't happen -- fail visibly quiet)
        _lc ctrlSetStructuredText parseText "";
        _ic ctrlSetText "";} else {_x params ["_lab", "", "", "_tone", "_ok", "", "", "", ["_icon", ""]];
        private _col = if (!_ok) then { _pDan } else { [_pPri, _pFla, _pPri] select _tone };
        _lc ctrlSetStructuredText parseText
            format ["<t align='center' size='1' font='EtelkaMonospacePro' color='%1'>%2</t>", _col, _lab];
        // live per-tool glyph: the ring art is iconless so a tool keeps its icon in any slot
        _ic ctrlSetText (if (_icon isEqualTo "") then { "" } else { format ["images\cyberdeck\icons\%1.paa", _icon] });
        _ic ctrlSetTextColor (if (!_ok) then { [1, 0.23, 0.19, 0.65] } else { [0.55, 0.62, 0.60, 1] });};} forEach PLB_ringVectors;

PLB_fnc_ringHub = {params ["_i"];
    private _d = findDisplay 941200;
    if (isNull _d) exitWith {};
    (missionNamespace getVariable ["PLB_ringPal", ["#c9e21a","#33ffbb","#ff3b1e","#7f918a","#4c5a55"]]) params ["_pPri","_pFla","_pDan","_pDim"];
    private _idle = if (playerSide isEqualTo west) then { "SELECT ACTION" } else { "SELECT VECTOR" };
    private _rdy  = if (playerSide isEqualTo west) then { "8 TOOLS ONLINE" } else { "8 VECTORS ONLINE" };
    if (_i < 0) exitWith {
        (_d displayCtrl 941240) ctrlSetStructuredText parseText format ["<t align='center' size='1' font='PuristaBold' color='%1'>%2</t>", _pPri, _idle];
        (_d displayCtrl 941241) ctrlSetStructuredText parseText format ["<t align='center' size='1' color='%1'>Orbit the ring.<br/>Click to execute.</t>", _pDim];
        (_d displayCtrl 941242) ctrlSetStructuredText parseText format ["<t align='center' size='1' color='%1'>%2</t>", _pFla, _rdy];};
    private _e = PLB_ringVectors select _i;
    if (_e isEqualTo []) exitWith {};
    _e params ["", "_full", "_blurb", "", "_ok", "_why"];
    (_d displayCtrl 941240) ctrlSetStructuredText parseText format ["<t align='center' size='1' font='PuristaBold' color='%1'>%2</t>", _pPri, toUpper _full];
    (_d displayCtrl 941241) ctrlSetStructuredText parseText format ["<t align='center' size='1' color='%1'>%2</t>", _pDim, _blurb];
    (_d displayCtrl 941242) ctrlSetStructuredText parseText format ["<t align='center' size='1' color='%1'>%2</t>",
        (if (_ok) then {_pFla} else {_pDan}), (if (_ok) then {"READY"} else {toUpper _why})];};
PLB_fnc_ringWire = {
// ---- true radial pick: screen mouse -> ring box -> angle -> wedge ----
private _d = findDisplay 941200;
private _catch = _d displayCtrl 941201;
_catch ctrlAddEventHandler ["MouseMoving", {params ["", "_mx", "_my"];
    // normalise the cursor into the RING's own box (square in pixels) so the pick is identical on
    // every resolution and aspect. Radii are the render_ring.py constants: hub 0.215, outer 0.459.
    (missionNamespace getVariable ["PLB_ringGeo", [0.5, 0.5, 0.4, 0.4]]) params ["_cx", "_cy", "_rw", "_rh"];
    private _dx = (_mx - _cx) / _rw;
    private _dy = (_my - _cy) / _rh;
    private _r  = sqrt ((_dx * _dx) + (_dy * _dy));
    private _i  = -1;
    if (_r > 0.215 && {_r < 0.50}) then {private _deg = ((_dy atan2 _dx) + 112.5) % 360;
        if (_deg < 0) then { _deg = _deg + 360 };
        _i = floor (_deg / 45);};
    if !(_i isEqualTo PLB_ringSel) then {PLB_ringSel = _i;
        private _d2 = findDisplay 941200;
        for "_k" from 0 to 7 do { (_d2 displayCtrl (941220 + _k)) ctrlShow (_k isEqualTo _i); };
        [_i] call PLB_fnc_ringHub;};}];
_catch ctrlAddEventHandler ["MouseButtonDown", {params ["", "_btn"];
    if (_btn isEqualTo 1) exitWith { closeDialog 0; };      // right-click = out
    if (PLB_ringSel < 0) exitWith {};
    private _sel = PLB_ringVectors select PLB_ringSel;
    if (_sel isEqualTo []) exitWith { closeDialog 0; };
    _sel params ["", "_full", "", "", "_ok", "_why", "_code"];
    closeDialog 0;
    if (!_ok) exitWith { [format ["%1 -- %2.", toUpper _full, _why], "basic"] spawn life_fnc_handleMessage; };
    [] spawn _code;}];};

// ---- telemetry: APD readout (issued kit, unit identity, live cooldowns) ----
private _tnameC = if (isNull _tgt) then { "NO LOCK" } else {
    if ((_tgt isKindOf "CAManBase") && {isPlayer _tgt}) then { toUpper (name _tgt) } else {
        private _dn = getText (configFile >> "CfgVehicles" >> _tt >> "displayName");
        toUpper (if (_dn isEqualTo "") then { _tt } else { _dn })};};
if (_isCop) exitWith {private _rankTxt = [west, player] call life_fnc_getRankString;
    (_d displayCtrl 941250) ctrlSetStructuredText parseText format [
        "<t size='1' font='EtelkaMonospacePro' color='%1'>SYSTEM</t><br/><t size='1' color='#dbe4ee'>TAL OS</t>  <t size='0.95' color='%2'>@ APD ISSUE</t><br/><t size='0.9' color='%3'>All actions logged</t>",
        _pFai, _pFla, _pDim];
    (_d displayCtrl 941251) ctrlSetStructuredText parseText format [
        "<t size='1' align='right' font='EtelkaMonospacePro' color='%1'>SUBJECT</t><br/><t size='1' align='right' color='#dbe4ee'>%2</t><br/><t size='0.9' align='right' color='%3'>%4</t>",
        _pFai, _tnameC, _pDim, (if (isNull _tgt) then {"aim at a subject"} else {format ["%1 m", (round ((player distance _tgt) * 10)) / 10]})];
    (_d displayCtrl 941252) ctrlSetStructuredText parseText format [
        "<t size='1' font='EtelkaMonospacePro' color='%1'>UNIT</t><br/><t size='1' color='#dbe4ee'>%2</t>  <t size='0.95' color='%3'>%4</t>",
        _pFai, toUpper (name player), _pFla, toUpper _rankTxt];
    private _fmt = { if (diag_tickTime >= _this) then { "ready" } else { format ["%1s", ceil (_this - diag_tickTime)] } };
    (_d displayCtrl 941253) ctrlSetStructuredText parseText format [
        "<t size='1' align='right' font='EtelkaMonospacePro' color='%1'>COOLDOWNS</t><br/><t size='0.95' align='right' color='%2'>SWEEP</t> <t size='1' color='#dbe4ee'>%3</t>   <t size='0.95' color='%2'>PIN</t> <t size='1' color='#dbe4ee'>%4</t>   <t size='0.95' color='%2'>BACKUP</t> <t size='1' color='#dbe4ee'>%5</t>",
        _pFai, _pDim, ((missionNamespace getVariable ["plb_talSweepCd", 0]) call _fmt),
        ((missionNamespace getVariable ["plb_talPinCd", 0]) call _fmt), ((missionNamespace getVariable ["plb_talBackupCd", 0]) call _fmt)];
    [-1] call PLB_fnc_ringHub;
    call PLB_fnc_ringWire;};

// ---- telemetry (all state you already have) ----
private _modChips = ""; {_x params ["_mid", "_mname"];
    if (_mid > 0) then {private _on = _mid in _mods;
        _modChips = _modChips + format ["<t color='%1'>%2</t>  ", (if (_on) then {"#33ffbb"} else {"#3d4a44"}), toUpper _mname];};
} forEach PLB_cdModules;
(_d displayCtrl 941250) ctrlSetStructuredText parseText format [
    "<t size='1' font='EtelkaMonospacePro' color='#4c5a55'>FIRMWARE</t><br/><t size='1' color='#dbe7e0'>ICEBREAKER OS</t>  <t size='0.95' color='#ff3b1e'>@ ILLEGAL</t><br/><t size='0.9'>%1</t>", _modChips];
private _tname = if (isNull _tgt) then { "no lock" } else {private _dn = getText (configFile >> "CfgVehicles" >> _tt >> "displayName");
    if (_dn isEqualTo "") then { _tt } else { _dn };};
(_d displayCtrl 941251) ctrlSetStructuredText parseText format [
    "<t size='1' align='right' font='EtelkaMonospacePro' color='#4c5a55'>TARGET LOCK</t><br/><t size='1' align='right' color='#dbe7e0'>%1</t><br/><t size='0.9' align='right' color='#7f918a'>%2</t>",
    toUpper _tname, (if (isNull _tgt) then {"aim at something"} else {format ["%1 m", (round ((player distance _tgt) * 10)) / 10]})];
(_d displayCtrl 941252) ctrlSetStructuredText parseText format [
    "<t size='1' font='EtelkaMonospacePro' color='#4c5a55'>CONSUMABLES</t><br/><t size='1' color='#dbe7e0'>%1</t> <t size='0.95' color='#7f918a'>Proxy Chain</t>   <t size='1' color='#dbe7e0'>%2</t> <t size='0.95' color='#7f918a'>Breach Kit</t>",
    (missionNamespace getVariable ["life_inv_proxychain", 0]), (missionNamespace getVariable ["life_inv_breachkit", 0])];
private _atmTxt = if (diag_tickTime < (missionNamespace getVariable ["plb_atmHackCd", 0])) then {
    format ["%1 min", ceil (((missionNamespace getVariable ["plb_atmHackCd", 0]) - diag_tickTime) / 60)]} else { "ready" };
(_d displayCtrl 941253) ctrlSetStructuredText parseText format [
    "<t size='1' align='right' font='EtelkaMonospacePro' color='#4c5a55'>COOLDOWNS</t><br/><t size='0.95' align='right' color='#7f918a'>ATM</t> <t size='1' align='right' color='#dbe7e0'>%1</t>   <t size='0.95' color='#7f918a'>WARDRIVE</t> <t size='1' color='#dbe7e0'>%2</t>",
    _atmTxt, (if (diag_tickTime >= _wdCd) then {"ready"} else {format ["%1s", ceil (_wdCd - diag_tickTime)]})];
[-1] call PLB_fnc_ringHub;
call PLB_fnc_ringWire;
