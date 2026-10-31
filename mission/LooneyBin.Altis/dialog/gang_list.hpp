// owner 2026-06-13: "Gangs Online" roster (press 9, civ). DECK RESKIN 2026-07-19 (LoonyNet cyberdeck theme).
// Left box = gangs/groups (idc 2451), right box = selected roster's online members (idc 2452), idc 2453 = count line.
// Runtime (life_fnc_gangListMenu / life_fnc_gangListSelect) only touches idc 2451/2452/2453 -- classes+idcs kept intact.
class life_gang_list_menu {idd = 2450;
    name = "life_gang_list_menu";
    movingEnable = false;
    enableSimulation = true;
    class controlsBackground {
        // Deck screen frame (replaces the old plain bg rects as the "phone frame") -- fills the 40x20 UI grid.
        class DeckFrame: Life_RscPicture {idc = -1;
            text = "images\phone_deck_blank.paa";
            x = -20*UI_GRID_W + UI_GRID_X; y = -10*UI_GRID_H + UI_GRID_Y; w = 40*UI_GRID_W; h = 20*UI_GRID_H;
            colorText[] = {1,1,1,1};};
        // Subtle content backing over the deck screen.
        class MainBackground: Life_RscText {idc = -1;
            x = -19.05 * UI_GRID_W + UI_GRID_X; y = -6.466 * UI_GRID_H + UI_GRID_Y; w = 36.0 * UI_GRID_W; h = 14.891 * UI_GRID_H;
            colorBackground[] = {0.02,0.045,0.035,0.35};};
        // Left column header bar (repurposed old title-bar background).
        class Life_RscTitleBackground: Life_RscText {idc = -1;
            x = -18.77 * UI_GRID_W + UI_GRID_X; y = -4.816 * UI_GRID_H + UI_GRID_Y; w = 17.254 * UI_GRID_W; h = 0.936 * UI_GRID_H;
            colorBackground[] = {0.047,0.09,0.07,0.9};};
        // Left list panel.
        class GangListBackground: Life_RscText {idc = -1;
            x = -18.77 * UI_GRID_W + UI_GRID_X; y = -3.79 * UI_GRID_H + UI_GRID_Y; w = 17.254 * UI_GRID_W; h = 11.548 * UI_GRID_H;
            colorBackground[] = {0.02,0.045,0.035,0.85};};
        // Right list panel.
        class MembersListBackground: Life_RscText {idc = -1;
            x = -0.584 * UI_GRID_W + UI_GRID_X; y = -3.79 * UI_GRID_H + UI_GRID_Y; w = 17.254 * UI_GRID_W; h = 11.548 * UI_GRID_H;
            colorBackground[] = {0.02,0.045,0.035,0.85};};};
    class controls {
        // LoonyNet brand header.
        class Brand: Life_RscStructuredText {idc = -1;
            x = -2.8 * UI_GRID_W + UI_GRID_X; y = -8.22 * UI_GRID_H + UI_GRID_Y; w = 5 * UI_GRID_W; h = 0.9 * UI_GRID_H;
            size = 0.55 * UI_GRID_H;
            text = "<t size='1' font='EtelkaMonospacePro' color='#4c5a55'>// GANGS ONLINE</t>";};
        // Status strip -- filled at runtime: "Gangs Online: X | Groups: Y | Gang members online: Z".
        class CountLine: Life_RscText {idc = 2453;
            sizeEx = 0.5529 * UI_GRID_H;
            text = "";
            x = -18.49 * UI_GRID_W + UI_GRID_X; y = -6.198 * UI_GRID_H + UI_GRID_Y; w = 34.881 * UI_GRID_W; h = 0.981 * UI_GRID_H;
            colorText[] = {0.86,0.905,0.878,1};
            colorBackground[] = {0,0,0,0};};
        // Left column header text.
        class Title: Life_RscTitle {idc = -1;
            text = "Gangs Online";
            sizeEx = 0.7134 * UI_GRID_H;
            x = -18.397 * UI_GRID_W + UI_GRID_X; y = -4.816 * UI_GRID_H + UI_GRID_Y; w = 16.788 * UI_GRID_W; h = 0.936 * UI_GRID_H;
            colorText[] = {0.788,0.886,0.10,1};};
        // Left roster list (gangs + groups). onLBSelChanged fills the members box -- UNCHANGED.
        class GangList: Life_RscListBox {idc = 2451;
            sizeEx = 0.6242 * UI_GRID_H;
            onLBSelChanged = "_this call life_fnc_gangListSelect";
            x = -18.77 * UI_GRID_W + UI_GRID_X; y = -3.79 * UI_GRID_H + UI_GRID_Y; w = 17.254 * UI_GRID_W; h = 11.548 * UI_GRID_H;
            colorText[] = {0.86,0.905,0.878,1};
            colorBackground[] = {0,0,0,0};
            colorSelectBackground[] = {0.788,0.886,0.10,0.30};
            colorSelectBackground2[] = {0.788,0.886,0.10,0.30};
            rowHeight = 0.05;
            period = 0;};
        // Right column header text.
        class MembersHeader: Life_RscText {idc = -1;
            text = " Members Online";
            sizeEx = 0.7134 * UI_GRID_H;
            x = -0.584 * UI_GRID_W + UI_GRID_X; y = -4.816 * UI_GRID_H + UI_GRID_Y; w = 17.254 * UI_GRID_W; h = 0.936 * UI_GRID_H;
            colorText[] = {0.2,1,0.73,1};
            colorBackground[] = {0.047,0.09,0.07,0.9};};
        // Right members list (display only, filled by life_fnc_gangListSelect).
        class MembersList: Life_RscListBox {idc = 2452;
            sizeEx = 0.6242 * UI_GRID_H;
            x = -0.584 * UI_GRID_W + UI_GRID_X; y = -3.79 * UI_GRID_H + UI_GRID_Y; w = 17.254 * UI_GRID_W; h = 11.548 * UI_GRID_H;
            colorText[] = {0.86,0.905,0.878,1};
            colorBackground[] = {0,0,0,0};
            colorSelectBackground[] = {0.2,1,0.73,0.20};
            colorSelectBackground2[] = {0.2,1,0.73,0.20};
            rowHeight = 0.05;
            period = 0;};
        // Small dim-danger close (ESC also closes). Logic UNCHANGED.
        class CloseButtonKey: Life_RscButtonMenu { text = "CLOSE"; sizeEx = 0.62 * UI_GRID_H; animTextureNormal = "#(argb,8,8,3)color(1,1,1,1)"; animTextureOver = "#(argb,8,8,3)color(1,1,1,1)"; animTextureFocused = "#(argb,8,8,3)color(1,1,1,1)"; animTexturePressed = "#(argb,8,8,3)color(1,1,1,1)"; animTextureDefault = "#(argb,8,8,3)color(1,1,1,1)"; colorText[] = {0.86,0.66,0.66,1}; colorBackground[] = {0.28,0.08,0.08,0.95}; colorBackground2[] = {0.28,0.08,0.08,0.95}; colorBackgroundActive[] = {0.4,0.12,0.12,1}; colorFocused[] = {0.4,0.12,0.12,1};
            idc = -1;
            
            onButtonClick = "closeDialog 0; [] spawn { uiSleep 0.15; if (isNull findDisplay 90000 && {alive player}) then { [] call life_fnc_p_openMenu; }; };";
            
            x = 11.9 * UI_GRID_W + UI_GRID_X; y = 7.35 * UI_GRID_H + UI_GRID_Y; w = 4.6 * UI_GRID_W; h = 1.2 * UI_GRID_H;};};};
