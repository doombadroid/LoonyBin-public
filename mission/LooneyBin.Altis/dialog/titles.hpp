// owner 2026-07-19: "Titles" phone app (life_fnc_getMyStats -> life_fnc_titleMenu / life_fnc_titleSel).
// DECK RESKIN 2026-07-19 (LoonyNet cyberdeck theme) -- matches gang_list.hpp / casino deck family.
// Runtime touches ONLY: idc 91001 (title list, LBSelChanged), 91002 (info/description), 91003 (Set Title button),
// 1005 (close), plus phone chrome 90300 (wallpaper -> hidden) and 90301/90302/90303 (status strip, filled by
// life_fnc_p_updateMenu with cash | clock | weight). Every idc/idd/control-type + onButtonClick/onLoad kept intact.
class life_titles_menu {idd = 91000;
    name = "life_titles_menu";
    movingEnable = false;
    enableSimulation = true;
    class Life_PhoneButton: Life_RscButtonMenu {animTextureNormal = "#(argb,8,8,3)color(0,0,0,0)";
        animTextureDisabled = "#(argb,8,8,3)color(0,0,0,0)";
        animTextureOver = "#(argb,8,8,3)color(0,0,0,0)";
        animTextureFocused = "#(argb,8,8,3)color(0,0,0,0)";
        animTexturePressed = "#(argb,8,8,3)color(0,0,0,0)";
        animTextureDefault = "#(argb,8,8,3)color(0,0,0,0)";
        onLoad = "(_this select 0) ctrlShow false";};
    class controlsBackground {
        // Phone wallpaper hidden -- the deck frame image is the screen now (per deck-reskin spec).
        class PhoneWallpaper: Life_RscPictureKeepAspect {idc = 90300;
            onLoad = "(_this select 0) ctrlShow false";
            x = -19.1 * UI_GRID_W + UI_GRID_X;
            y = -7.134 * UI_GRID_H + UI_GRID_Y;
            w = 36.09 * UI_GRID_W;
            h = 16.229 * UI_GRID_H;
            colorBackground[] = {0,0,0,0};};
        // Deck screen frame -- fills the 40x20 UI grid (replaces the old portrait images\phone.paa).
        class PhoneFrame: Life_RscPicture {idc = -1;
            text = "images\phone_deck_blank.paa";
            x = -20 * UI_GRID_W + UI_GRID_X;
            y = -10 * UI_GRID_H + UI_GRID_Y;
            w = 40 * UI_GRID_W;
            h = 20 * UI_GRID_H;
            colorText[] = {1,1,1,1};};
        // Subtle dark content backing over the deck screen.
        class MainBackground: Life_RscText {idc = -1;
            x = -19.05 * UI_GRID_W + UI_GRID_X;
            y = -6.466 * UI_GRID_H + UI_GRID_Y;
            w = 36.0 * UI_GRID_W;
            h = 14.891 * UI_GRID_H;
            colorBackground[] = {0.02,0.045,0.035,0.35};};
        // Solid panel behind the (transparent) title list.
        class TitleListBackground: Life_RscText {idc = -1;
            x = -18.77 * UI_GRID_W + UI_GRID_X;
            y = -3.88 * UI_GRID_H + UI_GRID_Y;
            w = 17.254 * UI_GRID_W;
            h = 11.949 * UI_GRID_H;
            colorBackground[] = {0.02,0.045,0.035,0.85};};
        // Phone status strip (cash | clock | weight) -- repositioned into the deck header row.
        // life_fnc_p_updateMenu force-shows + rewrites these each second at align left/center/right, no color -> Attributes.color wins.
        class StatusTextLeft: Life_RscStructuredText {idc = 90301;
            size = 0.8 * UI_GRID_H;
            x = 2.5 * UI_GRID_W + UI_GRID_X;
            y = -8.22 * UI_GRID_H + UI_GRID_Y;
            w = 13.7 * UI_GRID_W;
            h = 0.9 * UI_GRID_H;
            class Attributes { color = "#c9e21a"; };};
        class StatusTextCenter: Life_RscStructuredText {idc = 90302;
            size = 0.8 * UI_GRID_H;
            x = 2.5 * UI_GRID_W + UI_GRID_X;
            y = -8.22 * UI_GRID_H + UI_GRID_Y;
            w = 13.7 * UI_GRID_W;
            h = 0.9 * UI_GRID_H;
            class Attributes { color = "#8fae97"; };};
        class StatusTextRight: Life_RscStructuredText {idc = 90303;
            size = 0.8 * UI_GRID_H;
            x = 2.5 * UI_GRID_W + UI_GRID_X;
            y = -8.22 * UI_GRID_H + UI_GRID_Y;
            w = 13.7 * UI_GRID_W;
            h = 0.9 * UI_GRID_H;
            class Attributes { color = "#8fae97"; };};};
    class controls {
        // LoonyNet brand header.
        class Brand: Life_RscStructuredText {idc = -1;
            x = -2.8 * UI_GRID_W + UI_GRID_X;
            y = -8.22 * UI_GRID_H + UI_GRID_Y;
            w = 5 * UI_GRID_W;
            h = 0.9 * UI_GRID_H;
            size = 0.55 * UI_GRID_H;
            text = "<t size='1' font='EtelkaMonospacePro' color='#4c5a55'>// TITLES</t>";};
        // Left column header.
        class ListHeader: Life_RscText {idc = -1;
            text = " SELECT A TITLE";
            sizeEx = 0.7134 * UI_GRID_H;
            x = -18.77 * UI_GRID_W + UI_GRID_X;
            y = -4.905 * UI_GRID_H + UI_GRID_Y;
            w = 17.254 * UI_GRID_W;
            h = 0.936 * UI_GRID_H;
            colorText[] = {0.788,0.886,0.10,1};
            colorBackground[] = {0.047,0.09,0.07,0.9};};
        // Right column header.
        class InfoHeader: Life_RscText {idc = -1;
            text = " DETAILS";
            sizeEx = 0.7134 * UI_GRID_H;
            x = -0.584 * UI_GRID_W + UI_GRID_X;
            y = -4.905 * UI_GRID_H + UI_GRID_Y;
            w = 17.254 * UI_GRID_W;
            h = 0.936 * UI_GRID_H;
            colorText[] = {0.2,1,0.73,1};
            colorBackground[] = {0.047,0.09,0.07,0.9};};
        // Title list -- rows added + LBSelChanged wired in life_fnc_titleMenu. TRANSPARENT over TitleListBackground.
        class TitleList: Life_RscListBox {idc = 91001;
            sizeEx = 0.6242 * UI_GRID_H;
            x = -18.77 * UI_GRID_W + UI_GRID_X;
            y = -3.88 * UI_GRID_H + UI_GRID_Y;
            w = 17.254 * UI_GRID_W;
            h = 11.949 * UI_GRID_H;
            colorText[] = {0.86,0.905,0.878,1};
            colorBackground[] = {0,0,0,0};
            colorSelectBackground[] = {0.788,0.886,0.10,0.30};
            colorSelectBackground2[] = {0.788,0.886,0.10,0.30};
            rowHeight = 0.05;
            period = 0;};
        // Selected-title description -- filled by life_fnc_titleSel via ctrlSetStructuredText (align='center' size='0.65').
        class TitleInfo: Life_RscStructuredText {idc = 91002;
            x = -0.584 * UI_GRID_W + UI_GRID_X;
            y = -3.88 * UI_GRID_H + UI_GRID_Y;
            w = 17.254 * UI_GRID_W;
            h = 8.204 * UI_GRID_H;
            size = 1.0255 * UI_GRID_H;
            colorBackground[] = {0.02,0.045,0.035,0.85};
            class Attributes { color = "#dce7e0"; };};
        // Apply-title button -- ButtonClick wired in life_fnc_titleMenu (calls life_fnc_setTitle). Acid primary CTA.
        class TitleSetButton: Life_RscButtonMenu {idc = 91003;
            period = 0;
            periodOver = 2;
            periodFocus = 0;
            text = "SET TITLE";
            sizeEx = 0.7115 * UI_GRID_H;
            x = -0.584 * UI_GRID_W + UI_GRID_X;
            y = 4.904 * UI_GRID_H + UI_GRID_Y;
            w = 17.254 * UI_GRID_W;
            h = 1.962 * UI_GRID_H;
            colorText[] = {0.04,0.09,0.07,1};
            colorBackground[] = {0.788,0.886,0.10,1};};
        // Small dim-danger close (Esc also closes). onButtonClick / onLoad UNCHANGED.
        class HomeButton: Life_PhoneButton { text = "CLOSE"; sizeEx = 0.62 * UI_GRID_H; animTextureNormal = "#(argb,8,8,3)color(1,1,1,1)"; animTextureOver = "#(argb,8,8,3)color(1,1,1,1)"; animTextureFocused = "#(argb,8,8,3)color(1,1,1,1)"; animTexturePressed = "#(argb,8,8,3)color(1,1,1,1)"; animTextureDefault = "#(argb,8,8,3)color(1,1,1,1)"; colorText[] = {0.86,0.66,0.66,1}; colorBackground[] = {0.28,0.08,0.08,0.95}; colorBackground2[] = {0.28,0.08,0.08,0.95}; colorBackgroundActive[] = {0.4,0.12,0.12,1}; colorFocused[] = {0.4,0.12,0.12,1};
            onButtonClick = "closeDialog 0; [] spawn { uiSleep 0.15; if (isNull findDisplay 90000 && {alive player}) then { [] call life_fnc_p_openMenu; }; };";
            onLoad = "(_this select 0) ctrlShow true";
            idc = 1005;
            
            x = 11.9 * UI_GRID_W + UI_GRID_X;
            y = 7.35 * UI_GRID_H + UI_GRID_Y;
            w = 4.6 * UI_GRID_W;
            h = 1.2 * UI_GRID_H;
            
            tooltip = "Close (Esc)";};};};
