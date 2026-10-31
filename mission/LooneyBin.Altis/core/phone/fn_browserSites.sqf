/*
    life_fnc_browserSites  (LoonyNet site registry)
    [url] -> [browserTabTitle, navRailTitle, [[navLabel, navUrl], ...], structuredTextBody]

    ADD A SITE: add a case for its url (lowercase, no scheme/www) and return the 4-element array.
    Sub-pages are just more urls ("mysite.com/page"). The nav rail lists whatever links you return;
    every page decides its own rail. 3dprintfreedom.com is a stub 404 (owner is hand-building it).
*/
params [["_url", "loonynet.start", [""]]];

// DataBattle shared bits ------------------------------------------------------------------------
private _dbRed = "#a31b1e";
private _dbInk = "#262019";
private _dbRule = "<t align='center'><img size='0.3' image='images\news_rule.paa' /></t>";
// masthead: heavy display cap over a red rule -- the bg (browser_bg_port_news.paa) bakes the newsprint
// grain + the black/red double rule at the very top of the page.
private _dbHead = "<t size='3.3' font='PuristaBold' color='#211c15' align='center'>DATA BATTLE</t><br/><t align='center'><img size='0.32' image='images\news_rule_red.paa' /></t><br/><t size='1.15' font='RobotoCondensed' color='#6f6656' align='center'>There's a BATTLE on for your DATA!  --  with BEN BONES</t><br/><br/>";
private _dbFoot = "<br/><br/>" + _dbRule + format ["<br/><t size='1.35' color='%1' font='RobotoCondensedBold'>SPONSORED:</t> <t size='1.35' color='%2'>SUPER MALE VITALITY -- the bunker formula Ben Bones chugs ON AIR. The APD does NOT want you on it. 40% off with code WAKEUP.</t><br/><t size='1.05' color='#9a917f'>(c) Data Battle Media. Not affiliated with the Department of Restarts.</t>", _dbRed, _dbInk];
private _dbLinks = [["-- HEADLINES --", ""], ["The Great Reset", "databattle.com/reset"], ["CLANKR Is Watching", "databattle.com/clankr"],
    ["Stimmy Checks", "databattle.com/stimmy"], ["Red Gull Exposed", "databattle.com/redgull"],
    ["Tiny Island Reset", "databattle.com/malden"], ["Chemtrails Over Malden", "databattle.com/chemtrails"],
    ["Lizard Police", "databattle.com/lizards"], ["The Bug Invasion", "databattle.com/bugs"],
    ["Hospital Harvest", "databattle.com/hospital"], ["Follow The Tax", "databattle.com/governor"], ["", ""],
    ["<- LoonyNet Home", "loonynet.start"]];
private _art = {params ["_headline", "_body"];
    _dbHead
    + format ["<t size='2.2' font='RobotoCondensedBold' color='#211c15'>%1</t><br/><t size='1.05' color='%2' font='RobotoCondensedBold'>DATA BATTLE EXCLUSIVE</t><t size='1.05' color='#6f6656'>  --  by BEN BONES</t><br/><br/>", _headline, _dbRed]
    + _body + _dbFoot};

// -----------------------------------------------------------------------------------------------
switch (toLower _url) do {

    // ---------- start page ----------
    case "loonynet.start": {
        // 2026-07-20 LANDSCAPE redesign: the LEFT RAIL now owns the site directory, so the start page is an
        // IDENTITY page -- LoonGle mark, one inline quick-link row (wide), then a mono NETWORK STATUS board
        // that actually uses the horizontal panel. Clickables stay <a href='go:url'> via the HTMLLink EH.
        private _statRow = {params ["_k", "_v", ["_col", "#636c7c"]];
            format ["<t font='EtelkaMonospacePro' size='1.05' color='#5c6577'>%1</t><t font='EtelkaMonospacePro' size='1.05' color='%3'>%2</t><br/>", _k, _v, _col]
        }; ["LoonyNet", "-- BOOKMARKS --", [["Looner", "looner.com"], ["DataBattle News", "databattle.com"],
                ["LoonyBets Sportsbook", "loonybets.com"], ["Loonstreets", "loonstreets.com"], ["3D Print Freedom", "3dprintfreedom.com"]],
            "<br/><t size='3.8' font='RobotoCondensedBold' align='center' color='#5082eb'>Loon<t color='#e06a5f'>G</t><t color='#b58900'>l</t><t color='#2c8f57'>e</t></t>"
            + "<br/><t size='1.1' align='center' color='#636c7c'>The Island's #1 search engine. Results coming in Beta 0.9.</t>"
            + "<br/><br/><t size='1.25' align='center'>"
            + "<a href='go:looner.com'>LOONER</a><t color='#3c4750'>   ·   </t>"
            + "<a href='go:databattle.com'>DATA BATTLE</a><t color='#3c4750'>   ·   </t>"
            + "<a href='go:loonybets.com'>LOONYBETS</a><t color='#3c4750'>   ·   </t>"
            + "<a href='go:loonstreets.com'>LOONSTREETS</a><t color='#3c4750'>   ·   </t>"
            + "<a href='go:3dprintfreedom.com'>3D PRINT</a></t><br/>"
            + "<br/><t size='1.15' font='EtelkaMonospacePro' color='#5f7000'>NETWORK STATUS</t><br/>"
            + (["  CELL TOWERS ......... ", "2 / 3 REACHABLE", "#0d8f66"] call _statRow)
            + (["  PACKET LOSS ......... ", "ACCEPTABLE (LIES)", "#a86f00"] call _statRow)
            + (["  DNS .................. ", "A GUY NAMED DENNIS", "#636c7c"] call _statRow)
            + (["  GREAT RESET ......... ", "SEVERAL TIMES DAILY", "#c03418"] call _statRow)
            + (["  YOUR DATA ........... ", "SOLD (THANK YOU)", "#636c7c"] call _statRow)
            + "<br/><t size='0.95' align='center' color='#5c6577'>Bookmarks live on the left rail. Type an address up top, or tap a link.</t>"
        ]};

    // ---------- databattle.com ----------
    case "databattle.com": {private _news = missionNamespace getVariable ["PLB_newsHeadlines", []];
        private _breaking = "";
        if (_news isNotEqualTo []) then {_breaking = format ["<t size='1.7' font='PuristaBold' color='%1'>BREAKING</t><br/>", _dbRed];
            { _x params [["_c","NEWS"],["_hd",""]]; _breaking = _breaking + format ["<t size='1.4' color='%2'>&gt;  %1</t><br/>", _hd, _dbInk]; } forEach _news;
            _breaking = _breaking + _dbRule + "<br/><br/>";};
        ["DataBattle", "-- HEADLINES --", _dbLinks select [1, 12], _dbHead
            + _breaking
            + format ["<t size='1.725' font='RobotoCondensedBold' color='#262019'>WELCOME, PATRIOT.</t><br/><t size='1.425' color='#262019'>You found the LAST free press on this island. My name is Ben Bones. They have banned me from the sidechat NINE TIMES. Every story on the left rail is TRUE, DOCUMENTED, and ABSOLUTELY REAL. I have the documents. I have SEEN the documents. Sometimes the documents are shown to me in dreams, which is LEGALLY the same thing.</t><br/><br/><t size='1.5' font='RobotoCondensedBold' color='%1'>TODAY'S ALERT LEVEL: CRIMSON</t><br/><t size='1.425' color='#262019'>You heard my emergency broadcast on the radio -- LIVE FROM THE UNDERGROUND BUNKER, and yes, they tried to JAM THE SIGNAL. The so-called 'government' has announced a 'relocation program' to MALDEN. Folks, that is not a move. That is a FORCED MIGRATION INTO A PRISON ISLAND. Read OPERATION TINY ISLAND RESET on the left rail before they memory-hole it at the next restart. STAY VIGILANT.</t>", _dbRed]
            + _dbFoot]};
    case "databattle.com/reset": {["DataBattle", "-- HEADLINES --", _dbLinks select [1, 12],
            ["THE GREAT RESET HAPPENS EVERY FEW HOURS AND YOU'VE STOPPED NOTICING",
             "<t size='1.425' color='#262019'>FOLKS. Think about this. Several times a day, the ENTIRE ISLAND blinks out of existence. Your car? Gone from the street, back in some 'garage'. That fire you set? Extinguished. The economy? 'Rebalanced'. And everyone just stands in line at spawn select like SHEEP.<br/><br/>They call it 'the restart'. I call it THE GREAT RESET. The Department of Restarts posts a COUNTDOWN, in the chat, and people say 'thanks'. THANKS?! They are deleting the WORLD, patriot, and the only thing that survives is what the machine CHOOSES to remember about you.<br/><br/>And ask yourself this: WHY does your gear come back but my CHARGES don't get dropped? Selective memory. That's a FILING SYSTEM, folks. Somebody is CURATING reality. I've timed it. I have a spreadsheet. My spreadsheet was DELETED IN A RESTART.</t>"
            ] call _art]};
    case "databattle.com/clankr": {["DataBattle", "-- HEADLINES --", _dbLinks select [1, 12],
            ["CLANKR: THE MACHINE THAT BANS YOU IN YOUR SLEEP",
             "<t size='1.425' color='#262019'>There is a ROBOT, and I have CONFIRMED this with three separate guys named Dave, that reads EVERY transaction on this island. Every gun you buy. Every brick you move. It never blinks. It never sleeps. The insiders call it... CLANKR.<br/><br/>You duplicate ONE pallet of cocaine through a shed wall and BOOM -- banned before your boots hit the pavement. No trial. No jury. A MACHINE decided you were guilty, and a MACHINE filed the paperwork.<br/><br/>They say it 'only targets cheaters'. Oh really? Then why did it ping a man for REFILLING HIS OWN MAGAZINES? (They 'fixed' that. Sure. They 'fix' everything.) WAKE UP: the anti-cheat is just the beginning. First they came for the dupers, and I said nothing, because I was not duping. THEN THEY CAME FOR MY SHED.</t>"
            ] call _art]};
    case "databattle.com/stimmy": {["DataBattle", "-- HEADLINES --", _dbLinks select [1, 12],
            ["STIMMY CHECKS: THE MONEY PRINTER RUNS AT 3AM AND I CAN PROVE IT",
             "<t size='1.425' color='#262019'>Ever notice how when the island is EMPTY at 3 in the morning, suddenly the cartels pay out TEN TIMES the money? That's not a rumor. That is a DOCUMENTED PROGRAM. They literally call them 'STIMMY CHECKS'. They're not even hiding it, folks!<br/><br/>Somewhere there is a SWITCH. A physical switch, maybe a big red button, and when the population dips, a hand -- WHOSE hand, patriot? -- reaches out and flips the economy into OVERDRIVE. Free money falls from the sky onto the six insomniacs who 'happened' to be capping cartels at 3AM.<br/><br/>That's not an economy. That's a FAUCET. And when the normal people log on at 6PM? Faucet's OFF. You get paid in EXPOSURE. Do the math. I did the math. The math BANNED ME FROM THE GROUP CHAT.</t>"
            ] call _art]};
    case "databattle.com/redgull": {["DataBattle", "-- HEADLINES --", _dbLinks select [1, 12],
            ["WHAT'S REALLY IN RED GULL (I DRANK FORTY OF THEM)",
             "<t size='1.425' color='#262019'>A man drinks one Red Gull and sprints from Kavala to Athira WITHOUT BREATHING HARD. You think that's 'taurine'? You think that's B VITAMINS?! Folks, I ran the numbers: that is a 14 KILOMETER SPRINT in BODY ARMOR.<br/><br/>I bought forty cans. I drank them in one sitting, for journalism. My heart played the drum solo from an admin event and I FILED THIS REPORT FROM THE HOSPITAL, that's called DEDICATION. And here's the kicker -- the hospital sells MORE OF IT. The cycle is COMPLETE. They juice you, they treat you, they juice you again.<br/><br/>And don't get me started on the coke-sprint stacking question, because the so-called 'patch notes' say the buffs 'don't stack'. DON'T STACK?! Since when does chemistry respect PATCH NOTES?</t>"
            ] call _art]};
    case "databattle.com/malden": {["DataBattle", "-- HEADLINES --", _dbLinks select [1, 12],
            ["OPERATION TINY ISLAND RESET: THE MALDEN 'RELOCATION' IS A CONTAINMENT ZONE",
             "<t size='1.425' color='#262019'>LISTEN TO ME, PEOPLE OF ALTIS. The 'government' says everyone is moving to Malden. They call it a 'relocation program'. HA! That is the biggest load of globalist horse manure I have EVER heard in my LIFE. This is not a move, folks -- this is FORCED MIGRATION into a PRISON ISLAND.<br/><br/>Why Malden? Because it's ISOLATED. Because the waters around it are PERFECT for their black-site ships. Smaller land means fewer places to hide from their experiments! They are herding every last citizen onto that tiny rock so they can control us EASIER. First they take Altis -- the land of the free -- then they squeeze us onto Malden where they can monitor EVERY MOVE. Next they'll be TAXING THE AIR YOU BREATHE and putting fluoride in the water to sterilize the next generation of patriots!<br/><br/>And the real elites? THEY'RE NOT COMING WITH US. Oh no. They'll be safe on their private compounds, sipping adrenochrome while we fight over scraps on that cursed rock. They already POISONED THE FIELDS OF ALTIS -- now they want us weak and contained. Stock up on supplies. Build your hidden camps. SPREAD THE WORD. This has been the raw, UNCUT truth they don't want you hearing.</t>"
            ] call _art]};
    case "databattle.com/chemtrails": {["DataBattle", "-- HEADLINES --", _dbLinks select [1, 12],
            ["CHEMTRAILS OVER MALDEN: 'WEATHER MODIFICATION' IS A FLUID-HARVESTING OPERATION",
             "<t size='1.425' color='#262019'>I've got whistleblowers INSIDE the Altis administration, and they told me the REAL plan: the moment you're all penned up on Malden, they are going to spray the ENTIRE island under the guise of 'weather modification'. Folks -- LOOK UP. Those clouds are not natural. I've been watching the sky for nine hours from the bunker hatch and the clouds are moving in FORMATION.<br/><br/>The spray turns the population DOCILE. Compliant. 'Relaxed', they call it. And while you're standing there all relaxed, they are HARVESTING YOUR VITAL FLUIDS for their elite overlords. What do you think keeps the compound crowd looking so young?! It's not the peaches, patriot!<br/><br/>You want proof? The 'forecast' calls it 'startWeather 0.3'. THREE-TENTHS OF WHAT? They won't say. The weathermen know. The weathermen have ALWAYS known. My cousin asked one about it at the fuel station and the man got in his car and DROVE AWAY. Case. CLOSED.</t>"
            ] call _art]};
    case "databattle.com/lizards": {["DataBattle", "-- HEADLINES --", _dbLinks select [1, 12],
            ["NOT EVEN HUMAN ANYMORE: THE CHIEF OF POLICE AND THE SKIN-SUIT COVER-UP",
             "<t size='1.425' color='#262019'>I've SEEN the documents, folks. The Chief of Police. Half the politicians. THEY'RE NOT EVEN HUMAN ANYMORE. Lizard people wearing HUMAN SKIN SUITS, coordinating with foreign powers to break the spirit of every Altian citizen. You ever seen the Chief blink SIDEWAYS? I have. Frame 4,412 of my dashcam footage. The footage was 'corrupted in a restart'. CONVENIENT.<br/><br/>Think about it: who ELSE could stand in the APD HQ under those fluorescent lights for TWELVE STRAIGHT HOURS without moisturizing? A MAMMAL? Don't make me laugh. And the new 'Chief' rank they just added -- rank SEVEN, folks, SEVEN -- you know who else has seven? I don't even need to finish that sentence.<br/><br/>PROTOCOL: if you see a government official on Malden, you look him DEAD IN THE EYES and you scream 'I KNOW WHAT YOU ARE!' Do not break eye contact. Do not blink. If HE blinks -- sideways -- you RUN, patriot. You run and you tell DataBattle dot com.</t>"
            ] call _art]};
    case "databattle.com/bugs": {["DataBattle", "-- HEADLINES --", _dbLinks select [1, 12],
            ["THE BUG INVASION IS COMING AND THEY BRED IT THEMSELVES",
             "<t size='1.425' color='#262019'>Why do they want us weak and contained on Malden? So we CAN'T FIGHT BACK when the bug invasion hits. Yes -- THE BUGS. I have sources CONFIRMING the government has been breeding them in UNDERGROUND LABS for population control. Big ones, folks. Ones you can hear WALKING.<br/><br/>You think it's a coincidence the 'relocation' happens right before swarm season? You think it's a coincidence the new island has all those nice empty BUNKERS and TUNNELS, pre-dug, ready to go? WHO DUG THOSE, PATRIOT? Not a shovel company. I called every shovel company on Altis. NONE of them took the contract.<br/><br/>So here's what you do: stock up on supplies. Build your hidden camps NOW -- inland, high ground, away from the black-site waters. Learn to fish so the food supply can't be used against you. And when the first one crawls out of the ground on that cursed rock, remember: BEN BONES TOLD YOU FIRST. I'll be in the bunker. STAY VIGILANT, CITIZENS!</t>"
            ] call _art]};
    case "databattle.com/hospital": {["DataBattle", "-- HEADLINES --", _dbLinks select [1, 12],
            ["WHAT HAPPENS TO POLICE BODIES BEHIND THE MENTAL HOSPITAL",
             "<t size='1.425' color='#262019'>WARNING: this one's not for the faint of heart. You know what sells at your friendly neighborhood drug dealer, right next to the marijuana? HUMAN SCALPS. That's on the PUBLIC price list, folks. I'm not being metaphorical. CHECK THE MARKET APP.<br/><br/>And there is a... PROCEDURE... being performed on fallen officers of the law that I am LEGALLY not allowed to describe, but the RESULTING ITEM is fully TRADEABLE and some of them have NAMES ON THEM. Officer down? More like officer DISCOUNTED, folks, because his personal effects hit the black market before the medics even zip the bag!<br/><br/>They built a MENTAL HOSPITAL on this island and let me tell you -- after three weeks investigating this story, I have voluntarily checked MYSELF in. The food is fine. The walls are CONCERNINGLY new. More as I uncover it.</t>"
            ] call _art]};
    case "databattle.com/governor": {["DataBattle", "-- HEADLINES --", _dbLinks select [1, 12],
            ["FOLLOW THE TAX: I TRACED THE GOVERNOR'S 15% AND YOU WON'T BELIEVE WHERE IT LANDS",
             "<t size='1.425' color='#262019'>Every time you buy a lockpick, the Governor skims up to FIFTEEN PERCENT off the top. 'For the island', they say. 'For roads', they say. FOLKS. I have never ONCE seen a road crew. The potholes on the MSR are OLDER THAN THE ISLAND.<br/><br/>So I followed the money. Weeks of work. Bank records. Napkin math. Two Daves. And the tax river flows into... A GANG BANK ACCOUNT. I will not say WHICH gang on legal advice, but the ACCOUNT NUMBER ENDS IN 50000 and that is a FACT you can take to the (heavily taxed) bank.<br/><br/>Your Governor campaigns on 'law and order' and BANKS like a kingpin. Term limits? Seven days. SEVEN DAYS, folks -- just long enough to fill the bag, never long enough to face the RECALL I keep filing. VOTE BONES. (I am not eligible. THEY made sure of that.)</t>"
            ] call _art]};

    // ---------- looner.com : the microblog. fn_browser toggles the compose bar on any looner.* url and
    //            requests the feed from TON_fnc_loonerSRV; PLB_loonerFeed = [[name, message, "when"], ...]
    //            already oldest->newest. Body built here from that cache. ----------
    case "looner.com": {private _feed = missionNamespace getVariable ["PLB_loonerFeed", []];
        private _pfp = "icons\looner_pfp.paa";
        // owner 2026-07-15 redesign: gold-on-graphite. The page ground is baked into
        // images\browser_bg_port_looner.paa (dark + ghost dead-eyes watermark + gold hairline); this text
        // floats over it. One accent (the logo gold #b58900) carries wordmark, checkmark, hearts, and the
        // LOON IT button -- on looner even the checkmark is for sale. Verified + heart are PAA icons:
        // RobotoCondensed silently drops &#10004;/&#9829; (the old feed rendered a bare red "e").
        // Timestamps arrive as minutes-ago (number) -> "now / 12m / 3h / 2d".
        private _div = "<br/><img size='0.28' image='images\looner_div.paa' /><br/>";
        private _body = "<img size='2.6' image='icons\looner_logo.paa' /> <t size='2.4' font='RobotoCondensedBold' color='#b58900'>looner</t><t size='1.05' font='RobotoCondensed' color='#59627a'>   what are you doing?</t>"
            + "<br/><t size='0.75' font='RobotoCondensed' color='#454e63'>tap the heart under a loon to boost it</t><br/>";
        if (_feed isEqualTo []) then {
            _body = _body + "<br/><br/><t size='1.4' font='RobotoCondensed' color='#59627a' align='center'>Dead air.</t><br/><t size='1.4' font='RobotoCondensedBold' color='#b58900' align='center'>Be the first -- type below and LOON IT.</t>";
        } else {{_x params [["_id",0], ["_nm", "Loon"], ["_msg", ""], ["_mins",0], ["_likes",0], ["_ver",0], ["_re",0]];
                if (_mins isEqualType "") then { _mins = parseNumber _mins; };   // extDB3 may hand the number back as a string
                private _age = call {switch (true) do {case (_mins < 1):    { "now" };
                        case (_mins < 60):   { format ["%1m", floor _mins] };
                        case (_mins < 1440): { format ["%1h", floor (_mins / 60)] };
                        default              { format ["%1d", floor (_mins / 1440)] };}};
                private _badge = if (_ver isEqualTo 1) then { " <img size='1.15' image='icons\looner_ver.paa' />" } else { "" };
                _body = _body + _div
                    + format ["<img size='2.2' image='%1' />  <t size='1.4' font='RobotoCondensedBold' color='#22262e'>%2</t>%3<t size='1.0' font='RobotoCondensed' color='#59627a'>  %4 - #%5</t>", _pfp, _nm, _badge, _age, _id]
                    + (if (_re > 0) then { format ["<br/><t size='0.95' font='RobotoCondensed' color='#59627a'>re: #%1</t>", _re] } else { "" })
                    + format ["<br/><t size='1.4' font='RobotoCondensed' color='#454e60'>%1</t>", _msg]
                    + format ["<br/><t size='1.05' font='RobotoCondensedBold'><a href='like:%2'><img size='0.95' image='icons\looner_heart.paa' /> %1  boost</a></t>", _likes, _id];
            } forEach _feed;};
        ["Looner", "", [["Looner", "looner.com"], ["<- LoonyNet Home", "loonynet.start"]], _body]};

    // ---------- loonybets.com : parimutuel sportsbook on server events (PLB_sportsbook public var) ----------
    case "loonybets.com": {
        // owner 2026-07-15 redesign: the tote board. Near-black phosphor ground is baked into
        // browser_bg_port_bets.paa (scanlines + amber hairline); odds set in EtelkaMonospacePro like a
        // track board -- YES in phosphor green, NO in amber (labeled, never color-alone).
        private _mkts = missionNamespace getVariable ["PLB_sportsbook", []];
        private _div = "<br/><img size='0.28' image='images\bets_div.paa' /><br/>";
        private _body = "<t size='2.9' font='PuristaBold' color='#243024'>LOONYBETS</t><t size='1.0' font='EtelkaMonospacePro' color='#a86f00'>  THE BOOK</t>"
            + "<br/><t size='0.95' font='RobotoCondensed' color='#5c6b5e'>the book Bones warned you about</t><br/>";
        if (_mkts isEqualTo []) then {
            _body = _body + "<br/><br/><t size='1.5' font='EtelkaMonospacePro' color='#a86f00' align='center'>WINDOW SHUT</t>"
                + "<br/><t size='1.1' font='RobotoCondensed' color='#5c6b5e' align='center'>The book opens the moment a heist alarm sounds:</t><br/><br/>"
                + "<t size='1.05' font='EtelkaMonospacePro' color='#1f8f45' align='center'>BANK   JEWELRY   FED RESERVE</t>"
                + "<br/><t size='1.05' font='EtelkaMonospacePro' color='#1f8f45' align='center'>EVIDENCE   SHIPPING   LOONY BIN</t>"
                + "<br/><br/><t size='0.95' font='RobotoCondensed' color='#5c6b5e' align='center'>Start one. Or wait for someone braver.</t>";
        } else {{_x params [["_k",""],["_q",""],["_y",0],["_n",0],["_dl",0],["_st","open"],["_rs",""]];
                private _tot = _y + _n;
                private _oy = if (_y > 0) then { format ["%1x", ((_tot * 0.9 / _y) max 1) toFixed 2] } else { "--" };
                private _on = if (_n > 0) then { format ["%1x", ((_tot * 0.9 / _n) max 1) toFixed 2] } else { "--" };
                _body = _body + _div
                    + format ["<t size='1.45' font='RobotoCondensedBold' color='#243024'>%1</t><br/>", _q]
                    + format ["<t size='1.2' font='EtelkaMonospacePro' color='#1f8f45'><a href='bet:%3:yes'>YES  $%1  pays %2</a></t><br/>", [_y] call life_fnc_numberText, _oy, _k]
                    + format ["<t size='1.2' font='EtelkaMonospacePro' color='#a86f00'><a href='bet:%3:no'>NO   $%1  pays %2</a></t><br/>", [_n] call life_fnc_numberText, _on, _k]
                    + "<t size='0.9' font='EtelkaMonospacePro' color='#55645a'>tap YES or NO to bet ($50k max)</t><br/>";} forEach _mkts;
            _body = _body + _div + "<t size='0.95' font='RobotoCondensed' color='#5c6b5e'>Parimutuel: winners split the losing pool (10% house rake). Each market settles on its event, or NO at window close.</t>";
        };
        ["LoonyBets", "", [["<- LoonyNet Home", "loonynet.start"]], _body]};

    // ---------- loonazon.com : the drone store. Owner 2026-07-15 redesign: the inside of a shipping box --
    //            kraft cardboard ground w/ packing tape + a giant faint smile-arrow (browser_bg_port_loonazon.paa),
    //            warm ink text, mono prices, orange accents. Tap [ ORDER ] -> qty window -> Greyhawk drop.
    //            Catalog + markup in life_fnc_loonazonCfg. <a> stays the IMMEDIATE child of its <t> (link rule). ----------
    // ---------- loonazon.com : RETIRED storefront -- Loonazon is a standalone phone APP now (2026-07-16).
    //            The site stays as a redirect card so old bookmarks don't 404. ----------
    case "loonazon.com": {private _rule = "<t align='center'><img size='0.28' image='images\loonazon_rule.paa' /></t>";
        private _body = "<t size='3.0' font='PuristaBold' color='#2e2318'>loonazon</t><t size='1.05' font='RobotoCondensed' color='#c85f10'>  has moved</t><br/><t size='0.4'> </t><br/>"
            + _rule + "<br/>"
            + "<t size='1.4' font='RobotoCondensedBold' color='#2e2318'>Loonazon is an app now.</t><br/>"
            + "<t size='1.05' font='RobotoCondensed' color='#6d5a42'>Close the browser and open LOONAZON from your phone's home screen. Full catalog, cart, weight caps, the works. Same vans. Same driver. He still will not speak to you.</t><br/><t size='0.4'> </t><br/>"
            + _rule;
        ["Loonazon", "", [["Loonazon", "loonazon.com"], ["<- LoonyNet Home", "loonynet.start"]], _body]};

    // ---------- loonstreets.com : the streets keep score. Owner 2026-07-15 design pass: asphalt ground v2
    //            (worn lane dashes + spray-crown ghost), medal-toned TOP CREWS (gold/silver/bronze for 1-3),
    //            gold crown holder. Data: PLB_loonstreets (TON_fnc_loonstreetsSRV, 5-min refresh). ----------
    case "loonstreets.com": {
        (missionNamespace getVariable ["PLB_loonstreets", [["", 0], [], []]]) params [["_fort", ["", 0]], ["_turfs", []], ["_gangs", []]];
        private _body = "<t size='2.9' font='PuristaBold' color='#22262e'>LOONSTREETS</t><t size='1.05' font='RobotoCondensed' color='#c92e74'>  the streets keep score</t><br/><t size='0.4'> </t><br/>";
        _body = _body + "<t size='1.35' font='PuristaBold' color='#c92e74'>FORTRESS CROWN</t><br/>";
        _body = _body + (if ((_fort select 0) isEqualTo "") then {
            "<t size='1.3' font='RobotoCondensed' color='#55555c'>Unclaimed. The bunker sits empty and the crown gathers dust.</t><br/>"
        } else {
            format ["<t size='1.7' font='RobotoCondensedBold' color='#b58900'>%1</t><t size='1.05' font='RobotoCondensed' color='#4a505c'>  holds the fortress</t><br/>", _fort select 0]
        });
        _body = _body + "<br/><t size='1.35' font='PuristaBold' color='#c92e74'>TURF</t><br/>";
        if (_turfs isEqualTo []) then {
            _body = _body + "<t size='1.2' font='RobotoCondensed' color='#5c5c66'>No turf data. Suspicious.</t><br/>";} else {{
                _x params ["_tid", "_gn"];
                _body = _body + (if (_gn isEqualTo "") then {
                    format ["<t size='1.2' font='EtelkaMonospacePro' color='#55555e'>TURF %1</t><t size='1.2' font='RobotoCondensed' color='#55555e'>   unclaimed</t><br/>", _tid]
                } else {
                    format ["<t size='1.2' font='EtelkaMonospacePro' color='#4a505c'>TURF %1</t><t size='1.35' font='RobotoCondensedBold' color='#22262e'>   %2</t><br/>", _tid, _gn]
                });} forEach _turfs;};
        _body = _body + "<br/><t size='1.35' font='PuristaBold' color='#c92e74'>TOP CREWS</t><t size='0.9' font='RobotoCondensed' color='#5c5c66'>  by experience</t><br/>";
        if (_gangs isEqualTo []) then {
            _body = _body + "<t size='1.2' font='RobotoCondensed' color='#5c5c66'>Nobody has done anything. Ever.</t>";} else {{
                _x params ["_gn", "_bank", "_xp"];
                private _rk = _forEachIndex + 1;
                private _nmCol = switch (_rk) do { case 1: {"#b58900"}; case 2: {"#c9ced8"}; case 3: {"#d09a62"}; default {"#22262e"} };
                private _nmSize = if (_rk isEqualTo 1) then {"1.55"} else {"1.35"};
                _body = _body
                    + format ["<t size='1.25' font='EtelkaMonospacePro' color='#c92e74'>%1</t><t size='1.25' font='EtelkaMonospacePro' color='#6a6a72'>. </t><t size='%2' font='RobotoCondensedBold' color='%3'>%4</t><br/>", _rk, _nmSize, _nmCol, _gn]
                    + format ["<t size='1.0' font='EtelkaMonospacePro' color='#4a505c'>   %1 xp</t><t size='1.0' font='EtelkaMonospacePro' color='#2c8f57'>   $%2 banked</t><br/><t size='0.25'> </t><br/>", [_xp] call life_fnc_numberText, [_bank] call life_fnc_numberText];
            } forEach _gangs;};
        _body = _body + "<br/><t size='0.85' font='RobotoCondensed' color='#55555e'>Updated every 5 minutes. Numbers don't lie. People do.</t>";
        ["Loonstreets", "", [["Loonstreets", "loonstreets.com"], ["<- LoonyNet Home", "loonynet.start"]], _body]};

    // ---------- 3dprintfreedom.com : owner is hand-building this; stub 404 ----------
    case "3dprintfreedom.com": {["404", "", [["<- LoonyNet Home", "loonynet.start"]],
            "<br/><br/><br/><br/><t size='2.6' font='RobotoCondensedBold' align='center' color='#333333'>404</t><br/><t size='1.1' align='center' color='#555555'>Not Found</t><br/><br/><t size='1.45' align='center' color='#888888'>The requested resource /index.html was not found on this server.</t><br/><br/><t size='0.75' align='center' color='#aaaaaa'>loonynet/1.0 (island) at 3dprintfreedom.com port 80</t>"
        ]};

    // ---------- everything else: DNS fail ----------
    default {["No Signal", "", [["<- LoonyNet Home", "loonynet.start"]],
            format ["<br/><br/><br/><br/><t size='1.6' font='RobotoCondensedBold' align='center' color='#444444'>This site can't be reached</t><br/><br/><t size='0.95' align='center' color='#666666'>%1 took too long to respond, or does not exist,<br/>or was deleted in a restart.</t><br/><br/><t size='0.85' align='center' color='#999999'>DNS_PROBE_FINISHED_NO_LOONYNET</t>", _url]
        ]};};
