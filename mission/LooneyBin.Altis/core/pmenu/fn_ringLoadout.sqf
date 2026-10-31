// Altis Life game mechanic — fictional in-game "quickhack" ability, game logic only
/*
    File: fn_ringLoadout.sqf  (life_fnc_ringLoadout)
    LooneyBin 2026-07-20: QUICK-HACK LOADOUT editor -- pick which tools occupy the 5 changeable wedges
    of the SHIFT+Y ring. Civilians edit ICEBREAKER, officers edit TAL OS; three tools per side are welded
    to their wedge and are shown greyed so the rule is visible rather than mysterious.

    Loadout persists in profileNamespace as ID STRINGS ONLY (never code -- see security.md).
*/
if (playerSide isEqualTo west) then {} else {if !(call PLB_fnc_hasDeck) exitWith {
        ["No deck firmware. Flash it at an electronics shop first.", "basic"] spawn life_fnc_handleMessage;};};
if !(playerSide in [west, civilian]) exitWith {};
closeDialog 0;
uiSleep 0.1;
if !(createDialog "ring_loadout") exitWith {};
private _d = findDisplay 941400;

private _cop  = playerSide isEqualTo west;
PLB_ringLoadSel = 0;
PLB_ringLoadMode = 1;                                  // FIREWALL-ONLY now: the loadout moved to the ICEBREAKER OS /
                                                       // TAL OS console (the wheel mirrors it). This editor keeps only the counter-chips.
PLB_ringLoadWork = +(call PLB_fnc_ringLoadout);
PLB_fwWork = +(call PLB_fnc_fwEquipped);
(_d displayCtrl 941422) ctrlShow false;                // hide the RING SLOTS/FIREWALL toggle -- firewall only
(_d displayCtrl 941422) ctrlEnable false;

private _pri = if (_cop) then { "#f0a01e" } else { "#c9e21a" };
private _fla = if (_cop) then { "#4db8ff" } else { "#33ffbb" };
(_d displayCtrl 941402) ctrlSetStructuredText parseText format [
    "<t size='1' font='EtelkaMonospacePro' color='#4c5a55'>// %1 FIREWALL</t>", (if (_cop) then {"TAL OS"} else {"ICEBREAKER"})];
(_d displayCtrl 941403) ctrlSetStructuredText parseText format [
    "<t size='1' font='PuristaBold' color='%1'>RING SLOTS</t>  <t size='0.75' color='#7f918a'>pick a slot, then a tool</t>", _pri];
(_d displayCtrl 941404) ctrlSetStructuredText parseText format ["<t size='1' font='PuristaBold' color='%1'>AVAILABLE</t>", _fla];

// name + hover-help lookups for ids. Quickhacks pull name/blurb/numbers straight from the
// catalogue (fn_qhCfg) so they can't drift; tool wedges mirror the blurbs in fn_cyberdeckRing
// (kept inline so the editor doesn't need the whole ring context).
PLB_ringNames = createHashMapFromArray [["wardrive","Wardrive Scan"], ["unlock","Vehicle Unlock"], ["ignition","Killswitch.dll"],
    ["atm","ATM Jackpot"], ["house","Breach House"], ["rig","Hijack Rig"],
    ["turf","Turf Sniffer"], ["market","Market Sniffer"], ["proxy","Proxy Chain"], ["breachkit","Breach Kit"],
    ["records","Records Lookup"], ["plate","Plate Scan"], ["field","Field Test"], ["firmware","Firmware Scan"],
    ["reset","Factory Reset"], ["bolo","BOLO Board"], ["units","Unit Board"],
    ["sweep","Contraband Sweep"], ["dispatch","Dispatch Pin"], ["backup","Backup Beacon"],
    ["jammer","Deck Jammer"], ["honeypot","Honeypot ATM"], ["drone","Drone Uplink"],
    ["vehstop","Remote Vehicle Stop"], ["breachorder","Breach Order"]];
PLB_ringDescs = createHashMapFromArray [["wardrive","Maps every hackable target near you for 30s."],
    ["unlock","Sequence breach a locked vehicle's doors."], ["ignition","Fries the engine for ~20s. Stops a runner."],
    ["atm","Skims an ATM for cash. Once each per restart."], ["house","Terminal breach someone else's front door."],
    ["rig","Takes over a rig. Payout reroutes to you."], ["turf","Live capture points, holders and timers."],
    ["market","What every sellable item is paying right now."], ["proxy","Arms a proxy. Next hack leaves no trace."],
    ["breachkit","Arms a kit. Next breach auto-solves."], ["records","Priors, gang and time served."],
    ["plate","Registered owner. Flags a driver with no keys."], ["field","Breathalyser + drug screen on a suspect."],
    ["firmware","Is this handset running an illegal deck OS?"], ["reset","Wipes illegal firmware. Their upgrades survive."],
    ["bolo","Active APBs and who the APD wants."], ["units","Every officer on duty right now."],
    ["sweep","Marks rigs and ATM skimmers within 300m."], ["dispatch","Marks your position for every unit."],
    ["backup","Panic button. Alerts all units and medics."], ["jammer","80m intrusion blackout for 60s. Park it on the Fed."],
    ["honeypot","Rigs this machine. The next deck that hits it burns."], ["drone","Launch the UCAV straight from the visor."],
    ["vehstop","8s uplink stalls a wanted suspect's vehicle. Analog retrofits are immune.  [SGT+ / 180s cooldown]"],
    ["breachorder","Instant lawful unlock on a vehicle tied to a wanted suspect.  [SGT+ / no minigame]"]];
// id -> icon basename. Tool wedges name their icon after the id, but QUICKHACK icons are baked as "qh_<id>"
// (fn_cyberdeckRing carries the icon as its own catalogue field). This list was building picture paths from the
// id alone, so every quickhack row asked for e.g. icons\ping.paa -- a file that has never existed -- and drew
// nothing. Map it from the same catalogue the ring uses so the two can never disagree again.
PLB_ringIcons = createHashMap; {_x params ["_qid", "_qname", "_qblurb", "_qicon", "", "_qup", "_qcd", "_qrange", "_qlos", "_qauth"];
    PLB_ringNames set [_qid, _qname];
    PLB_ringIcons set [_qid, _qicon];
    private _meta = format ["%1s upload / %2s cooldown / %3m", _qup, _qcd, _qrange];
    if (_qlos) then { _meta = _meta + " / needs line of sight" };
    switch (_qauth) do {case "wanted":      { _meta = _meta + " / target must be WANTED" };
        case "restrained":  { _meta = _meta + " / target must be RESTRAINED" };
        case "wantedArmed": { _meta = _meta + " / target must be WANTED + ARMED" };};
    PLB_ringDescs set [_qid, format ["%1  [%2]", _qblurb, _meta]];} forEach (["all"] call life_fnc_qhCfg);

life_fnc_ringLoadoutRefresh = {private _d = findDisplay 941400;
    if (isNull _d) exitWith {};
    private _cop = playerSide isEqualTo west;
    // ---- FIREWALL MODE: 2 equipped chips left, owned chips right ----
    if ((missionNamespace getVariable ["PLB_ringLoadMode", 0]) isEqualTo 1) exitWith {
        private _slots = _d displayCtrl 941410; private _av = _d displayCtrl 941411;
        lbClear _slots; lbClear _av;
        private _owned = call PLB_fnc_fwOwned;
        for "_i" from 0 to 1 do {private _id = PLB_fwWork param [_i, ""];
            private _row = if (_id isEqualTo "") then { [] } else { (PLB_fwChips select { (_x select 0) isEqualTo _id }) param [0, []] };
            private _nm = if (_row isEqualTo []) then { "-- empty --" } else { _row select 2 };
            private _r = _slots lbAdd format ["FIREWALL %1     %2", _i + 1, _nm];
            _slots lbSetData [_r, _id];
            if (_row isNotEqualTo []) then { _slots lbSetTooltip [_r, _row select 3] };   // 0.2.0: hover explains the equipped chip's effect
        };
        _slots lbSetCurSel ((missionNamespace getVariable ["PLB_ringLoadSel", 0]) min 1); {_x params ["_cid", "", "_cnm", "_cdesc"];
            if (_cid in _owned) then {private _on = _cid in PLB_fwWork;
                private _r = _av lbAdd (if (_on) then { format ["%1   (live)", _cnm] } else { _cnm });
                _av lbSetData [_r, _cid];
                _av lbSetTooltip [_r, _cdesc];
                if (_on) then { _av lbSetColor [_r, [0.42,0.48,0.46,1]] };};} forEach PLB_fwChips;
        (_d displayCtrl 941412) ctrlSetStructuredText parseText
            "<t size='1' color='#7f918a'>Only TWO chips can be live at once -- pick your poison.<br/>Chips are bought at Kabuki Electronics (APD are issued the full set).</t>";
        (_d displayCtrl 941403) ctrlSetStructuredText parseText "<t size='1' font='PuristaBold' color='#33ffbb'>FIREWALL</t>  <t size='0.75' color='#7f918a'>2 slots</t>";
        (_d displayCtrl 941404) ctrlSetStructuredText parseText "<t size='1' font='PuristaBold' color='#33ffbb'>OWNED CHIPS</t>";};
    private _fixed = if (_cop) then { PLB_ringFixedCop } else { PLB_ringFixed };
    private _pool  = if (_cop) then { PLB_ringPoolCop } else { PLB_ringPool };
    private _slots = _d displayCtrl 941410;
    private _av    = _d displayCtrl 941411;
    lbClear _slots; lbClear _av;

    // 5 editable slots
    {private _nm = PLB_ringNames getOrDefault [_x, toUpper _x];
        private _i = _slots lbAdd format ["SLOT %1     %2", _forEachIndex + 1, _nm];
        _slots lbSetData [_i, _x];
        _slots lbSetPicture [_i, format ["images\cyberdeck\icons\%1.paa", (PLB_ringIcons getOrDefault [_x, _x])]];
        _slots lbSetTooltip [_i, PLB_ringDescs getOrDefault [_x, ""]];} forEach PLB_ringLoadWork;
    // welded tools, shown so the 5-of-8 rule is legible
    {private _nm = PLB_ringNames getOrDefault [_x, toUpper _x];
        private _i = _slots lbAdd format ["FIXED      %1", _nm];
        _slots lbSetData [_i, "#fixed"];
        _slots lbSetPicture [_i, format ["images\cyberdeck\icons\%1.paa", (PLB_ringIcons getOrDefault [_x, _x])]];
        _slots lbSetColor [_i, [0.42, 0.48, 0.46, 1]];
        _slots lbSetTooltip [_i, (PLB_ringDescs getOrDefault [_x, ""]) + "  (welded -- can't be swapped)"];} forEach _fixed;
    _slots lbSetCurSel (PLB_ringLoadSel min 4);

    // available pool -- equipped entries dimmed
    {private _nm = PLB_ringNames getOrDefault [_x, toUpper _x];
        private _on = _x in PLB_ringLoadWork;
        private _i = _av lbAdd (if (_on) then { format ["%1   (equipped)", _nm] } else { _nm });
        _av lbSetData [_i, _x];
        _av lbSetPicture [_i, format ["images\cyberdeck\icons\%1.paa", (PLB_ringIcons getOrDefault [_x, _x])]];
        _av lbSetTooltip [_i, PLB_ringDescs getOrDefault [_x, ""]];
        if (_on) then { _av lbSetColor [_i, [0.42, 0.48, 0.46, 1]] };} forEach _pool;

    (_d displayCtrl 941412) ctrlSetStructuredText parseText format [
        "<t size='1' color='#7f918a'>Three tools are welded to the ring and can't be swapped. The other five are yours.<br/>Changes save instantly and apply the next time you open the ring (%1).</t>",
        (if (_cop) then {"SHIFT+Y"} else {"SHIFT+Y"})];};
call life_fnc_ringLoadoutRefresh;

(_d displayCtrl 941410) ctrlAddEventHandler ["LBSelChanged", {params ["_c", "_i"];
    if ((_c lbData _i) isEqualTo "#fixed") exitWith {_c lbSetCurSel (PLB_ringLoadSel min 4);
        ["That wedge is welded -- it can't be swapped out.", "basic"] spawn life_fnc_handleMessage;};
    PLB_ringLoadSel = _i;}];
