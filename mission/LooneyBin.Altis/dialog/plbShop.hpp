/*
    plbShop.hpp -- PROOF NIGHT CITY shop, mockup-exact (custom PAA chrome, no mod).
    LEFT: THE CLIP list panel -- "REBEL ARMS" + CASH IN HAND readout (gold mono; rebel shop deals in cash) +
    cyan gradient divider + a SCROLLABLE weapon list (rows ctrlCreate'd by life_fnc_plbShopDemo: faction badge /
    name / sub / gold mono price; selection = magenta badge + magenta row clip). RIGHT: focused detail card
    (magenta clip) -- preview inset, name, mint price PLATE (glow baked into nc_plate.paa, digits on top), meta
    line, segmented LOAD meter, full-width cyan BUY (picture + invisible button: animTexture on
    Life_RscButtonMenu does NOT render). BELOW it: scrollable MAGAZINES / ACCESSORIES panel.
    NOTES: structured text sizes from `size` (sizeEx IGNORED on CT_STRUCTURED_TEXT). Whole dialog scales off
    NC_S -- coords are authored in the original 0-1 layout and the parser evaluates the arithmetic, so one knob
    resizes everything (dialog units track interface size / resolution, so it stays proportional per player).
    ESC closes. Owner test !shopdemo. Not the live shop.
*/
#define NC_S 1.45
#define NCX(v) ((v) * NC_S - 0.225)
#define NCY(v) ((v) * NC_S - 0.2025)
#define NCW(v) ((v) * NC_S)
#define NCH(v) ((v) * NC_S)
#define NCT(v) ((v) * NC_S)

// ── ctrlCreate'd row templates (sizes pre-scaled: ctrlCreate bypasses the macros) ─────────────
class PLB_ShopRowBg: life_RscPicture { idc = -1; text = "images\ui\nc_row.paa"; };
class PLB_ShopRowIcon: life_RscPicture { idc = -1; text = ""; };
class PLB_ShopRowName: Life_RscStructuredText {idc = -1; text = ""; size = 0.0348; sizeEx = 0.0348;
    class Attributes { font = "PuristaMedium"; color = "#ebeff4"; align = "left"; shadow = 0; };};
class PLB_ShopRowSub: Life_RscStructuredText {idc = -1; text = ""; size = 0.0232; sizeEx = 0.0232;
    class Attributes { font = "PuristaLight"; color = "#8993a0"; align = "left"; shadow = 0; };};
class PLB_ShopRowPrice: Life_RscStructuredText {idc = -1; text = ""; size = 0.0334; sizeEx = 0.0334;
    class Attributes { font = "EtelkaMonospacePro"; color = "#c7a24e"; align = "right"; shadow = 0; };};
class PLB_AccRowName: Life_RscStructuredText {idc = -1; text = ""; size = 0.0247; sizeEx = 0.0247;
    class Attributes { font = "PuristaMedium"; color = "#ebeff4"; align = "left"; shadow = 0; };};
class PLB_AccRowPrice: Life_RscStructuredText {idc = -1; text = ""; size = 0.0232; sizeEx = 0.0232;
    class Attributes { font = "EtelkaMonospacePro"; color = "#c7a24e"; align = "right"; shadow = 0; };};

// ── the dialog ─────────────────────────────────────────────────────────────────────────────────
class PLB_Shop {idd = 515300;
    movingEnable = false;
    enableSimulation = true;
    onLoad = "uiNamespace setVariable ['PLB_Shop', _this select 0];";
    onUnload = "uiNamespace setVariable ['PLB_Shop', displayNull];";
    class controls {
        // ══ LEFT: list panel (cyan clip) ══
        class LeftPanel: life_RscPicture { idc = -1; text = "images\ui\nc_panel.paa"; x = NCX(0.06); y = NCY(0.14); w = NCW(0.56); h = NCH(0.62); };
        class Title: Life_RscStructuredText {
            idc = 515301; x = NCX(0.085); y = NCY(0.163); w = NCW(0.24); h = NCH(0.045); size = NCT(0.036); sizeEx = NCT(0.036); text = "";
            class Attributes { font = "PuristaSemibold"; color = "#ebeff4"; align = "left"; shadow = 0; };};
        // kept clear of THE CLIP shear at the panel's top-right; rebel shop deals in CASH
        class BankLabel: Life_RscStructuredText {
            idc = 515303; x = NCX(0.30); y = NCY(0.162); w = NCW(0.245); h = NCH(0.022); size = NCT(0.016); sizeEx = NCT(0.016); text = "CASH IN HAND";
            class Attributes { font = "PuristaMedium"; color = "#8993a0"; align = "right"; shadow = 0; };};
        class BankValue: Life_RscStructuredText {
            idc = 515302; x = NCX(0.30); y = NCY(0.183); w = NCW(0.245); h = NCH(0.040); size = NCT(0.030); sizeEx = NCT(0.030); text = "";
            class Attributes { font = "EtelkaMonospacePro"; color = "#c7a24e"; align = "right"; shadow = 0; };};
        // category tabs (live shop only; !shopdemo hides them). Label + cyan active underline + hit each.
        class Tab0Label: Life_RscStructuredText {
            idc = 515350; x = NCX(0.085); y = NCY(0.232); w = NCW(0.10); h = NCH(0.026); size = NCT(0.018); sizeEx = NCT(0.018); text = "";
            class Attributes { font = "PuristaSemibold"; color = "#8993a0"; align = "left"; shadow = 0; };};
        class Tab0Line: Life_RscText { idc = 515351; x = NCX(0.085); y = NCY(0.259); w = NCW(0.062); h = NCH(0.0035); colorBackground[] = { 0.216, 0.910, 0.941, 1 }; text = ""; };
        class Tab0Hit: Life_RscButtonInvisible { idc = -1; x = NCX(0.085); y = NCY(0.230); w = NCW(0.10); h = NCH(0.032); onButtonClick = "['tab', 0] call life_fnc_ncShop;"; };
        class Tab1Label: Life_RscStructuredText {
            idc = 515352; x = NCX(0.195); y = NCY(0.232); w = NCW(0.10); h = NCH(0.026); size = NCT(0.018); sizeEx = NCT(0.018); text = "";
            class Attributes { font = "PuristaSemibold"; color = "#8993a0"; align = "left"; shadow = 0; };};
        class Tab1Line: Life_RscText { idc = 515353; x = NCX(0.195); y = NCY(0.259); w = NCW(0.068); h = NCH(0.0035); colorBackground[] = { 0.216, 0.910, 0.941, 1 }; text = ""; };
        class Tab1Hit: Life_RscButtonInvisible { idc = -1; x = NCX(0.195); y = NCY(0.230); w = NCW(0.10); h = NCH(0.032); onButtonClick = "['tab', 1] call life_fnc_ncShop;"; };
        class Tab2Label: Life_RscStructuredText {
            idc = 515354; x = NCX(0.305); y = NCY(0.232); w = NCW(0.08); h = NCH(0.026); size = NCT(0.018); sizeEx = NCT(0.018); text = "";
            class Attributes { font = "PuristaSemibold"; color = "#8993a0"; align = "left"; shadow = 0; };};
        class Tab2Line: Life_RscText { idc = 515355; x = NCX(0.305); y = NCY(0.259); w = NCW(0.036); h = NCH(0.0035); colorBackground[] = { 0.216, 0.910, 0.941, 1 }; text = ""; };
        class Tab2Hit: Life_RscButtonInvisible { idc = -1; x = NCX(0.305); y = NCY(0.230); w = NCW(0.08); h = NCH(0.032); onButtonClick = "['tab', 2] call life_fnc_ncShop;"; };

        class Divider: life_RscPicture { idc = -1; text = "images\ui\nc_divider.paa"; x = NCX(0.085); y = NCY(0.2655); w = NCW(0.34); h = NCH(0.005); };
        // weapon rows get ctrlCreate'd into here -- SCROLLABLE (shortened to make room for the search bar below)
        class Rows: Life_RscControlsGroupOneScrollbar {idc = 515310; x = NCX(0.085); y = NCY(0.278); w = NCW(0.515); h = NCH(0.420);
            class controls {};};
        // ── search / filter bar UNDER the list (owner 2026-07-10): live-filters the scroll rows by name as
        //    you type. The typed text is only ever used in toLower/find (substring match) in fn_ncShop -- it
        //    is never compiled or executed, so there is no script-injection surface. ──
        class SearchBg: Life_RscText {idc = -1; x = NCX(0.085); y = NCY(0.704); w = NCW(0.515); h = NCH(0.033);
            colorBackground[] = { 0.09, 0.13, 0.19, 0.96 }; text = "";};
        class SearchEdge: Life_RscText {   // slim cyan left accent, matches the active-tab underline
            idc = -1; x = NCX(0.085); y = NCY(0.704); w = NCW(0.004); h = NCH(0.033);
            colorBackground[] = { 0.216, 0.910, 0.941, 1 }; text = "";};
        class SearchHint: Life_RscStructuredText {   // dim placeholder shown through the transparent edit when empty
            idc = 515361; x = NCX(0.100); y = NCY(0.7085); w = NCW(0.40); h = NCH(0.026); size = NCT(0.0185); sizeEx = NCT(0.0185); text = "Search...";
            class Attributes { font = "PuristaLight"; color = "#5b6572"; align = "left"; shadow = 0; };};
        class SearchInput: Life_RscEdit {idc = 515360; x = NCX(0.098); y = NCY(0.7065); w = NCW(0.495); h = NCH(0.029);
            colorBackground[] = { 0, 0, 0, 0 }; colorText[] = { 0.216, 0.910, 0.941, 1 };
            colorSelection[] = { 0.216, 0.910, 0.941, 0.35 };
            size = NCT(0.0185); sizeEx = NCT(0.0185); text = ""; font = "PuristaMedium"; maxChars = 24;};

        // ══ RIGHT: focused detail card (magenta clip -- the ONE bloom) ══
        class DetailPanel: life_RscPicture { idc = -1; text = "images\ui\nc_panel_focus.paa"; x = NCX(0.635); y = NCY(0.14); w = NCW(0.30); h = NCH(0.43); };
        class PreviewPane: life_RscPicture { idc = -1; text = "images\ui\nc_preview.paa"; x = NCX(0.651); y = NCY(0.158); w = NCW(0.268); h = NCH(0.160); };
        class PreviewCap: Life_RscStructuredText {
            idc = -1; x = NCX(0.659); y = NCY(0.165); w = NCW(0.14); h = NCH(0.022); size = NCT(0.014); sizeEx = NCT(0.014); text = "PREVIEW";
            class Attributes { font = "PuristaMedium"; color = "#8993a0"; align = "left"; shadow = 0; };};
        class PreviewIcon: Life_RscPictureKeepAspect { idc = 515320; text = ""; x = NCX(0.685); y = NCY(0.174); w = NCW(0.200); h = NCH(0.130); };
        class DetailName: Life_RscStructuredText {
            idc = 515321; x = NCX(0.651); y = NCY(0.326); w = NCW(0.268); h = NCH(0.030); size = NCT(0.021); sizeEx = NCT(0.021); text = "";
            class Attributes { font = "PuristaMedium"; color = "#8993a0"; align = "left"; shadow = 0; };};
        class PricePlate: life_RscPicture { idc = -1; text = "images\ui\nc_plate.paa"; x = NCX(0.651); y = NCY(0.356); w = NCW(0.150); h = NCH(0.060); };
        class PlateNum: Life_RscStructuredText {
            idc = 515323; x = NCX(0.660); y = NCY(0.366); w = NCW(0.138); h = NCH(0.044); size = NCT(0.038); sizeEx = NCT(0.038); text = "";
            class Attributes { font = "EtelkaMonospacePro"; color = "#53e39c"; align = "left"; shadow = 0; };};
        class Meta: Life_RscStructuredText {
            idc = 515322; x = NCX(0.651); y = NCY(0.424); w = NCW(0.268); h = NCH(0.028); size = NCT(0.017); sizeEx = NCT(0.017); text = "";
            class Attributes { font = "PuristaLight"; color = "#8993a0"; align = "left"; shadow = 0; };};
        class LoadLabel: Life_RscStructuredText {
            idc = -1; x = NCX(0.651); y = NCY(0.4535); w = NCW(0.045); h = NCH(0.022); size = NCT(0.015); sizeEx = NCT(0.015); text = "LOAD";
            class Attributes { font = "PuristaMedium"; color = "#8993a0"; align = "left"; shadow = 0; };};
        class LoadTrack: Life_RscText { idc = -1; x = NCX(0.702); y = NCY(0.458); w = NCW(0.158); h = NCH(0.010); colorBackground[] = { 0.157, 0.196, 0.247, 0.9 }; text = ""; };
        class LoadFill:  Life_RscText { idc = 515324; x = NCX(0.702); y = NCY(0.458); w = NCW(0.040); h = NCH(0.010); colorBackground[] = { 0.216, 0.910, 0.941, 1 }; text = ""; };
        class LoadOver:  life_RscPicture { idc = -1; text = "images\ui\nc_seg.paa"; x = NCX(0.702); y = NCY(0.458); w = NCW(0.158); h = NCH(0.010); };
        class LoadVal: Life_RscStructuredText {
            idc = 515325; x = NCX(0.858); y = NCY(0.4505); w = NCW(0.061); h = NCH(0.026); size = NCT(0.019); sizeEx = NCT(0.019); text = "";
            class Attributes { font = "EtelkaMonospacePro"; color = "#ebeff4"; align = "right"; shadow = 0; };};
        // BUY = cyan PAA picture + centred label + invisible click target (animTexture doesn't render on buttons)
        class BuyBg: life_RscPicture { idc = -1; text = "images\ui\nc_btn_cyan.paa"; x = NCX(0.651); y = NCY(0.483); w = NCW(0.268); h = NCH(0.046); };
        class BuyLabel: Life_RscStructuredText {
            idc = -1; x = NCX(0.651); y = NCY(0.4895); w = NCW(0.268); h = NCH(0.034); size = NCT(0.030); sizeEx = NCT(0.030); text = "BUY";
            class Attributes { font = "PuristaSemibold"; color = "#0b131a"; align = "center"; shadow = 0; };};
        // dispatch: whoever built the dialog (demo or the live ncShop) sets PLB_ShopBuyFn. Spawned -- the live
        // buy uses blocking BIS_fnc_guiMessage prompts.
        class BuyHit: Life_RscButtonInvisible {idc = 515330; x = NCX(0.651); y = NCY(0.483); w = NCW(0.268); h = NCH(0.046);
            onButtonClick = "[] spawn (uiNamespace getVariable ['PLB_ShopBuyFn', {}]);";};

        // ══ BELOW the detail card: scrollable magazines / accessories for the selected weapon ══
        class AccPanel: life_RscPicture { idc = -1; text = "images\ui\nc_panel_wide.paa"; x = NCX(0.635); y = NCY(0.585); w = NCW(0.30); h = NCH(0.175); };
        class AccHeader: Life_RscStructuredText {
            idc = -1; x = NCX(0.651); y = NCY(0.597); w = NCW(0.27); h = NCH(0.024); size = NCT(0.016); sizeEx = NCT(0.016); text = "MAGAZINES / ACCESSORIES";
            class Attributes { font = "PuristaMedium"; color = "#8993a0"; align = "left"; shadow = 0; };};
        // addon rows get ctrlCreate'd into here -- SCROLLABLE
        class AccRows: Life_RscControlsGroupOneScrollbar {idc = 515340; x = NCX(0.651); y = NCY(0.624); w = NCW(0.272); h = NCH(0.124);
            class controls {};};};};
