/*
    TON_fnc_newsPush  (LooneyBin -- DataBattle living newspaper). SERVER-side; called from event fire points.
      [_cat, _headline]            prepend a headline to PLB_newsHeadlines (public var, cap 15) for the
                                   databattle.com browser page (Ben Bones spins real server events).
      [_cat, _headline, _loonMsg]  ALSO post it to Looner as @BenBones (verified) + rebroadcast the feed.
    No CfgRE/remoteExec: other SERVER fns call this directly; clients only READ the public var + get the loon
    feed (life_fnc_loonerReceive is already whitelisted server->client).
*/
if (!isServer) exitWith {};
params [["_cat", "NEWS", [""]], ["_headline", "", [""]], ["_loon", "", [""]]];
if (_headline isEqualTo "") exitWith {};

// sanitize the headline for structured-text rendering on the client (parseText)
private _h = (_headline splitString "<>") joinString "";
if ((count _h) > 140) then { _h = _h select [0, 140]; };

if (isNil "PLB_newsHeadlines") then { PLB_newsHeadlines = []; };
PLB_newsHeadlines = [[_cat, _h]] + PLB_newsHeadlines;
if (count PLB_newsHeadlines > 15) then { PLB_newsHeadlines resize 15; };
publicVariable "PLB_newsHeadlines";   // broadcasts + JIP-syncs to every client, read by fn_browserSites

if (_loon isNotEqualTo "") then {private _msg = (_loon splitString "\'""`<>") joinString "";
    _msg = (_msg splitString toString [10, 13]) joinString " ";
    if ((count _msg) > 180) then { _msg = _msg select [0, 180]; };
    if (_msg isNotEqualTo "") then {private _likes = 300 + floor (random 1500);
        [format ["INSERT INTO looner_posts (uid, name, message, likes, verified, reply_to) VALUES ('BENBONES', 'Ben Bones', '%1', %2, 1, 0)", _msg, _likes]] call DB_fnc_asyncQuery;
        private _rows = ["SELECT id, QUOTE(name), QUOTE(message), QUOTE(DATE_FORMAT(ts,'%b %e %H:%i')), likes, verified, reply_to FROM looner_posts ORDER BY id DESC LIMIT 50", 2, true] call DB_fnc_asyncQuery;
        if (!isNil "_rows" && {_rows isEqualType []}) then { reverse _rows; [[_rows], "life_fnc_loonerReceive", -2] spawn life_fnc_MP; };};
};
