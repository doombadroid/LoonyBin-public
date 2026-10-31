/*
    browser.hpp  (LooneyBin -- phone web browser "LoonyNet"). idd 936100.
    DECK RESKIN (cyberdeck theme): the old portrait phone.paa frame is replaced by the shared deck
    screen images\phone_deck_blank.paa at the standard -20/-10/40/20 UI grid (matches casino_landing +
    smartphone HOME). Layout re-flowed portrait->landscape to FILL the 40x20 deck screen:
      header (T-MALDEN // BROWSER) -> chrome row 1 (BACK / HOME / url / GO / X) -> chrome row 2 (page
      MENU combo, idc 936120) -> the page (scroll group) -> Looner compose bar pinned bottom.
    Palette: deck #0c1712 panels, acid #c9e21a (GO / brand / nav glyphs) + cyan #33ffbb (links / LOON IT).
    NOTE ON HEIGHTS: life_fnc_browser resizes the page group (936130) and page text (936131) HEIGHTS at
    runtime; that math was scaled to the old 79.66*pixelGrid frame and is rescaled to 40 (the deck's
    20*UI_GRID_H span) in the .sqf so the viewport fits this frame. Everything else here is static.
    ContentBg (936104) is kept (the .sqf still sets its texture per-site) but made invisible -- the deck
    panel replaces the old baked portrait backgrounds. Every idc / control type / handler is unchanged.
*/

class Life_BrowserBtn {                       // PLAIN button (type 1, ST_CENTER): RscButtonMenu draws a left
    idc = -1; type = 1; style = 2; shadow = 0;   // decoration strip + left-pads text (clipped "GO" -> "G",
    x = 0; y = 0; w = 0.1; h = 0.05;             // strip overhung the frame) -- so no ButtonMenu inherit.
    font = "PuristaMedium";
    sizeEx = 0.72*UI_GRID_H;
    colorText[] = {0.86,0.905,0.878,1};
    colorBackground[] = {0.047,0.09,0.07,1};       // deck #0c1712
    colorBackgroundActive[] = {0.16,0.24,0.12,1};
    colorFocused[] = {0.047,0.09,0.07,1};          // focused == idle (no pulse)
    colorDisabled[] = {0.5,0.57,0.54,0.6};
    colorBackgroundDisabled[] = {0,0,0,0.4};
    colorShadow[] = {0,0,0,0};
    colorBorder[] = {0,0,0,1};
    offsetX = 0; offsetY = 0; offsetPressedX = 0.0005; offsetPressedY = 0.0005; borderSize = 0;
    soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter", 0.09, 1};
    soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush", 0.09, 1};
    soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick", 0.09, 1};
    soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape", 0.09, 1};};

class life_browser {idd = 936100;
    name = "life_browser";
    movingEnable = false;
    enableSimulation = true;
    class controlsBackground {
        class Dim: Life_RscText { idc=-1; x=safezoneX; y=safezoneY; w=safezoneW; h=safezoneH; colorBackground[]={0,0,0,0.6}; };
        class Frame: Life_RscPicture { idc=-1;
            x=-20*UI_GRID_W + UI_GRID_X; y=-10*UI_GRID_H + UI_GRID_Y; w=40*UI_GRID_W; h=20*UI_GRID_H;
            colorText[]={1,1,1,1}; text="images\phone_deck_blank.paa";};
        class ChromePanel: Life_RscText { idc=-1;   // toolbar backdrop (BACK / HOME / url / GO / X), single row
            x = -18.6 * UI_GRID_W + UI_GRID_X; y = -6.65 * UI_GRID_H + UI_GRID_Y; w = 35.2 * UI_GRID_W; h = 1.5 * UI_GRID_H;
            colorBackground[]={0.02,0.045,0.035,0.85};};
        class RailPanel: Life_RscText { idc=-1;     // LEFT bookmark rail backdrop (landscape redesign 2026-07-20)
            x = -18.6 * UI_GRID_W + UI_GRID_X; y = -4.95 * UI_GRID_H + UI_GRID_Y; w = 7.9 * UI_GRID_W; h = 14.0 * UI_GRID_H;
            colorBackground[]={0.047,0.09,0.07,0.9};};
        class PagePanel: Life_RscText { idc=-1;     // page backdrop -- WHITE paper (owner 2026-07-20: sites read as pages, not terminal)
            x = -10.5 * UI_GRID_W + UI_GRID_X; y = -4.95 * UI_GRID_H + UI_GRID_Y; w = 27.1 * UI_GRID_W; h = 14.0 * UI_GRID_H;
            colorBackground[]={0.93,0.915,0.885,1};};
        class ContentBg: Life_RscPicture { idc=936104;   // texture still swapped per-site by the .sqf; held invisible under the deck panel
            x=-20*UI_GRID_W + UI_GRID_X; y=-10*UI_GRID_H + UI_GRID_Y; w=40*UI_GRID_W; h=20*UI_GRID_H;
            colorText[]={1,1,1,0}; text="images\browser_bg_port.paa";};};
    class controls {
        // ---- header (added for the deck theme) ----
        class Brand: Life_RscStructuredText { idc=-1;
            x = -2.8 * UI_GRID_W + UI_GRID_X; y = -8.22 * UI_GRID_H + UI_GRID_Y; w = 5 * UI_GRID_W; h = 0.9 * UI_GRID_H;
            size = 0.55 * UI_GRID_H;
            text = "<t size='1' font='EtelkaMonospacePro' color='#4c5a55'>// BROWSER</t>";};
        // ---- chrome row 1: BACK / HOME / url / GO / X ----
        class BackBtn: Life_BrowserBtn { idc=936111; text="<";
            x = -18.4 * UI_GRID_W + UI_GRID_X; y = -6.5 * UI_GRID_H + UI_GRID_Y; w = 2.0 * UI_GRID_W; h = 1.2 * UI_GRID_H;
            onButtonClick = "['back'] call life_fnc_browser;";
            colorText[]={0.788,0.886,0.10,1}; colorBackground[]={0,0,0,0}; colorBackgroundActive[]={0.788,0.886,0.10,0.16}; colorFocused[]={0,0,0,0};
        };
        class HomeBtn: Life_BrowserBtn { idc=936112; text="~";
            x = -16.2 * UI_GRID_W + UI_GRID_X; y = -6.5 * UI_GRID_H + UI_GRID_Y; w = 2.0 * UI_GRID_W; h = 1.2 * UI_GRID_H;
            onButtonClick = "['go','loonynet.start'] call life_fnc_browser;";
            colorText[]={0.788,0.886,0.10,1}; colorBackground[]={0,0,0,0}; colorBackgroundActive[]={0.788,0.886,0.10,0.16}; colorFocused[]={0,0,0,0};
        };
        class UrlEdit: Life_RscEdit { idc=936110;
            x = -14.0 * UI_GRID_W + UI_GRID_X; y = -6.5 * UI_GRID_H + UI_GRID_Y; w = 22.9 * UI_GRID_W; h = 1.2 * UI_GRID_H;
            sizeEx = 0.535 * UI_GRID_H; font="RobotoCondensed"; shadow=0; colorText[]={0.8,0.98,0.8,1}; colorBackground[]={0.02,0.045,0.035,0.85}; text="";
        };
        class GoBtn: Life_BrowserBtn { idc=936113; text="GO"; font="PuristaBold";
            x = 9.1 * UI_GRID_W + UI_GRID_X; y = -6.5 * UI_GRID_H + UI_GRID_Y; w = 3.4 * UI_GRID_W; h = 1.2 * UI_GRID_H;
            colorText[]={0.04,0.06,0.02,1}; colorBackground[]={0.788,0.886,0.10,1}; colorBackgroundActive[]={0.86,0.95,0.2,1}; colorFocused[]={0.788,0.886,0.10,1};
            onButtonClick = "['url'] call life_fnc_browser;";};
        class CloseBtn: Life_BrowserBtn { idc=936114; text="X";   // small, dim danger; ESC also closes
            x = 12.7 * UI_GRID_W + UI_GRID_X; y = -6.5 * UI_GRID_H + UI_GRID_Y; w = 2.4 * UI_GRID_W; h = 1.2 * UI_GRID_H;
            colorText[]={0.78,0.32,0.32,1}; colorBackground[]={0,0,0,0}; colorBackgroundActive[]={0.55,0.1,0.1,0.35}; colorFocused[]={0,0,0,0};
            onButtonClick = "closeDialog 0; [] spawn { uiSleep 0.15; if (isNull findDisplay 90000 && {alive player}) then { [] call life_fnc_p_openMenu; }; };";
        };
        // ---- LEFT bookmark rail (landscape redesign 2026-07-20; combo -> listbox, SAME idc/event -- the
        // lb* command family + onLBSelChanged behave identically, fn_browser untouched by the type change) ----
        class NavRail: Life_RscListBox { idc=936120;
            x = -18.4 * UI_GRID_W + UI_GRID_X; y = -4.75 * UI_GRID_H + UI_GRID_Y; w = 7.5 * UI_GRID_W; h = 13.6 * UI_GRID_H;
            sizeEx = 0.62 * UI_GRID_H; rowHeight = 0.052;
            colorBackground[]={0,0,0,0}; colorText[]={0.72,0.79,0.76,1};
            colorSelect[]={0.788,0.886,0.10,1}; colorSelect2[]={0.788,0.886,0.10,1};
            colorSelectBackground[]={0.788,0.886,0.10,0.20}; colorSelectBackground2[]={0.788,0.886,0.10,0.12};
            onLBSelChanged = "['nav'] call life_fnc_browser;";};
        // ---- the page ---- (height re-set at runtime by life_fnc_browser)
        class PageGroup: Life_RscControlsGroupOneScrollbar { idc=936130;
            x = -10.3 * UI_GRID_W + UI_GRID_X; y = -4.75 * UI_GRID_H + UI_GRID_Y; w = 26.7 * UI_GRID_W; h = 13.7 * UI_GRID_H;
            class Controls {class PageText: Life_RscStructuredText { idc=936131; shadow=0; font="RobotoCondensed";
                    colorLink[]={0.043,0.43,0.32,1};   // <a href> spans -- dark teal, readable on the paper ground
                    x=(0.4)*UI_GRID_W; y=(0.2)*UI_GRID_H; w = 25.5 * UI_GRID_W; h=(13)*UI_GRID_H;
                    size=0.6*UI_GRID_H;
                    class Attributes { align="left"; shadow=0; };
                    text="";};};};
        // ---- Looner compose bar (bottom; hidden unless on a looner.* page) ----
        class ComposeCount: Life_RscStructuredText { idc=936142; show=0; shadow=0; font="RobotoCondensed";
            x = -10.3 * UI_GRID_W + UI_GRID_X; y = 7.05 * UI_GRID_H + UI_GRID_Y; w = 26.7 * UI_GRID_W; h = 0.5 * UI_GRID_H;
            size = 0.4459 * UI_GRID_H; text="";};
        class ComposeEdit: Life_RscEdit { idc=936140; show=0;
            x = -10.3 * UI_GRID_W + UI_GRID_X; y = 7.65 * UI_GRID_H + UI_GRID_Y; w = 20.4 * UI_GRID_W; h = 1.15 * UI_GRID_H;
            sizeEx = 0.5529 * UI_GRID_H; font="RobotoCondensed"; shadow=0; colorText[]={0.86,0.905,0.878,1}; colorBackground[]={0.02,0.045,0.035,0.9}; text="";   // dark deck field
            tooltip="What's happening? (180 max)"; maxChars=180; onKeyUp="['updateCount'] call life_fnc_browser;";};
        class PostBtn: Life_BrowserBtn { idc=936141; text="LOON IT"; show=0; font="PuristaBold";
            x = 10.4 * UI_GRID_W + UI_GRID_X; y = 7.65 * UI_GRID_H + UI_GRID_Y; w = 6.0 * UI_GRID_W; h = 1.15 * UI_GRID_H;
            colorText[]={0.03,0.06,0.05,1};
            colorBackground[]={0.2,1,0.73,1}; colorBackgroundActive[]={0.45,1,0.82,1}; colorFocused[]={0.2,1,0.73,1};   // cyan CTA
            onButtonClick = "['loonpost'] call life_fnc_browser;";};};};
