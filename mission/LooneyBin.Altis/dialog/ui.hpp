class plb_playerHUD {idd = 23000;
    movingEnable = 0;
    fadein = 0;
    duration = 99999999999999999999999999999999999999999999;
    fadeout = 0;
    name = "plb_playerHUD";
    onLoad = "uiNamespace setVariable ['plb_playerHUD',_this select 0]";
    objects[] = {};
    class controlsBackground {};
    class controls {class hudtext: Life_RscStructuredText {idc = 23515;
            x = 0;
            y = 1;
            w = 1;
            h = 0.04;
            colorBackground[] = {0, 0, 0, 0};
            colorText[] = {1, 1, 1, 0.8};
            text = "";
            sizeEx = 0.03;
            class Attributes {font = "PuristaSemibold";
                color = "#FFFFFF";
                shadow = true;
                shadowColor = "#000000";
                size = "1";};};
        class hudhead: Life_RscStructuredText {idc = 23525;
            x = 0;
            y = 0;
            w = 1;
            h = 0.04;
            colorBackground[] = {0, 0, 0, 0};
            text = "";
            sizeEx = 0.03;
            class Attributes {font = "EtelkaMonospaceProBold";
                color = "#FFFFFF";
                shadow = true;
                shadowColor = "#000000";
                size = "1";};};

        // ── NIGHT CITY segmented survival bars, TRUE bottom-right (positions + fill + colour + value all set each
        //    tick by fn_hudUpdate via safeZone; hpp positions are placeholders). Each bar: icon + track + fill +
        //    gap-overlay PAA (void dividers -> 10 discrete segments) + mono value. ──
        #define PLB_BAR_ICON(IDC,IMG)   class plb_bi##IDC: Life_RscPicture { idc = IDC; x = 0.8; y = 0.85; w = 0.024; h = 0.030; text = IMG; }
        #define PLB_BAR_TRACK(IDC)      class plb_bt##IDC: Life_RscText { idc = IDC; x = 0.8; y = 0.85; w = 0.125; h = 0.017; colorBackground[] = { 0.157, 0.196, 0.247, 0.72 }; text = ""; }
        #define PLB_BAR_FILL(IDC,R,G,B) class plb_bf##IDC: Life_RscText { idc = IDC; x = 0.8; y = 0.85; w = 0.125; h = 0.017; colorBackground[] = { R, G, B, 1 }; text = ""; }
        #define PLB_BAR_OVER(IDC)       class plb_bo##IDC: Life_RscPicture { idc = IDC; x = 0.8; y = 0.85; w = 0.125; h = 0.017; text = "images\ui\hud_seg.paa"; }
        #define PLB_BAR_VALUE(IDC)      class plb_bv##IDC: Life_RscStructuredText { idc = IDC; x = 0.8; y = 0.85; w = 0.040; h = 0.044; sizeEx = 0.036; text = ""; class Attributes { font = "EtelkaMonospacePro"; color = "#ebeff4"; align = "left"; shadow = 1; shadowColor = "#05070d"; }; }

        PLB_BAR_ICON(23535, "icons\hud_health.paa"); PLB_BAR_TRACK(23530); PLB_BAR_FILL(23531, 0.325, 0.890, 0.612); PLB_BAR_OVER(23532); PLB_BAR_VALUE(23534);
        PLB_BAR_ICON(23545, "icons\hud_water.paa");  PLB_BAR_TRACK(23540); PLB_BAR_FILL(23541, 0.216, 0.910, 0.941); PLB_BAR_OVER(23542); PLB_BAR_VALUE(23544);
        PLB_BAR_ICON(23555, "icons\hud_food.paa");   PLB_BAR_TRACK(23550); PLB_BAR_FILL(23551, 0.216, 0.910, 0.941); PLB_BAR_OVER(23552); PLB_BAR_VALUE(23554);

        // WANTED bar (civ only): neon-yellow, 0-5000 bounty; full + red at 5000 = probable cause. $ climbs underneath (centred).
        PLB_BAR_ICON(23560, "icons\hud_police.paa"); PLB_BAR_TRACK(23561); PLB_BAR_FILL(23562, 0.957, 0.686, 0.176); PLB_BAR_OVER(23563);
        class plb_bv23564: Life_RscStructuredText { idc = 23564; x = 0.8; y = 0.92; w = 0.24; h = 0.050; sizeEx = 0.038; text = ""; class Attributes { font = "EtelkaMonospacePro"; color = "#f4af2d"; align = "center"; shadow = 1; shadowColor = "#05070d"; }; };
    };};