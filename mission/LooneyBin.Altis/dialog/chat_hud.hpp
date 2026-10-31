// LooneyBin (owner, 2026-06-11): persistent chat history HUD. Vanilla chat fades after a few seconds;
// this keeps the last ~12 messages on screen (bottom-left) so you can read recent side/global/direct
// chat. Fed by fn_handleChatMessage (the HandleChatMessage EH), rendered into the structured text ctrl.
class life_chat_hud {idd = 246000;
    duration = 1e+011;
    fadein = 0;
    fadeout = 0;
    name = "life_chat_hud";
    onLoad = "uiNamespace setVariable ['life_chat_hud', _this select 0]";
    onUnload = "uiNamespace setVariable ['life_chat_hud', nil]";
    class controls {class ChatHistory: Life_RscStructuredText {idc = 246001;
            x = 0.012 * safezoneW + safezoneX;
            y = 0.620 * safezoneH + safezoneY;
            w = 0.340 * safezoneW;
            h = 0.250 * safezoneH;
            text = "";
            class Attributes {font = "PuristaMedium";
                color = "#ffffff";
                align = "left";
                shadow = 1;};
            size = "0.034 * safezoneH";
            shadow = 2;};};};

// LooneyBin (owner, 2026-06-11): prison-break countdown HUD. An active break runs for 10 minutes before
// prisoners can escape, with no on-screen timer. This top-center bar (fed by the SRV_prisonData watcher in
// initPlayerLocal) shows the remaining time + a block-bar so everyone can see the break's progress.
class life_prison_hud {idd = 247000;
    duration = 1e+011;
    fadein = 0;
    fadeout = 0;
    name = "life_prison_hud";
    onLoad = "uiNamespace setVariable ['life_prison_hud', _this select 0]";
    onUnload = "uiNamespace setVariable ['life_prison_hud', nil]";
    class controls {class PrisonTimer: Life_RscStructuredText {idc = 247001;
            x = 0.300 * safezoneW + safezoneX;
            y = 0.140 * safezoneH + safezoneY;
            w = 0.400 * safezoneW;
            h = 0.075 * safezoneH;
            text = "";
            class Attributes {font = "PuristaMedium";
                color = "#ffffff";
                align = "center";
                shadow = 1;};
            size = "0.040 * safezoneH";
            shadow = 2;};
        class PrisonBar: Life_RscProgress {idc = 247002;
            x = 0.330 * safezoneW + safezoneX;
            y = 0.218 * safezoneH + safezoneY;
            w = 0.340 * safezoneW;
            h = 0.018 * safezoneH;
            colorBar[] = {0.92, 0.30, 0.20, 1};};};};

// LooneyBin 2026-06-11: bank vault drill progress bar (the 10-min server drill had no on-screen feedback).
// Driven by the initPlayerLocal watcher off life_bank_drilling + life_bank_robbed[1]; shown to anyone near
// the bank so robbers see their progress and cops see how long until the vault opens / time left to disarm.
class life_bank_hud {idd = 247003;
    duration = 1e+011;
    fadein = 0;
    fadeout = 0;
    name = "life_bank_hud";
    onLoad = "uiNamespace setVariable ['life_bank_hud', _this select 0]";
    onUnload = "uiNamespace setVariable ['life_bank_hud', nil]";
    class controls {class BankTimer: Life_RscStructuredText {idc = 247011;
            x = 0.300 * safezoneW + safezoneX;
            y = 0.140 * safezoneH + safezoneY;
            w = 0.400 * safezoneW;
            h = 0.075 * safezoneH;
            text = "";
            class Attributes {font = "PuristaMedium";
                color = "#ffffff";
                align = "center";
                shadow = 1;};
            size = "0.040 * safezoneH";
            shadow = 2;};
        class BankBar: Life_RscProgress {idc = 247012;
            x = 0.330 * safezoneW + safezoneX;
            y = 0.218 * safezoneH + safezoneY;
            w = 0.340 * safezoneW;
            h = 0.018 * safezoneH;
            colorBar[] = {0.945, 0.239, 0.659, 0.9};   // NIGHT CITY magenta -- matches Life_RscProgress (the bar every other event/drill/gather uses)
        };};};

// LooneyBin (owner, 2026-06-11): RESTORE the player nametag HUD. The RscTitles class was lost in deobf,
// so fn_playerTags `500 cutRsc ["plb_hud_nametags",...]` errored "not found" and no names showed over
// heads. 64 structured-text controls (idc 78000+i); fn_playerTags positions + sets each per frame via
// worldToScreen. Overflow past 64 simultaneous tags is skipped gracefully (ops on a null ctrl no-op).
class plb_hud_nametags {idd = 78100;
    duration = 1e+011;
    fadein = 0;
    fadeout = 0;
    name = "plb_hud_nametags";
    onLoad = "uiNamespace setVariable ['plb_hud_nametags', _this select 0]";
    class controls {class PLB_NameTagBase: Life_RscStructuredText {idc = -1;
            x = 0; y = 0; w = 0.30; h = 0.10;   // owner 2026-06-19 (#400): h 0.05 -> 0.10. The tag stacks up to 3 structured-text lines (name + gang/group + title); 0.05 only fit ~2 so a title clipped the name ("title cuts the name in half"). Box grows downward from the head, so single-line tags are unaffected.
            size = "0.0176 * safezoneH";   // owner 2026-06-13: ~30% smaller nametags (was 0.028; effective 0.028*0.9 scale -> now 0.0176 @ scale 1)
            shadow = 2;
            class Attributes { align = "center"; color = "#FFFFFF"; font = "PuristaMedium"; shadow = 1; };};
        class PLB_NameTag0: PLB_NameTagBase { idc = 78000; };
        class PLB_NameTag1: PLB_NameTagBase { idc = 78001; };
        class PLB_NameTag2: PLB_NameTagBase { idc = 78002; };
        class PLB_NameTag3: PLB_NameTagBase { idc = 78003; };
        class PLB_NameTag4: PLB_NameTagBase { idc = 78004; };
        class PLB_NameTag5: PLB_NameTagBase { idc = 78005; };
        class PLB_NameTag6: PLB_NameTagBase { idc = 78006; };
        class PLB_NameTag7: PLB_NameTagBase { idc = 78007; };
        class PLB_NameTag8: PLB_NameTagBase { idc = 78008; };
        class PLB_NameTag9: PLB_NameTagBase { idc = 78009; };
        class PLB_NameTag10: PLB_NameTagBase { idc = 78010; };
        class PLB_NameTag11: PLB_NameTagBase { idc = 78011; };
        class PLB_NameTag12: PLB_NameTagBase { idc = 78012; };
        class PLB_NameTag13: PLB_NameTagBase { idc = 78013; };
        class PLB_NameTag14: PLB_NameTagBase { idc = 78014; };
        class PLB_NameTag15: PLB_NameTagBase { idc = 78015; };
        class PLB_NameTag16: PLB_NameTagBase { idc = 78016; };
        class PLB_NameTag17: PLB_NameTagBase { idc = 78017; };
        class PLB_NameTag18: PLB_NameTagBase { idc = 78018; };
        class PLB_NameTag19: PLB_NameTagBase { idc = 78019; };
        class PLB_NameTag20: PLB_NameTagBase { idc = 78020; };
        class PLB_NameTag21: PLB_NameTagBase { idc = 78021; };
        class PLB_NameTag22: PLB_NameTagBase { idc = 78022; };
        class PLB_NameTag23: PLB_NameTagBase { idc = 78023; };
        class PLB_NameTag24: PLB_NameTagBase { idc = 78024; };
        class PLB_NameTag25: PLB_NameTagBase { idc = 78025; };
        class PLB_NameTag26: PLB_NameTagBase { idc = 78026; };
        class PLB_NameTag27: PLB_NameTagBase { idc = 78027; };
        class PLB_NameTag28: PLB_NameTagBase { idc = 78028; };
        class PLB_NameTag29: PLB_NameTagBase { idc = 78029; };
        class PLB_NameTag30: PLB_NameTagBase { idc = 78030; };
        class PLB_NameTag31: PLB_NameTagBase { idc = 78031; };
        class PLB_NameTag32: PLB_NameTagBase { idc = 78032; };
        class PLB_NameTag33: PLB_NameTagBase { idc = 78033; };
        class PLB_NameTag34: PLB_NameTagBase { idc = 78034; };
        class PLB_NameTag35: PLB_NameTagBase { idc = 78035; };
        class PLB_NameTag36: PLB_NameTagBase { idc = 78036; };
        class PLB_NameTag37: PLB_NameTagBase { idc = 78037; };
        class PLB_NameTag38: PLB_NameTagBase { idc = 78038; };
        class PLB_NameTag39: PLB_NameTagBase { idc = 78039; };
        class PLB_NameTag40: PLB_NameTagBase { idc = 78040; };
        class PLB_NameTag41: PLB_NameTagBase { idc = 78041; };
        class PLB_NameTag42: PLB_NameTagBase { idc = 78042; };
        class PLB_NameTag43: PLB_NameTagBase { idc = 78043; };
        class PLB_NameTag44: PLB_NameTagBase { idc = 78044; };
        class PLB_NameTag45: PLB_NameTagBase { idc = 78045; };
        class PLB_NameTag46: PLB_NameTagBase { idc = 78046; };
        class PLB_NameTag47: PLB_NameTagBase { idc = 78047; };
        class PLB_NameTag48: PLB_NameTagBase { idc = 78048; };
        class PLB_NameTag49: PLB_NameTagBase { idc = 78049; };
        class PLB_NameTag50: PLB_NameTagBase { idc = 78050; };
        class PLB_NameTag51: PLB_NameTagBase { idc = 78051; };
        class PLB_NameTag52: PLB_NameTagBase { idc = 78052; };
        class PLB_NameTag53: PLB_NameTagBase { idc = 78053; };
        class PLB_NameTag54: PLB_NameTagBase { idc = 78054; };
        class PLB_NameTag55: PLB_NameTagBase { idc = 78055; };
        class PLB_NameTag56: PLB_NameTagBase { idc = 78056; };
        class PLB_NameTag57: PLB_NameTagBase { idc = 78057; };
        class PLB_NameTag58: PLB_NameTagBase { idc = 78058; };
        class PLB_NameTag59: PLB_NameTagBase { idc = 78059; };
        class PLB_NameTag60: PLB_NameTagBase { idc = 78060; };
        class PLB_NameTag61: PLB_NameTagBase { idc = 78061; };
        class PLB_NameTag62: PLB_NameTagBase { idc = 78062; };
        class PLB_NameTag63: PLB_NameTagBase { idc = 78063; };};};
