// APD Wanted List (LoonyNet "Wanted" phone app, life_fnc_wantedMenu). DECK RESKIN 2026-07-19 (cyberdeck theme).
// Left box = wanted suspects (idc 2402); right column = selected suspect's criminal state (2403), bounty (2404) and charges (2405).
// Runtime (life_fnc_wantedMenu / TON_fnc_wantedFetch) only touches idc 2401/2402/2403/2404/2405/2406/2407/2408/2409/2410/2420
// -- all classes, idcs, control TYPES and onLoad/onButtonClick logic kept intact. UI-only restyle: colours + geometry + deck frame + header.
// NOTE: for a cop, the function shrinks idc 2405 (charges list) and idc 2420 (charges panel) height by a fixed 0.0452 screen-fraction
// (~1 UI grid row) to reveal the remove input (2406) + button (2407). The remove strip below is sized to that ~1-row reveal.
class life_wanted_menu {idd = 2400;
    name = "life_wanted_menu";
    movingEnable = false;
    enableSimulation = true;
    class controlsBackground {
        // Deck screen frame -- fills the 40x20 UI grid (the "phone frame").
        class DeckFrame: Life_RscPicture {idc = -1;
            text = "images\phone_deck_blank.paa";
            x = -20*UI_GRID_W + UI_GRID_X; y = -10*UI_GRID_H + UI_GRID_Y; w = 40*UI_GRID_W; h = 20*UI_GRID_H;
            colorText[] = {1,1,1,1};};
        // Subtle content backing over the deck screen.
        class MainBackground: Life_RscText {idc = -1;
            x = -19.05 * UI_GRID_W + UI_GRID_X; y = -6.466 * UI_GRID_H + UI_GRID_Y; w = 36.0 * UI_GRID_W; h = 14.891 * UI_GRID_H;
            colorBackground[] = {0.02,0.045,0.035,0.35};};
        // Left column header bar (repurposed old red title-bar background).
        class Life_RscTitleBackground: Life_RscText {idc = -1;
            x = -18.77 * UI_GRID_W + UI_GRID_X; y = -4.905 * UI_GRID_H + UI_GRID_Y; w = 13.99 * UI_GRID_W; h = 0.936 * UI_GRID_H;
            colorBackground[] = {0.047,0.09,0.07,0.9};};
        // Left suspects list panel.
        class WantedListBackground: Life_RscText {idc = -1;
            x = -18.77 * UI_GRID_W + UI_GRID_X; y = -3.88 * UI_GRID_H + UI_GRID_Y; w = 13.99 * UI_GRID_W; h = 11.637 * UI_GRID_H;
            colorBackground[] = {0.02,0.045,0.035,0.85};};
        // Right column: criminal-state readout panel.
        class CriminalStateBackground: Life_RscText {idc = -1;
            x = -3.848 * UI_GRID_W + UI_GRID_X; y = -4.905 * UI_GRID_H + UI_GRID_Y; w = 20.518 * UI_GRID_W; h = 1.427 * UI_GRID_H;
            colorBackground[] = {0.047,0.09,0.07,0.9};};
        // Right column: bounty readout panel.
        class BountyPriceBackground: Life_RscText {idc = -1;
            x = -3.848 * UI_GRID_W + UI_GRID_X; y = -3.211 * UI_GRID_H + UI_GRID_Y; w = 20.518 * UI_GRID_W; h = 1.427 * UI_GRID_H;
            colorBackground[] = {0.047,0.09,0.07,0.9};};
        // Right column: charges panel. idc 2420 -- runtime shrinks its height (cop) so KEEP idc + type.
        class WantedDetailsBackground: Life_RscText {idc = 2420;
            x = -3.848 * UI_GRID_W + UI_GRID_X; y = -1.517 * UI_GRID_H + UI_GRID_Y; w = 20.518 * UI_GRID_W; h = 9.274 * UI_GRID_H;
            colorBackground[] = {0.02,0.045,0.035,0.85};};};
    class controls {
        // LoonyNet brand header.
        class Brand: Life_RscStructuredText {idc = -1;
            x = -2.8 * UI_GRID_W + UI_GRID_X; y = -8.22 * UI_GRID_H + UI_GRID_Y; w = 5 * UI_GRID_W; h = 0.9 * UI_GRID_H;
            size = 0.55 * UI_GRID_H;
            text = "<t size='1' font='EtelkaMonospacePro' color='#4c5a55'>// WANTED</t>";};
        // Left column header text (repurposed old "APD Wanted List" title). Sits on the header bar above.
        class Title: Life_RscTitle {idc = -1;
            text = "WANTED LIST";
            sizeEx = 0.6242 * UI_GRID_H;
            x = -18.397 * UI_GRID_W + UI_GRID_X; y = -4.905 * UI_GRID_H + UI_GRID_Y; w = 13.244 * UI_GRID_W; h = 0.936 * UI_GRID_H;
            colorText[] = {0.788,0.886,0.10,1};};
        // Network/connection status strip -- filled at runtime ("Establishing connection", etc.). KEEP idc 2401 + onLoad.
        class WantedConnection: Title {idc = 2401;
            style = 0;
            text = "Establishing Connection";
            sizeEx = 0.5529 * UI_GRID_H;
            x = -18.49 * UI_GRID_W + UI_GRID_X; y = -6.198 * UI_GRID_H + UI_GRID_Y; w = 34.881 * UI_GRID_W; h = 0.981 * UI_GRID_H;
            colorText[] = {0.2,1,0.73,1};
            colorBackground[] = {0,0,0,0};};
        // Left suspects list. onLoad (fade) UNCHANGED.
        class WantedList: Life_RscListBox {idc = 2402;
            sizeEx = 0.5529 * UI_GRID_H;
            onLoad = "(_this select 0) ctrlSetFade 1; (_this select 0) ctrlCommit 0";
            x = -18.77 * UI_GRID_W + UI_GRID_X; y = -3.88 * UI_GRID_H + UI_GRID_Y; w = 13.99 * UI_GRID_W; h = 11.637 * UI_GRID_H;
            colorText[] = {0.86,0.905,0.878,1};
            colorBackground[] = {0,0,0,0};
            colorSelectBackground[] = {0.788,0.886,0.10,0.30};
            colorSelectBackground2[] = {0.788,0.886,0.10,0.30};
            rowHeight = 0.95*UI_GRID_H;
            period = 0;};
        // Right column: selected suspect's criminal state readout. onLoad (fade) UNCHANGED.
        class CriminalState: Life_RscText {idc = 2403;
            sizeEx = 0.6242 * UI_GRID_H;
            onLoad = "(_this select 0) ctrlSetFade 1; (_this select 0) ctrlCommit 0";
            x = -3.568 * UI_GRID_W + UI_GRID_X; y = -4.905 * UI_GRID_H + UI_GRID_Y; w = 19.959 * UI_GRID_W; h = 1.427 * UI_GRID_H;
            colorText[] = {0.86,0.905,0.878,1};
            colorBackground[] = {0,0,0,0};};
        // Right column: bounty price readout. onLoad (fade) UNCHANGED.
        class BountyPrice: Life_RscText {idc = 2404;
            sizeEx = 0.6242 * UI_GRID_H;
            onLoad = "(_this select 0) ctrlSetFade 1; (_this select 0) ctrlCommit 0";
            x = -3.568 * UI_GRID_W + UI_GRID_X; y = -3.211 * UI_GRID_H + UI_GRID_Y; w = 19.959 * UI_GRID_W; h = 1.427 * UI_GRID_H;
            colorText[] = {0.86,0.905,0.878,1};
            colorBackground[] = {0,0,0,0};};
        // Right column: charges list. idc 2405 -- runtime shrinks its height (cop). KEEP idc + type + onLoad.
        class WantedDetails: Life_RscListBox {idc = 2405;
            sizeEx = 0.5529 * UI_GRID_H;
            onLoad = "(_this select 0) ctrlSetFade 1; (_this select 0) ctrlCommit 0";
            x = -3.661 * UI_GRID_W + UI_GRID_X; y = -1.338 * UI_GRID_H + UI_GRID_Y; w = 20.145 * UI_GRID_W; h = 8.917 * UI_GRID_H;
            colorText[] = {0.86,0.905,0.878,1};
            colorBackground[] = {0,0,0,0};
            colorSelectBackground[] = {0.2,1,0.73,0.20};
            colorSelectBackground2[] = {0.2,1,0.73,0.20};
            rowHeight = 0.95*UI_GRID_H;
            period = 0;};
        // Cop-only: charge number to remove. Shown when a cop opens the menu. onLoad (disable+hide) UNCHANGED.
        class ChargeSuspectInput: Life_RscEdit {idc = 2406;
            text = "1";
            sizeEx = 0.5529 * UI_GRID_H;
            onLoad = "(_this select 0) ctrlEnable false; (_this select 0) ctrlShow false;";
            x = -3.568 * UI_GRID_W + UI_GRID_X; y = 6.642 * UI_GRID_H + UI_GRID_Y; w = 13.896 * UI_GRID_W; h = 0.892 * UI_GRID_H;
            colorText[] = {0.86,0.905,0.878,1};
            colorBackground[] = {0.02,0.045,0.035,0.85};};
        // Cop-only: remove-charge confirm (danger). onLoad (disable+hide) UNCHANGED.
        class ChargeSuspect: Life_RscButtonMenu {idc = 2407;
            text = "Remove";
            sizeEx = 0.5529 * UI_GRID_H;
            onLoad = "(_this select 0) ctrlEnable false; (_this select 0) ctrlShow false";
            x = 10.701 * UI_GRID_W + UI_GRID_X; y = 6.642 * UI_GRID_H + UI_GRID_Y; w = 5.689 * UI_GRID_W; h = 0.892 * UI_GRID_H;
            colorText[] = {0.86,0.905,0.878,1};
            colorBackground[] = {0.55,0.1,0.1,1};
            colorBackground2[] = {0.63,0.18,0.18,1};};
        // Small dim-danger close (ESC also closes). onButtonClick UNCHANGED.
        class CloseButtonKey: Life_RscButtonMenu { text = "CLOSE"; sizeEx = 0.62 * UI_GRID_H; animTextureNormal = "#(argb,8,8,3)color(1,1,1,1)"; animTextureOver = "#(argb,8,8,3)color(1,1,1,1)"; animTextureFocused = "#(argb,8,8,3)color(1,1,1,1)"; animTexturePressed = "#(argb,8,8,3)color(1,1,1,1)"; animTextureDefault = "#(argb,8,8,3)color(1,1,1,1)"; colorText[] = {0.86,0.66,0.66,1}; colorBackground[] = {0.28,0.08,0.08,0.95}; colorBackground2[] = {0.28,0.08,0.08,0.95}; colorBackgroundActive[] = {0.4,0.12,0.12,1}; colorFocused[] = {0.4,0.12,0.12,1};
            idc = -1;
            
            onButtonClick = "closeDialog 0; [] spawn { uiSleep 0.15; if (isNull findDisplay 90000 && {alive player}) then { [] call life_fnc_p_openMenu; }; };";
            
            x = 11.9 * UI_GRID_W + UI_GRID_X; y = 7.35 * UI_GRID_H + UI_GRID_Y; w = 4.6 * UI_GRID_W; h = 1.2 * UI_GRID_H;};
        // Action buttons (Pardon / Drop / Charge) -- wired + shown at runtime. onLoad (disable+hide) UNCHANGED.
        class ButtonSlot1: Life_RscButtonMenu {idc = 2408;
            sizeEx = 0.6242 * UI_GRID_H;
            onLoad = "(_this select 0) ctrlEnable false; (_this select 0) ctrlShow false";
            x = -12.242 * UI_GRID_W + UI_GRID_X; y = 8.069 * UI_GRID_H + UI_GRID_Y; w = 9.326 * UI_GRID_W; h = 0.981 * UI_GRID_H;
            colorText[] = {0.86,0.905,0.878,1};
            colorBackground[] = {0.06,0.11,0.09,1};
            colorBackground2[] = {0.16,0.24,0.12,1};};
        class ButtonSlot2: Life_RscButtonMenu {idc = 2409;
            sizeEx = 0.6242 * UI_GRID_H;
            onLoad = "(_this select 0) ctrlEnable false; (_this select 0) ctrlShow false";
            x = -2.449 * UI_GRID_W + UI_GRID_X; y = 8.069 * UI_GRID_H + UI_GRID_Y; w = 9.326 * UI_GRID_W; h = 0.981 * UI_GRID_H;
            colorText[] = {0.86,0.905,0.878,1};
            colorBackground[] = {0.06,0.11,0.09,1};
            colorBackground2[] = {0.16,0.24,0.12,1};};
        class ButtonSlot3: Life_RscButtonMenu {idc = 2410;
            sizeEx = 0.6242 * UI_GRID_H;
            onLoad = "(_this select 0) ctrlEnable false; (_this select 0) ctrlShow false";
            x = 7.344 * UI_GRID_W + UI_GRID_X; y = 8.069 * UI_GRID_H + UI_GRID_Y; w = 9.326 * UI_GRID_W; h = 0.981 * UI_GRID_H;
            colorText[] = {0.86,0.905,0.878,1};
            colorBackground[] = {0.06,0.11,0.09,1};
            colorBackground2[] = {0.16,0.24,0.12,1};};};};
