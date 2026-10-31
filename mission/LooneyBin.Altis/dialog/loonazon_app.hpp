/*
    loonazon_app.hpp -- LOONAZON standalone phone app (idd 987600). DECK RESKIN 2026-07-19 (cyberdeck theme).
    LoonyNet deck screen: phone_deck_blank.paa frame fills the 40x20 UI grid; dark #0c1712 / #050a08 panels,
    acid (#c9e21a) brand + selection, cyan (#33ffbb) flavor accent, cream (#dbe7e0) body, red kept for danger.
    Two-panel storefront: SHOP (left: category rail, item list, qty + add) / CART (right: lines, dual weight
    meters, total, order). Driven by life_fnc_loonazonApp (modes: open/cat/add/remove/refresh/order) -- every
    idc, control TYPE and onButtonClick kept intact; the fn repaints the active tab + meters at runtime (deck
    colours pushed there too). UI-only restyle: colours + geometry + deck frame + LoonyNet header.
*/
class PLB_LoonazonApp {idd = 987600;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "";

    class controlsBackground {
        // Deck screen frame -- fills the 40x20 UI grid (was the plain warm-black ground rect).
        class LzGround: Life_RscPicture {idc = -1;
            text = "images\phone_deck_blank.paa";
            x = -20*UI_GRID_W + UI_GRID_X; y = -10*UI_GRID_H + UI_GRID_Y; w = 40*UI_GRID_W; h = 20*UI_GRID_H;
            colorText[] = {1,1,1,1};};
        // Left SHOP panel backing (repurposed old kraft header band). #0c1712.
        class LzHeaderBand: Life_RscText {idc = -1;
            x = -18.77 * UI_GRID_W + UI_GRID_X; y = -5.396 * UI_GRID_H + UI_GRID_Y; w = 17.161 * UI_GRID_W; h = 14.267 * UI_GRID_H;
            colorBackground[] = {0.047,0.09,0.07,0.9};};
        // Right CART panel backing. #050a08.
        class LzCartPanel: Life_RscText {idc = -1;
            x = -0.49 * UI_GRID_W + UI_GRID_X; y = -5.396 * UI_GRID_H + UI_GRID_Y; w = 17.161 * UI_GRID_W; h = 14.267 * UI_GRID_H;
            colorBackground[] = {0.02,0.045,0.035,0.85};};};

    class controls {
        // ---- LoonyNet deck header (added) ----
        class LzBrand: Life_RscStructuredText {idc = -1;
            x = -2.8 * UI_GRID_W + UI_GRID_X; y = -8.22 * UI_GRID_H + UI_GRID_Y; w = 5 * UI_GRID_W; h = 0.9 * UI_GRID_H;
            size = 0.55 * UI_GRID_H;
            text = "<t size='1' font='EtelkaMonospacePro' color='#4c5a55'>// LOONAZON</t>";};
        // App wordmark -- kept (idc preserved), tucked top-right as a small acid-tinted brand echo.
        class LzLogo: Life_RscPicture {idc = 987602;
            text = "images\loonazon_logo.paa";
            x = 8.276 * UI_GRID_W + UI_GRID_X; y = -7.001 * UI_GRID_H + UI_GRID_Y; w = 6.995 * UI_GRID_W; h = 1.115 * UI_GRID_H;
            colorText[] = {0.788,0.886,0.10,0.9};};
        class LzTagline: Life_RscStructuredText {idc = 987603;
            text = "<t size='1' color='#7f918a'>same-day delivery, anywhere on Altis.</t> <t size='1' color='#33ffbb'>driver does not accept returns.</t>";
            x = -18.304 * UI_GRID_W + UI_GRID_X; y = -6.287 * UI_GRID_H + UI_GRID_Y; w = 34.508 * UI_GRID_W; h = 0.758 * UI_GRID_H;
            size = 0.535 * UI_GRID_H;};
        // Small dim-danger close, bottom-left corner (ESC also closes). onButtonClick UNCHANGED.
        class LzClose: Life_RscButtonMenu { text = "CLOSE"; sizeEx = 0.62 * UI_GRID_H; animTextureNormal = "#(argb,8,8,3)color(1,1,1,1)"; animTextureOver = "#(argb,8,8,3)color(1,1,1,1)"; animTextureFocused = "#(argb,8,8,3)color(1,1,1,1)"; animTexturePressed = "#(argb,8,8,3)color(1,1,1,1)"; animTextureDefault = "#(argb,8,8,3)color(1,1,1,1)"; colorText[] = {0.86,0.66,0.66,1}; colorBackground[] = {0.28,0.08,0.08,0.95}; colorBackground2[] = {0.28,0.08,0.08,0.95}; colorBackgroundActive[] = {0.4,0.12,0.12,1}; colorFocused[] = {0.4,0.12,0.12,1};
            idc = 987604;
            
            onButtonClick = "closeDialog 0; [] spawn { uiSleep 0.15; if (isNull findDisplay 90000 && {alive player}) then { [] call life_fnc_p_openMenu; }; };";
            
            x = 11.9 * UI_GRID_W + UI_GRID_X; y = 7.35 * UI_GRID_H + UI_GRID_Y; w = 4.6 * UI_GRID_W; h = 1.2 * UI_GRID_H;};

        // ---- category rail (the app fn repaints the active tab acid-green at runtime) ----
        // short single-word labels, style=2 (center). Spread across the SHOP panel width.
        class LzCatGen: Life_RscButtonMenu {idc = 987610;
            text = "GEN";
            onButtonClick = "[""cat"", ""gen""] spawn life_fnc_loonazonApp;";
            style = 2;
            sizeEx = 0.4904 * UI_GRID_H;
            x = -18.397 * UI_GRID_W + UI_GRID_X; y = -5.128 * UI_GRID_H + UI_GRID_Y; w = 3.171 * UI_GRID_W; h = 1.159 * UI_GRID_H;
            colorText[] = {0.86,0.905,0.878,1};
            colorBackground[] = {0.34,0.42,0.08,1};
            colorBackground2[] = {0.16,0.24,0.12,1};};
        class LzCatRebel: LzCatGen {idc = 987611;
            text = "GUNS";
            onButtonClick = "[""cat"", ""rebel""] spawn life_fnc_loonazonApp;";
            x = -15.086 * UI_GRID_W + UI_GRID_X;
            colorBackground[] = {0.047,0.09,0.07,1};};
        class LzCatDrip: LzCatGen {idc = 987613;
            text = "DRIP";
            onButtonClick = "[""cat"", ""drip""] spawn life_fnc_loonazonApp;";
            x = -11.775 * UI_GRID_W + UI_GRID_X;
            colorBackground[] = {0.047,0.09,0.07,1};};
        class LzCatRItems: LzCatGen {idc = 987614;
            text = "TOOLS";
            onButtonClick = "[""cat"", ""ritems""] spawn life_fnc_loonazonApp;";
            x = -8.465 * UI_GRID_W + UI_GRID_X;
            colorBackground[] = {0.047,0.09,0.07,1};};
        class LzCatSeeds: LzCatGen {idc = 987612;
            text = "SEEDS";
            onButtonClick = "[""cat"", ""seeds""] spawn life_fnc_loonazonApp;";
            x = -5.154 * UI_GRID_W + UI_GRID_X;
            colorBackground[] = {0.047,0.09,0.07,1};};

        // ---- shop list ----
        class LzItems: Life_RscListBox {idc = 987620;
            x = -18.397 * UI_GRID_W + UI_GRID_X; y = -3.79 * UI_GRID_H + UI_GRID_Y; w = 16.415 * UI_GRID_W; h = 10.611 * UI_GRID_H;
            sizeEx = 0.5529 * UI_GRID_H;
            rowHeight = 1.05*UI_GRID_H;
            period = 0;
            colorText[] = {0.86,0.905,0.878,1};
            colorBackground[] = {0.02,0.045,0.035,0.85};
            colorSelectBackground[] = {0.788,0.886,0.10,0.30};
            colorSelectBackground2[] = {0.788,0.886,0.10,0.30};
            colorSelect[] = {0.95,0.98,0.92,1};
            colorSelect2[] = {0.95,0.98,0.92,1};};
        class LzQty: Life_RscEdit {idc = 987621;
            text = "1";
            x = -18.397 * UI_GRID_W + UI_GRID_X; y = 7.044 * UI_GRID_H + UI_GRID_Y; w = 3.358 * UI_GRID_W; h = 1.25 * UI_GRID_H;
            sizeEx = 0.66 * UI_GRID_H;
            colorText[] = {0.95,0.98,0.92,1};
            colorBackground[] = {0.02,0.045,0.035,0.85};};
        class LzAdd: Life_RscButtonMenu {idc = 987622;
            text = "ADD TO CART";
            onButtonClick = "[""add""] spawn life_fnc_loonazonApp;";
            x = -14.76 * UI_GRID_W + UI_GRID_X; y = 7.044 * UI_GRID_H + UI_GRID_Y; w = 12.777 * UI_GRID_W; h = 1.25 * UI_GRID_H;
            sizeEx = 0.68 * UI_GRID_H;
            colorText[] = {0.86,0.905,0.878,1};
            colorBackground[] = {0.06,0.11,0.09,1};
            colorBackground2[] = {0.16,0.24,0.12,1};
         colorDisabled[] = {0.78,0.82,0.62,0.8}; colorBackgroundDisabled[] = {0.10,0.13,0.08,0.92};};
        class LzHint: Life_RscStructuredText {idc = 987623;
            text = "<t size='1' color='#4c5a55'>qty, then add. weapons ship with 2 mags.</t>";
            x = -15.599 * UI_GRID_W + UI_GRID_X; y = 8.292 * UI_GRID_H + UI_GRID_Y; w = 13.617 * UI_GRID_W; h = 0.535 * UI_GRID_H;
            size = 0.4904 * UI_GRID_H;};

        // ---- cart ----
        class LzCartHead: Life_RscStructuredText {idc = 987630;
            text = "<t size='1.05' color='#dbe7e0'>CART</t>";
            x = -0.117 * UI_GRID_W + UI_GRID_X; y = -5.128 * UI_GRID_H + UI_GRID_Y; w = 16.415 * UI_GRID_W; h = 1.0 * UI_GRID_H;
            size = 0.6242 * UI_GRID_H;};
        class LzCart: Life_RscListBox {idc = 987631;
            x = -0.117 * UI_GRID_W + UI_GRID_X; y = -5.35 * UI_GRID_H + UI_GRID_Y; w = 16.415 * UI_GRID_W; h = 7.6 * UI_GRID_H;
            sizeEx = 0.5529 * UI_GRID_H;
            rowHeight = 1.05*UI_GRID_H;
            period = 0;
            colorText[] = {0.86,0.905,0.878,1};
            colorBackground[] = {0.047,0.09,0.07,0.6};
            colorSelectBackground[] = {0.55,0.1,0.1,0.30};
            colorSelectBackground2[] = {0.55,0.1,0.1,0.30};
            colorSelect[] = {0.95,0.98,0.92,1};
            colorSelect2[] = {0.95,0.98,0.92,1};};
        class LzRemove: Life_RscButtonMenu {idc = 987632;
            text = "REMOVE LINE";
            onButtonClick = "[""remove""] spawn life_fnc_loonazonApp;";
            x = -0.117 * UI_GRID_W + UI_GRID_X; y = 2.45 * UI_GRID_H + UI_GRID_Y; w = 16.415 * UI_GRID_W; h = 1.05 * UI_GRID_H;
            sizeEx = 0.6 * UI_GRID_H;
            colorText[] = {0.86,0.905,0.878,1};
            colorBackground[] = {0.30,0.09,0.09,0.85};
            colorBackground2[] = {0.45,0.14,0.14,0.85};};
        class LzMeters: Life_RscStructuredText {idc = 987640;
            text = "";
            x = -0.117 * UI_GRID_W + UI_GRID_X; y = 3.6 * UI_GRID_H + UI_GRID_Y; w = 16.415 * UI_GRID_W; h = 2.2 * UI_GRID_H;
            size = 0.55 * UI_GRID_H;};
        class LzTotal: Life_RscStructuredText {idc = 987641;
            text = "";
            x = -0.117 * UI_GRID_W + UI_GRID_X; y = 5.9 * UI_GRID_H + UI_GRID_Y; w = 16.415 * UI_GRID_W; h = 0.85 * UI_GRID_H;
            size = 0.6 * UI_GRID_H;};
        // Primary money CTA -- deck button fill, acid text for priority.
        class LzOrder: Life_RscButtonMenu {idc = 987650;
            text = "PLACE ORDER";
            onButtonClick = "[""order""] spawn life_fnc_loonazonApp;";
            x = -0.117 * UI_GRID_W + UI_GRID_X; y = 6.85 * UI_GRID_H + UI_GRID_Y; w = 10.4 * UI_GRID_W; h = 1.35 * UI_GRID_H;
            sizeEx = 0.7 * UI_GRID_H;
            colorText[] = {0.788,0.886,0.10,1};
            colorBackground[] = {0.09,0.16,0.12,1};
            colorBackground2[] = {0.16,0.28,0.14,1};
         colorDisabled[] = {0.78,0.82,0.62,0.8}; colorBackgroundDisabled[] = {0.10,0.13,0.08,0.92};};};};
